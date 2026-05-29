---
name: create-spec-from-issue
description: 指定された GitHub Issue をもとに、仕様策定の草案 Markdown ファイルを作成します。
argument-hint: "[issue-number]"
disable-model-invocation: true
---

指定された番号の GitHub Issue をもとに、仕様策定の草案 Markdown ファイルを作成してください。

## ワークフロー

1. 指定された Issue 番号の Issue の内容とコメント全てを取得する。
2. 取得した内容をもとに、仕様策定の草案 Markdown ファイルを作成する。
3. reviewer エージェントを利用して、作成した草案 Markdown ファイルに対してレビューを行わせる
    - 草案 Markdown ファイルだけでなく、Issue の内容とコメント全てを reviewer エージェントに情報として提示する
    - 終了するまで待機する
4. 指摘事項や改善項目の１つずつに対して fix-planner エージェントを並列で呼び出し、それぞれの修正方針を検討させる
    - 終了するまで待機する
5. 修正方針に従って草案 Markdown ファイルを修正する。

## 作業ルール

- 日本語で記述してください。
- Issue の内容とコメント全てを取得する際には作業リポジトリ直下で gh コマンドを利用してください。
    - 実行するコマンドは `gh issue view [issue-number] --comments` とし、`[issue-number]` にはこのスキルに渡された Issue 番号をそのまま指定してください。
- 仕様策定の草案 Markdown ファイルの置き場所は `./docs/tmp/spec.md` とします。
- 仕様策定の草案 Markdown ファイルの１行目はタイトルとし、`# Issue #[issue-number] 対応仕様` （`[issue-number]` は対応する Issue 番号）としてください。
- ユーザーが判断すべきポイントがあれば、草案の最後に「ユーザー判断が必要なポイント」として箇条書きで提示してください。
- 「ユーザー判断が必要なポイント」には、推奨案も併記してください。

## GitHub Copilot の場合

reviewer, fix-planner エージェントの呼び出しには #tool:agent/runSubagent を利用してください。
