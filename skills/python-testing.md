# Skill: Python Testing

## Purpose
pytest によるテスト設計・実装のベストプラクティス。
DRF ベースのプロジェクトのPRレビューおよび研究コードの品質担保に使用。

## Escalation Criteria

### 自律実行OK
- テストコードのスタイル指摘
- fixture改善の提案
- parametrizeの追加提案

### ユーザー確認が必要
- テスト戦略の変更（unit/integration/e2e の比率）
- テスト対象の取捨選択
- モック方針の決定

## TDD Cycle

1. **Red**: 失敗するテストを書く
2. **Green**: テストが通る最小限のコードを書く
3. **Refactor**: コードを整理する（テストは緑のまま）

カバレッジ目標: 80%+, クリティカルパスは100%

## Fixtures

```python
import pytest

@pytest.fixture
def db_session():
    session = create_session()
    yield session        # テスト実行
    session.rollback()   # 後片付け

# scope でライフサイクル制御
@pytest.fixture(scope="module")
def expensive_resource():
    return load_large_dataset()
```

### conftest.py
共通fixture は `conftest.py` に配置。pytestが自動で読み込む。

## Parametrize

```python
@pytest.mark.parametrize("input,expected", [
    ("hello", 5),
    ("", 0),
    ("日本語", 3),
], ids=["ascii", "empty", "unicode"])
def test_length(input, expected):
    assert len(input) == expected
```

## Mocking

```python
from unittest.mock import patch, MagicMock

# 外部依存のモック
@patch("myapp.client.requests.get")
def test_fetch(mock_get):
    mock_get.return_value.json.return_value = {"data": 1}
    result = fetch_data()
    assert result == {"data": 1}

# autospec=True で引数チェックも行う
@patch("myapp.service.send_email", autospec=True)
def test_send(mock_send):
    process()
    mock_send.assert_called_once_with("user@example.com", subject="Done")
```

## Markers

```python
@pytest.mark.slow
def test_large_dataset(): ...

@pytest.mark.integration
@pytest.mark.django_db
def test_api_endpoint(): ...
```

```ini
# pyproject.toml
[tool.pytest.ini_options]
markers = [
    "slow: 実行に時間がかかるテスト",
    "integration: 外部依存を含むテスト",
]
```

## テスト構成

```
tests/
  conftest.py          # 共通fixture
  unit/
    test_models.py
    test_utils.py
  integration/
    test_api.py
    test_db.py
  e2e/
    test_workflow.py
```

## Best Practices

### DO
- 1テスト1アサーション（原則）
- テスト名は振る舞いを記述: `test_should_return_404_when_not_found`
- 外部依存はモック
- fixture で setup/teardown

### DON'T
- 実装の詳細をテストしない（振る舞いをテストする）
- テスト間で状態を共有しない
- テスト内で例外をキャッチしない（pytest.raises を使う）

## User's Customizations
<!-- 対話を通じてユーザー固有のパターンを追加 -->
<!-- 例: Django/DRF特有のテストパターン (APIClient, django_db) -->
<!-- 例: auth_client fixture のパターン -->

## Learned Patterns
<!-- 結晶化で追加 -->
