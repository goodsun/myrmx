# MaterialComposer 仕様書・操作説明書

## 目次
1. [概要](#概要)
2. [システム構成](#システム構成)
3. [基本操作](#基本操作)
4. [高度な使い方](#高度な使い方)
5. [フィルターリファレンス](#フィルターリファレンス)
6. [トラブルシューティング](#トラブルシューティング)

## 概要

MaterialComposerは、オンチェーンに保存されたSVG素材を動的に組み合わせて、複雑なSVG画像を生成するスマートコントラクトです。

### 主な機能
- 複数のSVG素材をレイヤーとして重ね合わせ
- 各レイヤーへのフィルター適用
- 透明度・変換の調整
- カスタムフィルターの定義と使用

### 使用シナリオ
- NFTアートの動的生成
- ロゴ・アイコンの組み合わせ
- パターン・背景の合成
- インタラクティブなビジュアル生成

## システム構成

### 依存関係
```
MaterialComposer
    └── MaterialBank (素材ストレージ)
```

### データ構造

#### Layer構造体
```solidity
struct Layer {
    string materialType;  // 素材タイプ（例: "icon", "background"）
    uint8 materialId;     // 素材ID（0-15）
    string filter;        // フィルター名（例: "grayscale"）
    uint8 opacity;        // 透明度（0-100）
    string transform;     // 変換（例: "scale(2) rotate(45)"）
}
```

#### CompositionRule構造体
```solidity
struct CompositionRule {
    string name;          // コンポジション名
    uint256 width;        // 幅（ピクセル）
    uint256 height;       // 高さ（ピクセル）
    string viewBox;       // SVG viewBox（例: "0 0 100 100"）
    string background;    // 背景色（例: "#ffffff"）
}
```

## 基本操作

### 1. シンプルな2層合成
背景とアイコンを重ねる基本的な例：

```solidity
// レイヤー配列を作成
Layer[] memory layers = new Layer[](2);

// 背景レイヤー
layers[0] = Layer({
    materialType: "background",
    materialId: 0,
    filter: "",
    opacity: 100,
    transform: ""
});

// アイコンレイヤー
layers[1] = Layer({
    materialType: "icon",
    materialId: 3,
    filter: "",
    opacity: 100,
    transform: ""
});

// コンポジションルール
CompositionRule memory rule = CompositionRule({
    name: "BasicComposition",
    width: 512,
    height: 512,
    viewBox: "0 0 100 100",
    background: ""
});

// SVG生成
string memory svg = composer.composeSVG(layers, rule);
```

### 2. フィルター適用
グレースケールフィルターを適用：

```solidity
layers[1] = Layer({
    materialType: "icon",
    materialId: 3,
    filter: "grayscale",  // フィルター指定
    opacity: 100,
    transform: ""
});
```

### 3. 透明度調整
半透明のレイヤーを作成：

```solidity
layers[2] = Layer({
    materialType: "effect",
    materialId: 1,
    filter: "",
    opacity: 50,  // 50%の透明度
    transform: ""
});
```

### 4. 変換適用
拡大・回転・移動：

```solidity
layers[1] = Layer({
    materialType: "icon",
    materialId: 3,
    filter: "",
    opacity: 100,
    transform: "scale(0.5) rotate(45) translate(10, 10)"
});
```

## 高度な使い方

### カスタムフィルターの定義と使用

#### 1. フィルター定義（オーナーのみ）
```solidity
// 色相回転フィルター
composer.setFilter(
    "hueRotate",
    '<filter id="hueRotate"><feColorMatrix type="hueRotate" values="180"/></filter>'
);

// ドロップシャドウ
composer.setFilter(
    "shadow",
    '<filter id="shadow"><feDropShadow dx="2" dy="2" stdDeviation="3"/></filter>'
);
```

#### 2. カスタムフィルターの直接使用
```solidity
string[] memory customFilters = new string[](1);
customFilters[0] = '<filter id="rainbow">
    <feColorMatrix type="matrix" values="
        1 0 0 0 0
        0 0.5 0 0 0.5
        0 0 0.3 0 0.7
        0 0 0 1 0"/>
</filter>';

string memory svg = composer.composeSVGWithFilters(layers, rule, customFilters);
```

### 変換ルールの設定

```solidity
// 特定の素材タイプに対する変換ルール
composer.setTransformRule("icon", "centered", "translate(-50%, -50%)");
composer.setTransformRule("background", "stretched", "scale(1.2)");
```

### 複雑な合成例

#### パララックス効果のある背景
```solidity
Layer[] memory layers = new Layer[](4);

// 遠景
layers[0] = Layer("background", 0, "blur", 100, "scale(1.2)");
// 中景
layers[1] = Layer("background", 1, "", 80, "scale(1.1)");
// 近景
layers[2] = Layer("pattern", 0, "", 100, "");
// メインオブジェクト
layers[3] = Layer("icon", 5, "shadow", 100, "");
```

#### アートワーク生成
```solidity
Layer[] memory layers = new Layer[](6);

// ベース
layers[0] = Layer("shape", 0, "", 100, "");
// パターンオーバーレイ
layers[1] = Layer("pattern", 3, "", 30, "");
// カラーアクセント
layers[2] = Layer("shape", 1, "hueRotate", 70, "scale(0.8)");
// ハイライト
layers[3] = Layer("effect", 0, "", 40, "");
// テクスチャ
layers[4] = Layer("texture", 2, "", 20, "");
// 仕上げ
layers[5] = Layer("effect", 1, "brightness", 60, "");
```

## フィルターリファレンス

### プリセットフィルター

| フィルター名 | 効果 | 使用例 |
|------------|------|-------|
| grayscale | グレースケール化 | モノクロ効果 |
| blur | ぼかし | 背景のぼかし |
| brightness | 明度調整 | ハイライト効果 |
| sepia | セピア調 | ビンテージ効果 |

### カスタムフィルター例

#### コントラスト調整
```xml
<filter id="contrast">
    <feComponentTransfer>
        <feFuncA type="linear" slope="2" intercept="-0.5"/>
    </feComponentTransfer>
</filter>
```

#### エンボス効果
```xml
<filter id="emboss">
    <feConvolveMatrix kernelMatrix="3 0 0 0 0 0 0 0 -3"/>
</filter>
```

#### グロー効果
```xml
<filter id="glow">
    <feGaussianBlur stdDeviation="4" result="coloredBlur"/>
    <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
    </feMerge>
</filter>
```

## トラブルシューティング

### よくある問題と解決方法

#### 1. 素材が表示されない
**原因**: MaterialBankに素材が登録されていない
**解決**: 
```solidity
// 素材の存在確認
require(materialBank.materialExists(materialType, materialId), "Material not found");
```

#### 2. フィルターが適用されない
**原因**: フィルター名の誤り、またはフィルターが未定義
**解決**: 
- 正しいフィルター名を使用
- カスタムフィルターの場合は事前に定義

#### 3. 変換が期待通りでない
**原因**: SVG変換の順序
**解決**: 変換は順序が重要。`scale`→`rotate`→`translate`の順が推奨

#### 4. ガス代が高い
**原因**: レイヤー数が多い、または複雑なフィルター
**解決**: 
- 必要最小限のレイヤー数に抑える
- フィルターを簡素化
- 素材を事前に最適化

### ベストプラクティス

1. **レイヤー数の最適化**: 5層以下を推奨
2. **フィルターの節約**: 必要な箇所のみに適用
3. **素材の最適化**: SVGを事前に圧縮・最適化
4. **変換の計画**: 複雑な変換は事前にテスト
5. **ガス効率**: view関数として呼び出し、結果をキャッシュ

## 付録

### サンプルコード
完全な実装例は `/examples/` ディレクトリを参照

### 関連ドキュメント
- [MaterialBank仕様書](./MaterialBank_Specification.md)
- [SVGフィルターリファレンス](https://developer.mozilla.org/docs/Web/SVG/Element/filter)
- [SVG変換リファレンス](https://developer.mozilla.org/docs/Web/SVG/Attribute/transform)