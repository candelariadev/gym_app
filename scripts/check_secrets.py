#!/usr/bin/env python3
"""Local-only publication guard. Reports paths/rules, never secret values."""
import argparse
import fnmatch
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import sys
import tempfile


BLOCKED_DIRS = {
    ".gradle", ".idea", "build", "target", ".dart_tool", ".fvm",
    "node_modules", ".aws", ".ssh", ".secrets", "secrets",
    "services_account", "environments", "env", "__pycache__", "coverage",
}
BLOCKED_NAMES = {
    ".DS_Store", ".npmrc", ".pypirc", ".netrc",
    "credentials.json", "application_default_credentials.json",
    "google-services.json", "GoogleService-Info.plist", "firebase_options.dart",
    "firebase_app_id_file.json", "key.properties", "local.properties",
}
BLOCKED_PATTERNS = (
    "*.pem", "*.key", "*.p8", "*.p12", "*.pfx", "*.jks", "*.keystore",
    "*.mobileprovision", "*.provisionprofile", "*.dump", "*.sql", "*.bson",
    "*.bak", "*.backup", "*.zip", "*.log", "*.pyc",
    "*firebase-adminsdk*.json", "firebase-service-account*.json",
    "service-account*.json", "client_secret_*.json", "id_rsa*", "id_ed25519*",
    "config.local.*", "application-local.*", "application-secrets.*",
    "docker-compose.override.*", "compose.override.*",
)


def forbidden(path):
    parts = PurePosixPath(path).parts
    name = parts[-1]
    return (
        bool(set(parts[:-1]) & BLOCKED_DIRS)
        or name in BLOCKED_NAMES
        or (name.startswith(".env") and name != ".env.example")
        or any(fnmatch.fnmatchcase(name, pattern) for pattern in BLOCKED_PATTERNS)
    )


def git(root, *args):
    return subprocess.check_output(
        ["git", "-C", str(root), *args], stderr=subprocess.PIPE,
    )


def scan(command, config):
    result = subprocess.run(
        ["gitleaks", *command, "--config", str(config),
         "--redact=100", "--no-banner", "--no-color",
         "--ignore-gitleaks-allow", "--report-format=json", "--report-path=-"],
        capture_output=True, text=True,
    )
    if result.returncode not in (0, 1):
        print("BLOCKED: secret scanner failed. No publication allowed.")
        return False
    try:
        findings = json.loads(result.stdout)
    except (ValueError, TypeError):
        print("BLOCKED: invalid scanner report. No publication allowed.")
        return False
    for item in findings:
        print(f"BLOCKED: {item['File']}:{item['StartLine']} [{item['RuleID']}]")
    return result.returncode == 0 and not findings


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--staged", action="store_true",
                      help="Scan the complete index, including unchanged files")
    mode.add_argument("--working-tree", action="store_true",
                      help="Scan tracked and nonignored untracked files")
    mode.add_argument("--history", action="store_true")
    parser.add_argument("--revision", help="Commit being pushed; default: all local refs")
    args = parser.parse_args()
    root = Path(git(Path.cwd(), "rev-parse", "--show-toplevel").decode().strip())
    config = Path(__file__).resolve().parents[1] / ".gitleaks.toml"
    if shutil.which("gitleaks") is None:
        print("BLOCKED: install Gitleaks first (brew install gitleaks).")
        return 2
    if args.history:
        rev = "--all"
        if args.revision:
            rev = git(root, "rev-parse", "--verify", args.revision + "^{commit}").decode().strip()
        names = git(root, "log", rev, "--format=", "--name-only", "-z", "--diff-filter=AM").decode()
        blocked = sorted({p.strip("\n") for p in names.split("\0")
                          if p.strip("\n") and forbidden(p.strip("\n"))})
        for path in blocked[:12]:
            print(f"BLOCKED: history contains prohibited file: {path}")
        if len(blocked) > 12:
            print(f"BLOCKED: {len(blocked)} prohibited historical paths in total.")
        clean = scan(["git", str(root), "--log-opts=" + rev], config)
        if blocked or not clean:
            print("Rotate exposed credentials and coordinate history cleanup; .gitignore is not retroactive.")
            return 1
    else:
        # Read blobs from the index so partially staged files cannot hide secrets.
        entries = {}
        for record in git(root, "ls-files", "--stage", "-z").split(b"\0"):
            if not record:
                continue
            meta, name = record.split(b"\t", 1)
            mode, oid, stage = meta.decode().split()
            if stage != "0":
                print("BLOCKED: resolve index conflicts before publication.")
                return 1
            entries[os.fsdecode(name)] = (mode, oid)
        names = set(entries)
        if args.working_tree:
            names.update(os.fsdecode(p) for p in git(
                root, "ls-files", "--others", "--exclude-standard", "-z"
            ).split(b"\0") if p)
        blocked = sorted(p for p in names if forbidden(p))
        for path in blocked:
            print(f"BLOCKED: prohibited file in publication candidates: {path}")
        with tempfile.TemporaryDirectory(prefix="gymsas-secret-check-") as directory:
            snapshot = Path(directory)
            for name in sorted(names):
                if name in blocked:
                    continue
                if args.staged:
                    mode, oid = entries[name]
                    if mode == "160000":
                        print(f"BLOCKED: audit submodule separately: {name}")
                        return 1
                    content = git(root, "cat-file", "blob", oid)
                else:
                    source = root / name
                    if source.is_symlink():
                        content = os.fsencode(os.readlink(source))
                    elif source.is_file():
                        content = source.read_bytes()
                    else:
                        continue
                target = snapshot / name
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(content)
            clean = scan(["dir", str(snapshot)], config)
        if blocked or not clean:
            return 1
    print("OK: no prohibited files or detected secrets in the requested scope.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, subprocess.CalledProcessError):
        print("BLOCKED: audit could not complete. No publication allowed.")
        sys.exit(2)
