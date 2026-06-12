# custom-agents-settings

## これは何？

実装を AI エージェントに任せるための SKILL とカスタムエージェントの設定。
自分が使っている GitHub Copilot と Codex に対応しています。他の AI エージェントを利用している場合は、その AI エージェントの仕様に合わせて同様のものを作成してください。

## 想定している利用状況

使い捨てで構わないツールの作成、プロトタイプの作成など、「認知負債」「理解負債」が問題にならない状況での利用を想定しています。

利用ワークフローについては [Workflow.md](./Workflow.md) を参照してください。

## 設定

### GitHub Copilot

GitHub Copilot では、サブエージェントからさらにサブエージェントを呼び出すために、リポジトリの `.vscode/settings.json` に以下の設定を記述します。

```json
{
  "chat.subagents.allowInvocationsFromSubagents": true
}
```

### Codex

`~/.codex/config.toml` に以下のような設定を記述します。
ここで `max_depth` は 2 以上を指定してください。それ以外は任意の値です。
ただし `job_max_runtime_seconds` のデフォルト値は 1800 秒（30 分）なので、全体の処理時間が長くなるとタイムアウトします。十分大きな値を指定することを推奨します。

```toml
[agents]
max_threads = 8
max_depth = 2
job_max_runtime_seconds = 10800
```

## 利用方法

別のリポジトリにこのリポジトリの SKILL / エージェント設定のシンボリックリンクを作成して利用します。
このリポジトリルートで以下を実行します。

```bash
./install.sh <target-repository-path>
```

このスクリプトは `<target-repository-path>` の以下の配下に、このリポジトリ内の対応するエントリへのシンボリックリンクを作成します。

- `.agents/skills`
- `.codex/agents`
- `.github/agents`

既に同名のファイル、ディレクトリ、または別のリンクが存在する場合は、何も変更せずエラーで終了します。
