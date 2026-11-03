# Wiki スキーマ

## 2 層の役割

- `raw/` は原本と事実の記録層。追記のみとし、書き換え・削除はしない。
- `wiki/` は原本から蒸留した知識層。LLM が編集でき、各ページは必ず `raw/` を根拠にする。

## 読み方

`SCHEMA.md` → `index.md` → 関連ジャンルの `index.md` → 必要なページの順に読む。Wiki 全体を一括で読み込まない。

## ジャンル

| ジャンル | 内容 |
| --- | --- |
| user-experiences | 操作体験と利用時の発見 |
| architecture | データモデル、構成、設計判断 |
| security | セキュリティ上の制約と対策 |
| infrastructure | 開発環境、CI、配布 |
| templates | 再利用する記録・作業テンプレート |
| reviews | レビューの結果と学び |
| concepts | 物理、計算幾何、描画などの概念 |
| entities | 人、ツール、外部プロジェクト |
| experiments | PoC の目的、実装、結果、制約、次の実験 |

## ページの書き方

`wiki/pages/<genre>/` に Markdown を置き、次の frontmatter を付ける。`sources` は根拠となる `raw/` 内のパスを一つ以上列挙する。観測事実、推測、未検証事項を区別する。

```yaml
---
title: ページ名
genre: experiments
summary: 一文の要約
updated: YYYY-MM-DD
confidence: high # high / medium / low
status: active # active / needs-review / superseded
sources:
  - raw/decisions/0001-example.md
---
```

## 更新操作

1. **Create**：新しい知識を根拠とともに作成する。
2. **Update**：新しい原本に基づき既存ページを更新する。
3. **Split**：大きくなったページを分割し、リンクを更新する。
4. **Synthesis**：複数の原本やページを照合し、根拠を示して統合する。

各操作後、該当ジャンルの `log.md` に `- YYYY-MM-DD [操作] ページ名: 一言（根拠 raw）` の形式で追記し、ジャンル index と全体 index のページ数を更新する。ログは追記専用。

## 矛盾と昇華

根拠同士が矛盾する場合、既存の主張を勝手に置き換えず、`status: needs-review` に変更して「未解決の矛盾」節に双方の根拠を書く。人間が裁定する。

同種の知見が raw に 2 回以上現れたら、共通点と差異を確認し、パターンとして根拠を列挙して蒸留する。

## 大きな原本

画像入り HTML などの重い原本は元の場所に置き、`raw/<カテゴリ>/` に元の場所への索引と要点抽出を作る。必要に応じて原本を `.gitignore` に追加する。索引から原本をたどれるようにする。
