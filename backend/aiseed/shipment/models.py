"""
出荷情報のデータモデル
"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


class ShipmentItem(BaseModel):
    """出荷商品"""
    name: str  # 商品名（トマト、ナス等）
    price: int  # 価格（円）
    unit: str = "個"  # 単位（個、袋、kg等）
    quantity: Optional[str] = None  # 数量（あれば）
    note: Optional[str] = None  # 備考


class ShipmentInfo(BaseModel):
    """出荷情報"""
    id: Optional[str] = None
    farmer_id: str  # 農家ID

    # 日時
    date: str  # 日付 (YYYY-MM-DD)
    time: Optional[str] = None  # 時間 (HH:MM)

    # 場所
    location_name: str  # 直売所名
    location_address: Optional[str] = None  # 住所

    # 商品
    items: list[ShipmentItem] = Field(default_factory=list)

    # その他
    note: Optional[str] = None  # 備考・メッセージ

    # メタ
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class Subscriber(BaseModel):
    """購読者"""
    id: Optional[str] = None
    farmer_id: str  # どの農家を購読するか

    # 通知方法
    email: Optional[str] = None
    push_subscription: Optional[dict] = None  # Webプッシュ用

    # 設定
    is_active: bool = True

    # メタ
    created_at: Optional[datetime] = None


class ShipmentPostRequest(BaseModel):
    """出荷情報投稿リクエスト（自然言語）"""
    farmer_id: str
    message: str  # 「今日10時に道の駅ひまわりにトマト100円出します」


class ShipmentPostStructuredRequest(BaseModel):
    """出荷情報投稿リクエスト（構造化）"""
    farmer_id: str
    date: str
    time: Optional[str] = None
    location_name: str
    location_address: Optional[str] = None
    items: list[ShipmentItem]
    note: Optional[str] = None


class SubscribeRequest(BaseModel):
    """購読登録リクエスト"""
    farmer_id: str
    email: Optional[str] = None
    push_subscription: Optional[dict] = None


class NotificationResult(BaseModel):
    """通知結果"""
    success: bool
    email_sent: int = 0
    push_sent: int = 0
    errors: list[str] = Field(default_factory=list)
