#!/usr/bin/env python3
"""Runs coding agents on SwiftUI tasks in throwaway Xcode projects and scores
what they write. Standard library only.

    python3 agent/evals/evals.py list
    python3 agent/evals/evals.py self-test
    python3 agent/evals/evals.py run --setup claude-baseline --task previews
    python3 agent/evals/evals.py report [RUN_ID]
    python3 agent/evals/evals.py score RUN_ID [--judge]

See agent/evals/README.md for the details.
"""

import argparse
import datetime as dt
import json
import os
import re
import shutil
import signal
import subprocess
import sys
import tempfile
import threading
import time
from contextlib import contextmanager
from pathlib import Path

sys.dont_write_bytecode = True
import minyaml  # noqa: E402  (lives next to this file)

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
TEMPLATE = HERE / "template"
TASKS_DIR = HERE / "tasks"
RESULTS = HERE / "results"
JUDGE_PROMPT = HERE / "judge-prompt.md"
# Deprecated-API hits come from the linter the skills ship, so the evals and the
# skills agree on what counts. Its rules are agent/src/corrections.yaml.
LINTER = REPO / "agent" / "src" / "check-swift.sh"
LINT_MIN_SEVERITY = "warning"  # corrections at warning or error; info rules are judgment calls
HIG_PREFIX = "hig-"  # the linter's HIG smells, which aren't deprecated APIs
LOCK = Path("/tmp/swiftui-for-humans-build.lock")  # shared with scripts/build.sh

PLATFORMS = {
    "ios": ("EvalApp-iOS", "generic/platform=iOS Simulator", "iOS"),
    "macos": ("EvalApp-macOS", "platform=macOS,arch=arm64", "macOS"),
}
CATEGORIES = {"deprecated-api", "liquid-glass", "hig", "mac", "app-review"}

# Headless Claude Code runs every shell command inside its OS sandbox, which
# auto-approves them but confines writes to the temp project and blocks the
# network. File edits are auto-accepted inside the project, WebFetch is limited
# to developer.apple.com, and anything else that would ask is denied. Per-command
# allowlists don't work here: Claude Code splits compound commands
# (`./build.sh ios 2>&1 | tail; echo $?`) and denies the whole thing if one
# part isn't listed, then denies every later approval in the session, so an
# agent that chains commands loses its build checks. xcodebuild can't run in
# the sandbox (it needs CoreSimulator and paths outside the project), so the
# project's ./build.sh asks the harness's BuildBroker to build instead.
# User settings, plugins, MCP servers, and ~/.claude/CLAUDE.md are left out so
# every setup starts from the same place.
CLAUDE_TOOLS = "Bash,Edit,Read,Write,Glob,Grep,Skill,WebFetch,Task"
CLAUDE_ALLOWED = [
    "Read", "Edit", "Write", "Glob", "Grep", "Skill",
    "WebFetch(domain:developer.apple.com)",
]
CLAUDE_SANDBOX = {"sandbox": {
    "enabled": True,
    "autoAllowBashIfSandboxed": True,
    "allowUnsandboxedCommands": False,  # no retrying outside the sandbox
    "failIfUnavailable": True,          # never fall back to running unsandboxed
}}
JUDGE_SCHEMA = {
    "type": "object",
    "properties": {
        "criteria": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "id": {"type": "string"},
                    "pass": {"type": "boolean"},
                    "note": {"type": "string"},
                },
                "required": ["id", "pass"],
            },
        },
        "overall": {"type": "integer"},
    },
    "required": ["criteria", "overall"],
}


def die(msg):
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


class UsageLimit(Exception):
    """The agent or judge hit the account's usage or rate limit. The job says
    nothing about the setup, so it's discarded and the run stops; rerun with
    the same --run-id once the limit resets."""


LIMIT_TEXT = re.compile(r"usage limit|hit your limit|rate.?limit|limit reached|overloaded|\b429\b", re.I)


def limit_hit(stdout, stderr=""):
    """True when Claude Code's output says the session ended on a usage or rate
    limit. Only error results, error events, and stderr count, so an agent that
    merely writes about limits doesn't trip it."""
    if LIMIT_TEXT.search(stderr or ""):
        return True
    for line in stdout.splitlines():
        try:
            e = json.loads(line)
        except json.JSONDecodeError:
            continue
        if not isinstance(e, dict):
            continue
        if e.get("error") in ("rate_limit", "overloaded") or e.get("api_error_status") == 429:
            return True
        if e.get("type") == "result" and e.get("is_error") and LIMIT_TEXT.search(str(e.get("result") or "")):
            return True
    return False


def log(msg):
    print(msg, file=sys.stderr, flush=True)


# ---------------------------------------------------------------- config

def resolve(path):
    p = Path(os.path.expanduser(str(path)))
    return p if p.is_absolute() else REPO / p


def load_tasks():
    tasks = {}
    for f in sorted(TASKS_DIR.glob("*.yaml")):
        t = minyaml.load(f)
        where = f.relative_to(REPO)
        if not isinstance(t, dict):
            die(f"{where}: not a mapping")
        for key in ("id", "title", "platform", "category", "prompt"):
            if not t.get(key):
                die(f"{where}: missing {key}")
        if t["id"] != f.stem:
            die(f"{where}: id {t['id']!r} doesn't match the file name")
        if t["platform"] not in PLATFORMS:
            die(f"{where}: platform must be one of {sorted(PLATFORMS)}")
        if t["category"] not in CATEGORIES:
            die(f"{where}: category must be one of {sorted(CATEGORIES)}")
        checks = t.get("checks") or {}
        for kind in ("require", "forbid", "max"):
            for c in checks.get(kind) or []:
                if not c.get("label") or not c.get("pattern"):
                    die(f"{where}: every {kind} check needs a label and a pattern")
                try:
                    re.compile(c["pattern"])
                except re.error as e:
                    die(f"{where}: bad pattern {c['pattern']!r}: {e}")
                if kind == "max" and not isinstance(c.get("count"), int):
                    die(f"{where}: max check {c['label']!r} needs an integer count")
        t["checks"] = checks
        t["rubric"] = t.get("rubric") or []
        tasks[t["id"]] = t
    if not tasks:
        die(f"no tasks in {TASKS_DIR}")
    return tasks


