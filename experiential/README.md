# Experiential Layer

## 役割

結晶化の原材料となる経験データを蓄積する層。
日常の対話・判断・エラーを構造化して記録し、定期的な結晶化で
上位層（skills/, constitutional/）に知識として昇華させる。

## Structure

### ファイル命名規則
- 日次ログ: `YYYY-MM-DD.md`
- ケースライブラリ: `cases/CATEGORY-NNN.md`
- エラーパターン: `errors/ERROR-NNN.md`
- 結晶化レポート: `crystallization-report-YYYY-MM-DD.md`

## 6カテゴリ タグ体系

NFD論文の6カテゴリに基づくタグ体系。

| タグ | カテゴリ名 | 記録内容 | 結晶化での価値 |
|------|-----------|---------|--------------|
| [DECISION] | Operational Records | 判断・行動・結果 | 行動パターンの抽出 |
| [REASONING] | Reasoning Traces | 判断の推論過程・前提・却下した選択肢 | **最重要**: 結晶化効率を大きく左右する |
| [PATTERN] | Pattern Observations | 繰り返し観察されるパターン | パターン候補の直接的な入力 |
| [ERROR] | Error Records | 誤り・修正・原因分析 | エラーパターンライブラリの素材 |
| [CONTEXT] | Contextual Annotations | 環境・制約・依存関係のメタデータ | パターンの適用条件の明確化 |
| [INSIGHT] | Insight Fragments | ユーザーの暗黙知・新しい洞察 | Constitutional層の精緻化 |

### 補助タグ（メインタグと併用可）
- [PREFERENCE] — ユーザーの好み・スタイルに関する発見
- [FRAMEWORK] — 思考フレームワーク・メンタルモデル
- [ROUTING] — 環境ルーティングに関する学び

### [REASONING] タグの重要性

論文の知見: 「推論の痕跡を持つ経験は結晶化効率が大幅に高い」

[REASONING] エントリには以下を必ず含める:
- **何を判断したか**（判断対象）
- **どの選択肢を検討したか**（A, B, C...）
- **なぜその選択肢を選んだか**（判断基準）
- **却下した選択肢とその理由**
- **前提条件**（この判断が成り立つ条件）

## 結晶化の目安

- 同じタグのエントリが5件以上 → パターン抽出を検討
- [ERROR] エントリが3件以上同カテゴリ → エラーパターンファイル作成を検討
- [REASONING] エントリが10件以上 → 判断基準のスキルファイルへの昇格を検討
- 臨時の結晶化トリガー → `scripts/crystallize.md` 参照

## アクセスルール

- **日常の検索**: grepで関連キーワードを検索 → 最新1-2件だけ読む
- **全件分析**: 結晶化タスク（Surgical Workspace）のみ
- **書き込み**: 全環境のClaudeが追記可能（append-only）
