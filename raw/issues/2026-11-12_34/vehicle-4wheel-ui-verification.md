# Issue #34 検証結果

- Godot 4.7.2 / GdUnit4で `make test` を実行した。
- 7 suites / 33 test cases が成功し、error・failure・flaky・skipは0件。
- 4輪標準車の部品・接続数、走行操作、画面ボタンの存在、旧標準保存データの移行、および改造済み旧車を置き換えないことを確認した。
- 実行時にmacOS証明書読み込みとユーザー領域へのGodot設定・ログ保存のエラー表示が出たが、テストコマンドは終了コード0で完了した。
- Pages再公開後のiPad実機確認はこれから。
