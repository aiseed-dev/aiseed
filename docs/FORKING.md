# 公開版の作り方

このリポジトリは**開発版**です。AIをフル活用してシナリオを開発し、パターンを抽出します。

公開版を作るには、このリポジトリをフォークして、AI使用箇所を置き換えてください。

---

## AI使用箇所一覧

### 高コスト（要置き換え）

| ファイル | 関数 | 用途 | 公開版での対応 |
|---------|------|------|---------------|
| `main.py` | `handle_conversation()` | 会話処理 | BYOA または テンプレート |
| `main.py` | `analyze_strengths()` | 強み分析 | ルールベース |
| `main.py` | `post_shipment_natural()` | 自然言語解析 | 構造化入力のみ |
| `agent/core.py` | `AIseedAgent.chat()` | AI会話 | BYOA |
| `agent/core.py` | `analyze_conversation()` | 会話分析 | ルールベース |

### 低コスト（そのまま使用可）

| ファイル | 機能 | 理由 |
|---------|------|------|
| `agent/tools/experience.py` | 体験タスク | ルールベース |
| `shipment/service.py` | 出荷情報管理 | データ操作のみ |
| `shipment/parser.py` | 自然言語パース | ルールベース（AIはフォールバック） |
| `community/service.py` | コミュニティ機能 | データ操作のみ |
| `memory/store.py` | ユーザーメモリ | データ操作のみ |

---

## 置き換え方法

### 1. BYOA（Bring Your Own AI）方式

ユーザーが自分のAPIキーを使う方式。運営コスト = 0

```python
# 開発版
response = await agent.chat(service, message, user_id)

# 公開版（BYOA）
user_api_key = get_user_api_key(user_id)  # ユーザーのAPIキー
response = await external_ai_query(message, api_key=user_api_key)
```

### 2. テンプレート方式

事前に生成したテンプレートを使う。運営コスト = 0

```python
# 開発版
response = await agent.chat("spark", message, user_id)

# 公開版（テンプレート）
template = select_template(message_type, user_context)
response = template.format(**user_data)
```

### 3. ルールベース方式

パターンマッチングで処理。運営コスト = 0

```python
# 開発版
shipment = await parse_with_ai(farmer_id, message, ai_query)

# 公開版（ルールベース）
shipment = parser.parse(farmer_id, message)  # 既存のルールベースパーサー
if not shipment:
    return {"error": "構造化入力を使ってください"}
```

### 4. OSS AI方式

ローカルで動くOSS AIを使う。初期コストあり、運営コスト = 低

```python
# 開発版
from claude_agent_sdk import query

# 公開版（OSS AI）
from llama_cpp import Llama
llm = Llama(model_path="./models/llama-3.2-1b.gguf")
response = llm(prompt)
```

---

## 推奨: 段階的な置き換え

### Phase 1: 構造化入力のみ

自然言語入力を無効化し、フォーム入力のみにする。

```python
# main.py の post_shipment_natural() を無効化
@app.post("/internal/shipment/post")
async def post_shipment_natural(request: ShipmentPostRequest):
    raise HTTPException(
        status_code=400,
        detail="公開版では構造化入力（/shipment/post/structured）を使ってください"
    )
```

### Phase 2: BYOA導入

ユーザーがAPIキーを設定すればAI機能を使える。

```python
# ユーザーのAPIキーをチェック
if user_has_api_key(user_id):
    response = await byoa_chat(message, user_id)
else:
    response = template_response(message_type)
```

### Phase 3: テンプレート充実

開発版で生成したパターンをテンプレート化。

```
templates/
├── spark/
│   ├── greeting.json
│   ├── feedback_patterns.json
│   └── strength_descriptions.json
├── grow/
│   └── observation_prompts.json
└── create/
    └── website_templates/
```

---

## ファイル構造

```
backend/aiseed/
├── agent/              # ← AI使用（公開版で置き換え）
│   ├── core.py         # AIseedAgent（AI会話）
│   ├── prompts.py      # プロンプト定義
│   └── tools/          # ツール群
├── shipment/           # ← 低コスト（そのまま使用可）
│   ├── service.py
│   └── parser.py       # ルールベースパーサー
├── community/          # ← 低コスト（そのまま使用可）
│   └── service.py
├── memory/             # ← 低コスト（そのまま使用可）
│   └── store.py
└── main.py             # ← エンドポイント（一部置き換え）
```

---

## 公開版のコスト構造

| 方式 | 初期コスト | 運営コスト | スケーラビリティ |
|------|-----------|-----------|----------------|
| BYOA | 低 | $0 | ◎ ユーザー負担 |
| テンプレート | 中（開発工数） | $0 | ◎ 静的 |
| ルールベース | 中 | $0 | ◎ 静的 |
| OSS AI | 高（サーバー） | 低 | △ サーバー依存 |

---

## チェックリスト

公開版を作る際のチェックリスト：

- [ ] `handle_conversation()` を BYOA/テンプレートに置き換え
- [ ] `analyze_strengths()` をルールベースに置き換え
- [ ] `post_shipment_natural()` を構造化入力に限定
- [ ] 不要なAIエンドポイントを無効化
- [ ] テンプレートファイルを作成
- [ ] BYOAのAPIキー管理を実装
- [ ] コスト監視を削除（不要）
- [ ] 広告表示を追加（任意）

---

## ライセンス

AGPL-3.0 により、公開版のソースコードも公開が必要です。
