#!/usr/bin/env python3
"""Watch the Apple pages this app cites, and report the ones that changed.

    python3 scripts/apple-watch.py                  check every source, write changes.json
    python3 scripts/apple-watch.py --update-lock    re-fetch and record new hashes
    python3 scripts/apple-watch.py --only buttons   limit either mode to matching sources
    python3 scripts/apple-watch.py --sources        rebuild apple-sources.json from the Swift files

apple-sources.json maps each Apple URL to the Swift files that cite it, plus
a few "signal" pages (Apple's change logs and the App Review Guidelines).
apple-sources.lock.json holds one hash per page and per section, never
Apple's text: the repo is public, and AGENTS.md forbids copying Apple's words.

Docs and HIG pages are fetched as markdown (Apple serves it when the URL ends
in .md). Every other page is HTML, and only its main article text is kept.
Before hashing, the text is normalized so noise doesn't count as change: the
metadata comment keeps only title and availability, images are dropped (art
refreshes often), and whitespace is collapsed. A page that moves, redirects,
or starts returning 404 counts as changed too, which catches link rot.

A check exits 0 whatever it finds and prints "changed: N". Fetch errors
(timeouts, 5xx after retries) are listed in changes.json but never counted as
changes, and --update-lock keeps the old entry for them. Python stdlib only.
"""

from __future__ import annotations

import argparse
import concurrent.futures
import datetime
import hashlib
import html
import html.parser
import json
import os
import re
import sys
import threading
import time
import urllib.error
import urllib.parse
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SWIFT_ROOT = "SwiftUIForHumans"
SOURCES_FILE = "apple-sources.json"
LOCK_FILE = "apple-sources.lock.json"
CHANGES_FILE = "changes.json"

USER_AGENT = (
    "swiftui-for-humans-apple-watch/1.0 "
    "(+https://github.com/tylerbecks/swiftui-for-humans; checks cited pages for changes)"
)
REQUESTS_PER_SECOND = 2.0
WORKERS = 4
TIMEOUT = 30
RETRIES = 3

# Pages that change often for reasons that don't matter to the app, or aren't
# pages at all. Matched against the URL without its fragment.
EXCLUDE = [
    re.compile(r"^https?://maps\.apple\.com/"),  # a map link in a demo
    re.compile(r"^https?://apps\.apple\.com/"),  # placeholder App Store links
    re.compile(r"^https?://www\.apple\.com/DTDs/"),  # plist DTD in a code sample
    re.compile(r"^https?://www\.apple\.com/?$"),  # home page
    re.compile(r"^https?://www\.apple\.com/privacy/?$"),  # marketing page
    re.compile(r"^https?://developer\.apple\.com/?$"),  # home page
]

# Hosts worth watching. Anything else on apple.com is ignored.
WATCHED_HOSTS = {"developer.apple.com", "support.apple.com", "www.apple.com"}

# Apple's change logs and the review rules. They tell us something moved even
# when no cited page did, so the update job can spot new APIs and guidelines.
SIGNALS = [
    "https://developer.apple.com/documentation/updates/swiftui",
    "https://developer.apple.com/documentation/updates/uikit",
    "https://developer.apple.com/documentation/updates/appkit",
    "https://developer.apple.com/documentation/updates/foundation",
    "https://developer.apple.com/documentation/updates/accessibility",
    "https://developer.apple.com/documentation/updates/storekit",
    "https://developer.apple.com/documentation/updates/swiftcharts",
    "https://developer.apple.com/documentation/updates/mapkit",
    "https://developer.apple.com/documentation/updates/tipkit",
    "https://developer.apple.com/documentation/updates/xcode",
    "https://developer.apple.com/app-store/review/guidelines/",
    "https://developer.apple.com/help/app-store-connect/release-notes/",
    "https://developer.apple.com/news/upcoming-requirements/",
]

URL_RE = re.compile(r"""https?://(?:[a-z0-9-]+\.)*apple\.com(?:/[^\s"'<>\\`]*)?""", re.I)
PAGE_ID_RE = re.compile(r"""ComponentPage\(\s*id:\s*"([^"]+)\"""")


# ---------------------------------------------------------------- utilities


def rel(path: str) -> str:
    relative = os.path.relpath(path, ROOT)
    return path if relative.startswith("..") else relative


def short_hash(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:16]


def load_json(path: str, default):
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return default


def write_json(path: str, data) -> None:
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, sort_keys=True, ensure_ascii=False)
        f.write("\n")


def strip_fragment(url: str) -> str:
    return urllib.parse.urldefrag(url)[0]


