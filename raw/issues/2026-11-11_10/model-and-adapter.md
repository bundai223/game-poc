# Issue #10 輪郭データモデルとGodot変換境界

- 日付: 2026-11-11
- 対象: https://github.com/bundai223/game-poc/issues/10
- 実装: `experiments/draw_physics/outline_data.gd` が2D輪郭点列を保持し、version付きJSONへ変換・復元する。`experiments/draw_physics/rigid_body_adapter.gd` がデータから `RigidBody2D`、`Polygon2D`、`CollisionPolygon2D` を作成し、`main.gd` は入力とSceneへの登録を担う。
- 判断: 現在利用される2D輪郭だけをモデル化した。3D部品IDとTransformは利用先ができるまで作らない。モデルはNode/SceneTreeに依存しないが、`Vector2` と `PackedVector2Array` を使うためGodotランタイムおよび別エンジンでの動作は未検証。画面上のファイル保存・読込機能も追加していない。
- 検証: JSON往復と不正JSONの拒否をSceneTreeなしで確認。`make test` は17件成功。`make import` と `make export-web` は成功。`npm run test:e2e` は2件成功。初回のE2Eはsandboxのlocalhost待受制限で起動せず、許可付きで再実行した。
- 環境上の出力: Godotはsandbox制約によりユーザー設定とログを保存できない警告、および証明書取得警告を出した。テスト、import、exportの終了コードは成功だった。
- 関連ファイル: `README.md`, `experiments/draw_physics/outline.gd`, `experiments/draw_physics/outline_data.gd`, `experiments/draw_physics/rigid_body_adapter.gd`, `experiments/draw_physics/main.gd`, `tests/test_outline_data.gd`, `tests/test_collider_integration.gd`, `tests/test_fixed_timestep_physics.gd`
