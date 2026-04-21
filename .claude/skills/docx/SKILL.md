---
name: docx
description: "Word文書(.docx)の作成・編集・読み込みを行うスキル。見出し、目次、表、画像、ヘッダー/フッター、変更履歴、コメントに対応。トリガー: Word, .docx, 報告書, レポート, メモ, レター, テンプレート, 文書作成"
---

# Word文書(.docx) スキル

## 基本知識

.docxファイルはXMLファイルを含むZIPアーカイブ。作成にはdocx-js（JavaScript）、読み込みにはpandoc、編集にはXML直接操作が最も確実。

## クイックリファレンス

| タスク | 手法 |
|--------|------|
| 読み込み・テキスト抽出 | `pandoc document.docx -o output.md` |
| 新規作成 | docx-js（JavaScript） |
| 既存テンプレートへの流し込み | **docxtpl**（推奨） |
| 既存ファイル編集 | ZIP展開 → XML編集 → 再パック |
| .doc → .docx 変換 | LibreOffice `--convert-to docx` |

---

## 読み込み

```bash
# テキスト抽出（変更履歴付き）
pandoc --track-changes=all document.docx -o output.md

# PDFへの変換
libreoffice --headless --convert-to pdf document.docx

# PDF → 画像変換
pdftoppm -jpeg -r 150 document.pdf page
```

---

## 新規作成（docx-js）

`npm install -g docx` でインストール後、JavaScriptで作成する。

### 基本構造

```javascript
const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
        ImageRun, Header, Footer, AlignmentType, PageOrientation,
        LevelFormat, ExternalHyperlink, HeadingLevel, BorderStyle,
        WidthType, ShadingType, PageNumber, PageBreak } = require('docx');
const fs = require('fs');

const doc = new Document({
  sections: [{
    properties: {
      page: {
        size: { width: 12240, height: 15840 },       // US Letter (DXA単位)
        margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } // 1インチ = 1440 DXA
      }
    },
    children: [/* コンテンツ */]
  }]
});

Packer.toBuffer(doc).then(buffer => fs.writeFileSync("output.docx", buffer));
```

### ページサイズ（DXA単位、1440 DXA = 1インチ）

| 用紙 | 幅 | 高さ | コンテンツ幅（余白1インチ） |
|------|-----|------|--------------------------|
| US Letter | 12,240 | 15,840 | 9,360 |
| A4（デフォルト） | 11,906 | 16,838 | 9,026 |

横向き（Landscape）の場合：短辺をwidth、長辺をheightに指定し、`orientation: PageOrientation.LANDSCAPE` を設定する。docx-jsが内部で幅と高さを入れ替える。

### スタイル定義

```javascript
const doc = new Document({
  styles: {
    default: { document: { run: { font: "Arial", size: 24 } } }, // 12pt
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal",
        quickFormat: true,
        run: { size: 32, bold: true, font: "Arial" },
        paragraph: { spacing: { before: 240, after: 240 }, outlineLevel: 0 } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal",
        quickFormat: true,
        run: { size: 28, bold: true, font: "Arial" },
        paragraph: { spacing: { before: 180, after: 180 }, outlineLevel: 1 } },
    ]
  },
  sections: [{ children: [
    new Paragraph({ heading: HeadingLevel.HEADING_1,
      children: [new TextRun("見出し1")] }),
  ]}]
});
```

**重要**: outlineLevelは目次（TOC）生成に必須（H1=0, H2=1, ...）。スタイルIDは組み込みIDと一致させる（"Heading1", "Heading2"）。

### 箇条書き・番号付きリスト

```javascript
// NG: Unicode箇条書き文字を手動入力
new Paragraph({ children: [new TextRun("• 項目")] })  // ダメ

// OK: numberingで定義
const doc = new Document({
  numbering: {
    config: [
      { reference: "bullets",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "\u2022",
          alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "numbers",
        levels: [{ level: 0, format: LevelFormat.DECIMAL, text: "%1.",
          alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
    ]
  },
  sections: [{ children: [
    new Paragraph({ numbering: { reference: "bullets", level: 0 },
      children: [new TextRun("箇条書き項目")] }),
  ]}]
});
```

同じreferenceを使うとナンバリングが継続、異なるreferenceにするとリセットされる。

### テーブル

```javascript
// 重要: テーブルにはcolumnWidthsとセルのwidthの両方を設定する
// WidthType.PERCENTAGEはGoogle Docsで崩れるため、必ずDXAを使う
const border = { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" };
const borders = { top: border, bottom: border, left: border, right: border };

new Table({
  width: { size: 9360, type: WidthType.DXA },
  columnWidths: [4680, 4680],  // 合計がテーブル幅と一致すること
  rows: [
    new TableRow({
      children: [
        new TableCell({
          borders,
          width: { size: 4680, type: WidthType.DXA },
          shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, // CLEARを使う（SOLIDは黒背景になる）
          margins: { top: 80, bottom: 80, left: 120, right: 120 },
          children: [new Paragraph({ children: [new TextRun("セル")] })]
        })
      ]
    })
  ]
})
```

### 画像

```javascript
new Paragraph({
  children: [new ImageRun({
    type: "png",  // 必須: png, jpg, jpeg, gif, bmp, svg
    data: fs.readFileSync("image.png"),
    transformation: { width: 200, height: 150 },
    altText: { title: "タイトル", description: "説明", name: "名前" } // 3つとも必須
  })]
})
```

### ページ区切り

```javascript
// PageBreakは必ずParagraph内に入れる
new Paragraph({ children: [new PageBreak()] })
// または
new Paragraph({ pageBreakBefore: true, children: [new TextRun("新ページ")] })
```

### ハイパーリンク

