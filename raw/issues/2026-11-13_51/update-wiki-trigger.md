# Issue #51 の Wiki 更新タイミング

- 日付: 2026-11-13
- 対象: https://github.com/bundai223/game-poc/issues/51
- 確認した事実: AGENTS.md はセッション開始時の Wiki 読み込みと、作業の一区切り・push 前の Wiki 更新を案内していたが、新しい発見があった時の更新契機は明示していなかった。
- 判断: 作業が一区切りした時、再利用できる発見があった時、push 前に `/update-wiki` を実行する。raw を先に追記し、その根拠を Wiki に蒸留する。
- 関連: `AGENTS.md`、`wiki/SCHEMA.md`、`wiki/pages/infrastructure/Issue単位の開発運用.md`
