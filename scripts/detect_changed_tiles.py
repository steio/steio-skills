#!/usr/bin/env python3
"""
Detect changed tiles in a monorepo.
Used by CI/CD to determine which tiles to publish.
"""

import json
import subprocess
import sys
from pathlib import Path
from typing import Set


def get_changed_files(base_ref: str = "HEAD^") -> Set[str]:
    """Get list of changed files from git diff."""
    result = subprocess.run(
        ["git", "diff", "--name-only", base_ref, "HEAD", "--", "tiles/"],
        capture_output=True,
        text=True,
    )
    return set(result.stdout.strip().split("\n"))


def extract_tile_paths(changed_files: Set[str]) -> Set[str]:
    """Extract unique tile paths from changed files.

    Tile path format: tiles/category/tile-name
    """
    tile_paths = set()
    for file_path in changed_files:
        if not file_path.startswith("tiles/"):
            continue
        parts = file_path.split("/")
        if len(parts) >= 3:
            tile_path = "/".join(parts[:3])
            tile_paths.add(tile_path)
    return tile_paths


def validate_tile(tile_path: str) -> bool:
    """Validate that a tile has required files."""
    tile_dir = Path(tile_path)
    required = ["tile.json"]

    for req in required:
        if not (tile_dir / req).exists():
            print(f"Warning: {tile_path} missing {req}", file=sys.stderr)
            return False
    return True


def main():
    # Get changed files
    changed_files = get_changed_files()

    if not changed_files or changed_files == {""}:
        print(json.dumps([]))
        return

    # Extract tile paths
    tile_paths = extract_tile_paths(changed_files)

    # Validate and filter
    valid_tiles = [t for t in tile_paths if validate_tile(t)]

    # Output as JSON array
    print(json.dumps(sorted(valid_tiles)))


if __name__ == "__main__":
    main()
