# iPadでタッチ描画できない報告と入力IDの修正

- 日付: 2026-11-08
- 対象: Issue #18、`experiments/draw_physics/main.gd`

## 確認した事実

- 利用者から、iPadで輪郭をドラッグしても描けないと報告があった。iPadOS/Safariの版、URL、公開ビルドのコミットは未記録。
- 修正前の入力コードは `InputEventScreenTouch` の `event.index == 0` だけを処理していた。
- ローカルWeb出力を使ったChromiumのタッチ模擬で、DOMのtouchイベントはcanvasまで届き、マウス描画も成功した。
- 同じタッチ軌跡で接触ID `0` は描画され、ID `1` と `7` は描画されなかった。
- Viewport入力の回帰テストは、修正前に8件中1件が失敗し、ID `1` の輪郭から剛体が生成されなかった。

## 変更と検証

- タッチ開始時の接触IDを `0` に限定せず、最初に押されたタッチのIDを追跡するようにした。
- 回帰テストを追加し、ID `1` でも剛体が生成されることを確認した。修正後のGdUnit4は15件成功。
- 修正版をGodot 4.7.2でWeb出力し、PlaywrightのChromiumタッチ模擬でID `1` の描画を確認した。既存のマウスE2Eと追加したタッチE2Eは2件とも成功。
- `make test` は `ggg 0.6.0` がPATH上にないため依存同期の段階で開始できず、インストール済みGdUnit4 runnerを直接実行した。

## 未解決

- 修正後のiPad Safari実機では未確認。Chromiumのタッチ模擬はiPad実機の代替ではない。
- iPadOS/Safariの版、端末、実際に開いた公開ビルドは未記録。
