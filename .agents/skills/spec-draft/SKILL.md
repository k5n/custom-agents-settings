---
name: spec-draft
description: 指定された GitHub Issue をもとに、仕様策定の草案 Markdown ファイルを作成します。
argument-hint: "[issue-number]"
disable-model-invocation: true
---

指定された番号の GitHub Issue をもとに、仕様策定の草案 Markdown ファイルを作成してください。

## ワークフロー

1. `bash ./scripts/fetch-issue.sh [issue-number]` を実行して、指定された Issue 番号の Issue の内容とコメント全てを `./docs/tmp/issue.md` に保存する。
2. `./docs/tmp/issue.md` の内容をもとに、仕様策定の草案 Markdown ファイルを作成する。
3. spec-draft-reviewer エージェントを利用して、作成した草案 Markdown ファイルに対してレビューを行わせる
    - 終了するまで待機する
4. 指摘事項と出力された修正方針を参考に、妥当であると判断した場合に草案 Markdown ファイルを修正する。

## 作業ルール

- 日本語で記述してください。
- Issue の内容とコメント全てを取得する際には、この `SKILL.md` と同じディレクトリにある `./scripts/fetch-issue.sh` を `bash ./scripts/fetch-issue.sh [issue-number]` として実行してください。
- 仕様策定の草案 Markdown ファイルの置き場所は `./docs/tmp/spec.md` とします。
- 仕様策定の草案 Markdown ファイルの１行目はタイトルとし、`# Issue #[issue-number] 対応仕様` （`[issue-number]` は対応する Issue 番号）としてください。
- ユーザーが判断すべきポイントがあれば、草案の最後に「ユーザー判断が必要なポイント」として箇条書きで提示してください。
- 「ユーザー判断が必要なポイント」には、推奨案も併記してください。
- レビュー指摘事項と修正方針は鵜呑みにせず、妥当であるかどうかを考えて、どのように修正するか判断してください。

## GitHub Copilot の場合

エージェントの呼び出しには #tool:agent/runSubagent を利用してください。
