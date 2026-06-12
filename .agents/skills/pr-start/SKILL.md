---
name: pr-start
description: 指定された GitHub Issue をもとに、Issue の内容とコメント全てを Markdown ファイルに保存し、ブランチを作成します。Issue 対応のための PR 作成作業を開始する際に利用します。
argument-hint: "[issue-number]"
---

## ワークフロー

1. spec-draft SKILL を利用して、指定された Issue 番号の Issue の内容とコメント全てを取得し、仕様策定がまだなら草案 Markdown ファイルを作成する。
2. `git checkout -b {issue-number}-{branch-name}` コマンドを実行して、ブランチを作成してブランチを切り替える。`{issue-number}` は指定された Issue 番号、`{branch-name}` は Issue の内容を簡潔に表す英語のブランチ名としてください。
