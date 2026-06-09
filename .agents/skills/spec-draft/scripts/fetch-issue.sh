#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <issue-number>" >&2
  exit 1
fi

issue_number="$1"
repo_root="$(git rev-parse --show-toplevel)"
output_dir="$repo_root/docs/tmp"
output_path="$output_dir/issue.md"

mkdir -p "$output_dir"
tmp_path="$(mktemp "$output_dir/issue.md.tmp.XXXXXX")"

cleanup() {
  rm -f "$tmp_path"
}

trap cleanup EXIT

cd "$repo_root"
gh issue view "$issue_number" --comments >"$tmp_path"
mv "$tmp_path" "$output_path"
trap - EXIT
