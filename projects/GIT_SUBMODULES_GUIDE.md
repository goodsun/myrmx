# Git Submodules設定ガイド

このガイドでは、siegeNgin/projects配下のプロジェクトを独立したGitHubリポジトリとして管理し、Git Submodulesとして参照する方法を説明します。

## 概要

Git Submodulesを使用することで：
- 各プロジェクトが独立したリポジトリとして管理できる
- プロジェクトごとに異なるアクセス権限を設定できる
- バージョン管理が明確になる
- CI/CDを個別に設定できる

## セットアップ方法

### 方法1: 自動セットアップスクリプトを使用

```bash
cd /Users/goodsun/develop/goodsun/siegeNgin/projects
./setup-git-submodules.sh
```

スクリプトが以下を自動で行います：
1. プロジェクトのバックアップ作成
2. 親リポジトリからの追跡を解除
3. 新しいGitリポジトリとして初期化
4. GitHubリモートの設定
5. Submoduleとしての追加

### 方法2: 手動セットアップ

#### ステップ1: GitHubで新しいリポジトリを作成

1. GitHubにログイン
2. 新しいリポジトリを作成（例：`onchain-cat`）
3. READMEなしで作成（既存のコードをプッシュするため）

#### ステップ2: プロジェクトを独立リポジトリ化

```bash
# プロジェクトディレクトリに移動
cd /Users/goodsun/develop/goodsun/siegeNgin/projects/onchain_cat

# Gitリポジトリとして初期化
git init

# すべてのファイルを追加
git add .

# 初回コミット
git commit -m "Initial commit"

# GitHubリモートを追加
git remote add origin https://github.com/yourusername/onchain-cat.git

# mainブランチにプッシュ
git branch -M main
git push -u origin main
```

#### ステップ3: 親リポジトリから削除（トラッキングのみ）

```bash
# 親リポジトリのルートに移動
cd /Users/goodsun/develop/goodsun/siegeNgin

# プロジェクトをGitの追跡から削除（ファイルは残す）
git rm -r --cached projects/onchain_cat

# 変更をコミット
git commit -m "Remove onchain_cat from tracking (converting to submodule)"
```

#### ステップ4: Submoduleとして追加

```bash
# Submoduleとして追加
git submodule add https://github.com/yourusername/onchain-cat.git projects/onchain_cat

# 変更をコミット
git commit -m "Add onchain_cat as a submodule"

# リモートにプッシュ
git push
```

## Submoduleの使い方

### クローン時

```bash
# 親リポジトリをクローン
git clone git:goodsun/siegeNgin

# Submodulesを初期化・更新
git submodule init
git submodule update

# または一度に
git clone --recurse-submodules git:goodsun/siegeNgin
```

### Submoduleの更新

```bash
# 特定のsubmoduleを更新
cd projects/onchain_cat
git pull origin main

# 親リポジトリで変更を記録
cd ../..
git add projects/onchain_cat
git commit -m "Update onchain_cat submodule"
```

### すべてのSubmodulesを更新

```bash
git submodule update --remote --merge
```

## 注意事項

1. **Submodule内での変更**
   - Submodule内で変更を行った場合、そのディレクトリ内でコミット・プッシュが必要
   - 親リポジトリでもSubmoduleの参照を更新する必要がある

2. **ブランチ管理**
   - Submoduleは特定のコミットを参照する
   - ブランチを切り替える場合は明示的な操作が必要

3. **アクセス権限**
   - プライベートリポジトリの場合、アクセス権限の設定が必要
   - CI/CDでは適切な認証設定が必要

## トラブルシューティング

### Submoduleが空の場合

```bash
git submodule init
git submodule update
```

### Submoduleの状態確認

```bash
git submodule status
```

### Submoduleの削除

```bash
# Submoduleを削除
git submodule deinit -f projects/onchain_cat
rm -rf .git/modules/projects/onchain_cat
git rm -f projects/onchain_cat
```

## 推奨されるワークフロー

1. **機能開発**
   - Submodule内で通常通り開発
   - テスト完了後、Submoduleリポジトリにプッシュ
   - 親リポジトリでSubmodule参照を更新

2. **リリース**
   - 各Submoduleでタグを作成
   - 親リポジトリで特定のタグを参照

3. **CI/CD**
   - 各Submoduleで独自のCI/CD設定
   - 親リポジトリでは統合テストを実施

## 各プロジェクトの推奨リポジトリ名

- `onchain_cat` → `onchain-cat`
- `daoshop` → `dao-shop`
- `memberSbt` → `member-sbt`
- `materialComposer` → `material-composer`
- `backgroundBank` → `background-bank`
- `effectBank` → `effect-bank`
- `tragedy` → `tragedy-game`

## 参考リンク

- [Git Submodules公式ドキュメント](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [GitHub: Working with submodules](https://github.blog/2016-02-01-working-with-submodules/)