# Issue tracker: GitHub

GitHub Issues は作業の受付、計画、担当する Issue の状態管理に使う。Issue の内容と現在の状態は GitHub 上で確認する。

- 作成: `gh issue create --title "..." --body "..."`
- 参照: `gh issue view <number> --json number,title,body,labels,comments`
- 一覧: `gh issue list --state open`
- コメント・ラベル: `gh issue comment <number> --body "..."`、`gh issue edit <number> --add-label "..."`
- 完了: 完了条件を満たす PR に `Closes #<number>` を記載する。途中の PR では Issue を閉じない。

## ローカル記録

- Issue に関する確認事実、判断、検証結果は `raw/issues/YYYY-MM-DD_<番号>/` に追記し、Issue の説明全体を複製しない。
- 再利用する知識は `raw/` を根拠に `wiki/pages/` へ蒸留する。Wiki の構造と更新手順は `wiki/SCHEMA.md` を正本とする。
- `raw/` は不変記録、`wiki/` は更新可能な知識として扱う。Issue の現在状態は GitHub で確認する。
- TSV の記録先や役割は、このリポジトリで確認できていない。既存運用が分かるまで新しい TSV を作らない。

リポジトリは `git remote -v` から特定する。PR は triage の依頼受付先として扱わない。
