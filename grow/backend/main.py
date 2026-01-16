"""
Grow HP Builder - AIサーバー

内部テスト用のシンプルなAPIサーバー。
アプリからのリクエストを受けて、Claude MAXでHTMLを生成する。
"""

import subprocess
import json
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional

app = FastAPI(
    title="Grow HP Builder API",
    description="農家向けホームページ作成AIサーバー",
    version="0.1.0",
)

# CORS設定（内部テスト用）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 本番前に制限する
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class HpRequest(BaseModel):
    """HP作成リクエスト"""
    farm_name: Optional[str] = None
    farming_methods: list[str] = []
    plants: list[dict] = []
    user_request: str


class HpResponse(BaseModel):
    """HP作成レスポンス"""
    html: str
    success: bool
    error: Optional[str] = None


class ModifyRequest(BaseModel):
    """HP修正リクエスト"""
    current_html: str
    modification_request: str


def build_prompt(request: HpRequest) -> str:
    """リクエストからプロンプトを構築"""
    prompt = """あなたはプロのWebデザイナーです。
以下の農家情報を元に、販売用ホームページのHTMLを作成してください。

## 農家情報
"""
    if request.farm_name:
        prompt += f"\n**農園名**: {request.farm_name}\n"

    if request.farming_methods:
        prompt += f"\n**栽培方法**: {', '.join(request.farming_methods)}\n"

    if request.plants:
        prompt += "\n**栽培中の野菜**:\n"
        for plant in request.plants:
            name = plant.get('name', '不明')
            variety = plant.get('variety', '')
            days = plant.get('days_growing', 0)
            variety_str = f"（{variety}）" if variety else ""
            prompt += f"- {name}{variety_str} - 栽培{days}日目\n"

    prompt += f"""
## ユーザーの要望

{request.user_request}

## 出力形式

- 単一のHTMLファイル（CSS埋め込み）
- レスポンシブ対応（スマートフォン・タブレット・PC）
- 日本語
- 画像は images/ ディレクトリを参照（例: images/tomato.jpg）
- 美しく洗練されたデザイン
- Google Fontsを使用可

## 参考

以下のような構成を参考にしてください:
- ヒーローセクション（農園名、キャッチコピー）
- 私たちについて（栽培方法、こだわり）
- 今週の野菜（商品紹介）
- ギャラリー（畑の写真）
- お問い合わせ/購入方法
- フッター

HTMLのみを出力してください。説明は不要です。
"""
    return prompt


def build_modify_prompt(request: ModifyRequest) -> str:
    """修正プロンプトを構築"""
    return f"""以下のHTMLを修正してください。

## 修正の要望

{request.modification_request}

## 現在のHTML

```html
{request.current_html}
```

## 出力

修正後の完全なHTMLのみを出力してください。説明は不要です。
"""


def call_claude(prompt: str) -> str:
    """Claude Code CLIを呼び出してレスポンスを取得"""
    try:
        result = subprocess.run(
            ["claude", "-p", prompt, "--output-format", "text"],
            capture_output=True,
            text=True,
            timeout=120,  # 2分タイムアウト
        )

        if result.returncode != 0:
            raise Exception(f"Claude CLI error: {result.stderr}")

        return result.stdout.strip()
    except subprocess.TimeoutExpired:
        raise Exception("Claude CLI timeout")
    except FileNotFoundError:
        raise Exception("Claude CLI not found. Please install claude-code.")


def extract_html(response: str) -> str:
    """レスポンスからHTMLを抽出"""
    # ```html ... ``` で囲まれている場合は抽出
    if "```html" in response:
        start = response.find("```html") + 7
        end = response.find("```", start)
        if end > start:
            return response[start:end].strip()

    # ``` ... ``` で囲まれている場合
    if response.startswith("```") and response.endswith("```"):
        return response[3:-3].strip()

    # そのまま返す
    return response


@app.get("/")
async def root():
    """ヘルスチェック"""
    return {"status": "ok", "service": "Grow HP Builder API"}


@app.post("/api/hp/generate", response_model=HpResponse)
async def generate_hp(request: HpRequest):
    """ホームページHTMLを生成"""
    try:
        prompt = build_prompt(request)
        response = call_claude(prompt)
        html = extract_html(response)

        return HpResponse(html=html, success=True)
    except Exception as e:
        return HpResponse(html="", success=False, error=str(e))


@app.post("/api/hp/modify", response_model=HpResponse)
async def modify_hp(request: ModifyRequest):
    """ホームページHTMLを修正"""
    try:
        prompt = build_modify_prompt(request)
        response = call_claude(prompt)
        html = extract_html(response)

        return HpResponse(html=html, success=True)
    except Exception as e:
        return HpResponse(html="", success=False, error=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