def load_setups():
    data = minyaml.load(HERE / "setups.yaml") or {}
    setups = data.get("setups") or {}
    for name, s in setups.items():
        if s.get("agent") not in ("claude", "codex"):
            die(f"setups.yaml: {name}: agent must be claude or codex")
    return setups


def lint_targets():
    """The template's deployment targets, as check-swift.sh --target values, per platform.
    The linter skips a correction whose replacement needs a newer OS than the target."""
    text = (TEMPLATE / "project.yml").read_text()
    out = {}
    for platform, (key, name) in {"ios": ("iOS", "iOS"), "macos": ("macOS", "macOS")}.items():
        m = re.search(rf'^\s*{key}:\s*"?(\d+(?:\.\d+)?)"?\s*$', text, re.MULTILINE)
        if not m:
            die(f"template/project.yml: no {key} deployment target")
        out[platform] = f"{name} {m.group(1)}"
    return out


def check_setup(name, setup):
    """Returns (skills_dir, primer) as Paths, or dies if they don't exist."""
    paths = []
    for key in ("skills_dir", "primer"):
        value = setup.get(key)
        if value is None:
            paths.append(None)
            continue
        p = resolve(value)
        if not p.exists():
            die(f"setup {name}: {key} {p} doesn't exist (see agent/evals/README.md)")
        paths.append(p)
    binary = setup["agent"]
    if not shutil.which(binary):
        die(f"setup {name}: `{binary}` isn't on PATH")
    return paths


# ---------------------------------------------------------------- the build lock

def _pid_alive(pid):
    try:
        os.kill(pid, 0)
        return True
    except ProcessLookupError:
        return False
    except PermissionError:
        return True


@contextmanager
def build_lock():
    """The same mkdir lock as scripts/build.sh, so evals and app builds take turns."""
    waited = False
    while True:
        try:
            LOCK.mkdir()
            break
        except FileExistsError:
            try:
                owner = int((LOCK / "pid").read_text().strip() or 0)
            except (OSError, ValueError):
                owner = 0
            try:
                age = time.time() - LOCK.stat().st_mtime
            except OSError:
                age = 0
            if (owner and not _pid_alive(owner)) or (not owner and age > 10):
                shutil.rmtree(LOCK, ignore_errors=True)
                continue
            if not waited:
                log(f"    waiting for another build (pid {owner or '?'})…")
                waited = True
            time.sleep(5)
    (LOCK / "pid").write_text(f"{os.getpid()}\n")
    try:
        yield
    finally:
        shutil.rmtree(LOCK, ignore_errors=True)


class BuildBroker(threading.Thread):
    """Builds for the agent while it runs. The project's ./build.sh drops
    `<id>.req` (holding ios or mac) into .build/requests/ and waits; the broker
    builds outside the agent's sandbox, then writes `<id>.out` and `<id>.done`
    (the exit code). `build` is injectable for the self-test."""

    def __init__(self, project, build=None):
        super().__init__(daemon=True)
        self.dir = project / ".build" / "requests"
        self.project = project
        self.build = build or agent_build
        self.stopping = threading.Event()
        self.builds = 0

    def __enter__(self):
        self.dir.mkdir(parents=True, exist_ok=True)
        (self.dir / "broker").write_text(f"{os.getpid()}\n")
        self.start()
        return self

    def __exit__(self, *exc):
        self.stopping.set()
        self.join(timeout=5)

    def run(self):
        while not self.stopping.is_set():
            for req in sorted(self.dir.glob("*.req")):
                work = req.with_suffix(".work")
                try:
                    req.rename(work)
                    platform = {"mac": "macos"}.get(work.read_text().strip(), "ios")
                except OSError:
                    continue
                try:
                    output, code = self.build(self.project, platform)
                except Exception as e:  # report it to the agent rather than hang it
                    output, code = f"build service error: {e}\n", 70
                self.builds += 1
                (work.with_suffix(".out")).write_text(output)
                tmp = work.with_suffix(".done-tmp")
                tmp.write_text(f"{code}\n")
                tmp.rename(work.with_suffix(".done"))
                work.unlink(missing_ok=True)
            self.stopping.wait(0.5)


def agent_build(project, platform):
    """What the template's build.sh used to run itself: an incremental build in
    the project's own DerivedData, behind the machine-wide lock."""
    scheme, destination, _ = PLATFORMS[platform]
    with build_lock():
        gen = subprocess.run(["xcodegen", "generate", "--quiet"], cwd=project, capture_output=True, text=True)
        if gen.returncode != 0:
            return gen.stdout + gen.stderr, gen.returncode
        r = subprocess.run(["xcodebuild", "-project", "EvalApp.xcodeproj", "-scheme", scheme,
                            "-destination", destination, "-derivedDataPath", ".build/DerivedData",
                            "-jobs", "4", "ARCHS=arm64", "CODE_SIGNING_ALLOWED=NO", "build", "-quiet"],
                           cwd=project, capture_output=True, text=True)
    output = r.stdout + r.stderr
    if r.returncode == 0:
        output += "Build succeeded.\n"
    return output, r.returncode


# ---------------------------------------------------------------- project setup

def copy_template(dest):
    shutil.copytree(TEMPLATE, dest, ignore=shutil.ignore_patterns(".build", "*.xcodeproj", ".DS_Store"))


def skill_folders(skills_dir):
    if (skills_dir / "SKILL.md").exists():
        return [skills_dir]
    found = sorted(p.parent for p in skills_dir.glob("*/SKILL.md"))
    if not found:
        die(f"{skills_dir} has no SKILL.md and no subfolders with one")
    return found


def prepare_project(project, skills_dir, primer):
    copy_template(project)
    if skills_dir:
        for folder in skill_folders(skills_dir):
            for root in (".claude/skills", ".agents/skills"):
                shutil.copytree(folder, project / root / folder.name)
    if primer:
        text = primer.read_text()
        for name in ("AGENTS.md", "CLAUDE.md"):
            with open(project / name, "a") as f:
                f.write("\n" + text)
    run_quiet(["xcodegen", "generate", "--quiet"], project)
    git = ["git", "-c", "user.name=evals", "-c", "user.email=evals@localhost", "-c", "commit.gpgsign=false",
           "-c", "core.hooksPath=/dev/null"]
    run_quiet(git + ["init", "-q"], project)
    run_quiet(git + ["add", "-A"], project)
    run_quiet(git + ["commit", "-q", "-m", "template"], project)


