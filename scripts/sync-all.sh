#!/bin/bash
# nurture-first-agent 全環境同期
# WSL / Windows Git Bash / Linux いずれからでも実行可能
#
# 使い方:
#   1. 下の `HOSTS` 配列を自分の SSH ホスト名リストに書き換える
#   2. 各ホストで `git clone` 済みかつ `~/.ssh/config` が整っている前提
#   3. `./sync-all.sh` で全環境 pull --rebase

set -euo pipefail

# --- 設定 (自分の環境に合わせて変更) ---
REPO_DIR_NAME="nurture-first-agent"
# リモート環境で git pull を走らせる SSH ホスト名を列挙
HOSTS=(
  # 例: "home-server" "gpu-lab"
)

# --- 環境判定 ---
detect_env() {
  if grep -qEi 'microsoft|wsl' /proc/version 2>/dev/null; then
    echo "wsl"
  elif [[ "$(uname -o 2>/dev/null)" == "Msys" || "$(uname -o 2>/dev/null)" == "Cygwin" || -n "${MSYSTEM:-}" ]]; then
    echo "winbash"
  else
    echo "linux"
  fi
}

ENV=$(detect_env)
echo "Detected environment: $ENV"

# --- SSH コマンド選択 ---
case "$ENV" in
  wsl)     SSH_CMD=/mnt/c/Windows/System32/OpenSSH/ssh.exe ;;
  winbash) SSH_CMD=ssh ;;
  linux)   SSH_CMD=ssh ;;
esac

REPO_LOCAL="$HOME/$REPO_DIR_NAME"

# --- ヘルパー ---
sync_env() {
  local name="$1"; shift
  echo "=== $name ==="
  if "$@" 2>&1; then
    echo "  OK"
  else
    echo "  SKIP"
  fi
}

# --- 1. ローカルリポジトリ同期 ---
sync_env "local ($ENV)" \
  git -C "$REPO_LOCAL" pull --rebase origin main

# --- 2. リモート環境同期 ---
for host in "${HOSTS[@]}"; do
  sync_env "$host" \
    $SSH_CMD "$host" "cd ~/$REPO_DIR_NAME && git pull --rebase origin main"
done

echo "  DONE"
