#!/usr/bin/env python3
"""Check README request includes, local images, and experiment references."""

from collections import Counter, defaultdict
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit


ROOT = Path(__file__).resolve().parent
README = ROOT / "README.md"
INCLUDE_OPEN = re.compile(r"^\s*<!--\s*include:\s*(\S.*?)\s*-->\s*$")
INCLUDE_CLOSE = re.compile(r"^\s*<!--\s*/include\s*-->\s*$")
IMAGE = re.compile(r"!\[[^\]]*\]\(\s*(?:<([^>]+)>|([^\s)]+))")
EXPERIMENT_ID = re.compile(r"^(E\d+)_", re.IGNORECASE)
REQUEST_SUFFIXES = {".http", ".rest"}


def _local_file(root, raw_path, source, line, errors):
    """Resolve a README-relative path without allowing it outside the repo."""
    path = Path(raw_path)
    if path.is_absolute():
        errors.append(f"{source}:{line}: expected a repository-relative path, got {raw_path!r}")
        return None

    resolved = (root / path).resolve()
    try:
        relative = resolved.relative_to(root.resolve())
    except ValueError:
        errors.append(f"{source}:{line}: path escapes the repository: {raw_path!r}")
        return None

    if not resolved.is_file():
        errors.append(f"{source}:{line}: referenced file does not exist: {raw_path}")
        return None
    return relative


def validate(root=ROOT):
    root = Path(root).resolve()
    readme = root / "README.md"
    if not readme.is_file():
        print(f"ERROR: README not found: {readme}", file=sys.stderr)
        return 1

    try:
        lines = readme.read_text(encoding="utf-8").splitlines()
    except OSError as exc:
        print(f"ERROR: cannot read {readme}: {exc}", file=sys.stderr)
        return 1

    errors = []
    include_paths = []
    active_include = None

    for line_number, line in enumerate(lines, start=1):
        opening = INCLUDE_OPEN.fullmatch(line)
        if opening:
            target = opening.group(1).strip()
            include_paths.append((target, line_number))
            if active_include is not None:
                errors.append(
                    f"README.md:{line_number}: nested include marker "
                    f"(previous include opened at line {active_include[1]})"
                )
            else:
                active_include = (target, line_number)

            relative = _local_file(root, target, "README.md", line_number, errors)
            if relative is not None and relative.suffix.lower() not in REQUEST_SUFFIXES:
                errors.append(
                    f"README.md:{line_number}: include must reference a request file "
                    f"(.http or .rest): {target}"
                )
            continue

        if INCLUDE_CLOSE.fullmatch(line):
            if active_include is None:
                errors.append(f"README.md:{line_number}: closing include marker has no opener")
            else:
                active_include = None
            continue

    if active_include is not None:
        errors.append(
            f"README.md:{active_include[1]}: include marker has no matching "
            "<!-- /include -->"
        )

    include_counts = Counter()
    for target, _ in include_paths:
        resolved = (root / target).resolve()
        try:
            relative = resolved.relative_to(root)
        except ValueError:
            continue
        include_counts[relative] += 1
    for path, count in include_counts.items():
        if count > 1:
            errors.append(f"README.md: request file is included {count} times: {path}")

    for line_number, line in enumerate(lines, start=1):
        for image in IMAGE.finditer(line):
            target = image.group(1) or image.group(2)
            parsed = urlsplit(target)
            if parsed.scheme or target.startswith("//") or not parsed.path:
                continue
            image_path = unquote(parsed.path)
            _local_file(root, image_path, "README.md", line_number, errors)

    request_files = []
    ids_to_files = defaultdict(list)
    for path in root.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in REQUEST_SUFFIXES:
            continue
        if any(part.startswith(".") for part in path.relative_to(root).parts):
            continue
        relative = path.relative_to(root)
        request_files.append(relative)
        match = EXPERIMENT_ID.match(path.name)
        if match:
            ids_to_files[match.group(1).upper()].append(relative)

    for experiment_id, paths in sorted(ids_to_files.items()):
        if len(paths) > 1:
            errors.append(
                f"{experiment_id}: duplicate experiment ID in request filenames: "
                + ", ".join(str(path) for path in sorted(paths))
            )
        for path in paths:
            count = include_counts[path]
            if count == 0:
                errors.append(
                    f"{path}: experiment request file is not referenced by a README include"
                )
            elif count > 1:
                # The duplicate include is also reported above; this adds ID context.
                errors.append(
                    f"{experiment_id}: request file {path} is included {count} times"
                )

    if errors:
        print("README validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(
        f"README validation passed: {len(include_paths)} request includes, "
        f"{len(ids_to_files)} unique experiment IDs, local image references exist."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(validate())
