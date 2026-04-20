# nurture-first-agent

> An opinionated scaffold for growing your own **Claude Code clone agent** over time — built on the NFD (Nurture-First agent Development) pattern.

**English summary**: This repo is a personal-clone agent framework for [Claude Code](https://docs.claude.com/en/docs/claude-code). Instead of prompting from scratch each session, you **nurture** a long-lived agent: constitutional rules at the top, task-specific skills in the middle, and a growing corpus of daily experience logs at the bottom. A periodic **crystallization** pass promotes recurring patterns from logs into skills. The repo gives you the directory structure, routing rules, crystallization workflow, and a starter set of generic skills (code review, Python/PyTorch patterns, Docker, database migrations, …).

---

## なぜこのリポジトリ？

Claude Code は強力ですが、毎セッション「あなたの判断基準」をゼロから伝え直すのは非効率です。
このリポジトリは、NFD 論文 (*Nurture-First Agent Development*, arXiv:2603.10808) の考え方に沿って、

- **Constitutional 層**: 常に読まれる人格・原則・ルーティング規則（軽量）
- **Skill 層**: タスクごとに1つだけ読む知識モジュール（PRレビュー／実験設計／Docker…）
- **Experiential 層**: 日々の判断・失敗・洞察を `[DECISION] [REASONING] [PATTERN] [ERROR] [CONTEXT] [INSIGHT]` の6タグで追記

…という3層構造を**1つのリポジトリ＋1つの `~/.claude/CLAUDE.md`** で実装します。

週1回程度の **結晶化チェックポイント (Crystallization Checkpoint)** で、経験ログから再現パターンを抽出してスキルに昇格させます。これにより、agent はセッションを跨いで "育って" いきます。

## 3層アーキテクチャ

```
~/.claude/CLAUDE.md                      ← 毎リクエスト自動読込（人格・ルーティング表）
            │
            ▼  必要に応じて参照
~/nurture-first-agent/
├── constitutional/      ← 憲法層：詳細な原則・横断エラーパターン
│   ├── CLAUDE.md
│   └── profile.TEMPLATE.md  (各自 profile.md にコピーして埋める)
├── skills/              ← スキル層：タスク別の知識モジュール
│   ├── code-review.md
│   ├── python-patterns.md
│   ├── pytorch-patterns.md
│   ├── docker-patterns.md
│   ├── database-migrations.md
│   ├── api-design.md
│   ├── security-review.md
│   ├── python-testing.md
│   ├── research-experiment.md
│   ├── deep-research.md
│   ├── journal.md          (朝のジャーナリング)
│   ├── email-composition.md
│   ├── crystallize.md
│   ├── environment-routing.md
│   ├── harness-engineering.md
│   └── claude-code-setup.md
├── experiential/        ← 経験層：日々の対話ログ（.gitignore推奨）
├── scripts/             ← bootstrap / sync / crystallize
└── config/              ← `~/.claude/CLAUDE.md` のソース
```

詳細は [`ARCHITECTURE.md`](./ARCHITECTURE.md) を参照。

## クイックスタート

1. このリポを自分のアカウントに fork / clone する
2. [`SETUP-GUIDE.md`](./SETUP-GUIDE.md) に沿って Phase 0 を進める
   - `~/.claude/CLAUDE.md` の配置
   - `constitutional/profile.TEMPLATE.md` を `profile.md` にコピーして自分の情報を書き込む
3. 普段通り `claude` を起動するだけ。任意のディレクトリでクローン人格が起動します
4. 週1回、`/crystallize` で経験ログからスキル更新案をドラフトさせる

マルチマシン運用（ローカル / ホームサーバー / GPUラボ / Claude Desktop Cowork）にも対応しています。詳細は SETUP-GUIDE.md の Step 8 以降を参照。

## カスタマイズ

- **プロジェクト固有スキル**: `skills/` 配下に `<your-project>.md` を追加し、`config/user-level-CLAUDE.md` の Skill Routing Table に1行追加するだけ
- **プロフィール**: `constitutional/profile.md` を自由に書き込む（このファイルは `.gitignore` 推奨）
- **環境マップ**: `config/user-level-CLAUDE.md` の Environment Map を自分のホスト構成に書き換える

## プライバシーに関する注意

`experiential/` 配下は感情・医療・組織内情報が混入しやすい領域です。
公開リポジトリで運用する場合は、**`.gitignore` で `experiential/*.md` を除外**して、個人的なログはローカルに留めることを強く推奨します。本リポジトリ同梱の `.gitignore` はこれをデフォルトで設定しています。

## Background

本リポジトリのベースは、1人のリサーチエンジニアが Claude Code のヘビーユーザーとして数ヶ月かけて進化させてきたプライベート版の **sanitized snapshot** です。個人情報・プロジェクト固有の知識は除去し、汎用的に再利用できるスキルとフレームワークだけを残しています。

## License

MIT License — see [`LICENSE`](./LICENSE).

## Acknowledgements

- *Nurture-First Agent Development* (arXiv:2603.10808) — 基本フレームワーク
- [Claude Code](https://docs.claude.com/en/docs/claude-code) team at Anthropic
