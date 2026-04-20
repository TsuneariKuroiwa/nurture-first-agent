# Nurture-First Agent — NFD Architecture Design

Based on: "Nurture-First Agent Development" (arXiv:2603.10808)

## Overview

ユーザーの分身として機能するAIエージェント。Google Tasksからその日のタスクを取得し、
適切な環境（ローカル / 自宅サーバー / 共用GPUマシン / Claude Desktop Cowork）に振り分けて実行する。
対話を通じてユーザーの暗黙知・判断基準・専門知識を吸収し、継続的に成長する。

> **Note**: Google Tasks連携はすべての環境で利用可能。
> - local: gtasks-mcp（ローカルMCPサーバー）経由
> - cowork: Claude Desktop の「ローカルMCPサーバー」設定から gtasks-mcp を登録するか、
>   レジストリ接続済みの Calendar/Slack/Gmail/Drive 等を利用

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Nurture-First Agent                      │
│                                                           │
│  ~/.claude/CLAUDE.md（全環境で常に読み込まれる）           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ Identity / Principles / Skill Routing Table          │ │
│  │ Experience Logging Protocol / Environment Map        │ │
│  └────────────────────────┬────────────────────────────┘ │
│                           │ 必要に応じて読みに行く        │
│                           ▼                               │
│  ~/nurture-first-agent/（知識ベース・Gitリポジトリ）          │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────────┐ │
│  │Constitutional│  │  Skill Layer │  │ Experiential Layer│ │
│  │    Layer     │  │             │  │                  │ │
│  │ (詳細設定)   │  │ (タスク別   │  │ (対話ログ・      │ │
│  │             │  │  知識)      │  │  ケース・エラー)  │ │
│  └─────────────┘  └──────┬──────┘  └────────┬─────────┘ │
│                          │                   │           │
│       タスクに応じて1つだけ読む    grepで関連分だけ検索   │
└─────────────────────────────────────────────────────────┘
```

## Key Design: 2つのCLAUDE.md

| | ~/.claude/CLAUDE.md | nurture-first-agent/constitutional/ |
|---|---|---|
| **読み込み** | 毎回自動 | 必要時のみ手動参照 |
| **場所** | 各マシンの ~/.claude/ | Gitリポジトリ内 |
| **内容** | 人格・原則・ルーティングテーブル | 詳細設定・補足情報 |
| **サイズ** | 小さく保つ（コンテキスト10-15%） | 必要なだけ |
| **役割** | 「何を読むべきか」の判断基準 | 読まれる側の知識 |

## Cross-Environment Sync (Git)

```
┌──────────┐    ┌──────────┐    ┌──────────┐
│  local   │    │home-srv  │    │ gpu-lab  │
│   (OS)   │    │ (Server) │    │   (GPU)  │
│          │    │          │    │          │
│ ~/.claude/CLAUDE.md（各マシンに同一内容を配置）│
│          │    │          │    │          │
│ any dir  │    │ any dir  │    │ any dir  │
│ で作業   │    │ で作業   │    │ で作業   │
└────┬─────┘    └────┬─────┘    └────┬─────┘
     │               │               │
     │  git commit   │  git commit   │  git commit
     │  & push       │  & push       │  & push
     │  (経験ログ)    │  (経験ログ)    │  (経験ログ)
     ▼               ▼               ▼
┌─────────────────────────────────────────┐
│        GitHub Private Repository         │
│       ~/nurture-first-agent/.git            │
│                                          │
│  constitutional/ ← 結晶化タスクのみ更新  │
│  skills/         ← 結晶化タスクのみ更新  │
│  experiential/   ← 全環境が書き込み      │
└──────────────────┬──────────────────────┘
                   │
                   │ 毎週金曜 21:00
                   ▼
          ┌─────────────────┐
          │  Crystallization │
          │  Scheduled Task  │
          │                  │
          │  pull → 分析 →   │
          │  結晶化 → push   │
          └─────────────────┘
```

## Three-Layer Cognitive Architecture

### Layer 1: Constitutional（憲法層）
- **ユーザーレベル**: `~/.claude/CLAUDE.md`（常に読まれる、軽量）
- **詳細版**: `~/nurture-first-agent/constitutional/CLAUDE.md`（補足情報）
- **サイズ目標**: ユーザーレベルはコンテキストの10-15%以下

### Layer 2: Skills（スキル層）
- **ディレクトリ**: `~/nurture-first-agent/skills/`
- **読み込み**: タスクに応じて1つだけ。ルーティングテーブルで判断
- **更新**: 結晶化タスクのみが更新（品質管理）
- **初期スキル**:
  - `code-review.md` — コードレビューの判断基準
  - `research-experiment.md` — 実験設計・実行のパターン
  - `environment-routing.md` — タスク→環境の振り分けロジック
  - （ユーザー固有の運用スキルは各自で追加）

### Layer 3: Experiential（経験層）
- **ディレクトリ**: `~/nurture-first-agent/experiential/`
- **日常アクセス**: grepで関連キーワード検索 → 最新1-2件のみ読む
- **全件分析**: 結晶化タスクのみ
- **同期**: Git（全環境が書き込み、結晶化タスクが統合）

## MCP Server Stack

### CoworkモードのMCP
レジストリ接続済み:
- **Google Calendar** — スケジュール管理・空き時間検索
- **Slack** — メッセージ送受信・チャンネル検索
- **Gmail** — メール検索・下書き作成
- **Google Drive** — ファイル検索・取得

ローカルMCP も追加登録可能:
- Claude Desktop の「ファイル → 設定 → 開発者 → 設定を編集」から、通常モードと同じ要領で
  gtasks-mcp 等を登録できる（Windows の場合 WSL 経由で bun 実体を呼ぶ形が典型）。

### 必須（Phase 0で導入）
1. **gtasks-mcp** — Google Tasks取得・更新（Claude Desktop / Claude Code / Cowork のいずれもローカルMCP として登録可能）

### 推奨（Phase 1で導入）
2. **ssh-mcp** — リモートマシンへのSSH接続

### 将来（Phase 2+）
3. **memory-mcp** — セマンティック検索による経験層アクセス
4. **slack/gmail通知** — 実行結果の報告（Cowork環境ではSlack/Gmail MCPで対応可能）

## Spiral Development Plan

### Phase 0: Bootstrap（1-3日）
- [ ] Gitリポジトリ初期化 & GitHub push
- [ ] 各マシンに ~/.claude/CLAUDE.md を配置
- [ ] 各リモート環境で nurture-first-agent をクローン
- [ ] gtasks-mcp のセットアップ

### Phase 1: Initial Nurturing（1-3週間）
- [ ] 日常タスクでの対話を開始
- [ ] 経験ログの蓄積を開始
- [ ] Crystallization Checkpoint 1

### Phase 2: Structured Nurturing（1-3ヶ月）
- [ ] スキル参照ファイルの実践的洗練
- [ ] エラーパターンライブラリの構築
- [ ] Crystallization Checkpoint 2

### Phase 3+: Mature Operation
- [ ] 結晶化の定期保守化
- [ ] エージェントからの結晶化候補の事前提案