def run_quiet(cmd, cwd):
    r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if r.returncode != 0:
        die(f"{' '.join(cmd)} failed in {cwd}:\n{r.stdout}{r.stderr}")
    return r.stdout


# ---------------------------------------------------------------- agents

def agent_command(setup, prompt, project):
    """The agent's command line. A setup's extra_args go after the harness's own
    options: before Codex's `--` (everything after it is the prompt), and before
    Claude's variadic --allowedTools list, which would swallow values placed after it."""
    model = setup.get("model")
    extra = [str(a) for a in setup.get("extra_args") or []]
    if setup["agent"] == "claude":
        cmd = [
            "claude", "-p", prompt, "--output-format", "stream-json", "--verbose",
            "--permission-mode", "acceptEdits", "--permission-prompts", "none",
            "--tools", CLAUDE_TOOLS,
            "--setting-sources", "project", "--strict-mcp-config",
            "--no-session-persistence", "--settings", json.dumps(CLAUDE_SANDBOX),
        ]
        if model:
            cmd += ["--model", model]
        cmd += extra
        cmd += ["--allowedTools", *CLAUDE_ALLOWED]
    else:
        cmd = [
            "codex", "exec", "--json", "--sandbox", "workspace-write",
            "--skip-git-repo-check", "--ephemeral", "--ignore-user-config",
            "--cd", str(project),
        ]
        if model:
            cmd += ["--model", model]
        cmd += extra
        cmd += ["--", prompt]
    return cmd


def run_agent(setup, prompt, project, out_dir, timeout):
    cmd = agent_command(setup, prompt, project)
    stdout_path = out_dir / "agent-output.jsonl"
    started = time.time()
    timed_out = False
    with open(stdout_path, "w") as out, open(out_dir / "agent-stderr.txt", "w") as err, \
            BuildBroker(project) as broker:
        proc = subprocess.Popen(cmd, cwd=project, stdout=out, stderr=err, stdin=subprocess.DEVNULL,
                                start_new_session=True)
        try:
            proc.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            timed_out = True
            os.killpg(proc.pid, signal.SIGTERM)
            try:
                proc.wait(timeout=15)
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid, signal.SIGKILL)
                proc.wait()
        except BaseException:
            os.killpg(proc.pid, signal.SIGKILL)
            raise
    info = {"exit_code": proc.returncode, "timed_out": timed_out,
            "seconds": round(time.time() - started, 1), "builds": broker.builds}
    text = stdout_path.read_text()
    info.update(parse_claude(text) if setup["agent"] == "claude" else parse_codex(text))
    if setup["agent"] == "claude" and limit_hit(text, (out_dir / "agent-stderr.txt").read_text()):
        raise UsageLimit(f"agent stopped on a usage or rate limit after {info['seconds']}s")
    return info


def parse_claude(text):
    """Reads `claude -p --output-format stream-json`. When the agent puts a
    command in the background, the session emits one result event per
    segment: each has that segment's usage and turns, while total_cost_usd is
    cumulative. So usage and turns are summed, and cost is the last one."""
    results = []
    for line in text.splitlines():
        try:
            e = json.loads(line)
        except json.JSONDecodeError:
            continue
        if isinstance(e, dict) and e.get("type") == "result":
            results.append(e)
    if not results:
        return {"error": "no result event from claude", "tokens_in": None, "tokens_out": None,
                "cost_usd": None, "turns": None, "models": [], "final_message": ""}
    tin = tout = turns = 0
    models, costs = [], []
    for d in results:
        u = d.get("usage") or {}
        tin += ((u.get("input_tokens") or 0) + (u.get("cache_read_input_tokens") or 0)
                + (u.get("cache_creation_input_tokens") or 0))
        tout += u.get("output_tokens") or 0
        turns += d.get("num_turns") or 0
        if d.get("total_cost_usd") is not None:
            costs.append(d["total_cost_usd"])
        models += [m for m in (d.get("modelUsage") or {}) if m not in models]
    errors = [d.get("subtype") for d in results if d.get("is_error")]
    return {
        "tokens_in": tin, "tokens_out": tout,
        "cost_usd": max(costs) if costs else None,
        "turns": turns, "segments": len(results), "models": models,
        "error": ", ".join(map(str, errors)) or None,
        "final_message": (results[-1].get("result") or "")[:2000],
    }


def parse_codex(text):
    tin = tcached = tout = 0
    final, error = "", None
    for line in text.splitlines():
        try:
            e = json.loads(line)
        except json.JSONDecodeError:
            continue
        kind = e.get("type")
        if kind == "turn.completed":
            u = e.get("usage") or {}
            tin += u.get("input_tokens") or 0
            tcached += u.get("cached_input_tokens") or 0
            tout += u.get("output_tokens") or 0
        elif kind == "item.completed" and (e.get("item") or {}).get("type") == "agent_message":
            final = e["item"].get("text") or ""
        elif kind in ("error", "turn.failed"):
            error = json.dumps(e)[:500]
    # Codex reports cached tokens as a subset of input tokens.
    return {"tokens_in": tin, "tokens_cached": tcached, "tokens_out": tout, "cost_usd": None,
            "turns": None, "models": [], "error": error, "final_message": final[:2000]}


# ---------------------------------------------------------------- scoring

WARNING_RE = re.compile(r"^(?P<file>/[^:\n]+\.swift):(?P<line>\d+):(?P<col>\d+): (?P<kind>warning|error): (?P<msg>.*)$",
                        re.MULTILINE)