def clean_url(raw: str) -> str:
    """Trims punctuation a regex sweep picks up after a URL in prose or code."""
    url = raw.rstrip(".,;:!?*")
    # Drop unbalanced closing parentheses, as in "(see https://…/foo)".
    while url.endswith(")") and url.count(")") > url.count("("):
        url = url[:-1]
    return url


def is_markdown_url(url: str) -> bool:
    path = urllib.parse.urlsplit(url).path
    return path.startswith("/documentation/") or path.startswith("/design/human-interface-guidelines/")


def fetch_url(url: str) -> str:
    """The URL actually requested: the .md version where Apple serves one."""
    if is_markdown_url(url):
        parts = urllib.parse.urlsplit(url)
        return urllib.parse.urlunsplit(parts._replace(path=parts.path.rstrip("/") + ".md"))
    return url


def watched(url: str) -> bool:
    host = urllib.parse.urlsplit(url).hostname or ""
    if host not in WATCHED_HOSTS:
        return False
    return not any(p.search(url) for p in EXCLUDE)


# ------------------------------------------------------------ source sweep


def sweep_sources() -> dict:
    """Every watched apple.com URL in the Swift sources → the files citing it."""
    found: dict[str, dict] = {}
    base = os.path.join(ROOT, SWIFT_ROOT)
    for dirpath, dirnames, filenames in os.walk(base):
        dirnames.sort()
        for name in sorted(filenames):
            if not name.endswith(".swift"):
                continue
            path = os.path.join(dirpath, name)
            with open(path, encoding="utf-8") as f:
                text = f.read()
            page_ids = PAGE_ID_RE.findall(text)
            for match in URL_RE.finditer(text):
                cited = clean_url(match.group(0))
                url = strip_fragment(cited)
                if not watched(url):
                    continue
                entry = found.setdefault(url, {"files": set(), "pages": set(), "cited": set()})
                entry["files"].add(rel(path))
                entry["pages"].update(page_ids)
                if cited != url:
                    entry["cited"].add(cited)
    sources = {}
    for url, entry in found.items():
        sources[url] = {
            "files": sorted(entry["files"]),
            "pages": sorted(entry["pages"]),
        }
        if entry["cited"]:
            sources[url]["anchors"] = sorted(urllib.parse.urldefrag(c)[1] for c in entry["cited"])
    for url in SIGNALS:
        sources.setdefault(url, {"files": [], "pages": []})["signal"] = True
    return dict(sorted(sources.items()))


def sources_document(sources: dict) -> dict:
    return {
        "about": (
            "Apple pages cited by the app, and the Swift files that cite them. "
            "Generated by `python3 scripts/apple-watch.py --sources`; don't edit by hand. "
            "Signal pages are Apple's change logs, watched for new APIs and rules."
        ),
        "sources": sources,
    }


# ----------------------------------------------------------------- fetching


class RateLimiter:
    def __init__(self, per_second: float):
        self.interval = 1.0 / per_second
        self.lock = threading.Lock()
        self.next = 0.0

    def wait(self) -> None:
        with self.lock:
            now = time.monotonic()
            start = max(now, self.next)
            self.next = start + self.interval
        delay = start - time.monotonic()
        if delay > 0:
            time.sleep(delay)


def fetch(url: str, limiter: RateLimiter) -> dict:
    """Returns {status, final, body, kind} or {error}. Kind follows the response's type."""
    target = fetch_url(url)
    kind = "md" if is_markdown_url(url) else "html"
    last_error = ""
    for attempt in range(RETRIES):
        limiter.wait()
        request = urllib.request.Request(
            target,
            headers={"User-Agent": USER_AGENT, "Accept": "text/markdown, text/html;q=0.9, */*;q=0.1"},
        )
        try:
            with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
                body = response.read().decode("utf-8", "replace")
                ctype = response.headers.get("Content-Type", "")
                return {"status": response.status, "final": response.geturl(), "body": body,
                        "kind": "md" if "markdown" in ctype else "html"}
        except urllib.error.HTTPError as error:
            if error.code in (404, 410, 403, 401, 400):
                return {"status": error.code, "final": error.geturl() or target, "body": "", "kind": kind}
            last_error = f"HTTP {error.code}"
        except (urllib.error.URLError, TimeoutError, ConnectionError, OSError) as error:
            last_error = f"{type(error).__name__}: {getattr(error, 'reason', error)}"
        time.sleep(2 ** attempt * 2)
    return {"error": last_error}


# ------------------------------------------------------------ normalization


