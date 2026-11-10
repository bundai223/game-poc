# Issue #8 お絵描き物理 PoC

- 日付: 2026-11-05
- 対象: `https://github.com/bundai223/game-poc/issues/8`
- 確認した事実: Issue #8 は Godot 4 系の2Dシーンで、手描き輪郭を剛体にし、CLI テストと README の利用手順を求めている。凹形状は初期制約として許容され、後続 #18 で Web と実機入力を確認する。
- 判断: 輪郭データは `PackedVector2Array` の純粋な処理として Node から分離する。面積500平方ピクセル以上、3〜32頂点の凸輪郭を受け付け、非有限座標、自己交差、凹形状を拒否する。表示形状と CollisionPolygon2D は同じ局所座標を使う。
- 実装: マウスドラッグと1本指タッチでプレビューし、リリース時に検証して RigidBody2D を生成する。R キーで生成物を消す。タッチ由来のマウスイベントを無効にして二重入力を防ぐ。
- 検証: `GGG_CACHE_DIR=/tmp/ggg-evaluate/cache make test GODOT=godot GGG=/tmp/ggg-evaluate/ggg-aarch64-apple-darwin/ggg` は9件成功した。Godot は sandbox の制約でユーザー設定とログを書けないエラーを出したが、テスト終了コードは0だった。
- 未確認: Mac の実ウィンドウでの視認性と操作感、Web 上のマウス・タッチ、Android/iPad 実機。
- 関連ファイル: `README.md`, `project.godot`, `experiments/draw_physics/main.gd`, `experiments/draw_physics/main.tscn`, `experiments/draw_physics/outline.gd`, `tests/test_outline.gd`, `tests/test_collider_integration.gd`, `tests/test_fixed_timestep_physics.gd`。
