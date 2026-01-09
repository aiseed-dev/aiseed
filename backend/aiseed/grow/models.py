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


# ==================== WRB土壌分類（32参照土壌群） ====================
# World Reference Base for Soil Resources 2022
# 日本語名は農耕地土壌分類に準拠

SoilType = Literal[
    "unknown",       # 不明
    # 有機質土壌
    "histosols",     # 泥炭土・黒泥土
    # 人為的土壌
    "anthrosols",    # 人為土壌
    "technosols",    # 造成土
    # 凍結・浅層土壌
    "cryosols",      # 永久凍土
    "leptosols",     # 岩屑土・浅層土
    # 塩類・アルカリ土壌
    "solonetz",      # アルカリ土壌
    "solonchaks",    # 塩類集積土壌
    # 水の影響を受ける土壌
    "vertisols",     # 膨張収縮土
    "gleysols",      # グライ土
    "stagnosols",    # 停滞水成土
    "planosols",     # 擬似グライ土
    "fluvisols",     # 沖積土
    # 火山灰土壌
    "andosols",      # 黒ボク土
    # 酸性・風化土壌
    "podzols",       # ポドゾル
    "plinthosols",   # プリンソソル
    "nitisols",      # 暗赤色土
    "ferralsols",    # 強風化熱帯土
    "alisols",       # 酸性粘土集積土
    "acrisols",      # 酸性風化土
    "lixisols",      # 塩基性風化土
    "luvisols",      # 粘土集積土
    "retisols",      # 舌状漂白土
    # 腐植質土壌
    "chernozems",    # チェルノーゼム（黒土）
    "kastanozems",   # 栗色土
    "phaeozems",     # 暗色表層土
    "umbrisols",     # 酸性暗色土
    # 乾燥地土壌
    "calcisols",     # 石灰集積土
    "gypsisols",     # 石膏集積土
    "durisols",      # シリカ硬盤土
    # 未発達土壌
    "arenosols",     # 砂質土
    "cambisols",     # 褐色森林土
    "regosols",      # 未熟土
]

