---
name: pptx
description: "PowerPoint(.pptx)プレゼンテーションの作成・編集・読み込みスキル。スライドデッキ、ピッチデッキの新規作成、既存ファイルの編集、テンプレート操作に対応。トリガー: PowerPoint, .pptx, プレゼン, スライド, デッキ, 発表資料"
---

# PowerPoint(.pptx) スキル

## クイックリファレンス

| タスク | 手法 |
|--------|------|
| テキスト抽出 | `python -m markitdown presentation.pptx` |
| 既存ファイル編集 | ZIP展開 → XML編集 → 再パック |
| 新規作成 | pptxgenjs（JavaScript） |
| 画像変換（QA用） | LibreOffice → pdftoppm |

---

## 読み込み

```bash
# テキスト抽出
python -m markitdown presentation.pptx

# 画像変換（ビジュアル確認）
libreoffice --headless --convert-to pdf presentation.pptx
pdftoppm -jpeg -r 150 presentation.pdf slide
ls slide-*.jpg
```

---

## 新規作成（pptxgenjs）

`npm install -g pptxgenjs` でインストール後、JavaScriptで作成する。
テンプレートや参照ファイルがない場合に使用。

### 基本構造

```javascript
const pptxgen = require('pptxgenjs');
const pres = new pptxgen();

pres.defineLayout({ name: 'WIDE', width: 13.33, height: 7.5 }); // 16:9ワイド
pres.layout = 'WIDE';

const slide = pres.addSlide();
slide.addText('タイトル', { x: 0.5, y: 0.5, w: 12, h: 1.5,
  fontSize: 36, bold: true, color: '1E2761' });

pres.writeFile({ fileName: 'output.pptx' });
```

### テキスト

```javascript
slide.addText('本文テキスト', {
  x: 0.5, y: 2, w: 5, h: 3,
  fontSize: 14, color: '333333',
  fontFace: 'Calibri',
  valign: 'top',
  margin: 0,  // テキストボックスのパディング
});

// 複数スタイルの混在
slide.addText([
  { text: '太字部分', options: { bold: true, fontSize: 18 } },
  { text: '\n通常テキスト', options: { fontSize: 14 } },
], { x: 0.5, y: 2, w: 5, h: 3 });
```

### 図形

```javascript
// 矩形
slide.addShape(pres.ShapeType.rect, {
  x: 0.5, y: 0.5, w: 4, h: 3,
  fill: { color: 'D5E8F0' },
  line: { color: 'CCCCCC', width: 1 },
  rectRadius: 0.1,  // 角丸
});

// 線
slide.addShape(pres.ShapeType.line, {
  x: 0.5, y: 4, w: 12, h: 0,
  line: { color: '2E75B6', width: 2 },
});
```

### 画像

```javascript
slide.addImage({
  path: 'image.png',  // またはdata: base64文字列
  x: 6, y: 1, w: 6, h: 4,
  rounding: true,  // 角丸
});
```

### テーブル

```javascript
const rows = [
  [{ text: 'ヘッダー1', options: { bold: true, fill: { color: '2E75B6' }, color: 'FFFFFF' } },
   { text: 'ヘッダー2', options: { bold: true, fill: { color: '2E75B6' }, color: 'FFFFFF' } }],
  [{ text: 'データ1' }, { text: 'データ2' }],
];

slide.addTable(rows, {
  x: 0.5, y: 2, w: 12,
  fontSize: 12,
  border: { type: 'solid', pt: 0.5, color: 'CCCCCC' },
  colW: [6, 6],
});
```

### チャート

```javascript
slide.addChart(pres.charts.BAR, [
  { name: 'シリーズ1', labels: ['A', 'B', 'C'], values: [10, 20, 30] },
], {
  x: 0.5, y: 1.5, w: 6, h: 4,
  showTitle: true, title: 'サンプルチャート',
  showValue: true,
});
```

---

## 既存ファイルの編集

### 手順

1. **展開**: `unzip presentation.pptx -d unpacked/`
2. **構造確認**: `ls unpacked/ppt/slides/` でスライド一覧
3. **XML編集**: 各スライドの `slideN.xml` を編集
4. **再パック**: `cd unpacked && zip -r ../output.pptx . -x ".*"`

### スライドの複製・削除

スライドの追加/削除時は以下も更新が必要：
- `[Content_Types].xml`: スライドのContentType定義
- `ppt/_rels/presentation.xml.rels`: リレーションシップ
- `ppt/presentation.xml`: スライド参照

---

## デザインガイドライン

### カラーパレット

トピックに合った色を選ぶ。デフォルトの青は避ける。

| テーマ | メイン | サブ | アクセント |
|--------|--------|------|-----------|
| ダークエグゼクティブ | `1E2761` (紺) | `CADCFC` (氷青) | `FFFFFF` (白) |
| フォレスト | `2C5F2D` (深緑) | `97BC62` (苔) | `F5F5F5` (クリーム) |
| コーラル | `F96167` (珊瑚) | `F9E795` (金) | `2F3C7E` (紺) |
| オーシャン | `065A82` (深青) | `1C7293` (ティール) | `21295C` (夜) |
| チャコール | `36454F` (炭) | `F2F2F2` (オフ白) | `212121` (黒) |

配色ルール: 1色を60-70%メインに、1-2色をサブに、1色をアクセントに。全色を均等にしない。

### タイポグラフィ

| 要素 | サイズ |
|------|--------|
| スライドタイトル | 36-44pt 太字 |
| セクション見出し | 20-24pt 太字 |
| 本文 | 14-16pt |
| キャプション | 10-12pt |

フォントペア例: Georgia + Calibri, Arial Black + Arial, Cambria + Calibri

### レイアウトのバリエーション

全スライドで同じレイアウトを繰り返さない。以下を使い分ける：
- 2カラム（テキスト左、画像右）
- アイコン＋テキスト行
- 2x2 / 2x3 グリッド
- 大きな数値の強調（60-72pt）
- タイムライン/プロセスフロー
- 画像ハーフブリード

### よくあるNG

- テキストのみのスライド（画像・アイコン・チャートを必ず入れる）
- 本文の中央揃え（タイトルのみ中央、本文は左揃え）
- タイトル下のアクセント線（AI生成っぽく見える）
- コントラスト不足（背景と文字色の明暗差を確保）
- 余白不足（スライド端から0.5インチ以上、要素間0.3-0.5インチ）

---

## QA（必須）

### コンテンツ確認

```bash
python -m markitdown output.pptx
```

脱字、内容漏れ、順序間違いを確認。テンプレート使用時はプレースホルダーテキストの残りも確認。

### ビジュアル確認

1. スライドを画像に変換
2. 各画像を目視確認

チェック項目：
- 要素の重なり（テキスト×図形、線×文字）
- テキストのはみ出し・切れ
- 要素間の間隔不均一
- コントラスト不足
- スライド端からの余白不足

### 検証ループ

生成 → 画像変換 → 確認 → 修正 → 再確認。最低1回の修正→再確認サイクルを行うこと。

---

## 依存ライブラリ

- **pptxgenjs**: `npm install -g pptxgenjs`（新規作成）
- **markitdown**: `pip install "markitdown[pptx]"`（テキスト抽出）
- **Pillow**: `pip install Pillow`（サムネイル）
- **LibreOffice**: PDF変換
- **Poppler**: `pdftoppm` で画像変換
