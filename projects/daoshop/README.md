# DAOShop

商品管理用のスマートコントラクト

## 概要

DAOShopは、ERC721ベースの商品管理システムです。各商品はNFTとして発行され、商品情報の更新・削除は登録者のみが行えます。

## 機能

- **商品登録** (`createItem`): 新規商品をNFTとして発行
- **商品更新** (`updateItem`): 登録者のみ商品情報を更新可能
- **商品削除** (`burnItem`): 登録者のみ商品を削除可能
- **商品照会** (`getItem`): 商品情報を取得

## 商品情報構造

```solidity
struct ItemInfo {
    string title;       // 商品名
    string tokenInfo;   // <contractAddress>/<tokenId>
    string contact;     // 連絡先 URL/メールアドレス等
    string price;       // 販売価格・単位込み
    string status;      // 予約受付中・販売中・非表示・売切など
    address creator;    // 商品登録者
}
```

## 開発環境

- Solidity 0.8.19
- Hardhat
- OpenZeppelin Contracts 4.9.6

## セットアップ

```bash
npm install
npx hardhat compile
npx hardhat test
```

## デプロイ

```bash
npx hardhat run scripts/deploy.js --network [ネットワーク名]
```