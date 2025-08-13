# インターフェース管理機能

siegeNginは、コントラクトのインターフェースファイルとABIを自動的に管理し、デプロイ済みコントラクトとの簡単なインタラクションを可能にします。

## 概要

インターフェース管理機能は以下の2つの主要な機能を提供します：

1. **自動インターフェース生成** - デプロイ時にABIとインターフェースファイルを自動生成
2. **Interface-based Interaction** - インターフェースを使用したコントラクト操作

## 自動インターフェース生成

### 生成されるファイル

コントラクトをデプロイすると、以下のファイルが自動的に生成されます：

```
projects/{project-name}/interface/
├── ContractName.abi.json        # コントラクトのABI
├── IContractName.sol            # Solidityインターフェース
└── IIContractName.sol           # 拡張インターフェース（必要に応じて）
```

### 生成タイミング

- **デプロイ成功時**: 自動的にinterfaceディレクトリを作成し、ファイルを生成
- **既存ファイルの扱い**: 同名のファイルが存在する場合は上書き

### 利点

- コントラクトのABIを手動でコピーする必要がない
- 他のプロジェクトからインターフェースをインポート可能
- TypeScriptやフロントエンド開発での型安全性の向上

### メンテナンス

- **Clean Project実行時**: interfaceディレクトリも削除対象に含まれます
- **再生成**: 次回デプロイ時に自動的に再生成されます
- **Git管理**: .gitignoreで除外されるため、リポジトリには含まれません

## Interface-based Interaction

### 概要

インターフェースディレクトリを持つプロジェクトでは、任意のデプロイ済みコントラクトに対して簡単にインタラクションできます。

### 使用方法

1. **プロジェクト選択**
   - interfaceディレクトリを持つプロジェクトを選択
   - 「Interface Interaction」ボタンが表示される

2. **コントラクト選択**
   - ドロップダウンから操作したいコントラクトを選択
   - インターフェースファイルから自動的にABIを読み込み

3. **アドレスとネットワーク指定**
   - デプロイ済みコントラクトのアドレスを入力
   - ネットワークを選択（Current Network推奨）

4. **関数実行**
   - Read関数：ガス不要、即座に結果を取得
   - Write関数：トランザクション送信、MetaMask承認が必要
   - Events：過去のイベントログを取得

### サポートされるネットワーク

- **Current Network**: MetaMaskで接続中のネットワークを自動検出
- **Ethereum**: Mainnet、Sepolia
- **Polygon**: Mainnet、Amoy Testnet
- **その他**: BSC、Avalanche、Arbitrum、Optimism等

### エラーハンドリング

- **詳細なエラーメッセージ**: Solidityのrevert理由を明確に表示
- **ネットワーク確認**: コントラクトが存在しない場合は警告
- **型検証**: パラメータの型を自動検証

## 技術的詳細

### ABIファイル形式

```json
[
  {
    "inputs": [],
    "name": "mint",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  // ... 他の関数
]
```

### インターフェースファイル形式

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IContractName {
    function mint() external;
    function balanceOf(address owner) external view returns (uint256);
    // ... 他の関数
}
```

### API エンドポイント

- `GET /api/projects/:projectName/interfaces` - インターフェースファイル一覧
- `GET /api/projects/:projectName/interface/:filename` - 特定のABIファイル取得

## ベストプラクティス

1. **バージョン管理**
   - interfaceディレクトリをGitで管理
   - コントラクト更新時は必ず再デプロイ

2. **命名規則**
   - インターフェースファイルは`I`プレフィックスを使用
   - ABIファイルは`.abi.json`拡張子

3. **セキュリティ**
   - プライベートな関数はインターフェースに含めない
   - アドレスは必ず検証してから使用

## トラブルシューティング

### "Contract call failed"エラー

原因：
- 間違ったネットワークに接続している
- コントラクトアドレスが間違っている
- ABIが実際のコントラクトと一致しない

解決方法：
1. MetaMaskのネットワークを確認
2. コントラクトアドレスを再確認
3. 最新のABIを使用しているか確認

### インターフェースファイルが生成されない

原因：
- デプロイが失敗した
- ファイルシステムの権限問題

解決方法：
1. デプロイログを確認
2. projectsディレクトリの書き込み権限を確認

## 関連ドキュメント

- [クロスプロジェクトインポート](./CROSS_PROJECT_IMPORTS.md)
- [複雑なデプロイメント](./COMPLEX_DEPLOYMENTS.md)
- [アーキテクチャ](./ARCHITECTURE.md)