# Troubleshooting Guide

siegeNginの使用中に発生する可能性のある問題と解決方法をまとめています。

## 目次
- [起動時の問題](#起動時の問題)
- [MetaMask関連](#metamask関連)
- [コンパイルエラー](#コンパイルエラー)
- [デプロイエラー](#デプロイエラー)
- [UI/表示の問題](#ui表示の問題)
- [パフォーマンス問題](#パフォーマンス問題)

## 起動時の問題

### サーバーが起動しない

**エラー**: `Error: listen EADDRINUSE: address already in use :::3000`

**解決方法**:
```bash
# ポート3000を使用しているプロセスを確認
lsof -i :3000

# プロセスを終了
kill -9 <PID>

# または別のポートで起動
PORT=3001 npm start
```

### プロジェクトが表示されない

**原因**: プロジェクトディレクトリの権限問題

**解決方法**:
```bash
# 権限を確認
ls -la projects/

# 読み取り権限を付与
chmod -R 755 projects/
```

## MetaMask関連

### MetaMaskが接続できない

**チェックリスト**:
1. MetaMaskがインストールされているか
2. 正しいネットワークに接続しているか
3. サイトへの接続が許可されているか

**解決方法**:
```javascript
// MetaMaskの手動接続
// ブラウザコンソールで実行
await window.ethereum.request({ method: 'eth_requestAccounts' });
```

### "User rejected the request"エラー

**原因**: ユーザーが接続を拒否

**解決方法**:
1. MetaMaskの「接続済みサイト」を確認
2. localhost:3000への接続を許可
3. ページをリロードして再接続

### ネットワーク切り替えができない

**解決方法**:
1. MetaMaskで手動でネットワークを追加
```javascript
// Hardhat Localhost設定
Network Name: Hardhat Localhost
RPC URL: http://127.0.0.1:8545
Chain ID: 1337
Currency Symbol: ETH
```

## コンパイルエラー

### "Cannot find module '@openzeppelin/contracts'"

**解決方法**:
```bash
cd projects/your-project
npm install @openzeppelin/contracts
```

### "Stack too deep"エラー

**解決方法**:
```javascript
// hardhat.config.js
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      viaIR: true  // IR-based code generation
    }
  }
};
```

### Solidity バージョンエラー

**エラー**: `Source file requires different compiler version`

**解決方法**:
1. `hardhat.config.js`のSolidityバージョンを確認
2. コントラクトのpragmaと一致させる
3. 必要に応じて複数バージョンを設定：

```javascript
module.exports = {
  solidity: {
    compilers: [
      { version: "0.8.19" },
      { version: "0.8.20" }
    ]
  }
};
```

## デプロイエラー

### Gas estimation failed

**エラー**: `cannot estimate gas; transaction may fail or may require manual gas limit`

**一般的な原因**:
1. コンストラクタの引数が間違っている
2. コントラクトのロジックエラー
3. 不十分な残高

**解決方法**:
```javascript
// ガスリミットを手動設定
const tx = await contract.deploy({
  gasLimit: 3000000
});
```

### "Nonce too low"エラー

**解決方法**:
1. MetaMaskの設定 → 詳細 → アカウントをリセット
2. ページをリロード
3. 再度デプロイ

### "Insufficient funds"エラー

**解決方法**:
1. アカウントの残高を確認
2. テストネットの場合、Faucetから取得
3. ローカルの場合、Hardhatノードを再起動

### OwnableInvalidOwnerエラー (0x1e4fbdf7)

**原因**: OpenZeppelin v5のOwnable実装の変更

**解決方法**:
```solidity
// コンストラクタで明示的にオーナーを設定
constructor() Ownable(msg.sender) {
    // ...
}
```

## UI/表示の問題

### 複雑なデプロイメントUIが表示されない

**原因**: `deploy-config.json`が認識されていない

**解決方法**:
1. `deploy-config.json`がプロジェクトルートにあるか確認
2. JSONの構文エラーをチェック
3. ブラウザコンソールでエラーを確認

### コントラクトリストが空

**チェックリスト**:
- [ ] コンパイルが成功しているか
- [ ] `artifacts`ディレクトリが生成されているか
- [ ] サーバーが正常に動作しているか

### ボタンが反応しない

**解決方法**:
1. ブラウザのDevToolsでエラーを確認
2. キャッシュをクリア（Ctrl+F5）
3. 別のブラウザで試す

## パフォーマンス問題

### コンパイルが遅い

**最適化方法**:
1. 不要な依存関係を削除
```bash
npm prune
```

2. キャッシュをクリア
```bash
npx hardhat clean
```

3. 並列コンパイルを有効化
```javascript
// hardhat.config.js
module.exports = {
  solidity: {
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
};
```

### UIの反応が遅い

**原因と対策**:
1. **大量のコントラクト**: ページネーション実装を検討
2. **メモリリーク**: ページをリロード
3. **ネットワーク遅延**: RPCエンドポイントを変更

## よくある質問（FAQ）

### Q: プロジェクト間でコントラクトを共有できますか？
A: はい、Shared Contracts機能を使用してください。詳細は[CROSS_PROJECT_IMPORTS.md](./CROSS_PROJECT_IMPORTS.md)を参照。

### Q: デプロイ履歴は保存されますか？
A: 現在のバージョンではセッション中のみ保持されます。永続化機能は開発中です。

### Q: 複数のウォレットアカウントを切り替えられますか？
A: MetaMaskでアカウントを切り替えた後、ページをリロードしてください。

### Q: カスタムネットワークを追加できますか？
A: プロジェクトの`hardhat.config.js`にネットワーク設定を追加してください。

## デバッグ方法

### ブラウザコンソールの活用
```javascript
// 現在の状態を確認
console.log('Selected Project:', selectedProject);
console.log('Deployment Config:', deploymentConfig);
console.log('Deployed Addresses:', deployedAddresses);
```

### ネットワークリクエストの確認
1. DevTools → Network タブ
2. 失敗したリクエストを特定
3. レスポンスの詳細を確認

### サーバーログの確認
```bash
# サーバー起動時に詳細ログを表示
DEBUG=* npm start
```

## サポート

問題が解決しない場合：

1. **GitHubイシューを作成**: 詳細なエラーメッセージとステップを記載
2. **コミュニティに質問**: Discord/Telegramチャンネル
3. **ドキュメントを確認**: 最新の更新情報をチェック

**重要**: セキュリティに関わる問題を発見した場合は、公開イシューではなく、プライベートに報告してください。