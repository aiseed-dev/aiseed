"""
栽培記録モデル
"""
from datetime import datetime
from typing import Optional, Literal
from pydantic import BaseModel


# ==================== 栽培方法の分類 ====================
# 参照: docs/natural_farming_classification.md

FarmingMethod = Literal[
    "undecided",           # 未定
    "natural_fukuoka",     # ① 自然農法（福岡正信）・リジェネラティブ
    "natural_okada",       # ② 自然農法（岡田茂吉）
    "natural_cultivation", # ③ 自然栽培
    "natural_farming",     # ④ 自然農
    "carbon_cycling",      # ⑤ 炭素循環農法
    "organic",             # ⑥ 一般有機農業
    "conventional",        # ⑦ 慣行農業
    "other",               # その他
]

FARMING_METHODS = {
    "undecided": {
        "name": "未定",
        "description": "まだ決めていない、または試行中",
        "approach": "",
        "microbes": "",
    },
    "natural_fukuoka": {
        "name": "自然農法（福岡正信）・リジェネラティブ",
        "description": "生きた植物・混植で光合成を最大化",
        "approach": "【交換】根からの炭素供給と土中ミネラルの交換",
        "microbes": "菌根菌・根圏微生物（共生ネットワーク）",
    },
    "natural_okada": {
        "name": "自然農法（岡田茂吉）",
        "description": "無肥料・連作で清浄化と適応",
        "approach": "【純化・特化】作物と微生物の高度な適応関係",
        "microbes": "固有微生物（作物特異的な共生菌群）",
    },
    "natural_cultivation": {
        "name": "自然栽培",
        "description": "無肥料・耕起で根圏を健全化",
        "approach": "【共生・適応】根圏の健全化と植物自身の適応",
        "microbes": "根圏微生物・内生菌（植物体内共生）",
    },
    "natural_farming": {
        "name": "自然農",
        "description": "草マルチ・不耕起で亡骸の層を作る",
        "approach": "【循環】地表分解物が時間差で地下へ供給",
        "microbes": "腐生菌・土壌動物（地表分解系）",
    },
    "carbon_cycling": {
        "name": "炭素循環農法",
        "description": "高炭素資材（チップ等）を投入",
        "approach": "【高炭素分解】窒素飢餓を通じた菌糸網形成",
        "microbes": "担子菌（木質分解菌・キノコ菌）",
    },
    "organic": {
        "name": "一般有機農業",
        "description": "堆肥・有機肥料を外部から投入",
        "approach": "【分解・無機化】投入有機物を可給化",
        "microbes": "分解バクテリア（無機化主体）",
    },
    "conventional": {
        "name": "慣行農業",
        "description": "化学肥料・農薬を使用",
        "approach": "外部投入による栄養供給",
        "microbes": "",
    },
    "other": {
        "name": "その他",
        "description": "上記以外の方法",
        "approach": "",
        "microbes": "",
    },
}


class Plant(BaseModel):
    """植物（栽培対象）"""
    id: str = ""
    user_id: str
    name: str  # 例: "ミニトマト", "バジル"
    variety: Optional[str] = None  # 品種
    started_at: Optional[datetime] = None  # 栽培開始日
    location: Optional[str] = None  # 場所（ベランダ、庭など）
    status: str = "growing"  # growing, harvested, ended

    # 栽培方法
    farming_method: Optional[str] = "undecided"  # 主な栽培方法
    farming_method_sub: Optional[str] = None     # サブの栽培方法（併用の場合）
    farming_method_notes: Optional[str] = None   # 栽培方法についてのメモ

    photo_url: Optional[str] = None
    notes: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class Observation(BaseModel):
    """観察記録"""
    id: str = ""
    plant_id: str
    user_id: str
    date: str  # YYYY-MM-DD
    time: Optional[str] = None  # HH:MM

    # 観察内容
    text: str  # 自由記述
    weather: Optional[str] = None  # 天気
    temperature: Optional[float] = None  # 気温
    watered: bool = False  # 水やりした
    fertilized: bool = False  # 肥料あげた
    harvested: bool = False  # 収穫した
    harvest_amount: Optional[str] = None  # 収穫量

    # 気づき（ルールベース or AI抽出）
    insights: list[str] = []

    # 写真
    photo_urls: list[str] = []

    created_at: Optional[datetime] = None


class PlantStats(BaseModel):
    """植物の統計"""
    plant_id: str
    observation_count: int = 0
    days_since_start: int = 0
    last_observation: Optional[str] = None
    total_harvests: int = 0
    streak_days: int = 0  # 連続観察日数


# ==================== リクエストモデル ====================

class PlantCreateRequest(BaseModel):
    """植物作成リクエスト"""
    user_id: str
    name: str
    variety: Optional[str] = None
    location: Optional[str] = None
    farming_method: Optional[str] = "undecided"  # 主な栽培方法
    farming_method_sub: Optional[str] = None     # サブの栽培方法（併用の場合）
    farming_method_notes: Optional[str] = None   # 栽培方法についてのメモ
    notes: Optional[str] = None


class ObservationCreateRequest(BaseModel):
    """観察記録作成リクエスト"""
    plant_id: str
    user_id: str
    text: str
    date: Optional[str] = None  # 未指定は今日
    time: Optional[str] = None
    weather: Optional[str] = None
    temperature: Optional[float] = None
    watered: bool = False
    fertilized: bool = False
    harvested: bool = False
    harvest_amount: Optional[str] = None
    photo_urls: list[str] = []


# ==================== AI分析リクエストモデル ====================

class GrowthAnalysisRequest(BaseModel):
    """成長分析リクエスト"""
    user_id: str
    plant_id: str
    recent_days: int = 7


class ProblemDiagnosisRequest(BaseModel):
    """問題診断リクエスト"""
    user_id: str
    plant_id: str
    problem_description: str  # 問題の説明


class HarvestPredictionRequest(BaseModel):
    """収穫予測リクエスト"""
    user_id: str
    plant_id: str