FENCE_RE = re.compile(r"^\s*(```|~~~)")
HEADING_RE = re.compile(r"^(#{2,3})\s+(.+?)\s*#*\s*$")
IMAGE_RE = re.compile(r"!\[[^\]]*\]\([^)]*\)")
META_RE = re.compile(r"\A\s*<!--(.*?)-->", re.S)


COPYRIGHT_RE = re.compile(r"^\s*(?:Copyright\s*)?(?:©|&copy;)\s*\d{4}.*$", re.I)
RULE_RE = re.compile(r"^\s*(?:-{3,}|\*{3,}|_{3,})\s*$")


def collapse(text: str) -> str:
    return " ".join(html.unescape(text).split())


def is_noise(line: str) -> bool:
    """Lines that change for reasons unrelated to content: the yearly
    copyright footer and horizontal rules."""
    return bool(COPYRIGHT_RE.match(line) or RULE_RE.match(line))


def split_sections(lines: list[str]) -> list[tuple[str, str]]:
    """Splits markdown on ## and ### headings (outside code fences)."""
    sections: list[tuple[str, list[str]]] = [("(intro)", [])]
    in_fence = False
    for line in lines:
        if FENCE_RE.match(line):
            in_fence = not in_fence
        elif not in_fence and is_noise(line):
            continue
        heading = None if in_fence else HEADING_RE.match(line)
        if heading:
            sections.append((collapse(heading.group(2)), []))
        else:
            sections[-1][1].append(line)
    named: list[tuple[str, str]] = []
    seen: dict[str, int] = {}
    for name, body in sections:
        seen[name] = seen.get(name, 0) + 1
        if seen[name] > 1:
            name = f"{name} #{seen[name]}"
        text = collapse("\n".join(body))
        if text or name != "(intro)":
            named.append((name, text))
    return named


def normalize_markdown(body: str) -> list[tuple[str, str]]:
    meta_lines = []
    match = META_RE.match(body)
    if match:
        body = body[match.end():]
        try:
            meta = json.loads(match.group(1))
        except ValueError:
            meta = {}
        if meta.get("title"):
            meta_lines.append(f"title: {meta['title']}")
        if meta.get("availability"):
            meta_lines.append("availability: " + ", ".join(map(str, meta["availability"])))
    lines = [IMAGE_RE.sub("", line) for line in body.splitlines()]
    sections = split_sections(lines)
    if meta_lines:
        sections.insert(0, ("(metadata)", collapse("\n".join(meta_lines))))
    return sections


