# Onchain Cat NFT System Design

## 概要
10種類×4レイヤーで10,000通りのユニークなピクセルアート猫NFTを生成する**フルオンチェーン**システム

## 決定事項
- **アーキテクチャ**: フルオンチェーン（Tragedyプロジェクト方式）
- **ミント方式**: 完全ランダム（決定的シャッフルアルゴリズム）
- **価格**: オーナーが可変設定
- **コレクション規模**: 10,000個全て
- **拡張性**: なし（固定仕様）

## 素材構成（各10種類）
- **Back**: 背景パターン（10種）
- **Main**: 猫の種類（10種）
- **Item**: アクセサリー（10種）
- **Front**: 持ち物（10種）

合計: 10 × 10 × 10 × 10 = 10,000通り

## コントラクトアーキテクチャ（6層構造）

### Layer 1: データバンク（SVGストレージ）
```
├── BackBank1       - 背景SVG 0-4
├── BackBank2       - 背景SVG 5-9
├── MainBank1       - 猫SVG 0-4
├── MainBank2       - 猫SVG 5-9
├── ItemBank1       - アクセサリSVG 0-4
├── ItemBank2       - アクセサリSVG 5-9
├── FrontBank1      - 持ち物SVG 0-4
└── FrontBank2      - 持ち物SVG 5-9
```

### Layer 2: アグリゲータバンク
```
├── BackBank        - BackBank1/2へのルーティング
├── MainBank        - MainBank1/2へのルーティング
├── ItemBank        - ItemBank1/2へのルーティング
└── FrontBank       - FrontBank1/2へのルーティング
```

### Layer 3: コンポーザー
```
└── CatComposer     - 4レイヤーのSVG合成
```

### Layer 4: メタデータジェネレータ
```
└── CatMetadata     - JSONメタデータ生成
```

### Layer 5: プロキシ
```
└── MetadataBank    - メタデータアクセス用プロキシ
```

### Layer 6: NFTコントラクト
```
└── OnchainCat      - ERC721実装とミントロジック
```

## 決定的シャッフルアルゴリズム

```solidity
// Linear Congruential Generator (LCG)
uint256 public constant SHUFFLE_SEED = 8901; // 猫用のシード値
uint256 shuffled = ((tokenId - 1) * SHUFFLE_SEED + 1) % 10000;

// 各桁から属性を取得（0-9の値）
uint8 front = uint8(shuffled % 10);
uint8 item = uint8((shuffled / 10) % 10);
uint8 main = uint8((shuffled / 100) % 10);
uint8 back = uint8((shuffled / 1000) % 10);
```

## SVGデータ構造

### 個別SVG（純粋関数として実装）
```solidity
contract MainBank1 {
    function getTabby() external pure returns (string memory) {
        return '<g id="main"><!-- tabby cat SVG data --></g>';
    }
    // ... 他の猫種
}
```

### 合成SVG構造
```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="384" height="384">
    <!-- Layer 1: Background -->
    <g id="back">...</g>
    <!-- Layer 2: Main Cat -->
    <g id="main">...</g>
    <!-- Layer 3: Item (Accessory) -->
    <g id="item">...</g>
    <!-- Layer 4: Front (Held Item) -->
    <g id="front">...</g>
</svg>
```

## メタデータ構造

### 名前生成ルール
```
"OnchainCats #[tokenId]"
例: "OnchainCats #1234"
```

### 説明生成ルール
各素材に対して詳細な説明を定義し、動的に組み合わせて生成。

### 素材説明マッピング

#### Background (背景)
- baby_blue_gingham: "a soft baby blue gingham pattern"
- checkerboard: "a classic black and white checkerboard"
- checkered: "a checkered racing flag pattern"
- cloud_pattern: "fluffy white clouds"
- gingham: "a traditional red gingham pattern"
- houndstooth: "an elegant houndstooth pattern"
- polka_dots: "playful polka dots"
- stars: "a starry night sky"
- stripes: "bold diagonal stripes"
- tartan: "a traditional Scottish tartan"

#### Main (猫の種類)
- blue: "A blue-colored Abyssinian cat"
- buchi: "A spotted Japanese bobtail cat"
- hachiware: "A black and white tuxedo cat"
- kuro: "A sleek black cat with golden eyes"
- mike: "A calico cat with orange, black and white patches"
- robo: "A mechanical robot cat"
- scottish_fold: "A Scottish Fold with adorable folded ears"
- siamese: "A Siamese cat with distinctive color points"
- sphinx: "A hairless Sphinx cat"
- tabby: "A classic brown tabby cat"

#### Item (アクセサリー)
- bell: "wearing a golden bell collar"
- box: "sitting in a cardboard box"
- cap: "sporting a baseball cap"
- flower: "adorned with a flower crown"
- gasmask: "equipped with a protective gas mask"
- hat: "wearing a stylish top hat"
- ribbon: "decorated with a silk ribbon"
- stoll: "wrapped in a cozy scarf"
- suit: "dressed in a formal suit"
- sunglass: "looking cool in sunglasses"

