# Skill: Docker Patterns

## Purpose
Docker/Docker Composeによる開発・GPU計算環境の構築・運用。
gpu-lab でのPyTorch環境、および一般的なWeb/アプリプロジェクトの開発環境に適用。

## Escalation Criteria

### 自律実行OK
- Dockerfile の改善提案
- docker-compose.yml の構文チェック

### ユーザー確認が必要
- 本番環境のコンテナ構成変更
- GPU環境のベースイメージ変更
- ネットワーク・ボリューム設計の変更

## Multi-Stage Dockerfile (Python/PyTorch)

```dockerfile
# --- deps stage ---
FROM python:3.11-slim AS deps
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- dev stage ---
FROM deps AS dev
COPY . .
CMD ["python", "-m", "pytest"]

# --- production stage ---
FROM deps AS production
RUN useradd -r appuser
COPY --from=deps /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY . .
USER appuser
HEALTHCHECK CMD python -c "import torch; print('ok')" || exit 1
CMD ["python", "main.py"]
```

## GPU (NVIDIA) Configuration

```yaml
# docker-compose.yml
services:
  train:
    build: .
    runtime: nvidia
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    volumes:
      - ./data:/app/data
      - ./checkpoints:/app/checkpoints
```

```bash
# NVIDIA Container Toolkit が必要
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/
nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

## Docker Compose (Web App)

```yaml
services:
  app:
    build: .
    ports:
      - "127.0.0.1:8000:8000"  # localhost のみ公開
    env_file: .env
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16-alpine
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: myapp
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U myapp"]
      interval: 5s

volumes:
  pgdata:
```

## Volume Strategy

| 種類 | 用途 | 例 |
|------|------|-----|
| Named volume | DB永続化 | `pgdata:/var/lib/postgresql/data` |
| Bind mount | 開発時のコード同期 | `./src:/app/src` |
| Bind mount | データセット・チェックポイント | `./data:/app/data` |

## Container Security

- **特定タグ**を使う（`:latest` 禁止）
- **non-root user** で実行
- `security_opt: [no-new-privileges:true]`
- 必要なら `read_only: true`
- `cap_drop: [ALL]`

## .dockerignore

```
.git
.env
__pycache__
*.pyc
node_modules
checkpoints/
data/
```

## Debugging

```bash
docker compose logs -f app        # ログ追跡
docker compose exec app bash      # コンテナ内シェル
docker compose ps                 # コンテナ状態
docker system prune -f            # 不要リソース削除
```

## Anti-Patterns

| やりがち | 正しくは |
|---------|---------|
| `:latest` タグ | バージョン固定 |
| root で実行 | `USER appuser` |
| secrets を compose に直書き | `env_file` or Docker secrets |
| 1コンテナにDB+アプリ | サービス分割 |
| volume なしでデータ永続化 | named volume を使う |

## User's Customizations
<!-- 対話を通じてユーザー固有のパターンを追加 -->
<!-- 例: GPU構成に合わせた設定 -->
<!-- 例: CUDA/cuDNN バージョン固定パターン -->

## Learned Patterns

### LP-DP-02: DockerでClaude CodeインストールはHOME明示必須
- **適用条件**: DockerfileでClaude Codeをインストールするとき
- **行動指針**: `HOME=/home/<user>` を明示指定する。Docker buildはrootで実行されるため`HOME=/root`になる。`CLAUDE_USER`ではインストール先は変わらない。
- **根拠**: 2026-04-03 14:00

### LP-DP-03: Claude Code用コンテナは非rootをデフォルトに
- **適用条件**: DockerコンテナでClaude Codeを使う場合
- **行動指針**: Dockerfile末尾に`USER <non-root-user>`。`claude --dangerously-skip-permissions`はroot実行を拒否する（`claude`自体はrootでも動作可能）。entrypointのroot操作は`sudo`で代替。
- **根拠**: 2026-04-03 14:10

### LP-DP-04: ボリュームマウント時はentrypointでchown
- **適用条件**: docker-composeでホストディレクトリをマウントするとき
- **行動指針**: entrypoint.shで`sudo chown -R <user>:<user> <mountpoint>`を実行。特に`.claude`ディレクトリで必要。
- **根拠**: 2026-04-03 14:20

### LP-DP-01: build-argが必要なDockerプロジェクトではbuild.shを確認
- **適用条件**: Docker環境でテスト実行やビルドを行うとき
- **行動指針**: `docker build` が失敗する場合、build.sh等のラッパースクリプトがないか確認する。build-argの指定が必要なプロジェクトではスクリプトを使う方が確実。
- **根拠**: 2026-03-27 16:00 (Docker buildでbuild-argが必要、build.shで解決)

### LP-DP-05: コンテナ内ユーザーUID変更時の影響範囲チェックリスト
- **適用条件**: DockerコンテナのUID（`useradd -u`）を変更するとき
- **行動指針**: 以下6箇所を全て確認・更新する:
  1. Dockerfileの`useradd -u <UID>`
  2. ボリュームマウント先のホスト側ファイル所有権（UIDを一致させる）
  3. fstab（CIFS/NFS）の`uid=`/`gid=`オプション
  4. Claude Code `HOME`環境変数+`chown`（LP-DP-02/04参照）
  5. entrypoint.shのマウントポイント`chown`
  6. 既存ボリューム内ファイル（`.claude`等）の権限
- **根拠**: 2026-04-04 11:00/11:20, 2026-04-06 14:00/14:10

## Error Cases

### EC-DP-01: CIFS/NFSマウントのuid/gidがコンテナUID変更に追従しない
- **事象**: bobのUIDを1000→1010に変更後、NASのCIFSマウント（fstabに`uid=1000`固定）で書き込み不可。matplotlib savefigがPermissionError。
- **原因**: UID変更はコンテナ内useraddだけでなく、ホスト側のfstabのマウントオプションにも波及する。
- **回避策**: LP-DP-05のチェックリストで影響範囲を洗い出す。特にCIFS/NFSは見落としやすい。UID変更時は必ずfstabの`uid=`/`gid=`も更新する。
