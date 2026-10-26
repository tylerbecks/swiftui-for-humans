"""A small YAML subset parser, so the eval harness needs only the Python
standard library.

Supported: block mappings and lists (including lists of mappings), `#`
comments, block scalars (`|`, `|-`, `>`, `>-`), single- and double-quoted
strings, null / true / false / numbers, and flat flow lists like `[a, b]`.
Not supported: anchors, tags, flow mappings, multi-document files. Keep the
task files inside this subset; `python3 agent/evals/evals.py list` parses
every file and fails loudly on anything it can't read.
"""

import re

KEY_RE = re.compile(r"""^('(?:[^']|'')*'|"(?:[^"\\]|\\.)*"|[A-Za-z0-9_][A-Za-z0-9_.\-]*)\s*:(?=\s|$)""")


class YAMLError(ValueError):
    pass


def loads(text):
    return _Parser(text).parse()


def load(path):
    with open(path, encoding="utf-8") as f:
        try:
            return loads(f.read())
        except YAMLError as e:
            raise YAMLError(f"{path}: {e}") from None


def _indent(line):
    return len(line) - len(line.lstrip(" "))


def _is_item(content):
    return content == "-" or content.startswith("- ")


def _strip_comment(s):
    """Drops a trailing ` # comment` from a plain (unquoted) scalar."""
    m = re.search(r"\s#", s)
    return s[: m.start()].rstrip() if m else s.strip()


def _unquote_single(s):
    # s starts with a quote; returns (value, rest)
    i, out = 1, []
    while i < len(s):
        c = s[i]
        if c == "'":
            if i + 1 < len(s) and s[i + 1] == "'":
                out.append("'")
                i += 2
                continue
            return "".join(out), s[i + 1 :]
        out.append(c)
        i += 1
    raise YAMLError(f"unterminated single-quoted string: {s!r}")


_ESCAPES = {"n": "\n", "t": "\t", '"': '"', "\\": "\\", "/": "/", "0": "\0"}


def _unquote_double(s):
    i, out = 1, []
    while i < len(s):
        c = s[i]
        if c == "\\" and i + 1 < len(s):
            nxt = s[i + 1]
            out.append(_ESCAPES.get(nxt, "\\" + nxt))
            i += 2
            continue
        if c == '"':
            return "".join(out), s[i + 1 :]
        out.append(c)
        i += 1
    raise YAMLError(f"unterminated double-quoted string: {s!r}")


def _scalar(s):
    s = s.strip()
    if s.startswith("'"):
        value, _ = _unquote_single(s)
        return value
    if s.startswith('"'):
        value, _ = _unquote_double(s)
        return value
    s = _strip_comment(s)
    if s.startswith("[") and s.endswith("]"):
        inner = s[1:-1].strip()
        return [_scalar(part) for part in _split_flow(inner)] if inner else []
    if s == "{}":
        return {}
    if s in ("", "~", "null", "Null", "NULL"):
        return None
    if s in ("true", "True", "TRUE"):
        return True
    if s in ("false", "False", "FALSE"):
        return False
    if re.fullmatch(r"[-+]?\d+", s):
        return int(s)
    if re.fullmatch(r"[-+]?(\d+\.\d*|\.\d+)([eE][-+]?\d+)?", s):
        return float(s)
    return s


def _split_flow(s):
    parts, cur, quote = [], [], None
    for c in s:
        if quote:
            cur.append(c)
            if c == quote:
                quote = None
        elif c in "'\"":
            quote = c
            cur.append(c)
        elif c == ",":
            parts.append("".join(cur))
            cur = []
        else:
            cur.append(c)
    parts.append("".join(cur))
    return [p.strip() for p in parts]


def _key(raw):
    if raw.startswith("'"):
        return _unquote_single(raw)[0]
    if raw.startswith('"'):
        return _unquote_double(raw)[0]
    return raw


class _Parser:
    def __init__(self, text):
        self.lines = text.replace("\t", "    ").splitlines()
        self.i = 0

    def parse(self):
        self._skip()
        if self.i >= len(self.lines):
            return None
        value = self._node(_indent(self.lines[self.i]))
        self._skip()
        if self.i < len(self.lines):
            raise YAMLError(f"line {self.i + 1}: unexpected indentation: {self.lines[self.i]!r}")
        return value

    def _skip(self):
        while self.i < len(self.lines):
            s = self.lines[self.i].strip()
            if s == "" or s.startswith("#"):
                self.i += 1
            else:
                break

    def _node(self, indent):
        content = self.lines[self.i].strip()
        if _is_item(content):
            return self._list(indent)
        return self._map(indent)

    def _list(self, indent):
        out = []
        while True:
            self._skip()
            if self.i >= len(self.lines):
                break
            line = self.lines[self.i]
            cur, content = _indent(line), line.strip()
            if cur != indent or not _is_item(content):
                if cur > indent:
                    raise YAMLError(f"line {self.i + 1}: bad indentation: {line!r}")
                break
            rest = content[1:].lstrip()
            if rest == "":
                self.i += 1
                self._skip()
                if self.i < len(self.lines) and _indent(self.lines[self.i]) > indent:
                    out.append(self._node(_indent(self.lines[self.i])))
                else:
                    out.append(None)
            elif KEY_RE.match(rest):
                item_indent = cur + (len(content) - len(rest))
                self.lines[self.i] = " " * item_indent + rest
                out.append(self._map(item_indent))
            else:
                self.i += 1
                out.append(self._value(rest, cur))
        return out

    def _map(self, indent):
        out = {}
        while True:
            self._skip()
            if self.i >= len(self.lines):
                break
            line = self.lines[self.i]
            cur, content = _indent(line), line.strip()
            if cur < indent or (cur == indent and _is_item(content)):
                break
            if cur > indent:
                raise YAMLError(f"line {self.i + 1}: bad indentation: {line!r}")
            m = KEY_RE.match(content)
            if not m:
                raise YAMLError(f"line {self.i + 1}: expected 'key: value': {line!r}")
            key = _key(m.group(1))
            rest = content[m.end():].strip()
            self.i += 1
            if rest == "" or rest.startswith("#"):
                self._skip()
                if self.i < len(self.lines):
                    nxt = self.lines[self.i]
                    n_ind = _indent(nxt)
                    if n_ind > indent or (n_ind == indent and _is_item(nxt.strip())):
                        out[key] = self._node(n_ind)
                        continue
                out[key] = None
            else:
                out[key] = self._value(rest, indent)
        return out

    def _value(self, rest, parent_indent):
        header = _strip_comment(rest) if rest[:1] in "|>" else rest
        if header in ("|", "|-", "|+", ">", ">-", ">+"):
            return self._block(header, parent_indent)
        return _scalar(rest)

    def _block(self, header, parent_indent):
        raw = []
        while self.i < len(self.lines):
            line = self.lines[self.i]
            if line.strip() == "" or _indent(line) > parent_indent:
                raw.append(line)
                self.i += 1
            else:
                break
        while raw and raw[-1].strip() == "":
            raw.pop()
        if not raw:
            return ""
        block_indent = min(_indent(l) for l in raw if l.strip())
        body = [l[block_indent:] if l.strip() else "" for l in raw]
        if header.startswith("|"):
            text = "\n".join(body)
        else:
            paragraphs, para = [], []
            for l in body:
                if l == "":
                    paragraphs.append(" ".join(para))
                    para = []
                else:
                    para.append(l.strip())
            paragraphs.append(" ".join(para))
            text = "\n".join(paragraphs)
        return text if header.endswith("-") else text + "\n"
