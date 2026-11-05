# game-poc

Godot を使い、物理演算やグラフィックスの仕組みを、触って動く小さなゲームの実験を通して学ぶプロジェクトです。各実験で得たデータモデル、アルゴリズム、テスト、設計判断を蓄積し、必要になったものから共通基盤として育てます。

## 現在の状態

開発環境の準備段階です。Godot の最小シーンは起動できますが、お絵描き物理デモはまだ実装されていません。

## 開発環境と起動

Mac 上の [Godot 4.7.2 stable](https://godotengine.org/download/archive/4.7.2-stable/)、[ggg 0.6.0](https://github.com/godotneers/ggg/releases/tag/v0.6.0)、`make` を使用します。Godot を `/Applications/Godot.app` に配置し、ggg を PATH に通してリポジトリのルートで実行してください。ggg の導入方法は[公式手順](https://godotneers.github.io/ggg/)を参照してください。

```sh
make setup   # Godot 4.7.2 と GdUnit4 6.2.3 を同期
make import  # アセットをヘッドレスでインポート
make test    # ヘッドレステストを実行
make editor  # エディタを開く
make run     # 最小シーンを起動
make export-web # build/web/ に Web 版を出力
```

別の場所に Godot がある場合は `make run GODOT=/path/to/Godot` のように実行ファイルを指定できます。ggg が PATH にない場合は `make setup GGG=/path/to/ggg` のように指定できます。Godot を使う各 Make ターゲットは先に ggg で環境を同期します。`ggg.toml` が Godot と GdUnit4 6.2.3 を宣言し、`ggg.lock` が addon の取得元と archive hash を固定します。addon のファイルは Git 管理しません。`.godot/` は生成物のため Git で管理せず、シーンなどのプロジェクトファイルと Godot が生成する `.uid` ファイルは管理対象にします。

Godot 4.7.2 と GdUnit4 6.2.3 を固定しています。ggg は `ggg.toml` と `ggg.lock` に基づいて GdUnit4 を同期し、addon ファイル自体は Git 管理しません。既存の `addons/gdUnit4` が ggg 管理外の場合、`make setup` は競合として停止し、上書きや削除をしません。移行前にそのディレクトリをプロジェクト外へバックアップし、既存の内容が不要だと確認できた後でのみ退避または削除してから再実行してください。ネットワーク接続も必要です。`make test` はエディターを開かずにテストを実行します。Linux で `godot` が PATH にある場合のコマンドは `make test GODOT=godot` です。テストは `tests/` に置き、幾何計算、Node/Collider の生成、固定物理ステップの最小例を含みます。描画品質やタッチ操作はヘッドレステストの対象外です。

Web エクスポートには、Godot の「エディター → エクスポートテンプレートを管理」から 4.7.2 のテンプレートをインストールしてください。

Web 版はシングルスレッドの Compatibility 設定です。`make export-web` の後、`python3 -m http.server 8000 --bind 127.0.0.1 --directory build/web` を実行し、同じ Mac のブラウザで `http://127.0.0.1:8000/` を開けます。停止するにはサーバーを実行したターミナルで Ctrl+C を押します。共有や実機検証は [#18](https://github.com/bundai223/game-poc/issues/18) で進めます。

`main` への push 時には GitHub Actions が Web 版をビルドし、GitHub Pages に公開します。

GdUnit4 の互換表は Godot 4.7.1 までの記載ですが、リポジトリ内の GdUnit4 6.2.3 runner で Godot 4.7.2 のヘッドレス実行を確認しています。

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
