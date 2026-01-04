"""
AIseed Global Settings
グローバル設定（公開可能な設定値）

秘匿情報は.envに、それ以外はここで管理
"""

# ===========================================
# AI Provider Configuration
# ===========================================

# 利用可能なプロバイダー
AI_PROVIDERS = {
    "anthropic": {
        "name": "Anthropic",
        "models": {
            "opus": "claude-opus-4-5-20250514",
            "sonnet": "claude-sonnet-4-20250514",
            "haiku": "claude-haiku-3-5-20250115",
        },
        "default_model": "opus",
    },
    "openai": {
        "name": "OpenAI",
        "models": {
            "gpt4": "gpt-4o",
            "gpt4-mini": "gpt-4o-mini",
        },
        "default_model": "gpt4",
    },
    "google": {
        "name": "Google",
        "models": {
            "gemini-pro": "gemini-1.5-pro",
            "gemini-flash": "gemini-1.5-flash",
        },
        "default_model": "gemini-pro",
    },
}

# 現在のプロバイダー設定
CURRENT_PROVIDER = "anthropic"

# ===========================================
# Model Assignment
# ===========================================
# 処理タイプごとのモデル設定
# (provider, model_key) のタプル、またはモデルキーのみ（現在のプロバイダーを使用）

MODEL_ASSIGNMENT = {
    # Heavy - 深い分析・対話
    "heavy": "opus",

    # Medium - 標準的な対話
    "medium": "opus",

    # Light - 軽い処理
    "light": "haiku",
}

# ===========================================
# Task Classification
# ===========================================
# 各処理がどのモデルタイプを使うか

TASK_CLASSIFICATION = {
    # Heavy
    "spark_conversation": "heavy",
    "analyze_conversation": "heavy",
    "analyze_strengths": "heavy",
    "generate_skill": "heavy",

    # Medium
    "grow_conversation": "medium",
    "create_conversation": "medium",
    "learn_conversation": "medium",
    "experience_feedback": "medium",

    # Light
    "get_user_profile": "light",
    "get_experience_tasks": "light",
    "get_skill": "light",
    "health_check": "light",
}

# ===========================================
# Logging Configuration
# ===========================================

LOG_LEVELS = {
    "root": "INFO",
    "aiseed.api": "INFO",
    "aiseed.agent": "INFO",
    "aiseed.memory": "WARNING",
    "aiseed.experience": "INFO",
}

LOG_FORMAT = "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"

# ===========================================
# Server Configuration
# ===========================================

SERVER = {
    "host": "0.0.0.0",
    "port": 8001,
}

# ===========================================
# Memory Configuration
# ===========================================

MEMORY = {
    "base_path": "user_memory",
}

# ===========================================
# Helper Functions
# ===========================================

def get_model_id(task_name: str, provider: str = None) -> str:
    """
    タスク名からモデルIDを取得

    Args:
        task_name: 処理名
        provider: プロバイダー名（省略時は CURRENT_PROVIDER）

    Returns:
        モデルID
    """
    provider = provider or CURRENT_PROVIDER
    provider_config = AI_PROVIDERS.get(provider, AI_PROVIDERS["anthropic"])

    # タスクからモデルタイプを取得
    model_type = TASK_CLASSIFICATION.get(task_name, "medium")

    # モデルタイプからモデルキーを取得
    model_key = MODEL_ASSIGNMENT.get(model_type, "opus")

    # モデルキーからIDを取得
    models = provider_config["models"]
    return models.get(model_key, list(models.values())[0])


def get_model_info(task_name: str, provider: str = None) -> dict:
    """
    タスク名からモデル情報を取得

    Returns:
        {"provider": str, "model_key": str, "model_id": str}
    """
    provider = provider or CURRENT_PROVIDER
    provider_config = AI_PROVIDERS.get(provider, AI_PROVIDERS["anthropic"])

    model_type = TASK_CLASSIFICATION.get(task_name, "medium")
    model_key = MODEL_ASSIGNMENT.get(model_type, "opus")
    model_id = provider_config["models"].get(model_key, list(provider_config["models"].values())[0])

    return {
        "provider": provider,
        "model_key": model_key,
        "model_id": model_id,
        "task_type": model_type,
    }
