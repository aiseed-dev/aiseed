from config import RAW_DATA_DIR
import csv
import json
import os

TYPE = "crop"
# 入力CSVファイル名
csv_file = RAW_DATA_DIR / f"{TYPE}_data.csv"

if TYPE == "weec":
    field_map = {
        "番号": "id",
        "名前": "name",
    }
else:
    field_map = {
        "番号": "id",
        "和名": "name",
        "学名": "binominal name",
    }
# CSVを1行ずつ読み込んでJSONに変換
with open(csv_file, encoding='utf-8') as f:
    reader = csv.DictReader(f)
    data = []
    for row in reader:
        # フィールド名を英語に変換して新しい辞書にする
        new_row = {field_map[k]: v for k, v in row.items() if k in field_map}
        # 番号（id）を整数として保持（ソートのため）
        new_row["id"] = int(new_row["id"])
        data.append(new_row)

        # JSONとして保存（インデント付きで読みやすく）
    path = RAW_DATA_DIR / f"{TYPE}_data.json"
    with open(path, "w", encoding='utf-8') as jsonfile:
        json.dump(data, jsonfile, ensure_ascii=False, indent=2)
