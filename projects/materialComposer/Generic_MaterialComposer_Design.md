# 汎用MaterialComposer設計書

## 概要
MaterialComposerは、MaterialBankに保存されたSVG素材を柔軟に組み合わせて、複雑なSVG画像を生成する汎用的なコンポーザーです。

## 主な特徴

### 1. レイヤーシステム
- **動的レイヤー構成**: 任意の数のレイヤーを重ね合わせ可能
- **レイヤー属性**:
  - `materialType`: MaterialBankでの素材タイプ（例: "icon", "background", "pattern"）
  - `materialId`: 素材ID
  - `filter`: 適用するフィルター名
  - `opacity`: 透明度（0-100）
  - `transform`: 変換（拡大縮小、回転、移動）

### 2. フィルターシステム
- **プリセットフィルター**: grayscale, blur, brightness, sepia
- **カスタムフィルター**: 動的に追加可能
- **フィルター定義**: SVGフィルター構文で定義

### 3. 変換ルール
- **素材タイプ別ルール**: 特定の素材タイプに対する変換を定義
- **カスタム変換**: レイヤー毎に個別の変換を指定可能

### 4. コンポジションルール
- **キャンバス設定**: 幅、高さ、viewBox
- **背景色**: オプションで背景色を指定

## 使用例

### 基本的な使用
```solidity
Layer[] memory layers = new Layer[](3);
layers[0] = Layer("background", 1, "", 100, "");
layers[1] = Layer("icon", 5, "grayscale", 80, "scale(0.5)");
layers[2] = Layer("effect", 3, "blur", 50, "rotate(45)");

CompositionRule memory rule = CompositionRule(
    "MyComposition",
    800,
    600,
    "0 0 800 600",
    "#ffffff"
);

string memory svg = composer.composeSVG(layers, rule);
```

### カスタムフィルター使用
```solidity
string[] memory customFilters = new string[](1);
customFilters[0] = '<filter id="custom"><feColorMatrix type="hueRotate" values="90"/></filter>';

string memory svg = composer.composeSVGWithFilters(layers, rule, customFilters);
```

## 拡張性

### 新しい素材タイプの追加
MaterialBankに新しい素材タイプを追加するだけで、即座に使用可能

### フィルターの追加
```solidity
composer.setFilter("shadow", '<filter id="shadow">...</filter>');
```

### 変換ルールの追加
```solidity
composer.setTransformRule("icon", "large", "scale(2)");
```

## 利点
1. **汎用性**: 特定の用途に限定されない
2. **柔軟性**: レイヤー数、フィルター、変換を自由に組み合わせ
3. **拡張性**: 新しい機能を簡単に追加
4. **再利用性**: 一度定義した素材を様々な組み合わせで使用

## 今後の拡張案
- マスク機能
- グラデーション定義
- アニメーション対応
- 条件付きレンダリング
- レイヤーグループ化