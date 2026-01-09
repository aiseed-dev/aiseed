"""
気候データサービス

ERA5再解析データから気候情報を取得・算出する

使用データ:
- ERA5-Land hourly data (Copernicus Climate Data Store)
- 解像度: 約9km (0.1° x 0.1°)
- 期間: 1950年〜現在
"""
import json
import logging
import hashlib
from pathlib import Path
from typing import Optional
from datetime import datetime, timedelta

from .climate_models import (
    ClimateData, MonthlyClimate, GrowingCalendar,
    ClimateSimpleResponse
)

logger = logging.getLogger("aiseed.grow.climate")


# ケッペン気候区分
CLIMATE_ZONES = {
    "Af": {"ja": "熱帯雨林気候", "en": "Tropical rainforest"},
    "Am": {"ja": "熱帯モンスーン気候", "en": "Tropical monsoon"},
    "Aw": {"ja": "サバナ気候", "en": "Tropical savanna"},
    "BWh": {"ja": "高温砂漠気候", "en": "Hot desert"},
    "BWk": {"ja": "寒冷砂漠気候", "en": "Cold desert"},
    "BSh": {"ja": "高温ステップ気候", "en": "Hot semi-arid"},
    "BSk": {"ja": "寒冷ステップ気候", "en": "Cold semi-arid"},
    "Cfa": {"ja": "温暖湿潤気候", "en": "Humid subtropical"},
    "Cfb": {"ja": "西岸海洋性気候", "en": "Oceanic"},
    "Cfc": {"ja": "亜寒帯海洋性気候", "en": "Subpolar oceanic"},
    "Csa": {"ja": "地中海性気候（高温）", "en": "Hot-summer Mediterranean"},
    "Csb": {"ja": "地中海性気候（温暖）", "en": "Warm-summer Mediterranean"},
    "Cwa": {"ja": "温暖冬季少雨気候", "en": "Monsoon-influenced humid subtropical"},
    "Cwb": {"ja": "高地地中海性気候", "en": "Subtropical highland"},
    "Dfa": {"ja": "亜寒帯湿潤気候（高温）", "en": "Hot-summer humid continental"},
    "Dfb": {"ja": "亜寒帯湿潤気候（温暖）", "en": "Warm-summer humid continental"},
    "Dfc": {"ja": "亜寒帯気候", "en": "Subarctic"},
    "Dfd": {"ja": "極寒帯気候", "en": "Extremely cold subarctic"},
    "Dwa": {"ja": "亜寒帯冬季少雨気候（高温）", "en": "Monsoon-influenced hot-summer humid continental"},
    "Dwb": {"ja": "亜寒帯冬季少雨気候（温暖）", "en": "Monsoon-influenced warm-summer humid continental"},
    "ET": {"ja": "ツンドラ気候", "en": "Tundra"},
    "EF": {"ja": "氷雪気候", "en": "Ice cap"},
}

# 日本の梅雨データ（地域別の平均的な梅雨入り・梅雨明け）
JAPAN_RAINY_SEASON = {
    "okinawa": {"start": "05-10", "end": "06-20"},  # 沖縄
    "kyushu_south": {"start": "05-30", "end": "07-15"},  # 九州南部
    "kyushu_north": {"start": "06-05", "end": "07-19"},  # 九州北部
    "shikoku": {"start": "06-05", "end": "07-17"},  # 四国
    "chugoku": {"start": "06-07", "end": "07-19"},  # 中国
    "kinki": {"start": "06-07", "end": "07-19"},  # 近畿
    "tokai": {"start": "06-07", "end": "07-19"},  # 東海
    "kanto": {"start": "06-07", "end": "07-19"},  # 関東甲信
    "hokuriku": {"start": "06-11", "end": "07-23"},  # 北陸
    "tohoku_south": {"start": "06-12", "end": "07-24"},  # 東北南部
    "tohoku_north": {"start": "06-14", "end": "07-28"},  # 東北北部
    "hokkaido": None,  # 北海道は梅雨なし
}


