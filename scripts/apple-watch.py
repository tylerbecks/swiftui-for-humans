#!/usr/bin/env python3
"""Watch the Apple pages this app cites, and report the ones that changed.

    python3 scripts/apple-watch.py                  check every source, write changes.json
    python3 scripts/apple-watch.py --update-lock    re-fetch and record new hashes
    python3 scripts/apple-watch.py --update-lock --from-changes changes.json
                                                    record only what a check reported
    python3 scripts/apple-watch.py --only buttons   limit either mode to matching sources
    python3 scripts/apple-watch.py --sources        rebuild apple-sources.json from the sources
    python3 scripts/apple-watch.py --self-test      offline checks of fetch handling (no network)

apple-sources.json maps each Apple URL to the files that cite it (the Swift
pages, plus the agent pack's sources in agent/src/**/*.yaml and *.md), and
adds a few "signal" pages (Apple's change logs and the App Review
Guidelines). apple-sources.lock.json holds one hash per page and per section,
never Apple's text: the repo is public, and AGENTS.md forbids copying Apple's
words.

Index pages (INDEXES: the HIG index, the HIG's What's New, the SwiftUI topic
index, and the list of change logs) are watched as link sets instead, one
hash per link, expanded one level where it helps. A link that appears and
that the app doesn't cite yet is reported in changes.json as `new_pages`, so
the update job can suggest new pages.

Docs and HIG pages are fetched as markdown (Apple serves it when the URL ends
in .md). Every other page is HTML, and only its main article text is kept.
Before hashing, the text is normalized so noise doesn't count as change: the
metadata comment keeps only title and availability, images are dropped (art
refreshes often), generated relationship lists (Conforms To and the like) are
dropped, and whitespace is collapsed. A page that moves, redirects,
or starts returning 404 or 410 counts as changed too, which catches link rot.

Only 404 and 410 count as status changes. 403, 429, 5xx, timeouts, and
network errors are transient: they are retried with backoff, then listed as
fetch errors in changes.json, never counted as changes, and --update-lock
keeps the old entry for them. If more than 20% of the fetches fail, Apple is
probably blocking or down: the run stops early, writes nothing, and exits 3,
so the update job never runs on a partial picture.

A successful check exits 0 whatever it finds and prints "changed: N".
changes.json also holds flood_hash, a stable hash of the sorted set of
changed URLs, which the workflow uses to skip a flood it already reported.
Python stdlib only.
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
import random
import re
import sys
import threading
import time
import urllib.error
import urllib.parse
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SWIFT_ROOT = "SwiftUIForHumans"
AGENT_SRC = os.path.join("agent", "src")  # agent-only sources; *.yaml and *.md are swept
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
RETRIES = 4  # attempts per page for transient failures
BACKOFF = 2.0  # seconds before the first retry; doubles each time
MAX_BACKOFF = 60.0  # cap, including a server's Retry-After
MAX_ERROR_RATIO = 0.20  # more fetch errors than this and the run writes nothing

GONE = {404, 410}  # the only statuses that count as a status change
THROTTLED = {403, 429}  # Apple's CDN answers these when it rate-limits; transient

# Pages that change often for reasons that don't matter to the app, or aren't
# pages at all. Matched against the URL without its fragment.
EXCLUDE = [
    re.compile(r"^https?://maps\.apple\.com/"),  # a map link in a demo
    re.compile(r"^https?://apps\.apple\.com/"),  # placeholder App Store links
    re.compile(r"^https?://www\.apple\.com/DTDs/"),  # plist DTD in a code sample
    re.compile(r"^https?://www\.apple\.com/?$"),  # home page
    re.compile(r"^https?://www\.apple\.com/privacy/?$"),  # marketing page
    re.compile(r"^https?://developer\.apple\.com/?$"),  # home page
    re.compile(r"^https?://support\.apple\.com/?$"),  # home page, in a code sample
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
    "https://developer.apple.com/documentation/updates/swift",
    "https://developer.apple.com/documentation/updates/swiftdata",
    "https://developer.apple.com/documentation/updates/symbols",
    "https://developer.apple.com/documentation/updates/appintents",
    "https://developer.apple.com/documentation/updates/widgetkit",
    "https://developer.apple.com/documentation/updates/activitykit",
    "https://developer.apple.com/documentation/updates/photokit",
    "https://developer.apple.com/documentation/updates/usernotifications",
    "https://developer.apple.com/documentation/updates/authenticationservices",
    "https://developer.apple.com/documentation/updates/foundationmodels",
    "https://developer.apple.com/design/whats-new/",
    "https://developer.apple.com/app-store/review/guidelines/",
    "https://developer.apple.com/help/app-store-connect/release-notes/",
    "https://developer.apple.com/news/upcoming-requirements/",
]

# Index pages, watched as link sets to spot pages Apple adds that the app
# doesn't cite yet: a new HIG guideline, a new SwiftUI view or modifier, a
# change log for a new framework. Each index keeps the links whose path starts
# with `prefix`. With `expand`, the pages it links to under that prefix are
# fetched too and their links join the set, one level deep (the HIG's
# category pages list its guidelines; SwiftUI's topic pages list its symbols).
# The lockfile stores a hash per link, never the link text.
INDEXES = {
    "https://developer.apple.com/design/human-interface-guidelines": {
        "prefix": "/design/human-interface-guidelines/", "expand": True},
    "https://developer.apple.com/design/whats-new/": {
        "prefix": "/design/human-interface-guidelines/", "expand": False},
    "https://developer.apple.com/documentation/swiftui": {
        "prefix": "/documentation/swiftui/", "expand": True},
    "https://developer.apple.com/documentation/updates": {
        "prefix": "/documentation/updates/", "expand": False},
}

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
    return (path.startswith("/documentation/") or path.startswith("/design/human-interface-guidelines/")
            or path == "/design/human-interface-guidelines")


def fetch_url(url: str) -> str:
    """The URL actually requested: the .md version where Apple serves one."""
    if is_markdown_url(url):
        parts = urllib.parse.urlsplit(url)
        return urllib.parse.urlunsplit(parts._replace(path=parts.path.rstrip("/") + ".md"))
    return url


def canonical(url: str) -> str:
    """One key per page: no fragment, and no .md on docs and HIG URLs (the
    agent sources cite the .md form; fetch_url adds it back)."""
    url = strip_fragment(url)
    if is_markdown_url(url) and url.endswith(".md"):
        url = url[: -len(".md")]
    return url


def change_set_hash(urls) -> str:
    """A stable hash of a set of URLs: order and duplicates don't matter."""
    unique = sorted(set(urls))
    return short_hash("\n".join(unique)) if unique else ""


