#!/usr/bin/env bash

set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)

if [[ ! -d "$repo_root" ]]; then
	printf 'Repository root not found: %s\n' "$repo_root" >&2
	exit 1
fi

repo_root=$(cd "$repo_root" && pwd)

draft_dir="$repo_root/docs/tmp/issues"
if [[ ! -d "$draft_dir" ]]; then
	printf 'Draft directory not found: %s\n' "$draft_dir" >&2
	exit 1
fi

tmp_files=()
cleanup() {
	if (( ${#tmp_files[@]} > 0 )); then
		rm -f "${tmp_files[@]}"
	fi
}
trap cleanup EXIT

repo=$(cd "$repo_root" && gh repo view --json nameWithOwner -q .nameWithOwner)
processed_count=0

while IFS= read -r -d '' draft; do
	title=$(awk '
		BEGIN { in_frontmatter = 0 }
		/^---$/ {
			if (in_frontmatter == 0) {
				in_frontmatter = 1
				next
			}
			exit
		}
		in_frontmatter == 1 && /^title:[[:space:]]*/ {
			sub(/^title:[[:space:]]*/, "", $0)
			print
			exit
		}
	' "$draft")

	if [[ -z "$title" ]]; then
		printf 'Draft is missing a title front matter: %s\n' "$draft" >&2
		exit 1
	fi

	body_tmp=$(mktemp)
	tmp_files+=("$body_tmp")
	awk '
		BEGIN { delimiter_count = 0 }
		/^---$/ {
			delimiter_count++
			next
		}
		delimiter_count >= 2 { print }
	' "$draft" > "$body_tmp"

	issue_url=$(cd "$repo_root" && gh issue create --repo "$repo" --title "$title" --body-file "$body_tmp")
	rm -f "$draft"
	printf '%s\n' "$issue_url"
	processed_count=$((processed_count + 1))
done < <(find "$draft_dir" -mindepth 1 -maxdepth 1 -type f -name '*.md' -print0 | sort -z)

if (( processed_count == 0 )); then
	printf 'No draft markdown files found in: %s\n' "$draft_dir" >&2
	exit 1
fi
