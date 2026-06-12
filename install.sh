#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./install.sh
  ./install.sh <target-repository-path>

Creates symbolic links in:
  - $HOME when no target repository path is given
  - the target repository when a path is given

Source link roots:
  .agents/skills
  .codex/agents
  .github/agents

Home install targets:
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

relative_path() {
  python3 -c 'import os, sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$1" "$2"
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

declare -a SOURCE_ENTRIES=()
declare -a TARGET_ENTRIES=()
declare -a CONFLICTS=()

for i in "${!SOURCE_LINK_ROOTS[@]}"; do
  source_rel_dir="${SOURCE_LINK_ROOTS[$i]}"
  target_rel_dir="${TARGET_LINK_ROOTS[$i]}"
  source_dir="$SOURCE_ROOT/$source_rel_dir"
  target_dir="$TARGET_ROOT/$target_rel_dir"

  while IFS= read -r -d '' source_entry; do
    entry_name="$(basename "$source_entry")"
    target_entry="$target_dir/$entry_name"

    SOURCE_ENTRIES+=("$source_entry")
    TARGET_ENTRIES+=("$target_entry")

    if [[ -L "$target_entry" ]]; then
      existing_resolved="$(canonical_path "$target_entry")"
      source_resolved="$(canonical_path "$source_entry")"

      if [[ "$existing_resolved" != "$source_resolved" ]]; then
        CONFLICTS+=("$target_entry (different symlink target)")
      fi
      continue
    fi

    if [[ -e "$target_entry" ]]; then
      CONFLICTS+=("$target_entry (already exists)")
    fi
  done < <(find "$source_dir" -mindepth 1 -maxdepth 1 -print0)
done

if (( ${#CONFLICTS[@]} > 0 )); then
  echo "Error: install aborted because conflicting entries already exist:" >&2
  for conflict in "${CONFLICTS[@]}"; do
    echo "  - $conflict" >&2
  done
  exit 1
fi

for rel_dir in "${TARGET_LINK_ROOTS[@]}"; do
  mkdir -p "$TARGET_ROOT/$rel_dir"
done

created_count=0
skipped_count=0

for i in "${!SOURCE_ENTRIES[@]}"; do
  source_entry="${SOURCE_ENTRIES[$i]}"
  target_entry="${TARGET_ENTRIES[$i]}"

  if [[ -L "$target_entry" ]]; then
    skipped_count=$((skipped_count + 1))
    continue
  fi

  link_parent="$(dirname "$target_entry")"
  link_target="$(relative_path "$source_entry" "$link_parent")"
  ln -s "$link_target" "$target_entry"
  created_count=$((created_count + 1))
done

echo "Install complete."
echo "  Source:  $SOURCE_ROOT"
echo "  Target:  $TARGET_ROOT"
echo "  Created: $created_count"
echo "  Skipped: $skipped_count"