```javascript
// 外部リンク
new Paragraph({
  children: [new ExternalHyperlink({
    children: [new TextRun({ text: "リンクテキスト", style: "Hyperlink" })],
    link: "https://example.com",
  })]
})
```

### ヘッダー・フッター

```javascript
sections: [{
  headers: {
    default: new Header({ children: [
      new Paragraph({ children: [new TextRun("ヘッダーテキスト")] })
    ]})
  },
  footers: {
    default: new Footer({ children: [
      new Paragraph({ children: [
        new TextRun("ページ "),
        new TextRun({ children: [PageNumber.CURRENT] })
      ]})
    ]})
  },
  children: [/* コンテンツ */]
}]
```

### 目次

```javascript
// 目次はHeadingLevelのみ使用（カスタムスタイル不可）
new TableOfContents("目次", { hyperlink: true, headingStyleRange: "1-3" })
```

---

## テンプレートへの流し込み（docxtpl）

既存のWordテンプレートにデータを流し込む場合は **docxtpl** が最も確実。書式・表・画像が全て保持される。
`pip install docxtpl` でインストール。

### 基本的な使い方

テンプレート内に `{{ variable }}` のJinja2タグをプレースホルダーとして配置し、Pythonで値を渡す。

```python
from docxtpl import DocxTemplate, InlineImage
from docx.shared import Mm

doc = DocxTemplate("template.docx")
context = {
    "title": "報告書タイトル",
    "date": "2026年3月31日",
    "summary": "全体概要のテキスト...",
}
doc.render(context)
doc.save("output.docx")
```

### テーブル行のループ

テンプレート内で `{%tr for item in items %}` を使うと、表の行を動的に生成できる。

```
テンプレート側（Word内の表）:
| 発表者 | タイトル | 発表年月 |
| {%tr for p in presentations %} |
| {{ p.author }} | {{ p.title }} | {{ p.date }} |
| {%tr endfor %} |
```

```python
context = {
    "presentations": [
        {"author": "著者A ほか", "title": "サンプルタイトル1", "date": "2025年7月"},
        {"author": "著者A ほか", "title": "サンプルタイトル2", "date": "2025年11月"},
    ]
}
```

### 条件分岐

```
{% if has_change %}
ビジネスアイデアの変更あり: {{ change_description }}
{% else %}
変更なし
{% endif %}
```

### 画像の挿入

```python
from docxtpl import InlineImage
from docx.shared import Mm

context = {
    "chart": InlineImage(doc, "chart.png", width=Mm(150))
}
```

### 注意点

- Wordの「run」分断問題: `{{ name }}` がWordの自動整形で `{{ na` + `me }}` に分断されることがある。タグは一度に入力するか貼り付けで挿入する
- `{%- xxx -%}` タグは行に単独で置く
- テンプレート作成時にスタイル変更をタグの途中で行わない

### python-docxとの使い分け

| 場面 | 推奨 |
|------|------|
| 既存テンプレートにデータを流し込む | **docxtpl**（書式保持、表・画像対応） |
| ゼロから文書を構築する | docx-js or python-docx |
| テンプレートなしで既存ファイルを部分編集 | ZIP展開 → XML編集 |

**python-docxでテンプレート編集しようとしない。** セクション境界の検出やパラグラフ挿入時のインデックスずれで破綻しやすい。

---

## 既存ファイルの編集

### 手順

1. **展開**: `unzip document.docx -d unpacked/`
2. **XML編集**: `unpacked/word/document.xml` などを直接編集
3. **再パック**: `cd unpacked && zip -r ../output.docx . -x ".*"`

### 変更履歴（Tracked Changes）

```xml
<!-- 挿入 -->
<w:ins w:id="1" w:author="Claude" w:date="2025-01-01T00:00:00Z">
  <w:r><w:t>挿入テキスト</w:t></w:r>
</w:ins>

<!-- 削除 -->
<w:del w:id="2" w:author="Claude" w:date="2025-01-01T00:00:00Z">
  <w:r><w:delText>削除テキスト</w:delText></w:r>
</w:del>
```

**注意**: `<w:del>` 内では `<w:t>` ではなく `<w:delText>` を使う。

### コメント

```xml
<w:commentRangeStart w:id="0"/>
<w:r><w:t>コメント対象テキスト</w:t></w:r>
<w:commentRangeEnd w:id="0"/>
<w:r>
  <w:rPr><w:rStyle w:val="CommentReference"/></w:rPr>
  <w:commentReference w:id="0"/>
</w:r>
```

`commentRangeStart/End` は `<w:r>` の兄弟要素（中に入れない）。

---

## docx-js 重要ルール

- ページサイズを明示的に設定する（デフォルトはA4）
- `\n` は使わない。別の Paragraph 要素にする
- Unicode箇条書き文字を使わない。LevelFormat.BULLET を使う
- PageBreak は必ず Paragraph 内に入れる
- ImageRun には `type` パラメータが必須
- テーブル幅は常に `WidthType.DXA` を使う（PERCENTAGE は不可）
- テーブルには `columnWidths` と各セルの `width` の両方を設定する
- セルの背景色は `ShadingType.CLEAR` を使う（SOLID は黒背景になる）
- セルの margins はパディング（内側余白）であり、幅に加算されない
- テーブルを区切り線代わりに使わない（最低高さがあるため空箱になる）
- 目次は HeadingLevel のみ対応（カスタムスタイル不可）

---

## 依存ライブラリ

- **docx**: `npm install -g docx`（新規作成用）
- **docxtpl**: `pip install docxtpl`（テンプレート流し込み用）
- **pandoc**: テキスト抽出
- **LibreOffice**: PDF変換、.doc→.docx変換
- **Poppler**: `pdftoppm` で画像変換
