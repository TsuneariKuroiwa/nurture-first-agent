#!/bin/bash
# Nurture-First Agent — Remote Machine Setup

set -e

REPO_URL="${1:-git@github.com:YOUR_USERNAME/nurture-first-agent.git}"
CLONE_DIR="${2:-$HOME/nurture-first-agent}"

echo "=== Nurture-First Agent — Remote Setup ==="

# Clone
if [ -d "$CLONE_DIR" ]; then
    echo "既にクローン済み: $CLONE_DIR"
    cd "$CLONE_DIR" && git pull --rebase origin main
else
    git clone "$REPO_URL" "$CLONE_DIR"
    cd "$CLONE_DIR"
fi

# ~/.claude/CLAUDE.md 配置
mkdir -p ~/.claude
cp config/user-level-CLAUDE.md ~/.claude/CLAUDE.md
echo "~/.claude/CLAUDE.md を配置しました"

# ~/.claude/skills を .claude/skills へリンク（Agent Skill 群を repo 一元管理）
SKILLS_TARGET="$CLONE_DIR/.claude/skills"
SKILLS_LINK="$HOME/.claude/skills"

if [ -d "$SKILLS_TARGET" ]; then
    if [ -e "$SKILLS_LINK" ] || [ -L "$SKILLS_LINK" ]; then
        echo "~/.claude/skills は既に存在するためスキップ（必要なら手動で削除してから再実行）"
    else
        case "$(uname -s)" in
            MINGW*|MSYS*|CYGWIN*)
                # Windows: junction を貼る（管理者権限不要）
                WIN_TARGET=$(cygpath -w "$SKILLS_TARGET")
                WIN_LINK=$(cygpath -w "$SKILLS_LINK")
                cmd.exe /c mklink /J "$WIN_LINK" "$WIN_TARGET"
                ;;
            *)
                # Linux / macOS: 通常のシンボリックリンク
                ln -s "$SKILLS_TARGET" "$SKILLS_LINK"
                ;;
        esac
        echo "~/.claude/skills → $SKILLS_TARGET へリンクしました"
    fi
fi

# ~/.claude/commands に slash command を配置
mkdir -p ~/.claude/commands
cp commands/*.md ~/.claude/commands/ 2>/dev/null || true

echo ""
echo "=== 完了 ==="
echo "どのディレクトリでも claude コマンドを起動すれば"
echo "Nurture-First Agent として動作します。"
