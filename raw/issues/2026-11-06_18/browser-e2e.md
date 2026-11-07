# ブラウザ E2E

- 日付: 2026-11-07
- 対象: Issue #18 の Web 版の自動確認。
- 内容: Playwright と Chromium でロード、マウス描画、R キーによる消去を確認する。PR の CI でも実行する。
- 検証: Mac の Chromium で Web エクスポート後、E2E 1 件が成功した。
- 制約: Android・iPad の実機操作、Linux CI は未確認。スクリーンショットの変化で描画を確認し、物理挙動の正確さは確認しない。
