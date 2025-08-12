# Hardhat Browser Deploy Tool

ブラウザ上でMetaMaskを使ってHardhatプロジェクトのスマートコントラクトをデプロイできるツールです。コマンドラインを使わずに、GUIで簡単にコントラクトのデプロイとインタラクションが可能です。

## 特徴

- 🚀 **ブラウザベースのUI** - コマンドライン不要
- 🦊 **MetaMask統合** - ウォレット接続でセキュアにデプロイ
- 📁 **マルチプロジェクト対応** - 複数のHardhatプロジェクトを管理
- 📋 **ABI出力** - デプロイ後すぐにABIをコピー/ダウンロード
- 🔧 **コントラクト操作** - デプロイ済みコントラクトの関数実行（今後実装予定）

## クイックスタート

### 1. リポジトリのクローン

```bash
git clone https://github.com/yourusername/myrmx.git
cd myrmx
```

### 2. 依存関係のインストール

```bash
# ツール本体の依存関係
cd browser-deploy
npm install

# サンプルプロジェクトの依存関係
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

1. **プロジェクト選択**: ドロップダウンから `sample-project` を選択
2. **MetaMask接続**: 「Connect MetaMask」ボタンをクリック
3. **コンパイル**: 「📁 Compile」ボタンでコントラクトをコンパイル
4. **コントラクト選択**: 表示されたコントラクトから1つを選択
5. **デプロイ**: 「🚀 Deploy Selected Contract」をクリック
6. **結果確認**: デプロイアドレスとABIが表示されます

## プロジェクト構成

```
myrmx/
├── browser-deploy/        # WebUIツール本体
│   ├── index.html        # メインUI
│   ├── js/app.js         # アプリケーションロジック
│   └── server.js         # Expressサーバー
├── projects/             # Hardhatプロジェクト群
│   └── sample-project/   # サンプルプロジェクト
│       ├── contracts/    # スマートコントラクト
│       ├── hardhat.config.js
│       └── package.json
└── docs/                 # ドキュメント
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

## 開発ロードマップ

- [x] 基本的なデプロイ機能
- [x] マルチプロジェクト対応
- [x] ABI出力機能
- [ ] コントラクトインタラクション機能
- [ ] デプロイ履歴
- [ ] ガス見積もり表示
- [ ] Hardhatプラグイン化

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

## コントリビューション

プルリクエストは大歓迎です！

## ライセンス

MIT
