#!/usr/bin/env python3
"""Build the agent pack from the app's pages and the agent-only sources.

    scripts/agent-build.py               write agent/skills/, agent/primer/, and the hook plugin's linter copy
    scripts/agent-build.py --check       exit 1 if anything is stale, a budget is over, or an id doesn't resolve
    scripts/agent-build.py --check-urls  also HEAD every docs and HIG link (slow, needs the network)

Inputs:
    agent/build/ios.json, agent/build/macos.json   scripts/export-catalog.sh (gitignored)
    agent/src/skills/<skill>.md                    each SKILL.md's frontmatter, workflow, and top rules
    agent/src/topics/<id>.md                       agent-only topics (a topic with a page's id replaces it)
    agent/src/overlays/<id>.md                     extra sections merged into a page's topic
    agent/src/corrections.yaml                     the primer's and swiftui-build's top corrections, and the linter

Output is deterministic: the same inputs always give the same bytes, so CI can run --check.
Python 3.9+, standard library only.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import time
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
AGENT = ROOT / "agent"
BUILD = AGENT / "build"
SRC = AGENT / "src"
SKILLS_OUT = AGENT / "skills"
PRIMER_OUT = AGENT / "primer"
HOOK_PLUGIN = AGENT / "plugins" / "swiftui-lint-hook"

sys.dont_write_bytecode = True
sys.path.insert(0, str(SRC))
from check_swift import load_rules  # noqa: E402

SKILLS = ["swiftui-build", "apple-design", "app-store-ship", "swiftui-review"]
SKILL_FOR_TAB = {"components": "swiftui-build", "design": "apple-design", "ship": "app-store-ship"}
EDITIONS = {"ios": ("iOS", "iPadOS"), "macos": ("macOS",)}
# Page kinds whose prose is reference material people read; the agent copy keeps it.
# Components, modifiers, and blocks keep only code, rules, and pitfalls.
GUIDE_KINDS = {"Concept", "Reference"}
# Headings that only introduce something the agent copy drops or moves.
SKIP_HEADINGS = {"Examples", "Try it", "Try the settings", "Try every size"}

# Budgets (plan: "Token budgets"). Tokens are estimated as characters / 4.
PRIMER_MAX_BYTES = 8 * 1024
DESCRIPTION_MAX_CHARS = 1024
SKILL_BODY_MAX_LINES = 300
TOPIC_MAX_TOKENS = 1500
TOPIC_TOC_LINES = 100
MAX_ALIASES = 10  # "Also called" names, for matching web and UIKit terms
PRIMER_CORRECTIONS = 16
SKILL_CORRECTIONS = 16

LINTER_FILES = ["check-swift.sh", "check_swift.py", "corrections.yaml"]
EXECUTABLE = {"check-swift.sh", "check_swift.py"}

CATALOG_LINK = re.compile(r"\[([^\]]+)\]\(catalog://([\w-]+)\)")
SIBLING_LINK = re.compile(r"(?<![\w/.-])`?([a-z0-9][a-z0-9-]*)\.md\b`?")


def tokens(text: str) -> int:
    return (len(text) + 3) // 4


# --------------------------------------------------------------------------- inputs

def read_frontmatter(text: str) -> tuple[dict, str]:
    """Split simple `key: value` frontmatter from a Markdown body."""
    if not text.startswith("---\n"):
        return {}, text
    end = text.index("\n---\n", 4)
    meta = {}
    for line in text[4:end].splitlines():
        if ":" in line:
            key, value = line.split(":", 1)
            meta[key.strip()] = value.strip()
    return meta, text[end + 5:]


def inline_list(value: str) -> list[str]:
    value = value.strip()
    if value.startswith("[") and value.endswith("]"):
        value = value[1:-1]
    return [v.strip() for v in value.split(",") if v.strip()]


def load_editions() -> dict[str, list[dict]]:
    editions = {}
    for name in EDITIONS:
        path = BUILD / f"{name}.json"
        if not path.exists():
            sys.exit(f"Missing {path.relative_to(ROOT)}. Run scripts/export-catalog.sh first.")
        data = json.loads(path.read_text(encoding="utf-8"))
        if data.get("edition") != name:
            sys.exit(f"{path.name} says edition {data.get('edition')!r}, expected {name!r}.")
        editions[name] = data["pages"]
    return editions


@dataclass
class SourceTopic:
    id: str
    meta: dict
    body: str


def load_topics() -> dict[str, SourceTopic]:
    topics = {}
    for path in sorted((SRC / "topics").glob("*.md")):
        meta, body = read_frontmatter(path.read_text(encoding="utf-8"))
        tid = meta.get("id", path.stem)
        if tid != path.stem:
            sys.exit(f"{path}: id {tid!r} doesn't match the file name.")
        for key in ("title", "summary", "skills"):
            if key not in meta:
                sys.exit(f"{path}: frontmatter needs `{key}:`.")
        for skill in inline_list(meta["skills"]):
            if skill not in SKILLS:
                sys.exit(f"{path}: unknown skill {skill!r}.")
        topics[tid] = SourceTopic(tid, meta, body)
    return topics


def load_overlays() -> dict[str, dict[str, list[str]]]:
    """Each overlay is `## Section` blocks; returns {id: {section: [lines]}}."""
    overlays = {}
    for path in sorted((SRC / "overlays").glob("*.md")):
        sections: dict[str, list[str]] = {}
        current = None
        for line in path.read_text(encoding="utf-8").splitlines():
            m = re.match(r"^## (.+)$", line)
            if m:
                current = m.group(1).strip()
                sections[current] = []
            elif current is not None:
                sections[current].append(line)
            elif line.strip():
                sys.exit(f"{path}: text before the first `## Section` heading.")
        overlays[path.stem] = {k: trim(v) for k, v in sections.items()}
    return overlays


def trim(lines: list[str]) -> list[str]:
    while lines and not lines[0].strip():
        lines = lines[1:]
    while lines and not lines[-1].strip():
        lines = lines[:-1]
    return lines


# --------------------------------------------------------------------------- the corpus

@dataclass
class Topic:
    id: str
    title: str
    summary: str
    skills: list[str]
    category: str
    platforms: list[str]
    ios: dict | None = None
    mac: dict | None = None
    source: SourceTopic | None = None
    files: dict[str, str] = field(default_factory=dict)  # skill -> rendered text

    @property
    def mac_only(self) -> bool:
        return self.ios is None and self.mac is not None and self.source is None


def build_corpus(editions, topics) -> tuple[dict[str, Topic], list[str]]:
    corpus: dict[str, Topic] = {}
    errors: list[str] = []
    ios = {p["id"]: p for p in editions["ios"]}
    mac = {p["id"]: p for p in editions["macos"]}
    order = [p["id"] for p in editions["ios"]] + [p["id"] for p in editions["macos"] if p["id"] not in ios]

    for tid, src in topics.items():
        skills = inline_list(src.meta["skills"])
        page = ios.get(tid) or mac.get(tid)
        if page:  # the agent topic replaces the page, in the page's skill too
            skills = sorted(set(skills) | {SKILL_FOR_TAB[page["tab"]]}, key=SKILLS.index)
        corpus[tid] = Topic(tid, src.meta["title"], src.meta["summary"], skills, "Start here",
                            inline_list(src.meta.get("platforms", "[iOS, iPadOS, macOS]")), source=src)

    for pid in order:
        if pid in corpus:
            continue
        i, m = ios.get(pid), mac.get(pid)
        primary = i or m
        tab = primary["tab"]
        if tab not in SKILL_FOR_TAB:
            errors.append(f"{pid}: unknown tab {tab!r}")
            continue
        platforms = (list(EDITIONS["ios"]) if i else []) + (list(EDITIONS["macos"]) if m else [])
        corpus[pid] = Topic(pid, primary["title"], primary["summary"], [SKILL_FOR_TAB[tab]],
                            primary["category"]["title"], platforms, ios=i, mac=m)

    # Every id a page points at must exist.
    for edition, pages in editions.items():
        for p in pages:
            for rid in p.get("related", []):
                if rid not in corpus:
                    errors.append(f"{edition} {p['id']}: related id {rid!r} doesn't exist")
            for block in p.get("blocks", []):
                for item in block.get("items") or []:
                    if item.get("page") and item["page"] not in corpus:
                        errors.append(f"{edition} {p['id']}: checklist page {item['page']!r} doesn't exist")
                for text in (block.get("text"), block.get("caption")):
                    for _, rid in CATALOG_LINK.findall(text or ""):
                        if rid not in corpus:
                            errors.append(f"{edition} {p['id']}: link to {rid!r} doesn't exist")
    return corpus, errors


# --------------------------------------------------------------------------- rendering helpers

class Linker:
    """Rewrites page links for the skill a file lands in."""

    def __init__(self, corpus: dict[str, Topic], skill: str, in_references: bool):
        self.corpus, self.skill, self.prefix = corpus, skill, ("" if in_references else "references/")

    def ref(self, tid: str, label: str | None = None) -> str:
        topic = self.corpus.get(tid)
        label = label or tid
        if topic is None:
            return label
        if self.skill in topic.skills:
            return f"[{label}]({self.prefix}{tid}.md)"
        if label == tid:
            return f"`{tid}` ({topic.skills[0]} skill)"
        return f"{label} (`{tid}`, {topic.skills[0]} skill)"

    def text(self, text: str) -> str:
        return CATALOG_LINK.sub(lambda m: self.ref(m.group(2), m.group(1)), text)

    def siblings(self, text: str) -> str:
        """In agent-only topics, `other.md` must be a file in this skill; point elsewhere otherwise."""
        def fix(m):
            tid = m.group(1)
            topic = self.corpus.get(tid)
            if topic is None or self.skill in topic.skills:
                return m.group(0)
            return f"{m.group(0)} ({topic.skills[0]} skill)"
        out = []
        for line in text.split("\n"):
            out.append(line if line.lstrip().startswith(("http", "- http")) else SIBLING_LINK.sub(fix, line))
        return "\n".join(out)


def md_url(url: str | None) -> str | None:
    """Apple's docs and HIG pages return Markdown with `.md` added to the path."""
    if not url:
        return None
    m = re.match(r"^(https://developer\.apple\.com/(?:documentation|design/human-interface-guidelines)/[^#?]*?)/?([#?].*)?$", url)
    if not m or m.group(1).endswith(".md"):
        return url
    return m.group(1) + ".md" + (m.group(2) or "")


