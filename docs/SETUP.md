# siegeNgin セットアップガイド

## 必要な環境

- Node.js v14以上
- npm または yarn
- MetaMask（ブラウザ拡張機能）
- Git（オプション）

## インストール手順

### 1. リポジトリのクローンまたはダウンロード

```bash
git clone https://github.com/yourusername/siegeNgin.git
cd siegeNgin
```

### 2. サーバーのセットアップ

```bash
cd browser-deploy
npm install
```

### 3. サーバーの起動

```bash
npm start
# または
node server.js
```

サーバーが http://localhost:3000 で起動します。

### 4. ブラウザでアクセス

1. ブラウザで http://localhost:3000 を開く
2. MetaMaskをインストール済みであることを確認
3. 適切なネットワークに接続

## プロジェクトの管理

### 新規プロジェクトの作成

1. UIの「➕ New Project」ボタンをクリック
2. プロジェクト名を入力（英数字、ハイフン、アンダースコアのみ）
3. 自動的に以下が実行されます：
   - プロジェクト構造の生成
   - 依存関係のインストール
   - サンプルコントラクトの作成

### 既存プロジェクトの追加

既存のHardhatプロジェクトがある場合：

```bash
# プロジェクトをprojectsディレクトリにコピー
cp -r /path/to/your/hardhat-project ./projects/

# 依存関係をインストール（必要な場合）
cd projects/your-hardhat-project
npm install
```

### プロジェクトの操作

1. **プロジェクト選択**: ドロップダウンから選択
2. **プロジェクトステータスの確認**:
   - Dependencies: 依存関係のインストール状態
   - Build artifacts: コンパイル結果の有無
   - Cache: Hardhatキャッシュの状態
   - Interface files: 生成されたインターフェースファイルの有無
3. **コンパイル**: 「Compile」ボタンをクリック
4. **デプロイ**: 
   - MetaMaskを接続
   - コントラクトを選択
   - パラメータを入力
   - 「Deploy」をクリック
5. **クリーンアップ**: 「🧹 Clean Project」ボタンで以下を削除
   - node_modules
   - artifacts
   - cache
   - interface（生成されたABI/インターフェースファイル）
   - その他.gitignoreに記載されたファイル

## トラブルシューティング

### コンパイルエラー: "Error HH12"

**原因**: node_modulesが存在しない

**解決方法**:
```bash
cd projects/your-project
npm install
```

### MetaMask接続エラー

**確認事項**:
- MetaMaskがインストールされているか
- 正しいネットワークに接続しているか
- アカウントがアンロックされているか

### ポート3000が使用中

**解決方法**:
```bash
# 別のポートで起動
PORT=3001 npm start
```

### artifacts/cacheが作成されない

**確認事項**:
1. node_modulesが存在するか確認
2. hardhat.config.jsが正しく設定されているか
3. コンパイルエラーがないか確認

## 推奨事項

### プロジェクトごとの.gitignore

各プロジェクトに以下の`.gitignore`を配置：

```gitignore
node_modules
.env
coverage
coverage.json
typechain
typechain-types

# Hardhat files
cache
artifacts
```

### 環境変数の管理

機密情報は`.env`ファイルで管理：

```bash
# .env.example
PRIVATE_KEY=your_private_key_here
INFURA_API_KEY=your_infura_key_here
```

**注意**: `.env`ファイルは絶対にGitにコミットしないでください。

### バックアップ

重要なプロジェクトは定期的にバックアップ：
- contractsフォルダ
- hardhat.config.js
- package.json
- デプロイ済みコントラクトのアドレス

## 次のステップ

- [アーキテクチャ設計](./ARCHITECTURE.md)を読んで設計思想を理解
- [README](../README.md)で基本的な使い方を確認
- サンプルプロジェクトでテストデプロイを実行