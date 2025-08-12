# Deployment Best Practices

siegeNginでスマートコントラクトをデプロイする際のベストプラクティスガイドです。

## デプロイ前の準備

### 1. ローカルでのテスト
**必ず最初にローカルネットワークでテストしてください**
```bash
# 別ターミナルでHardhatノードを起動
npx hardhat node
```

### 2. コントラクトの検証
- [ ] コンパイルエラーがないことを確認
- [ ] 単体テストが全て通ることを確認
- [ ] セキュリティ監査（可能であれば）

### 3. ガス最適化
```javascript
// hardhat.config.js
module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
};
```

## ネットワーク別の注意点

### ローカルネットワーク（localhost:8545）
- **用途**: 開発・テスト
- **ガス**: 無制限
- **注意**: Hardhatノードの再起動でデータがリセット

### テストネット（Sepolia、Goerli等）
- **用途**: 本番前の最終テスト
- **ガス**: テスト用ETHが必要
- **注意**: 
  - Faucetから十分なテストETHを取得
  - ネットワーク混雑時はガス価格を調整
  - コントラクトサイズ制限に注意

### メインネット
- **用途**: 本番デプロイ
- **ガス**: 実際のETHが必要
- **重要チェックリスト**:
  - [ ] コントラクトのオーナー権限設定は正しいか
  - [ ] アップグレード可能性の設計は適切か
  - [ ] 初期パラメータは正しいか
  - [ ] 十分なETH残高があるか

## 複雑なデプロイメントの管理

### deploy-config.jsonの活用
```json
{
  "deploymentOrder": [
    {
      "step": 1,
      "contracts": [
        {
          "name": "Token",
          "contract": "MyToken",
          "constructorArgs": ["MyToken", "MTK", 1000000],
          "parallel": false
        }
      ]
    }
  ]
}
```

### 依存関係の明確化
- 各ステップで必要なコントラクトアドレスを明確に
- `{"ref": "Contract.address"}`を使用して参照
- 循環依存を避ける

## ガス料金の最適化

### 1. コントラクトサイズの削減
```solidity
// 使用しない機能は削除
// 修飾子やライブラリで共通処理をまとめる
library CommonValidations {
    function validateAddress(address addr) internal pure {
        require(addr != address(0), "Invalid address");
    }
}
```

### 2. ストレージの最適化
```solidity
// パッキングを活用
contract Optimized {
    uint128 public value1;  // スロット1
    uint128 public value2;  // スロット1（同じスロット）
    uint256 public value3;  // スロット2
}
```

### 3. バッチ処理
```solidity
// 複数の操作をまとめる
function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external {
    require(recipients.length == amounts.length, "Length mismatch");
    for (uint i = 0; i < recipients.length; i++) {
        _transfer(msg.sender, recipients[i], amounts[i]);
    }
}
```

## セキュリティチェックリスト

### デプロイ前
- [ ] Reentrancy攻撃への対策
- [ ] Integer overflow/underflowの確認（Solidity 0.8.0未満の場合）
- [ ] Access controlの実装
- [ ] 外部呼び出しの検証

### デプロイ後
- [ ] コントラクトの所有権が正しく設定されているか
- [ ] 必要に応じて所有権を放棄（renounceOwnership）
- [ ] Etherscanでのverify（該当する場合）

## トラブルシューティング

### "Out of gas"エラー
1. ガスリミットを増やす
2. コントラクトロジックを最適化
3. 大きなデータは分割してデプロイ

### "Contract size exceeds limit"エラー
1. 不要な機能を削除
2. ライブラリとして分離
3. プロキシパターンの使用を検討

### "Nonce too low"エラー
1. MetaMaskの「Settings > Advanced > Reset Account」
2. ページをリロード
3. 再度デプロイを試行

## デプロイ後の管理

### 1. アドレスの記録
```javascript
// deployed-addresses.json
{
  "mainnet": {
    "Token": "0x...",
    "Governor": "0x..."
  },
  "sepolia": {
    "Token": "0x...",
    "Governor": "0x..."
  }
}
```

### 2. ABIの保管
- GitHubリポジトリにコミット
- IPFSに保存
- 開発者ドキュメントに含める

### 3. モニタリング
- イベントログの監視設定
- 異常なトランザクションのアラート
- 定期的な状態確認

## 緊急時の対応

### 問題が発生した場合
1. **即座に一時停止機能を実行**（実装されている場合）
2. **コミュニティへの通知**
3. **原因の調査と対策の検討**
4. **必要に応じて新バージョンのデプロイ**

### バックアッププラン
- アップグレード可能な設計の採用
- 緊急時の連絡体制の確立
- インシデント対応手順の文書化

## まとめ

siegeNginを使用することで、複雑なデプロイメントも安全かつ効率的に実行できます。
しかし、ツールに頼りすぎず、常にセキュリティとベストプラクティスを意識することが重要です。

**Remember**: "Measure twice, deploy once"（二度測って、一度デプロイ）