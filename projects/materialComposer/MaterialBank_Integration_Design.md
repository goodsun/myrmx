# MaterialComposer - MaterialBank統合設計書

## 概要
現在MaterialComposerが依存している4つの個別Bank契約（MonsterBank、BackgroundBank、ItemBank、EffectBank）を、単一のMaterialBank契約に統合する。

## 現状の課題
- 4つの個別Bank契約を管理する必要があり、デプロイ・管理が複雑
- 各Bankで同様の機能が重複実装されている可能性
- MaterialBank契約が存在するが活用されていない

## 設計方針

### 1. MaterialBankの拡張

#### 1.1 マテリアルタイプの定義
```solidity
// MaterialBank.sol に追加
uint256 public constant MATERIAL_TYPE_MONSTER = 0;
uint256 public constant MATERIAL_TYPE_BACKGROUND = 1;
uint256 public constant MATERIAL_TYPE_ITEM = 2;
uint256 public constant MATERIAL_TYPE_EFFECT = 3;
```

#### 1.2 データ構造
既存のMaterialBank構造をそのまま活用：
```solidity
struct Material {
    string name;       // マテリアル名
    string attribute;  // 属性情報（モンスターの種族、背景の種類など）
    string image;      // SVGデータ
    bool exists;       // 存在フラグ
}

mapping(uint256 => mapping(uint256 => Material)) public materials;
// materials[materialType][id] = Material
```

### 2. MaterialComposerの改修

#### 2.1 契約参照の変更
```solidity
// 変更前
IMonsterBank public monsterBank;
IBackgroundBank public backgroundBank;
IItemBank public itemBank;
IEffectBank public effectBank;

// 変更後
IMaterialBank public materialBank;
```

#### 2.2 コンストラクタの変更
```solidity
// 変更前
constructor(
    address _monsterBank,
    address _backgroundBank,
    address _itemBank,
    address _effectBank
)

// 変更後
constructor(address _materialBank)
```

#### 2.3 データ取得メソッドの統一

##### 変更前の各メソッド：
```solidity
function getMonsterImage(uint256 _monsterId) internal view returns (string memory)
function getBackgroundImage(uint256 _backgroundId) internal view returns (string memory)
function getItemImage(uint256 _itemId) internal view returns (string memory)
function getEffectImage(uint256 _effectId) internal view returns (string memory)
```

##### 変更後の統一メソッド：
```solidity
function getMaterialImage(uint256 _materialType, uint256 _id) internal view returns (string memory) {
    (,,string memory image,) = materialBank.getMaterial(_materialType, _id);
    return image;
}
```

#### 2.4 属性取得の統一
```solidity
// モンスターの種族取得
function getMonsterSpecies(uint256 _monsterId) internal view returns (uint256) {
    (,string memory attribute,,) = materialBank.getMaterial(MATERIAL_TYPE_MONSTER, _monsterId);
    return parseUint(attribute); // attribute文字列を数値に変換
}
```

### 3. 機能の維持

#### 3.1 カラーフィルター機能
- 背景タイプに基づくHSLフィルターの仕組みは完全に維持
- `getColorFilter()`関数は変更なし

#### 3.2 シナジー変換ロジック
- モンスター種族とアイテムの組み合わせによる変換は維持
- `getDisplayItem()`関数のロジックは保持

#### 3.3 SVG合成処理
- レイヤー構造（背景→モンスター→アイテム→エフェクト）は維持
- `composeSVG()`と`composeSVGWithSynergy()`の基本構造は保持

### 4. マイグレーション計画

#### フェーズ1: MaterialBankの準備
1. MaterialBankに定数を追加
2. 4種類のマテリアルタイプのデータを登録
   - Monster: id 0-15, attribute = species番号
   - Background: id 0-9, attribute = 背景タイプ名
   - Item: id 0-11, attribute = アイテムタイプ
   - Effect: id 0-15, attribute = エフェクトタイプ

#### フェーズ2: MaterialComposerの改修
1. 新しいMaterialComposer契約をデプロイ
2. MaterialBankアドレスを指定して初期化
3. 動作確認とテスト

### 5. 互換性とインターフェース

#### 5.1 外部インターフェース
`composeSVG()`関数のシグネチャは変更なし：
```solidity
function composeSVG(
    uint256 _backgroundId,
    uint256 _monsterId,
    uint256 _itemId,
    uint256 _effectId
) external view returns (string memory)
```

#### 5.2 内部実装の変更点
- Bank参照が4つから1つに削減
- データ取得が統一的なインターフェースに

### 6. メリット

1. **管理の簡素化**: 4つの契約から1つに削減
2. **デプロイコストの削減**: 契約数が減少
3. **一貫性の向上**: 統一的なデータ管理
4. **拡張性**: 新しいマテリアルタイプの追加が容易

### 7. リスクと対策

#### リスク
- データ移行時のミス
- 既存機能の破損

#### 対策
- 十分なテストの実施
- 段階的な移行
- 旧契約の保持（ロールバック用）

### 8. テスト計画

1. **単体テスト**
   - MaterialBankの各マテリアルタイプのCRUD操作
   - MaterialComposerの各関数の動作確認

2. **統合テスト**
   - SVG合成の完全性確認
   - シナジー変換の動作確認
   - カラーフィルターの適用確認

3. **パフォーマンステスト**
   - ガスコストの比較
   - 応答速度の確認

## まとめ
この統合により、契約の管理が大幅に簡素化され、将来的な拡張も容易になる。既存の機能は完全に維持されるため、ユーザー体験への影響はない。