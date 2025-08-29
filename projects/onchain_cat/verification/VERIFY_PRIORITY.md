# Etherscan Verification優先順位ガイド

## 概要

OnchainCatsプロジェクトには多数のコントラクトがありますが、すべてをverifyする必要はありません。
以下、優先順位に基づいたverification推奨リストです。

## 🔴 必須（High Priority）

これらのコントラクトは必ずverifyすべきです：

### 1. **OnchainCats** （メインNFTコントラクト）
- **理由**: ユーザーが直接やり取りするメインコントラクト
- **機能**: NFTのmint、transfer、管理
- **重要度**: ★★★★★

### 2. **CatMetadata** 
- **理由**: NFTのメタデータとSVG画像を生成
- **機能**: tokenURIの生成、画像のレンダリング
- **重要度**: ★★★★★

## 🟡 推奨（Medium Priority）

透明性のためにverifyすることを推奨：

### 3. **CatComposer**
- **理由**: SVGパーツを組み合わせて画像を生成
- **機能**: 各パーツの組み合わせロジック
- **重要度**: ★★★★☆

### 4. **Aggregatorコントラクト** (BackBank, MainBank, ItemBank, FrontBank)
- **理由**: Bank統合の中核となるコントラクト
- **機能**: 各Bankコントラクトへのルーティング
- **重要度**: ★★★☆☆

## 🟢 任意（Low Priority）

必要に応じてverify：

### 5. **個別Bankコントラクト** (BackBank1-3, MainBank1-2, ItemBank1-2, FrontBank1-2)
- **理由**: SVGデータを保持するだけの静的コントラクト
- **機能**: SVGパーツのストレージ
- **重要度**: ★★☆☆☆

## Verification戦略

### フェーズ1: 必須コントラクトのみ
```
1. OnchainCats
2. CatMetadata
```

### フェーズ2: 推奨コントラクトを追加
```
3. CatComposer
4. BackBank, MainBank, ItemBank, FrontBank
```

### フェーズ3: 完全性を求める場合
```
5. すべてのBankコントラクト（9個）
```

## コスト削減のヒント

- **最小限アプローチ**: OnchainCatsとCatMetadataのみ（2コントラクト）
- **バランス型**: 上記2つ + CatComposer（3コントラクト）
- **完全型**: すべて（16コントラクト）

## 技術的な考慮事項

1. **Bankコントラクト**は純粋なデータストレージなので、セキュリティリスクは低い
2. **ユーザーインタラクション**があるコントラクトを優先
3. **資金管理**に関わるコントラクトは最優先（OnchainCats）

## 推奨アクション

Polygonメインネットデプロイ時は：
1. まず**OnchainCats**と**CatMetadata**をverify
2. ユーザーからの要望があれば他のコントラクトも追加でverify
3. プロジェクトの成長に応じて段階的にverify範囲を拡大

---

**注**: Bankコントラクトは静的なSVGデータのみを含むため、コードを読めばその内容は明らかです。
セキュリティ監査の観点からは、ユーザーが直接操作するコントラクトのverifyが最も重要です。