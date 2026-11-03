---
title: Godot 開発環境
genre: infrastructure
summary: Mac で Godot の最小シーンを起動するための構成と検証状況。
updated: 2026-11-04
confidence: high
status: active
sources:
  - raw/decisions/0001-Godot開発環境.md
---

# Godot 開発環境

Godot 4.7.2 stable と Compatibility レンダラーを採用し、Mac ネイティブで最小 2D シーンを起動する。コマンドとセットアップ手順はリポジトリの README を参照する。

通常環境ではヘッドレスインポートと起動、およびウィンドウ起動の正常終了を確認した。ウィンドウの表示内容は未確認。サンドボックスでは Godot のユーザー設定・ログ領域への書き込みが拒否された。

Web 用テンプレートは構築した Mac に配置済みだが、Web エクスポートは未設定。GdUnit4 と Godot 4.7.2 の実動互換性は未確認で、テスト基盤導入時に検証する。
