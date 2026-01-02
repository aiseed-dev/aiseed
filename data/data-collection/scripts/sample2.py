from config import RAW_DATA_DIR

import pandas as pd

path = RAW_DATA_DIR / "weed_data.csv"
# CSVファイルの読み込み
df = pd.read_csv(path)

# 番号列を先頭に追加（1から始まる連番）
df.insert(0, "番号", range(1, len(df) + 1))

# 上書き保存（または別名で保存）
df.to_csv(path, index=False)