# 結晶化チェックポイント手順書

Based on: NFD論文 Section 3.2 "Knowledge Crystallization Cycle"

## いつ実行するか

### 定期実行
- 毎週金曜 21:00 に自動実行（スケジュールタスク）

### 臨時トリガー
- 同一タグの経験ログが10件以上蓄積したとき
- ユーザーから明示的に指示されたとき
- 重大なエラーパターンが3件以上同カテゴリで発生したとき

## 結晶化の4フェーズ

### Phase 1: Pattern Extraction（パターン抽出）

```bash
cd ~/nurture-first-agent && git pull --rebase origin main
```

1. 前回の結晶化以降の全経験ログを読み込む
2. タグごとに分類・カウント
3. 3回以上繰り返されるパターンを候補として抽出
4. 特に [REASONING] タグのエントリから判断基準の一般化を試みる

**出力**: パターン候補リスト（各候補に根拠となるログエントリのリファレンス付き）

### Phase 2: Knowledge Structuring（知識構造化）

抽出したパターンを、対応する skills/ ファイルのフォーマットに整形する。

- Learned Patterns セクションに追加する形式で記述
- 各パターンに「適用条件」「期待される行動」「根拠（ログリファレンス）」を含める
- Error Cases セクションにはエラーパターンと回避策を記述

### Phase 3: De-contextualization（文脈除去・汎化）

構造化した知識から、特定の日時・PR番号・ファイル名など状況固有の情報を除去し、
再利用可能な一般原則に変換する。

例:
- Before: 「3/15のPR #42で、user_service.pyのN+1クエリを指摘した」
- After: 「SQLAlchemy ORMでリレーションを含むクエリでは、N+1問題を必ずチェックする」

**注意**: 汎化しすぎて意味が失われないよう、適用条件は具体的に残す。

### Phase 4: Validation（検証・承認）

#### 4a. 自動検証
- 抽出したパターンが経験コーパス全体と矛盾しないか確認
- 反例が存在する場合:
  - 条件を絞って矛盾を解消できるか試みる
  - 解消できなければ候補から除外し、理由を記録

#### 4b. Human Validation（ユーザー承認）
- 結晶化レポートをユーザーに提示
- ユーザーの承認を得てから skills/, constitutional/ を更新
- ユーザーの修正・却下は [REASONING] としてexperiential層に記録
  （結晶化プロセス自体も学習の対象）

## 結晶化レポートのテンプレート

```markdown
# 結晶化レポート YYYY-MM-DD

## 対象期間
YYYY-MM-DD 〜 YYYY-MM-DD

## 経験ログ統計
- 総エントリ数: N
- タグ別: [DECISION] X, [REASONING] X, [PATTERN] X, [ERROR] X, [CONTEXT] X, [INSIGHT] X

## 抽出されたパターン（承認待ち）

### パターン 1: [タイトル]
- **適用条件**: どういう状況で適用するか
- **行動指針**: 何をすべきか
- **根拠**: ログエントリ YYYY-MM-DD #N, YYYY-MM-DD #N
- **更新先**: skills/[ファイル名].md > [セクション名]

### パターン 2: ...

## 反例・矛盾が見つかったケース
- [記述]

## スキルファイル更新案
- skills/code-review.md: [変更概要]
- skills/xxx.md: [変更概要]

## Constitutional層の更新案（あれば）
- [変更概要]

## 次回までの課題
- [課題1]
- [課題2]
```

## Git操作

```bash
git add skills/ constitutional/ experiential/crystallization-report-*
git commit -m "crystallize: weekly checkpoint YYYY-MM-DD"
git push origin main
```
