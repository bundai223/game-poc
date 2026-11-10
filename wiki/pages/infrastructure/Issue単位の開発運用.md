---
title: Issue 単位の開発運用
genre: infrastructure
summary: Issue、ブランチ、PR、セッションと worktree の分け方。
updated: 2026-11-10
confidence: high
status: active
sources:
  - raw/decisions/0003-Issue単位の開発運用.md
  - raw/conversations/2026-11-10_進捗報告の粒度.md
---

# Issue 単位の開発運用

作業 Issue ごとにセッション、ブランチ、PR を分けることを原則とする。ブランチには `codex/` プレフィックスを使う。例: `codex/16-headless-tests`。

大きな Issue はレビューしやすい複数の PR に分割できる。Issue の完了条件を満たす PR には `Closes #番号` を記載し、途中の PR では自動クローズしない。

worktree は並行作業や作業場所の分離が必要な場合に使い、毎回は必須としない。片付ける前に所有者、追跡済み・未追跡・無視対象の変更、ブランチの状態を確認する。

## 進捗報告の粒度

通常の作業報告では、実施内容、確認結果、未確認事項を短く伝える。複数段階の作業は節目で進捗を知らせる。

明確で安全に解消できる前提不足は、原因と対応方針を伝えてから自律的に解消し、作業を続ける。破壊的な操作や、選択によって結果が変わる曖昧な判断は事前に相談する。
