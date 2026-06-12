#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./uninstall.sh
  ./uninstall.sh <target-repository-path>

Removes symbolic links created from this repository in:
  - $HOME when no target repository path is given
  - the target repository when a path is given

Source link roots:
  .agents/skills
  .codex/agents
  .github/agents

Home uninstall targets:
  .agents/skills
  .codex/agents
  .copilot/agents
EOF
}

if [[ $# -gt 1 ]]; then
  usage >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Error: python3 is required." >&2
  exit 1
fi

canonical_path() {
  python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$1"
}

path_is_within() {
  python3 -c '
import os
import sys

path = os.path.realpath(sys.argv[1])
root = os.path.realpath(sys.argv[2])

try:
    print("1" if os.path.commonpath([path, root]) == root else "0")
except ValueError:
    print("0")
' "$1" "$2"
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SOURCE_ROOT="$(canonical_path "$SCRIPT_DIR")"

if [[ $# -eq 0 ]]; then
  TARGET_LABEL="home directory"
  TARGET_ROOT="$(canonical_path "$HOME")"
else
  TARGET_LABEL="target repository"
  TARGET_INPUT="$1"

  if [[ ! -d "$TARGET_INPUT" ]]; then
    echo "Error: target repository path does not exist: $TARGET_INPUT" >&2
    exit 1
  fi

  TARGET_ROOT="$(canonical_path "$TARGET_INPUT")"
fi

if [[ "$TARGET_ROOT" == "$SOURCE_ROOT" ]]; then
  echo "Error: $TARGET_LABEL must be different from the source repository." >&2
  exit 1
fi

if [[ $# -eq 1 && ! -e "$TARGET_ROOT/.git" ]]; then
  echo "Error: target path is not a Git repository root: $TARGET_ROOT" >&2
  exit 1
fi

SOURCE_LINK_ROOTS=(
  ".agents/skills"
  ".codex/agents"
  ".github/agents"
)

if [[ $# -eq 0 ]]; then
  TARGET_LINK_ROOTS=(
    ".agents/skills"
    ".codex/agents"
    ".copilot/agents"
  )
else
  TARGET_LINK_ROOTS=("${SOURCE_LINK_ROOTS[@]}")
fi

for rel_dir in "${SOURCE_LINK_ROOTS[@]}"; do
  if [[ ! -d "$SOURCE_ROOT/$rel_dir" ]]; then
    echo "Error: source directory is missing: $SOURCE_ROOT/$rel_dir" >&2
    exit 1
  fi
done

removed_count=0
skipped_non_symlink_count=0
skipped_non_managed_count=0
missing_target_dir_count=0
skipped_target_root_count=0

declare -A CLEANED_DIRS=()

remove_if_empty() {
  local dir="$1"

  if [[ -d "$dir" ]] && rmdir "$dir" 2>/dev/null; then
    CLEANED_DIRS["$dir"]=1
  fi
}

for i in "${!SOURCE_LINK_ROOTS[@]}"; do
  source_rel_dir="${SOURCE_LINK_ROOTS[$i]}"
  target_rel_dir="${TARGET_LINK_ROOTS[$i]}"
  source_dir="$SOURCE_ROOT/$source_rel_dir"
  target_dir="$TARGET_ROOT/$target_rel_dir"

  if [[ ! -d "$target_dir" ]]; then
    if [[ -e "$target_dir" || -L "$target_dir" ]]; then
      skipped_target_root_count=$((skipped_target_root_count + 1))
    else
      missing_target_dir_count=$((missing_target_dir_count + 1))
    fi
    continue
  fi

  while IFS= read -r -d '' target_entry; do
    if [[ ! -L "$target_entry" ]]; then
      skipped_non_symlink_count=$((skipped_non_symlink_count + 1))
      continue
    fi

    if [[ "$(path_is_within "$target_entry" "$source_dir")" != "1" ]]; then
      skipped_non_managed_count=$((skipped_non_managed_count + 1))
      continue
    fi

    rm "$target_entry"
    removed_count=$((removed_count + 1))
  done < <(find "$target_dir" -mindepth 1 -maxdepth 1 -print0)
done

for rel_dir in "${TARGET_LINK_ROOTS[@]}"; do
  target_dir="$TARGET_ROOT/$rel_dir"
  parent_dir="$(dirname "$target_dir")"

  remove_if_empty "$target_dir"
  remove_if_empty "$parent_dir"
done

echo "Uninstall complete."
echo "  Source:                 $SOURCE_ROOT"
echo "  Target:                 $TARGET_ROOT"
echo "  Removed:                $removed_count"
echo "  Skipped non-symlinks:   $skipped_non_symlink_count"
echo "  Skipped unmanaged links:$skipped_non_managed_count"
echo "  Missing target dirs:    $missing_target_dir_count"
echo "  Skipped target roots:   $skipped_target_root_count"
echo "  Cleaned empty dirs:     ${#CLEANED_DIRS[@]}"
