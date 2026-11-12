---
title: Issue 単位の開発運用
genre: infrastructure
summary: Issue、ブランチ、PR、セッションと worktree の分け方。
updated: 2026-11-13
confidence: high
status: active
sources:
  - raw/decisions/0003-Issue単位の開発運用.md
  - raw/conversations/2026-11-10_進捗報告の粒度.md
  - raw/conversations/2026-11-13_開発フェーズとスキル.md
  - raw/conversations/2026-11-13_開発スキルと記録先.md
  - raw/issues/2026-11-13_51/issue-created.md
  - raw/issues/2026-11-13_51/scope-update.md
---

# Issue 単位の開発運用

作業 Issue ごとにセッション、ブランチ、PR を分けることを原則とする。ブランチには `codex/` プレフィックスを使う。例: `codex/16-headless-tests`。

大きな Issue はレビューしやすい複数の PR に分割できる。Issue の完了条件を満たす PR には `Closes #番号` を記載し、途中の PR では自動クローズしない。

worktree は並行作業や作業場所の分離が必要な場合に使い、毎回は必須としない。片付ける前に所有者、追跡済み・未追跡・無視対象の変更、ブランチの状態を確認する。

## 進捗報告の粒度

通常の作業報告では、実施内容、確認結果、未確認事項を短く伝える。複数段階の作業は節目で進捗を知らせる。

明確で安全に解消できる前提不足は、原因と対応方針を伝えてから自律的に解消し、作業を続ける。破壊的な操作や、選択によって結果が変わる曖昧な判断は事前に相談する。

## 開発フェーズ

計画では要求と完了条件を整理して Issue を作り、内容を利用者に提示して確認する。実装は利用者が対象 Issue を指定した後に始める。報告・レビューではその差分を確認する。フェーズごとのスキルと切替条件は `AGENTS.md` に記載する。マージ報告だけでは、同じ Issue の残作業を含む新たな実装に着手しない。

GitHub Issues は作業の受付と現在状態の正本にする。Issue の確認事実・判断・検証結果は `raw/issues/` に記録し、再利用する知識を `wiki/pages/` に蒸留する。Issue 本文をそのまま複製せず、Issue 状態は GitHub で確認する。TSV の用途はリポジトリから確認できていないため、既存ファイルが特定されるまで新規作成しない。
