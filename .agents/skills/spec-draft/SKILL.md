---
name: spec-draft
description: 指定された GitHub Issue をもとに、仕様策定の草案 Markdown ファイルを作成します。
argument-hint: "[issue-number]"
disable-model-invocation: true
---

指定された番号の GitHub Issue をもとに、仕様策定の草案 Markdown ファイルを作成してください。

## ワークフロー

1. fetch-issue SKILL を利用して、指定された Issue 番号の Issue の内容とコメント全てを取得する。
2. `./docs/tmp/spec.md` が作成された場合は、既に仕様策定の草案 Markdown ファイルが存在しているとみなし、上書きしてはいけません。エラーを返してください。
3. `./docs/tmp/spec.md` が存在しない場合は、create-draft-spec SKILL を利用して、仕様策定の草案 Markdown ファイルを作成する。
