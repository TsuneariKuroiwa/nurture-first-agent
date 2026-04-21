---
name: xlsx
description: "Excel(.xlsx)ファイルの作成・編集・分析を行うスキル。スプレッドシートの読み込み、書式設定、数式、グラフ、データ分析に対応。トリガー: Excel, spreadsheet, .xlsx, .csv, データ表, 予算, 集計, グラフ, チャート"
---

# Excel(.xlsx) スキル

## 基本方針

### テンプレート編集時の鉄則
- 既存ファイルを編集する場合、フォーマット・スタイル・結合セル・列幅などを **絶対に壊さない**
- 既存テンプレートの慣例は、このスキルのガイドラインより常に優先する
- `data_only=True` で開いて保存すると数式が失われるため、編集時は使わない

### フォント
- 特に指示がなければ、一貫したプロフェッショナルなフォント（Arial, メイリオ, 游ゴシック等）を使用する

### 数式エラーゼロ
- 納品時に #REF!, #DIV/0!, #VALUE!, #N/A, #NAME? などのエラーが一切ないことを確認する

---

## ライブラリの使い分け

| 用途 | ライブラリ |
|------|-----------|
| データ分析・集計・可視化 | **pandas** |
| 書式設定・数式・セル結合・テンプレート編集 | **openpyxl** |

---

## 読み込み・分析（pandas）

```python
import pandas as pd

# 基本読み込み
df = pd.read_excel('file.xlsx')

# 全シート読み込み
all_sheets = pd.read_excel('file.xlsx', sheet_name=None)

# 型指定・日付パース
df = pd.read_excel('file.xlsx', dtype={'id': str}, parse_dates=['date_col'])

# 分析
df.head()
df.info()
df.describe()

# 書き出し
df.to_excel('output.xlsx', index=False)
```

---

## 新規作成（openpyxl）

```python
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side

wb = Workbook()
ws = wb.active
ws.title = 'Sheet1'

# データ入力
ws['A1'] = 'ヘッダー'
ws['A1'].font = Font(bold=True, size=11)
ws['A1'].alignment = Alignment(horizontal='center', vertical='center')

# 列幅
ws.column_dimensions['A'].width = 20

# 罫線
thin_border = Border(
    left=Side(style='thin'),
    right=Side(style='thin'),
    top=Side(style='thin'),
    bottom=Side(style='thin')
)
ws['A1'].border = thin_border

# セル結合
ws.merge_cells('A1:C1')

# 数式（Pythonで計算してハードコードしない！）
ws['B10'] = '=SUM(B2:B9)'
ws['C5'] = '=AVERAGE(C2:C4)'

wb.save('output.xlsx')
```

---

## 既存ファイル編集（openpyxl）

```python
from openpyxl import load_workbook

wb = load_workbook('existing.xlsx')
ws = wb.active  # または wb['シート名']

# 結合セルの確認
print(list(ws.merged_cells.ranges))

# セルの値を設定
ws['A1'] = '新しい値'

# 行・列の挿入/削除
ws.insert_rows(2)
ws.delete_cols(3)

# シート追加
new_ws = wb.create_sheet('新シート')

wb.save('modified.xlsx')
```

---

## 数式のルール

### ハードコード禁止
Pythonで計算した値をセルに書き込むのではなく、Excel数式を使う。
これによりスプレッドシートが動的に更新可能になる。

```python
# NG: Pythonで計算してハードコード
total = sum(values)
ws['B10'] = total

# OK: Excel数式を使う
ws['B10'] = '=SUM(B2:B9)'
```

### 前提値（Assumptions）の配置
- 成長率・マージン等の前提値は専用セルに置く
- 数式内にマジックナンバーを入れない
- 例: `=B5*(1+$B$6)` ○ / `=B5*1.05` ×

---

## 財務モデルの色分け規則

| 文字色 | 用途 |
|--------|------|
| 青 (0,0,255) | ハードコード入力値・シナリオ変更用の数値 |
| 黒 (0,0,0) | 数式・計算結果 |
| 緑 (0,128,0) | 同一ブック内の他シートからの参照 |
| 赤 (255,0,0) | 外部ファイルへのリンク |

| 背景色 | 用途 |
|--------|------|
| 黄 (255,255,0) | 要確認の前提値・更新が必要なセル |

---

## 数値フォーマット

| 種類 | フォーマット |
|------|-------------|
| 年 | テキスト（"2024" であり "2,024" ではない） |
| 通貨 | `#,##0` / `¥#,##0` |
| ゼロ | ダッシュ表示 `#,##0;(#,##0);"-"` |
| パーセント | `0.0%`（小数1桁） |
| 負数 | 括弧表示 `(123)` |

---

## 数式の検証チェックリスト

- [ ] サンプルとして2-3セルの参照が正しいか確認
- [ ] Excelの列番号とPythonのインデックスが一致しているか（列64 = BL）
- [ ] 行オフセット：Excel行は1始まり（DataFrame行5 = Excel行6）
- [ ] NaN処理：`pd.notna()` で null チェック
- [ ] ゼロ除算：分母が0になりうる数式に注意
- [ ] クロスシート参照：`Sheet1!A1` 形式の確認
- [ ] 結合セルへの書き込み：左上セルに書き込む

---

## LibreOfficeによる数式再計算（任意）

openpyxlで作成した数式は文字列として保存され、計算値は含まれない。
LibreOfficeがインストールされている環境では、以下で再計算が可能：

```bash
libreoffice --headless --calc --convert-to xlsx output.xlsx
```

---

## よくあるピットフォール

1. **`data_only=True` で開いて保存** → 数式が全て消える
2. **結合セルの左上以外に書き込み** → 値が反映されない
3. **大きなファイルを通常モードで開く** → メモリ不足。`read_only=True` / `write_only=True` を使う
4. **日付の型不一致** → `datetime` オブジェクトか文字列か統一する
5. **シート名に禁止文字** → `: \ / ? * [ ]` は使えない

---

## コードスタイル

- 簡潔に書く。冗長なコメントや変数名は不要
- 不要な print 文を避ける
- ハードコード値にはソースをコメントで記載する
