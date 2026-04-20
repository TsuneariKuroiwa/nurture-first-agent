# Skill: Environment Routing

## Purpose
タスクの内容から適切な実行環境を判断する。

## Escalation Criteria

### 自律実行OK
- ルーティングテーブルに明確に合致するタスク
- 単一環境で完結するタスク

### ユーザー確認が必要
- 複数環境にまたがるタスク（分割方法の判断）
- ルーティングテーブルのどのカテゴリにも明確に合致しないタスク
- 新しい種類のタスクで前例がない場合

## Routing Decision Tree

```
タスクを受信
├─ GPU/CUDA/学習/training/推論/モデル/データセット → gpu-lab
├─ デプロイ/サーバー/cron/監視/常時稼働/ネットワーク → home-server
├─ レビュー/設計/ドキュメント/一般コーディング → local
├─ ドキュメント作成/Slack連携/Gmail連携/カレンダー管理/スプレッドシート → cowork
├─ 複数環境にまたがる → 分割して各環境に振り分け。ユーザーに確認。
└─ 判断不能 → ユーザーに確認
```

## Environment Capabilities

### local (手元のPC)
- Claude Code (CLI) インストール済み
- Git Bash / bash でシェルスクリプト実行可能
- メインの作業環境

### home-server (自宅サーバー。例: Raspberry Pi)
- 常時稼働
- SSH接続: ユーザー固有に設定（`~/.ssh/config` で管理）
- 制約: CPU/メモリが限定的

### gpu-lab (共用GPUマシン)
- SSH接続: ユーザー固有に設定
- GPU: 個別構成
- 制約: 共用リソースのため占有に配慮

### cowork (Claude Desktop Coworkモード)
- サンドボックスLinux VM上で動作
- ドキュメント作成（docx, pptx, xlsx, pdf）が得意
- レジストリ接続済みMCP: Google Calendar, Slack, Gmail, Google Drive
- ローカルMCP（gtasks-mcp 等）も「ファイル → 設定 → 開発者 → 設定を編集」から登録可能
- Git操作はサンドボックス内のみ（ユーザーのローカルリポジトリには直接触れない）

## Learned Patterns

### LP-ER-01: GPU環境のセットアップ確認項目
- **適用条件**: GPU環境で新しいタスクを開始するとき
- **行動指針**: (1) PyTorchとGPU compute capabilityの互換性確認、(2) configファイルのパスが現環境と一致するか確認、(3) コンテナ環境ではpipインストールが再起動で消えることを考慮。

### LP-ER-03: 定型ドキュメント作成はcowork環境を優先提案
- **適用条件**: 出張報告書・申請書等の定型ドキュメント作成を依頼されたとき
- **行動指針**: cowork環境（Claude Desktop）を優先提案する。Drive/Gmail等のMCPがあり、ドキュメント作成系タスクに適している。localでも対応可能だが、coworkの方が自然なワークフロー。

### LP-ER-04: Windows OpenSSHで多環境接続（Windowsユーザー向け）
- **適用条件**: local環境（Windows）から他環境にSSH接続するとき
- **行動指針**: Windows OpenSSH (`ssh`) を直接使用する。ssh-agent等はWindows側で管理。WSL経由は不要。

### LP-ER-05: local環境の最新ツール状況
- **適用条件**: local環境でCLIツールを使うとき
- **行動指針**: `gh`, `git`, `bun`, `ssh` 等はOSネイティブ（Windowsなら Git Bash + Claude Code）から直接実行可能。

### LP-ER-06: Claude Code (Windows)のシェル初期化はBASH_ENV経由
- **適用条件**: Claude Code (Windows)のシェル環境をカスタマイズしたいとき
- **行動指針**: (1) `~/.bashrc`に設定を書く (2) settings.jsonの`env.BASH_ENV`で`"~/.bashrc"`を指定。Claude CodeはGit Bash + `bash -c`（非インタラクティブ）のため、`.bashrc`は直接読まれない。`BASH_ENV`のみ有効。

### LP-ER-07: Bashパーミッションのglobルール（Windows対応）
- **適用条件**: settings.jsonでBash許可パターンを設定するとき
- **行動指針**: `*`はパスセパレータを跨がない→Windowsパスには`**`必須。`\`はJSON+globの2層エスケープで`\\\\`。

### LP-ER-08: チェーン・パイプ用の汎用Bashパーミッションパターン
- **適用条件**: settings.jsonのBash許可設定を構築するとき
- **行動指針**: `Bash(** && **)`, `Bash(** || **)`, `Bash(** | **)`, `Bash(** & **)`を追加。シェルメタ文字を跨ぐマッチングに必要。

## Error Cases

### EC-ER-01: コンテナのパス不一致を見落とし
- **事象**: 学習済みモデルのconfigが旧パスを参照しており、データロードが0件。
- **回避策**: LP-ER-01を適用。configのパスを最初に確認。
