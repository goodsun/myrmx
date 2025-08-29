# ガス代最適化ガイド

## 問題: MetaMask Internal JSON-RPC Error

BackBank2のデプロイ時にエラーが発生する場合の対処法です。

## 解決策

### 1. Hardhat設定でガスリミットを増加

`hardhat.config.js`に以下を追加済み：
```javascript
networks: {
  hardhat: {
    chainId: 1337,
    gas: 30000000, // 30M gas limit
    blockGasLimit: 30000000,
    allowUnlimitedContractSize: true
  },
  localhost: {
    url: "http://127.0.0.1:8545",
    gas: 30000000, // 30M gas limit
    blockGasLimit: 30000000
  }
}
```

### 2. デプロイスクリプトでコントラクト別ガス設定

`scripts/deploy-config.js`で各コントラクトに適切なガスリミットを設定：
```javascript
contractGasOverrides: {
  "BackBank2": { gasLimit: 25000000 }, // 25M gas - 特に大きい
  // 他のコントラクト...
}
```

### 3. ローカルノードの起動オプション

Hardhatノードを以下のオプションで起動：
```bash
npx hardhat node --max-memory 4096
```

### 4. MetaMaskの設定

1. MetaMaskの詳細設定で「高度なガス管理」を有効化
2. トランザクション時に「編集」をクリック
3. ガスリミットを手動で増やす（例：20,000,000）

## 推奨手順

1. **まずローカルでテスト**
   ```bash
   npx hardhat run scripts/deploy_all.js --network localhost
   ```

2. **個別にデプロイ**
   問題のあるコントラクトだけを個別にデプロイ：
   ```bash
   npx hardhat run scripts/deploy-single.js --network localhost
   ```

3. **コントラクトサイズの確認**
   ```bash
   npx hardhat size-contracts
   ```

## 根本的な解決策

もしコントラクトが24KB制限を超えている場合：
1. SVGデータを外部ストレージに移動
2. IPFSやArweaveを使用
3. オンチェーンとオフチェーンのハイブリッド構成

## デバッグ情報

エラーが続く場合は以下を確認：
- コントラクトのバイトコードサイズ
- ローカルノードのメモリ使用量
- MetaMaskのネットワーク設定