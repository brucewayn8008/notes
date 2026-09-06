#!/usr/bin/env python3
"""
scope-check.py — the safety gate. Filters a list of hosts/URLs against a target's
scope.yaml and prints ONLY the in-scope ones. Everything Claude Code sends traffic
to should pass through here first.

Usage:
    cat hosts.txt | python3 scripts/scope-check.py targets/<name>/scope.yaml
    python3 scripts/scope-check.py targets/<name>/scope.yaml --list hosts.txt

scope.yaml format:
    in_scope:
      wildcards: ["*.example.com"]     # matches example.com and any subdomain
      hosts:     ["api.example.com"]    # exact hosts
      urls:      ["https://x.com/app"]  # url prefixes
    out_of_scope:
      hosts:     ["blog.example.com"]   # explicit denies win over in_scope
      wildcards: ["*.legacy.example.com"]
"""
import sys, re
from urllib.parse import urlparse

try:
    import yaml
except ImportError:
    sys.exit("Install pyyaml: pip install pyyaml --break-system-packages")


def host_of(line: str) -> str:
    line = line.strip()
    if not line:
        return ""
    if "://" in line:
        return (urlparse(line).hostname or "").lower()
    return line.split("/")[0].split(":")[0].lower()


def wc_match(host: str, pattern: str) -> bool:
    pattern = pattern.lower().lstrip("*.")
    return host == pattern or host.endswith("." + pattern)


def load(path):
    with open(path) as f:
        d = yaml.safe_load(f) or {}
    return d.get("in_scope", {}) or {}, d.get("out_of_scope", {}) or {}


def in_scope(host, url, inc, exc):
    # explicit deny wins
    for h in exc.get("hosts", []) or []:
        if host == h.lower():
            return False
    for w in exc.get("wildcards", []) or []:
        if wc_match(host, w):
            return False
    # allow
    for h in inc.get("hosts", []) or []:
        if host == h.lower():
            return True
    for w in inc.get("wildcards", []) or []:
        if wc_match(host, w):
            return True
    for u in inc.get("urls", []) or []:
        if url and url.startswith(u):
            return True
    return False


def main():
    args = [a for a in sys.argv[1:]]
    if not args:
        sys.exit(__doc__)
    scope_path = args[0]
    lines = []
    if "--list" in args:
        with open(args[args.index("--list") + 1]) as f:
            lines = f.readlines()
    else:
        lines = sys.stdin.readlines()
    inc, exc = load(scope_path)
    kept, dropped = 0, 0
    for line in lines:
        raw = line.strip()
        if not raw:
            continue
        host = host_of(raw)
        url = raw if "://" in raw else ""
        if host and in_scope(host, url, inc, exc):
            print(raw)
            kept += 1
        else:
            dropped += 1
    print(f"[scope-check] kept={kept} dropped={dropped}", file=sys.stderr)


if __name__ == "__main__":
    main()
