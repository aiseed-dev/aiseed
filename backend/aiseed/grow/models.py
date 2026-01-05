"""
栽培記録モデル
"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel


class Plant(BaseModel):
    """植物（栽培対象）"""
    id: str = ""
    user_id: str
    name: str  # 例: "ミニトマト", "バジル"
    variety: Optional[str] = None  # 品種
    started_at: Optional[datetime] = None  # 栽培開始日
    location: Optional[str] = None  # 場所（ベランダ、庭など）
    status: str = "growing"  # growing, harvested, ended
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
