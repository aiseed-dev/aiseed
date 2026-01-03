# Test Data

AIテスター用のテストデータを格納するディレクトリ

## ディレクトリ構成

```
test_data/
├── grow/           # Growサービス用画像
│   ├── pest_*.jpg        # 害虫写真
│   ├── disease_*.jpg     # 病気写真
│   └── seedling_*.jpg    # 苗の写真
└── README.md
```

## 画像の追加方法

1. Facebookグループから画像をダウンロード
2. 適切なサブディレクトリに配置
3. `test_ai.py` のシナリオに画像パスを追加

例:
```python
{
    "id": "grow_img_pest_identify",
    "images": [
        "test_data/grow/pest_01.jpg",
        "test_data/grow/pest_02.jpg",
    ],
    ...
}
```

## 法的注意事項

- AI訓練目的での利用は著作権法30条の4で許可されています
- 画像は再配布しないでください
- 個人情報が写っている場合は除外してください