def fence(code: str) -> list[str]:
    # The app's code blocks are Swift, except a few Info.plist and privacy manifest samples.
    lang = "xml" if code.lstrip().startswith("<") else "swift"
    return [f"```{lang}", code.rstrip("\n"), "```"]


def note(aside: dict | None, link: Linker) -> list[str]:
    if not aside or aside["text"].startswith("Try it"):  # "Try it" asides point at the live demo
        return []
    label = "Important" if aside.get("style") == "important" else "Note"
    return [f"**{label}:** {link.text(aside['text'])}"]


def plain(text: str) -> str:
    text = CATALOG_LINK.sub(lambda m: m.group(1), text)
    return re.sub(r"\s+", " ", text).strip()


def sentences(text: str) -> list[str]:
    parts = re.split(r"(?<=[.!?])\s+(?=[A-Z`\[])", re.sub(r"\s+", " ", text).strip())
    return [p for p in parts if p]


# --------------------------------------------------------------------------- page topics

def rules(page: dict, link: Linker) -> list[str]:
    out = []
    for g in page.get("guidelines", []):
        # The Do / Don't captions label live previews and repeat the detail, so they're left out.
        out.append(f"- **{link.text(g['title'])}** {link.text(g['detail'])}")
    return out


def key_apis(page: dict, link: Linker, details: bool = True) -> list[str]:
    if not details:
        names = [a["name"] for a in page.get("api", [])]
        return [", ".join(names)] if names else []
    return [f"- {a['name']}: {link.text(a['detail'])}" for a in page.get("api", [])]


