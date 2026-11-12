# Issue #11 3D Vehicle Craft の駆動軸

- 対象: https://github.com/bundai223/game-poc/issues/11
- 発見: CIの物理テストで車体が前進しなかった。車輪の円筒軸はX方向だが、ヒンジの回転軸がY方向を向いていた。また、W入力の符号がGodotの前進方向(-Z)と逆だった。
- 修正: ヒンジをZ方向に90度回し、X軸の車輪軸に一致させた。W/Sのモーター速度符号を反転し、Wで-Z方向へ進むようにした。
- 確認: `make test` 31件成功。前進・車輪回転・A/D旋回を物理フレームテストで確認した。CIで同じ回帰を検出し、PR更新後に再実行する。
- 関連: `experiments/vehicle_craft/vehicle_adapter.gd`, `experiments/vehicle_craft/main.gd`, `tests/test_vehicle_craft.gd`
