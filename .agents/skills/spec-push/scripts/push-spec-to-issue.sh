#!/usr/bin/env bash

set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)

if [[ ! -d "$repo_root" ]]; then
	printf 'Repository root not found: %s\n' "$repo_root" >&2
	exit 1
fi

repo_root=$(cd "$repo_root" && pwd)

spec_file="$repo_root/docs/tmp/spec.md"
if [[ ! -f "$spec_file" ]]; then
	printf 'Spec file not found: %s\n' "$spec_file" >&2
	exit 1
fi

first_line=$(sed -n '1p' "$spec_file")
if [[ ! "$first_line" =~ ^#\ Issue\ #([0-9]+)\ 対応仕様$ ]]; then
	printf 'Spec title is invalid: %s\n' "$first_line" >&2
	exit 1
fi

issue_number="${BASH_REMATCH[1]}"
repo=$(cd "$repo_root" && gh repo view --json nameWithOwner -q .nameWithOwner)

cd "$repo_root"
gh issue comment "$issue_number" --repo "$repo" --body-file "$spec_file" >/dev/null
rm -f "$spec_file" "$repo_root/docs/tmp"/spec-review-*.md
gh issue view "$issue_number" --repo "$repo" --json url -q .url
