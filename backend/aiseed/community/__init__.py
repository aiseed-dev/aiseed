"""
コミュニティ機能モジュール

生産者と消費者の軽いコミュニケーションを実現
- お気に入り（フォロー）
- 来店記録（チェックイン）
- 通知設定
"""

from .models import Favorite, CheckIn, NotificationSettings
from .service import CommunityService

__all__ = ["Favorite", "CheckIn", "NotificationSettings", "CommunityService"]