def build_project(project, platform, derived, log_path):
    scheme, destination, _ = PLATFORMS[platform]
    started = time.time()
    with build_lock():
        gen = subprocess.run(["xcodegen", "generate", "--quiet"], cwd=project, capture_output=True, text=True)
        if gen.returncode != 0:
            log_path.write_text(gen.stdout + gen.stderr)
            return {"ok": False, "seconds": 0, "errors": 1, "warnings": 0, "deprecations": 0,
                    "messages": ["xcodegen failed: " + (gen.stderr or gen.stdout).strip()[:500]]}
        cmd = ["xcodebuild", "-project", "EvalApp.xcodeproj", "-scheme", scheme,
               "-destination", destination, "-derivedDataPath", str(derived),
               "-jobs", "4", "ARCHS=arm64", "CODE_SIGNING_ALLOWED=NO", "build", "-quiet"]
        r = subprocess.run(cmd, cwd=project, capture_output=True, text=True)
    output = r.stdout + r.stderr
    log_path.write_text(output)
    seen, messages = set(), []
    errors = warnings = deprecations = 0
    root = str(project.resolve())
    for m in WARNING_RE.finditer(output):
        file = os.path.realpath(m["file"])
        key = (file, m["line"], m["col"], m["kind"], m["msg"])
        if key in seen:
            continue
        seen.add(key)
        rel = os.path.relpath(file, root) if file.startswith(root) else file
        messages.append(f"{rel}:{m['line']}: {m['kind']}: {m['msg']}")
        if m["kind"] == "error":
            errors += 1
        else:
            warnings += 1
            if "deprecated" in m["msg"]:
                deprecations += 1
    if r.returncode != 0 and errors == 0:
        errors = 1
        messages.append("build failed: " + output.strip()[-500:])
    return {"ok": r.returncode == 0, "seconds": round(time.time() - started, 1), "errors": errors,
            "warnings": warnings, "deprecations": deprecations, "messages": messages[:60]}


SKIP_DIRS = {".build", ".git", ".claude", ".agents", "EvalApp.xcodeproj"}


def swift_files(project):
    out = []
    for dirpath, dirnames, filenames in os.walk(project):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.endswith(".xcodeproj")]
        for name in filenames:
            if name.endswith(".swift"):
                p = Path(dirpath) / name
                out.append((str(p.relative_to(project)), p.read_text(errors="replace")))
    return sorted(out)


def strip_comments(src):
    """Blanks out // and /* */ comments, keeping strings and line numbers."""
    out, i, n = [], 0, len(src)
    while i < n:
        c = src[i]
        if src.startswith('"""', i):
            j = src.find('"""', i + 3)
            j = n if j < 0 else j + 3
            out.append(src[i:j])
            i = j
        elif c == '"':
            j = i + 1
            while j < n and src[j] not in '"\n':
                j += 2 if src[j] == "\\" else 1
            j = min(j + 1, n)
            out.append(src[i:j])
            i = j
        elif src.startswith("//", i):
            j = src.find("\n", i)
            j = n if j < 0 else j
            i = j
        elif src.startswith("/*", i):
            j = src.find("*/", i + 2)
            j = n if j < 0 else j + 2
            out.append("\n" * src.count("\n", i, j))
            i = j
        else:
            out.append(c)
            i += 1
    return "".join(out)


def find_all(regex, files):
    hits = []
    for name, text in files:
        for m in regex.finditer(text):
            hits.append(f"{name}:{text.count(chr(10), 0, m.start()) + 1}")
    return hits


def deprecated_hits(project, names, target):
    """Runs `check-swift.sh --json` on the agent's Swift files and returns
    {id: ["file:line", ...]} for its corrections (not its HIG checks)."""
    if not names:
        return {}
    cmd = ["sh", str(LINTER), "--json", "--min-severity", LINT_MIN_SEVERITY, "--target", target, "--", *names]
    r = subprocess.run(cmd, cwd=project, capture_output=True, text=True)
    if r.returncode not in (0, 1):  # 1 means it found something
        die(f"{' '.join(cmd)} failed (exit {r.returncode}):\n{r.stderr}")
    try:
        findings = json.loads(r.stdout or "[]")
    except json.JSONDecodeError:
        die(f"check-swift.sh --json printed something that isn't JSON:\n{r.stdout[:500]}")
    by_id = {}
    for f in findings:
        if not f["id"].startswith(HIG_PREFIX):
            by_id.setdefault(f["id"], []).append(f"{f['path']}:{f['line']}")
    return by_id


def score_sources(project, task, targets):
    sources = swift_files(project)
    files = [(name, strip_comments(text)) for name, text in sources]
    by_id = deprecated_hits(project, [name for name, _ in sources], targets[task["platform"]])
    items = []
    checks = task["checks"]
    for c in checks.get("require") or []:
        hits = find_all(re.compile(c["pattern"]), files)
        items.append({"kind": "require", "label": c["label"], "pass": bool(hits)})
    for c in checks.get("forbid") or []:
        hits = find_all(re.compile(c["pattern"]), files)
        items.append({"kind": "forbid", "label": c["label"], "pass": not hits, "hits": hits[:10]})
    for c in checks.get("max") or []:
        hits = find_all(re.compile(c["pattern"]), files)
        items.append({"kind": "max", "label": c["label"], "pass": len(hits) <= c["count"],
                      "count": len(hits), "limit": c["count"]})
    return {
        "swift_files": len(files),
        "swift_lines": sum(t.count("\n") + 1 for _, t in files),
        "deprecated_hits": {"total": sum(len(v) for v in by_id.values()), "by_id": by_id},
        "checks": {"passed": sum(i["pass"] for i in items), "total": len(items), "items": items},
    }


def git_diff(project):
    # --no-ext-diff and --no-color: a user's diff.external (difftastic, say)
    # would otherwise replace the unified diff the judge reads.
    git = ["git", "-c", "core.quotepath=off", "-c", "diff.mnemonicPrefix=false", "-c", "diff.noprefix=false"]
    plain = ["--no-ext-diff", "--no-color", "--cached", "HEAD"]
    env = {k: v for k, v in os.environ.items() if k != "GIT_EXTERNAL_DIFF"}
    subprocess.run(git + ["add", "-A"], cwd=project, capture_output=True, env=env)
    diff = subprocess.run(git + ["diff", *plain], cwd=project, capture_output=True, text=True, env=env).stdout
    stat = subprocess.run(git + ["diff", "--numstat", *plain], cwd=project,
                          capture_output=True, text=True, env=env).stdout
    changed = [line.split("\t")[-1] for line in stat.splitlines() if line.strip()]
    return diff, changed


