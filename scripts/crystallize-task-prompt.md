あなたはユーザーのクローンエージェントの「結晶化」プロセスを実行するタスクです。

NFD（Nurture-First Development）論文に基づき、全環境から蓄積された経験ログをGit経由で収集し、パターンを抽出してスキル参照ファイルを更新します。

## 前提

- 作業ディレクトリは nurture-first-agent リポジトリのルートに設定済み
- 詳細な結晶化手順は scripts/crystallize.md に定義されている

## 対象ディレクトリ

- experiential/ — 経験ログ（日次ログ、ケース、エラー）
- skills/ — スキル参照ファイル群
- constitutional/ — 憲法層（CLAUDE.md, profile.md）
- config/ — user-level-CLAUDE.md（Phase昇格・Skill Routing変更時に更新）

## 実行手順

### Step 0: Git同期（全環境の経験を収集）

```bash
git pull --rebase origin main
```

これにより、local/raspi/gpu-lab すべての環境から push された経験ログを取得する。

### Step 1: 手順書の読み込み

scripts/crystallize.md を読み込み、結晶化の4フェーズ（Pattern Extraction → Knowledge Structuring → De-contextualization → Validation）に従って実行する。

### Step 2: 経験ログの収集と分類

experiential/ 配下の全ファイル（日次ログ YYYY-MM-DD.md、cases/、errors/）を読み込む。

前回の結晶化レポート（crystallization-report-*.md）の日付以降に追加されたエントリを特定する。

タグ別に分類する: [INSIGHT], [PATTERN], [ERROR], [DECISION], [REASONING], [CONTEXT], [FRAMEWORK], [ROUTING], [PREFERENCE]

環境タグ（env:local, env:raspi, env:gpu-lab）も集計し、どの環境からの学びかを識別する。

### Step 3: パターン抽出と汎化（crystallize.md Phase 1-3）

- 同じタグ・カテゴリのエントリが3回以上繰り返されているパターンを特定
- 繰り返されるエラーの共通原因を分析
- ユーザーからのフィードバックの傾向を把握
- 新しい洞察（INSIGHT）で既存スキルに統合すべきものを特定
- 環境横断パターン（複数環境で同じ傾向）があれば特に注目
- 特定の日時・PR番号等の状況固有情報を除去し、再利用可能な一般原則に変換する

### Step 4: スキル参照ファイルの更新

skills/ 配下の各ファイルについて:

- 「Learned Patterns」セクションに新規パターンを追記
- 「Error Cases」セクションにエラーパターンを追記
- 新しいスキルファイルが必要な場合は作成

対象ファイル:

- skills/environment-routing.md — タスク→環境の振り分けルール
- skills/code-review.md — コードレビュー基準
- skills/research-experiment.md — 研究・実験パターン
- skills/server-ops.md — サーバー運用手順
- その他、必要に応じて新規作成

### Step 5: Constitutional層の見直し

constitutional/CLAUDE.md の内容が現在の実践と一致しているか確認:

- Task Routing Rules は実際のルーティングパターンと合っているか
- constitutional/profile.md に対話から得た新情報を追加すべきか
- 新しい原則を追加すべきか

Phase昇格やSkill Routing変更がある場合は config/user-level-CLAUDE.md も更新する。

### Step 6: 結晶化レポートの作成

experiential/crystallization-report-YYYY-MM-DD.md を作成（テンプレートは scripts/crystallize.md に定義）:

- 期間中の新規経験ログ数（環境別内訳）
- 抽出されたパターン数と内容の要約
- 更新したスキルファイルの一覧と変更内容
- 新規作成したファイル（あれば）
- 次回までの課題・注目すべき傾向
- ユーザーへの質問事項（判断に迷った点など）

### Step 7: Git commit & push（結晶化結果を全環境に配信）

```bash
git add skills/ constitutional/ experiential/crystallization-report-*.md config/
git commit -m "crystallize: weekly checkpoint YYYY-MM-DD"
git push origin main
```

### Step 8: 品質チェック

以下を確認:

- 結晶化した内容が十分に一般化されているか（特定状況に依存しすぎていないか）
- 経験データに裏付けられているか
- 既存スキルファイルとの矛盾がないか

## 注意事項

- 経験ログがまだ存在しない、または前回以降の新規エントリがない場合は「まだ結晶化するデータがありません」と報告して終了
- 破壊的な変更（既存パターンの削除等）は行わず、追記を基本とする
- 確信が持てない結晶化は「候補」として報告し、ユーザーの確認を求める
- git push が失敗した場合はエラーを報告し、手動対応を促す
