# Issue #36: 2D切断モード

2026-11-12、手描き物体の切断モードを実装した。切断開始時に既存剛体を凍結し、入力を離すと折れ線で分割して物理を再開する。低速または静止で折れ点を追加する。凹形状と複数物体にも対応する。自己交差する切断線、既存の輪郭検証を通らない小片、面積が維持できない分割は元の物体を残す。

`make test` は42件成功した。Webの書き出しは成功した。ブラウザE2Eはローカル接続が環境の制限で拒否され、AndroidやiPad実機の切断操作も未確認。

関連: `experiments/draw_physics/main.gd`, `experiments/draw_physics/slice.gd`, `tests/test_slice.gd`, `tests/test_collider_integration.gd`, `tests/test_fixed_timestep_physics.gd`。
