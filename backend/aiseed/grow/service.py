"""
栽培記録サービス

植物の観察記録を管理する（AI不使用、ルールベース）
"""
import json
import logging
import uuid
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional

from .models import Plant, Observation, PlantStats, FARMING_METHODS

logger = logging.getLogger("aiseed.grow")


class GrowService:
    """栽培記録サービス"""

    def __init__(self, base_path: str = "grow_data"):
        self.base_path = Path(base_path)
        self.base_path.mkdir(parents=True, exist_ok=True)

    # ==================== 栽培方法 ====================

    def get_farming_methods(self) -> dict:
        """栽培方法の一覧を取得"""
        return FARMING_METHODS

    # ==================== 植物管理 ====================

    def create_plant(
        self,
        user_id: str,
        name: str,
        variety: Optional[str] = None,
        location: Optional[str] = None,
        farming_method: Optional[str] = "undecided",
        farming_method_sub: Optional[str] = None,
        farming_method_notes: Optional[str] = None,
        notes: Optional[str] = None
    ) -> Plant:
        """植物を登録"""
        plant = Plant(
            id=str(uuid.uuid4())[:8],
            user_id=user_id,
            name=name,
            variety=variety,
            location=location,
            farming_method=farming_method,
            farming_method_sub=farming_method_sub,
            farming_method_notes=farming_method_notes,
            notes=notes,
            started_at=datetime.now(),
            created_at=datetime.now(),
            updated_at=datetime.now()
        )

        plants = self._load_plants(user_id)
        plants.append(plant.model_dump())
        self._save_plants(user_id, plants)

        logger.info(f"[Grow] Plant created: user={user_id} name={name}")
        return plant

    def get_plant(self, user_id: str, plant_id: str) -> Optional[Plant]:
        """植物を取得"""
        plants = self._load_plants(user_id)
        for p in plants:
            if p.get("id") == plant_id:
                return Plant(**p)
        return None

    def get_plants(self, user_id: str) -> list[Plant]:
        """ユーザーの植物一覧を取得"""
        plants = self._load_plants(user_id)
        return [Plant(**p) for p in plants]

    def update_plant(
        self,
        user_id: str,
        plant_id: str,
        **kwargs
    ) -> Optional[Plant]:
        """植物を更新"""
        plants = self._load_plants(user_id)

        for i, p in enumerate(plants):
            if p.get("id") == plant_id:
                for key, value in kwargs.items():
                    if value is not None:
                        p[key] = value
                p["updated_at"] = datetime.now().isoformat()
                plants[i] = p
                self._save_plants(user_id, plants)
                return Plant(**p)
        return None

    def delete_plant(self, user_id: str, plant_id: str) -> bool:
        """植物を削除"""
        plants = self._load_plants(user_id)
        new_plants = [p for p in plants if p.get("id") != plant_id]

        if len(new_plants) < len(plants):
            self._save_plants(user_id, new_plants)
            # 観察記録も削除
            self._delete_observations(user_id, plant_id)
            return True
        return False

    def _load_plants(self, user_id: str) -> list[dict]:
        """植物データを読み込み"""
        file_path = self.base_path / f"user_{user_id}" / "plants.json"
        if not file_path.exists():
            return []
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return []

    def _save_plants(self, user_id: str, plants: list[dict]):
        """植物データを保存"""
        user_dir = self.base_path / f"user_{user_id}"
        user_dir.mkdir(parents=True, exist_ok=True)
        file_path = user_dir / "plants.json"
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(plants, f, ensure_ascii=False, indent=2, default=str)

    # ==================== 観察記録 ====================

    def add_observation(
        self,
        plant_id: str,
        user_id: str,
        text: str,
        date: Optional[str] = None,
        time: Optional[str] = None,
        weather: Optional[str] = None,
        temperature: Optional[float] = None,
        watered: bool = False,
        fertilized: bool = False,
        harvested: bool = False,
        harvest_amount: Optional[str] = None,
        photo_urls: list[str] = None
    ) -> Observation:
        """観察記録を追加"""
        if date is None:
            date = datetime.now().strftime("%Y-%m-%d")
        if time is None:
            time = datetime.now().strftime("%H:%M")

        # ルールベースで気づきを抽出
        insights = self._extract_insights(text, watered, harvested)

        observation = Observation(
            id=str(uuid.uuid4())[:8],
            plant_id=plant_id,
            user_id=user_id,
            date=date,
            time=time,
            text=text,
            weather=weather,
            temperature=temperature,
            watered=watered,
            fertilized=fertilized,
            harvested=harvested,
            harvest_amount=harvest_amount,
            insights=insights,
            photo_urls=photo_urls or [],
            created_at=datetime.now()
        )

        observations = self._load_observations(user_id, plant_id)
        observations.append(observation.model_dump())
        self._save_observations(user_id, plant_id, observations)

        logger.info(f"[Grow] Observation added: plant={plant_id} date={date}")
        return observation

    def get_observations(
        self,
        user_id: str,
        plant_id: str,
        limit: int = 30,
        offset: int = 0
    ) -> list[Observation]:
        """観察記録を取得"""
        observations = self._load_observations(user_id, plant_id)

        # 新しい順にソート
        observations = sorted(
            observations,
            key=lambda x: (x.get("date", ""), x.get("time", "")),
            reverse=True
        )

        return [Observation(**o) for o in observations[offset:offset + limit]]

    def get_observation(
        self,
        user_id: str,
        plant_id: str,
        observation_id: str
    ) -> Optional[Observation]:
        """特定の観察記録を取得"""
        observations = self._load_observations(user_id, plant_id)
        for o in observations:
            if o.get("id") == observation_id:
                return Observation(**o)
        return None

    def get_today_observations(self, user_id: str) -> list[Observation]:
        """今日の観察記録を全植物から取得"""
        today = datetime.now().strftime("%Y-%m-%d")
        all_observations = []

        plants = self.get_plants(user_id)
        for plant in plants:
            observations = self._load_observations(user_id, plant.id)
            for o in observations:
                if o.get("date") == today:
                    all_observations.append(Observation(**o))

        return all_observations

    def _load_observations(self, user_id: str, plant_id: str) -> list[dict]:
        """観察記録を読み込み"""
        file_path = self.base_path / f"user_{user_id}" / f"observations_{plant_id}.json"
        if not file_path.exists():
            return []
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return []

    def _save_observations(self, user_id: str, plant_id: str, observations: list[dict]):
        """観察記録を保存"""
        user_dir = self.base_path / f"user_{user_id}"
        user_dir.mkdir(parents=True, exist_ok=True)
        file_path = user_dir / f"observations_{plant_id}.json"
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(observations, f, ensure_ascii=False, indent=2, default=str)

    def _delete_observations(self, user_id: str, plant_id: str):
        """観察記録を削除"""
        file_path = self.base_path / f"user_{user_id}" / f"observations_{plant_id}.json"
        if file_path.exists():
            file_path.unlink()

    # ==================== 気づき抽出（ルールベース） ====================

    def _extract_insights(
        self,
        text: str,
        watered: bool,
        harvested: bool
    ) -> list[str]:
        """
        観察テキストから気づきを抽出（ルールベース）

        AI不使用。キーワードマッチングで抽出。
        公開版でも使える低コスト実装。
        """
        insights = []
        text_lower = text.lower()

        # 成長に関する気づき
        growth_keywords = {
            "大きく": "成長を感じていますね",
            "伸びた": "順調に育っています",
            "増えた": "元気に成長中",
            "育った": "成長が見られます",
            "芽が出": "発芽おめでとうございます",
            "葉っぱ": "葉の観察、大切ですね",
            "花が咲": "開花！素敵な瞬間ですね",
            "実が": "実がなってきましたね",
            "色づ": "色づきは収穫のサイン",
        }

        for keyword, insight in growth_keywords.items():
            if keyword in text:
                insights.append(insight)
                break

        # 問題に関する気づき
        problem_keywords = {
            "枯れ": "様子を見守りましょう",
            "虫": "早めの対処が大切です",
            "黄色": "水やりや日当たりを確認",
            "しおれ": "水やりのタイミングかも",
            "元気ない": "環境を見直してみましょう",
        }

        for keyword, insight in problem_keywords.items():
            if keyword in text:
                insights.append(insight)
                break

        # アクションに基づく気づき
        if watered:
            insights.append("水やりお疲れさまです")
        if harvested:
            insights.append("収穫おめでとうございます！")

        # 気づきがなければ励ましの言葉
        if not insights:
            insights.append("観察を続けていますね")

        return insights[:3]  # 最大3つ

    # ==================== 統計 ====================

    def get_plant_stats(self, user_id: str, plant_id: str) -> PlantStats:
        """植物の統計を取得"""
        plant = self.get_plant(user_id, plant_id)
        observations = self._load_observations(user_id, plant_id)

        # 日数計算
        days_since_start = 0
        if plant and plant.started_at:
            start = plant.started_at
            if isinstance(start, str):
                start = datetime.fromisoformat(start)
            days_since_start = (datetime.now() - start).days

        # 最後の観察
        last_observation = None
        if observations:
            sorted_obs = sorted(observations, key=lambda x: x.get("date", ""), reverse=True)
            last_observation = sorted_obs[0].get("date")

        # 収穫回数
        total_harvests = sum(1 for o in observations if o.get("harvested"))

        # 連続観察日数
        streak_days = self._calculate_streak(observations)

        return PlantStats(
            plant_id=plant_id,
            observation_count=len(observations),
            days_since_start=days_since_start,
            last_observation=last_observation,
            total_harvests=total_harvests,
            streak_days=streak_days
        )

    def _calculate_streak(self, observations: list[dict]) -> int:
        """連続観察日数を計算"""
        if not observations:
            return 0

        dates = set(o.get("date") for o in observations if o.get("date"))
        if not dates:
            return 0

        today = datetime.now().date()
        streak = 0

        current = today
        while current.isoformat() in dates:
            streak += 1
            current -= timedelta(days=1)

        return streak

    # ==================== ユーザー統計 ====================

    def get_user_stats(self, user_id: str) -> dict:
        """ユーザーの全体統計"""
        plants = self.get_plants(user_id)

        total_observations = 0
        total_harvests = 0
        active_plants = 0

        for plant in plants:
            observations = self._load_observations(user_id, plant.id)
            total_observations += len(observations)
            total_harvests += sum(1 for o in observations if o.get("harvested"))
            if plant.status == "growing":
                active_plants += 1

        return {
            "total_plants": len(plants),
            "active_plants": active_plants,
            "total_observations": total_observations,
            "total_harvests": total_harvests,
        }

    # ==================== 公開ページ生成 ====================

    def generate_plant_page(self, user_id: str, plant_id: str) -> str:
        """植物の公開ページHTMLを生成"""
        plant = self.get_plant(user_id, plant_id)
        if not plant:
            return "<html><body><h1>植物が見つかりません</h1></body></html>"

        observations = self.get_observations(user_id, plant_id, limit=10)
        stats = self.get_plant_stats(user_id, plant_id)

        obs_html = ""
        for obs in observations:
            insights_html = "".join(f"<span class='insight'>{i}</span>" for i in obs.insights)
            obs_html += f"""
            <div class="observation">
              <div class="date">{obs.date} {obs.time or ''}</div>
              <div class="text">{obs.text}</div>
              <div class="insights">{insights_html}</div>
            </div>
            """

        return f'''<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{plant.name}の栽培記録</title>
  <style>
    * {{ margin: 0; padding: 0; box-sizing: border-box; }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: linear-gradient(135deg, #e8f5e9 0%, #f1f8e9 100%);
      min-height: 100vh;
      padding: 20px;
    }}
    .container {{
      max-width: 600px;
      margin: 0 auto;
    }}
    .header {{
      background: white;
      border-radius: 16px;
      padding: 24px;
      margin-bottom: 16px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }}
    .plant-name {{
      font-size: 1.5rem;
      color: #2e7d32;
      margin-bottom: 8px;
    }}
    .stats {{
      display: flex;
      gap: 16px;
      margin-top: 16px;
    }}
    .stat {{
      text-align: center;
      flex: 1;
    }}
    .stat-value {{
      font-size: 1.5rem;
      font-weight: bold;
      color: #4caf50;
    }}
    .stat-label {{
      font-size: 0.85rem;
      color: #888;
    }}
    .observation {{
      background: white;
      border-radius: 12px;
      padding: 16px;
      margin-bottom: 12px;
      box-shadow: 0 1px 4px rgba(0,0,0,0.1);
    }}
    .date {{
      font-size: 0.85rem;
      color: #888;
      margin-bottom: 8px;
    }}
    .text {{
      color: #333;
      line-height: 1.6;
      margin-bottom: 8px;
    }}
    .insights {{
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
    }}
    .insight {{
      background: #e8f5e9;
      color: #2e7d32;
      padding: 4px 12px;
      border-radius: 16px;
      font-size: 0.85rem;
    }}
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1 class="plant-name">🌱 {plant.name}</h1>
      {f'<p>{plant.variety}</p>' if plant.variety else ''}
      {f'<p>📍 {plant.location}</p>' if plant.location else ''}
      <div class="stats">
        <div class="stat">
          <div class="stat-value">{stats.days_since_start}</div>
          <div class="stat-label">日目</div>
        </div>
        <div class="stat">
          <div class="stat-value">{stats.observation_count}</div>
          <div class="stat-label">観察</div>
        </div>
        <div class="stat">
          <div class="stat-value">{stats.streak_days}</div>
          <div class="stat-label">連続日</div>
        </div>
      </div>
    </div>
    <h2 style="margin: 16px 0; color: #333;">📝 観察記録</h2>
    {obs_html if obs_html else '<p style="color: #888;">まだ観察記録がありません</p>'}
  </div>
</body>
</html>'''
