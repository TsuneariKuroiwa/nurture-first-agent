# Nurture-First Agent — セットアップガイド

上から順番にやってください。推定所要時間: Phase 0 は 1〜2時間。

---

## Phase 0: Bootstrap

### Coworkモードでの MCP 利用について

以下のStep 1〜3（gtasks-mcp セットアップ）は **Claude Desktop（通常モード）または Claude Code** で行うのが標準。
加えて Claude Desktop の Coworkモードでも、**ファイル → 設定 → 開発者 → 設定を編集** から
ローカルMCPサーバー（gtasks 含む）を登録できる（Windows の場合、WSL 経由で bun 実体を呼ぶ形が典型）。

また、Coworkモードではレジストリ接続済みの MCP として以下も利用可能:
- Google Calendar
- Slack
- Gmail
- Google Drive

---

### Step 0: 前提ソフトウェアの確認

以下が必要（OS依存部分はお使いの環境に合わせて調整）:
- **Git**（Windowsなら Git Bash を含む Git for Windows）
- **bun**（scoop / Homebrew / 公式インストーラー等）

bun のインストール例（Windows + scoop）:
```powershell
scoop install bun
```

確認:
```bash
bun --version   # バージョンが返ること
```

---

### Step 1: Google Cloud で OAuth 認証情報を作る（15分、任意）

Google Tasks MCP を使う場合のみ。不要なら Step 2-3 をスキップできます。

1. https://console.cloud.google.com にアクセス
2. 新しいプロジェクトを作成（名前は何でもOK）
3. 「APIとサービス」→「ライブラリ」→ **Google Tasks API** を有効にする
4. 「OAuth 同意画面」→ 外部 → アプリ名適当 → テストユーザーに自分のアカウントを追加
5. 「認証情報」→ OAuth クライアント ID → **デスクトップアプリ** → JSONダウンロード

### Step 2: gtasks-mcp セットアップ（10分、任意）

PowerShell または Git Bash で実行:
```bash
mkdir -p ~/mcp-servers
cd ~/mcp-servers
git clone https://github.com/zcaceres/gtasks-mcp.git
cd gtasks-mcp
bun install
bun run build
```

Step 1 のJSONを `~/mcp-servers/gtasks-mcp/gcp-oauth.keys.json` にコピーして:
```bash
cd ~/mcp-servers/gtasks-mcp
bun dist/index.js auth
```
ブラウザが開くのでGoogleアカウントで認証する。

### Step 3: Claude Desktop に MCP 登録（5分、任意）
Claude Desktopの設定ファイルを編集:

- **Windows（通常版）**: `%APPDATA%\Claude\claude_desktop_config.json`
- **Windows（MSIX版）**: `C:\Users\<USER>\AppData\Local\Packages\Claude_<hash>\LocalCache\Roaming\Claude\claude_desktop_config.json`
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "gtasks": {
      "command": "bun",
      "args": ["dist/index.js"],
      "cwd": "<path-to>/mcp-servers/gtasks-mcp"
    }
  }
}
```

> bunのパスが通らない場合はフルパスを指定する。

Claude Desktop を再起動。「Google Tasksのタスク一覧を見せて」で動作確認。

### Step 4: nurture-first-agent を好きな場所に配置（1分）

```
~/nurture-first-agent
```

### Step 5: ~/.claude/CLAUDE.md を配置（3分）

どのディレクトリでClaude Codeを起動してもクローン人格が有効になるための設定。

**Windows（PowerShell）**:
```powershell
mkdir ~\.claude -ErrorAction SilentlyContinue
copy ~\nurture-first-agent\config\user-level-CLAUDE.md ~\.claude\CLAUDE.md
```

**Linux / macOS**:
```bash
mkdir -p ~/.claude
cp ~/nurture-first-agent/config/user-level-CLAUDE.md ~/.claude/CLAUDE.md
```

※ `user-level-CLAUDE.md` の中のパス `~/nurture-first-agent/` が
実際の配置場所と一致しているか確認。

### Step 6: User Profile を埋める（5分）

```bash
cp ~/nurture-first-agent/constitutional/profile.TEMPLATE.md \
   ~/nurture-first-agent/constitutional/profile.md
