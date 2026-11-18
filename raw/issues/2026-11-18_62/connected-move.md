# Issue #62 連結群の Move

- 日付: 2026-11-18
- 対象: https://github.com/bundai223/game-poc/issues/62
- 基点: main 3bffccd。PR #52 のマージを確認して専用 worktree に隔離した。通常 checkout の未コミットコード・文書は変更していない。
- 原因: `_begin_move` は接続のある図形を検出すると return していた。単体 Move の制約だった。
- 修正: 選択した剛体から PinJoint2D の接続先をたどり、循環を重複処理せず連結成分全体を停止する。ポインターの差分を各剛体に適用し、接続・相対位置を保つ。未接続の図形は動かさない。
- 終了・中断: 各剛体の元の freeze を復元する。速度は単体 Move と同じくゼロにする。タッチID、モード切替、フォーカス喪失、Reset は既存の入力解除処理を使う。
- 検証: 修正前の `make test` でマウスの群移動回帰テストが失敗し、位置が変わらないことを確認。修正後は全58件成功、0 failures / 0 errors。追加2件は、実際の Connect 入力で作った間接接続・循環、マウスのリリース位置、タッチの別指無視と中断、未接続図形、固定状態復元、接続の維持を確認する。
- 未確認: Android / iPad 実機。移動中に障害物をすり抜ける既存仕様は継続する。
- 関連: `experiments/draw_physics/main.gd`、`tests/test_collider_integration.gd`、`README.md`。

## 追加の検証

- Web 書き出し成功。既存 Chromium E2E は4件成功。群移動のWeb E2Eは追加せず、入力統合テストで検証した。
- Standards / Spec の独立レビューは各0件、文書の独立レビューは pass。
- Wiki の必須frontmatter、全sourcesの実在、indexリンクを確認。ページ数変更なし。
