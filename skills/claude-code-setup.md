# Skill: Claude Code Environment Setup

## Purpose
新しい環境・プロジェクトで Claude Code を使い始める際に、パーミッション設定を効率的に構築する。
nurture-first-agent にベーステンプレートを保持し、各環境で呼び出して適用する。

## Escalation Criteria

### 自律実行OK
- ベーステンプレートの適用（ユーザーレベル設定）
- プロジェクトテンプレートの適用（既知のプロジェクトタイプ）

### ユーザー確認が必要
- 新しいプロジェクトタイプのテンプレート作成
- 破壊的コマンド（rm, git push --force 等）の許可追加

## Setup Procedure

### 1. ユーザーレベル設定 (`~/.claude/settings.json`)
ベース共通パーミッションを適用する。OS を判定し、適切なテンプレートを選択。

### 2. プロジェクトレベル設定 (`<project>/.claude/settings.local.json`)
プロジェクト固有のツール・ビルドコマンドを追加。

## Permission Pattern Notes

### glob エスケープルール
- `*` はパスセパレータ (`/`, `\`) を跨がない
- `**` はパスセパレータを跨いでマッチする
- コマンド引数にパスが含まれる場合は `**` を使うこと
- Windows パスの `\` は glob でエスケープ文字扱い → リテラル `\` には `\\` が必要
- JSON の中では更に倍化: `\\\\` → 文字列 `\\` → glob リテラル `\`

### 注意事項
- `2>&1` などのリダイレクトもコマンド文字列に含まれるため、末尾は `**` で受ける
- パーミッション変更後は Claude Code の再起動が必要

---

## Base Template: Cross-Platform (共通)

どの OS・環境でも使えるコマンド群。

**注意**: `"Grep"` (専用ツール) と `"Bash(grep **)"` (シェルコマンド) は別物。
同様に `"Glob"` (専用ツール) と `"Bash(find **)"` (シェルコマンド) も別物。
Claude Code は専用ツール → Bash コマンドの順で優先するが、両方許可しておくと安全。

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Edit",
      "Write",
      "Glob",
      "Grep",
      "WebSearch",
      "WebFetch",

      "Bash(git status**)",
      "Bash(git log**)",
      "Bash(git diff**)",
      "Bash(git branch**)",
      "Bash(git show **)",
      "Bash(git remote -v**)",
      "Bash(git tag**)",
      "Bash(git stash list**)",
      "Bash(git blame **)",
      "Bash(git shortlog **)",
      "Bash(git add **)",
      "Bash(git commit **)",
      "Bash(git checkout **)",
      "Bash(git switch **)",
      "Bash(git merge **)",
      "Bash(git rebase **)",
      "Bash(git stash **)",
      "Bash(git cherry-pick **)",

      "Bash(ls **)",
      "Bash(cat **)",
      "Bash(head **)",
      "Bash(tail **)",
      "Bash(wc **)",
      "Bash(file **)",
      "Bash(du **)",
      "Bash(df **)",
      "Bash(tree **)",
      "Bash(pwd**)",
      "Bash(cd **)",
      "Bash(mkdir **)",
      "Bash(cp **)",
      "Bash(mv **)",
      "Bash(touch **)",
      "Bash(chmod **)",
      "Bash(stat **)",

      "Bash(find **)",
      "Bash(grep **)",
      "Bash(rg **)",
      "Bash(sort **)",
      "Bash(uniq **)",
      "Bash(diff **)",
      "Bash(which **)",
      "Bash(xxd **)",

      "Bash(tar **)",
      "Bash(zip **)",
      "Bash(unzip **)",
      "Bash(curl **)",
      "Bash(wget **)",

      "Bash(ping **)",
      "Bash(nslookup **)",
      "Bash(whoami**)",
      "Bash(hostname**)",
      "Bash(env**)",
      "Bash(printenv**)",
      "Bash(date**)",
      "Bash(ps **)",
      "Bash(netstat **)",

      "Bash(python --version**)",
      "Bash(python3 --version**)",
      "Bash(python **)",
      "Bash(python3 **)",
      "Bash(pip list**)",
      "Bash(pip show **)",
      "Bash(pip install **)",

      "Bash(node --version**)",
      "Bash(npm --version**)",
      "Bash(npm install**)",
      "Bash(npm run **)",
      "Bash(npm test**)"
    ]
  }
}
```

## OS-Specific Additions

### Windows 追加分
```json
"Bash(where **)",
"Bash(tasklist**)",
"Bash(ipconfig**)",
"Bash(systeminfo**)",
"Bash(top **)"
```

### Linux 追加分
```json
"Bash(apt list **)",
"Bash(dpkg -l **)",
"Bash(systemctl status **)",
"Bash(journalctl **)",
"Bash(free **)",
"Bash(uname **)",
"Bash(lsblk**)",
"Bash(ip addr**)",
"Bash(ss **)",
"Bash(htop**)",
"Bash(top **)"
```

### Linux (Docker/GPU環境) 追加分
```json
"Bash(docker ps**)",
"Bash(docker logs **)",
"Bash(docker images**)",
"Bash(docker exec **)",
"Bash(nvidia-smi**)",
"Bash(gpustat**)"
```

---

## Project-Type Templates

プロジェクト固有のコマンドは `<project>/.claude/settings.local.json` に設定する。

### Arduino / Embedded

Arduino CLI のパスは環境に応じて変更すること。

```json
{
  "permissions": {
    "allow": [
      "Bash(arduino-cli compile **)",
      "Bash(arduino-cli board list**)",
      "Bash(arduino-cli lib list**)",
      "Bash(arduino-cli lib search **)",
      "Bash(arduino-cli core list**)",
      "Bash(arduino-cli core search **)",
      "Bash(arduino-cli config dump**)",
      "Bash(arduino-cli config get **)",
      "Bash(arduino-cli version**)",
      "Bash(arduino-cli sketch **)",
      "Bash(arduino-cli monitor **)"
    ]
  }
}
```

Windows で arduino-cli にフルパスが必要な場合:
```json
"Bash(\"C:\\\\Program Files\\\\Arduino CLI\\\\arduino-cli.exe\" compile **)"
```
※ `\\\\` = JSON層(`\\`) × glob層(リテラル`\`)

### Python ML / Research
```json
{
  "permissions": {
    "allow": [
      "Bash(pytest **)",
      "Bash(jupyter **)",
      "Bash(tensorboard **)",
      "Bash(wandb **)"
    ]
  }
}
```

### Web (Node.js)
```json
{
  "permissions": {
    "allow": [
      "Bash(npx **)",
      "Bash(yarn **)",
      "Bash(pnpm **)",
      "Bash(next **)",
      "Bash(vite **)"
    ]
  }
}
```

### Server Ops (raspi等)
```json
{
  "permissions": {
    "allow": [
      "Bash(systemctl status **)",
      "Bash(journalctl **)",
      "Bash(crontab -l**)",
      "Bash(pm2 list**)",
      "Bash(pm2 logs **)",
      "Bash(pm2 status **)"
    ]
  }
}
```

---

## Learned Patterns

(結晶化で追加される)

## Error Cases

### EC-CS-01: glob の `*` がパスセパレータを跨がない
- **事象**: `compile *` パターンが引数にWindowsパスを含むコマンドにマッチしなかった
- **回避策**: コマンド引数にパスが含まれる場合は必ず `**` を使う

### EC-CS-02: Windows パスの2層エスケープ
- **事象**: JSON `\\` → glob `\`(エスケープ文字) となり、リテラル `\` にマッチしなかった
- **回避策**: JSON上で `\\\\` と書く (JSON→`\\`, glob→リテラル`\`)
