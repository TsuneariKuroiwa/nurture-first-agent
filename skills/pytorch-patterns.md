# Skill: PyTorch Patterns

## Purpose
PyTorchを用いた深層学習の訓練・推論パイプラインにおけるベストプラクティス。
時系列データ・Foundation Model 等の研究プロジェクトに適用。

## Escalation Criteria

### 自律実行OK
- device-agnostic コードへの修正提案
- 既知のアンチパターンの指摘
- DataLoader最適化の提案

### ユーザー確認が必要
- モデルアーキテクチャの変更
- 学習ハイパーパラメータの決定
- 新しいloss関数・評価指標の選択

## Core Principles

1. **Device-Agnostic Code**: ハードコードせず `torch.device` で切り替え
2. **再現性**: seed設定を徹底（torch, numpy, random, CUDA）
3. **Shape管理**: テンソルの形状をコメントで明示

```python
# 再現性テンプレート
def set_seed(seed: int = 42):
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    np.random.seed(seed)
    random.seed(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False
```

## Model Architecture

- `nn.Module` を継承、`__init__` でレイヤー定義、`forward` で計算
- 重み初期化は `kaiming_normal_` (ReLU系) or `xavier_uniform_` (その他)
- forward内でshapeコメントを付ける: `# (B, T, C) -> (B, T, H)`

## Training Loop

```python
model.train()
for epoch in range(num_epochs):
    for batch in dataloader:
        optimizer.zero_grad(set_to_none=True)  # set_to_none=Trueが高速
        with torch.amp.autocast('cuda'):       # mixed precision
            loss = criterion(model(x), y)
        scaler.scale(loss).backward()
        scaler.unscale_(optimizer)
        torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
        scaler.step(optimizer)
        scaler.update()
```

## Validation Loop

```python
model.eval()
with torch.no_grad():  # 勾配計算を無効化
    for batch in val_loader:
        # ...
```

**絶対に `model.eval()` を忘れない** — BatchNorm/Dropoutの挙動が変わる。

## DataLoader最適化

```python
DataLoader(
    dataset,
    batch_size=64,
    num_workers=4,          # CPU数に応じて調整
    pin_memory=True,        # GPU転送高速化
    persistent_workers=True, # worker再生成コスト回避
    prefetch_factor=2,
)
```

## Checkpointing

```python
# 保存: model + optimizer + epoch + loss を全部含める
torch.save({
    'epoch': epoch,
    'model_state_dict': model.state_dict(),
    'optimizer_state_dict': optimizer.state_dict(),
    'loss': loss,
    'scaler': scaler.state_dict(),  # mixed precision使用時
}, path)

# 復元
checkpoint = torch.load(path, weights_only=False)
model.load_state_dict(checkpoint['model_state_dict'])
```

## Performance Tips

- **Mixed Precision** (`torch.amp`): メモリ削減 & 速度向上
- **Gradient Checkpointing**: 大モデルのメモリ節約（速度とトレードオフ）
- **torch.compile**: PyTorch 2.x の JIT コンパイル（`mode="reduce-overhead"` が安全）

## Anti-Patterns

| やりがち | 正しくは |
|---------|---------|
| `model.eval()` 忘れ | 推論前に必ず呼ぶ |
| ループ内で `.to(device)` | ループ前に1回だけ |
| `torch.save(model)` | `torch.save(model.state_dict())` |
| `.item()` を backward 前に呼ぶ | backward 後にのみ |
| in-place ops (`x += 1`) | autograd が壊れる。`x = x + 1` を使う |

## User's Customizations
<!-- 対話を通じてユーザー固有のパターンを追加 -->
<!-- 例: 時系列データのsliding window, variable length sequence処理 -->
<!-- 例: ご自身のGPU構成に合わせた最適化 -->

## Learned Patterns
<!-- 結晶化で追加 -->
