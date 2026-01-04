"""
出荷情報サービス

出荷情報の管理と通知を担当
"""
import json
import logging
import uuid
from datetime import datetime
from pathlib import Path
from typing import Optional

from .models import (
    ShipmentInfo,
    ShipmentItem,
    Subscriber,
    NotificationResult,
)

logger = logging.getLogger("aiseed.shipment")


class ShipmentService:
    """出荷情報サービス"""

    def __init__(self, base_path: str = "shipment_data"):
        self.base_path = Path(base_path)
        self.base_path.mkdir(parents=True, exist_ok=True)

        # 通知サービス（後で初期化）
        self.email_service = None
        self.push_service = None

    def _get_farmer_path(self, farmer_id: str) -> Path:
        """農家のデータディレクトリを取得"""
        path = self.base_path / farmer_id
        path.mkdir(parents=True, exist_ok=True)
        return path

    def _get_shipments_file(self, farmer_id: str) -> Path:
        """出荷情報ファイルのパス"""
        return self._get_farmer_path(farmer_id) / "shipments.json"

    def _get_subscribers_file(self, farmer_id: str) -> Path:
        """購読者ファイルのパス"""
        return self._get_farmer_path(farmer_id) / "subscribers.json"

    # ==================== 出荷情報管理 ====================

    def post_shipment(self, shipment: ShipmentInfo) -> ShipmentInfo:
        """出荷情報を投稿"""
        # IDと日時を設定
        shipment.id = str(uuid.uuid4())[:8]
        shipment.created_at = datetime.now()
        shipment.updated_at = datetime.now()

        # 保存
        shipments = self._load_shipments(shipment.farmer_id)
        shipments.append(shipment.model_dump())
        self._save_shipments(shipment.farmer_id, shipments)

        logger.info(f"[Shipment] Posted: farmer={shipment.farmer_id} id={shipment.id}")
        return shipment

    def get_latest_shipment(self, farmer_id: str) -> Optional[ShipmentInfo]:
        """最新の出荷情報を取得"""
        shipments = self._load_shipments(farmer_id)
        if not shipments:
            return None

        # 日付でソートして最新を返す
        sorted_shipments = sorted(
            shipments,
            key=lambda x: (x.get("date", ""), x.get("time", "")),
            reverse=True
        )
        return ShipmentInfo(**sorted_shipments[0])

    def get_shipments(
        self,
        farmer_id: str,
        limit: int = 10,
        offset: int = 0
    ) -> list[ShipmentInfo]:
        """出荷情報の履歴を取得"""
        shipments = self._load_shipments(farmer_id)

        # 日付でソート
        sorted_shipments = sorted(
            shipments,
            key=lambda x: (x.get("date", ""), x.get("time", "")),
            reverse=True
        )

        # ページネーション
        paginated = sorted_shipments[offset:offset + limit]
        return [ShipmentInfo(**s) for s in paginated]

    def get_today_shipments(self, farmer_id: str) -> list[ShipmentInfo]:
        """今日の出荷情報を取得"""
        today = datetime.now().strftime("%Y-%m-%d")
        shipments = self._load_shipments(farmer_id)

        today_shipments = [
            ShipmentInfo(**s) for s in shipments
            if s.get("date") == today
        ]

        # 時間でソート
        return sorted(today_shipments, key=lambda x: x.time or "")

    def _load_shipments(self, farmer_id: str) -> list[dict]:
        """出荷情報を読み込み"""
        file_path = self._get_shipments_file(farmer_id)
        if not file_path.exists():
            return []

        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"Failed to load shipments: {e}")
            return []

    def _save_shipments(self, farmer_id: str, shipments: list[dict]):
        """出荷情報を保存"""
        file_path = self._get_shipments_file(farmer_id)
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(shipments, f, ensure_ascii=False, indent=2, default=str)

    # ==================== 購読者管理 ====================

    def subscribe(self, subscriber: Subscriber) -> Subscriber:
        """購読登録"""
        subscriber.id = str(uuid.uuid4())[:8]
        subscriber.created_at = datetime.now()

        subscribers = self._load_subscribers(subscriber.farmer_id)

        # 既存の購読をチェック（メールが同じなら更新）
        existing_idx = None
        for i, s in enumerate(subscribers):
            if subscriber.email and s.get("email") == subscriber.email:
                existing_idx = i
                break

        if existing_idx is not None:
            # 既存を更新
            subscribers[existing_idx] = subscriber.model_dump()
        else:
            # 新規追加
            subscribers.append(subscriber.model_dump())

        self._save_subscribers(subscriber.farmer_id, subscribers)
        logger.info(f"[Subscribe] farmer={subscriber.farmer_id} email={subscriber.email}")
        return subscriber

    def unsubscribe(self, farmer_id: str, email: str) -> bool:
        """購読解除"""
        subscribers = self._load_subscribers(farmer_id)

        new_subscribers = [
            s for s in subscribers
            if s.get("email") != email
        ]

        if len(new_subscribers) < len(subscribers):
            self._save_subscribers(farmer_id, new_subscribers)
            logger.info(f"[Unsubscribe] farmer={farmer_id} email={email}")
            return True
        return False

    def get_subscribers(self, farmer_id: str) -> list[Subscriber]:
        """購読者一覧を取得"""
        subscribers = self._load_subscribers(farmer_id)
        return [Subscriber(**s) for s in subscribers if s.get("is_active", True)]

    def _load_subscribers(self, farmer_id: str) -> list[dict]:
        """購読者を読み込み"""
        file_path = self._get_subscribers_file(farmer_id)
        if not file_path.exists():
            return []

        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"Failed to load subscribers: {e}")
            return []

    def _save_subscribers(self, farmer_id: str, subscribers: list[dict]):
        """購読者を保存"""
        file_path = self._get_subscribers_file(farmer_id)
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(subscribers, f, ensure_ascii=False, indent=2, default=str)

    # ==================== 通知 ====================

    async def notify_subscribers(
        self,
        farmer_id: str,
        shipment: ShipmentInfo
    ) -> NotificationResult:
        """購読者に出荷情報を通知"""
        subscribers = self.get_subscribers(farmer_id)
        result = NotificationResult(success=True)

        if not subscribers:
            logger.info(f"[Notify] No subscribers for farmer={farmer_id}")
            return result

        # 通知メッセージを作成
        message = self._build_notification_message(shipment)

        # メール通知
        for sub in subscribers:
            if sub.email:
                try:
                    await self._send_email(sub.email, shipment, message)
                    result.email_sent += 1
                except Exception as e:
                    result.errors.append(f"Email to {sub.email}: {str(e)}")
                    logger.error(f"Email notification failed: {e}")

            # Webプッシュ通知
            if sub.push_subscription:
                try:
                    await self._send_push(sub.push_subscription, shipment, message)
                    result.push_sent += 1
                except Exception as e:
                    result.errors.append(f"Push: {str(e)}")
                    logger.error(f"Push notification failed: {e}")

        if result.errors:
            result.success = False

        logger.info(
            f"[Notify] farmer={farmer_id} email={result.email_sent} "
            f"push={result.push_sent} errors={len(result.errors)}"
        )
        return result

    def _build_notification_message(self, shipment: ShipmentInfo) -> str:
        """通知メッセージを作成"""
        items_text = ", ".join([
            f"{item.name} {item.price}円"
            for item in shipment.items
        ])

        time_text = f"{shipment.time}に" if shipment.time else ""

        message = (
            f"【出荷情報】\n"
            f"{shipment.date} {time_text}{shipment.location_name}\n"
            f"{items_text}"
        )

        if shipment.note:
            message += f"\n{shipment.note}"

        return message

    async def _send_email(
        self,
        to_email: str,
        shipment: ShipmentInfo,
        message: str
    ):
        """メール送信（実装は後で追加）"""
        # TODO: Resend/SendGrid等で実装
        logger.info(f"[Email] Would send to {to_email}: {message[:50]}...")
        pass

    async def _send_push(
        self,
        subscription: dict,
        shipment: ShipmentInfo,
        message: str
    ):
        """Webプッシュ送信（実装は後で追加）"""
        # TODO: web-push で実装
        logger.info(f"[Push] Would send: {message[:50]}...")
        pass

    # ==================== HTML生成 ====================

    def generate_shipment_html(self, farmer_id: str, farmer_name: str = "") -> str:
        """出荷情報ページのHTMLを生成"""
        today_shipments = self.get_today_shipments(farmer_id)

        # 商品リストHTML
        if today_shipments:
            items_html = ""
            for shipment in today_shipments:
                items_html += f'<div class="shipment-card">'
                items_html += f'<div class="location">📍 {shipment.location_name}</div>'
                if shipment.time:
                    items_html += f'<div class="time">🕐 {shipment.time}</div>'
                items_html += '<ul class="items">'
                for item in shipment.items:
                    items_html += f'<li>{item.name} <span class="price">{item.price}円</span></li>'
                items_html += '</ul>'
                if shipment.note:
                    items_html += f'<div class="note">{shipment.note}</div>'
                items_html += '</div>'
        else:
            items_html = '<p class="no-shipment">今日の出荷情報はまだありません</p>'

        today = datetime.now().strftime("%Y年%m月%d日")

        return f'''<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{farmer_name or "農家"}の出荷情報</title>
  <style>
    * {{ margin: 0; padding: 0; box-sizing: border-box; }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: linear-gradient(135deg, #f5f0e6 0%, #e8f5e9 100%);
      color: #3e2723;
      min-height: 100vh;
      padding: 20px;
    }}
    .container {{ max-width: 480px; margin: 0 auto; }}
    header {{
      text-align: center;
      padding: 24px 0;
    }}
    header h1 {{ font-size: 1.5rem; color: #2e7d32; }}
    .date {{ color: #5d4037; margin-top: 8px; }}

    .shipment-card {{
      background: white;
      border-radius: 16px;
      padding: 20px;
      margin-bottom: 16px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.08);
    }}
    .location {{
      font-weight: bold;
      font-size: 1.1rem;
      margin-bottom: 8px;
    }}
    .time {{ color: #666; margin-bottom: 12px; }}
    .items {{
      list-style: none;
      border-top: 1px solid #eee;
      padding-top: 12px;
    }}
    .items li {{
      padding: 8px 0;
      display: flex;
      justify-content: space-between;
      border-bottom: 1px dashed #eee;
    }}
    .price {{
      color: #e65100;
      font-weight: bold;
    }}
    .note {{
      margin-top: 12px;
      padding: 12px;
      background: #fff8e1;
      border-radius: 8px;
      font-size: 0.9rem;
    }}
    .no-shipment {{
      text-align: center;
      color: #888;
      padding: 40px 20px;
    }}

    .subscribe-section {{
      margin-top: 32px;
      padding: 24px;
      background: white;
      border-radius: 16px;
      text-align: center;
    }}
    .subscribe-section h2 {{
      font-size: 1.1rem;
      color: #2e7d32;
      margin-bottom: 16px;
    }}
    .subscribe-form input {{
      width: 100%;
      padding: 12px 16px;
      border: 2px solid #a5d6a7;
      border-radius: 8px;
      font-size: 1rem;
      margin-bottom: 12px;
    }}
    .subscribe-form button {{
      width: 100%;
      padding: 14px;
      background: #4caf50;
      color: white;
      border: none;
      border-radius: 8px;
      font-size: 1rem;
      font-weight: bold;
      cursor: pointer;
    }}
    .subscribe-form button:hover {{
      background: #388e3c;
    }}

    footer {{
      text-align: center;
      padding: 24px;
      color: #888;
      font-size: 0.85rem;
    }}
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>🌾 {farmer_name or "農家"}の出荷情報</h1>
      <p class="date">{today}</p>
    </header>

    <main>
      {items_html}
    </main>

    <section class="subscribe-section">
      <h2>📬 出荷情報を受け取る</h2>
      <form class="subscribe-form" action="/subscribe" method="POST">
        <input type="hidden" name="farmer_id" value="{farmer_id}">
        <input type="email" name="email" placeholder="メールアドレス" required>
        <button type="submit">登録する</button>
      </form>
    </section>

    <footer>
      <p>Powered by aiseed</p>
    </footer>
  </div>
</body>
</html>'''
