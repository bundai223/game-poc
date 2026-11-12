# Issue #11 3D Vehicle Craft の画面遷移時保存

- 対象: https://github.com/bundai223/game-poc/issues/11
- 変更理由: 3D Craftで編集した車が、保存ボタンを押さずに2D画面へ移ると失われる実装上の問題を避ける。
- 実装: `2Dへ` の遷移前に `user://vehicle-craft.json` へ保存する。保存に失敗した場合は画面遷移しない。次に3D Craftを開いた際、保存ファイルがあれば読み込む。
- 保存処理: ファイルを開けない場合と書込エラーを状態表示し、画面遷移を止める。壊れたデータの読込は現在の車を維持する。
- 確認: `make test` 31件すべて成功。画面遷移時の保存・再入場時の復元は自動テストとブラウザE2Eでは直接確認していない。
- 関連: `experiments/vehicle_craft/main.gd`, `README.md`, `wiki/pages/experiments/3D物理クラフト.md`
