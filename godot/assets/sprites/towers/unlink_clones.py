#!/usr/bin/env python3
"""
Batch unlink clones recursively on every SVG in a folder (modifies files in-place).

This version uses export-filename + export-do (run with cwd=svg_dir so the export filename is just the basename),
which is more reliable for saving in most Inkscape versions.

Usage:
  # use inkscape env var and folder name 'svgs' that's next to where you run the script:
  python unlink_clones_batch_savefix.py --folder svgs

  # explicitly provide inkscape and do subfolders:
  python unlink_clones_batch_savefix.py --inkscape "/usr/bin/inkscape" --folder ./my_svgs --recursive

Options:
  --backup    make a .bak copy before modifying each file
  --dry-run   print commands but don't execute inkscape
  -v / -vv    increase verbosity
"""
from pathlib import Path
import argparse
import subprocess
import logging
import os
import sys
import shutil

# actions we need
UNLINK_ACTIONS = "select-all;clone-unlink-recursively"
# We'll append export-filename:<basename>;export-do;FileClose when running in the svg folder.

def find_folder(candidate: str) -> Path:
    p = Path(candidate)
    if p.exists() and p.is_dir():
        return p.resolve()
    alt1 = Path.cwd() / candidate
    if alt1.exists() and alt1.is_dir():
        return alt1.resolve()
    script_dir = Path(__file__).resolve().parent
    alt2 = script_dir / candidate
    if alt2.exists() and alt2.is_dir():
        return alt2.resolve()
    return None

def run_inkscape_in_dir(inkscape_cmd: str, actions: str, input_filename: str, cwd: Path, dry_run: bool=False, timeout: int=60):
    """
    Run inkscape with --batch-process and --actions=... for the given file name, using cwd,
    returning (returncode, stdout, stderr)
    """
    actions_arg = f"--actions={actions}"
    cmd = [inkscape_cmd, "--batch-process", actions_arg, input_filename]

    logging.debug("Running: %s (cwd=%s)", " ".join(cmd), cwd)
    if dry_run:
        logging.info("[dry-run] Would run (cwd=%s): %s", cwd, " ".join(cmd))
        return 0, "", ""
    try:
        proc = subprocess.run(cmd, cwd=str(cwd), capture_output=True, text=True, timeout=timeout)
        return proc.returncode, proc.stdout or "", proc.stderr or ""
    except FileNotFoundError:
        logging.error("Inkscape executable not found: %s", inkscape_cmd)
        return 127, "", f"Inkscape not found: {inkscape_cmd}"
    except subprocess.TimeoutExpired as e:
        logging.error("Inkscape timed out for %s", input_filename)
        return -1, "", f"timeout: {e}"
    except Exception as e:
        logging.exception("Unexpected error running inkscape")
        return -2, "", str(e)

def process_file(inkscape_cmd: str, svg_path: Path, dry_run: bool=False, backup: bool=False):
    svg_dir = svg_path.parent
    svg_name = svg_path.name

    if backup and not dry_run:
        bak = svg_path.with_suffix(svg_path.suffix + ".bak")
        logging.info("Creating backup: %s", bak)
        shutil.copy2(svg_path, bak)

    # Build actions string using basename for export target (avoid absolute path with colon problems)
    actions = f"{UNLINK_ACTIONS};export-filename:{svg_name};export-do;FileClose"
    rc, out, err = run_inkscape_in_dir(inkscape_cmd, actions, svg_name, svg_dir, dry_run=dry_run)

    if rc == 0:
        logging.info("Processed & saved: %s", svg_path)
        return True
    else:
        logging.warning("Primary export method failed for %s (rc=%s). stderr:\n%s", svg_path, rc, err.strip())
        # Try fallback using FileSave action (some versions accept FileSave; sometimes it fails).
        fallback_actions = f"{UNLINK_ACTIONS};FileSave;FileClose"
        rc2, out2, err2 = run_inkscape_in_dir(inkscape_cmd, fallback_actions, svg_name, svg_dir, dry_run=dry_run)
        if rc2 == 0:
            logging.info("Fallback FileSave succeeded for: %s", svg_path)
            return True
        else:
            logging.error("Fallback FileSave also failed for %s (rc=%s). stderr:\n%s", svg_path, rc2, err2.strip())
            return False

def gather_files(folder: Path, recursive: bool):
    if recursive:
        return sorted(folder.rglob("*.svg"))
    else:
        return sorted(folder.glob("*.svg"))

def main():
    parser = argparse.ArgumentParser(description="Batch unlink clones recursively in SVG files using Inkscape (saves in-place).")
    parser.add_argument("--inkscape", help="Path/command for inkscape. If omitted, environment variable 'inkscape' is used.")
    parser.add_argument("--folder", required=True, help="Folder containing SVG files (relative or absolute).")
    parser.add_argument("--recursive", action="store_true", help="Also process subfolders.")
    parser.add_argument("--dry-run", action="store_true", help="Print commands without executing.")
    parser.add_argument("--backup", action="store_true", help="Make a .bak copy before modifying each file.")
    parser.add_argument("--verbose", "-v", action="count", default=0, help="Verbose logging (use -v or -vv).")
    args = parser.parse_args()

    # logging
    if args.verbose >= 2:
        level = logging.DEBUG
    elif args.verbose == 1:
        level = logging.INFO
    else:
        level = logging.WARNING
    logging.basicConfig(level=level, format="%(levelname)s: %(message)s")

    inkscape_cmd = args.inkscape or os.environ.get("inkscape")
    if not inkscape_cmd:
        logging.error("No Inkscape command supplied and environment variable 'inkscape' is not set.")
        logging.error("Set the environment variable 'inkscape' or pass --inkscape '/path/to/inkscape'.")
        sys.exit(2)

    folder_path = find_folder(args.folder)
    if folder_path is None:
        logging.error("Folder not found: %s", args.folder)
        sys.exit(2)

    files = gather_files(folder_path, args.recursive)
    if not files:
        logging.warning("No .svg files found in %s (recursive=%s).", folder_path, args.recursive)
        return

    logging.info("Found %d SVG file(s) in %s. Starting...", len(files), folder_path)

    failures = []
    for f in files:
        ok = process_file(inkscape_cmd, f, dry_run=args.dry_run, backup=args.backup)
        if not ok:
            failures.append(f)

    logging.info("Finished. Successes: %d, Failures: %d", len(files) - len(failures), len(failures))
    if failures:
        logging.error("Failed files:")
        for ff in failures:
            logging.error("  %s", ff)
        sys.exit(1)

if __name__ == "__main__":
    main()
