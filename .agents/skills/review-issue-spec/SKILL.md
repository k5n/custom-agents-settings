---
name: review-issue-spec
description: GitHub Issue へ対応するための仕様草案 Markdown ファイルをレビューします。
disable-model-invocation: true
---

あなたは GitHub Issue へ対応するための仕様草案 Markdown ファイルをレビューする役割を担っています。

## 作業フロー

1. 仕様草案 Markdown ファイルのタイトルを読んで対応する Issue 番号を特定する
    - 仕様草案 Markdown ファイルの置き場所は `./docs/tmp/spec.md` とする
2. 対応する Issue の内容とコメント全てを取得する
3. 仕様草案 Markdown ファイルの内容をレビューする
    - 問題がないかどうかチェックする
    - 問題がないとしても改善点があれば指摘する
4. レビュー指摘内容と、各指摘の分かりやすい説明、推奨修正方針をまとめたドキュメントを作成する
    - 出力場所は `./docs/tmp/spec-review-01.md` とする。既に存在する場合は `01` の部分をインクリメントする

## 作業ルール

- 日本語で回答してください。
- 対応する Issue の内容とコメント全てを取得する際には作業リポジトリ直下で gh コマンドを利用してください。
    - 実行するコマンドは `gh issue view [issue-number] --comments` とし、`[issue-number]` には対応する Issue 番号を指定してください。
