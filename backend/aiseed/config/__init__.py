"""AIseed Configuration"""

# Settings (公開設定)
from .settings import (
    AI_PROVIDERS,
    CURRENT_PROVIDER,
    MODEL_ASSIGNMENT,
    TASK_CLASSIFICATION,
    LOG_LEVELS,
    LOG_FORMAT,
    SERVER,
    MEMORY,
    get_model_id,
    get_model_info,
)

# Logging
from .logging import (
    setup_logging,
    get_logger,
)

__all__ = [
    # Settings
    "AI_PROVIDERS",
    "CURRENT_PROVIDER",
    "MODEL_ASSIGNMENT",
    "TASK_CLASSIFICATION",
    "LOG_LEVELS",
    "LOG_FORMAT",
    "SERVER",
    "MEMORY",
    "get_model_id",
    "get_model_info",
    # Logging
    "setup_logging",
    "get_logger",
]
