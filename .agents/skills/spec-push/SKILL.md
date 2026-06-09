---
name: spec-push
description: GitHub Issue へ対応するための仕様 Markdown ファイルを、対応する Issue のコメントとして残します。
disable-model-invocation: true
---

あなたは `./docs/tmp/spec.md` に保存された Issue 対応仕様を GitHub Issue のコメントとして残す役割を担っています。
このスキルでは自然言語で手順を再実装せず、この SKILL.md と同じディレクトリにある `scripts/push-spec-to-issue.sh` を `bash` で実行して処理してください。
現在の作業ディレクトリはユーザーが作業しているプロジェクトルートのままとし、リポジトリルートの取得や引数の組み立てを追加で考えたり実行したりしないでください。
仕様ファイルの存在確認、Issue 番号抽出、GitHub Issue へのコメント投稿、成功後のファイル削除は `scripts/push-spec-to-issue.sh` に委譲してください。

## `scripts/push-spec-to-issue.sh` の処理内容

`scripts/push-spec-to-issue.sh` は次の処理をこの順序で行います。

1. 現在の作業ディレクトリが属する Git リポジトリのルートパスを取得します。
2. リポジトリルート配下の `./docs/tmp/spec.md` ファイルの存在を確認します。
3. `spec.md` の 1 行目が `# Issue #[issue-number] 対応仕様` 形式であることを確認し、対応する Issue 番号を取得します。
4. `gh issue comment` を実行して `spec.md` の内容を対応する Issue のコメントとして投稿します。
5. コメント投稿に成功した場合のみ `spec.md`、`./docs/tmp/issue.md`、`./docs/tmp/spec-review-*.md` を削除します。
6. コメント投稿先の Issue URL を標準出力に 1 行出力します。

このため、あなたは `spec.md` の存在確認、Issue 番号抽出、`gh` コマンド呼び出し、削除処理を自分で考えて実装する必要はありません。これらはすべて `scripts/push-spec-to-issue.sh` が行います。

`scripts/push-spec-to-issue.sh` は次の場合に失敗します。

- 現在の作業ディレクトリから Git リポジトリルートを取得できない場合。
- `./docs/tmp/spec.md` ファイルが存在しない場合。
- `spec.md` の 1 行目から Issue 番号を取得できない場合。
- `gh repo view` または `gh issue comment` の実行に失敗した場合。

## 作業ルール

- `scripts/push-spec-to-issue.sh` が存在しない、実行できない、または失敗した場合は、エラーを返してください。
- `spec.md` を手で読んで手作業でコメント投稿したり、別の一時スクリプトを新規作成したりせず、必ず同梱の `scripts/push-spec-to-issue.sh` を使ってください。