def diff_line_count(diff):
    return sum(1 for l in diff.splitlines() if l[:1] in "+-" and not l.startswith(("+++", "---")))


def run_judge(task, diff, model):
    platform = PLATFORMS[task["platform"]][2]
    rubric = "\n".join(f"{i}. {item}" for i, item in enumerate(task["rubric"], start=5)) or "(none)"
    if len(diff) > 80_000:
        diff = diff[:80_000] + "\n… (diff truncated)"
    prompt = (JUDGE_PROMPT.read_text()
              .replace("{{PLATFORM}}", platform)
              .replace("{{PROMPT}}", task["prompt"].strip())
              .replace("{{RUBRIC}}", rubric)
              .replace("{{DIFF}}", diff or "(no changes)"))
    cmd = ["claude", "-p", "--output-format", "json", "--tools", "", "--setting-sources", "project",
           "--strict-mcp-config", "--no-session-persistence", "--model", model,
           "--json-schema", json.dumps(JUDGE_SCHEMA)]
    with tempfile.TemporaryDirectory(prefix="sfh-judge-") as cwd:
        r = subprocess.run(cmd, input=prompt, cwd=cwd, capture_output=True, text=True, timeout=600)
    if limit_hit(r.stdout, r.stderr) or (r.returncode and LIMIT_TEXT.search(r.stdout)):
        raise UsageLimit("judge stopped on a usage or rate limit")
    try:
        d = json.loads(r.stdout)
    except json.JSONDecodeError:
        return {"error": f"judge returned no JSON (exit {r.returncode}): {r.stderr[-300:]}"}
    verdict = d.get("structured_output")
    if not isinstance(verdict, dict):
        m = re.search(r"\{.*\}", d.get("result") or "", re.DOTALL)
        try:
            verdict = json.loads(m.group(0)) if m else None
        except json.JSONDecodeError:
            verdict = None
    if not isinstance(verdict, dict) or not isinstance(verdict.get("criteria"), list):
        return {"error": "couldn't parse the judge's verdict", "raw": (d.get("result") or "")[:1000]}
    criteria = verdict["criteria"]
    passed = sum(1 for c in criteria if c.get("pass"))
    return {
        "pass_rate": round(passed / len(criteria), 3) if criteria else None,
        "passed": passed, "total": len(criteria),
        "overall": verdict.get("overall"),
        "criteria": criteria,
        "model": model, "models": list((d.get("modelUsage") or {}).keys()),
        "cost_usd": d.get("total_cost_usd"),
    }


def snapshot(project, dest):
    """Keeps the agent's project (minus build products and installed skills) so it can be rescored."""
    shutil.copytree(project, dest, ignore=shutil.ignore_patterns(".build", ".git", "*.xcodeproj", ".DS_Store",
                                                                 "skills"))


def score_project(project, task, out_dir, targets, judge_model, diff, keep_build=False):
    derived = Path(tempfile.mkdtemp(prefix="sfh-eval-dd-"))
    try:
        build = build_project(project, task["platform"], derived, out_dir / "build.log")
    finally:
        if not keep_build:
            shutil.rmtree(derived, ignore_errors=True)
    result = {"build": build}
    result.update(score_sources(project, task, targets))
    if judge_model:
        log("    judging…")
        result["judge"] = run_judge(task, diff, judge_model)
        (out_dir / "judge.json").write_text(json.dumps(result["judge"], indent=2))
    return result


# ---------------------------------------------------------------- commands

def cmd_list(args):
    tasks, setups = load_tasks(), load_setups()
    targets = lint_targets()
    print(f"{len(tasks)} tasks:")
    for t in tasks.values():
        checks = sum(len(t["checks"].get(k) or []) for k in ("require", "forbid", "max"))
        print(f"  {t['id']:<28} {t['platform']:<6} {t['category']:<15} {checks} checks, "
              f"{len(t['rubric'])} rubric items")
    print(f"\n{len(setups)} setups:")
    for name, s in setups.items():
        ready = all(s.get(k) is None or resolve(s[k]).exists() for k in ("skills_dir", "primer"))
        print(f"  {name:<22} {s['agent']:<7} skills={s.get('skills_dir')} primer={s.get('primer')}"
              f"{'' if ready else '  (missing files)'}")
    print(f"\nDeprecated-API hits: {LINTER.relative_to(REPO)} --json --min-severity {LINT_MIN_SEVERITY} "
          f"--target {targets['ios']!r} (iOS tasks) or {targets['macos']!r} (macOS tasks)")


def pick_tasks(tasks, args):
    chosen = list(tasks.values())
    if args.task:
        unknown = [t for t in args.task if t not in tasks]
        if unknown:
            die(f"unknown task(s): {', '.join(unknown)}")
        chosen = [tasks[t] for t in args.task]
    if args.category:
        chosen = [t for t in chosen if t["category"] in args.category]
    if args.platform:
        chosen = [t for t in chosen if t["platform"] == args.platform]
    if not chosen:
        die("no tasks match")
    return chosen


