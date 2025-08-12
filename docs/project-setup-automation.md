# プロジェクトセットアップの自動化案

## 現状の課題
- 新しいプロジェクトごとに手動で`npm install`が必要
- 依存関係のインストール忘れによるエラー
- プロジェクト作成からデプロイまでの手順が多い

## 解決案

### 1. 自動npm install機能
```javascript
// server.js に追加
app.post('/api/projects/:projectName/setup', async (req, res) => {
    // npm install を自動実行
});
```

### 2. プロジェクトテンプレート機能
```javascript
// 新規プロジェクト作成時にテンプレートから依存関係をコピー
app.post('/api/projects/create', async (req, res) => {
    const { projectName, template } = req.body;
    // テンプレートからプロジェクト作成
});
```

### 3. 依存関係チェック機能
```javascript
// コンパイル前に依存関係の存在を確認
async function checkDependencies(projectPath) {
    const nodeModulesExists = await fs.access(
        path.join(projectPath, 'node_modules')
    ).then(() => true).catch(() => false);
    
    if (!nodeModulesExists) {
        // 自動インストールまたは警告
    }
}
```

## 実装オプション

### オプション1: 自動インストール（推奨）
**メリット:**
- ユーザーの手間が最小限
- エラーが少ない

**デメリット:**
- 初回は時間がかかる
- サーバーリソースを使用

### オプション2: UIからインストール実行
**メリット:**
- ユーザーが制御可能
- プログレス表示可能

**デメリット:**
- 追加の操作が必要

### オプション3: 共有node_modules
**メリット:**
- インストール不要
- ディスク容量節約

**デメリット:**
- バージョン競合の可能性
- 複雑な実装

## 推奨実装

1. **初期チェック**: プロジェクト選択時に依存関係を確認
2. **自動プロンプト**: 未インストールの場合、UIで通知
3. **ワンクリックセットアップ**: ボタン一つでnpm install実行
4. **プログレス表示**: インストール状況をリアルタイム表示

```html
<!-- UI追加案 -->
<div id="dependencyStatus" class="hidden">
    <p class="text-yellow-600">⚠️ Dependencies not installed</p>
    <button onclick="setupProject()" class="bg-yellow-500 text-white px-4 py-2 rounded">
        Setup Project
    </button>
    <div id="setupProgress" class="hidden">
        <div class="animate-spin">🔄</div>
        <p>Installing dependencies...</p>
    </div>
</div>
```