def watched(url: str) -> bool:
    host = urllib.parse.urlsplit(url).hostname or ""
    if host not in WATCHED_HOSTS:
        return False
    return not any(p.search(url) for p in EXCLUDE)


# ------------------------------------------------------------ source sweep


def source_files():
    """The files swept for Apple URLs: Swift pages, then the agent sources."""
    for top, suffixes in ((SWIFT_ROOT, (".swift",)), (AGENT_SRC, (".yaml", ".md"))):
        for dirpath, dirnames, filenames in os.walk(os.path.join(ROOT, top)):
            dirnames.sort()
            for name in sorted(filenames):
                if name.endswith(suffixes):
                    yield os.path.join(dirpath, name)


def sweep_sources() -> dict:
    """Every watched apple.com URL in the sources → the files citing it."""
    found: dict[str, dict] = {}
    for path in source_files():
        with open(path, encoding="utf-8") as f:
            text = f.read()
        # Page ids come only from Swift pages; agent topics aren't app pages.
        page_ids = PAGE_ID_RE.findall(text) if path.endswith(".swift") else []
        for match in URL_RE.finditer(text):
            cited = clean_url(match.group(0))
            fragment = urllib.parse.urldefrag(cited)[1]
            url = canonical(cited)
            if not watched(url):
                continue
            entry = found.setdefault(url, {"files": set(), "pages": set(), "anchors": set()})
            entry["files"].add(rel(path))
            entry["pages"].update(page_ids)
            if fragment:
                entry["anchors"].add(fragment)
    sources = {}
    for url, entry in found.items():
        sources[url] = {
            "files": sorted(entry["files"]),
            "pages": sorted(entry["pages"]),
        }
        if entry["anchors"]:
            sources[url]["anchors"] = sorted(entry["anchors"])
    for url in SIGNALS:
        sources.setdefault(url, {"files": [], "pages": []})["signal"] = True
    for url, index in INDEXES.items():
        sources.setdefault(url, {"files": [], "pages": []})["index"] = dict(index)
    return dict(sorted(sources.items()))


