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

echo ""
echo "=== 完了 ==="
echo "どのディレクトリでも claude コマンドを起動すれば"
echo "Nurture-First Agent として動作します。"
