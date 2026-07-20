#!/usr/bin/env python3
"""
Migrate Day One imported notes from day-one/ to daily/ or weekly/.

Rules:
- Filenames like "2025-06-29 164716.md" -> daily/2025-06-29.md
- Multiple files with same date: combine tags, append body with blank line separator
- Tags: lowercase, spaces replaced with hyphens, "day-one" and "daily" added
- Files containing "Sunday review" (case-insensitive) -> weekly/YYYY-WWW.md
  with tags "day-one" and "weekly" instead of "daily"
"""

import os
import re
import sys
import shutil
from datetime import datetime, date
from pathlib import Path

import yaml  # pip install pyyaml


# ── Config ────────────────────────────────────────────────────────────────────

VAULT_ROOT = Path.home() / "Obsidian-Vault"
SOURCE_DIR = VAULT_ROOT / "day-one"
DAILY_DIR  = VAULT_ROOT / "daily"
WEEKLY_DIR = VAULT_ROOT / "weekly"

# Multi-word tags to kebab-case (add more as needed)
KEBAB_REPLACEMENTS = {
    "martial arts": "martial-arts",
    "jiu jitsu":    "jiu-jitsu",
    "weight loss":  "weight-loss",
    "daily prompt": "day-one-prompt",
    "race analysis": "race-analysis",
    "apple fitness+": "apple-fitness"
}

DRY_RUN = "--dry-run" in sys.argv


# ── Helpers ───────────────────────────────────────────────────────────────────

def log(msg: str):
    prefix = "[DRY RUN] " if DRY_RUN else ""
    print(f"{prefix}{msg}")


def parse_note(path: Path) -> tuple[dict, str]:
    """Return (frontmatter_dict, body_str). Body does not include the --- delimiters."""
    text = path.read_text(encoding="utf-8")
    if text.startswith("---"):
        # Find closing ---
        end = text.find("\n---", 3)
        if end != -1:
            fm_raw = text[3:end].strip()
            body   = text[end + 4:].lstrip("\n")
            fm = yaml.safe_load(fm_raw) or {}
            return fm, body
    return {}, text


def serialize_note(fm: dict, body: str) -> str:
    """Combine frontmatter and body back into a note string."""
    fm_str = yaml.dump(fm, allow_unicode=True, default_flow_style=False, sort_keys=False).strip()
    return f"---\n{fm_str}\n---\n\n{body}"


def normalize_tag(tag: str) -> str:
    """Lowercase, apply kebab replacements, replace remaining spaces with hyphens."""
    t = str(tag).lower().strip()
    for phrase, replacement in KEBAB_REPLACEMENTS.items():
        t = t.replace(phrase, replacement)
    t = re.sub(r"\s+", "-", t)
    return t


def normalize_tags(tags) -> list[str]:
    if not tags:
        return []
    if isinstance(tags, str):
        tags = [tags]
    return [normalize_tag(t) for t in tags]


def merge_tags(existing: list[str], additions: list[str]) -> list[str]:
    seen = list(existing)
    seen_set = set(seen)
    for t in additions:
        if t not in seen_set:
            seen.append(t)
            seen_set.add(t)
    return seen


def is_sunday_review(body: str) -> bool:
    return bool(re.search(r"sunday\s+review", body, re.IGNORECASE))


def week_filename(d: date) -> str:
    """Return weekly/YYYY-WNN.md style filename (ISO week)."""
    iso = d.isocalendar()          # (year, week, weekday)
    return f"{iso[0]}-W{iso[1]:02d}.md"


def extract_date(filename: str) -> date | None:
    """Parse date from '2025-06-29 164716' style stem."""
    m = re.match(r"(\d{4}-\d{2}-\d{2})", filename)
    if m:
        return datetime.strptime(m.group(1), "%Y-%m-%d").date()
    return None


def write_or_merge(dest: Path, fm: dict, body: str):
    """Write dest, or merge into it if it already exists."""
    if dest.exists():
        existing_fm, existing_body = parse_note(dest)
        # Merge tags
        combined_tags = merge_tags(
            existing_fm.get("tags", []),
            fm.get("tags", [])
        )
        existing_fm["tags"] = combined_tags
        # Append body
        merged_body = existing_body.rstrip("\n") + "\n\n" + body.lstrip("\n")
        log(f"  MERGE -> {dest.relative_to(VAULT_ROOT)}")
        if not DRY_RUN:
            dest.write_text(serialize_note(existing_fm, merged_body), encoding="utf-8")
    else:
        log(f"  WRITE -> {dest.relative_to(VAULT_ROOT)}")
        if not DRY_RUN:
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_text(serialize_note(fm, body), encoding="utf-8")


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    source_files = sorted(SOURCE_DIR.glob("*.md"))
    if not source_files:
        print(f"No .md files found in {SOURCE_DIR}")
        return

    log(f"Found {len(source_files)} files in {SOURCE_DIR}")
    log(f"Daily dir : {DAILY_DIR}")
    log(f"Weekly dir: {WEEKLY_DIR}")
    print()

    for src in source_files:
        note_date = extract_date(src.stem)
        if note_date is None:
            log(f"SKIP (unparseable date): {src.name}")
            continue

        fm, body = parse_note(src)

        # Normalize existing tags
        tags = normalize_tags(fm.get("tags", []))

        if is_sunday_review(body):
            # Weekly note
            tags = merge_tags(tags, ["day-one", "weekly"])
            fm["tags"] = tags
            dest = WEEKLY_DIR / week_filename(note_date)
            log(f"{src.name} -> WEEKLY {dest.name}  tags={tags}")
        else:
            # Daily note
            tags = merge_tags(tags, ["day-one", "daily"])
            fm["tags"] = tags
            dest = DAILY_DIR / f"{note_date}.md"
            log(f"{src.name} -> DAILY  {dest.name}  tags={tags}")

        write_or_merge(dest, fm, body)

    print()
    log("Done.")
    if DRY_RUN:
        print("Re-run without --dry-run to apply changes.")


if __name__ == "__main__":
    main()
