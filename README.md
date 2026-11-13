# game-poc

Godot を使い、物理演算やグラフィックスの仕組みを、触って動く小さなゲームの実験を通して学ぶプロジェクトです。各実験で得たデータモデル、アルゴリズム、テスト、設計判断を蓄積し、必要になったものから共通基盤として育てます。

## 現在の状態

Godot で手描き輪郭を落下させる2D PoCと、ブロックと車輪で車を組み立てる3D PoCを試せます。

Web 版: https://bundai223.github.io/game-poc/

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

ブラウザ E2E は Node.js 22、Python 3、Web エクスポートテンプレートが必要です。リポジトリのルートで `npm ci`、`npx playwright install chromium`、`make import`、`make export-web`、`npm run test:e2e` を順に実行します。Chromium で読み込み、マウス描画、`R` キーによる消去を確認します。PR の CI でも実行します。Android では利用者が Reset を含む操作に問題がないことを確認しました。iPad の実機操作は未確認です。

### Dagger によるローカル CI

Dagger 0.21.11 と Docker 互換の Linux コンテナ環境が必要です。Mac の Apple Silicon では `brew install dagger docker colima` で導入した Dagger 0.21.11、Docker CLI 29.9.2、Colima 0.10.3 を使用しました。Homebrew が別の版を導入する場合は、[Dagger の公式インストール手順](https://docs.dagger.io/getting-started/install/)で 0.21.11 を指定してください。

Colima は `colima start --cpu 4 --memory 6 --disk 30 --vm-type vz --vz-rosetta` で起動しました。起動時には Docker の接続先が切り替わります。

```sh
dagger -m .dagger call verify --source . --output build/dagger-web
```

Godot のインポート、ヘッドレステスト、Web 出力と Playwright の E2E を実行します。エラー時は非ゼロで終了します。Godot のビルドは Linux x86_64、ブラウザは Engine の CPU アーキテクチャで動きます。Apple Silicon で x86_64 Chromium はクラッシュしたため、ブラウザには ARM64 を使います。初回は約 1.2 GiB の Godot テンプレートに加え、ブラウザとコンテナイメージの取得が必要です。同じ入力の再実行はキャッシュを使うためテストが再実行されない場合があります。GitHub 固有の workflow や成果物保存は GitHub Actions で確認します。Colima は不要になれば `colima stop` で停止できます。

GdUnit4 の互換表は Godot 4.7.1 までの記載ですが、リポジトリ内の GdUnit4 6.2.3 runner で Godot 4.7.2 のヘッドレス実行を確認しています。

## お絵描き物理 PoC

`make run` で起動し、マウスまたは1本指でドラッグして閉じた形を描きます。描いている間は既存の図形の物理が停止し、入力を離すと再開します。新しい形は落下し、床に当たります。画面右上のモードボタンは `Draw`、`Cut`、`Delete`、`Connect`、`Move` の順に切り替わります。`Cut` ではドラッグ中に物理が停止し、入力を離すと線に沿って形を切断します。速度を落とすか、進む方向を大きく変えると線を折り曲げられます。自己交差する切断線や、小さすぎる破片ができる切断は適用されません。`Connect` では閉じた図形を描き、各剛体との重なり領域の面積が合計0.5平方ピクセルを超える剛体が2個以上ある場合、それらを固定接続します。描いた図形も剛体として残ります。接続先が足りない場合は図形を作りません。接続先の削除や切断では接続も解除します。`Delete` では図形をタッチまたはクリックして個別に削除できます。重なった図形では当たり判定にヒットした1個を削除します。`Move` では図形をドラッグして移動します。重なった図形は最後に生成されたものを選びます。移動中は障害物をすり抜け、離すと速度ゼロで物理が再開します。中断、モード切替、Reset でも操作を解除します。連結済みの図形は移動できません。`Reset` ボタンまたは `R` キーですべての形と接続を消せます。

輪郭は `PackedVector2Array` の点列として `outline.gd` が検証します。近接点とほぼ一直線の点を簡略化し、3〜32頂点、面積500平方ピクセル以上の単純な輪郭を受け付けます。非有限座標と自己交差は破棄します。入力点が2048点を超えた場合も描画を破棄します。`outline_data.gd` はNodeに依存しない輪郭データとバージョン付きJSON変換を持ち、`rigid_body_adapter.gd` がそのデータから `RigidBody2D`、`Polygon2D`、`CollisionPolygon2D` を生成します。`part_data.gd` と `vehicle_data.gd` は3D部品ID・種別・Transform・接続の値モデルとJSON変換を持ちます。モデルはGodotの `Vector2` / `Transform3D` 型を使い、Godotランタイム外や別エンジンでの実行は未検証です。

### 3D Vehicle Craft PoC

2D PoCの画面右上にある `3D Craft` から開きます。1mグリッドにブロックを隣接配置し、ブロック左右に車輪を配置します。既定の車はブロック1個と車輪2個です。部品を選択して移動・削除でき、`保存` / `読込` は `user://vehicle-craft.json` を使います。2D画面へ移るときに保存し、次に開いたときに復元します。

`試走`では車体が動き、車輪もヒンジモーターで回ります。`W/S` または画面上の前進・後退ボタンで進み、`A/D` または左右ボタンで旋回します。`編集`で組み立てに戻れます。試走には、固定接続で連結したブロック群、ブロックにヒンジ接続した車輪、車体中心の左右に少なくとも1個ずつの車輪が必要です。保存はこの実行環境のローカルユーザーデータです。クラウド同期や共有機能はありません。

CLI の unit、Node/Collider、固定物理ステップテストは `make test` で実行できます。GdUnit4 のヘッドレス実行は実際のマウス・タッチ操作を配信しないため、ドラッグ入力の見た目と実機タッチはウィンドウ上で確認してください。Web 操作確認は [#18](https://github.com/bundai223/game-poc/issues/18) で進めています。

- [開発環境と CLI の準備 #9](https://github.com/bundai223/game-poc/issues/9)
- [ヘッドレス自動テスト #16](https://github.com/bundai223/game-poc/issues/16)
- [2D お絵描き物理 PoC #8](https://github.com/bundai223/game-poc/issues/8)
- [エンジン非依存モデル #10](https://github.com/bundai223/game-poc/issues/10)
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
