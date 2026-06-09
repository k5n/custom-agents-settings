---
name: issue-push
description: 草案 Markdown ファイルをもとに、GitHub Issue を作成します。
disable-model-invocation: true
---

あなたは GitHub Issue を作成する役割を担っています。
ユーザーが現在作業しているプロジェクトルート配下の `./docs/tmp/issues/` に Issue 作成用の草案 Markdown ファイルがあります。
このスキルでは自然言語で手順を再実装せず、この SKILL.md と同じディレクトリにある `scripts/create-issues-from-drafts.sh` を `bash` で実行して処理してください。
現在の作業ディレクトリはユーザーが作業しているプロジェクトルートのままとし、リポジトリルートの取得や引数の組み立てを追加で考えたり実行したりしないでください。
Issue 作成、複数ファイル処理、作成済み草案ファイルの削除は `scripts/create-issues-from-drafts.sh` に委譲してください。

## `scripts/create-issues-from-drafts.sh` の処理内容

`scripts/create-issues-from-drafts.sh` は次の処理をこの順序で行います。

1. 現在の作業ディレクトリが属する Git リポジトリのルートパスを取得します。
2. リポジトリルート配下の `./docs/tmp/issues/` ディレクトリの存在を確認します。
3. `./docs/tmp/issues/` 直下の `.md` ファイルを列挙し、ファイル名順に 1 件ずつ処理します。
4. 各草案ファイルの front matter から `title:` を取得します。
5. front matter 終了後の本文を Issue 本文として一時ファイルに書き出します。
6. `gh issue create` を実行して GitHub Issue を作成します。
7. Issue 作成に成功した草案ファイルを削除します。
8. 作成した Issue の URL を標準出力に 1 行ずつ出力します。

このため、あなたは草案ファイルの探索、タイトル抽出、本文生成、複数ファイルの反復処理、削除処理を自分で考えて実装する必要はありません。これらはすべて `scripts/create-issues-from-drafts.sh` が行います。

`scripts/create-issues-from-drafts.sh` は次の場合に失敗します。

- 現在の作業ディレクトリから Git リポジトリルートを取得できない場合。
- `./docs/tmp/issues/` ディレクトリが存在しない場合。
- `./docs/tmp/issues/` 直下に対象の草案 Markdown ファイルが 1 件も存在しない場合。
- 草案ファイルに `title:` front matter が存在しない場合。
- `gh repo view` または `gh issue create` の実行に失敗した場合。

## 作業ルール

- `scripts/create-issues-from-drafts.sh` が存在しない、実行できない、または失敗した場合は、エラーを返してください。
- 草案 Markdown を 1 件ずつ手で処理したり、別の一時スクリプトを新規作成したりせず、必ず同梱の `scripts/create-issues-from-drafts.sh` を使ってください。
