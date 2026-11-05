---
date: 2026-11-05
type: decision
---

# GdUnit4 依存の自動セットアップ

- GdUnit4 6.2.3 の addon ファイルを Git 管理対象から外し、GitHub の `v6.2.3` archive からセットアップ時に取得する。
- archive URL: https://github.com/godot-gdunit-labs/gdUnit4/archive/refs/tags/v6.2.3.tar.gz
- SHA256: `42dc61721b1b6bc40dac0ff34a71d2b0811ca92109add0b923ad01f96f04abf8`
- `make setup` が checksum、addon バージョン、runner の存在を検査してから配置する。Godot を起動する Make ターゲットは setup を先に実行する。
- 同バージョンの addon があれば再利用し、異なる版・不完全なディレクトリは上書きせず失敗する。
- archive の SHA256 は取得物と照合して一致を確認した。
