"""
AIseed Model Configuration
処理の種類に応じてモデルを設定

使用方法:
1. .envで上書き可能
2. コード内で get_model(task_type) で取得
"""
from typing import Optional
from pydantic_settings import BaseSettings


class ModelConfig(BaseSettings):
    """モデル設定"""

    # ===========================================
    # 処理の分類とデフォルトモデル
    # ===========================================

    # heavy: 深い分析・対話・生成
    # - Spark会話（特性発見の対話）
    # - 会話分析（JSON抽出、特性抽出）
    # - スキル生成（BYOA用スキルファイル作成）
    # - レガシー分析
    model_heavy: str = "opus"

    # medium: 標準的な対話
    # - Grow会話（栽培・育児アドバイス）
    # - Create会話（BYOA対話）
    # - 体験タスクのフィードバック生成
    model_medium: str = "opus"

    # light: 軽い処理
    # - プロファイル取得（DB/JSONのみ、AI不使用）
    # - タスク一覧取得（静的データ）
    # - スキル取得（保存済みデータ取得）
    # - ヘルスチェック
    # 注: light処理の多くはAIを使わないため、このモデル設定は
    #     将来の拡張用（軽い要約生成など）
    model_light: str = "haiku"

    # ===========================================
    # 処理タイプのマッピング
    # ===========================================
    # 各エンドポイント/処理がどの分類に属するか

    class Config:
        env_file = ".env"
        env_prefix = "AISEED_"
        extra = "ignore"


# シングルトンインスタンス
_config: Optional[ModelConfig] = None


def get_config() -> ModelConfig:
    """設定を取得（シングルトン）"""
    global _config
    if _config is None:
        _config = ModelConfig()
    return _config


# ===========================================
# 処理タイプの定義
# ===========================================
class TaskType:
    """処理タイプの定数"""
    HEAVY = "heavy"
    MEDIUM = "medium"
    LIGHT = "light"


# 各処理と分類のマッピング
TASK_CLASSIFICATION = {
    # Heavy - 深い分析・対話
    "spark_conversation": TaskType.HEAVY,
    "analyze_conversation": TaskType.HEAVY,
    "analyze_strengths": TaskType.HEAVY,
    "generate_skill": TaskType.HEAVY,

    # Medium - 標準的な対話
    "grow_conversation": TaskType.MEDIUM,
    "create_conversation": TaskType.MEDIUM,
    "learn_conversation": TaskType.MEDIUM,  # Createにリダイレクト
    "experience_feedback": TaskType.MEDIUM,

    # Light - 軽い処理（多くはAI不使用）
    "get_user_profile": TaskType.LIGHT,
    "get_experience_tasks": TaskType.LIGHT,
    "get_skill": TaskType.LIGHT,
    "health_check": TaskType.LIGHT,
}


def get_model(task_name: str) -> str:
    """
    処理名からモデルを取得

    Args:
        task_name: 処理名（TASK_CLASSIFICATIONのキー）

    Returns:
        モデル名 (opus, sonnet, haiku)
    """
    config = get_config()

    task_type = TASK_CLASSIFICATION.get(task_name, TaskType.MEDIUM)

    if task_type == TaskType.HEAVY:
        return config.model_heavy
    elif task_type == TaskType.MEDIUM:
        return config.model_medium
    else:
        return config.model_light


def get_model_for_type(task_type: str) -> str:
    """
    処理タイプからモデルを取得

    Args:
        task_type: TaskType.HEAVY / MEDIUM / LIGHT

    Returns:
        モデル名 (opus, sonnet, haiku)
    """
    config = get_config()

    if task_type == TaskType.HEAVY:
        return config.model_heavy
    elif task_type == TaskType.MEDIUM:
        return config.model_medium
    else:
        return config.model_light


# ===========================================
# モデルID変換（Claude Code/API用）
# ===========================================
MODEL_IDS = {
    "opus": "claude-opus-4-5-20250514",
    "sonnet": "claude-sonnet-4-20250514",
    "haiku": "claude-haiku-3-5-20250115",
}


def get_model_id(model_name: str) -> str:
    """
    モデル名からIDを取得

    Args:
        model_name: opus, sonnet, haiku

    Returns:
        モデルID
    """
    return MODEL_IDS.get(model_name, MODEL_IDS["opus"])
