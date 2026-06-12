#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <issue-number>" >&2
  exit 1
fi

issue_number="$1"

if [[ ! "$issue_number" =~ ^[0-9]+$ ]]; then
  echo "issue number must be numeric: $issue_number" >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
output_dir="$repo_root/docs/tmp"
issue_output_path="$output_dir/issue.md"
spec_output_path="$output_dir/spec.md"
spec_title="# Issue #$issue_number 対応仕様"
created_paths=("./docs/tmp/issue.md")

mkdir -p "$output_dir"
tmp_json_path="$(mktemp "$output_dir/issue.json.tmp.XXXXXX")"
tmp_issue_path="$(mktemp "$output_dir/issue.md.tmp.XXXXXX")"
tmp_spec_path=""

cleanup() {
  rm -f "$tmp_json_path" "$tmp_issue_path"
  if [[ -n "$tmp_spec_path" ]]; then
    rm -f "$tmp_spec_path"
  fi
}

trap cleanup EXIT

cd "$repo_root"
gh issue view "$issue_number" --json number,title,body,comments >"$tmp_json_path"

spec_comment_count="$(
  jq -r \
    --arg spec_title "$spec_title" \
    '[.comments[]? | select((.body // "" | split("\n")[0] | sub("\r$"; "")) == $spec_title)] | length' \
    "$tmp_json_path"
)"

if [[ "$spec_comment_count" -gt 1 ]]; then
  echo "multiple spec comments matched '$spec_title'" >&2
  exit 1
fi

jq -r \
  --arg spec_title "$spec_title" \
  '
  def is_spec_comment:
    ((.body // "" | split("\n")[0] | sub("\r$"; "")) == $spec_title);

  [
    "# Issue #\(.number) \(.title)",
    "",
    (.body // "")
  ]
  +
  (
    [.comments[]? | select(is_spec_comment | not)] as $comments
    | if ($comments | length) == 0 then
        []
      else
        ["", "## コメント", ""]
        + (
            $comments
            | to_entries
            | map([
                "### コメント \(.key + 1)",
                "",
                (.value.body // "")
              ])
            | add
          )
      end
  )
  | join("\n")
  ' \
  "$tmp_json_path" >"$tmp_issue_path"

if [[ "$spec_comment_count" -eq 1 ]]; then
  tmp_spec_path="$(mktemp "$output_dir/spec.md.tmp.XXXXXX")"
  jq -r \
    --arg spec_title "$spec_title" \
    '.comments[]? | select((.body // "" | split("\n")[0] | sub("\r$"; "")) == $spec_title) | (.body // "")' \
    "$tmp_json_path" >"$tmp_spec_path"
fi

mv "$tmp_issue_path" "$issue_output_path"

if [[ "$spec_comment_count" -eq 1 ]]; then
  mv "$tmp_spec_path" "$spec_output_path"
  tmp_spec_path=""
  created_paths+=("./docs/tmp/spec.md")
else
  rm -f "$spec_output_path"
fi

trap - EXIT
cleanup

printf '作成したファイル:\n'
printf '%s\n' "${created_paths[@]}"
