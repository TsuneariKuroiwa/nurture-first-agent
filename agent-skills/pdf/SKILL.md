---
name: pdf
description: "PDF(.pdf)ファイルの読み込み・作成・結合・分割・フォーム記入・暗号化・OCRなど包括的なPDF処理スキル。トリガー: PDF, .pdf, フォーム, 結合, 分割, テキスト抽出, OCR"
---

# PDF処理スキル

## クイックリファレンス

| タスク | ベストツール | 備考 |
|--------|-------------|------|
| テキスト抽出 | pdfplumber | レイアウト保持に強い |
| テーブル抽出 | pdfplumber | pandas連携可 |
| 結合 | pypdf | PdfWriter.add_page() |
| 分割 | pypdf | ページ単位で出力 |
| 新規作成 | reportlab | Canvas / Platypus |
| コマンドライン操作 | qpdf | 結合・分割・暗号化 |
| OCR（スキャンPDF） | pytesseract + pdf2image | 画像変換してからOCR |
| フォーム記入 | pypdf | フォームフィールド操作 |

---

## Python ライブラリ

### pypdf — 基本操作

```python
from pypdf import PdfReader, PdfWriter

# 読み込み
reader = PdfReader("document.pdf")
print(f"ページ数: {len(reader.pages)}")

# テキスト抽出
for page in reader.pages:
    print(page.extract_text())

# メタデータ取得
meta = reader.metadata
print(f"タイトル: {meta.title}, 著者: {meta.author}")
```

#### 結合

```python
writer = PdfWriter()
for pdf_file in ["doc1.pdf", "doc2.pdf"]:
    reader = PdfReader(pdf_file)
    for page in reader.pages:
        writer.add_page(page)

with open("merged.pdf", "wb") as f:
    writer.write(f)
```

#### 分割

```python
reader = PdfReader("input.pdf")
for i, page in enumerate(reader.pages):
    writer = PdfWriter()
    writer.add_page(page)
    with open(f"page_{i+1}.pdf", "wb") as f:
        writer.write(f)
```

#### ページ回転

```python
reader = PdfReader("input.pdf")
writer = PdfWriter()
page = reader.pages[0]
page.rotate(90)  # 時計回り90度
writer.add_page(page)
with open("rotated.pdf", "wb") as f:
    writer.write(f)
```

#### パスワード保護

```python
reader = PdfReader("input.pdf")
writer = PdfWriter()
for page in reader.pages:
    writer.add_page(page)
writer.encrypt("userpass", "ownerpass")
with open("encrypted.pdf", "wb") as f:
    writer.write(f)
```

#### 透かし追加

```python
watermark = PdfReader("watermark.pdf").pages[0]
reader = PdfReader("document.pdf")
writer = PdfWriter()
for page in reader.pages:
    page.merge_page(watermark)
    writer.add_page(page)
with open("watermarked.pdf", "wb") as f:
    writer.write(f)
```

---

### pdfplumber — テキスト・テーブル抽出

```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        # テキスト
        print(page.extract_text())

        # テーブル
        for table in page.extract_tables():
            for row in table:
                print(row)
```

#### テーブルをExcelに変換

```python
import pandas as pd
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    all_tables = []
    for page in pdf.pages:
        for table in page.extract_tables():
            if table:
                df = pd.DataFrame(table[1:], columns=table[0])
                all_tables.append(df)
    if all_tables:
        pd.concat(all_tables, ignore_index=True).to_excel("output.xlsx", index=False)
```

---

### reportlab — PDF新規作成

#### 基本（Canvasベース）

```python
from reportlab.lib.pagesizes import letter, A4
from reportlab.pdfgen import canvas

c = canvas.Canvas("output.pdf", pagesize=A4)
width, height = A4

c.drawString(100, height - 100, "Hello World!")
c.line(100, height - 120, 400, height - 120)
c.save()
```

#### 複数ページ（Platypusベース）

```python
from reportlab.lib.pagesizes import A4
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
from reportlab.lib.styles import getSampleStyleSheet

doc = SimpleDocTemplate("report.pdf", pagesize=A4)
styles = getSampleStyleSheet()
story = []

story.append(Paragraph("レポートタイトル", styles['Title']))
story.append(Spacer(1, 12))
story.append(Paragraph("本文テキスト。" * 20, styles['Normal']))
story.append(PageBreak())
story.append(Paragraph("2ページ目", styles['Heading1']))

doc.build(story)
```

#### 上付き・下付き文字

**重要**: Unicode上付き/下付き文字（₀₁₂₃、⁰¹²³等）はreportlabの組み込みフォントで黒い四角に化ける。代わりにXMLタグを使う。

```python
# 下付き: <sub>
chemical = Paragraph("H<sub>2</sub>O", styles['Normal'])

# 上付き: <super>
squared = Paragraph("x<super>2</super>", styles['Normal'])
```

---

## コマンドラインツール

### pdftotext（poppler-utils）

```bash
pdftotext input.pdf output.txt           # テキスト抽出
pdftotext -layout input.pdf output.txt   # レイアウト保持
pdftotext -f 1 -l 5 input.pdf output.txt # ページ1-5
```

### qpdf

```bash
# 結合
qpdf --empty --pages file1.pdf file2.pdf -- merged.pdf

# 分割
qpdf input.pdf --pages . 1-5 -- pages1-5.pdf

# 回転
qpdf input.pdf output.pdf --rotate=+90:1

# パスワード解除
qpdf --password=mypass --decrypt encrypted.pdf decrypted.pdf
```

### 画像抽出

```bash
pdfimages -j input.pdf output_prefix
# → output_prefix-000.jpg, output_prefix-001.jpg, ...
```

---

## OCR（スキャンPDF）

```python
# pip install pytesseract pdf2image
import pytesseract
from pdf2image import convert_from_path

images = convert_from_path('scanned.pdf')
for i, image in enumerate(images):
    text = pytesseract.image_to_string(image, lang='jpn')  # 日本語の場合
    print(f"Page {i+1}:\n{text}")
```

日本語OCRには `tesseract-ocr-jpn` パッケージが必要。

---

## 依存ライブラリ

- **pypdf**: 結合・分割・回転・暗号化
- **pdfplumber**: テキスト・テーブル抽出
- **reportlab**: PDF新規作成
- **poppler-utils**: pdftotext, pdfimages, pdftoppm
- **qpdf**: コマンドライン操作
- **pytesseract + pdf2image**: OCR
