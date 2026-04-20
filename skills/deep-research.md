# Skill: Deep Research

## Purpose
複数ソースからの深層リサーチと引用付きレポート生成。
学位論文・学会発表の先行研究調査、技術調査、意思決定資料の作成に使用。

## Escalation Criteria

### 自律実行OK
- 明確なキーワードでの文献検索
- 検索結果の要約

### ユーザー確認が必要
- 研究の方向性に影響する判断
- 先行研究の解釈・位置づけ
- レポートの結論部分

## 6-Step Workflow

### 1. Understand Goal
- ユーザーの質問・調査目的を明確化
- 「何がわかれば次に進めるか」を特定

### 2. Plan Sub-Questions
- 3-5個のサブ質問に分解
- 例: 「時系列データからのラベル分類」→
  - 既存手法は？（従来ML vs DL）
  - Foundation Modelのアプローチは？
  - どのデータセット・ベンチマークが標準？

### 3. Execute Multi-Source Search
- 各サブ質問に2-3のキーワードバリエーション
- 15-30ソースを収集
- **学術論文**: Google Scholar, Semantic Scholar, arXiv
- **技術情報**: GitHub, 公式ドキュメント, ブログ
- **一般情報**: Web検索

### 4. Deep-Read Key Sources
- 上位3-5件を精読
- 方法論・結果・限界を抽出

### 5. Synthesize Report
```markdown
## Executive Summary
[1-2段落]

## [テーマ別セクション]
- 主張 [出典]
- 比較・分析

## Key Takeaways
- 箇条書き

## Sources
1. [著者, タイトル, URL, 確認日]

## Methodology
- 検索キーワード、ソース数、期間
```

### 6. Deliver
- ユーザーに提示、追加調査の要否を確認

## Quality Rules

- **全ての主張にソースを付ける** — 引用なし主張は禁止
- **単一ソースの主張はクロスチェック**
- **最新情報を優先** — 過去12ヶ月以内
- **ギャップを認める** — 情報がない部分は明示
- **事実と推論を分離**

## Parallel Research

独立したサブ質問はAgentで並列実行可能:
```
Agent 1: 従来手法サーベイ
Agent 2: Foundation Modelサーベイ
Agent 3: データセット・ベンチマークサーベイ
→ 結果を統合してレポート
```

## User's Customizations
<!-- 対話を通じてユーザー固有のパターンを追加 -->
<!-- 例: バイオロギング分野の主要ジャーナル・カンファレンス -->
<!-- 例: 動物行動認識の主要研究グループ -->

## Learned Patterns
<!-- 結晶化で追加 -->