def pitfalls(page: dict, link: Linker) -> list[str]:
    return [f"- {link.text(n)}" for n in page.get("notes", [])]


def usage(page: dict) -> dict | None:
    return next((b for b in page.get("blocks", []) if b["type"] == "usage"), None)


def variants(page: dict, link: Linker, skip_codes: set[str] = frozenset(), level: str = "###") -> list[tuple[str, list[str]]]:
    """Each example (and, on component pages, each standalone code block) as (title, lines)."""
    out = []
    heading = None
    for b in page.get("blocks", []):
        if b["type"] == "heading":
            heading = b["text"]
        elif b["type"] == "example" and b["code"] not in skip_codes:
            title = link.text(b["title"])
            lines = ["", f"{level} {title}"]
            if b.get("caption"):
                lines += ["", link.text(b["caption"])]
            lines += [""] + fence(b["code"])
            if note(b.get("aside"), link):
                lines += [""] + note(b["aside"], link)
            out.append((title, lines))
        elif b["type"] == "code" and page["kind"] not in GUIDE_KINDS and b["code"] not in skip_codes:
            title = link.text(heading if heading and heading not in SKIP_HEADINGS else "More code")
            out.append((title, ["", f"{level} {title}", ""] + fence(b["code"])))
    return out


def joined(chunks: list[tuple[str, list[str]]]) -> list[str]:
    return [line for _, lines in chunks for line in lines][1:]


