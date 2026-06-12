---
name: fetch-issue
description: 指定された GitHub Issue を取得して、Markdown ファイルに保存します。Issue 内容の取得を依頼された際に利用します。
argument-hint: "[issue-number]"
---

この `SKILL.md` と同じディレクトリにある `./scripts/fetch-issue.sh` を `bash ./scripts/fetch-issue.sh [issue-number]` として実行してください。

`fetch-issue.sh` は、指定された Issue 番号の Issue 内容を `./docs/tmp/issue.md` に保存します。
また、Issue コメントのうち 1 行目が `# Issue #[issue-number] 対応仕様` に一致するコメントが存在する場合は、そのコメント本文のみを `./docs/tmp/spec.md` に保存します。
仕様コメントは `issue.md` には含めません。
成功時は標準出力に `作成したファイル:` を 1 行目として出力し、2 行目以降に実際に作成したファイルのパスを 1 行ずつ列挙します。
