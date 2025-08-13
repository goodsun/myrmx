# プロジェクトテンプレート仕様

新規プロジェクト作成時に必要なファイルとディレクトリ構造。

## 必須ファイル

### .gitignore
```
# Dependencies
node_modules/

# Hardhat files
cache/
artifacts/
typechain/
typechain-types/

# Generated interface files
interface/

# Environment variables
.env
.env.local

# IDE
.vscode/
.idea/

# OS
.DS_Store

# Logs
*.log

# Temporary files
*.tmp
```

### hardhat.config.js
```javascript
require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: "0.8.19",
  networks: {
    // Network configurations
  }
};
```

### package.json
```json
{
  "name": "project-name",
  "version": "1.0.0",
  "devDependencies": {
    "@nomiclabs/hardhat-ethers": "^2.0.0",
    "@nomiclabs/hardhat-waffle": "^2.0.0",
    "chai": "^4.2.0",
    "ethereum-waffle": "^3.0.0",
    "ethers": "^5.0.0",
    "hardhat": "^2.0.0"
  }
}
```

## ディレクトリ構造

```
new-project/
├── contracts/           # Solidityコントラクト
├── scripts/            # デプロイメントスクリプト
├── test/               # テストファイル
├── .gitignore          # Git除外設定
├── hardhat.config.js   # Hardhat設定
└── package.json        # パッケージ設定
```

## 自動生成されるディレクトリ

以下のディレクトリは実行時に自動生成され、.gitignoreで除外されます：

- `node_modules/` - npm依存関係
- `artifacts/` - コンパイル結果
- `cache/` - Hardhatキャッシュ
- `interface/` - ABIとインターフェースファイル

## 注意事項

1. **interfaceディレクトリ**
   - デプロイ時に自動生成される
   - Gitには含めない（再生成可能なため）
   - Clean Project実行時に削除される

2. **環境変数**
   - .envファイルは絶対にGitにコミットしない
   - 秘密鍵やAPIキーは.envに保存

3. **バージョン管理**
   - package-lock.jsonはプロジェクトによって判断
   - 再現性を重視する場合はコミット推奨