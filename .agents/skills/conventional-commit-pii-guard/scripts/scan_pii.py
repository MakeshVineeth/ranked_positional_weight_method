#!/usr/bin/env python3
"""Scan staged Git diffs or repository files for PII, secrets, and local paths."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

FORBIDDEN_FILENAMES = (
    ".env",
    "key.properties",
    "google-services.json",
    "GoogleService-Info.plist",
)
FORBIDDEN_SUFFIXES = (".jks", ".keystore", ".pem", ".p12", ".pfx", ".key")

TEXT_EXTENSIONS = {
    ".dart",
    ".md",
    ".yml",
    ".yaml",
    ".kts",
    ".gradle",
    ".properties",
    ".xml",
    ".html",
    ".json",
    ".dsl",
    ".py",
    ".txt",
    ".pro",
    ".rc",
    ".cpp",
    ".h",
    ".kt",
    ".swift",
    ".cc",
}

PATTERNS: list[tuple[str, re.Pattern[str]]] = [
    ("Private key header", re.compile(r"-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----")),
    ("GitHub token", re.compile(r"\b(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{20,}\b")),
    ("GitHub fine-grained token", re.compile(r"\bgithub_pat_[A-Za-z0-9_]{20,}\b")),
    ("AWS access key", re.compile(r"\bAKIA[0-9A-Z]{16}\b")),
    ("Google API key", re.compile(r"\bAIza[0-9A-Za-z\-_]{35}\b")),
    ("Generic secret assignment", re.compile(r"(?i)\b(?:api_key|secret_key|password|keystore_password|store_password|key_password)\s*[:=]\s*['\"][^'\"]{6,}['\"]")),
    ("Windows user profile path", re.compile(r"(?i)[A-Z]:\\Users\\[A-Za-z0-9._-]+\\")),
    ("Unix home directory path", re.compile(r"/(?:Users|home)/[A-Za-z0-9._-]+/")),
    ("Email address", re.compile(r"\b[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}\b")),
    ("US SSN pattern", re.compile(r"\b\d{3}-\d{2}-\d{4}\b")),
]

SAFE_EMAIL_DOMAINS = ("example.com", "example.org", "users.noreply.github.com")
ASSET_SCALE_SUFFIX = re.compile(r"@\d+x\.png$", re.IGNORECASE)


def run_git(args: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        check=False,
    )


def is_forbidden_filename(path_str: str) -> bool:
    name = Path(path_str).name
    if name in FORBIDDEN_FILENAMES or name.startswith(".env."):
        return True
    return any(name.endswith(suffix) for suffix in FORBIDDEN_SUFFIXES)


def scan_line(label: str, line_no: int, text: str) -> list[str]:
    findings: list[str] = []
    for rule_name, pattern in PATTERNS:
        for match in pattern.finditer(text):
            matched = match.group(0)
            if rule_name == "Email address" and (
                any(matched.lower().endswith(f"@{domain}") for domain in SAFE_EMAIL_DOMAINS)
                or ASSET_SCALE_SUFFIX.search(matched)
            ):
                continue
            redacted = matched[:4] + "..." if len(matched) > 10 else "[REDACTED]"
            findings.append(f"{label}:{line_no}: {rule_name} detected ({redacted})")
    return findings


def scan_staged() -> list[str]:
    findings: list[str] = []
    names_proc = run_git(["diff", "--cached", "--name-only", "--diff-filter=ACMR"])
    if names_proc.returncode != 0:
        return [f"git diff --cached failed: {names_proc.stderr.strip()}"]

    staged_files = [line.strip() for line in names_proc.stdout.splitlines() if line.strip()]
    for file_path in staged_files:
        if is_forbidden_filename(file_path):
            findings.append(f"{file_path}: forbidden sensitive filename staged")

    diff_proc = run_git(["diff", "--cached", "--unified=0", "--no-color"])
    if diff_proc.returncode != 0:
        return [f"git diff --cached failed: {diff_proc.stderr.strip()}"]

    current_file = "<staged>"
    current_line = 0
    for raw_line in diff_proc.stdout.splitlines():
        if raw_line.startswith("+++ b/"):
            current_file = raw_line[6:]
        elif raw_line.startswith("@@ "):
            plus_part = [part for part in raw_line.split() if part.startswith("+")]
            if plus_part:
                start = plus_part[0][1:].split(",")[0]
                current_line = int(start) if start.isdigit() else 0
        elif raw_line.startswith("+") and not raw_line.startswith("+++"):
            findings.extend(scan_line(current_file, current_line, raw_line[1:]))
            current_line += 1
    return findings


def scan_repo() -> list[str]:
    findings: list[str] = []
    ls_proc = run_git(["ls-files", "--cached", "--others", "--exclude-standard"])
    if ls_proc.returncode != 0:
        return [f"git ls-files failed: {ls_proc.stderr.strip()}"]

    for rel_path in [line.strip() for line in ls_proc.stdout.splitlines() if line.strip()]:
        if is_forbidden_filename(rel_path):
            findings.append(f"{rel_path}: forbidden sensitive filename present")
            continue
        path = Path(rel_path)
        if not path.is_file():
            continue
        if path.suffix.lower() not in TEXT_EXTENSIONS and path.name != "AGENTS.md":
            continue
        try:
            content = path.read_text(encoding="utf-8", errors="ignore")
        except OSError as exc:
            findings.append(f"{rel_path}: unable to read ({exc})")
            continue
        for idx, line in enumerate(content.splitlines(), start=1):
            findings.extend(scan_line(rel_path, idx, line))
    return findings


def main() -> int:
    parser = argparse.ArgumentParser(description="Scan repository or staged changes for PII/secrets.")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--staged", action="store_true", help="Scan staged Git changes only.")
    group.add_argument("--repo", action="store_true", help="Scan all non-ignored repo text files.")
    args = parser.parse_args()

    findings = scan_staged() if args.staged else scan_repo()
    if findings:
        print("PII/Secret scan failed:", file=sys.stderr)
        for item in findings:
            print(f"  - {item}", file=sys.stderr)
        return 1

    print("PII/Secret scan passed with zero findings.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
