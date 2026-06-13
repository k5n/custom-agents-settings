---
name: pr-plan
description: 対応仕様を元に全体実施計画を作成し、自動的にレビューと修正を行います。
disable-model-invocation: true
---

## 作業フロー

1. impl-plan-creator エージェントを呼び出し、対応仕様を元に全体実施計画を作成します。
    - impl-plan-creator エージェントは、仕様書が `./docs/tmp/spec.md` に存在することを前提としています。仕様内容を渡す必要はありせん。
    - 作成完了（最長で15分）を待ちます。
2. impl-plan-reviewer エージェントを呼び出し、全体実施計画のレビューと修正を行います。
    - impl-plan-reviewer エージェントは、全体実施計画の草案が `./docs/tmp/impl-plan.md` に存在することを前提としています。全体実施計画の草案を渡す必要はありません。
    - 作成完了（最長で30分）を待ちます。
3. レビューによる指摘事項のレベルが「重大」「高」のものがなくなるまで 2 を繰り返します。

## GitHub Copilot の場合

エージェントの呼び出しには #tool:agent/runSubagent を利用してください。
