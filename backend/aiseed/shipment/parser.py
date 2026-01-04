"""
出荷情報パーサー

自然言語から出荷情報を抽出する
AIを使った解析とルールベースの解析を組み合わせる
"""
import re
import logging
from datetime import datetime, timedelta
from typing import Optional

from .models import ShipmentInfo, ShipmentItem

logger = logging.getLogger("aiseed.shipment.parser")


class ShipmentParser:
    """出荷情報パーサー"""

    # よくある野菜名
    VEGETABLES = [
        "トマト", "ミニトマト", "きゅうり", "キュウリ", "なす", "ナス",
        "ピーマン", "パプリカ", "にんじん", "ニンジン", "人参",
        "大根", "だいこん", "白菜", "はくさい", "キャベツ",
        "レタス", "ほうれん草", "ホウレンソウ", "小松菜", "こまつな",
        "ねぎ", "ネギ", "玉ねぎ", "タマネギ", "にんにく", "ニンニク",
        "じゃがいも", "ジャガイモ", "さつまいも", "サツマイモ",
        "かぼちゃ", "カボチャ", "ズッキーニ", "とうもろこし",
        "枝豆", "えだまめ", "いんげん", "オクラ", "ゴーヤ",
        "しそ", "シソ", "大葉", "バジル", "パセリ",
        "いちご", "イチゴ", "ブルーベリー", "みかん", "りんご",
    ]

    # 直売所のパターン
    LOCATION_PATTERNS = [
        r"道の駅\s*[\w]+",
        r"ファーマーズマーケット\s*[\w]*",
        r"JA\s*[\w]+",
        r"直売所\s*[\w]*",
        r"[\w]+農園",
        r"[\w]+市場",
    ]

    def parse(self, farmer_id: str, message: str) -> Optional[ShipmentInfo]:
        """
        自然言語から出荷情報を抽出

        例:
        - 「今日10時に道の駅ひまわりにトマト100円とナス150円出します」
        - 「明日の朝、JA直売所でキュウリ3本100円」
        """
        try:
            # 日付を抽出
            date = self._parse_date(message)

            # 時間を抽出
            time = self._parse_time(message)

            # 場所を抽出
            location = self._parse_location(message)

            # 商品を抽出
            items = self._parse_items(message)

            if not location and not items:
                logger.warning(f"Could not parse: {message[:50]}...")
                return None

            return ShipmentInfo(
                farmer_id=farmer_id,
                date=date,
                time=time,
                location_name=location or "直売所",
                items=items,
            )

        except Exception as e:
            logger.error(f"Parse error: {e}")
            return None

    def _parse_date(self, message: str) -> str:
        """日付を抽出"""
        today = datetime.now()

        # 「今日」
        if "今日" in message:
            return today.strftime("%Y-%m-%d")

        # 「明日」
        if "明日" in message:
            return (today + timedelta(days=1)).strftime("%Y-%m-%d")

        # 「明後日」
        if "明後日" in message or "あさって" in message:
            return (today + timedelta(days=2)).strftime("%Y-%m-%d")

        # 「〇月〇日」パターン
        match = re.search(r"(\d{1,2})月(\d{1,2})日", message)
        if match:
            month, day = int(match.group(1)), int(match.group(2))
            year = today.year
            # 月が過去なら来年と判断
            if month < today.month:
                year += 1
            return f"{year}-{month:02d}-{day:02d}"

        # 「〇/〇」パターン
        match = re.search(r"(\d{1,2})/(\d{1,2})", message)
        if match:
            month, day = int(match.group(1)), int(match.group(2))
            year = today.year
            if month < today.month:
                year += 1
            return f"{year}-{month:02d}-{day:02d}"

        # デフォルトは今日
        return today.strftime("%Y-%m-%d")

    def _parse_time(self, message: str) -> Optional[str]:
        """時間を抽出"""
        # 「〇時」パターン
        match = re.search(r"(\d{1,2})時(?:(\d{1,2})分)?", message)
        if match:
            hour = int(match.group(1))
            minute = int(match.group(2)) if match.group(2) else 0
            return f"{hour:02d}:{minute:02d}"

        # 「〇:〇〇」パターン
        match = re.search(r"(\d{1,2}):(\d{2})", message)
        if match:
            return f"{int(match.group(1)):02d}:{match.group(2)}"

        # 「朝」「午前」
        if "朝" in message or "午前" in message:
            return "09:00"

        # 「昼」
        if "昼" in message:
            return "12:00"

        # 「午後」「夕方」
        if "午後" in message:
            return "14:00"
        if "夕方" in message:
            return "17:00"

        return None

    def _parse_location(self, message: str) -> Optional[str]:
        """場所を抽出"""
        # パターンマッチ
        for pattern in self.LOCATION_PATTERNS:
            match = re.search(pattern, message)
            if match:
                return match.group()

        # 「〇〇に」「〇〇で」パターン
        match = re.search(r"([\w]+(?:直売所|農園|市場|道の駅))(?:に|で|へ)", message)
        if match:
            return match.group(1)

        return None

    def _parse_items(self, message: str) -> list[ShipmentItem]:
        """商品を抽出"""
        items = []

        # 野菜名 + 価格のパターン
        for veg in self.VEGETABLES:
            # 「トマト100円」「トマト 100円」
            pattern = rf"{veg}\s*(\d+)\s*円"
            match = re.search(pattern, message)
            if match:
                items.append(ShipmentItem(
                    name=veg,
                    price=int(match.group(1)),
                ))
                continue

            # 「トマト3個100円」「トマト 3個 100円」
            pattern = rf"{veg}\s*(\d+)\s*(個|袋|本|束|パック|kg|g)\s*(\d+)\s*円"
            match = re.search(pattern, message)
            if match:
                items.append(ShipmentItem(
                    name=veg,
                    price=int(match.group(3)),
                    quantity=match.group(1),
                    unit=match.group(2),
                ))

        # 汎用パターン: 「〇〇 100円」
        if not items:
            pattern = r"([\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF]+)\s*(\d+)\s*円"
            for match in re.finditer(pattern, message):
                name = match.group(1)
                # 除外ワード
                if name in ["合計", "計", "税", "送料"]:
                    continue
                items.append(ShipmentItem(
                    name=name,
                    price=int(match.group(2)),
                ))

        return items