@dataclass
class Fit:
    """How much of a page's topic to keep. render_page shrinks it until the topic fits its budget."""
    ios_variants: int = 99
    mac_variants: int = 99
    mac_guide: bool = True
    api_details: bool = True
    aliases: bool = True


def guide(page: dict, link: Linker, level: str = "###") -> list[str]:
    """The prose of a concept or reference page, in reading order, without examples."""
    if page["kind"] not in GUIDE_KINDS:
        # Components keep only standalone asides, which are usually pitfalls.
        return [line for b in page.get("blocks", []) if b["type"] == "aside" for line in ["", *note(b["aside"], link)]][1:]
    out: list[str] = []
    pending: str | None = None

    def emit(lines: list[str]):
        nonlocal pending
        if pending:
            out.extend(["", f"{level} {link.text(pending)}"])
            pending = None
        out.extend([""] + lines)

    for b in page.get("blocks", []):
        t = b["type"]
        if t == "heading":
            pending = None if b["text"] in SKIP_HEADINGS else b["text"]
        elif t == "prose":
            emit([link.text(b["text"])])
        elif t == "aside" and note(b["aside"], link):
            emit(note(b["aside"], link))
        elif t == "code":
            emit(fence(b["code"]))
        elif t == "checklist":
            emit([f"- **{link.text(i['title'])}**: {link.text(i['detail'])}"
                  + (f" ({link.ref(i['page'])})" if i.get("page") else "") for i in b["items"]])
        elif t == "steps":
            emit([f"{n}. {link.text(s)}" for n, s in enumerate(b["steps"], 1)])
        elif t == "facts":
            emit([f"- {link.text(f['label'])}: {link.text(f['value'])}" for f in b["facts"]])
    return out[1:]


def when_sections(page: dict, overlay: dict, link: Linker) -> tuple[list[str], list[str]]:
    """`about` sentences that send people to another page become "Don't use when"."""
    use, instead = [], []
    for s in sentences(page.get("about") or ""):
        (instead if "catalog://" in s else use).append(f"- {link.text(s)}")
    use += overlay.get("Use when", [])
    instead += overlay.get("Don't use when", [])
    return use, instead


def section(title: str, lines: list[str]) -> list[str]:
    lines = trim(list(lines))
    return ["", f"## {title}", ""] + lines if lines else []


def frontmatter(pairs: list[tuple[str, str | None]]) -> list[str]:
    return ["---"] + [f"{k}: {v}" for k, v in pairs if v] + ["---"]


def availability(topic: Topic) -> str | None:
    seen: list[str] = []
    for page in (topic.ios, topic.mac):
        for a in (page or {}).get("availability", []):
            if a not in seen:
                seen.append(a)
    return ", ".join(seen) or None


def render_page(topic: Topic, skill: str, corpus, overlay: dict) -> str:
    """Render the whole topic, then, while it's over budget, drop in this order: the Mac
    guide prose, Key API details, then the last variant of whichever platform has more
    variant text. Dropped variants are named at the end, so the agent knows they exist."""
    fit = Fit()
    text = render_page_with(topic, skill, corpus, overlay, fit)
    link = Linker(corpus, skill, in_references=True)
    ios_all, mac_all = variant_sets(topic, link)
    steps = 0
    while tokens(text) > TOPIC_MAX_TOKENS and steps < 200:
        steps += 1
        if fit.mac_guide and topic.mac and topic.ios and topic.mac["kind"] in GUIDE_KINDS:
            fit.mac_guide = False
        elif fit.api_details:
            fit.api_details = False
        elif fit.aliases:
            fit.aliases = False
        else:
            ios_kept = ios_all[:min(fit.ios_variants, len(ios_all))]
            mac_kept = mac_all[:min(fit.mac_variants, len(mac_all))]
            if not ios_kept and not mac_kept:
                break
            ios_size = sum(len("\n".join(lines)) for _, lines in ios_kept)
            mac_size = sum(len("\n".join(lines)) for _, lines in mac_kept)
            if mac_kept and mac_size >= ios_size:
                fit.mac_variants = len(mac_kept) - 1
            else:
                fit.ios_variants = len(ios_kept) - 1
        text = render_page_with(topic, skill, corpus, overlay, fit)
    return text


