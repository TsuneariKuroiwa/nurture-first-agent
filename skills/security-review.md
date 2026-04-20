# Skill: Security Review

## Purpose
コードレビュー・設計レビュー時のセキュリティチェックリスト。
DRFプロジェクトのPRレビューおよびIoTデバイス開発に適用。

## Escalation Criteria

### 自律実行OK
- 明確なセキュリティ違反の指摘（ハードコード秘密鍵、SQLインジェクション等）
- チェックリストに基づく機械的チェック

### ユーザー確認が必要
- 認証・認可設計の変更
- セキュリティとユーザビリティのトレードオフ判断
- 本番環境に影響するセキュリティ設定

## Checklist — Web/API

### 1. Secrets Management
- [ ] 秘密情報は環境変数 or `.env` ファイル（gitignore済み）
- [ ] ハードコードされた鍵・パスワードがないか
- [ ] `.env.example` にダミー値のみ記載

### 2. Input Validation
- [ ] ユーザー入力はSerializerでバリデーション
- [ ] ファイルアップロードは種類・サイズを制限
- [ ] URLパラメータも検証

### 3. SQL Injection
- [ ] ORM使用（生SQLは `params` でパラメータ化）
- [ ] 文字列結合でクエリを組み立てていないか

### 4. Authentication & Authorization
- [ ] 全エンドポイントに `permission_classes` を明示
- [ ] オブジェクトレベル権限のチェック（自分のリソースのみ操作可能か）
- [ ] JWTは `httpOnly` cookie（localStorage はNG）

### 5. XSS Prevention
- [ ] ユーザー入力の出力時にエスケープ/サニタイズ
- [ ] `Content-Security-Policy` ヘッダー設定

### 6. CSRF Protection
- [ ] Django CSRF middleware 有効
- [ ] API認証がCookie-basedの場合、CSRFトークン必須

### 7. Rate Limiting
- [ ] 認証エンドポイントに厳しいレート制限
- [ ] 高コスト操作（メール送信等）にも制限

### 8. Sensitive Data
- [ ] ログにパスワード・トークンが含まれていないか
- [ ] エラーレスポンスに内部情報が漏れていないか
- [ ] DEBUG=False in production

## Checklist — IoT/Embedded

### 9. 通信セキュリティ
- [ ] HTTP → HTTPS（ESP32でもTLS可能）
- [ ] WiFi認証情報のハードコード回避
- [ ] OTAアップデート時の署名検証

### 10. 物理セキュリティ
- [ ] シリアルコンソールの無効化（本番デバイス）
- [ ] Flash暗号化の検討
- [ ] デバッグ用エンドポイントの削除

## Pre-Deploy Checklist
- [ ] SECRET_KEY は十分な長さのランダム値
- [ ] ALLOWED_HOSTS を明示的に設定
- [ ] HTTPS強制 (`SECURE_SSL_REDIRECT`)
- [ ] セキュリティヘッダー（HSTS, X-Frame-Options 等）
- [ ] 依存パッケージの脆弱性チェック (`pip audit`)

## User's Customizations
<!-- 対話を通じてユーザー固有のパターンを追加 -->

## Learned Patterns
<!-- 結晶化で追加 -->
