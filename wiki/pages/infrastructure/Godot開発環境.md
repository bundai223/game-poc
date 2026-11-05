---
title: Godot 開発環境
genre: infrastructure
summary: Mac で Godot の最小シーンを起動するための構成と検証状況。
updated: 2026-11-05
confidence: high
status: active
sources:
  - raw/decisions/0001-Godot開発環境.md
  - raw/decisions/0002-Webエクスポート.md
  - raw/decisions/0004-ヘッドレステスト.md
  - raw/decisions/0005-Web出力のテスト除外.md
  - raw/decisions/0006-GdUnit4依存の自動セットアップ.md
---

# Godot 開発環境

Godot 4.7.2 stable と Compatibility レンダラーを採用し、Mac ネイティブで最小 2D シーンを起動する。コマンドとセットアップ手順はリポジトリの README を参照する。

通常環境ではヘッドレスインポートと起動、およびウィンドウ起動の正常終了を確認した。ウィンドウの表示内容は未確認。サンドボックスでは Godot のユーザー設定・ログ領域への書き込みが拒否された。

Web 用テンプレートは構築した Mac に配置済み。シングルスレッドの Web 版をエクスポートし、ローカルブラウザで最小シーンの表示を確認した。Tailscale 限定共有の URL から HTML と WebAssembly を取得できたが、リモート端末での表示・操作は未確認。

Godot 4.7.2 と GdUnit4 6.2.3 の組み合わせで、`make test` による 3 件のヘッドレステストと故意の失敗の検出を Mac で確認した。Linux CI は未確認。

Web export には GdUnit4 とテストを含めない。addon を含めると export が異常終了したため、Mac で除外後の出力を確認した。修正後の Linux CI は未確認。

GdUnit4 6.2.3 の addon は Git 管理せず、`make setup` が固定 URL と SHA256 を使って取得する。Godot を呼ぶ Make ターゲットが setup を先に実行し、同版の既存 addon は再利用する。版の不一致や不完全な addon は上書きせず失敗する。archive の SHA256 は取得物と照合して一致を確認した。