def sources_document(sources: dict) -> dict:
    return {
        "about": (
            "Apple pages cited by the app, and the Swift files that cite them. "
            "Generated by `python3 scripts/apple-watch.py --sources`; don't edit by hand. "
            "Signal pages are Apple's change logs, watched for new APIs and rules. "
            "Index pages are watched as link sets, to spot pages Apple adds."
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

    def pause(self, seconds: float) -> None:
        """Holds every worker back, as when Apple's CDN starts throttling."""
        with self.lock:
            self.next = max(self.next, time.monotonic() + seconds)


def retry_after(error: urllib.error.HTTPError) -> float | None:
    value = error.headers.get("Retry-After") if error.headers is not None else None
    try:
        return max(0.0, float(value))
    except (TypeError, ValueError):
        return None  # an HTTP date or nothing; fall back to our own backoff


def is_transient(status: int) -> bool:
    return status in THROTTLED or 500 <= status <= 599


def fetch(url: str, limiter: RateLimiter, abort: threading.Event | None = None) -> dict:
    """Returns {status, final, body, kind} or {error}. Kind follows the response's type.

    Only 200s and 404/410 come back with a status. Throttling (403, 429), server
    errors, and network failures are retried with backoff, then returned as
    {error}, so they can never be mistaken for a page that changed or vanished.
    Any other HTTP error is returned as {error} right away."""
    target = fetch_url(url)
    kind = "md" if is_markdown_url(url) else "html"
    last_error = ""
    for attempt in range(RETRIES):
        if abort is not None and abort.is_set():
            return {"error": f"skipped after too many fetch errors ({last_error or 'not tried'})"}
        limiter.wait()
        request = urllib.request.Request(
            target,
            headers={"User-Agent": USER_AGENT, "Accept": "text/markdown, text/html;q=0.9, */*;q=0.1"},
        )
        delay = min(BACKOFF * 2 ** attempt, MAX_BACKOFF)
        try:
            with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
                body = response.read().decode("utf-8", "replace")
                ctype = response.headers.get("Content-Type", "")
                return {"status": response.status, "final": response.geturl(), "body": body,
                        "kind": "md" if "markdown" in ctype else "html"}
        except urllib.error.HTTPError as error:
            if error.code in GONE:
                return {"status": error.code, "final": error.geturl() or target, "body": "", "kind": kind}
            last_error = f"HTTP {error.code}"
            if not is_transient(error.code):
                return {"error": last_error}
            waited = retry_after(error)
            if waited is not None:
                delay = min(max(delay, waited), MAX_BACKOFF)
            if error.code in THROTTLED:
                limiter.pause(delay)  # slow everyone down, not just this worker
        except (urllib.error.URLError, TimeoutError, ConnectionError, OSError) as error:
            last_error = f"{type(error).__name__}: {getattr(error, 'reason', error)}"
        if attempt + 1 < RETRIES:
            time.sleep(delay + random.uniform(0, delay / 4))
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


# Generated relationship lists on symbol pages. Apple regenerates them across
# the whole site (on 2026-10-26 one rebuild touched 46 cited pages at once),
# and no page in the app discusses conformances, so they're left out.
IGNORED_SECTIONS = {"Conforms To", "Conforming Types", "Inherits From", "Inherited By"}


def split_sections(lines: list[str]) -> list[tuple[str, str]]:
    """Splits markdown on ## and ### headings (outside code fences), leaving
    out IGNORED_SECTIONS."""
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
        if name in IGNORED_SECTIONS:
            continue
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


# ------------------------------------------------------------------- links


DOC_LINK_RE = re.compile(r"<doc://com\.apple\.documentation(/[^>\s]+)>")
MD_LINK_RE = re.compile(r"\]\(([^()\s]+(?:\([^()\s]*\))?)\)")  # one level of parens, as in padding(_:_:)
HREF_RE = re.compile(r"""href=["']([^"']+)["']""", re.I)
ASSET_RE = re.compile(r"\.(?:png|jpe?g|gif|svg|pdf|zip|mov|mp4)$", re.I)


def page_links(body: str, base: str, prefix: str) -> set[str]:
    """Links on a page whose path starts with `prefix`, on the page's own
    host. Paths are lowercased (Apple's are case-insensitive, and the app
    cites them lowercase), without fragment, query, trailing slash, or .md."""
    host = urllib.parse.urlsplit(base).hostname
    raw = [f"https://developer.apple.com{m.group(1)}" for m in DOC_LINK_RE.finditer(body)]
    raw += [m.group(1) for m in MD_LINK_RE.finditer(body)]
    raw += [html.unescape(m.group(1)) for m in HREF_RE.finditer(body)]
    links = set()
    for link in raw:
        parts = urllib.parse.urlsplit(urllib.parse.urljoin(base, link))
        if parts.scheme not in ("http", "https") or parts.hostname != host:
            continue
        path = parts.path.lower().rstrip("/")
        if path.endswith(".md"):
            path = path[: -len(".md")]
        if not path.startswith(prefix.lower()) or ASSET_RE.search(path):
            continue
        links.add(urllib.parse.urlunsplit((parts.scheme, parts.netloc.lower(), path, "", "")))
    return links


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
    if "links" in result:  # an index page: the set of pages it links to
        entry["links"] = sorted(short_hash(link) for link in result["links"])
        entry["_links"] = {short_hash(link): link for link in result["links"]}
    return entry


def public(entry: dict) -> dict:
    return {k: v for k, v in entry.items() if not k.startswith("_")}


def compare(old: dict, new: dict, watch_content: bool = True, known: set[str] | frozenset = frozenset()) -> dict | None:
    """What differs between two lock entries, or None. An index page nobody
    cites passes watch_content=False: its prose churns, and only its links
    matter. Links already in `known` (pages the app cites) aren't reported as
    new."""
    reasons = []
    detail: dict = {}
    if new.get("status") == 200 and "links" in new and "links" in old:
        old_links = set(old["links"])
        added = sorted(link for h, link in new.get("_links", {}).items() if h not in old_links and link not in known)
        removed = len(old_links - set(new["links"]))
        if added:
            reasons.append("new-pages")
            detail["new_pages"] = added
        if removed:
            reasons.append("removed-pages")
            detail["removed_pages"] = removed
    if not watch_content:
        new = {**new, "hash": old.get("hash")}  # skip the content comparison below
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


def error_budget(total: int) -> int:
    """How many fetch errors a run of `total` pages may have and still count."""
    return int(total * MAX_ERROR_RATIO)


def fetch_all(urls: list[str]) -> dict[str, dict]:
    """Fetches every URL. Once the errors exceed the budget the run can't
    count anyway, so the remaining fetches are skipped instead of retried."""
    limiter = RateLimiter(REQUESTS_PER_SECOND)
    abort = threading.Event()
    budget = error_budget(len(urls))
    failed = 0
    results: dict[str, dict] = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=WORKERS) as pool:
        futures = {pool.submit(fetch, url, limiter, abort): url for url in urls}
        for done, future in enumerate(concurrent.futures.as_completed(futures), 1):
            url = futures[future]
            try:
                results[url] = future.result()
            except Exception as error:  # a parser bug shouldn't sink the run
                results[url] = {"error": f"{type(error).__name__}: {error}"}
            if "error" in results[url]:
                failed += 1
                if failed > budget and not abort.is_set():
                    print(f"  {failed} fetch errors (budget {budget}); skipping the rest", file=sys.stderr)
                    abort.set()
            if done % 50 == 0 or done == len(urls):
                print(f"  fetched {done}/{len(urls)}", file=sys.stderr)
    return results


def expand_indexes(sources: dict, results: dict[str, dict]) -> int:
    """Gives each index page's result its link set (`links`). For an index
    with `expand`, the pages it links to are fetched and their links join the
    set. If any of those fail, the index becomes a fetch error: a partial set
    would read as pages removed now and added back next run. Returns how many
    extra pages were fetched."""
    children: dict[str, set[str]] = {}
    for url, info in sources.items():
        index, result = info.get("index"), results.get(url, {})
        if not index or result.get("status") != 200:
            continue
        result["links"] = page_links(result["body"], fetch_url(url), index["prefix"])
        if index.get("expand"):
            children[url] = set(result["links"])
    wanted = sorted({link for links in children.values() for link in links} - set(results))
    fetched = fetch_all(wanted) if wanted else {}
    for url, links in children.items():
        result, prefix = results[url], sources[url]["index"]["prefix"]
        failed = []
        for child in sorted(links):
            page = fetched.get(child) or results.get(child) or {}
            if page.get("status") == 200:
                result["links"] |= page_links(page["body"], fetch_url(child), prefix)
            elif "error" in page:
                failed.append(f"{child}: {page['error']}")
        if failed:
            results[url] = {"error": f"{len(failed)} of {len(links)} linked pages failed, first {failed[0]}"}
    return len(wanted)


def github_output(**values) -> None:
    path = os.environ.get("GITHUB_OUTPUT")
    if path:
        with open(path, "a", encoding="utf-8") as f:
            for key, value in values.items():
                f.write(f"{key}={value}\n")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--update-lock", action="store_true", help="re-fetch and write new hashes to the lockfile")
    parser.add_argument("--only", metavar="SUBSTR", help="only sources whose URL, citing file, or page id contains SUBSTR")
    parser.add_argument("--from-changes", metavar="PATH",
                        help="only the URLs a changes.json lists (changed or unbaselined), so a refresh records "
                             "exactly what was reviewed")
    parser.add_argument("--sources", action="store_true", help="rebuild apple-sources.json from the Swift and agent sources")
    parser.add_argument("--sources-file", default=os.path.join(ROOT, SOURCES_FILE), help=argparse.SUPPRESS)
    parser.add_argument("--lock-file", default=os.path.join(ROOT, LOCK_FILE), help=argparse.SUPPRESS)
    parser.add_argument("--out", default=os.path.join(ROOT, CHANGES_FILE), help="where to write changes.json")
    parser.add_argument("--self-test", action="store_true", help=argparse.SUPPRESS)
    args = parser.parse_args(argv)

    if args.self_test:
        return self_test()

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
    if args.from_changes:
        report = load_json(args.from_changes, None)
        if report is None:
            print(f"{args.from_changes} is missing", file=sys.stderr)
            return 2
        listed = {c["url"] for c in report.get("changes", [])} | set(report.get("unbaselined", []))
        sources = {url: info for url, info in sources.items() if url in listed}
        if not sources:
            print(f"{args.from_changes} lists no sources to check; nothing to do")
            github_output(changed=0, files=0, errors=0, hash="")
            return 0
    if not sources:
        print(f"no sources match {args.only!r}", file=sys.stderr)
        return 2
    partial = bool(args.only or args.from_changes)

    lock = load_json(args.lock_file, {"pages": {}})
    locked = lock.setdefault("pages", {})
    print(f"checking {len(sources)} Apple pages…", file=sys.stderr)
    results = fetch_all(list(sources))
    extra = expand_indexes(sources, results)
    if extra:
        print(f"  plus {extra} pages linked from index pages", file=sys.stderr)

    errors = []
    snapshots: dict[str, dict] = {}
    for url in sources:
        result = results[url]
        if "error" in result:
            errors.append({"url": url, "error": result["error"]})
        else:
            snapshots[url] = snapshot(url, result)

    if len(errors) > error_budget(len(sources)):
        # Throttled or down: a partial picture would read as mass link rot or
        # leave half the lockfile stale. Write nothing, so Claude never runs.
        if not args.update_lock and os.path.exists(args.out):
            os.remove(args.out)  # don't leave an older report lying around
        for error in errors[:20]:
            print(f"  error: {error['url']}: {error['error']}", file=sys.stderr)
        if len(errors) > 20:
            print(f"  … and {len(errors) - 20} more", file=sys.stderr)
        print(f"too many fetch errors: {len(errors)} of {len(sources)} "
              f"(more than {MAX_ERROR_RATIO:.0%}); wrote nothing", file=sys.stderr)
        github_output(changed=0, files=0, errors=len(errors), hash="")
        return 3

    if args.update_lock:
        for url, entry in snapshots.items():
            locked[url] = public(entry)
        if not partial:
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
    known = {canonical(u).lower().rstrip("/") for u in all_sources}
    for url, entry in snapshots.items():
        if url not in locked:
            unbaselined.append(url)
            continue
        info = sources[url]
        watch_content = bool(info.get("files") or info.get("signal") or not info.get("index"))
        diff = compare(locked[url], entry, watch_content, known)
        if diff:
            changes.append({
                "url": url,
                "fetched": fetch_url(url),
                "signal": bool(info.get("signal")),
                "index": bool(info.get("index")),
                "files": info.get("files", []),
                "pages": info.get("pages", []),
                **({"anchors": info["anchors"]} if info.get("anchors") else {}),
                **diff,
            })

    stale = False
    if not partial:
        stale = sweep_sources() != all_sources

    affected_files = sorted({f for c in changes for f in c["files"]})
    flood_hash = change_set_hash(c["url"] for c in changes)
    report = {
        "generated": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "only": args.only,
        "checked": len(sources),
        "changed": len(changes),
        "flood_hash": flood_hash,
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
    if flood_hash:
        print(f"flood hash: {flood_hash}")
    github_output(changed=len(changes), files=len(affected_files), errors=len(errors), hash=flood_hash)
    return 0


# ---------------------------------------------------------------- self-test


def self_test() -> int:
    """Offline checks against a local server: throttling and server errors are
    fetch errors (never changes), 404/410 are status changes, the error budget
    stops a run from writing anything, and the flood hash is stable."""
    import contextlib
    import http.server
    import io
    import tempfile

    global BACKOFF, MAX_BACKOFF, REQUESTS_PER_SECOND
    saved = (BACKOFF, MAX_BACKOFF, REQUESTS_PER_SECOND)
    BACKOFF, MAX_BACKOFF, REQUESTS_PER_SECOND = 0.01, 0.05, 1000.0

    state = {"throttled": set(), "gone": set(), "hits": {}, "flaky": 1, "md": {}}
    page = "<html><head><title>{0}</title></head><body><article><h2>{0}</h2><p>Same text.</p></article></body></html>"

    class Handler(http.server.BaseHTTPRequestHandler):
        def log_message(self, *args):
            pass

        def do_GET(self):
            path = self.path
            state["hits"][path] = state["hits"].get(path, 0) + 1
            if path in state["throttled"] or path == "/forbidden":
                return self.send_error(403)
            if path == "/ratelimited":
                self.send_response(429)
                self.send_header("Retry-After", "0")
                self.end_headers()
                return
            if path in state["gone"]:
                return self.send_error(404)
            if path == "/removed":
                return self.send_error(410)
            if path == "/bad":
                return self.send_error(400)
            if path == "/flaky" and state["flaky"] > 0:
                state["flaky"] -= 1
                return self.send_error(503)
            markdown = state["md"].get(path)
            body = (markdown if markdown is not None else page.format(path.strip("/"))).encode()
            self.send_response(200)
            self.send_header("Content-Type", "text/markdown; charset=utf-8" if markdown is not None
                             else "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

    server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    base = f"http://127.0.0.1:{server.server_address[1]}"
    failures: list[str] = []

    def check(condition: bool, label: str) -> None:
        print(f"  {'ok  ' if condition else 'FAIL'} {label}")
        if not condition:
            failures.append(label)

    saved_output = os.environ.pop("GITHUB_OUTPUT", None)
    try:
        limiter = RateLimiter(REQUESTS_PER_SECOND)
        result = fetch(f"{base}/forbidden", limiter)
        check(result.get("error") == "HTTP 403" and "status" not in result, "403 is a fetch error, not a status")
        check(state["hits"].get("/forbidden") == RETRIES, f"403 is retried ({RETRIES} attempts)")
        result = fetch(f"{base}/ratelimited", limiter)
        check(result.get("error") == "HTTP 429" and state["hits"].get("/ratelimited") == RETRIES, "429 is retried, then an error")
        result = fetch(f"{base}/flaky", limiter)
        check(result.get("status") == 200, "a 503 that recovers on retry is a 200")
        result = fetch(f"{base}/bad", limiter)
        check(result.get("error") == "HTTP 400" and state["hits"].get("/bad") == 1, "400 is an error, not retried")
        state["gone"].add("/gone")
        check(fetch(f"{base}/gone", limiter).get("status") == 404, "404 is a status")
        check(fetch(f"{base}/removed", limiter).get("status") == 410, "410 is a status")

        urls = [f"{base}/page{i}" for i in range(10)]
        with tempfile.TemporaryDirectory() as tmp:
            sources_file = os.path.join(tmp, "sources.json")
            lock_file = os.path.join(tmp, "lock.json")
            out = os.path.join(tmp, "changes.json")
            write_json(sources_file, {"sources": {u: {"files": [f"F{u[-1]}.swift"], "pages": []} for u in urls}})
            common = ["--only", "127.0.0.1", "--sources-file", sources_file, "--lock-file", lock_file, "--out", out]

            def run(*extra: str) -> tuple[int, dict | None]:
                if os.path.exists(out):
                    os.remove(out)
                with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                    code = main([*extra, *common])
                return code, load_json(out, None)

            code, _ = run("--update-lock")
            check(code == 0 and len(load_json(lock_file, {}).get("pages", {})) == 10, "baseline records 10 pages")

            code, report = run()
            check(code == 0 and report and report["changed"] == 0 and report["flood_hash"] == "", "unchanged pages: 0 changes")

            state["throttled"] = {"/page3"}
            code, report = run()
            check(code == 0 and report and report["changed"] == 0
                  and [e["url"] for e in report["errors"]] == [urls[3]], "one 403 (10%): listed as an error, 0 changes")

            state["throttled"] = {"/page1", "/page2", "/page3"}
            with open(lock_file, encoding="utf-8") as f:
                lock_before = f.read()
            code, report = run()
            check(code == 3 and report is None, "three 403s (30%): exits 3 and writes no changes.json")
            code, _ = run("--update-lock")
            with open(lock_file, encoding="utf-8") as f:
                check(code == 3 and f.read() == lock_before, "three 403s (30%): --update-lock leaves the lockfile alone")

            state["throttled"] = set()
            state["gone"] = {"/page5", "/page8"}
            code, first = run()
            code2, second = run()
            gone = [urls[8], urls[5]]
            check(code == 0 and first and first["changed"] == 2
                  and all(c["reasons"] == ["status"] for c in first["changes"]), "two 404s: 2 status changes")
            check(bool(first and second) and first["flood_hash"] == second["flood_hash"] == change_set_hash(gone),
                  "flood hash is the same across runs")
            check(change_set_hash(gone) == change_set_hash(list(reversed(gone)) + gone),
                  "flood hash ignores order and duplicates")

            # A filtered run reviews page5 only; refreshing from its report must leave page8 pending.
            filtered = os.path.join(tmp, "filtered.json")
            with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
                main([*common[:1], "page5", *common[2:-1], filtered])
                main(["--update-lock", "--from-changes", filtered, *common[:-1], out])
            code, report = run()
            check(code == 0 and report and [c["url"] for c in report["changes"]] == [urls[8]],
                  "--update-lock --from-changes refreshes only what the report listed")

            # Relationship lists are generated noise; reordering them changes nothing.
            symbol = "# Text\n\n## Overview\n\nShows text.\n\n### Conforms To\n\n[`{0}`](/a)\n\n[`{1}`](/b)\n\n### Topics\n\nMore.\n"
            check(normalize_markdown(symbol.format("View", "Sendable")) == normalize_markdown(symbol.format("Equatable", "Copyable"))
                  and "Conforms To" not in dict(normalize_markdown(symbol.format("View", "Sendable"))),
                  "Conforms To and the other relationship lists are ignored")

            # Index pages: a link set, expanded one level, and new links reported by URL.
            check(page_links("<doc://com.apple.documentation/documentation/SwiftUI/Button> [p](/documentation/SwiftUI/View/padding(_:_:))",
                             "https://developer.apple.com/documentation/swiftui.md", "/documentation/swiftui/")
                  == {"https://developer.apple.com/documentation/swiftui/button",
                      "https://developer.apple.com/documentation/swiftui/view/padding(_:_:)"},
                  "doc:// and relative links resolve to lowercase developer.apple.com URLs")
            state["gone"] = set()
            index = f"{base}/idx"
            state["md"] = {
                "/idx": "# Index\n\n- [A](/docs/a)\n- [B](/Docs/B)\n- [Elsewhere](/other/z)\n"
                        "![art](images/hero@2x.png)\n",
                "/docs/a": "# A\n\nSee [X](/docs/a/x) and [padding](/docs/a/padding(_:_:)).\n",
                "/docs/b": "# B\n\nPlain prose.\n",
            }
            write_json(sources_file, {"sources": {
                index: {"files": [], "pages": [], "index": {"prefix": "/docs/", "expand": True}},
                f"{base}/docs/a/x": {"files": ["X.swift"], "pages": []},
                **{u: {"files": [f"F{u[-1]}.swift"], "pages": []} for u in urls[:8]},  # room in the error budget
            }})
            code, _ = run("--update-lock")
            links = load_json(lock_file, {}).get("pages", {}).get(index, {}).get("links", [])
            check(code == 0 and len(links) == 4, "index baseline: 4 links (a, b, a/x, a/padding), other paths and images left out")
            check(state["hits"].get("/docs/a", 0) >= 1 and state["hits"].get("/docs/b", 0) >= 1, "expand fetches the linked pages")

            state["md"]["/idx"] = state["md"]["/idx"].replace("Index", "Index, reworded")
            code, report = run()
            check(code == 0 and report and report["changed"] == 0, "an uncited index's prose change isn't a change")

            state["md"]["/docs/b"] += "\nNew: [C](/docs/b/c) and [X again](/Docs/A/X/).\n"
            code, report = run()
            found = report["changes"][0] if report and report["changes"] else {}
            check(code == 0 and report and report["changed"] == 1 and found.get("reasons") == ["new-pages"]
                  and found.get("new_pages") == [f"{base}/docs/b/c"],
                  "a new linked page is reported by URL; one the app already cites isn't")

            state["throttled"] = {"/docs/a"}
            code, report = run()
            check(code == 0 and report and report["changed"] == 0
                  and [e["url"] for e in report["errors"]] == [index],
                  "a linked page that fails makes the index a fetch error, not a removal")
            state["throttled"] = set()
    finally:
        server.shutdown()
        BACKOFF, MAX_BACKOFF, REQUESTS_PER_SECOND = saved
        if saved_output is not None:
            os.environ["GITHUB_OUTPUT"] = saved_output

    print(f"self-test: {'all passed' if not failures else f'{len(failures)} failed'}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
