---
title: Godot 開発環境
genre: infrastructure
summary: Mac で Godot の最小シーンを起動するための構成と検証状況。
updated: 2026-11-07
confidence: high
status: active
sources:
  - raw/decisions/0001-Godot開発環境.md
  - raw/decisions/0002-Webエクスポート.md
  - raw/decisions/0004-ヘッドレステスト.md
  - raw/issues/2026-11-05_17/ci-workflow.md
  - raw/issues/2026-11-05_17/ci-verification.md
  - raw/decisions/0005-Web出力のテスト除外.md
  - raw/decisions/0006-GdUnit4依存の自動セットアップ.md
  - raw/decisions/0007-ggg依存管理.md
  - raw/issues/2026-11-05_17/ggg-ci-verification.md
  - raw/issues/2026-11-07_24/local-dagger.md
  - raw/issues/2026-11-07_24/github-dagger.md
  - raw/issues/2026-11-07_24/github-dagger-failure.md
  - raw/issues/2026-11-09_24/closure.md
---

# Godot 開発環境

Godot 4.7.2 stable と Compatibility レンダラーを採用し、Mac ネイティブで最小 2D シーンを起動する。コマンドとセットアップ手順はリポジトリの README を参照する。

通常環境ではヘッドレスインポートと起動、およびウィンドウ起動の正常終了を確認した。ウィンドウの表示内容は未確認。サンドボックスでは Godot のユーザー設定・ログ領域への書き込みが拒否された。

Web 用テンプレートは構築した Mac に配置済み。シングルスレッドの Web 版をエクスポートし、ローカルブラウザで最小シーンの表示を確認した。Tailscale 限定共有の URL から HTML と WebAssembly を取得できたが、リモート端末での表示・操作は未確認。

Godot 4.7.2 と GdUnit4 6.2.3 の組み合わせで、`make test` による 3 件のヘッドレステストと故意の失敗の検出を Mac で確認した。GitHub Actions の Ubuntu でも import、テスト、Web export、Artifact の取得を確認した。ローカル Linux での実行は未確認。

Web export には GdUnit4 とテストを含めない。addon を含めると export が異常終了したため、除外後の出力を Mac と GitHub Actions の Ubuntu で確認した。

GdUnit4 6.2.3 の addon は Git 管理せず、`ggg.toml` と `ggg.lock` に取得元と SHA256 を固定する。Godot を呼ぶ Make ターゲットは `ggg sync` を先に実行する。Mac と GitHub Actions の Ubuntu で依存の同期、3 件のテスト、Web export を確認した。既存ファイルとの競合時には ggg が停止してファイルを保護する。Pages workflow 自体の実行結果は未確認。

Apple Silicon の Mac では、Colima 上の Dagger 0.21.11 で Linux x86_64 の Godot テスト 14 件と Web 出力、ARM64 Chromium の E2E 1 件が成功した。x86_64 Chromium はページ作成時にクラッシュした。GitHub Actions の Ubuntu x86_64 でも同じ Dagger 定義による Godot 14 件、Web 出力、Chromium E2E 1 件が成功した。故意に E2E を失敗させた実行では、Dagger のローカル実行と GitHub Actions の両方で失敗を検出した。

Issue #24 の検証は完了し、PR #25 はマージ済み。Podman でのローカル実行は保留し、当面は GitHub Actions で Dagger を実行する。Dagger 試験用マシンは停止・削除済みで、既存のデフォルト Podman マシンには変更を加えていない。Podman Engine を使った Dagger 実行は未検証。
