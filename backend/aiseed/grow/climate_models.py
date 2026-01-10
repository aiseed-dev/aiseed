"""
気候データモデル

ERA5から取得した気候データの構造定義
"""
from pydantic import BaseModel
from typing import Optional
from datetime import date


class MonthlyClimate(BaseModel):
    """月別気候データ"""
    month: int  # 1-12
    avg_temp: float  # 平均気温 (°C)
    min_temp: float  # 最低気温 (°C)
    max_temp: float  # 最高気温 (°C)
    precipitation: float  # 降水量 (mm)
    frost_days: int  # 霜日数
    sunshine_hours: Optional[float] = None  # 日照時間 (hours)


class GrowingCalendar(BaseModel):
    """栽培カレンダー情報"""
    last_frost: str  # 最終霜日 (MM-DD)
    first_frost: str  # 初霜日 (MM-DD)
    growing_season_days: int  # 栽培可能日数
    rainy_season_start: Optional[str] = None  # 梅雨入り (MM-DD)
    rainy_season_end: Optional[str] = None  # 梅雨明け (MM-DD)


class ClimateData(BaseModel):
    """気候データ（総合）"""
    location: dict  # {lat, lon, name}
    climate_zone: str  # ケッペン気候区分 (e.g., "Cfa")
    climate_zone_name_ja: str  # 日本語名 (e.g., "温暖湿潤気候")
    climate_zone_name_en: str  # 英語名 (e.g., "Humid subtropical")

    # 年間統計
    annual_avg_temp: float
    annual_precipitation: float
    frost_free_days: int

    # 月別データ
    monthly: list[MonthlyClimate]

    # 栽培カレンダー
    growing_calendar: GrowingCalendar

    # 栽培アドバイス
    recommendations: dict

    # データソース情報
    data_source: str = "ERA5"
    reference_period: str = "1991-2020"


class ClimateRequest(BaseModel):
    """気候データリクエスト"""
    lat: float
    lon: float
    location_name: Optional[str] = None


class ClimateSimpleResponse(BaseModel):
    """簡易気候レスポンス（Grow App向け）"""
    location_name: str
    climate_zone: str
    climate_zone_name: str

    # 栽培に重要な情報
    annual_avg_temp: float
    annual_precipitation: float
    last_frost: str
    first_frost: str
    growing_season_days: int

    # 季節の特徴（文字列）
    spring_note: str
    summer_note: str
    fall_note: str
    winter_note: str
