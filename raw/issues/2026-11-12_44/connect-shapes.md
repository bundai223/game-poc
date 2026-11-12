# Issue #44: 2D図形の連結

- 2026-11-12、Connect モードで2図形を選び、PinJoint2D で連結する実装を追加した。接続は回転可能。
- 空白・同一図形・モード切替・タッチ中断・フォーカス喪失で選択を解除する。同じ組の重複接続は作らない。重なりの選択順は未指定。
- 図形の削除や切断で、その図形についた接続を削除し、破片へ引き継がない。Reset は全接続を消す。
- Godot のヘッドレステスト53件でマウス・タッチ、3図形、物理挙動、削除、切断、Reset、選択の解除を確認した。実機は未確認。
- 関連: experiments/draw_physics/main.gd、tests/test_collider_integration.gd、README.md。
