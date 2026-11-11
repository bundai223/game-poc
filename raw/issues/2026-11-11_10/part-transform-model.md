# Issue #10 3D部品IDとTransformモデル

- 日付: 2026-11-11
- 対象: https://github.com/bundai223/game-poc/issues/10
- 実装: `experiments/draw_physics/part_data.gd` が3D部品IDと `Transform3D` を保持し、バージョン付きJSONへ変換・復元する。不正なJSON、空ID、形式・数値が不正なTransformを拒否する。
- 判断: Issue #10の作業項目にある最小の部品データのみ定義した。現時点で部品の形状・接続・Scene変換の利用先はないため、3D Node adapterや編集機能は追加していない。Godotの `Transform3D` 型を使い、Godotランタイム外・別エンジンでの実行は未検証。
- 検証: 3D部品IDとTransformのJSON往復、不正データ拒否をSceneTreeなしでテスト。`make test` は19件成功。`make import` と `make export-web` 成功。最新Web出力に対する `npm run test:e2e` は2件成功。
- 環境上の出力: Godotはsandbox制約によりユーザー設定とログを保存できない警告、および証明書取得警告を出した。各検証コマンドは成功終了した。
- 関連ファイル: `experiments/draw_physics/part_data.gd`, `tests/test_outline_data.gd`, `README.md`
