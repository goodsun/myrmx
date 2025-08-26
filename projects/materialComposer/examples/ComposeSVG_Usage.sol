// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contracts/MaterialComposer.sol";

contract ComposeSVGExample {
    MaterialComposer public composer;
    
    constructor(address _composer) {
        composer = MaterialComposer(_composer);
    }
    
    // 例1: シンプルな2層構成
    function simpleComposition() external view returns (string memory) {
        MaterialComposer.Layer[] memory layers = new MaterialComposer.Layer[](2);
        
        // 背景レイヤー
        layers[0] = MaterialComposer.Layer({
            materialType: "background",  // MaterialBankに登録したタイプ
            materialId: 0,               // そのタイプ内のID
            filter: "",                  // フィルターなし
            opacity: 100,                // 100%不透明
            transform: ""                // 変換なし
        });
        
        // アイコンレイヤー
        layers[1] = MaterialComposer.Layer({
            materialType: "icon",
            materialId: 5,
            filter: "",
            opacity: 100,
            transform: "scale(0.8)"      // 80%に縮小
        });
        
        // キャンバス設定
        MaterialComposer.CompositionRule memory rule = MaterialComposer.CompositionRule({
            name: "MyIcon",
            width: 512,                  // 出力サイズ 512x512px
            height: 512,
            viewBox: "0 0 100 100",      // SVG座標系 100x100
            background: "#f0f0f0"        // 薄いグレー背景
        });
        
        return composer.composeSVG(layers, rule);
    }
    
    // 例2: フィルター付き複雑な構成
    function complexComposition() external view returns (string memory) {
        MaterialComposer.Layer[] memory layers = new MaterialComposer.Layer[](4);
        
        // レイヤー1: 背景（ぼかし効果）
        layers[0] = MaterialComposer.Layer({
            materialType: "pattern",
            materialId: 2,
            filter: "blur",              // ぼかしフィルター
            opacity: 80,                 // 80%不透明
            transform: "scale(1.2)"
        });
        
        // レイヤー2: メインオブジェクト
        layers[1] = MaterialComposer.Layer({
            materialType: "shape",
            materialId: 1,
            filter: "",
            opacity: 100,
            transform: "translate(10, 10)"  // 右下に10単位移動
        });
        
        // レイヤー3: 装飾（グレースケール）
        layers[2] = MaterialComposer.Layer({
            materialType: "decoration",
            materialId: 3,
            filter: "grayscale",         // グレースケールフィルター
            opacity: 60,
            transform: "rotate(45)"      // 45度回転
        });
        
        // レイヤー4: エフェクト（半透明）
        layers[3] = MaterialComposer.Layer({
            materialType: "effect",
            materialId: 0,
            filter: "brightness",        // 明度フィルター
            opacity: 40,                 // 40%半透明
            transform: ""
        });
        
        MaterialComposer.CompositionRule memory rule = MaterialComposer.CompositionRule({
            name: "ComplexArt",
            width: 800,
            height: 600,
            viewBox: "0 0 200 150",      // 横長のviewBox
            background: ""               // 背景色なし（透明）
        });
        
        return composer.composeSVG(layers, rule);
    }
    
    // 例3: カスタムフィルター使用
    function customFilterComposition() external view returns (string memory) {
        MaterialComposer.Layer[] memory layers = new MaterialComposer.Layer[](2);
        
        layers[0] = MaterialComposer.Layer({
            materialType: "background",
            materialId: 0,
            filter: "custom1",           // カスタムフィルター名
            opacity: 100,
            transform: ""
        });
        
        layers[1] = MaterialComposer.Layer({
            materialType: "logo",
            materialId: 1,
            filter: "",
            opacity: 90,
            transform: "scale(0.5) translate(50, 50)"  // 複数の変換
        });
        
        MaterialComposer.CompositionRule memory rule = MaterialComposer.CompositionRule({
            name: "LogoWithEffect",
            width: 256,
            height: 256,
            viewBox: "0 0 100 100",
            background: "#ffffff"
        });
        
        // カスタムフィルター定義
        string[] memory customFilters = new string[](1);
        customFilters[0] = '<filter id="custom1"><feColorMatrix type="hueRotate" values="90"/></filter>';
        
        return composer.composeSVGWithFilters(layers, rule, customFilters);
    }
}

/*
使い方のポイント：

1. Layer構造体の各フィールド:
   - materialType: MaterialBankに登録した素材タイプ名（"icon", "background"など）
   - materialId: そのタイプ内の素材ID（0-15）
   - filter: 適用するフィルター名（"grayscale", "blur", "brightness", "sepia"）または空文字
   - opacity: 透明度（0-100、100が完全不透明）
   - transform: SVG変換（"scale()", "rotate()", "translate()"など）

2. CompositionRule構造体:
   - name: コンポジションの名前（任意）
   - width/height: 出力SVGのピクセルサイズ
   - viewBox: SVGの座標系（"x y width height"形式）
   - background: 背景色（"#RRGGBB"形式）または空文字で透明

3. 注意事項:
   - レイヤーは配列の順番で下から上に重なる
   - MaterialBankに素材が登録されていることが前提
   - フィルターは事前定義またはカスタムで指定
   - transformは標準的なSVG変換構文を使用
*/