def variant_sets(topic: Topic, link: Linker):
    page = topic.ios or topic.mac
    ios_all = variants(page, link)
    mac_all = []
    if topic.ios and topic.mac:
        ios_codes = {b.get("code") for b in topic.ios.get("blocks", []) if b.get("code")}
        mac_all = variants(topic.mac, link, skip_codes=ios_codes, level="####")
    return ios_all, mac_all


def render_page_with(topic: Topic, skill: str, corpus, overlay: dict, fit: Fit) -> str:
    link = Linker(corpus, skill, in_references=True)
    ios_all, mac_all = variant_sets(topic, link)
    page = topic.ios or topic.mac
    mac = topic.mac if topic.ios else None
    reviewed = max(filter(None, [(topic.ios or {}).get("reviewed"), (topic.mac or {}).get("reviewed")]), default=None)
    out = frontmatter([
        ("id", topic.id),
        ("title", topic.title),
        ("platforms", "[" + ", ".join(topic.platforms) + "]"),
        ("availability", availability(topic)),
        ("docs", md_url(page.get("docsURL")) or md_url((mac or {}).get("docsURL"))),
        ("hig", md_url(page.get("higURL")) or md_url((mac or {}).get("higURL"))),
        ("reviewed", reviewed),
    ])
    out += ["", f"# {topic.title}", "", link.text(page["summary"])]
    aliases = [a for a in page.get("aliases", []) if a.lower() != topic.title.lower()][:MAX_ALIASES]
    if aliases and fit.aliases:
        out += ["", "Also called: " + ", ".join(aliases) + "."]

    use, instead = when_sections(page, overlay, link)
    out += section("Use when", use)
    out += section("Don't use when", instead)

    u = usage(page)
    if u:
        out += section("Default code", fence(u["code"]) + ([""] + note(u["aside"], link) if u.get("aside") else []))
    if page.get("composition"):
        out += section("Built from", [link.text(page["composition"])])
    out += section("Rules", rules(page, link) + overlay.get("Rules", []))
    out += section("Pitfalls", pitfalls(page, link) + overlay.get("Pitfalls", [])
                   + ([""] + guide(page, link) if page["kind"] not in GUIDE_KINDS and guide(page, link) else []))
    if page["kind"] in GUIDE_KINDS:
        out += section("Guide", guide(page, link))
    out += section("Key APIs", key_apis(page, link, fit.api_details))
    out += section("Variants", joined(ios_all[:fit.ios_variants]))

    if mac:
        out += render_mac(page, mac, link, fit, mac_all)

    for name, lines in overlay.items():
        if name not in {"Use when", "Don't use when", "Rules", "Pitfalls", "Related"}:
            out += section(name, lines)

    dropped = [t for t, _ in ios_all[fit.ios_variants:]] + [f"{t} (macOS)" for t, _ in mac_all[fit.mac_variants:]]
    if dropped:
        docs = md_url(page.get("docsURL")) or md_url((mac or {}).get("docsURL"))
        out += ["", f"More variants, left out to keep this file short: {', '.join(dropped)}."
                + (f" Apple's docs: {docs}" if docs else "")]

    related = list(dict.fromkeys(page.get("related", []) + (mac or {}).get("related", [])))
    links = [link.ref(r) for r in related if r in corpus] + overlay.get("Related", [])
    if links:
        out += ["", "## Related", "", ", ".join(links)]
    return finish(out)


def render_mac(ios: dict, mac: dict, link: Linker, fit: Fit, mac_all) -> list[str]:
    """Only what the Mac edition adds or says differently."""
    parts: list[str] = []
    if plain(mac["summary"]) != plain(ios["summary"]):
        parts += ["", link.text(mac["summary"])]
    iu, mu = usage(ios), usage(mac)
    if mu and (not iu or mu["code"] != iu["code"]):
        parts += ["", "### Default code", ""] + fence(mu["code"]) + ([""] + note(mu["aside"], link) if mu.get("aside") else [])
    ios_titles = {g["title"] for g in ios.get("guidelines", [])}
    mac_rules = rules({"guidelines": [g for g in mac.get("guidelines", []) if g["title"] not in ios_titles]}, link)
    if mac_rules:
        parts += ["", "### Rules", ""] + mac_rules
    mac_notes = [n for n in mac.get("notes", []) if n not in ios.get("notes", [])]
    if mac_notes:
        parts += ["", "### Pitfalls", ""] + [f"- {link.text(n)}" for n in mac_notes]
    ios_api = {a["name"] for a in ios.get("api", [])}
    mac_api = [a for a in mac.get("api", []) if a["name"] not in ios_api]
    if mac_api:
        parts += ["", "### Key APIs", ""] + key_apis({"api": mac_api}, link, fit.api_details)
    if fit.mac_guide and mac["kind"] in GUIDE_KINDS and guide(mac, link) != guide(ios, link):
        parts += ["", "### Guide", ""] + guide(mac, link, level="####")
    if mac_all[:fit.mac_variants]:
        parts += ["", "### Variants", ""] + joined(mac_all[:fit.mac_variants])
    return section("On macOS", parts[1:]) if parts else []


