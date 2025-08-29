const fs = require('fs');
const path = require('path');

// SVGファイルを1行に変換
function minifySVG(svgContent) {
  return svgContent
    .replace(/<!--.*?-->/gs, '') // コメントを削除
    .replace(/\n/g, ' ') // 改行をスペースに
    .replace(/\s+/g, ' ') // 複数のスペースを1つに
    .replace(/>\s+</g, '><') // タグ間の空白を削除
    .trim();
}

// 特定のSVGファイルを処理
const svgFiles = [
  'contracts/material/back/houndstooth.svg',
  'contracts/material/back/stars.svg'
];

svgFiles.forEach(filePath => {
  const fullPath = path.join(__dirname, '..', filePath);
  
  if (fs.existsSync(fullPath)) {
    const content = fs.readFileSync(fullPath, 'utf8');
    const minified = minifySVG(content);
    
    fs.writeFileSync(fullPath, minified);
    console.log(`✅ Minified: ${filePath}`);
    console.log(`   Size: ${content.length} → ${minified.length} bytes (${Math.round((1 - minified.length/content.length) * 100)}% reduction)`);
  } else {
    console.log(`❌ File not found: ${filePath}`);
  }
});

console.log('\n✅ SVG minification complete!');