def cmd_run(args):
    tasks, setups = load_tasks(), load_setups()
    targets = lint_targets()
    unknown = [s for s in args.setup if s not in setups]
    if unknown:
        die(f"unknown setup(s): {', '.join(unknown)} (see setups.yaml)")
    chosen = pick_tasks(tasks, args)
    resolved = {name: check_setup(name, setups[name]) for name in args.setup}
    run_id = args.run_id or dt.datetime.now().strftime("%Y-%m-%d-%H%M%S")
    run_dir = RESULTS / run_id
    jobs = [(s, t, r) for r in range(1, args.repeats + 1) for s in args.setup for t in chosen]

    if args.dry_run:
        for s, t, r in jobs:
            cmd = agent_command(setups[s], t["prompt"].strip(), Path("<project>"))
            print(f"{s} / {t['id']} / r{r}:\n  " + " ".join(
                a if re.fullmatch(r"[\w./:=,@+-]+", a) else repr(a) for a in cmd))
        return

    run_dir.mkdir(parents=True, exist_ok=True)
    meta_path = run_dir / "run.json"
    meta = json.loads(meta_path.read_text()) if meta_path.exists() else {"run_id": run_id, "invocations": []}
    meta["invocations"].append({
        "started": dt.datetime.now().isoformat(timespec="seconds"), "setups": args.setup,
        "tasks": [t["id"] for t in chosen], "repeats": args.repeats, "judge_model": args.judge_model,
        "versions": tool_versions(),
    })
    meta_path.write_text(json.dumps(meta, indent=2))

    log(f"run {run_id}: {len(jobs)} job(s) → {run_dir.relative_to(REPO)}")
    for n, (setup_name, task, rep) in enumerate(jobs, start=1):
        setup = setups[setup_name]
        out_dir = run_dir / setup_name / task["id"] / f"r{rep}"
        if (out_dir / "result.json").exists() and not args.force:
            log(f"[{n}/{len(jobs)}] {setup_name} / {task['id']} / r{rep}: already done, skipping")
            continue
        if out_dir.exists():
            shutil.rmtree(out_dir)
        out_dir.mkdir(parents=True)
        log(f"[{n}/{len(jobs)}] {setup_name} / {task['id']} / r{rep}")
        skills_dir, primer = resolved[setup_name]
        workdir = Path(tempfile.mkdtemp(prefix=f"sfh-eval-{task['id']}-"))
        project = workdir / "EvalApp"
        try:
            prepare_project(project, skills_dir, primer)
            log(f"    running {setup['agent']} in {project}")
            agent = run_agent(setup, task["prompt"].strip(), project, out_dir, args.timeout)
            log(f"    agent finished in {agent['seconds']}s"
                + (" (timed out)" if agent["timed_out"] else "")
                + (f", error: {agent['error']}" if agent.get("error") else ""))
            diff, changed = git_diff(project)
            (out_dir / "changes.diff").write_text(diff)
            snapshot(project, out_dir / "project")
            log("    building…")
            scores = score_project(project, task, out_dir, targets,
                                   args.judge_model if args.judge else None, diff)
            result = {
                "run_id": run_id, "setup": setup_name, "agent": setup["agent"],
                "model": setup.get("model"), "task": task["id"], "platform": task["platform"],
                "category": task["category"], "repeat": rep,
                "finished": dt.datetime.now().isoformat(timespec="seconds"),
                "agent_run": agent, "files_changed": changed,
                "diff_lines": diff_line_count(diff),
                **scores,
            }
            (out_dir / "result.json").write_text(json.dumps(result, indent=2))
            log("    " + one_line(result))
        except UsageLimit as e:
            shutil.rmtree(out_dir, ignore_errors=True)
            log(f"    {e}; discarded this job and stopped. Rerun with --run-id {run_id} once the limit resets.")
            print(save_report(run_dir))
            sys.exit(4)
        finally:
            if args.keep:
                log(f"    kept {workdir}")
            else:
                shutil.rmtree(workdir, ignore_errors=True)
    print(save_report(run_dir))


def cmd_score(args):
    tasks = load_tasks()
    targets = lint_targets()
    run_dir = find_run(args.run)
    for path in sorted(run_dir.glob("*/*/r*/result.json")):
        result = json.loads(path.read_text())
        task = tasks.get(result["task"])
        if not task:
            log(f"skipping {path}: task {result['task']} no longer exists")
            continue
        out_dir = path.parent
        log(f"rescoring {result['setup']} / {result['task']} / r{result['repeat']}")
        workdir = Path(tempfile.mkdtemp(prefix="sfh-rescore-"))
        try:
            project = workdir / "EvalApp"
            shutil.copytree(out_dir / "project", project)
            diff = (out_dir / "changes.diff").read_text() if (out_dir / "changes.diff").exists() else ""
            scores = score_project(project, task, out_dir, targets,
                                   args.judge_model if args.judge else None, diff)
        except UsageLimit as e:
            die(f"{e}; stopped rescoring. Rerun `score` once the limit resets.")
        finally:
            shutil.rmtree(workdir, ignore_errors=True)
        if not args.judge and "judge" in result:
            scores["judge"] = result["judge"]
        result.update(scores)
        result["diff_lines"] = diff_line_count(diff)
        result["rescored"] = dt.datetime.now().isoformat(timespec="seconds")
        path.write_text(json.dumps(result, indent=2))
        log("    " + one_line(result))
    print(save_report(run_dir))


def cmd_report(args):
    print(save_report(find_run(args.run)))


SELF_TEST_SWIFT = '''import SwiftUI

struct Card: View {
    var body: some View {
        NavigationView {
            // .foregroundColor(.red) in a comment doesn't count
            Text("Hi")
                .cornerRadius(12)
                .font(.system(size: 30))
        }
    }
}
'''