def render_source_topic(topic: Topic, skill: str, corpus) -> str:
    link = Linker(corpus, skill, in_references=True)
    src = topic.source
    keep = [(k, v) for k, v in src.meta.items() if k not in {"skills", "summary"}]
    text = "\n".join(frontmatter(keep)) + "\n" + link.siblings(link.text(src.body))
    return finish(text.split("\n"))


def finish(lines: list[str]) -> str:
    text = "\n".join(lines)
    text = re.sub(r"\n{3,}", "\n\n", text).strip() + "\n"
    body_lines = text.count("\n")
    if body_lines > TOPIC_TOC_LINES and "## Contents" not in text:
        heads = re.findall(r"^## (.+)$", text, re.M)
        toc = "## Contents\n\n" + "\n".join(f"- {h}" for h in heads) + "\n\n"
        first = re.search(r"^## ", text, re.M)
        if first:
            text = text[:first.start()] + toc + text[first.start():]
    return text


# --------------------------------------------------------------------------- skills and primer

def correction_lines(entries: list[dict], limit: int) -> list[str]:
    picked = [e for e in entries if e.get("severity") == "error"] + \
             [e for e in entries if e.get("severity", "warning") == "warning"]
    return [f"- {e['brief']}" for e in picked[:limit]]


def render_index(corpus: dict[str, Topic], skill: str) -> list[str]:
    groups: dict[str, list[Topic]] = {}
    for t in corpus.values():
        if skill in t.skills:
            groups.setdefault(t.category, []).append(t)
    out = []
    for name in ["Start here"] + [g for g in groups if g != "Start here"]:
        if name not in groups:
            continue
        out += ["", f"### {name}", ""]
        for t in groups[name]:
            mark = " (macOS only)" if t.mac_only else ""
            out.append(f"- `references/{t.id}.md`{mark}: {plain(t.summary)}")
    return out[1:]


def render_skill(skill: str, corpus, entries) -> str:
    path = SRC / "skills" / f"{skill}.md"
    meta, body = read_frontmatter(path.read_text(encoding="utf-8"))
    if set(meta) != {"name", "description"} or meta["name"] != skill:
        sys.exit(f"{path}: frontmatter must be exactly `name: {skill}` and `description:`.")
    link = Linker(corpus, skill, in_references=False)
    body = body.replace("{{index}}", "\n".join(render_index(corpus, skill)))
    body = body.replace("{{corrections}}", "\n".join(
        ["## Top corrections", "", "Old → new. Every one, with its minimum OS: `references/deprecated-apis.md`.", ""]
        + correction_lines(entries, SKILL_CORRECTIONS)))
    text = f"---\nname: {meta['name']}\ndescription: {meta['description']}\n---\n" + link.text(body)
    return re.sub(r"\n{3,}", "\n\n", text).rstrip() + "\n"


