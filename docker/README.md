# Docker Sample

このディレクトリには、AI エージェントに Full Access 相当の権限を与えて作業させる際の、隔離された作業用コンテナのサンプル設定を配置しています。

この設定は完成品ではなく、fork やカスタマイズを前提としたサンプル実装です。用途に応じてパッケージ追加、ポート公開、ボリューム追加、セキュリティ設定の調整を行ってください。

## 方針

- コンテナは `tty: true` で起動しっぱなしにし、VS Code Dev Containers 拡張で接続するか、`docker compose exec` でシェルに入って利用します。
- 永続化するのは `/home/ubuntu` のみです。
- `/home/ubuntu` 配下のディレクトリ構成は利用者の裁量に委ねます。
- 各リポジトリはコンテナ内で `git clone` して利用します。
- このリポジトリの設定も利用者がコンテナ内で clone し、`./install.sh` を実行して導入します。

## 含まれるファイル

- `Dockerfile`: `ubuntu:26.04` をベースに、`ubuntu` ユーザーだけを作成した最小構成のイメージ
- `compose.yml`: `/home/ubuntu` を named volume として永続化する Compose 設定

## 使い方

このディレクトリで以下を実行してコンテナを起動します。

```bash
docker compose up -d --build
```

初回起動時は、`entrypoint.sh` 内のセットアップ処理が走るため、完了するまで数分かかります。ログに `=== entrypoint.sh: setup finished ===` と出力されたらセットアップ完了です。

```bash
docker compose logs -f
```

でログを確認できます。

コンテナ内のシェルに入る場合:

```bash
docker compose exec workspace zsh
```

VS Code Dev Containers 拡張を使う場合は、起動済みコンテナ `workspace` にアタッチして利用してください。

使い方の基本は、コンテナ内で自身が利用するツール類の設定を行い、必要なリポジトリを clone して利用する形になります。

[mise](https://mise.jdx.dev/) をインストールしているので、コンテナ内でユーザ権限で開発ツールをインストールすることもできます。
`mise` 経由で導入済みのツール類は `mise ls` で確認できます。

## 初期セットアップ例

以下は、`custom-agents-settings` 導入例です。

```bash
cd /home/ubuntu
git clone <this-repository-url>
cd custom-agents-settings
./install.sh
```

`./install.sh` を引数なしで実行すると、`/home/ubuntu` 配下の以下へ設定がインストールされます。

- `~/.agents/skills`
- `~/.codex/agents`
- `~/.copilot/agents`

GitHub 認証は、必要に応じてコンテナ内で利用者自身が行ってください。

## カスタマイズ例

- Dockerfile を変更し、ユーザー権限ではインストールできない Ubuntu 提供パッケージを追加する
- Web 開発用にポートを公開する
- `node`、`bun` などを追加インストールする
- named volume を分割してキャッシュ領域を別管理にする
- `compose.override.yml` を追加して個人用設定を重ねる
