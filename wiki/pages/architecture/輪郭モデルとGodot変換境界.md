---
title: 輪郭モデルとGodot変換境界
genre: architecture
summary: 2D輪郭と3D部品ID・Transformを値データとJSONで扱い、2DのGodotノード生成をadapterへ分ける。
updated: 2026-11-11
confidence: medium
status: active
sources:
  - raw/issues/2026-11-11_10/model-and-adapter.md
  - raw/issues/2026-11-11_10/part-transform-model.md
---

# 輪郭モデルとGodot変換境界

## 現在の分割

- `outline.gd` は輪郭点列の簡略化と凸形状の検証を行う。
- `outline_data.gd` は2D輪郭点列を保持し、バージョン付きJSONへ変換・復元する。NodeやSceneTreeを必要としない。
- `part_data.gd` は3D部品IDと `Transform3D` を値データとして保持し、バージョン付きJSONへ変換・復元する。
- `rigid_body_adapter.gd` は輪郭データから `RigidBody2D` と表示・衝突用Polygonを作る。
- `main.gd` は入力とSceneへの登録・リセットを扱う。

データモデルはGodotの `Vector2`、`PackedVector2Array`、`Transform3D` を使う。NodeやSceneTreeなしのテストはできるが、Godotランタイム外や別エンジンでの実行は未検証。

## 範囲

2D輪郭と3D部品ID・Transformの最小データモデルを実装した。3D部品の形状、接続、Scene変換は利用先ができるまで定義しない。JSON変換の往復はテスト済みだが、アプリ画面からのファイル保存・読込は未実装。