#### Front (持ち物)
- apple: "holding a fresh red apple"
- mouse: "playing with a toy mouse"
- dry_food: "munching on dry cat food"
- fish: "proudly displaying a caught fish"
- flower: "presenting a beautiful flower"
- herb: "carrying fresh catnip"
- liquor: "with a bottle of sake"
- meat: "feasting on a piece of meat"
- onigiri: "holding a rice ball"
- rice: "with a bowl of rice"

### 説明テンプレート
```
"[Main description], [Item description], [Front description], set against [Background description]."
```

### JSONメタデータ例
```json
{
    "name": "OnchainCats #1234",
    "description": "A classic brown tabby cat, wearing a golden bell collar, proudly displaying a caught fish, set against a traditional red gingham pattern.",
    "image": "data:image/svg+xml;base64,...",
    "attributes": [
        {"trait_type": "Background", "value": "Gingham"},
        {"trait_type": "Cat", "value": "Tabby"},
        {"trait_type": "Accessory", "value": "Bell"},
        {"trait_type": "Item", "value": "Fish"}
    ]
}
```

## Virtual Ownership実装（採用）

```solidity
contract OnchainCat is ERC721Enumerable, Ownable {
    uint256 public constant TOTAL_SUPPLY = 10000;
    mapping(uint256 => address) private _virtualOwners;
    
    constructor() ERC721("OnchainCats", "OCAT") {
        // Virtual Ownership: 実際のミントは購入時に行う
    }
    
    function totalSupply() public pure override returns (uint256) {
        return TOTAL_SUPPLY;
    }
    
    function exists(uint256 tokenId) public pure returns (bool) {
        return tokenId >= 1 && tokenId <= TOTAL_SUPPLY;
    }
    
    function ownerOf(uint256 tokenId) public view override returns (address) {
        require(exists(tokenId), "Token does not exist");
        address virtualOwner = _virtualOwners[tokenId];
        // 未販売の場合はコントラクトオーナーが所有
        return virtualOwner == address(0) ? owner() : virtualOwner;
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        // 初回転送時（購入時）に実際のミントを行う
        if (from == address(0) && _virtualOwners[tokenId] == address(0)) {
            super._beforeTokenTransfer(from, to, tokenId);
        }
        _virtualOwners[tokenId] = to;
    }
    
    function tokenByIndex(uint256 index) public pure override returns (uint256) {
        require(index < TOTAL_SUPPLY, "Index out of bounds");
        return index + 1; // tokenId は 1 から開始
    }
    
    function tokenOfOwnerByIndex(address owner, uint256 index) 
        public view override returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 1; i <= TOTAL_SUPPLY; i++) {
            if (ownerOf(i) == owner) {
                if (count == index) return i;
                count++;
            }
        }
        revert("Index out of bounds");
    }
}
```

## 価格管理システム

```solidity
contract OnchainCat {
    uint256 public price = 0.01 ether; // 初期価格
    
    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }
    
    function buy(uint256 tokenId) public payable {
        require(ownerOf(tokenId) == owner(), "Not for sale");
        require(msg.value >= price, "Insufficient payment");
        
        // 余剰分は自動返金
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
        
        // NFTを購入者に転送
        _transfer(owner(), msg.sender, tokenId);
    }
}

## デプロイ戦略

### Phase 1: データバンクのデプロイ（並列可能）
```
npm run deploy:backbanks
npm run deploy:mainbanks
npm run deploy:itembanks
npm run deploy:frontbanks
```

### Phase 2: アグリゲータのデプロイ
```
npm run deploy:aggregators
```

### Phase 3: コンポーザーとメタデータ
```
npm run deploy:composer
npm run deploy:metadata
```

### Phase 4: プロキシとNFT
```
npm run deploy:proxy
npm run deploy:nft
```

## ガス最適化戦略

1. **Pure関数**: SVGデータはstorageではなくpure関数で返す
2. **バッチデプロイ**: 独立したコントラクトは並列デプロイ
3. **効率的な文字列結合**: `abi.encodePacked`使用
4. **View関数**: メタデータ生成はview関数（ユーザーのガス負担なし）

## 実装タイムライン

### Week 1: 基盤開発
- [ ] データバンクコントラクト実装
- [ ] SVGデータの最適化とエンコード
- [ ] アグリゲータ実装

### Week 2: 合成システム
- [ ] CatComposer実装
- [ ] メタデータジェネレータ実装
- [ ] シャッフルアルゴリズムのテスト

### Week 3: NFTとデプロイ
- [ ] OnchainCat（ERC721）実装
- [ ] デプロイスクリプト作成
- [ ] テストネットデプロイ

### Week 4: 最終調整
- [ ] ガス最適化
- [ ] セキュリティ監査
- [ ] メインネットデプロイ準備