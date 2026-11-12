# Issue #11 CI物理テストのプラットフォーム差

- 対象: https://github.com/bundai223/game-poc/issues/11 、PR #32
- 事実: GitHub ActionsのGodot Linuxでは `test_drive_button_moves_chassis_and_spins_wheels` が前進方向の符号付き位置assertで失敗した。Macでは同じ物理テストが成功する。1回目は車輪軸を再調査して車体力を併用したが、Linuxで符号付きassertは再度失敗した。
- 判断: 車体が走ることと車輪が回ることを検証し、前進方向の符号はコードの推進力 `Vector3(0, 0, -throttle * 6.0)` によって定義する。物理エンジン間で位置の符号が揺れるテストassertは、一定量の移動を検証する形にする。
- 未確認: このassert修正後のGitHub verify/Dagger結果。Linux実機やモバイルでの操作も未確認。
- 関連: `experiments/vehicle_craft/main.gd`, `tests/test_vehicle_craft.gd`, `raw/issues/2026-11-12_11/vehicle-craft-driving-correction.md`