# profile.md を編集して自分の情報を記入
```

※ `profile.md` は `.gitignore` 推奨（個人情報のため）。

### Step 7: スラッシュコマンドを配置（2分）

`commands/` 配下の `.md` ファイルは Claude Code のユーザーレベル
スラッシュコマンドとして使えるが、自動読み込みされる場所は
`~/.claude/commands/` に限られるため、手動でコピーする。

**Windows（PowerShell）**:
```powershell
mkdir ~\.claude\commands -ErrorAction SilentlyContinue
copy ~\nurture-first-agent\commands\*.md ~\.claude\commands\
```

**Linux / macOS**:
```bash
mkdir -p ~/.claude/commands
cp ~/nurture-first-agent/commands/*.md ~/.claude/commands/
```

これで以下が使えるようになる:
- `/log <内容>` — その場の対話を経験ログに記録
- `/sync` — `scripts/sync-all.sh` を実行して全環境を同期

プロジェクトディレクトリ（`nurture-first-agent/`）で Claude Code
を起動したときだけ使いたいコマンドは `.claude/commands/` 配下に置く
（本リポでは `/crystallize` が既に設置済み）。

独自コマンドを増やしたくなったら、`commands/<name>.md` に1ファイル
追加 →（必要なら）`~/.claude/commands/` に再コピー、で完結する。

### Step 8: Agent Skills を配置（任意、3分）

`agent-skills/` 配下には Office 系ファイル操作のユーザーレベル
スキル（docx / xlsx / pptx / pdf）が同梱されている。これらを
`~/.claude/skills/` に配置すると、どのプロジェクトでも Skill tool
経由で呼び出せるようになる（Excel 編集・Word 報告書作成・PDF処理・
PowerPoint スライド作成）。

**Windows（PowerShell）**:
```powershell
mkdir ~\.claude\skills -ErrorAction SilentlyContinue
xcopy ~\nurture-first-agent\agent-skills\* ~\.claude\skills\ /E /I /Y
```

**Linux / macOS**:
```bash
mkdir -p ~/.claude/skills
cp -r ~/nurture-first-agent/agent-skills/* ~/.claude/skills/
```

既に同名スキルがある場合は上書きされるので、カスタマイズ版を
残したい場合はバックアップを取ってから実行すること。

### Step 9: Git リポジトリ化 & GitHub push（5分）

```bash
cd ~/nurture-first-agent
git init
git add -A
git commit -m "bootstrap: Nurture-First Agent initial scaffolding (NFD Phase 0)"
gh repo create <your-repo-name> --private --source=. --remote=origin --push
```

### Step 10: リモート環境にセットアップ（各5分）

各マシンにSSHして:
```bash
git clone git@github.com:<YOUR_USERNAME>/<your-repo-name>.git ~/nurture-first-agent
cd ~/nurture-first-agent
bash scripts/clone-setup.sh git@github.com:<YOUR_USERNAME>/<your-repo-name>.git
```

clone-setup.sh が自動的に `~/.claude/CLAUDE.md` を配置する。

---

## Phase 0 完了チェックリスト

- [ ] （任意）Google Tasks MCP が Claude Desktop（通常モード / Coworkモードの「ローカルMCPサーバー」）で動く
- [ ] nurture-first-agent が GitHub リポジトリにある（private 推奨）
- [ ] ローカルの `~/.claude/CLAUDE.md` が配置済み
- [ ] `constitutional/profile.md` に自分のプロフィールが記入済み
- [ ] `~/.claude/commands/` に `/log` `/sync` が配置済み
- [ ] （任意）`~/.claude/skills/` に docx/xlsx/pptx/pdf の Agent Skills が配置済み
- [ ] 各リモート環境に `~/.claude/CLAUDE.md` 配置済み & リポジトリがクローン済み

**確認方法**: 任意のプロジェクトディレクトリで `claude` を起動して
「あなたは誰ですか？」と聞く。「ユーザーの分身です」的な回答が返ればOK。

---

## Phase 1: Initial Nurturing

普段通りClaudeを使うだけ。ただし3つだけ意識する:

### 1. 判断の「なぜ」を説明する

```
❌ 「このPRマージして」
✅ 「このPRマージして。テストが通ってるし、変更が小さいから
    レビュー1人でOK。ただしDB migration含むPRは必ず2人レビュー。」
```

### 2. 間違えたら修正理由を伝える

```
❌ 「違う、こうして」
✅ 「違う。このケースではAじゃなくB。データが1万件超えるとAは遅いから。」
```

### 3. 週1回、結晶化レポートを確認する

毎週1回の結晶化タスクを走らせる。翌週に:
> 「今週の結晶化レポートを見せて」

---

## 育成の目安

| 期間 | 状態 | ユーザーの関与度 |
|------|------|-------------|
| 1-3週間 | 基本的な判断基準を学習中 | 高（毎回確認・修正） |
| 1-3ヶ月 | パターン認識が機能し始める | 中（たまに修正） |
| 3ヶ月〜 | 大半のタスクを自律的に処理 | 低（例外対応のみ） |

---

## トラブルシューティング

**Q: Claude Codeがクローン人格で動かない**
→ `~/.claude/CLAUDE.md` が存在するか確認: `cat ~/.claude/CLAUDE.md`

**Q: 経験ログがgit pushできない**
→ `cd ~/nurture-first-agent && git pull --rebase origin main` してから再push

**Q: スキルファイルを読みに行かない**
→ 「code-review.mdを読んでからレビューして」と明示的に指示してみる。
  改善が必要ならCLAUDE.mdのルーティングテーブルを調整する。

**Q: gtasks-mcpで `bun: command not found`**
→ bunのフルパスをClaude Desktop設定のcommandに指定する。
  `where bun` / `which bun` でパスを確認。

**Q: gtasks-mcpで `spawn node ENOENT`**
→ Claude Desktopはshimの `.cmd` を解決できない場合がある。
  bunの実体（.cmdではなく.exe）のフルパスを指定する。

**Q: gtasks-mcpで `Credentials not found`**
→ CWDが違うと認証ファイルが見つからない。
  設定の `cwd` が正しいか確認すること。
  認証をやり直す場合:
  ```bash
  cd ~/mcp-servers/gtasks-mcp
  bun dist/index.js auth
  ```

**Q: 結晶化タスクが動かない**
→ Claude Desktopのサイドバー「Scheduled」で週次クリスタライズタスクを確認
