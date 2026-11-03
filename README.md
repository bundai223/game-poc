# game-poc

Godot を使い、物理演算やグラフィックスの仕組みを、触って動く小さなゲームの実験を通して学ぶプロジェクトです。各実験で得たデータモデル、アルゴリズム、テスト、設計判断を蓄積し、必要になったものから共通基盤として育てます。

## 現在の状態

企画・準備段階です。このリポジトリにはまだ Godot プロジェクトや実行可能なデモはありません。Godot のバージョン、セットアップ手順、実行コマンドは [開発環境の Issue](https://github.com/bundai223/game-poc/issues/9) で整備する予定です。

## 最初に作るもの

マウスなどで描いた閉じた形を物理オブジェクトに変え、落下や床との衝突を観察できる 2D デモを目指します。まず Mac 上で動かし、その後 Web プレビューやブラウザ・モバイル実機での検証を進めます。

- [開発環境と CLI の準備 #9](https://github.com/bundai223/game-poc/issues/9)
- [ヘッドレス自動テスト #16](https://github.com/bundai223/game-poc/issues/16)
- [2D お絵描き物理 PoC #8](https://github.com/bundai223/game-poc/issues/8)
- [CI と Web ビルド #17](https://github.com/bundai223/game-poc/issues/17)
- [Web プレビューと実機検証 #18](https://github.com/bundai223/game-poc/issues/18)

## 今後の実験

- [物理クラフト #3](https://github.com/bundai223/game-poc/issues/3)：ブロックと車輪を組み立て、走らせる。
- [自由切断 #4](https://github.com/bundai223/game-poc/issues/4)：物体を平面で切り、分割片の物理挙動を試す。
- [パーティクルと GPGPU #5](https://github.com/bundai223/game-poc/issues/5)：粒子表現と Compute Shader による計算を試す。
- [シェーダ #6](https://github.com/bundai223/game-poc/issues/6)：頂点変形やフラグメント表現を試す。

## 開発方針

- Mac ネイティブの Godot 4 系と GDScript を開発の出発点とし、CLI と Linux CI での検証を整える。
- Web を共有・動作確認の主な対象とする。Compute Shader などはネイティブ専用の実験も許容する。
- 先に動くものを作り、必要になったデータやロジックから Godot の Node と分離する。最初から汎用エンジンを作ることは目標にしない。
- 各 PoC の目的、実装、結果、制約、設計判断、次の実験を記録する。

全体の順序と詳細は [ロードマップ #1](https://github.com/bundai223/game-poc/issues/1) を参照してください。