class ArticleText(html.parser.HTMLParser):
    """Collects the text of the first <article> (or <main>, or <body>) as markdown-ish lines."""

    SKIP = {"script", "style", "noscript", "svg", "template", "nav", "footer", "form", "button", "iframe"}
    BLOCK = {"p", "div", "section", "li", "ul", "ol", "table", "tr", "td", "th", "br", "dd", "dt",
             "blockquote", "pre", "figure", "figcaption", "header", "aside", "hr"}
    VOID = {"area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "source", "track", "wbr"}

    def __init__(self, container: str, container_id: str | None = None):
        super().__init__(convert_charrefs=True)
        self.container = container
        self.container_id = container_id  # when set, the container is the element with this id
        self.depth = 0  # nesting of the container tag; > 0 while inside it
        self.done = False
        self.skip = 0
        self.lines: list[str] = []
        self.current: list[str] = []
        self.heading: str | None = None
        self.title_parts: list[str] = []
        self.in_title = False

    def flush(self) -> None:
        text = " ".join("".join(self.current).split())
        if text:
            self.lines.append(f"{self.heading} {text}" if self.heading else text)
        self.current = []

    def handle_starttag(self, tag, attrs):
        if tag == "title":
            self.in_title = True
        if self.done:
            return
        if tag == self.container and (self.depth or not self.container_id or dict(attrs).get("id") == self.container_id):
            self.depth += 1
            return
        if self.depth and not self.skip:
            # The App Review Guidelines mark each numbered guideline (2.1, 4.2, …)
            # with data-sidenav, so each becomes its own section.
            sidenav = dict(attrs).get("data-sidenav")
            if sidenav and sidenav.strip():
                self.flush()
                self.lines.append(f"### {collapse(sidenav)}")
        if self.depth == 0 or tag in self.VOID:
            if self.depth and tag == "br":
                self.flush()
            return
        if tag in self.SKIP:
            self.skip += 1
        elif not self.skip and re.fullmatch(r"h[1-6]", tag):
            self.flush()
            level = int(tag[1])
            self.heading = "#" * level if level <= 3 else "####"
        elif not self.skip and tag in self.BLOCK:
            self.flush()

    def handle_endtag(self, tag):
        if tag == "title":
            self.in_title = False
        if self.done or self.depth == 0:
            return
        if tag == self.container:
            self.depth -= 1
            if self.depth == 0:
                self.flush()
                self.done = True
            return
        if tag in self.SKIP and self.skip:
            self.skip -= 1
        elif not self.skip and re.fullmatch(r"h[1-6]", tag):
            self.flush()
            self.heading = None
        elif not self.skip and tag in self.BLOCK:
            self.flush()

    def handle_data(self, data):
        if self.in_title:
            self.title_parts.append(data)
        if self.depth and not self.skip and not self.done:
            self.current.append(data)


def html_title(body: str) -> str:
    match = re.search(r"<title[^>]*>(.*?)</title>", body, re.S | re.I)
    return collapse(match.group(1)) if match else ""


def normalize_html(body: str) -> list[tuple[str, str]]:
    lowered = body.lower()
    if "<article" in lowered:
        parser = ArticleText("article")
    elif re.search(r"""id=["']article-section["']""", lowered):  # support.apple.com guides
        parser = ArticleText("div", "article-section")
    elif "<main" in lowered:
        parser = ArticleText("main")
    else:
        parser = ArticleText("body")
    parser.feed(body)
    parser.close()
    parser.flush()
    sections = split_sections(parser.lines)
    title = html_title(body)
    if title:
        sections.insert(0, ("(metadata)", f"title: {title}"))
    return sections


def is_soft_404(body: str) -> bool:
    """Apple's help pages answer 200 with a "Page Not Found" page."""
    return html_title(body).lower().startswith("page not found")


# ------------------------------------------------------------------ hashing


def snapshot(url: str, result: dict) -> dict:
    """A lock entry: status, final URL if it moved, and hashes (never text)."""
    status = result["status"]
    body = result["body"]
    if status == 200 and result["kind"] == "html" and is_soft_404(body):
        status = 404
    entry: dict = {"status": status}
    final = strip_fragment(result.get("final") or "")
    if final and final != fetch_url(url):
        entry["final"] = final
    if status != 200 or not body:
        return entry
    sections = normalize_markdown(body) if result["kind"] == "md" else normalize_html(body)
    entry["hash"] = short_hash("\n".join(f"{name}\n{text}" for name, text in sections))
    entry["sections"] = {short_hash(name): short_hash(text) for name, text in sections}
    entry["_names"] = {short_hash(name): name for name, _ in sections}  # stripped before writing
    return entry


def public(entry: dict) -> dict:
    return {k: v for k, v in entry.items() if not k.startswith("_")}


def compare(old: dict, new: dict) -> dict | None:
    """What differs between two lock entries, or None."""
    reasons = []
    detail: dict = {}
    if old.get("status") != new.get("status"):
        reasons.append("status")
        detail["status"] = {"old": old.get("status"), "new": new.get("status")}
    if old.get("final") != new.get("final"):
        reasons.append("redirect")
        detail["final_url"] = {"old": old.get("final"), "new": new.get("final")}
    if new.get("status") == 200 and old.get("hash") != new.get("hash"):
        reasons.append("content")
        old_sections = old.get("sections", {})
        new_sections = new.get("sections", {})
        names = new.get("_names", {})
        detail["sections"] = {
            "changed": [names[h] for h in new_sections if h in old_sections and old_sections[h] != new_sections[h]],
            "added": [names[h] for h in new_sections if h not in old_sections],
            "removed": sum(1 for h in old_sections if h not in new_sections),
        }
    if not reasons:
        return None
    return {"reasons": reasons, **detail}


# --------------------------------------------------------------------- main


def select(sources: dict, only: str | None) -> dict:
    if not only:
        return sources
    needle = only.lower()
    return {
        url: info for url, info in sources.items()
        if needle in url.lower()
        or any(needle in f.lower() for f in info.get("files", []))
        or any(needle in p.lower() for p in info.get("pages", []))
    }


def fetch_all(urls: list[str]) -> dict[str, dict]:
    limiter = RateLimiter(REQUESTS_PER_SECOND)
    results: dict[str, dict] = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=WORKERS) as pool:
        futures = {pool.submit(fetch, url, limiter): url for url in urls}
        for done, future in enumerate(concurrent.futures.as_completed(futures), 1):
            url = futures[future]
            try:
                results[url] = future.result()
            except Exception as error:  # a parser bug shouldn't sink the run
                results[url] = {"error": f"{type(error).__name__}: {error}"}
            if done % 50 == 0 or done == len(urls):
                print(f"  fetched {done}/{len(urls)}", file=sys.stderr)
    return results


