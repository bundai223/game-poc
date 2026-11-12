# Issue #44: PR #47 の CI 結果

- 2026-11-12、PR #47 は `55c7a69bb7a877d426d8b9d7420c804b6a334961` として main にマージされた。
- PR の Godot CI は `verify` が成功し、`dagger` が失敗した。Dagger の Godot テストは51件中1件失敗した。
- 失敗した `test_connect_mouse_touch_and_cleanup` は、連結した2図形の中心間距離の変化が15未満であることを期待したが、33.800507 だった。
- ローカルの Godot テスト53件と Chromium E2E 4件は成功した。Dagger の失敗原因は未特定であり、テストが不安定なのか連結の挙動に問題があるのかは未確認。
- PR の結果: https://github.com/bundai223/game-poc/pull/47
- Dagger の失敗ログ: https://github.com/bundai223/game-poc/actions/runs/43229357706/job/131220517557
- Web preview は確認時点で実行中。実機での連結操作と表示は未確認。
- その後、マージコミット `55c7a69` の Web preview ワークフローは成功した。ワークフロー結果のみの確認であり、公開先や実機での操作は確認していない: https://github.com/bundai223/game-poc/actions/runs/43229803031
