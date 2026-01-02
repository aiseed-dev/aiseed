# scripts/config.py
from pathlib import Path

# プロジェクトルートの定義
SCRIPT_DIR = Path(__file__).parent
TEMPLATES_DIR = SCRIPT_DIR / "templates"
PROJECT_ROOT = SCRIPT_DIR.parent

# 共通ディレクトリ
RAW_DATA_DIR = PROJECT_ROOT / "raw_data"
PROCESSED_DATA_DIR = PROJECT_ROOT / "processed_data"
LOGS_DIR = PROJECT_ROOT / "logs"

# サブディレクトリ
GEMINI_RESPONSES_DIR = RAW_DATA_DIR / "gemini_responses"
WEED_DIR = RAW_DATA_DIR / "weed"
MANUAL_ENTRIES_DIR = RAW_DATA_DIR / "manual_entries"
IMAGES_DIR = RAW_DATA_DIR / "images"

# ファイルパス
SPECIES_DB_JSON = PROCESSED_DATA_DIR / "species_database.json"

# ディレクトリ作成
def init_directories():
    """必要なディレクトリを作成"""
    for dir_path in [RAW_DATA_DIR, PROCESSED_DATA_DIR, LOGS_DIR,
                     GEMINI_RESPONSES_DIR, WEED_DIR,
                     MANUAL_ENTRIES_DIR, IMAGES_DIR]:
        dir_path.mkdir(parents=True, exist_ok=True)