"""
コミュニティサービス

お気に入り・来店記録・通知設定を管理
"""
import json
import logging
import uuid
from datetime import datetime
from pathlib import Path
from typing import Optional

from .models import (
    Favorite,
    CheckIn,
    NotificationSettings,
    FarmerStats,
)

logger = logging.getLogger("aiseed.community")


class CommunityService:
    """コミュニティサービス"""

    def __init__(self, base_path: str = "community_data"):
        self.base_path = Path(base_path)
        self.base_path.mkdir(parents=True, exist_ok=True)

    # ==================== お気に入り ====================

    def add_favorite(
        self,
        user_id: str,
        farmer_id: str,
        notify_shipment: bool = True
    ) -> Favorite:
        """お気に入りに追加"""
        favorite = Favorite(
            id=str(uuid.uuid4())[:8],
            user_id=user_id,
            farmer_id=farmer_id,
            notify_shipment=notify_shipment,
            created_at=datetime.now()
        )

        favorites = self._load_favorites(user_id)

        # 既存チェック
        existing = next(
            (f for f in favorites if f.get("farmer_id") == farmer_id),
            None
        )
        if existing:
            # 既にお気に入り済み、設定を更新
            existing["notify_shipment"] = notify_shipment
            self._save_favorites(user_id, favorites)
            return Favorite(**existing)

        favorites.append(favorite.model_dump())
        self._save_favorites(user_id, favorites)

        logger.info(f"[Favorite] Added: user={user_id} farmer={farmer_id}")
        return favorite

    def remove_favorite(self, user_id: str, farmer_id: str) -> bool:
        """お気に入りから削除"""
        favorites = self._load_favorites(user_id)
        new_favorites = [f for f in favorites if f.get("farmer_id") != farmer_id]

        if len(new_favorites) < len(favorites):
            self._save_favorites(user_id, new_favorites)
            logger.info(f"[Favorite] Removed: user={user_id} farmer={farmer_id}")
            return True
        return False

    def get_user_favorites(self, user_id: str) -> list[Favorite]:
        """ユーザーのお気に入り一覧を取得"""
        favorites = self._load_favorites(user_id)
        return [Favorite(**f) for f in favorites]

    def is_favorite(self, user_id: str, farmer_id: str) -> bool:
        """お気に入り済みかチェック"""
        favorites = self._load_favorites(user_id)
        return any(f.get("farmer_id") == farmer_id for f in favorites)

    def get_farmer_followers(self, farmer_id: str) -> list[Favorite]:
        """農家のフォロワー一覧を取得"""
        # 全ユーザーのお気に入りを検索
        followers = []
        for user_dir in self.base_path.glob("user_*"):
            favorites_file = user_dir / "favorites.json"
            if favorites_file.exists():
                try:
                    with open(favorites_file, "r", encoding="utf-8") as f:
                        favorites = json.load(f)
                        for fav in favorites:
                            if fav.get("farmer_id") == farmer_id:
                                followers.append(Favorite(**fav))
                except Exception:
                    pass
        return followers

    def _load_favorites(self, user_id: str) -> list[dict]:
        """お気に入りを読み込み"""
        file_path = self.base_path / f"user_{user_id}" / "favorites.json"
        if not file_path.exists():
            return []
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return []

    def _save_favorites(self, user_id: str, favorites: list[dict]):
        """お気に入りを保存"""
        user_dir = self.base_path / f"user_{user_id}"
        user_dir.mkdir(parents=True, exist_ok=True)
        file_path = user_dir / "favorites.json"
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(favorites, f, ensure_ascii=False, indent=2, default=str)

    # ==================== 来店記録 ====================

    def check_in(
        self,
        user_id: str,
        farmer_id: str,
        location_name: Optional[str] = None
    ) -> CheckIn:
        """来店を記録"""
        checkin = CheckIn(
            id=str(uuid.uuid4())[:8],
            user_id=user_id,
            farmer_id=farmer_id,
            location_name=location_name,
            created_at=datetime.now()
        )

        checkins = self._load_checkins(farmer_id)
        checkins.append(checkin.model_dump())
        self._save_checkins(farmer_id, checkins)

        logger.info(
            f"[CheckIn] user={user_id} farmer={farmer_id} "
            f"location={location_name}"
        )
        return checkin

    def get_checkins(
        self,
        farmer_id: str,
        limit: int = 50,
        date: Optional[str] = None
    ) -> list[CheckIn]:
        """来店記録を取得"""
        checkins = self._load_checkins(farmer_id)

        # 日付フィルター
        if date:
            checkins = [
                c for c in checkins
                if c.get("created_at", "").startswith(date)
            ]

        # 新しい順にソート
        checkins = sorted(
            checkins,
            key=lambda x: x.get("created_at", ""),
            reverse=True
        )

        return [CheckIn(**c) for c in checkins[:limit]]

    def get_user_checkins(self, user_id: str, limit: int = 20) -> list[CheckIn]:
        """特定ユーザーの来店記録を取得（全農家から）"""
        all_checkins = []
        # 全農家のディレクトリを検索
        for farmer_dir in self.base_path.glob("farmer_*"):
            checkins_file = farmer_dir / "checkins.json"
            if checkins_file.exists():
                try:
                    with open(checkins_file, "r", encoding="utf-8") as f:
                        checkins = json.load(f)
                        for c in checkins:
                            if c.get("user_id") == user_id:
                                all_checkins.append(c)
                except Exception:
                    pass

        # 新しい順にソート
        all_checkins = sorted(
            all_checkins,
            key=lambda x: x.get("created_at", ""),
            reverse=True
        )

        return [CheckIn(**c) for c in all_checkins[:limit]]

    def _load_checkins(self, farmer_id: str) -> list[dict]:
        """来店記録を読み込み"""
        file_path = self.base_path / f"farmer_{farmer_id}" / "checkins.json"
        if not file_path.exists():
            return []
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return []

    def _save_checkins(self, farmer_id: str, checkins: list[dict]):
        """来店記録を保存"""
        farmer_dir = self.base_path / f"farmer_{farmer_id}"
        farmer_dir.mkdir(parents=True, exist_ok=True)
        file_path = farmer_dir / "checkins.json"
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(checkins, f, ensure_ascii=False, indent=2, default=str)

    # ==================== 通知設定 ====================

    def update_notification_settings(
        self,
        user_id: str,
        email_enabled: Optional[bool] = None,
        push_enabled: Optional[bool] = None,
        email: Optional[str] = None,
        push_subscription: Optional[str] = None
    ) -> NotificationSettings:
        """通知設定を更新"""
        # 既存の設定を読み込み
        existing = self.get_notification_settings(user_id)
        if existing:
            settings = existing
            if email_enabled is not None:
                settings.email_enabled = email_enabled
            if push_enabled is not None:
                settings.push_enabled = push_enabled
            if email is not None:
                settings.email = email
            if push_subscription is not None:
                settings.push_subscription = push_subscription
        else:
            settings = NotificationSettings(
                user_id=user_id,
                email_enabled=email_enabled if email_enabled is not None else False,
                push_enabled=push_enabled if push_enabled is not None else False,
                email=email,
                push_subscription=push_subscription
            )

        settings.updated_at = datetime.now()

        user_dir = self.base_path / f"user_{user_id}"
        user_dir.mkdir(parents=True, exist_ok=True)
        file_path = user_dir / "notification_settings.json"

        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(settings.model_dump(), f, ensure_ascii=False, indent=2, default=str)

        logger.info(f"[NotificationSettings] Updated: user={user_id}")
        return settings

    def get_notification_settings(self, user_id: str) -> Optional[NotificationSettings]:
        """通知設定を取得"""
        file_path = self.base_path / f"user_{user_id}" / "notification_settings.json"
        if not file_path.exists():
            return None
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return NotificationSettings(**json.load(f))
        except Exception:
            return None

    # ==================== 統計 ====================

    def get_farmer_stats(self, farmer_id: str) -> FarmerStats:
        """農家/店舗の統計を取得"""
        followers = self.get_farmer_followers(farmer_id)
        checkins = self._load_checkins(farmer_id)

        today = datetime.now().strftime("%Y-%m-%d")
        today_checkins = [
            c for c in checkins
            if c.get("created_at", "").startswith(today)
        ]

        return FarmerStats(
            farmer_id=farmer_id,
            favorite_count=len(followers),
            checkin_count=len(checkins),
            today_checkin_count=len(today_checkins),
        )

    # ==================== QRコード用ページ生成 ====================

    def generate_checkin_page(self, farmer_id: str, farmer_name: str = "") -> str:
        """来店記録用のHTMLページを生成"""
        stats = self.get_farmer_stats(farmer_id)

        return f'''<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{farmer_name or "お店"}に来店</title>
  <style>
    * {{ margin: 0; padding: 0; box-sizing: border-box; }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: linear-gradient(135deg, #e8f5e9 0%, #fff8e1 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px;
    }}
    .container {{
      background: white;
      border-radius: 24px;
      padding: 32px;
      max-width: 400px;
      width: 100%;
      text-align: center;
      box-shadow: 0 4px 20px rgba(0,0,0,0.1);
    }}
    .icon {{ font-size: 64px; margin-bottom: 16px; }}
    h1 {{ font-size: 1.5rem; color: #2e7d32; margin-bottom: 8px; }}
    .subtitle {{ color: #666; margin-bottom: 24px; }}
    .stats {{
      display: flex;
      justify-content: center;
      gap: 24px;
      margin-bottom: 24px;
    }}
    .stat {{
      text-align: center;
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
    .checkin-btn {{
      width: 100%;
      padding: 16px;
      background: linear-gradient(135deg, #4caf50, #8bc34a);
      color: white;
      border: none;
      border-radius: 12px;
      font-size: 1.1rem;
      font-weight: bold;
      cursor: pointer;
      margin-bottom: 16px;
    }}
    .checkin-btn:active {{
      transform: scale(0.98);
    }}
    .favorite-btn {{
      width: 100%;
      padding: 14px;
      background: white;
      color: #4caf50;
      border: 2px solid #4caf50;
      border-radius: 12px;
      font-size: 1rem;
      cursor: pointer;
    }}
    .message {{
      margin-top: 24px;
      padding: 16px;
      background: #fff8e1;
      border-radius: 12px;
      display: none;
    }}
    .message.show {{ display: block; }}
  </style>
</head>
<body>
  <div class="container">
    <div class="icon">🌾</div>
    <h1>{farmer_name or "お店"}へようこそ！</h1>
    <p class="subtitle">来店ありがとうございます</p>

    <div class="stats">
      <div class="stat">
        <div class="stat-value">{stats.favorite_count}</div>
        <div class="stat-label">お気に入り</div>
      </div>
      <div class="stat">
        <div class="stat-value">{stats.today_checkin_count}</div>
        <div class="stat-label">今日の来店</div>
      </div>
    </div>

    <button class="checkin-btn" onclick="checkIn()">
      📍 来店を記録する
    </button>

    <button class="favorite-btn" onclick="addFavorite()">
      ❤️ お気に入りに登録
    </button>

    <div class="message" id="message"></div>
  </div>

  <script>
    const farmerId = "{farmer_id}";

    async function checkIn() {{
      const msg = document.getElementById('message');
      msg.textContent = '✨ 来店を記録しました！';
      msg.classList.add('show');

      // TODO: APIに送信
      // await fetch('/api/checkin', {{ ... }});
    }}

    async function addFavorite() {{
      const msg = document.getElementById('message');
      msg.textContent = '❤️ お気に入りに登録しました！出荷情報をお届けします。';
      msg.classList.add('show');

      // TODO: APIに送信
      // await fetch('/api/favorite', {{ ... }});
    }}
  </script>
</body>
</html>'''
