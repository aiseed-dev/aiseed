from config import RAW_DATA_DIR
import json

path = RAW_DATA_DIR / "weed_raw_response" / "w1_20250714_191308.txt"

with open(path, "r") as f:
    response_text = f.read()
# マークダウンのコードブロックを除去
start = response_text.find("```json")
if start != -1:
    response_text = response_text[start + len("```json"):].lstrip()
if response_text.endswith("```"):
    response_text = response_text.rstrip()[:-3]
weed_data = json.loads(response_text)

path = RAW_DATA_DIR / "weed" / "w1_20250714_191308.json"
with open(path, "w") as f:
    f.write(json.dumps(weed_data, ensure_ascii=False, indent=2))