def render_primer(corpus, entries) -> str:
    index = []
    for skill in SKILLS:
        ids = [t.id for t in corpus.values() if skill in t.skills]
        index.append(f"|{skill}/references:{{" + ",".join(f"{i}.md" for i in ids) + "}")
    lines = [
        "<!-- SwiftUI for Humans primer. Generated by scripts/agent-build.py; edit agent/src/, not this file. -->",
        "## SwiftUI for Humans",
        "",
        "Targets Xcode 27 with the iOS/iPadOS 27.1 and macOS 27 SDKs. Liquid Glass arrived in 26. "
        "Gate anything newer than the deployment target with `if #available` and a real fallback.",
        "",
        "**Prefer retrieval-led reasoning over pre-training for SwiftUI, Apple design, and App Store work.** "
        "Your training data predates these APIs and is full of deprecated patterns. Before writing or reviewing "
        "SwiftUI, read the matching file from the index below, then follow it over memory. Paths are relative to "
        "the folder the swiftui-for-humans skills are installed in (such as `.claude/skills/`, `.agents/skills/`, "
        "or the plugin's `skills/`). For full API detail, use Xcode's `DocumentationSearch` tool or add `.md` "
        "to any developer.apple.com docs URL.",
        "",
        "Before finishing SwiftUI work, run `python3 <skills>/swiftui-review/scripts/check_swift.py --target \"iOS 17\" <paths>` "
        "with your real deployment target, and fix what it reports.",
        "",
        "### Top corrections (old → new)",
        "",
        *correction_lines(entries, PRIMER_CORRECTIONS),
        "- More: `swiftui-build/references/deprecated-apis.md`",
        "",
        "### Index",
        "",
        "[SwiftUI for Humans skills]|root: <skills folder>",
        *index,
    ]
    return "\n".join(lines) + "\n"


# --------------------------------------------------------------------------- build, check, report

def generate() -> tuple[dict[Path, tuple[str, bool]], list[str], dict]:
    editions = load_editions()
    topics = load_topics()
    overlays = load_overlays()
    entries = load_rules(SRC / "corrections.yaml")
    corpus, errors = build_corpus(editions, topics)

    for oid in overlays:
        if oid not in corpus:
            errors.append(f"agent/src/overlays/{oid}.md: no page or topic has the id {oid!r}")
        elif corpus[oid].source is not None:
            errors.append(f"agent/src/overlays/{oid}.md: {oid!r} is an agent topic; edit agent/src/topics/{oid}.md")

    files: dict[Path, tuple[str, bool]] = {}
    for t in corpus.values():
        for skill in t.skills:
            text = render_source_topic(t, skill, corpus) if t.source else render_page(t, skill, corpus, overlays.get(t.id, {}))
            t.files[skill] = text
            files[SKILLS_OUT / skill / "references" / f"{t.id}.md"] = (text, False)
    for skill in SKILLS:
        files[SKILLS_OUT / skill / "SKILL.md"] = (render_skill(skill, corpus, entries), False)
    for name in LINTER_FILES:
        text = (SRC / name).read_text(encoding="utf-8")
        files[SKILLS_OUT / "swiftui-review" / "scripts" / name] = (text, name in EXECUTABLE)
        files[HOOK_PLUGIN / "scripts" / name] = (text, name in EXECUTABLE)
    files[PRIMER_OUT / "AGENTS.snippet.md"] = (render_primer(corpus, entries), False)

    # Links inside generated files must point at files that exist.
    for path, (text, _) in files.items():
        if path.suffix != ".md" or path.parent.name not in {"references"} and path.name != "SKILL.md":
            continue
        base = path.parent
        for target in re.findall(r"\]\(((?:references/)?[a-z0-9-]+\.md)\)", text):
            if (base / target) not in files:
                errors.append(f"{path.relative_to(ROOT)}: broken link {target}")
    stats = {"corpus": corpus, "editions": editions}
    return files, errors, stats


MANAGED = [SKILLS_OUT, PRIMER_OUT]


def existing_files() -> set[Path]:
    found = set()
    for base in MANAGED:
        if base.exists():
            found |= {p for p in base.rglob("*") if p.is_file() and p.name != ".DS_Store"}
    for name in LINTER_FILES:
        p = HOOK_PLUGIN / "scripts" / name
        if p.exists():
            found.add(p)
    return found