SOIL_TYPES = {
    "unknown": {
        "name_en": "Unknown",
        "name_ja": "不明",
        "description_en": "Soil type not yet determined",
        "description_ja": "土壌タイプ未確定",
        "japan_common": True,
    },
    # === 有機質土壌 ===
    "histosols": {
        "name_en": "Histosols",
        "name_ja": "泥炭土・黒泥土",
        "description_en": "Soils with thick organic layers (peat)",
        "description_ja": "有機物層が厚い土壌（泥炭・黒泥）",
        "japan_common": True,
    },
    # === 人為的土壌 ===
    "anthrosols": {
        "name_en": "Anthrosols",
        "name_ja": "人為土壌",
        "description_en": "Soils modified by long-term human activity",
        "description_ja": "長期の農業活動で改変された土壌",
        "japan_common": True,
    },
    "technosols": {
        "name_en": "Technosols",
        "name_ja": "造成土",
        "description_en": "Soils containing significant artifacts or constructed materials",
        "description_ja": "人工物や建設材料を含む土壌",
        "japan_common": True,
    },
    # === 凍結・浅層土壌 ===
    "cryosols": {
        "name_en": "Cryosols",
        "name_ja": "永久凍土",
        "description_en": "Ice-affected soils with permafrost",
        "description_ja": "永久凍土を含む土壌",
        "japan_common": False,
    },
    "leptosols": {
        "name_en": "Leptosols",
        "name_ja": "岩屑土",
        "description_en": "Shallow soils over hard rock or gravelly material",
        "description_ja": "岩盤や礫の上の浅い土壌",
        "japan_common": True,
    },
    # === 塩類・アルカリ土壌 ===
    "solonetz": {
        "name_en": "Solonetz",
        "name_ja": "アルカリ土壌",
        "description_en": "Soils with high sodium content",
        "description_ja": "ナトリウムを多く含むアルカリ性土壌",
        "japan_common": False,
    },
    "solonchaks": {
        "name_en": "Solonchaks",
        "name_ja": "塩類集積土壌",
        "description_en": "Salt-affected soils",
        "description_ja": "塩類が集積した土壌（沿海部など）",
        "japan_common": True,
    },
    # === 水の影響を受ける土壌 ===
    "vertisols": {
        "name_en": "Vertisols",
        "name_ja": "膨張収縮土",
        "description_en": "Clay-rich soils that shrink and swell",
        "description_ja": "膨張・収縮する粘土質土壌",
        "japan_common": False,
    },
    "gleysols": {
        "name_en": "Gleysols",
        "name_ja": "グライ土",
        "description_en": "Groundwater-affected soils with reducing conditions",
        "description_ja": "地下水位が高く還元状態の土壌",
        "japan_common": True,
    },
    "stagnosols": {
        "name_en": "Stagnosols",
        "name_ja": "停滞水成土",
        "description_en": "Soils affected by stagnant water",
        "description_ja": "停滞水の影響を受けた土壌",
        "japan_common": True,
    },
    "planosols": {
        "name_en": "Planosols",
        "name_ja": "擬似グライ土",
        "description_en": "Soils with bleached topsoil over dense subsoil",
        "description_ja": "漂白層と停滞水層を持つ土壌",
        "japan_common": True,
    },
    "fluvisols": {
        "name_en": "Fluvisols",
        "name_ja": "沖積土（灰色低地土・褐色低地土）",
        "description_en": "Young soils in river floodplains",
        "description_ja": "河川氾濫原の若い土壌、日本の農地で最多",
        "japan_common": True,
    },
    # === 火山灰土壌 ===
    "andosols": {
        "name_en": "Andosols",
        "name_ja": "黒ボク土",
        "description_en": "Soils formed in volcanic ash, dark and fluffy",
        "description_ja": "火山灰起源の黒い土壌、日本の代表的土壌",
        "japan_common": True,
    },
    # === 酸性・風化土壌 ===
    "podzols": {
        "name_en": "Podzols",
        "name_ja": "ポドゾル",
        "description_en": "Acid soils with bleached layer and iron/humus accumulation",
        "description_ja": "漂白層とFe・腐植の集積層を持つ酸性土壌",
        "japan_common": True,
    },
    "plinthosols": {
        "name_en": "Plinthosols",
        "name_ja": "プリンソソル",
        "description_en": "Soils with iron-rich, humus-poor subsoil that hardens",
        "description_ja": "鉄に富み硬化する下層土を持つ土壌",
        "japan_common": False,
    },
    "nitisols": {
        "name_en": "Nitisols",
        "name_ja": "暗赤色土",
        "description_en": "Deep red tropical soils with shiny ped surfaces",
        "description_ja": "石灰岩上に発達した深い赤色土壌",
        "japan_common": True,
    },
    "ferralsols": {
        "name_en": "Ferralsols",
        "name_ja": "強風化熱帯土",
        "description_en": "Highly weathered tropical soils",
        "description_ja": "熱帯の極度に風化した土壌",
        "japan_common": False,
    },
    "alisols": {
        "name_en": "Alisols",
        "name_ja": "酸性粘土集積土",
        "description_en": "Acid soils with high-activity clay accumulation",
        "description_ja": "高活性粘土が集積した酸性土壌",
        "japan_common": False,
    },
    "acrisols": {
        "name_en": "Acrisols",
        "name_ja": "赤黄色土",
        "description_en": "Acid soils with low-activity clay accumulation",
        "description_ja": "低活性粘土が集積した酸性土壌",
        "japan_common": True,
    },
    "lixisols": {
        "name_en": "Lixisols",
        "name_ja": "塩基性風化土",
        "description_en": "Soils with low-activity clay and high base saturation",
        "description_ja": "塩基飽和度が高い風化土壌",
        "japan_common": False,
    },
    "luvisols": {
        "name_en": "Luvisols",
        "name_ja": "粘土集積土",
        "description_en": "Soils with clay accumulation in subsoil",
        "description_ja": "下層に粘土が集積した土壌",
        "japan_common": True,
    },
    "retisols": {
        "name_en": "Retisols",
        "name_ja": "舌状漂白土",
        "description_en": "Soils with tongue-shaped bleached penetrations",
        "description_ja": "舌状の漂白層が入り込んだ土壌",
        "japan_common": False,
    },
    # === 腐植質土壌 ===
    "chernozems": {
        "name_en": "Chernozems",
        "name_ja": "チェルノーゼム（黒土）",
        "description_en": "Black soils of temperate grasslands, very fertile",
        "description_ja": "温帯草原の黒い肥沃な土壌",
        "japan_common": False,
    },
    "kastanozems": {
        "name_en": "Kastanozems",
        "name_ja": "栗色土",
        "description_en": "Chestnut-colored soils of dry grasslands",
        "description_ja": "乾燥草原の栗色土壌",
        "japan_common": False,
    },
    "phaeozems": {
        "name_en": "Phaeozems",
        "name_ja": "暗色表層土",
        "description_en": "Dark surface soils of humid grasslands",
        "description_ja": "湿潤草原の暗色表層土壌",
        "japan_common": False,
    },
    "umbrisols": {
        "name_en": "Umbrisols",
        "name_ja": "酸性暗色土",
        "description_en": "Acid soils with dark, humus-rich topsoil",
        "description_ja": "酸性で腐植に富む暗色土壌",
        "japan_common": True,
    },
    # === 乾燥地土壌 ===
    "calcisols": {
        "name_en": "Calcisols",
        "name_ja": "石灰集積土",
        "description_en": "Soils with calcium carbonate accumulation",
        "description_ja": "石灰が集積した土壌",
        "japan_common": False,
    },
    "gypsisols": {
        "name_en": "Gypsisols",
        "name_ja": "石膏集積土",
        "description_en": "Soils with gypsum accumulation",
        "description_ja": "石膏が集積した土壌",
        "japan_common": False,
    },
    "durisols": {
        "name_en": "Durisols",
        "name_ja": "シリカ硬盤土",
        "description_en": "Soils with silica-ceite�cemented hardpan",
        "description_ja": "シリカで硬化した層を持つ土壌",
        "japan_common": False,
    },
    # === 未発達土壌 ===
    "arenosols": {
        "name_en": "Arenosols",
        "name_ja": "砂丘未熟土",
        "description_en": "Sandy soils with little development",
        "description_ja": "砂質で層位発達の少ない土壌",
        "japan_common": True,
    },
    "cambisols": {
        "name_en": "Cambisols",
        "name_ja": "褐色森林土",
        "description_en": "Young soils with beginning horizon development",
        "description_ja": "層位発達が始まった若い土壌、日本の森林に多い",
        "japan_common": True,
    },
    "regosols": {
        "name_en": "Regosols",
        "name_ja": "未熟土",
        "description_en": "Weakly developed soils in unconsolidated material",
        "description_ja": "未固結物質上の発達の弱い土壌",
        "japan_common": True,
    },
}

# 日本で一般的な土壌タイプ（選択肢を絞る場合用）
JAPAN_COMMON_SOIL_TYPES = [
    code for code, data in SOIL_TYPES.items() if data.get("japan_common", False)
]


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

    # 土壌タイプ（WRB分類）
    soil_type: Optional[str] = "unknown"         # 主な土壌タイプ
    soil_type_notes: Optional[str] = None        # 土壌についてのメモ

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
    soil_type: Optional[str] = "unknown"         # 土壌タイプ（WRB分類）
    soil_type_notes: Optional[str] = None        # 土壌についてのメモ
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
