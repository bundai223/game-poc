# game-poc

Godot を使い、物理演算やグラフィックスの仕組みを、触って動く小さなゲームの実験を通して学ぶプロジェクトです。各実験で得たデータモデル、アルゴリズム、テスト、設計判断を蓄積し、必要になったものから共通基盤として育てます。

## 現在の状態

Godot で手描きの凸形状を剛体に変え、床への落下と衝突を試せます。

## 開発環境と起動

Mac 上の [Godot 4.7.2 stable](https://godotengine.org/download/archive/4.7.2-stable/)、[ggg 0.6.0](https://github.com/godotneers/ggg/releases/tag/v0.6.0)、`make` を使用します。Godot を `/Applications/Godot.app` に配置し、ggg を PATH に通してリポジトリのルートで実行してください。ggg の導入方法は[公式手順](https://godotneers.github.io/ggg/)を参照してください。

```sh
make setup   # Godot 4.7.2 と GdUnit4 6.2.3 を同期
make import  # アセットをヘッドレスでインポート
make test    # ヘッドレステストを実行
make editor  # エディタを開く
make run     # お絵描き物理 PoC を起動
make export-web # build/web/ に Web 版を出力
```

別の場所に Godot がある場合は `make run GODOT=/path/to/Godot` のように実行ファイルを指定できます。ggg が PATH にない場合は、各コマンドに `GGG=/path/to/ggg` を指定してください。Godot を使う各 Make ターゲットは先に ggg で環境を同期します。`ggg.toml` が Godot と GdUnit4 6.2.3 を宣言し、`ggg.lock` が addon の取得元と archive hash を固定します。addon のファイルは Git 管理しません。`.godot/` は生成物のため Git で管理せず、シーンなどのプロジェクトファイルと Godot が生成する `.uid` ファイルは管理対象にします。

既存の `addons/gdUnit4` が ggg 管理外の場合、`make setup` は競合として停止し、上書きや削除をしません。移行前にディレクトリをプロジェクト外へバックアップし、内容を確認してから退避してください。初回取得にはネットワーク接続が必要です。

`make test` はエディターを開かずにテストを実行します。GitHub Actions は pull request ごとに Ubuntu 上で import、テスト、Web export を実行し、`build/web/` を Artifact として保存します。ローカル Linux での実行は未確認です。Linux で `godot` が PATH にある場合のコマンドは `make test GODOT=godot` です。テストは `tests/` に置き、幾何計算、Node/Collider の生成、固定物理ステップの最小例を含みます。描画品質やタッチ操作はヘッドレステストの対象外です。

Web エクスポートには、Godot の「エディター → エクスポートテンプレートを管理」から 4.7.2 のテンプレートをインストールしてください。

Web 版はシングルスレッドの Compatibility 設定です。`make export-web` の後、`python3 -m http.server 8000 --bind 127.0.0.1 --directory build/web` を実行し、同じ Mac のブラウザで `http://127.0.0.1:8000/` を開けます。停止するにはサーバーを実行したターミナルで Ctrl+C を押します。共有や実機検証は [#18](https://github.com/bundai223/game-poc/issues/18) で進めます。

`main` への push 時には GitHub Actions が Web 版をビルドし、GitHub Pages に公開します。

GdUnit4 の互換表は Godot 4.7.1 までの記載ですが、リポジトリ内の GdUnit4 6.2.3 runner で Godot 4.7.2 のヘッドレス実行を確認しています。

## お絵描き物理 PoC

`make run` で起動し、マウスまたは1本指でドラッグして閉じた形を描きます。入力を離すと形が落下し、床に当たります。`R` キーで作成した形を消して描き直せます。

輪郭は `PackedVector2Array` の点列として `outline.gd` が検証します。近接点とほぼ一直線の点を簡略化し、3〜32頂点、面積500平方ピクセル以上の凸形状だけを受け付けます。非有限座標、自己交差、凹形状は破棄します。入力点が2048点を超えた場合も描画を破棄します。輪郭のモデルは Node に依存しません。表示用 `Polygon2D` と物理用 `CollisionPolygon2D` は同じ輪郭点列から生成します。

CLI の unit、Node/Collider、固定物理ステップテストは `make test` で実行できます。GdUnit4 のヘッドレス実行は実際のマウス・タッチ操作を配信しないため、ドラッグ入力の見た目と実機タッチはウィンドウ上で確認してください。Mac、Android、iPad の Web 操作確認は [#18](https://github.com/bundai223/game-poc/issues/18) で行います。

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
