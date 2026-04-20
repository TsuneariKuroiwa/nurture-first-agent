# Skill: Database Migrations

## Purpose
データベースマイグレーションの安全な実行手順。
Django ORMを中心に、プロジェクトで適用。

## Escalation Criteria

### 自律実行OK
- マイグレーションファイルの内容レビュー
- 既知のアンチパターンの指摘

### ユーザー確認が必要
- 本番DBへのマイグレーション実行
- データマイグレーション（RunPython）の承認
- カラム削除・リネームなど不可逆操作

## Core Principles

1. **全ての変更はマイグレーション経由** — 手動SQLは禁止
2. **本番では forward-only** — rollback用のmigrationは別途作成
3. **スキーマ変更とデータ変更を分離** — 1マイグレーション1責務
4. **デプロイ済みマイグレーションは不変** — 修正は新規マイグレーションで

## Django Workflow

```bash
# 開発時
python manage.py makemigrations  # モデル変更からマイグレーション生成
python manage.py migrate         # 適用

# データマイグレーション
python manage.py makemigrations --empty myapp -n describe_change
```

```python
# データマイグレーション例
from django.db import migrations

def forwards(apps, schema_editor):
    MyModel = apps.get_model('myapp', 'MyModel')
    MyModel.objects.filter(status='old').update(status='new')

class Migration(migrations.Migration):
    dependencies = [('myapp', '0010_previous')]
    operations = [
        migrations.RunPython(forwards, migrations.RunPython.noop),
    ]
```

## Safety Checklist

| チェック | 理由 |
|---------|------|
| 新カラムは `null=True` or `default=` 付き | NOT NULL without default はテーブルロック |
| インデックス追加は小テーブルのみ即時 | 大テーブルはCONCURRENTLYで |
| カラム削除前にコードから参照を除去 | コード → マイグレーション の順 |
| データマイグレーションはバッチ処理 | 大量UPDATEはロック・メモリ問題 |

## Zero-Downtime Strategy (Expand-Contract)

カラムリネームの例:
1. **Expand**: 新カラム追加、両方に書き込み
2. **Migrate**: 旧→新にデータコピー
3. **Contract**: コードを新カラムに切替、旧カラム削除

## Anti-Patterns

| やりがち | 正しくは |
|---------|---------|
| 手動SQL | マイグレーションファイル経由 |
| デプロイ済みマイグレーション編集 | 新規マイグレーションを作成 |
| NOT NULL without default | `null=True` → データ埋め → NOT NULL |
| スキーマ+データ同時変更 | 別マイグレーションに分割 |
| コード削除前にカラム削除 | コード削除 → デプロイ → カラム削除 |

## User's Customizations
<!-- 対話を通じてユーザー固有のパターンを追加 -->

## Learned Patterns
<!-- 結晶化で追加 -->
