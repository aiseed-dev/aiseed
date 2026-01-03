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

__all__ = [
    "ModelConfig",
    "TaskType",
    "TASK_CLASSIFICATION",
    "MODEL_IDS",
    "get_config",
    "get_model",
    "get_model_for_type",
    "get_model_id",
]
