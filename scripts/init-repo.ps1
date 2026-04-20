# Nurture-First Agent — Git リポジトリ初期化スクリプト (Windows PowerShell)
#
# このスクリプトは nurture-first-agent/ を Git リポジトリとして初期化し、
# GitHub にプライベートリポジトリとして push します。
#
# 前提条件:
#   - git がインストール済み
#   - gh (GitHub CLI) がインストール済み & 認証済み
#   - このスクリプトを nurture-first-agent/scripts/ 配下から実行
#
# 使い方: .\init-repo.ps1

$agentDir = Join-Path $PSScriptRoot ".."
Push-Location $agentDir

Write-Host "=== Nurture-First Agent — Git Repository Init ===" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: .gitignore ---
Write-Host "[Step 1/4] .gitignore を作成" -ForegroundColor Yellow

$gitignore = @"
# OS
.DS_Store
Thumbs.db
desktop.ini

# Editor
.vscode/
.idea/
*.swp
*.swo

# Secrets (OAuth credentials etc.)
**/gcp-oauth.keys.json
**/*credentials*.json
**/.env

# Personal data — never commit
experiential/*.md
!experiential/README.md
experiential/journal/
personal/
state/
constitutional/profile.md
"@

Set-Content -Path ".gitignore" -Value $gitignore
Write-Host "  .gitignore を作成しました"

# --- Step 2: Git init ---
Write-Host "[Step 2/4] Git リポジトリを初期化" -ForegroundColor Yellow

if (Test-Path ".git") {
    Write-Host "  既に Git リポジトリです。スキップ。"
} else {
    git init
    Write-Host "  Git リポジトリを初期化しました"
}

# --- Step 3: Initial commit ---
Write-Host "[Step 3/4] 初回コミット" -ForegroundColor Yellow

git add -A
git commit -m "bootstrap: Nurture-First Agent initial scaffolding (NFD Phase 0)"
Write-Host "  初回コミット完了"

# --- Step 4: GitHub リモート作成 ---
Write-Host "[Step 4/4] GitHub プライベートリポジトリを作成" -ForegroundColor Yellow

$repoName = Read-Host "  リポジトリ名を入力してください (例: my-clone-agent)"
if (-not $repoName) {
    $repoName = "my-clone-agent"
}

Write-Host "  gh コマンドで GitHub にリポジトリを作成します..."
Write-Host "  リポジトリ名: $repoName (private)" -ForegroundColor Green
Write-Host ""

$confirm = Read-Host "  続行しますか？ (y/n)"
if ($confirm -eq "y") {
    gh repo create $repoName --private --source=. --remote=origin --push
    Write-Host ""
    Write-Host "  GitHub リポジトリを作成し、push しました！" -ForegroundColor Green
} else {
    Write-Host "  スキップしました。後で手動で以下を実行してください:"
    Write-Host "    gh repo create $repoName --private --source=. --remote=origin --push"
}

Pop-Location

Write-Host ""
Write-Host "=== 完了 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "次のステップ:" -ForegroundColor Yellow
Write-Host "  1. 各リモートマシン（サーバー・GPUマシン等）でクローン:"
Write-Host "     git clone git@github.com:<your-username>/$repoName.git"
Write-Host ""
Write-Host "  2. 各環境の Claude Code プロジェクトとして開く:"
Write-Host "     cd $repoName && claude"
Write-Host ""
Write-Host "  3. Claude が CLAUDE.md を読み込み、クローンとして起動します"
