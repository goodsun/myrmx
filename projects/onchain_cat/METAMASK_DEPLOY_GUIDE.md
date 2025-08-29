# MetaMaskでのデプロイガイド

## 問題: Internal JSON-RPC Error

プライベートノードでは成功するが、MetaMask経由でエラーが出る場合の対処法。

## MetaMask設定の確認

### 1. ネットワーク設定
MetaMaskでローカルネットワークの設定を確認：
- **RPC URL**: http://localhost:8545
- **チェーンID**: 1337
- **通貨記号**: ETH

### 2. アカウントの確認
- 十分なETH残高があるか確認
- ガス代として最低でも1 ETH以上推奨

## デプロイ時の推奨設定

### 方法1: MetaMaskの詳細設定を使用

1. MetaMaskでトランザクション確認画面が出たら「編集」をクリック
2. 以下の値に手動で設定：
   - **ガスリミット**: 20000000 (2000万)
   - **優先度**: 「高」を選択

### 方法2: フロントエンドでガス設定を明示

```javascript
// app.jsやデプロイスクリプトで
const contract = await contractFactory.deploy({
  gasLimit: 20000000, // 20M
  gasPrice: ethers.utils.parseUnits('20', 'gwei'), // 固定ガス価格
  nonce: await signer.getTransactionCount() // nonce明示
});
```

## トラブルシューティング

### 1. MetaMaskをリセット
設定 → 詳細 → アカウントのリセット

### 2. ローカルノードの再起動
```bash
# 一度停止して
npx hardhat node --max-memory 4096
```

### 3. 別のアプローチ: 段階的デプロイ

BackBank2が特に問題なら：
1. 他のコントラクトを先にデプロイ
2. BackBank2だけ個別にデプロイ
3. 必要に応じてBackBank2を分割

### 4. ガス推定を無効化

```javascript
// MetaMask経由のデプロイで
const overrides = {
  gasLimit: 25000000, // 固定値
  gasPrice: ethers.utils.parseUnits('50', 'gwei'),
  type: 0 // レガシートランザクション
};

const contract = await factory.deploy(overrides);
```

## 代替案: スクリプトデプロイ

MetaMaskでの問題が続く場合は、秘密鍵を使った直接デプロイ：

1. `.env`ファイルに秘密鍵を設定
2. hardhatスクリプトでデプロイ
3. デプロイ後、MetaMaskにコントラクトアドレスをインポート

```bash
npx hardhat run scripts/deploy_all.js --network localhost
```

## 推奨事項

1. **まず小さいコントラクトでテスト** - FrontBank1など
2. **ガスリミットは大きめに** - 推定値の2倍程度
3. **トランザクションタイプ** - Type 0（レガシー）を使用
4. **順次デプロイ** - 並列ではなく1つずつ

## BackBank2特有の対策

BackBank2は20.92KBと大きいため：
- ガスリミット: 25,000,000
- 単独でデプロイ
- 他のトランザクションと競合しないように