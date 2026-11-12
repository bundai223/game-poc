---
title: 輪郭モデルとGodot変換境界
genre: architecture
summary: 2D輪郭と3D部品・接続を値データとJSONで扱い、Godotノード生成をadapterへ分ける。
updated: 2026-11-12
confidence: medium
status: active
sources:
  - raw/issues/2026-11-11_10/model-and-adapter.md
  - raw/issues/2026-11-11_10/part-transform-model.md
  - raw/issues/2026-11-12_8/concave-outlines.md
  - raw/issues/2026-11-12_11/vehicle-craft-poc.md
  - raw/issues/2026-11-12_11/vehicle-craft-autosave.md
---

# 輪郭モデルとGodot変換境界

## 現在の分割

- `outline.gd` は輪郭点列を簡略化し、面積・頂点数・自己交差などを検証する。凹形状も受け付ける。
- `outline_data.gd` は2D輪郭点列を保持し、バージョン付きJSONへ変換・復元する。NodeやSceneTreeを必要としない。
- `part_data.gd` は3D部品IDと `Transform3D` を値データとして保持し、バージョン付きJSONへ変換・復元する。
- `vehicle_data.gd` は部品種別、Transform、ID参照の固定/ヒンジ接続を値として保持し、バージョン付きJSONへ変換・復元する。
- `rigid_body_adapter.gd` は輪郭データから `RigidBody2D` と表示・衝突用Polygonを作る。
- `vehicle_adapter.gd` は部品・接続モデルから3D表示用部品と `RigidBody3D` / `HingeJoint3D` を作る。固定接続のブロック群は一つの剛体へまとめる。
- `main.gd` は入力とSceneへの登録・リセットを扱う。
- `vehicle_craft/main.gd` は3D編集・試走・保存/読込UIを扱う。

データモデルはGodotの `Vector2`、`PackedVector2Array`、`Transform3D` を使う。NodeやSceneTreeなしのテストはできるが、Godotランタイム外や別エンジンでの実行は未検証。

## 範囲

2D輪郭と3D部品の種別・Transform・固定/ヒンジ接続の最小データモデルを実装した。3D表示と走行用のScene変換は `vehicle_adapter.gd` に置き、汎用の剛体・関節レイヤーは作らない。両モデルのJSON変換をテストし、3D Vehicle Craftは画面からローカル保存・読込できる。2D輪郭の画面からの保存・読込は未実装。