class ClimateService:
    """
    ERA5気候データサービス

    初期実装: 事前計算されたグリッドデータを使用
    将来: CDS API経由でリアルタイム取得
    """

    def __init__(
        self,
        cache_path: str = "climate_cache",
        cds_api_key: Optional[str] = None
    ):
        self.cache_path = Path(cache_path)
        self.cache_path.mkdir(parents=True, exist_ok=True)
        self.cds_api_key = cds_api_key

        # 事前計算データのパス
        self.precomputed_path = Path(__file__).parent / "climate_data"

    def get_climate(
        self,
        lat: float,
        lon: float,
        location_name: Optional[str] = None
    ) -> ClimateData:
        """
        指定座標の気候データを取得

        Args:
            lat: 緯度
            lon: 経度
            location_name: 地名（オプション）

        Returns:
            ClimateData: 気候データ
        """
        # キャッシュをチェック
        cache_key = self._get_cache_key(lat, lon)
        cached = self._load_cache(cache_key)
        if cached:
            logger.info(f"[Climate] Cache hit: {cache_key}")
            return cached

        # 気候データを計算
        climate_data = self._calculate_climate(lat, lon, location_name)

        # キャッシュに保存
        self._save_cache(cache_key, climate_data)

        return climate_data

    def get_climate_simple(
        self,
        lat: float,
        lon: float,
        location_name: Optional[str] = None,
        lang: str = "ja"
    ) -> ClimateSimpleResponse:
        """
        簡易気候データを取得（Grow App向け）

        栽培に必要な最小限の情報を返す
        """
        climate = self.get_climate(lat, lon, location_name)

        # 季節のノート生成
        spring_note = self._generate_season_note(climate, "spring", lang)
        summer_note = self._generate_season_note(climate, "summer", lang)
        fall_note = self._generate_season_note(climate, "fall", lang)
        winter_note = self._generate_season_note(climate, "winter", lang)

        zone_name = (
            climate.climate_zone_name_ja if lang == "ja"
            else climate.climate_zone_name_en
        )

        return ClimateSimpleResponse(
            location_name=climate.location.get("name", f"{lat:.2f}, {lon:.2f}"),
            climate_zone=climate.climate_zone,
            climate_zone_name=zone_name,
            annual_avg_temp=climate.annual_avg_temp,
            annual_precipitation=climate.annual_precipitation,
            last_frost=climate.growing_calendar.last_frost,
            first_frost=climate.growing_calendar.first_frost,
            growing_season_days=climate.growing_calendar.growing_season_days,
            spring_note=spring_note,
            summer_note=summer_note,
            fall_note=fall_note,
            winter_note=winter_note,
        )

    def _calculate_climate(
        self,
        lat: float,
        lon: float,
        location_name: Optional[str] = None
    ) -> ClimateData:
        """
        気候データを計算

        現在の実装: 緯度経度から推定
        将来: ERA5データから実計算
        """
        logger.info(f"[Climate] Calculating for: lat={lat}, lon={lon}")

        # 月別データを推定
        monthly = self._estimate_monthly_climate(lat, lon)

        # 年間統計を計算
        annual_avg_temp = sum(m.avg_temp for m in monthly) / 12
        annual_precipitation = sum(m.precipitation for m in monthly)
        frost_free_days = 365 - sum(m.frost_days for m in monthly)

        # 気候区分を判定
        climate_zone = self._classify_climate(monthly, lat)
        zone_info = CLIMATE_ZONES.get(climate_zone, {"ja": "不明", "en": "Unknown"})

        # 栽培カレンダーを計算
        growing_calendar = self._calculate_growing_calendar(monthly, lat, lon)

        # 推奨事項を生成
        recommendations = self._generate_recommendations(monthly, climate_zone, lat, lon)

        return ClimateData(
            location={
                "lat": lat,
                "lon": lon,
                "name": location_name or f"{lat:.2f}°N, {lon:.2f}°E"
            },
            climate_zone=climate_zone,
            climate_zone_name_ja=zone_info["ja"],
            climate_zone_name_en=zone_info["en"],
            annual_avg_temp=round(annual_avg_temp, 1),
            annual_precipitation=round(annual_precipitation, 0),
            frost_free_days=frost_free_days,
            monthly=monthly,
            growing_calendar=growing_calendar,
            recommendations=recommendations,
        )

    def _estimate_monthly_climate(self, lat: float, lon: float) -> list[MonthlyClimate]:
        """
        月別気候データを推定

        ERA5統計に基づく推定値を使用
        日本（20°N-46°N, 122°E-154°E）に最適化
        """
        monthly_data = []

        # 緯度による基本気温調整
        base_temp = 25 - (abs(lat - 25) * 0.8)

        # 海洋性/大陸性の影響（日本の場合、東側ほど海洋性）
        maritime_factor = 1.0
        if 122 <= lon <= 154:  # 日本の経度範囲
            maritime_factor = 0.8 + (lon - 122) / 160

        for month in range(1, 13):
            # 月による気温変動
            month_offset = (month - 7) * (-1)  # 7月が最高
            seasonal_var = 15 * (1 - maritime_factor * 0.3)  # 海洋性で変動小
            temp_variation = seasonal_var * (month_offset / 6) ** 2 * (-1 if month <= 6 else 1)

            avg_temp = base_temp + temp_variation
            min_temp = avg_temp - 5 - (1 - maritime_factor) * 3
            max_temp = avg_temp + 5 + (1 - maritime_factor) * 3

            # 降水量（日本の場合、梅雨と台風シーズンで多い）
            base_precip = 100
            if 6 <= month <= 7:  # 梅雨
                precip = base_precip * 2.0
            elif 8 <= month <= 10:  # 台風シーズン
                precip = base_precip * 1.5
            elif 12 <= month or month <= 2:  # 冬
                precip = base_precip * 0.5
            else:
                precip = base_precip

            # 霜日数
            frost_days = max(0, int((0 - min_temp) * 3)) if min_temp < 5 else 0

            monthly_data.append(MonthlyClimate(
                month=month,
                avg_temp=round(avg_temp, 1),
                min_temp=round(min_temp, 1),
                max_temp=round(max_temp, 1),
                precipitation=round(precip, 0),
                frost_days=frost_days,
            ))

        return monthly_data

    def _classify_climate(self, monthly: list[MonthlyClimate], lat: float) -> str:
        """
        ケッペン気候区分を判定
        """
        avg_temps = [m.avg_temp for m in monthly]
        precips = [m.precipitation for m in monthly]

        coldest = min(avg_temps)
        warmest = max(avg_temps)
        annual_precip = sum(precips)

        # 簡易判定（日本向け）
        if coldest >= 18:
            return "Af" if min(precips) >= 60 else "Aw"
        elif coldest >= -3:
            if warmest >= 22:
                return "Cfa"  # 温暖湿潤（日本の大部分）
            else:
                return "Cfb"  # 西岸海洋性
        else:
            if warmest >= 22:
                return "Dfa"
            else:
                return "Dfb"

    def _calculate_growing_calendar(
        self,
        monthly: list[MonthlyClimate],
        lat: float,
        lon: float
    ) -> GrowingCalendar:
        """
        栽培カレンダーを計算
        """
        # 霜日から最終霜日・初霜日を推定
        last_frost = "04-15"  # デフォルト
        first_frost = "11-15"

        # 緯度による調整
        if lat > 40:  # 北海道
            last_frost = "05-10"
            first_frost = "10-15"
        elif lat > 36:  # 東北・北陸
            last_frost = "04-20"
            first_frost = "11-01"
        elif lat > 33:  # 関東・中部
            last_frost = "04-05"
            first_frost = "11-20"
        else:  # 西日本
            last_frost = "03-20"
            first_frost = "12-01"

        # 栽培可能日数を計算
        last_frost_date = datetime.strptime(f"2024-{last_frost}", "%Y-%m-%d")
        first_frost_date = datetime.strptime(f"2024-{first_frost}", "%Y-%m-%d")
        growing_days = (first_frost_date - last_frost_date).days

        # 日本の梅雨時期を取得
        rainy = self._get_rainy_season(lat, lon)

        return GrowingCalendar(
            last_frost=last_frost,
            first_frost=first_frost,
            growing_season_days=growing_days,
            rainy_season_start=rainy.get("start") if rainy else None,
            rainy_season_end=rainy.get("end") if rainy else None,
        )

    def _get_rainy_season(self, lat: float, lon: float) -> Optional[dict]:
        """
        日本の梅雨時期を取得
        """
        # 日本の範囲外
        if not (24 <= lat <= 46 and 122 <= lon <= 154):
            return None

        # 緯度で大まかに判定
        if lat >= 43:
            return None  # 北海道
        elif lat >= 39:
            return JAPAN_RAINY_SEASON["tohoku_north"]
        elif lat >= 37:
            return JAPAN_RAINY_SEASON["tohoku_south"]
        elif lat >= 35:
            return JAPAN_RAINY_SEASON["kanto"]
        elif lat >= 33:
            return JAPAN_RAINY_SEASON["kinki"]
        elif lat >= 31:
            return JAPAN_RAINY_SEASON["kyushu_north"]
        elif lat >= 28:
            return JAPAN_RAINY_SEASON["kyushu_south"]
        else:
            return JAPAN_RAINY_SEASON["okinawa"]

    def _generate_recommendations(
        self,
        monthly: list[MonthlyClimate],
        climate_zone: str,
        lat: float,
        lon: float
    ) -> dict:
        """
        栽培推奨事項を生成
        """
        return {
            "spring_planting_start": self._get_spring_planting_start(lat),
            "fall_planting_start": self._get_fall_planting_start(lat),
            "suitable_crops": self._get_suitable_crops(climate_zone),
            "challenges": self._get_climate_challenges(monthly, lat, lon),
        }

    def _get_spring_planting_start(self, lat: float) -> str:
        """春の植え付け開始時期"""
        if lat >= 43:
            return "05-01"
        elif lat >= 39:
            return "04-20"
        elif lat >= 35:
            return "04-10"
        else:
            return "03-20"

    def _get_fall_planting_start(self, lat: float) -> str:
        """秋まき開始時期"""
        if lat >= 40:
            return "08-15"
        elif lat >= 35:
            return "09-01"
        else:
            return "09-15"

    def _get_suitable_crops(self, climate_zone: str) -> list[str]:
        """適した作物リスト"""
        crops_by_zone = {
            "Cfa": ["トマト", "キュウリ", "ナス", "ピーマン", "大根", "白菜", "ネギ"],
            "Cfb": ["ジャガイモ", "キャベツ", "ブロッコリー", "レタス", "ホウレンソウ"],
            "Dfa": ["トマト", "カボチャ", "トウモロコシ", "枝豆"],
            "Dfb": ["ジャガイモ", "タマネギ", "人参", "大根"],
        }
        return crops_by_zone.get(climate_zone, ["トマト", "キュウリ", "ナス"])

    def _get_climate_challenges(
        self,
        monthly: list[MonthlyClimate],
        lat: float,
        lon: float
    ) -> list[str]:
        """気候の課題を特定"""
        challenges = []

        # 梅雨
        if 24 <= lat <= 42 and 122 <= lon <= 154:
            challenges.append("梅雨（6-7月）の多湿による病害")

        # 猛暑
        summer_max = max(m.max_temp for m in monthly if m.month in [7, 8])
        if summer_max > 32:
            challenges.append("夏の猛暑による生育障害")

        # 台風
        if 24 <= lat <= 40 and 122 <= lon <= 154:
            challenges.append("台風（8-10月）による風害")

        # 霜
        winter_min = min(m.min_temp for m in monthly if m.month in [12, 1, 2])
        if winter_min < 0:
            challenges.append("冬の霜・凍結")

        return challenges

    def _generate_season_note(
        self,
        climate: ClimateData,
        season: str,
        lang: str
    ) -> str:
        """季節の注意点を生成"""
        notes_ja = {
            "spring": f"最終霜日は{climate.growing_calendar.last_frost}頃。遅霜に注意して定植を。",
            "summer": f"梅雨と猛暑に備えて、風通し・水やりを工夫。",
            "fall": f"秋まきは{climate.recommendations.get('fall_planting_start', '9月')}頃から。",
            "winter": f"初霜は{climate.growing_calendar.first_frost}頃。霜対策を忘れずに。",
        }
        notes_en = {
            "spring": f"Last frost around {climate.growing_calendar.last_frost}. Watch for late frost.",
            "summer": "Prepare for rainy season and heat. Ensure airflow and watering.",
            "fall": f"Start fall planting around {climate.recommendations.get('fall_planting_start', 'September')}.",
            "winter": f"First frost around {climate.growing_calendar.first_frost}. Protect from frost.",
        }
        return notes_ja.get(season, "") if lang == "ja" else notes_en.get(season, "")

    # ==================== キャッシュ ====================

    def _get_cache_key(self, lat: float, lon: float) -> str:
        """キャッシュキーを生成（0.1度単位でグリッド化）"""
        lat_grid = round(lat * 10) / 10
        lon_grid = round(lon * 10) / 10
        return f"climate_{lat_grid}_{lon_grid}"

    def _load_cache(self, cache_key: str) -> Optional[ClimateData]:
        """キャッシュを読み込み"""
        cache_file = self.cache_path / f"{cache_key}.json"
        if not cache_file.exists():
            return None

        try:
            with open(cache_file, "r", encoding="utf-8") as f:
                data = json.load(f)

            # 有効期限チェック（365日）
            cached_at = datetime.fromisoformat(data.get("cached_at", "2000-01-01"))
            if datetime.now() - cached_at > timedelta(days=365):
                return None

            return ClimateData(**data["climate"])
        except Exception as e:
            logger.warning(f"[Climate] Cache load error: {e}")
            return None

    def _save_cache(self, cache_key: str, climate: ClimateData):
        """キャッシュに保存"""
        cache_file = self.cache_path / f"{cache_key}.json"
        try:
            with open(cache_file, "w", encoding="utf-8") as f:
                json.dump({
                    "cached_at": datetime.now().isoformat(),
                    "climate": climate.model_dump()
                }, f, ensure_ascii=False, indent=2)
            logger.info(f"[Climate] Cached: {cache_key}")
        except Exception as e:
            logger.warning(f"[Climate] Cache save error: {e}")

    # ==================== ERA5 API（将来実装） ====================

    async def fetch_era5_data(self, lat: float, lon: float, year_range: str = "1991-2020"):
        """
        ERA5データをCDS APIから取得（将来実装）

        Required:
            - CDS API key (https://cds.climate.copernicus.eu/)
            - cdsapi パッケージ

        Variables:
            - 2m_temperature
            - total_precipitation
            - surface_solar_radiation_downwards
        """
        if not self.cds_api_key:
            raise ValueError("CDS API key not configured")

        # TODO: Implement CDS API integration
        # import cdsapi
        # c = cdsapi.Client()
        # c.retrieve('reanalysis-era5-land-monthly-means', {...})

        raise NotImplementedError("ERA5 API integration not yet implemented")
