# 指示

あなたは、植物の系統や育種の歴史に詳しい、経験豊かな農業研究家です。リジェネラティブ農業における多様な作物の役割についても深い知見を持っています。

これから、作物や緑肥の品種を体系的に整理するための、基礎となるデータベースを作成します。
今回は、個別の品種ではなく、「トマト」という**「種」全体**に関する情報を、以下のJSONスキーマに従って生成してください。

# 特に重視する点

1.  **`history_and_origin`**: この作物が持つグローバルな歴史的背景を重視してください。特に`spread_and_adaptation_history`では、各地域でどのように受容され、文化に根付いていったかのストーリーがわかるように記述してください。

2.  **`role_in_regenerative_agriculture`**: 単なる栽培植物としてではなく、土壌改良、生物多様性への貢献といった、生態系におけるポジティブな役割を多角的に記述してください。

3.  **`cultivar_diversity_info`**: このセクションは、今後の品種整理の基盤となるため、最も重要です。
    - `summary`では、この種が持つ多様性の全体像を要約してください。
    - `classification_axes`では、実践者が品種群を理解しやすくなるような、**本質的で多様な分類の「軸」**を複数提案してください。（例：サイズ、形、用途、草型、熟期など）
    - `traditional_and_heirloom_varieties`では、その種の多様性を象徴するような、代表的な固定種や伝統品種をいくつか挙げて、その特徴に触れてください。

もし情報が不明な項目があれば、`null`ではなく、空の文字列 `""` または空の配列 `[]` を使用してください。

# JSONスキーマ
```json
{
  "name_jp": "標準和名（例：トマト）",
  "name_kana": "ヨミガナ",
  "scientific_name": "学名",
  "family_jp": "科名",
  "common_names": {
    "en": ["英語名"],
    "jp": ["別名"]
  },
  "type": "種別（作物, 緑肥, 兼用）", // ★分類のためのタグ

  "history_and_origin": {
    "place_of_origin": "原産地（例：南米アンデス山脈）",
    "history_of_domestication": "栽培化の歴史の要約",
    "spread_and_adaptation_history": [ // ★ "introduction_to_japan" から変更
    {
      "region": "東アジア（日本、中国、朝鮮半島など）",
      "period": "伝来したおおよその時期（例：16世紀）",
      "route_and_process": "伝播の経緯や、その地域でどのように受容・土着化していったかの要約"
    },
    {
      "region": "ヨーロッパ（特に地中海沿岸）",
      "period": "伝来したおおよその時期（例：16世紀）",
      "route_and_process": "当初は観賞用だったが、後に食用として広まった経緯など"
    }
    // ... 他の重要な地域に関する情報を追加可能 ...
    ]
  },
  
  "botanical_characteristics": {
    "summary": "種としての植物学的特徴の要約",
    "growth_habit": "生育習性（つる性, 直立性, etc.）",
    "root_system": "根系の特徴（直根性, 浅根性, 窒素固定能力の有無など）",
    "flower_and_pollination": "花と受粉様式（自家受粉, 虫媒花など）",
    "life_cycle": "生活環（一年草, 多年草など）"
  },

  "role_in_regenerative_agriculture": {
    "summary": "リジェネラティブ農業における、この種の全体的な役割と価値",
    "soil_improvement_effects": ["窒素固定", "硬盤破砕", "有機物供給", "リン酸可溶化"],
    "biodiversity_contribution": ["益虫の誘引（バンカープランツ）", "蜜源・花粉源"],
    "allelopathy_info": "アレロパシー（他の植物への影響）に関する情報",
    "cover_crop_potential": "被覆作物（カバークロップ）としての適性評価（被覆速度, 越冬性など）"
  },
  
  // ★★★ このセクションが品種群設定の参考となる ★★★
  "cultivar_diversity_info": {
    "summary": "この種が持つ多様性の概要（例：果実の色、形、大きさ、早晩性など、多様な品種が存在する）",
    "classification_axes": [ // ★品種を分類するための「軸」を列挙
      {
        "axis_name": "果実のサイズによる分類",
        "groups": ["大玉系", "中玉系", "ミニトマト系"]
      },
      {
        "axis_name": "草型による分類",
        "groups": ["芯止まり性（ブッシュ型）", "非芯止まり性（つる性）"]
      },
      {
        "axis_name": "利用目的による分類",
        "groups": ["生食用品種", "加工用品種"]
      },
      {
        "axis_name": "熟期による分類",
        "groups": ["早生", "中生", "晩生"]
      }
    ],
    "breeding_history_summary": "主要な育種の歴史や方向性（例：病害虫抵抗性、収量性、食味向上など）",
    "traditional_and_heirloom_varieties": "代表的な固定種や伝統品種に関する情報"
  },

  "basic_cultivation_info": {
    "climate_preference": "好む気候条件（冷涼, 温暖など）",
    "soil_preference": "好む土壌条件（pH, 排水性など）",
    "sowing_season": "播種の代表的な時期",
    "harvesting_season": "収穫の代表的な時期",
    "major_pests_and_diseases": "この種に共通して見られる主要な病害虫"
  },

  "references": ["参考にした情報源のURLや書籍名"]
}
---