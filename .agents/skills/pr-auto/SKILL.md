---
name: pr-auto
description: 指定された GitHub Issue への対応を行い PR 作成までを行う
argument-hint: "[issue-number]"
disable-model-invocation: true
---

## ワークフロー

### 1. Issue 内容取得

指定された Issue 番号の Issue の内容とコメント全てを取得します。
実行するコマンドは `gh issue view [issue-number] --comments` とし、`[issue-number]` にはこのスキルに渡された Issue 番号をそのまま指定してください。

### 2. 対応仕様の策定

以下の条件の両方に当てはまる場合にのみ実施します。

- Issue に対応仕様が記載されていない
- 対応するための仕様を決める必要がある

issue-spec-creator エージェントを呼び出して、Issue 内容とコメントの全てを情報として提示して、対応仕様書を作成させます。

### 3. 実施計画書の策定

implementation-planner.agent を呼び出して、以下の情報を提示して、

- Issue 内容とコメントの全て
- 対応仕様書（もし 2. で作成した場合）

どのような手順で実施するかの実施計画書を作成させます。

### 4. 実施計画の各フェーズを実施


## GitHub Copilot の場合

エージェントの呼び出しには #tool:agent/runSubagent を利用してください。
