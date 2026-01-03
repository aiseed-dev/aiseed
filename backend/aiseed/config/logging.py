"""
AIseed Logging Configuration
モジュールごとにログレベルを設定
"""
import logging
from typing import Optional
from pydantic_settings import BaseSettings


class LogConfig(BaseSettings):
    """ログ設定"""

    # 各モジュールのログレベル
    log_level_root: str = "INFO"
    log_level_api: str = "INFO"
    log_level_agent: str = "INFO"
    log_level_memory: str = "WARNING"
    log_level_experience: str = "INFO"

    class Config:
        env_file = ".env"
        extra = "ignore"


# シングルトンインスタンス
_config: Optional[LogConfig] = None


def get_log_config() -> LogConfig:
    """ログ設定を取得"""
    global _config
    if _config is None:
        _config = LogConfig()
    return _config


# ロガー名とログレベル設定のマッピング
LOGGER_MAPPING = {
    "aiseed.api": "log_level_api",
    "aiseed.agent": "log_level_agent",
    "aiseed.memory": "log_level_memory",
    "aiseed.experience": "log_level_experience",
}


def setup_logging():
    """ロギングを設定"""
    config = get_log_config()

    # フォーマット
    log_format = "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"
    formatter = logging.Formatter(log_format)

    # ルートロガーの設定
    root_level = getattr(logging, config.log_level_root.upper(), logging.INFO)
    root_logger = logging.getLogger()
    root_logger.setLevel(root_level)

    # ハンドラーがなければ追加
    if not root_logger.handlers:
        handler = logging.StreamHandler()
        handler.setFormatter(formatter)
        root_logger.addHandler(handler)

    # 各モジュールのログレベルを設定
    for logger_name, config_attr in LOGGER_MAPPING.items():
        level_str = getattr(config, config_attr, "INFO")
        level = getattr(logging, level_str.upper(), logging.INFO)
        logging.getLogger(logger_name).setLevel(level)


def get_logger(name: str) -> logging.Logger:
    """
    ロガーを取得

    Args:
        name: ロガー名（例: "aiseed.api", "aiseed.agent"）

    Returns:
        設定済みのロガー
    """
    return logging.getLogger(name)
