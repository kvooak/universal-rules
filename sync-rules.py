#!/usr/bin/env python3
"""
sync-rules.py - Sync universal rules to project .claude folders

This script automatically synchronizes rule files from the universal-rules
source folder to all project .claude/ folders.

USAGE:
    python sync-rules.py [--project <path>] [--all] [--dry-run]

OPTIONS:
    --project PATH    Sync to specific project path
    --all             Sync to all projects in parent directory
    --dry-run         Show what would be synced without actually copying
    --verbose, -v     Show detailed output

EXAMPLES:
    # Sync to specific project
    python sync-rules.py --project ../knowledge

    # Sync to all sibling projects
    python sync-rules.py --all

    # Dry run to see what would be synced
    python sync-rules.py --all --dry-run

HOW IT WORKS:
    1. Scans universal-rules/ for all .md rule files
    2. Finds target project .claude/ directories
    3. Copies .md files from source to target .claude/ folders
    4. Preserves .gitignore (keeps .claude/ out of git)
    5. Reports sync status

RULE FILES SYNCED:
    - universal.md
    - typescript.md
    - python.md
    - clean-architecture.md
    - Any other .md files in universal-rules/
"""

import argparse
import shutil
import sys
from datetime import datetime
from pathlib import Path

# Source directory (where this script lives)
UNIVERSAL_RULES_DIR = Path(__file__).parent
PARENT_DIR = UNIVERSAL_RULES_DIR.parent


def get_rule_files() -> list[Path]:
    """Get all .md rule files from universal-rules directory."""
    rule_files = []
    for file in UNIVERSAL_RULES_DIR.glob("*.md"):
        if file.is_file():
            rule_files.append(file)
    return sorted(rule_files)


def find_projects(parent_dir: Path) -> list[Path]:
    """Find all project directories with .claude/ folders."""
    projects = []

    for item in parent_dir.iterdir():
        if not item.is_dir():
            continue
        if item.name.startswith("."):
            continue
        if item == UNIVERSAL_RULES_DIR:
            continue  # Skip self

        claude_dir = item / ".claude"
        if claude_dir.exists() and claude_dir.is_dir():
            projects.append(item)

    return sorted(projects)


def sync_rules_to_project(
    project_path: Path,
    rule_files: list[Path],
    dry_run: bool = False,
    verbose: bool = False,
) -> dict:
    """
    Sync rule files to a project's .claude/ directory.

    Returns dict with sync statistics.
    """
    claude_dir = project_path / ".claude"

    if not claude_dir.exists():
        claude_dir.mkdir(parents=True, exist_ok=True)
        if verbose:
            print(f"  Created .claude/ directory")

    stats = {
        "project": project_path.name,
        "copied": 0,
        "updated": 0,
        "skipped": 0,
        "errors": 0,
    }

    for rule_file in rule_files:
        target_file = claude_dir / rule_file.name

        try:
            # Check if file exists and compare
            if target_file.exists():
                source_content = rule_file.read_text(encoding="utf-8")
                target_content = target_file.read_text(encoding="utf-8")

                if source_content == target_content:
                    stats["skipped"] += 1
                    if verbose:
                        print(f"    ✓ {rule_file.name} (unchanged)")
                    continue
                else:
                    action = "updated"
                    stats["updated"] += 1
            else:
                action = "copied"
                stats["copied"] += 1

            if not dry_run:
                shutil.copy2(rule_file, target_file)

            if verbose or dry_run:
                prefix = "[DRY RUN] " if dry_run else "    "
                print(f"{prefix}✓ {rule_file.name} ({action})")

        except Exception as e:
            stats["errors"] += 1
            print(f"    ✗ {rule_file.name} - ERROR: {e}", file=sys.stderr)

    return stats


def main():
    parser = argparse.ArgumentParser(
        description="Sync universal rules to project .claude/ folders",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )

    parser.add_argument(
        "--project",
        type=Path,
        help="Specific project path to sync to",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Sync to all projects in parent directory",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be synced without copying",
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Show detailed output",
    )

    args = parser.parse_args()

    # Validate arguments
    if not args.project and not args.all:
        parser.print_help()
        print("\nERROR: Must specify either --project or --all", file=sys.stderr)
        sys.exit(1)

    # Get rule files
    rule_files = get_rule_files()

    if not rule_files:
        print("ERROR: No .md rule files found in universal-rules/", file=sys.stderr)
        sys.exit(1)

    print("=" * 60)
    print("UNIVERSAL RULES SYNC")
    print("=" * 60)
    print(f"Source: {UNIVERSAL_RULES_DIR}")
    print(f"Rule files: {len(rule_files)}")
    for rf in rule_files:
        print(f"  - {rf.name}")
    print()

    if args.dry_run:
        print("⚠️  DRY RUN MODE - No files will be copied")
        print()

    # Determine target projects
    if args.project:
        projects = [args.project.resolve()]
        if not (projects[0] / ".claude").exists():
            print(f"Creating .claude/ directory in {projects[0].name}")
    else:  # args.all
        projects = find_projects(PARENT_DIR)

    if not projects:
        print("No projects found with .claude/ directories")
        sys.exit(0)

    print(f"Target projects: {len(projects)}")
    print()

    # Sync to each project
    total_stats = {
        "copied": 0,
        "updated": 0,
        "skipped": 0,
        "errors": 0,
    }

    for project in projects:
        print(f"📁 {project.name}")

        stats = sync_rules_to_project(
            project,
            rule_files,
            dry_run=args.dry_run,
            verbose=args.verbose,
        )

        # Accumulate totals
        for key in total_stats:
            total_stats[key] += stats[key]

        # Print summary for this project
        if not args.verbose:
            actions = []
            if stats["copied"]:
                actions.append(f"{stats['copied']} copied")
            if stats["updated"]:
                actions.append(f"{stats['updated']} updated")
            if stats["skipped"]:
                actions.append(f"{stats['skipped']} unchanged")
            if stats["errors"]:
                actions.append(f"❌ {stats['errors']} errors")

            if actions:
                print(f"  {', '.join(actions)}")
            else:
                print("  No changes")

        print()

    # Print final summary
    print("=" * 60)
    if args.dry_run:
        print("DRY RUN SUMMARY")
    else:
        print("SYNC COMPLETE")
    print("=" * 60)
    print(f"Projects synced: {len(projects)}")
    print(f"Files copied:    {total_stats['copied']}")
    print(f"Files updated:   {total_stats['updated']}")
    print(f"Files unchanged: {total_stats['skipped']}")

    if total_stats['errors']:
        print(f"❌ Errors:       {total_stats['errors']}")

    print()

    if not args.dry_run and (total_stats['copied'] > 0 or total_stats['updated'] > 0):
        print("✓ Rules synchronized successfully!")
        print()
        print("Next steps:")
        print("1. Review changes in project .claude/ folders")
        print("2. Ensure .claude/ is in .gitignore")
        print("3. Projects will use updated rules on next run")


if __name__ == "__main__":
    main()
