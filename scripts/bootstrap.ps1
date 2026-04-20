# Nurture-First Agent — Bootstrap Script (Windows PowerShell)
# Phase 0: 初期セットアップ用

Write-Host "=== Nurture-First Agent Bootstrap ===" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: gtasks-mcp ---
Write-Host "[Step 1/5] gtasks-mcp のセットアップ" -ForegroundColor Yellow

$gtasksDir = "$HOME\mcp-servers\gtasks-mcp"

if (Test-Path $gtasksDir) {
    Write-Host "  gtasks-mcp は既にクローン済み: $gtasksDir"
} else {
    Write-Host "  gtasks-mcp をクローン中..."
    New-Item -ItemType Directory -Force -Path "$HOME\mcp-servers" | Out-Null
    git clone https://github.com/zcaceres/gtasks-mcp.git $gtasksDir
    Push-Location $gtasksDir
    npm install
    npm run build
    Pop-Location
}

# --- Step 2: OAuth ---
Write-Host "[Step 2/5] Google OAuth" -ForegroundColor Yellow
Write-Host "  gcp-oauth.keys.json を $gtasksDir に配置してください"
$oauthFile = "$gtasksDir\gcp-oauth.keys.json"
if (Test-Path $oauthFile) {
    Push-Location $gtasksDir
    npm run start auth
    Pop-Location
} else {
    Write-Host "  [待機] gcp-oauth.keys.json を配置後、再実行してください" -ForegroundColor Red
}

# --- Step 3: Claude Desktop設定 ---
Write-Host "[Step 3/5] Claude Desktop MCP設定" -ForegroundColor Yellow
$claudeConfig = "$env:APPDATA\Claude\claude_desktop_config.json"
Write-Host "  設定ファイル: $claudeConfig"
Write-Host "  以下を追加:"
Write-Host @"
{
  "mcpServers": {
    "gtasks": {
      "command": "node",
      "args": ["$($gtasksDir -replace '\\', '\\\\')\\dist\\index.js"]
    }
  }
}
"@

# --- Step 4: ~/.claude/CLAUDE.md 配置 ---
Write-Host "[Step 4/5] ユーザーレベル CLAUDE.md 配置" -ForegroundColor Yellow
$claudeDir = "$HOME\.claude"
$claudeMd = "$claudeDir\CLAUDE.md"
$sourceMd = Join-Path (Split-Path $PSScriptRoot) "config\user-level-CLAUDE.md"

if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
}

if (Test-Path $sourceMd) {
    Copy-Item $sourceMd $claudeMd -Force
    Write-Host "  $claudeMd に配置しました" -ForegroundColor Green
} else {
    Write-Host "  [エラー] config/user-level-CLAUDE.md が見つかりません" -ForegroundColor Red
}

# --- Step 5: 確認 ---
Write-Host "[Step 5/5] 確認" -ForegroundColor Yellow
Write-Host "  [OK] ディレクトリ構造" -ForegroundColor Green
Write-Host ""
Write-Host "=== 次のステップ ===" -ForegroundColor Cyan
Write-Host "  1. Claude Desktop を再起動"
Write-Host "  2. 'Google Tasksのタスクを見せて' で動作確認"
Write-Host "  3. 各リモート環境で git clone & ~/.claude/CLAUDE.md を配置"
