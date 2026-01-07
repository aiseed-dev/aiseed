"""
栽培記録モジュール

植物の観察記録を管理する

2つのモード:
- GrowService: ルールベース（AI不使用、低コスト）
- GrowAIService: AI分析（BYOA対応、高機能）
"""
from .service import GrowService
from .ai_service import GrowAIService, GrowthAnalysis, ProblemDiagnosis, HarvestPrediction
from .models import (
    Plant,
    Observation,
    PlantStats,
    PlantCreateRequest,
    ObservationCreateRequest,
)

__all__ = [
    "GrowService",
    "GrowAIService",
    "GrowthAnalysis",
    "ProblemDiagnosis",
    "HarvestPrediction",
    "Plant",
    "Observation",
    "PlantStats",
    "PlantCreateRequest",
    "ObservationCreateRequest",
]
