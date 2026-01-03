"""
AIseed Logging Configuration
設定はsettings.pyで管理
"""
import logging
from .settings import LOG_LEVELS, LOG_FORMAT


def setup_logging():
    """ロギングを設定（settings.pyの設定を使用）"""
    formatter = logging.Formatter(LOG_FORMAT)

    # ルートロガーの設定
    root_level = getattr(logging, LOG_LEVELS.get("root", "INFO").upper(), logging.INFO)
    root_logger = logging.getLogger()
    root_logger.setLevel(root_level)

    # ハンドラーがなければ追加
    if not root_logger.handlers:
        handler = logging.StreamHandler()
        handler.setFormatter(formatter)
        root_logger.addHandler(handler)

    # 各モジュールのログレベルを設定
    for logger_name, level_str in LOG_LEVELS.items():
        if logger_name != "root":
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
