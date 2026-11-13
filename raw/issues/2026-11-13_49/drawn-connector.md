# Issue #49: 描いた図形で剛体を接続

- 2026-11-13、Connect モードで閉じた輪郭を描き、その輪郭と各剛体との重なり領域の面積が合計0.5平方ピクセルを超える剛体が2個以上なら、輪郭を剛体として作り各対象へ PinJoint2D で接続する実装を追加した。角度制限を相対角に設定して固定接続にする。
- 対象が2個未満なら何も作らない。描画中の物理停止・運動復帰は既存の Draw 停止処理を使う。接続先の削除・切断では該当するJointを削除し、Resetではすべて消す。
- シーン統合テストはマウスの複数剛体接続と物理挙動、タッチの不足対象を確認。Godotテスト56件が成功した。
- Chromium E2E既存4件は成功したが、ConnectのWeb操作自体はE2Eで直接確認していない。Android・iPad実機も未確認。
- GodotにFixedJoint2Dはないため、PinJoint2Dの角度制限を使う。Godot公式クラス文書: https://docs.godotengine.org/en/stable/classes/class_pinjoint2d.html
