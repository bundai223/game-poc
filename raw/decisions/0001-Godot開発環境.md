# Godot 開発環境の初期構築

日付: 2026-11-04
対象: [Issue #9](https://github.com/bundai223/game-poc/issues/9)

- Mac に既存の Godot 4.7.2 stable を使用し、Compatibility レンダラーの最小 2D シーンを作成した。
- `make import` と Godot のヘッドレス起動は通常環境で成功した。ウィンドウ起動も終了コード 0 で、Compatibility レンダラーの起動ログを確認した。表示内容の目視確認は未実施。
- サンドボックスでは Godot がユーザー設定・ログの保存先を作成できずエラーが発生した。通常環境ではこのエラーは出なかった。
- Godot 公式配布の 4.7.2 テンプレートから Web 用ファイルをこの Mac の Godot 設定領域に配置した。Web エクスポートは未設定・未検証。
- `make test` と `make export-web` は未実装を示して失敗する。テスト基盤は #16、Web ビルドは #17 で整備する。
- GdUnit4 の互換表は確認時点で Godot 4.7.1 まで記載しており、4.7.2 との実動互換性は未確認。
- 関連: `project.godot`, `experiments/draw_physics/main.tscn`, `Makefile`, `README.md`。
