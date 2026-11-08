# GitHub Actions での失敗確認

- 日付: 2026-11-07
- PR #25、コミット `9cf7c11`、Actions run `42332388276`。
- 故意に E2E のアサーションを失敗させ、dagger ジョブと既存 verify ジョブが失敗した。
- dagger ジョブのログに `Expected: true`、`Received: false`、失敗させたアサーションを確認した。確認後、アサーションを元に戻す。
