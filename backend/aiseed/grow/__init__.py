"""
栽培記録モジュール

植物の観察記録を管理する

3つのサービス:
- GrowService: ルールベース（AI不使用、低コスト）
- GrowAIService: AI分析（BYOA対応、高機能）
- ClimateService: ERA5気候データ（AI不使用）
"""
from .service import GrowService
from .ai_service import GrowAIService, GrowthAnalysis, ProblemDiagnosis, HarvestPrediction
from .climate_service import ClimateService
from .climate_models import ClimateData, ClimateSimpleResponse, ClimateRequest
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
    "ClimateService",
    "GrowthAnalysis",
    "ProblemDiagnosis",
    "HarvestPrediction",
    "ClimateData",
    "ClimateSimpleResponse",
    "ClimateRequest",
    "Plant",
    "Observation",
    "PlantStats",
    "PlantCreateRequest",
    "ObservationCreateRequest",
]