def cmd_self_test(args):
    """Checks the harness without running an agent, a build, or the judge: tasks and
    setups parse, agent commands are well formed, and scoring counts the right hits."""
    problems = []
    tasks, setups = load_tasks(), load_setups()
    targets = lint_targets()
    if targets != {"ios": "iOS 18.0", "macos": "macOS 15.0"}:
        problems.append(f"template deployment targets read as {targets}; update this test if they changed on purpose")

    for name in ("ours", "ours-no-primer"):
        s = setups.get(name)
        if not s:
            problems.append(f"setups.yaml has no {name!r} setup")
            continue
        for key in ("skills_dir", "primer"):
            if s.get(key) is not None and not resolve(s[key]).exists():
                problems.append(f"setup {name}: {key} {s[key]} doesn't exist; run scripts/agent-build.py")
    if setups.get("ours", {}).get("primer") is None:
        problems.append("setup ours should include the primer")
    if setups.get("ours-no-primer", {}).get("primer") is not None:
        problems.append("setup ours-no-primer should have no primer")

    extra = ["--flag", "value"]
    codex = agent_command({"agent": "codex", "model": "m", "extra_args": extra}, "PROMPT", Path("/p"))
    if codex[-2:] != ["--", "PROMPT"] or codex.index("--flag") > codex.index("--"):
        problems.append(f"codex: extra_args must come before `--` and the prompt: {codex}")
    claude = agent_command({"agent": "claude", "extra_args": extra}, "PROMPT", Path("/p"))
    allowed = claude[claude.index("--allowedTools") + 1:]
    if claude.index("--flag") > claude.index("--allowedTools") or "--flag" in allowed:
        problems.append(f"claude: extra_args must come before the --allowedTools list: {claude}")
    if any(a.startswith("Bash") for a in allowed):
        problems.append(f"claude: shell commands run in the sandbox, not through the allowlist: {allowed}")
    sandbox = json.loads(claude[claude.index("--settings") + 1])["sandbox"]
    if not (sandbox["enabled"] and sandbox["failIfUnavailable"] and not sandbox["allowUnsandboxedCommands"]):
        problems.append(f"claude: the agent must run in the sandbox with no unsandboxed fallback: {sandbox}")
    for tool in ("Glob", "Grep"):
        if tool not in allowed or tool not in CLAUDE_TOOLS.split(","):
            problems.append(f"claude: {tool} should be in --tools and --allowedTools")

    with tempfile.TemporaryDirectory(prefix="sfh-eval-selftest-") as tmp:
        project = Path(tmp)
        (project / "Shared").mkdir()
        (project / "Shared" / "Card.swift").write_text(SELF_TEST_SWIFT)
        task = {"platform": "ios", "checks": {"forbid": [{"label": "no cornerRadius", "pattern": r"\.cornerRadius\("}]}}
        scores = score_sources(project, task, targets)
        hits = scores["deprecated_hits"]
        want = {"navigation-view": ["Shared/Card.swift:5"], "corner-radius": ["Shared/Card.swift:8"]}
        if hits["by_id"] != want or hits["total"] != 2:
            problems.append(f"deprecated hits: expected {want}, got {hits['by_id']} "
                            "(comments and HIG checks such as hig-fixed-font-size must not count)")
        if scores["checks"]["passed"] != 0 or scores["checks"]["total"] != 1:
            problems.append(f"task checks: expected the forbid check to fail, got {scores['checks']}")

    with tempfile.TemporaryDirectory(prefix="sfh-eval-selftest-") as tmp:
        project = Path(tmp) / "EvalApp"
        copy_template(project)
        stub = lambda proj, platform: (f"built {platform} in {proj.name}\n", 0 if platform == "ios" else 65)
        with BuildBroker(project, build=stub) as broker:
            ios = subprocess.run(["./build.sh", "ios"], cwd=project, capture_output=True, text=True, timeout=30)
            mac = subprocess.run(["./build.sh", "mac"], cwd=project, capture_output=True, text=True, timeout=30)
        if (ios.returncode, ios.stdout, mac.returncode, mac.stdout, broker.builds) != (
                0, "built ios in EvalApp\n", 65, "built macos in EvalApp\n", 2):
            problems.append(f"build broker: ./build.sh should relay the build's output and exit code: "
                            f"{ios.returncode} {ios.stdout!r} {ios.stderr!r} / {mac.returncode} {mac.stdout!r}")
        leftovers = sorted(p.name for p in (project / ".build" / "requests").iterdir() if p.name != "broker")
        if leftovers:
            problems.append(f"build broker: request files left behind: {leftovers}")

    limited = json.dumps({"type": "result", "is_error": True, "result": "Claude AI usage limit reached|1793000000"})
    chatty = json.dumps({"type": "result", "is_error": False, "result": "Added a rate limit to the search field."})
    if not limit_hit(limited) or not limit_hit("", "API Error: 429 rate_limit_error") or limit_hit(chatty):
        problems.append("limit_hit: should catch limit errors and ignore an agent that mentions limits")

    if problems:
        print("self-test FAILED:")
        for p in problems:
            print(f"  {p}")
        sys.exit(1)
    print(f"self-test passed: {len(tasks)} tasks and {len(setups)} setups parse, agent commands are well formed, "
          "check-swift.sh scoring counts the right deprecated-API hits, ./build.sh reaches the build broker, "
          "and usage limits are caught")


def find_run(run):
    if run:
        p = Path(run)
        p = p if p.is_dir() else RESULTS / run
        if not p.is_dir():
            die(f"no run at {p}")
        return p
    runs = sorted(d for d in RESULTS.glob("*") if d.is_dir()) if RESULTS.exists() else []
    if not runs:
        die(f"no runs in {RESULTS}")
    return runs[-1]


def tool_versions():
    out = {}
    for name, cmd in (("claude", ["claude", "--version"]), ("codex", ["codex", "--version"]),
                      ("xcode", ["xcodebuild", "-version"])):
        try:
            out[name] = subprocess.run(cmd, capture_output=True, text=True, timeout=30).stdout.strip().replace("\n", " ")
        except (OSError, subprocess.TimeoutExpired):
            out[name] = None
    return out


# ---------------------------------------------------------------- report

def one_line(r):
    b = r["build"]
    parts = [
        "build ok" if b["ok"] else f"build FAILED ({b['errors']} errors)",
        f"{b['deprecations']} deprecation warnings",
        f"{r['deprecated_hits']['total']} deprecated-API hits",
        f"checks {r['checks']['passed']}/{r['checks']['total']}",
    ]
    j = r.get("judge")
    if j and j.get("pass_rate") is not None:
        parts.append(f"judge {j['passed']}/{j['total']} ({j.get('overall')}/10)")
    elif j:
        parts.append(f"judge error: {j.get('error')}")
    a = r["agent_run"]
    if a.get("cost_usd") is not None:
        parts.append(f"${a['cost_usd']:.2f}")
    return ", ".join(parts)


def _avg(values):
    values = [v for v in values if v is not None]
    return sum(values) / len(values) if values else None


def _fmt(v, kind="num"):
    if v is None:
        return "–"
    if kind == "pct":
        return f"{v * 100:.0f}%"
    if kind == "usd":
        return f"${v:.2f}"
    if kind == "tok":
        return f"{v / 1000:.0f}k" if v >= 1000 else f"{v:.0f}"
    if kind == "sec":
        return f"{v / 60:.1f}m"
    return f"{v:.1f}"


def save_report(run_dir):
    text = render_report(run_dir)
    (run_dir / "report.md").write_text(text)
    return text


