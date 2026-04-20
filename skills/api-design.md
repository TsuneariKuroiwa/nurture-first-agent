# Skill: API Design

## Purpose
REST API設計の標準パターン。
Django REST Framework ベースのプロジェクトのPRレビュー・設計判断に使用。

## Escalation Criteria

### 自律実行OK
- URL命名規則の指摘
- ステータスコード使い分けの指摘
- レスポンス形式の一貫性チェック

### ユーザー確認が必要
- 新しいエンドポイントの設計
- 認証・認可方式の決定
- API バージョニング戦略

## URL Design

```
# 基本形: 複数形 + kebab-case
GET    /api/answers/          # 一覧
POST   /api/answers/          # 作成
GET    /api/answers/{id}/     # 取得
PUT    /api/answers/{id}/     # 更新
DELETE /api/answers/{id}/     # 削除

# 子リソース
GET    /api/answers/{id}/reviews/

# クエリパラメータでフィルタ・ソート・ページネーション
GET    /api/answers/?subject=math&sort=-created_at&page=2
```

**URLに動詞を入れない** — HTTPメソッドで表現する。

## HTTP Status Codes

| コード | 用途 |
|--------|------|
| 200 | 成功（GET, PUT） |
| 201 | 作成成功（POST） |
| 204 | 成功・レスポンスなし（DELETE） |
| 400 | バリデーションエラー |
| 401 | 未認証 |
| 403 | 権限なし |
| 404 | リソースなし |
| 409 | 競合（重複作成など） |
| 429 | レート制限超過 |

## Response Format

```json
// 成功（単体）
{ "data": { "id": 1, "title": "..." } }

// 成功（一覧）
{
  "data": [...],
  "meta": { "total": 100, "page": 2, "per_page": 20 }
}

// エラー
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "入力内容に問題があります",
    "details": [
      { "field": "email", "message": "有効なメールアドレスを入力してください" }
    ]
  }
}
```

## Pagination

| 方式 | 特徴 | 使い分け |
|------|------|---------|
| **Offset-based** | シンプル、大量データで遅い | 管理画面、少量データ |
| **Cursor-based** | スケーラブル、一貫性あり | 公開API、無限スクロール |

## Authentication

- JWT は `httpOnly` cookie に格納（localStorage はXSS脆弱）
- APIキーはヘッダー: `Authorization: Bearer <token>`
- セッションベースも DRF では有効

## Rate Limiting

ヘッダーで残量を通知:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1623456789
```

## DRF Implementation Notes

```python
# ViewSet パターン
class AnswerViewSet(viewsets.ModelViewSet):
    queryset = Answer.objects.all()
    serializer_class = AnswerSerializer
    permission_classes = [IsAuthenticated]
    pagination_class = PageNumberPagination

# エラーレスポンスの一貫性
# non_field_errors vs field-level errors を統一する
```

## User's Customizations
<!-- 対話を通じてユーザー固有のパターンを追加 -->
<!-- 例: CustomGetObjectMixin の設計方針 -->
<!-- 例: permission_classes の使い分け基準 -->
<!-- 例: non_field_errors の一貫性ルール -->

## Learned Patterns
<!-- 結晶化で追加 -->
