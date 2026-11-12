## ドキュメント運用（LLM wiki 方式）

- 構造と基準の正本: `wiki/SCHEMA.md`
- セッション開始時に `/load-wiki-as-context`、作業の区切り・push 前に `/update-wiki` を実行する。スキルが利用できない場合は `wiki/SCHEMA.md` の手順を手動で行う。
- 新しい情報は必ず `raw/`（不変記録）を経由して `wiki/pages/` に蒸留する。

## 開発の進め方

- 原則として、作業 Issue ごとにセッション、`codex/` で始まるブランチ、PR を分ける。レビューしやすいよう 1 Issue を複数 PR に分けてもよい。
- Issue の完了条件を満たす PR には `Closes #番号` を記載する。途中の PR では Issue を自動クローズしない。
- 並行作業や作業場所の分離が必要な場合に worktree を使う。片付ける前に所有者、追跡済み・未追跡・無視対象の変更、ブランチの状態を確認する。

## 開発フェーズとスキル

- 計画、実装、レビュー・報告を区別し、利用者が指定した対象とフェーズに従う。マージ完了の報告だけでは、同じ Issue の残作業を含む新たな実装に着手せず、利用者の指示を待つ。
- 計画では要求と完了条件を整理し、Issue や仕様の作成に `to-spec`、複数の作業 Issue への分割に `to-tickets` を使う。作成した Issue の内容と完了条件を利用者に提示して確認し、実装は利用者が対象 Issue を指定した後に始める。
- 実装では対象 Issue と完了条件を確認し、`implement` を使う。このスキルは自動レビュー後にコミットする。対象が不明な場合は利用者に確認する。Issue ごとのブランチと PR は上記の運用に従う。
- 実装後は変更、検証結果、未確認事項を報告し、利用者が差分を確認できる状態にする。レビュー依頼には `code-review` を使い、差分について話し合う。次の Issue や追加の実装は利用者の指示に従う。
- 必須スキルが利用できない場合やトラッカー設定が不足する場合は、状況と代替案を伝え、利用者の指示を待つ。利用者が明示的に別の進め方を指定した場合は、その指示を優先する。

## Agent skills

### Issue tracker

GitHub Issues が作業の受付・状態管理の正本で、継続的な知識は `raw/issues/` と `wiki/pages/` に記録する。詳細は `docs/agents/issue-tracker.md`。

### Triage labels

GitHub Issues では標準 triage ラベルを使う。対応表は `docs/agents/triage-labels.md`。

### Domain docs

単一コンテキスト構成。用語集と ADR の読み方は `docs/agents/domain.md`。
