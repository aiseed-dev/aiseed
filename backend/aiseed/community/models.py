"""
コミュニティ機能のデータモデル
"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


class Favorite(BaseModel):
    """お気に入り（フォロー）"""
    id: Optional[str] = None
    user_id: str  # 消費者のID
    farmer_id: str  # フォローする農家/店舗のID

    # 通知設定
    notify_shipment: bool = True  # 出荷情報の通知を受け取る

    # メタ
    created_at: Optional[datetime] = None


class CheckIn(BaseModel):
    """来店記録"""
    id: Optional[str] = None
    user_id: str  # 来店した消費者
    farmer_id: str  # 農家/店舗
    location_name: Optional[str] = None  # 来店場所（直売所名など）

    # メタ
    created_at: Optional[datetime] = None


class NotificationSettings(BaseModel):
    """通知設定"""
    user_id: str

    # 通知方法
    email: Optional[str] = None
    push_enabled: bool = False
    push_subscription: Optional[dict] = None

    # 通知の種類
    notify_shipment: bool = True  # 出荷情報
    notify_thanks: bool = True  # お礼メッセージ

    # メタ
    updated_at: Optional[datetime] = None


class FarmerStats(BaseModel):
    """農家/店舗の統計"""
    farmer_id: str
    favorite_count: int = 0  # お気に入り登録数
    checkin_count: int = 0  # 総来店数
    today_checkin_count: int = 0  # 今日の来店数


# リクエスト/レスポンス
class FavoriteRequest(BaseModel):
    """お気に入り登録リクエスト"""
    user_id: str
    farmer_id: str
    notify_shipment: bool = True


class CheckInRequest(BaseModel):
    """来店記録リクエスト"""
    user_id: str
    farmer_id: str
    location_name: Optional[str] = None


class NotificationSettingsRequest(BaseModel):
    """通知設定更新リクエスト"""
    user_id: str
    email: Optional[str] = None
    push_enabled: bool = False
    push_subscription: Optional[dict] = None
    notify_shipment: bool = True
    notify_thanks: bool = True
