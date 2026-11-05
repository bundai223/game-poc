# Issue #17: CI 実行結果

- 日付: 2026-11-05
- 対象: PR #20、commit `4c73e20`
- GitHub Actions の Ubuntu で import、3 件のテスト、Web export、Artifact 保存が成功した。
- `godot-web-build` を取得し、HTML、PCK、Wasm が存在することを確認した。
- 修正前は GdUnit4 を Web 出力に含めた export が終了コード 134 で中断した。内部原因は未特定。
- 実行記録: https://github.com/bundai223/game-poc/actions/runs/41941202530