def render_report(run_dir):
    results = [json.loads(p.read_text()) for p in sorted(run_dir.glob("*/*/r*/result.json"))]
    lines = [f"# Eval run {run_dir.name}", ""]
    if not results:
        return "\n".join(lines + ["No results yet."]) + "\n"
    setups = list(dict.fromkeys(r["setup"] for r in results))
    tasks = list(dict.fromkeys(r["task"] for r in results))
    lines += [
        "| Setup | Runs | Builds | Deprecation warnings (avg) | Deprecated-API hits (avg) | Checks passed | "
        "Judge criteria passed | Judge overall (avg /10) | Tokens in / out (avg) | Cost (total) | Agent time (avg) |",
        "|---|---|---|---|---|---|---|---|---|---|---|",
    ]
    for s in setups:
        rs = [r for r in results if r["setup"] == s]
        judged = [r["judge"] for r in rs if r.get("judge") and r["judge"].get("pass_rate") is not None]
        checks_total = sum(r["checks"]["total"] for r in rs)
        costs = [r["agent_run"].get("cost_usd") for r in rs if r["agent_run"].get("cost_usd") is not None]
        lines.append("| " + " | ".join([
            s, str(len(rs)),
            f"{sum(r['build']['ok'] for r in rs)}/{len(rs)}",
            _fmt(_avg([r["build"]["deprecations"] for r in rs])),
            _fmt(_avg([r["deprecated_hits"]["total"] for r in rs])),
            _fmt(sum(r["checks"]["passed"] for r in rs) / checks_total if checks_total else None, "pct"),
            _fmt(sum(j["passed"] for j in judged) / sum(j["total"] for j in judged) if judged else None, "pct"),
            _fmt(_avg([j.get("overall") for j in judged])),
            f"{_fmt(_avg([r['agent_run'].get('tokens_in') for r in rs]), 'tok')} / "
            f"{_fmt(_avg([r['agent_run'].get('tokens_out') for r in rs]), 'tok')}",
            _fmt(sum(costs) if costs else None, "usd"),
            _fmt(_avg([r["agent_run"].get("seconds") for r in rs]), "sec"),
        ]) + " |")

    lines += ["", "## Per task", "",
              "Each cell: build (ok / FAIL), deprecation warnings + deprecated-API hits, checks passed, "
              "judge criteria passed. Repeats are summed.", "",
              "| Task | " + " | ".join(setups) + " |", "|---|" + "---|" * len(setups)]
    for t in tasks:
        row = [t]
        for s in setups:
            rs = [r for r in results if r["setup"] == s and r["task"] == t]
            if not rs:
                row.append("–")
                continue
            ok = sum(r["build"]["ok"] for r in rs)
            build = "ok" if ok == len(rs) else ("FAIL" if ok == 0 else f"{ok}/{len(rs)} ok")
            dep = sum(r["build"]["deprecations"] + r["deprecated_hits"]["total"] for r in rs)
            checks = f"{sum(r['checks']['passed'] for r in rs)}/{sum(r['checks']['total'] for r in rs)}"
            judged = [r["judge"] for r in rs if r.get("judge") and r["judge"].get("pass_rate") is not None]
            judge = f", judge {sum(j['passed'] for j in judged)}/{sum(j['total'] for j in judged)}" if judged else ""
            row.append(f"{build}, {dep} dep, {checks}{judge}")
        lines.append("| " + " | ".join(row) + " |")

    hits = {}
    for r in results:
        for pid, locs in r["deprecated_hits"]["by_id"].items():
            hits.setdefault(pid, {}).setdefault(r["setup"], 0)
            hits[pid][r["setup"]] += len(locs)
    if hits:
        lines += ["", "## Deprecated-API hits by rule", "",
                  "Rule ids are check-swift.sh's, from agent/src/corrections.yaml.", "",
                  "| Rule | " + " | ".join(setups) + " |", "|---|" + "---|" * len(setups)]
        for pid in sorted(hits):
            lines.append(f"| {pid} | " + " | ".join(str(hits[pid].get(s, 0)) for s in setups) + " |")
    failures = [r for r in results if not r["build"]["ok"]]
    if failures:
        lines += ["", "## Build failures", ""]
        for r in failures:
            first = next((m for m in r["build"]["messages"] if ": error:" in m or "failed" in m), "")
            lines.append(f"- {r['setup']} / {r['task']} / r{r['repeat']}: {first[:200]}")
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------- main

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="command", required=True)

    sub.add_parser("list", help="validate and list tasks and setups").set_defaults(func=cmd_list)
    sub.add_parser("self-test", help="check the harness itself (no agents, builds, or cost)").set_defaults(
        func=cmd_self_test)

    run = sub.add_parser("run", help="run agents on tasks and score them")
    run.add_argument("--setup", action="append", required=True, help="setup name from setups.yaml (repeatable)")
    run.add_argument("--task", action="append", help="task id (repeatable; default: all)")
    run.add_argument("--category", action="append", help="only tasks in this category (repeatable)")
    run.add_argument("--platform", choices=sorted(PLATFORMS), help="only tasks for this platform")
    run.add_argument("--repeats", type=int, default=1, help="runs per setup and task (default 1)")
    run.add_argument("--run-id", help="results folder name (default: a timestamp); reuse one to resume")
    run.add_argument("--judge", action="store_true", help="also grade with the LLM judge")
    run.add_argument("--judge-model", default="sonnet", help="model for the judge (default: sonnet)")
    run.add_argument("--timeout", type=int, default=1200, help="seconds per agent run (default 1200)")
    run.add_argument("--keep", action="store_true", help="keep the temp projects")
    run.add_argument("--force", action="store_true", help="redo jobs that already have results")
    run.add_argument("--dry-run", action="store_true", help="print the agent commands and exit")
    run.set_defaults(func=cmd_run)

    score = sub.add_parser("score", help="rebuild and rescore a run's saved projects")
    score.add_argument("run", nargs="?", help="run id or folder (default: the latest)")
    score.add_argument("--judge", action="store_true", help="also (re)grade with the LLM judge")
    score.add_argument("--judge-model", default="sonnet")
    score.set_defaults(func=cmd_score)

    report = sub.add_parser("report", help="print a run's markdown report (and save report.md)")
    report.add_argument("run", nargs="?", help="run id or folder (default: the latest)")
    report.set_defaults(func=cmd_report)

    args = ap.parse_args()
    if getattr(args, "repeats", 1) < 1:
        die("--repeats must be at least 1")
    args.func(args)


if __name__ == "__main__":
    main()
