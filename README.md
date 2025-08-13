# siegeNgin

<div align="center">
  <h3>Hardhat Browser Deploy Tool</h3>
  <p>ブラウザ上でMetaMaskを使ってHardhatプロジェクトのスマートコントラクトをデプロイできるツールです。<br>
  コマンドラインを使わずに、GUIで簡単にコントラクトのデプロイとインタラクションが可能です。</p>
</div>

<div align="center">
  <img src="docs/images/trebuchet.jpg" alt="Trebuchet - Medieval Siege Engine" width="600">
  
  *A trebuchet at Château de Castelnaud (Image: [ChrisO](https://commons.wikimedia.org/wiki/User:ChrisO), [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0), via Wikimedia Commons)*
</div>


## 特徴

- **ブラウザベースのUI** - コマンドライン不要
- **MetaMask統合** - ウォレット接続でセキュアにデプロイ
- **マルチプロジェクト対応** - 複数のHardhatプロジェクトを管理
- **ABI出力** - デプロイ後すぐにABIをコピー/ダウンロード
- **インターフェース自動生成** - デプロイ時にABIとインターフェースファイルを自動出力
- **Interface-based Interaction** - インターフェースディレクトリを持つプロジェクトで、任意のコントラクトアドレスに対してインタラクション可能
- **マルチネットワーク対応** - Ethereum、Polygon、BSC、Avalanche等の主要ネットワークをサポート
- **ガス見積もり** - デプロイ前に料金を確認
- **セキュリティ強化** - パストラバーサル対策、ネットワーク検証
- **プロジェクト管理** - 自動依存関係インストール、クリーンアップ機能
- **スマートバリデーション** - コンストラクタ引数の型別検証
- **クロスプロジェクト インポート** - 他プロジェクトのコントラクトを共有
- **複雑なデプロイメント対応** - 多層構造のコントラクトを自動デプロイ
- **コントラクトインタラクション** - デプロイ済みコントラクトの読み書き機能
- **イベントモニタリング** - コントラクトイベントのリアルタイム監視
- **詳細なエラー表示** - Solidityのrevert理由を明確に表示

## 名前の由来

中世ヨーロッパで使われた「siege engine」（攻城兵器）は、
難攻不落の城を攻略するための投石機やカタパルトでした。
この攻城兵器を操作する技術者を「ingeniator」と呼び、
これが現代の「engineer」（エンジニア）の語源となっています。

Hardhat開発環境は、その複雑さから初心者にとってまるで難攻不落の「要塞」のようです。
コマンドライン、設定ファイル、デプロイスクリプト...これらの壁を乗り越えるのは大変な作業です。
siegeNginは、この現代の要塞を攻略するための 新時代の「攻城兵器」として開発されました。
誰もが簡単にスマートコントラクトをデプロイできる世界を実現します。

Web3開発の参入障壁という「城壁」を打ち破り、
より多くの開発者がブロックチェーンの世界に参加できることを願って、
このツールは作られました。

エンジニアの語源に立ち返り、複雑な技術的障壁を打ち破る
― それがsiegeNginに込められた想いです。

## 動作環境

### 必要なソフトウェア
- Node.js: v16以上（推奨: v18）
- npm: v8以上
- MetaMask: 最新版

### 対応ブラウザ
- Chrome 90+
- Firefox 88+
- Edge 90+
- Safari 14+（一部制限あり）

## クイックスタート

### 1. リポジトリのクローン

```bash
git clone https://github.com/yourusername/siegeNgin.git
cd siegeNgin
```

### 2. 依存関係のインストール

```bash
# ツール本体の依存関係
cd browser-deploy
npm install

# サンプルプロジェクトの依存関係（オプション）
# 注: コンパイル時に自動インストールされるため、手動実行は不要
cd ../projects/sample-project
npm install
```

### 3. サーバーの起動

```bash
# browser-deployディレクトリで実行
cd ../../browser-deploy
npm start
```

### 4. ブラウザでアクセス

ブラウザで http://localhost:3000 を開きます。

### 5. 使い方

#### コントラクトのデプロイ
1. **プロジェクト選択**: ドロップダウンから `sample-project` を選択
2. **MetaMask接続**: 「Connect MetaMask」ボタンをクリック
3. **コンパイル**: 「📁 Compile」ボタンでコントラクトをコンパイル
4. **コントラクト選択**: 表示されたコントラクトから1つを選択
5. **デプロイ**: 「🚀 Deploy Selected Contract」をクリック
6. **結果確認**: デプロイアドレスとABIが表示されます
   - ABI/インターフェースファイルは `projects/{project-name}/interface/` に自動保存

#### Interface-based Interaction（インターフェースを使用したコントラクト操作）
1. **Interface Interactionボタン**: プロジェクトに `interface` ディレクトリがある場合に表示
2. **コントラクト選択**: インターフェースファイルから操作したいコントラクトを選択
3. **アドレス入力**: デプロイ済みのコントラクトアドレスを入力
4. **ネットワーク選択**: 
   - "Current Network"を選択するとMetaMaskの現在のネットワークを使用
   - または特定のネットワーク（Polygon、Ethereum等）を選択
5. **Load Contract**: コントラクトを読み込み
6. **関数実行**: Read/Write関数を実行、イベントログを確認

## プロジェクト構成

```
siegeNgin/
├── browser-deploy/        # WebUIツール本体
│   ├── index.html        # メインUI
│   ├── js/app.js         # アプリケーションロジック
│   └── server.js         # Expressサーバー
├── projects/             # Hardhatプロジェクト群
│   ├── sample-project/   # サンプルプロジェクト
│   ├── campaign-v2/      # FreeMintSBTプロジェクト
│   ├── tragedy/          # 複雑な多層NFTプロジェクト
│   └── twin-contracts/   # 共有コントラクトライブラリ
└── docs/                 # ドキュメント
    ├── ARCHITECTURE.md   # システム設計
    ├── COMPLEX_DEPLOYMENTS.md  # 複雑なデプロイガイド
    └── CROSS_PROJECT_IMPORTS.md # プロジェクト間インポート
```

## 新しいプロジェクトの追加

1. `projects/` ディレクトリに新しいHardhatプロジェクトを作成
2. 必要な依存関係をインストール
3. ブラウザをリフレッシュすると自動的に認識されます

```bash
cd projects
mkdir my-new-project
cd my-new-project
npx hardhat init
```

## 主な機能

### プロジェクト管理
- **プロジェクトステータス表示**: 依存関係、ビルド状態、キャッシュ状況を一目で確認
- **クリーンアップ機能**: .gitignoreベースで不要ファイルを一括削除
- **自動依存関係インストール**: コンパイル時に自動でnpm install実行

### セキュリティ機能
- **ネットワーク検証**: メインネット接続時に警告表示
- **パストラバーサル対策**: プロジェクト名の厳格な検証
- **ガス見積もり**: デプロイ前に料金確認ダイアログ表示

### 開発者体験
- **型別入力フィールド**: address、uint、bool等に最適化された入力UI
- **リアルタイムバリデーション**: 入力値の即座検証
- **CORS対応**: 外部ツールとの連携可能

## 主な機能詳細

### 🔗 クロスプロジェクト インポート
他のプロジェクトのコントラクトを共有して使用できます。
- コンパイル時に自動的にコントラクトをコピー
- 依存関係の明確化
- 詳細: [CROSS_PROJECT_IMPORTS.md](docs/CROSS_PROJECT_IMPORTS.md)

### 🏗️ 複雑なデプロイメント
`deploy-config.json`を使用して、依存関係のある複数のコントラクトを正しい順序でデプロイ。
- 自動的な依存関係解決
- 並列デプロイのサポート
- デプロイ後の初期化関数実行
- 詳細: [COMPLEX_DEPLOYMENTS.md](docs/COMPLEX_DEPLOYMENTS.md)

### 📡 コントラクトインタラクション
デプロイ済みのコントラクトと対話できます。
- Read関数の実行と結果表示
- Write関数の実行（トランザクション送信）
- イベントログのリアルタイム監視

## 開発ロードマップ

- [x] 基本的なデプロイ機能
- [x] マルチプロジェクト対応
- [x] ABI出力機能
- [x] ガス見積もり表示
- [x] セキュリティ強化
- [x] プロジェクト管理機能
- [x] コントラクトインタラクション機能
- [x] クロスプロジェクト インポート
- [x] 複雑なデプロイメント対応
- [ ] デプロイ履歴の永続化
- [ ] Hardhatプラグイン化
- [ ] TypeScript対応

## トラブルシューティング

### MetaMaskが接続できない
- MetaMaskがインストールされているか確認
- 正しいネットワークに接続しているか確認（デフォルトはlocalhost:8545）

### コンパイルエラー
- プロジェクトディレクトリで `npm install` を実行したか確認
- Solidityのバージョンが正しいか確認

### ポート3000が使用中
```bash
# 別のポートで起動
PORT=3001 npm start
```

### 環境変数の設定
`.env.example`を`.env`にコピーして、必要に応じて設定を変更してください。

## ドキュメント

- [アーキテクチャ設計](docs/ARCHITECTURE.md) - システム設計と設計思想
- [セットアップガイド](docs/SETUP.md) - 詳細なインストールと設定手順
- [APIリファレンス](docs/api-reference.md) - 開発者向けAPI仕様
- [セキュリティガイド](docs/security.md) - セキュリティ機能と推奨設定
- [変更履歴](docs/CHANGELOG.md) - バージョンごとの変更内容
- [今後の機能拡張予定](docs/future-enhancements.md)

## コントリビューション

プルリクエストは大歓迎です！

## ライセンス

MIT
