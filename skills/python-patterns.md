# Skill: Python Patterns

## Purpose
Pythonのイディオム・型ヒント・エラーハンドリング・並行処理のベストプラクティス。
ユーザーの主力言語（研究コード、Django、データ処理）全般に適用。

## Escalation Criteria

### 自律実行OK
- PEP 8準拠の指摘
- 型ヒントの追加提案
- 既知のアンチパターンの指摘

### ユーザー確認が必要
- パッケージ構成の変更
- 並行処理方式の選択
- 外部ライブラリの導入提案

## Core Philosophy

- **Readability counts**: 明示的 > 暗黙的
- **EAFP**: 許可より許しを求めよ（try/except > if チェック）
- **Flat is better than nested**: 早期returnでネストを減らす

## Type Hints

```python
# Python 3.9+: builtinをそのまま使える
def process(items: list[str]) -> dict[str, int]: ...

# Protocol: 構造的部分型（duck typing を型で表現）
from typing import Protocol

class Readable(Protocol):
    def read(self) -> str: ...
```

## Error Handling

```python
# 具体的な例外をキャッチ
try:
    result = parse(data)
except ValueError as e:
    logger.error("Parse failed: %s", e)
    raise  # 再送出は raise のみ（raise e だとトレースバックが切れる）

# カスタム例外は階層化
class AppError(Exception): ...
class ValidationError(AppError): ...
class NotFoundError(AppError): ...
```

## Context Managers

```python
from contextlib import contextmanager

@contextmanager
def timer(label: str):
    start = time.perf_counter()
    yield
    elapsed = time.perf_counter() - start
    print(f"{label}: {elapsed:.3f}s")
```

## Data Classes

```python
from dataclasses import dataclass, field

@dataclass
class ExperimentConfig:
    model_name: str
    lr: float = 1e-3
    epochs: int = 100
    tags: list[str] = field(default_factory=list)

    def __post_init__(self):
        if self.lr <= 0:
            raise ValueError(f"lr must be positive, got {self.lr}")
```

## Concurrency

| 方式 | 用途 |
|------|------|
| `threading` | I/O待ち（ファイル読み書き、HTTP） |
| `multiprocessing` | CPU-bound（データ前処理） |
| `asyncio` | 大量I/O並行（センサデータ収集） |

## Package Organization

```
src/
  mypackage/
    __init__.py
    core.py
    utils.py
tests/
  test_core.py
pyproject.toml
```

## Anti-Patterns

| やりがち | 正しくは |
|---------|---------|
| `def f(x, items=[])` | `def f(x, items=None)` でmutable default回避 |
| `except:` (bare) | `except Exception:` で最低限限定 |
| `type(x) == int` | `isinstance(x, int)` |
| `x == None` | `x is None` |
| 文字列結合のループ | `"".join(parts)` |

## Tooling

| ツール | 用途 |
|--------|------|
| **ruff** | linting + formatting (black/isort互換、高速) |
| **mypy** | 静的型チェック |
| **pytest** | テスト |
| **pyproject.toml** | 設定の一元管理 |

## User's Customizations
<!-- 対話を通じてユーザー固有のパターンを追加 -->
<!-- 例: numpy/pandas/scikit-learnバージョン互換性パターン -->

## Learned Patterns
<!-- 結晶化で追加 -->