def github_output(**values) -> None:
    path = os.environ.get("GITHUB_OUTPUT")
    if path:
        with open(path, "a", encoding="utf-8") as f:
            for key, value in values.items():
                f.write(f"{key}={value}\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--update-lock", action="store_true", help="re-fetch and write new hashes to the lockfile")
    parser.add_argument("--only", metavar="SUBSTR", help="only sources whose URL, citing file, or page id contains SUBSTR")
    parser.add_argument("--sources", action="store_true", help="rebuild apple-sources.json from the Swift sources")
    parser.add_argument("--sources-file", default=os.path.join(ROOT, SOURCES_FILE), help=argparse.SUPPRESS)
    parser.add_argument("--lock-file", default=os.path.join(ROOT, LOCK_FILE), help=argparse.SUPPRESS)
    parser.add_argument("--out", default=os.path.join(ROOT, CHANGES_FILE), help="where to write changes.json")
    args = parser.parse_args()

    if args.sources:
        sources = sweep_sources()
        write_json(args.sources_file, sources_document(sources))
        signals = sum(1 for s in sources.values() if s.get("signal"))
        print(f"wrote {rel(args.sources_file)}: {len(sources)} URLs ({signals} signal pages)")
        if not args.update_lock:
            return 0

    document = load_json(args.sources_file, None)
    if document is None:
        print(f"{rel(args.sources_file)} is missing; run with --sources first", file=sys.stderr)
        return 2
    all_sources = document["sources"]
    sources = select(all_sources, args.only)
    if not sources:
        print(f"no sources match {args.only!r}", file=sys.stderr)
        return 2

    lock = load_json(args.lock_file, {"pages": {}})
    locked = lock.setdefault("pages", {})
    print(f"checking {len(sources)} Apple pages…", file=sys.stderr)
    results = fetch_all(list(sources))

    errors = []
    snapshots: dict[str, dict] = {}
    for url in sources:
        result = results[url]
        if "error" in result:
            errors.append({"url": url, "error": result["error"]})
        else:
            snapshots[url] = snapshot(url, result)

    if args.update_lock:
        for url, entry in snapshots.items():
            locked[url] = public(entry)
        if not args.only:
            for url in [u for u in locked if u not in all_sources]:
                del locked[url]
        lock["about"] = (
            "Hashes of the Apple pages in apple-sources.json, per page and per section. "
            "Hashes only, never Apple's text. Refresh with `python3 scripts/apple-watch.py --update-lock`."
        )
        lock["pages"] = dict(sorted(locked.items()))
        write_json(args.lock_file, lock)
        print(f"updated {len(snapshots)} entries in {rel(args.lock_file)}"
              + (f"; kept old entries for {len(errors)} fetch errors" if errors else ""))
        for error in errors:
            print(f"  error: {error['url']}: {error['error']}", file=sys.stderr)
        return 0

    changes = []
    unbaselined = []
    for url, entry in snapshots.items():
        if url not in locked:
            unbaselined.append(url)
            continue
        diff = compare(locked[url], entry)
        if diff:
            info = sources[url]
            changes.append({
                "url": url,
                "fetched": fetch_url(url),
                "signal": bool(info.get("signal")),
                "files": info.get("files", []),
                "pages": info.get("pages", []),
                **({"anchors": info["anchors"]} if info.get("anchors") else {}),
                **diff,
            })

    stale = False
    if not args.only:
        stale = sweep_sources() != all_sources

    affected_files = sorted({f for c in changes for f in c["files"]})
    report = {
        "generated": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "only": args.only,
        "checked": len(sources),
        "changed": len(changes),
        "affected_files": affected_files,
        "changes": changes,
        "errors": errors,
        "unbaselined": unbaselined,
        "sources_stale": stale,
    }
    write_json(args.out, report)

    for change in changes:
        print(f"  changed ({', '.join(change['reasons'])}): {change['url']}")
    for error in errors:
        print(f"  error (not counted): {error['url']}: {error['error']}", file=sys.stderr)
    if unbaselined:
        print(f"  {len(unbaselined)} sources have no lock entry yet; run --update-lock", file=sys.stderr)
    if stale:
        print("  apple-sources.json is out of date with the Swift sources; run --sources", file=sys.stderr)
    print(f"changed: {len(changes)} (affected files: {len(affected_files)}, errors: {len(errors)}) → {rel(args.out)}")
    github_output(changed=len(changes), files=len(affected_files), errors=len(errors))
    return 0


if __name__ == "__main__":
    sys.exit(main())
