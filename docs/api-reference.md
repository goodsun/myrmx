# API リファレンス

siegeNgin Browser Deploy ToolのAPIエンドポイント一覧です。

## 基本情報
- ベースURL: `http://localhost:3000`
- Content-Type: `application/json`

## エンドポイント

### プロジェクト管理

#### GET /api/projects
利用可能なプロジェクト一覧を取得

**レスポンス:**
```json
{
  "projects": ["project1", "project2", "sample-project"]
}
```

#### GET /api/projects/:projectName/status
プロジェクトのステータスを取得

**パラメータ:**
- `projectName`: プロジェクト名（英数字、ハイフン、アンダースコアのみ）

**レスポンス:**
```json
{
  "hasDependencies": true,
  "hasArtifacts": true,
  "hasCache": false,
  "cleanableSize": 0
}
```

### コントラクト操作

#### GET /api/projects/:projectName/contracts
プロジェクト内のコントラクト一覧を取得

**レスポンス:**
```json
{
  "contracts": {
    "SimpleStorage": {
      "abi": [...],
      "bytecode": "0x..."
    },
    "Token": {
      "abi": [...],
      "bytecode": "0x..."
    }
  }
}
```

#### POST /api/projects/:projectName/compile
プロジェクトをコンパイル（依存関係の自動インストール含む）

**レスポンス（ストリーミング）:**
```json
{"status": "installing", "message": "Installing dependencies..."}
{"status": "installed", "message": "Dependencies installed successfully"}
{"success": true, "output": "Compilation output..."}
```

#### POST /api/projects/:projectName/deploy
デプロイ用データを取得

**リクエストボディ:**
```json
{
  "contractName": "SimpleStorage",
  "constructorArgs": []
}
```

**レスポンス:**
```json
{
  "success": true,
  "bytecode": "0x...",
  "abi": [...]
}
```

### メンテナンス

#### POST /api/projects/:projectName/clean
プロジェクトのクリーンアップ（.gitignoreベース）

**レスポンス:**
```json
{
  "success": true,
  "deletedFiles": ["node_modules", "artifacts", "cache"],
  "errors": [],
  "message": "Cleaned 3 items"
}
```

## セキュリティ

### プロジェクト名の検証
- 使用可能文字: `a-zA-Z0-9_-`
- 最大長: 100文字
- パストラバーサルパターンは拒否（`..`, `/`, `\`等）

### CORS設定
- 開発環境: すべてのオリジンを許可
- 本番環境: 指定されたオリジンのみ許可

## エラーレスポンス

```json
{
  "error": "エラーメッセージ",
  "success": false
}
```

**HTTPステータスコード:**
- `400`: 不正なリクエスト（バリデーションエラー）
- `404`: リソースが見つからない
- `500`: サーバーエラー