async def parse_with_ai(
    farmer_id: str,
    message: str,
    ai_query_func
) -> Optional[ShipmentInfo]:
    """
    AIを使って出荷情報を解析

    より複雑な文章や曖昧な表現に対応
    """
    prompt = f'''
以下のメッセージから出荷情報を抽出してください。

メッセージ: {message}

JSON形式で出力してください:
{{
    "date": "YYYY-MM-DD",
    "time": "HH:MM" or null,
    "location_name": "場所名",
    "location_address": "住所" or null,
    "items": [
        {{"name": "商品名", "price": 価格(数値), "unit": "単位", "quantity": "数量" or null}}
    ],
    "note": "備考" or null
}}

今日の日付: {datetime.now().strftime("%Y-%m-%d")}
'''

    try:
        response = await ai_query_func(prompt)

        import json
        # JSONを抽出
        json_match = re.search(r'\{[\s\S]*\}', response)
        if json_match:
            data = json.loads(json_match.group())

            items = [
                ShipmentItem(**item)
                for item in data.get("items", [])
            ]

            return ShipmentInfo(
                farmer_id=farmer_id,
                date=data.get("date", datetime.now().strftime("%Y-%m-%d")),
                time=data.get("time"),
                location_name=data.get("location_name", "直売所"),
                location_address=data.get("location_address"),
                items=items,
                note=data.get("note"),
            )

    except Exception as e:
        logger.error(f"AI parse error: {e}")

    # フォールバック: ルールベース
    parser = ShipmentParser()
    return parser.parse(farmer_id, message)
