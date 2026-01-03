"""AIseed Configuration"""
from .models import (
    ModelConfig,
    TaskType,
    TASK_CLASSIFICATION,
    MODEL_IDS,
    get_config,
    get_model,
    get_model_for_type,
    get_model_id,
)

from .logging import (
    LogConfig,
    get_log_config,
    setup_logging,
    get_logger,
)

__all__ = [
    # Models
    "ModelConfig",
    "TaskType",
    "TASK_CLASSIFICATION",
    "MODEL_IDS",
    "get_config",
    "get_model",
    "get_model_for_type",
    "get_model_id",
    # Logging
    "LogConfig",
    "get_log_config",
    "setup_logging",
    "get_logger",
]
