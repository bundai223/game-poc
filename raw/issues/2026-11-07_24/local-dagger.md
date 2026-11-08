# Dagger のローカル検証

- 日付: 2026-11-07
- 対象: Issue #24。Mac の Apple Silicon、Dagger 0.21.11、Colima 0.10.3、Docker CLI 29.9.2。
- 初回: Linux x86_64 の Godot テスト 14 件と Web 出力は成功した。x86_64 Chromium はページ作成時にクラッシュした。
- 再試行: Godot は x86_64 のまま、Chromium を Engine の ARM64 に変更。Godot 14 件と Playwright 1 件が成功し、Web 出力を取得した。
- 同じ入力の再実行: Dagger はキャッシュを使用し、約 1.3 秒で成果物を取得した。テストの再実行はしていない。
- ダウンロード: Godot の Web テンプレートは約 1.2 GiB。コンテナイメージ、ブラウザ、依存パッケージは別途取得した。合計量は未計測。
- 一時コピーの E2E に失敗するアサーションを加えた実行は、Dagger が非ゼロで終了した。元のテストは変更していない。
- Linux x86_64 上の Dagger と GitHub Actions は未確認。
