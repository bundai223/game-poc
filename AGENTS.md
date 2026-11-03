## ドキュメント運用（LLM wiki 方式）

- 構造と基準の正本: `wiki/SCHEMA.md`
- セッション開始時に `/load-wiki-as-context`、作業の区切り・push 前に `/update-wiki` を実行する。スキルが利用できない場合は `wiki/SCHEMA.md` の手順を手動で行う。
- 新しい情報は必ず `raw/`（不変記録）を経由して `wiki/pages/` に蒸留する。