def budgets(files, corpus) -> tuple[list[str], list[str]]:
    report, errors = [], []
    primer = files[PRIMER_OUT / "AGENTS.snippet.md"][0]
    size = len(primer.encode("utf-8"))
    report.append(f"primer           {size:>6} bytes  ~{tokens(primer):>5} tokens  (max {PRIMER_MAX_BYTES} bytes)")
    if size > PRIMER_MAX_BYTES:
        errors.append(f"primer is {size} bytes, over {PRIMER_MAX_BYTES}")
    for skill in SKILLS:
        text = files[SKILLS_OUT / skill / "SKILL.md"][0]
        meta, body = read_frontmatter(text)
        desc = meta["description"]
        lines = body.strip("\n").count("\n") + 1
        report.append(f"{skill:<16} description {len(desc):>4} chars, body {lines:>3} lines ~{tokens(body):>5} tokens")
        if len(desc) > DESCRIPTION_MAX_CHARS:
            errors.append(f"{skill}: description is {len(desc)} chars, over {DESCRIPTION_MAX_CHARS}")
        if re.search(r": | #|^[\[\]{}>|*&!%@`'\"]", desc):
            errors.append(f"{skill}: description needs YAML quoting (contains ': ', ' #', or starts with a symbol)")
        if lines > SKILL_BODY_MAX_LINES:
            errors.append(f"{skill}: SKILL.md body is {lines} lines, over {SKILL_BODY_MAX_LINES}")
    sizes = []
    for t in corpus.values():
        for skill, text in t.files.items():
            sizes.append((tokens(text), f"{skill}/references/{t.id}.md"))
            if tokens(text) > TOPIC_MAX_TOKENS:
                errors.append(f"{skill}/references/{t.id}.md is ~{tokens(text)} tokens, over {TOPIC_MAX_TOKENS}")
    sizes.sort()
    total = sum(s for s, _ in sizes)
    report.append(f"topics           {len(sizes)} files, ~{total} tokens in all; smallest ~{sizes[0][0]} ({sizes[0][1]}), "
                  f"largest ~{sizes[-1][0]} ({sizes[-1][1]}), median ~{sizes[len(sizes) // 2][0]}")
    for skill in SKILLS:
        n = sum(1 for t in corpus.values() if skill in t.skills)
        report.append(f"  {skill:<16} {n} topics")
    return report, errors


def check_urls(corpus) -> list[str]:
    urls = set()
    for t in corpus.values():
        for page in (t.ios, t.mac):
            for key in ("docsURL", "higURL"):
                if page and page.get(key):
                    urls.add(md_url(page[key]))
        if t.source:
            for url in re.findall(r"https://developer\.apple\.com/[^\s>`]+", t.source.body):
                url = url.rstrip(".,;")
                while url.endswith(")") and url.count(")") > url.count("("):
                    url = url[:-1]
                urls.add(url)
    bad = []
    for url in sorted(urls):
        req = urllib.request.Request(url, method="HEAD", headers={"User-Agent": "swiftui-for-humans agent-build"})
        try:
            with urllib.request.urlopen(req, timeout=20) as resp:
                status = resp.status
        except urllib.error.HTTPError as e:
            status = e.code
        except Exception as e:  # noqa: BLE001
            status = repr(e)
        if status != 200:
            bad.append(f"{status} {url}")
        time.sleep(0.3)
    print(f"checked {len(urls)} URLs, {len(bad)} not 200")
    return bad


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true", help="don't write; exit 1 if output is stale or invalid")
    ap.add_argument("--check-urls", action="store_true", help="also HEAD every Apple link")
    args = ap.parse_args()

    files, errors, stats = generate()
    report, budget_errors = budgets(files, stats["corpus"])
    errors += budget_errors
    if args.check_urls:
        errors += [f"URL: {b}" for b in check_urls(stats["corpus"])]

    on_disk = existing_files()
    stale = []
    for path, (text, executable) in sorted(files.items()):
        if not path.exists() or path.read_text(encoding="utf-8") != text:
            stale.append(f"changed  {path.relative_to(ROOT)}")
        elif executable and not path.stat().st_mode & 0o100:
            stale.append(f"mode     {path.relative_to(ROOT)}")
    for path in sorted(on_disk - set(files)):
        stale.append(f"extra    {path.relative_to(ROOT)}")

    pages = {k: len(v) for k, v in stats["editions"].items()}
    print(f"pages: {pages['ios']} iOS, {pages['macos']} macOS -> {len(stats['corpus'])} topics")
    print("\n".join(report))

    if args.check:
        for line in stale:
            print(f"stale: {line}")
        for e in errors:
            print(f"error: {e}")
        if stale:
            print("Output is stale; run scripts/agent-build.py")
        ok = not stale and not errors
        print("check passed" if ok else "check failed")
        return 0 if ok else 1

    for e in errors:
        print(f"error: {e}")
    for path, (text, executable) in files.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        if not path.exists() or path.read_text(encoding="utf-8") != text:
            path.write_text(text, encoding="utf-8")
        if executable:
            path.chmod(0o755)
    for path in on_disk - set(files):
        path.unlink()
    for base in MANAGED:  # drop folders left empty
        for d in sorted((p for p in base.rglob("*") if p.is_dir()), reverse=True):
            if not any(d.iterdir()):
                d.rmdir()
    print(f"wrote {len(files)} files ({len(stale)} changed)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
