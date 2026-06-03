#!/usr/bin/env python3
"""
Audit modular coverage of the legacy monolithic test files.

For each `libraries/stzlib/base/test/stz<X>Test.ring` (the originals,
hundreds of /*---*/ narrative blocks chained inline), check that the
modular dir `libraries/stzlib/base/test/modular/<x>/` contains the
same assertions and `#-->` expected markers.

Output three buckets per legacy file:

  GREEN   -- every `#-->` marker in the legacy file appears in some
             modular block under <x>/. Safe to archive.
  YELLOW  -- modular dir exists but is missing some markers. Report
             how many and from which legacy block.
  RED     -- no modular dir at all, or modular dir is empty. Still
             load-bearing; do NOT archive.

Pass --archive to actually `git mv` the GREEN files into
libraries/stzlib/base/test/legacy/. Default is dry-run.

Pass --json to emit machine-readable output instead of the human
report.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).parent
TEST_DIR = ROOT / "libraries" / "stzlib" / "base" / "test"
MOD_ROOT = TEST_DIR / "modular"
LEGACY_DIR = TEST_DIR / "legacy"

# Match a `#--> expected` marker. We compare the *value* part
# (whitespace-collapsed) so reformat-only drift doesn't trip the audit.
MARKER_RE = re.compile(r"^\s*#-->\s*(.+?)\s*$", re.M)

# Match block delimiters in the monolith: `/*----`, `/*-`, `/*=`, etc.
BLOCK_OPEN_RE = re.compile(r"^/\*[-=]+", re.M)


def _norm(s: str) -> str:
    """Collapse all whitespace and lowercase for fuzzy-equality."""
    return re.sub(r"\s+", " ", s).strip().lower()


def extract_markers(text: str) -> list[str]:
    """Return the list of normalised `#-->` expected values in text."""
    return [_norm(m.group(1)) for m in MARKER_RE.finditer(text)]


def split_blocks(text: str) -> list[str]:
    """Split a monolith into its narrative blocks.

    The first chunk before any `/*---` is the file header (load, etc.)
    and is included as block 0 for completeness.
    """
    parts = BLOCK_OPEN_RE.split(text)
    return parts


def legacy_stem_to_modular_name(stem: str) -> str:
    """Map `stzCounterTest` / `stzcountertest` -> `counter`."""
    s = stem.lower()
    if s.startswith("stz"):
        s = s[3:]
    if s.endswith("test"):
        s = s[:-4]
    return s


def collect_modular_markers(mod_dir: Path) -> Counter[str]:
    """Aggregate every `#-->` marker from every block under mod_dir."""
    bag: Counter[str] = Counter()
    if not mod_dir.is_dir():
        return bag
    for ring_file in sorted(mod_dir.glob("*.ring")):
        if ring_file.name.startswith("_"):
            continue
        text = ring_file.read_text(encoding="utf-8", errors="replace")
        for marker in extract_markers(text):
            bag[marker] += 1
    return bag


def audit_one(legacy_file: Path) -> dict:
    """Audit a single legacy monolith.

    Returns:
      { name, modular_name, color, legacy_marker_count,
        modular_marker_count, missing: [...],
        missing_count, total_assertions_in_legacy }
    """
    stem = legacy_file.stem
    mod_name = legacy_stem_to_modular_name(stem)
    mod_dir = MOD_ROOT / mod_name

    text = legacy_file.read_text(encoding="utf-8", errors="replace")
    legacy_markers = extract_markers(text)

    if not mod_dir.is_dir():
        color = "RED"
        missing = legacy_markers
        modular_count = 0
    else:
        modular_bag = collect_modular_markers(mod_dir)
        modular_count = sum(modular_bag.values())
        missing = []
        # Track per-marker multiplicity so a legacy file with the same
        # marker three times is only "covered" if modular has it >=3 too.
        legacy_bag = Counter(legacy_markers)
        for marker, want in legacy_bag.items():
            have = modular_bag.get(marker, 0)
            if have < want:
                # Record the under-coverage (want - have copies missing)
                missing.extend([marker] * (want - have))
        if not missing:
            # A monolith with zero `#-->` markers is not actually
            # *verified* by anything -- the audit can only certify
            # "no assertions were lost" if there were assertions to
            # begin with. Flag it as GREY so --archive doesn't sweep
            # it up without human inspection.
            if len(legacy_markers) == 0:
                color = "GREY"
            else:
                color = "GREEN"
        elif modular_count > 0:
            color = "YELLOW"
        else:
            color = "RED"

    return {
        "name": legacy_file.name,
        "modular_name": mod_name,
        "color": color,
        "legacy_marker_count": len(legacy_markers),
        "modular_marker_count": modular_count,
        "missing_count": len(missing),
        "missing_sample": missing[:5],
    }


def discover_legacy_files() -> list[Path]:
    """Return every stz*Test.ring under base/test/ (not inside modular/)."""
    seen: dict[str, Path] = {}
    for path in TEST_DIR.glob("stz*est.ring"):
        # Skip when the file is *inside* a subdir (e.g. legacy/ later).
        if path.parent != TEST_DIR:
            continue
        # Case-insensitive dedupe so stzfoo + stzFoo on Windows count once.
        key = path.name.lower()
        seen.setdefault(key, path)
    return sorted(seen.values())


def render_report(results: list[dict]) -> str:
    by_color: dict[str, list[dict]] = {
        "GREEN": [], "YELLOW": [], "RED": [], "GREY": [],
    }
    for r in results:
        by_color[r["color"]].append(r)

    lines = []
    lines.append(
        f"audit: {len(results)} legacy monoliths inspected"
        f"  --  GREEN {len(by_color['GREEN'])}"
        f"  YELLOW {len(by_color['YELLOW'])}"
        f"  RED {len(by_color['RED'])}"
        f"  GREY {len(by_color['GREY'])}"
    )
    lines.append("")
    lines.append("GREEN (verified -- every #--> marker covered, safe to archive):")
    for r in by_color["GREEN"]:
        lines.append(
            f"  {r['name']:<45s}  legacy {r['legacy_marker_count']:4d}"
            f" / modular {r['modular_marker_count']:4d}"
        )
    lines.append("")
    lines.append("YELLOW (modular dir exists but under-covers the legacy):")
    for r in by_color["YELLOW"]:
        lines.append(
            f"  {r['name']:<45s}  missing {r['missing_count']:3d} marker(s)"
            f"  ->  modular/{r['modular_name']}/"
        )
        for m in r["missing_sample"]:
            lines.append(f"      example missing marker: {m[:90]}")
    lines.append("")
    lines.append("RED (no modular coverage at all -- still load-bearing):")
    for r in by_color["RED"]:
        lines.append(
            f"  {r['name']:<45s}  -> modular/{r['modular_name']}/  MISSING"
            f"  ({r['legacy_marker_count']} markers in legacy)"
        )
    lines.append("")
    lines.append(
        "GREY (no #--> markers in legacy -- nothing to verify, "
        "needs manual inspection before archiving):"
    )
    for r in by_color["GREY"]:
        lines.append(f"  {r['name']:<45s}  modular/{r['modular_name']}/ exists but has no assertions either")
    return "\n".join(lines)


def _tracked_name(name: str) -> str | None:
    """Return the exact path git knows for this test file, or None.

    Windows treats the filesystem as case-insensitive, so a file
    listed by Path.glob() as `stzcountertest.ring` may actually be
    tracked by git as `stzCounterTest.ring`. git mv refuses the
    lowercase form ("not under version control"). Ask git for its
    canonical spelling and use that.
    """
    proc = subprocess.run(
        ["git", "ls-files", str((TEST_DIR / name).relative_to(ROOT))],
        cwd=str(ROOT),
        capture_output=True,
        text=True,
    )
    if proc.returncode == 0 and proc.stdout.strip():
        return proc.stdout.strip().splitlines()[0]
    # Fall back to a directory-wide listing keyed on lowercase
    proc = subprocess.run(
        ["git", "ls-files", str(TEST_DIR.relative_to(ROOT))],
        cwd=str(ROOT),
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        return None
    target = name.lower()
    for line in proc.stdout.splitlines():
        if Path(line).name.lower() == target:
            return line
    return None


def archive_green(results: list[dict]) -> int:
    """git mv every GREEN legacy file into legacy/ subdir."""
    LEGACY_DIR.mkdir(exist_ok=True)
    moved = 0
    for r in results:
        if r["color"] != "GREEN":
            continue
        tracked = _tracked_name(r["name"])
        if tracked is None:
            print(
                f"  skip (not git-tracked): {r['name']}",
                file=sys.stderr,
            )
            continue
        canon_name = Path(tracked).name
        dst_rel = str((LEGACY_DIR / canon_name).relative_to(ROOT))
        if (LEGACY_DIR / canon_name).exists():
            print(f"  skip (dst exists): {canon_name}", file=sys.stderr)
            continue
        proc = subprocess.run(
            ["git", "mv", tracked, dst_rel],
            cwd=str(ROOT),
            capture_output=True,
            text=True,
        )
        if proc.returncode == 0:
            moved += 1
            print(f"  archived: {canon_name}")
        else:
            print(
                f"  FAILED to archive {canon_name}: {proc.stderr.strip()}",
                file=sys.stderr,
            )
    return moved


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--archive",
        action="store_true",
        help="git-mv every GREEN legacy file into base/test/legacy/",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="emit machine-readable JSON instead of the human report",
    )
    parser.add_argument(
        "--only",
        metavar="NAME",
        help="audit a single legacy file (basename or substring match)",
    )
    args = parser.parse_args()

    files = discover_legacy_files()
    if args.only:
        files = [p for p in files if args.only.lower() in p.name.lower()]
        if not files:
            print(f"no legacy file matched --only={args.only!r}", file=sys.stderr)
            return 2

    results = [audit_one(p) for p in files]

    if args.json:
        json.dump(results, sys.stdout, indent=2)
        sys.stdout.write("\n")
    else:
        print(render_report(results))

    if args.archive:
        print()
        print("archiving GREEN files ...")
        moved = archive_green(results)
        print(f"done: {moved} file(s) moved into {LEGACY_DIR}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
