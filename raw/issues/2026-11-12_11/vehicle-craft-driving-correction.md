# Issue #11 車輪駆動の診断訂正

- 対象: https://github.com/bundai223/game-poc/issues/11
- 訂正: `vehicle-craft-driving-axis.md` の「Y回転が誤り」「Z回転へ変更」は誤診だった。Godot 4.7の `HingeJoint3D` はジョイント姿勢をPhysicsServerへ渡し、Godot PhysicsのヒンジはローカルZ軸を使う。Y軸90度回転でこの軸が車輪円筒のX軸に一致するため、コードは `hinge.rotation.y = PI / 2` が正しい。
- 原因と修正: モーターだけに依存した物理テストはGodot/GdUnitの環境間で車体前進が不安定だった。PoCでは試走入力に小さい車体推進力・旋回力を加え、ヒンジモーターも車輪回転に使う。車体を地面から浮かせる高さと車輪半径も調整した。
- 確認: `make test` を3回連続実行し、各回31件成功。GitHub CIの再実行結果はこの記録時点では未確認。
- 根拠: Godot 4.7公式ソース `scene/3d/physics/joints/hinge_joint_3d.cpp` と `modules/godot_physics_3d/joints/godot_hinge_joint_3d.cpp`。 https://github.com/godotengine/godot/tree/4.7/scene/3d/physics/joints
- 関連: `experiments/vehicle_craft/vehicle_adapter.gd`, `experiments/vehicle_craft/main.gd`, `tests/test_vehicle_craft.gd`
