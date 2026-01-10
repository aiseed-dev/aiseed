/// AIリサーチガイド - プロンプトテンプレート集
///
/// ユーザーが自分のAI（ChatGPT、Claude等）で調べるためのプロンプト
library;

/// リサーチカテゴリ
enum ResearchCategory {
  soil('soil', '🌍', '土壌', 'Soil'),
  climate('climate', '🌡️', '気候', 'Climate'),
  plantCare('plant_care', '🌱', '栽培方法', 'Plant Care'),
  pestDisease('pest_disease', '🐛', '病害虫', 'Pest & Disease'),
  companion('companion', '🤝', 'コンパニオンプランツ', 'Companion Plants'),
  harvest('harvest', '🍅', '収穫時期', 'Harvest Timing');

  final String id;
  final String emoji;
  final String nameJa;
  final String nameEn;

  const ResearchCategory(this.id, this.emoji, this.nameJa, this.nameEn);
}

/// リサーチプロンプト
class ResearchPrompt {
  final String id;
  final ResearchCategory category;
  final String titleJa;
  final String titleEn;
  final String descriptionJa;
  final String descriptionEn;
  final String promptTemplateJa;
  final String promptTemplateEn;
  final String exampleInputJa;
  final String exampleInputEn;
  final String exampleOutputJa;
  final String exampleOutputEn;
  final List<String> placeholders;

  const ResearchPrompt({
    required this.id,
    required this.category,
    required this.titleJa,
    required this.titleEn,
    required this.descriptionJa,
    required this.descriptionEn,
    required this.promptTemplateJa,
    required this.promptTemplateEn,
    required this.exampleInputJa,
    required this.exampleInputEn,
    required this.exampleOutputJa,
    required this.exampleOutputEn,
    this.placeholders = const [],
  });

  /// プレースホルダーを置換してプロンプトを生成
  String generatePrompt({
    required String locale,
    required Map<String, String> values,
  }) {
    var template = locale == 'ja' ? promptTemplateJa : promptTemplateEn;
    for (final entry in values.entries) {
      template = template.replaceAll('{${entry.key}}', entry.value);
    }
    return template;
  }
}

/// 土壌リサーチプロンプト集
class SoilResearchPrompts {
  static const basic = ResearchPrompt(
    id: 'soil_basic',
    category: ResearchCategory.soil,
    titleJa: '地域の土壌を調べる',
    titleEn: 'Research Local Soil',
    descriptionJa: 'あなたの地域で一般的な土壌タイプを調べます',
    descriptionEn: 'Find out the common soil type in your area',
    promptTemplateJa: '''
{location}で家庭菜園・農業をしています。

この地域で一般的な土壌の種類を教えてください。
以下の形式で回答してください：

1. 土壌の種類（日本語名）
2. WRB国際土壌分類での名称（英語）
3. 土壌の特徴（色、質感、水はけなど）
4. この土壌に適した野菜・作物
5. この土壌で注意すべき点
''',
    promptTemplateEn: '''
I'm doing gardening/farming in {location}.

Please tell me about the common soil type in this area.
Please answer in the following format:

1. Soil type name
2. WRB (World Reference Base) classification name
3. Soil characteristics (color, texture, drainage, etc.)
4. Vegetables/crops suitable for this soil
5. Points to note when using this soil
''',
    exampleInputJa: '神奈川県横浜市',
    exampleInputEn: 'Yokohama, Kanagawa Prefecture, Japan',
    exampleOutputJa: '''
1. 土壌の種類：黒ボク土
2. WRB分類：Andosols（アンドソル）
3. 特徴：
   - 黒褐色で腐植に富む
   - 関東ローム層由来の火山灰土壌
   - 軽くてふかふかしている
   - リン酸の固定力が強い
4. 適した作物：
   - 根菜類（大根、人参）
   - 葉物野菜全般
   - ジャガイモ
5. 注意点：
   - リン酸肥料が効きにくい
   - 酸性に傾きやすい
   - 乾燥しやすい
''',
    exampleOutputEn: '''
1. Soil type: Andosol (Volcanic ash soil)
2. WRB classification: Andosols
3. Characteristics:
   - Dark brown color, rich in humus
   - Derived from Kanto Loam volcanic ash
   - Light and fluffy texture
   - Strong phosphate fixation
4. Suitable crops:
   - Root vegetables (daikon, carrots)
   - Leafy greens
   - Potatoes
5. Notes:
   - Phosphate fertilizers less effective
   - Tends toward acidity
   - Dries out easily
''',
    placeholders: ['location'],
  );

  static const detailed = ResearchPrompt(
    id: 'soil_detailed',
    category: ResearchCategory.soil,
    titleJa: '土壌を詳しく分析',
    titleEn: 'Detailed Soil Analysis',
    descriptionJa: '土壌の見た目から詳しい特性を調べます',
    descriptionEn: 'Analyze soil characteristics from appearance',
    promptTemplateJa: '''
私の畑の土壌について教えてください。

【土壌の観察結果】
- 場所：{location}
- 色：{color}
- 手触り：{texture}
- 水はけ：{drainage}
- その他の特徴：{other}

この情報から：
1. 推定される土壌タイプ（WRB分類）
2. 土壌のpH傾向
3. 適している農法
4. 改良のアドバイス
を教えてください。
''',
    promptTemplateEn: '''
Please tell me about my garden soil.

【Soil Observations】
- Location: {location}
- Color: {color}
- Texture: {texture}
- Drainage: {drainage}
- Other features: {other}

Based on this information, please tell me:
1. Estimated soil type (WRB classification)
2. pH tendency
3. Suitable farming methods
4. Improvement advice
''',
    exampleInputJa: '色：黒っぽい、手触り：さらさら、水はけ：良い',
    exampleInputEn: 'Color: dark, Texture: sandy, Drainage: good',
    exampleOutputJa: '''
推定土壌：黒ボク土（Andosols）

1. pH傾向：弱酸性（pH 5.5-6.5）
2. 適した農法：
   - 自然栽培（土壌微生物が豊富）
   - 不耕起栽培（土壌構造を活かす）
3. 改良アドバイス：
   - �iteite石灰で酸度調整
   - 堆肥で保水性向上
   - マルチングで乾燥防止
''',
    exampleOutputEn: '''
Estimated soil: Andosol

1. pH tendency: Slightly acidite (pH 5.5-6.5)
2. Suitable methods:
   - Natural farming (rich soil microbes)
   - No-till farming (preserves structure)
3. Improvement advice:
   - Lime to adjust acidity
   - Compost for water retention
   - Mulching to prevent drying
''',
    placeholders: ['location', 'color', 'texture', 'drainage', 'other'],
  );

  /// 土壌の3要素（物理性・生物性・化学性）を総合的に調べる
  static const comprehensive = ResearchPrompt(
    id: 'soil_comprehensive',
    category: ResearchCategory.soil,
    titleJa: '土壌の3要素を調べる',
    titleEn: 'Comprehensive Soil Analysis',
    descriptionJa: '物理性・生物性・化学性の3つの観点で土壌を診断',
    descriptionEn: 'Diagnose soil from physical, biological, and chemical aspects',
    promptTemplateJa: '''
{location}で{farming_method}をしています。

土壌について、以下の3つの観点から教えてください。

【1. 物理性（Physical Properties）】
- この地域で一般的な土性（砂質/壌土/粘土質）
- 団粒構造の傾向
- 排水性・保水性の特徴
- 物理性を改善するためのアドバイス

【2. 生物性（Biological Properties）】
- 土壌生物（微生物、ミミズなど）を増やす方法
- 有機物の施用方法（堆肥、緑肥、草マルチなど）
- 自然農法で土を育てるポイント
- 健康な土の見分け方（匂い、色など）

【3. 化学性（Chemical Properties）】
- この地域の土壌のpH傾向
- 不足しがちな養分（窒素、リン酸、カリウムなど）
- 化学肥料を使わない養分管理の方法
- 土壌改良材の自然な選択肢

※{farming_method}の考え方に沿った、自然なアドバイスをお願いします。
''',
    promptTemplateEn: '''
I'm practicing {farming_method} in {location}.

Please tell me about the soil from these three perspectives:

【1. Physical Properties】
- Common soil texture in this area (sandy/loam/clay)
- Soil aggregate structure tendency
- Drainage and water retention characteristics
- Advice for improving physical properties

【2. Biological Properties】
- How to increase soil life (microbes, earthworms, etc.)
- Organic matter application (compost, green manure, grass mulch)
- Tips for building soil naturally
- How to recognize healthy soil (smell, color, etc.)

【3. Chemical Properties】
- pH tendency in this region
- Nutrients that tend to be deficient (N, P, K, etc.)
- Natural nutrient management without chemical fertilizers
- Natural soil amendment options

※Please provide advice aligned with {farming_method} principles.
''',
    exampleInputJa: '神奈川県横浜市、自然栽培',
    exampleInputEn: 'Yokohama, Japan, Natural farming',
    exampleOutputJa: '''
【神奈川県横浜市の土壌診断（自然栽培向け）】

■ 1. 物理性
土性：黒ボク土（火山灰土壌）、軽くてふかふか
団粒構造：形成されやすいが、耕しすぎると崩れる
排水性：良好（乾燥しやすい）
保水性：やや低い

改善アドバイス：
- 草マルチで土を覆い、乾燥を防ぐ
- 不耕起または浅耕起で団粒構造を維持
- 緑肥の根で土を柔らかく保つ

■ 2. 生物性
土壌微生物：火山灰土壌は微生物が定着しやすい
ミミズ：有機物を入れると増える

改善アドバイス：
- 落ち葉、刈り草をマルチとして敷く
- 米ぬかボカシで微生物を活性化
- 冬も緑肥（ライムギ等）で根を維持
- 健康な土の匂い＝森の香り

■ 3. 化学性
pH：弱酸性（5.5-6.5）に傾きやすい
不足しがち：リン酸（火山灰に固定される）

改善アドバイス：
- 米ぬか、油かすで窒素補給
- 骨粉、魚粉でリン酸補給（ゆっくり効く）
- 草木灰でカリウム＋pH調整
- 貝殻石灰で酸度を緩やかに調整
''',
    exampleOutputEn: '''
【Yokohama Soil Diagnosis (Natural Farming)】

■ 1. Physical Properties
Texture: Andosol (volcanic ash), light and fluffy
Aggregation: Forms easily, but breaks down if over-tilled
Drainage: Good (dries quickly)
Water retention: Somewhat low

Improvement:
- Grass mulch to prevent drying
- No-till or shallow tillage to maintain structure
- Green manure roots to keep soil loose

■ 2. Biological Properties
Microbes: Volcanic ash soil supports microbial life
Earthworms: Increase with organic matter

Improvement:
- Apply fallen leaves, grass clippings as mulch
- Rice bran bokashi to activate microbes
- Winter green manure (rye) to maintain roots
- Healthy soil smells like forest

■ 3. Chemical Properties
pH: Tends toward slight acidity (5.5-6.5)
Deficiency: Phosphorus (fixed by volcanic ash)

Improvement:
- Rice bran, oil cake for nitrogen
- Bone meal, fish meal for phosphorus
- Wood ash for potassium + pH adjustment
- Oyster shell lime for gentle pH correction
''',
    placeholders: ['location', 'farming_method'],
  );

  /// 土壌観察による簡易診断
  static const quickDiagnosis = ResearchPrompt(
    id: 'soil_quick_diagnosis',
    category: ResearchCategory.soil,
    titleJa: '土壌を観察して診断',
    titleEn: 'Soil Observation Diagnosis',
    descriptionJa: '5つの観察項目から土壌の状態を診断',
    descriptionEn: 'Diagnose soil condition from 5 observations',
    promptTemplateJa: '''
畑の土を観察しました。診断してください。

【観察結果】
1. 場所：{location}
2. 土を握ると：{grip_test}
3. 雨の後の状態：{after_rain}
4. 土の匂い：{smell}
5. 掘った時の様子：{digging}

【教えてほしいこと】
- 土壌タイプの推定
- 物理性の評価（団粒構造、排水性）
- 生物性の評価（微生物活性、土壌動物）
- 化学性の傾向（pH、養分）
- 自然農法での改善優先順位
- 具体的な改善方法
''',
    promptTemplateEn: '''
I observed my garden soil. Please diagnose it.

【Observations】
1. Location: {location}
2. When squeezed: {grip_test}
3. After rain: {after_rain}
4. Soil smell: {smell}
5. When digging: {digging}

【Please tell me】
- Estimated soil type
- Physical assessment (aggregation, drainage)
- Biological assessment (microbial activity, soil fauna)
- Chemical tendency (pH, nutrients)
- Improvement priorities for natural farming
- Specific improvement methods
''',
    exampleInputJa: '握ると軽く固まりすぐ崩れる、翌日には乾く、森のような香り、ミミズが数匹いた',
    exampleInputEn: 'Forms lightly when squeezed then crumbles, dries by next day, forest-like smell, found several earthworms',
    exampleOutputJa: '''
【診断結果】

■ 土壌タイプ：壌土〜砂壌土（良好な土性）

■ 物理性評価：★★★★☆
- 団粒構造：良好（握って崩れる）
- 排水性：良好（翌日乾く）
- 保水性：やや低め

■ 生物性評価：★★★★★
- 微生物活性：高い（森の香り＝放線菌が活発）
- ミミズ：存在確認（有機物分解が進んでいる）

■ 化学性傾向：
- pH：中性〜弱酸性と推定
- 有機物：豊富（香りから判断）

■ 改善優先順位：
1. 保水性の向上（乾燥防止）
2. 現状維持（良い状態）

■ 具体的アドバイス：
- 草マルチを継続して乾燥を防ぐ
- 耕しすぎない（今の団粒構造を維持）
- 有機物を少しずつ追加し続ける
''',
    exampleOutputEn: '''
【Diagnosis Result】

■ Soil Type: Loam to sandy loam (good texture)

■ Physical Assessment: ★★★★☆
- Aggregation: Good (crumbles when squeezed)
- Drainage: Good (dries by next day)
- Water retention: Slightly low

■ Biological Assessment: ★★★★★
- Microbial activity: High (forest smell = active actinomycetes)
- Earthworms: Present (organic matter decomposing well)

■ Chemical Tendency:
- pH: Estimated neutral to slightly acidic
- Organic matter: Rich (judged by smell)

■ Improvement Priority:
1. Improve water retention (prevent drying)
2. Maintain current state (good condition)

■ Specific Advice:
- Continue grass mulching to prevent drying
- Avoid over-tilling (maintain current aggregation)
- Keep adding organic matter gradually
''',
    placeholders: ['location', 'grip_test', 'after_rain', 'smell', 'digging'],
  );
}

/// 気候リサーチプロンプト集
class ClimateResearchPrompts {
  static const growingCalendar = ResearchPrompt(
    id: 'climate_calendar',
    category: ResearchCategory.climate,
    titleJa: '栽培カレンダーを作る',
    titleEn: 'Create Growing Calendar',
    descriptionJa: '地域と作物に合った栽培スケジュールを調べます',
    descriptionEn: 'Find the growing schedule for your area and crop',
    promptTemplateJa: '''
{location}で{plant}を育てたいです。

この地域の気候に合った栽培カレンダーを教えてください：

1. 播種・定植の適期（月）
2. 収穫時期の目安
3. 生育適温
4. この地域特有の注意点（霜、梅雨、台風など）
5. おすすめの品種（この気候に強いもの）
''',
    promptTemplateEn: '''
I want to grow {plant} in {location}.

Please tell me the growing calendar suitable for this climate:

1. Best time for sowing/transplanting (month)
2. Expected harvest time
3. Optimal growing temperature
4. Regional considerations (frost, rainy season, typhoons, etc.)
5. Recommended varieties (suited for this climate)
''',
    exampleInputJa: '東京都、ミニトマト',
    exampleInputEn: 'Tokyo, Japan, Cherry tomatoes',
    exampleOutputJa: '''
【東京でのミニトマト栽培カレンダー】

1. 播種・定植：
   - 種まき：2月下旬〜3月（室内育苗）
   - 定植：4月下旬〜5月上旬（遅霜後）

2. 収穫時期：6月下旬〜10月

3. 生育適温：20〜30℃（夜温15℃以上）

4. 地域の注意点：
   - 4月中旬まで遅霜の可能性
   - 6月の梅雨：病気に注意
   - 7-8月の猛暑：遮光・水やり
   - 9月の台風：支柱補強

5. おすすめ品種：
   - アイコ（耐病性、裂果しにくい）
   - 千果（多収、暑さに強い）
''',
    exampleOutputEn: '''
【Cherry Tomato Calendar for Tokyo】

1. Sowing/Transplanting:
   - Seed: Late Feb-Mar (indoor)
   - Transplant: Late Apr-Early May

2. Harvest: Late June - October

3. Optimal temp: 20-30°C (night 15°C+)

4. Regional notes:
   - Late frost possible until mid-April
   - June rainy season: disease risk
   - July-Aug heat: shade & water
   - September typhoons: stake support

5. Recommended varieties:
   - Aiko (disease resistant)
   - Senka (high yield, heat tolerant)
''',
    placeholders: ['location', 'plant'],
  );

  static const microclimate = ResearchPrompt(
    id: 'climate_micro',
    category: ResearchCategory.climate,
    titleJa: '栽培環境の微気候',
    titleEn: 'Microclimate Analysis',
    descriptionJa: 'ベランダやプランターなど特定環境の気候を調べます',
    descriptionEn: 'Analyze climate for specific environments like balconies',
    promptTemplateJa: '''
以下の環境で野菜を育てたいです：

【栽培環境】
- 場所：{location}
- 環境タイプ：{environment}（例：南向きベランダ、北側の庭など）
- 日当たり：{sunlight}
- 風通し：{wind}

この環境の微気候の特徴と、適した野菜を教えてください。
''',
    promptTemplateEn: '''
I want to grow vegetables in the following environment:

【Growing Environment】
- Location: {location}
- Environment type: {environment} (e.g., south-facing balcony)
- Sunlight: {sunlight}
- Wind: {wind}

Please tell me about the microclimate and suitable vegetables.
''',
    exampleInputJa: '南向きベランダ、日当たり6時間、風通し良好',
    exampleInputEn: 'South-facing balcony, 6 hours sunlight, good airflow',
    exampleOutputJa: '''
【南向きベランダの微気候特性】

特徴：
- 夏場はコンクリートの照り返しで高温
- 冬場は日当たり良好で暖かい
- 雨が当たりにくい

適した野菜：
- トマト、ナス、ピーマン（実物野菜）
- バジル、シソ（ハーブ類）
- 日当たり好きな野菜全般

注意点：
- 真夏は遮光が必要
- 水やりは朝夕2回
- 鉢は二重にして根の高温を防ぐ
''',
    exampleOutputEn: '''
【South-facing Balcony Microclimate】

Characteristics:
- High temps in summer from concrete reflection
- Warm in winter with good sunlight
- Protected from rain

Suitable vegetables:
- Tomatoes, eggplants, peppers
- Basil, shiso (herbs)
- Sun-loving vegetables

Notes:
- Shade needed in midsummer
- Water twice daily (morning/evening)
- Double-pot to protect roots from heat
''',
    placeholders: ['location', 'environment', 'sunlight', 'wind'],
  );

  /// 地域の気候を総合的に調べる
  static const comprehensive = ResearchPrompt(
    id: 'climate_comprehensive',
    category: ResearchCategory.climate,
    titleJa: '地域の気候を調べる',
    titleEn: 'Research Local Climate',
    descriptionJa: '栽培に必要な気候情報を総合的に調べます',
    descriptionEn: 'Comprehensive climate information for growing',
    promptTemplateJa: '''
{location}で家庭菜園・自然農法をしています。

この地域の気候について、以下を教えてください：

【1. 気候の基本情報】
- 気候区分（ケッペン分類や日本の気候区分）
- 年間平均気温、最高・最低気温
- 年間降水量と降雨パターン

【2. 栽培カレンダーの目安】
- 最終霜日・初霜日の目安
- 栽培可能期間（霜なし期間）
- 梅雨の時期と特徴
- 台風シーズン

【3. 季節ごとの特徴】
- 春：遅霜リスク、植え付け開始時期
- 夏：猛暑日、水やりの注意点
- 秋：収穫適期、秋まきの時期
- 冬：寒さ対策、越冬できる野菜

【4. 自然農法での気候活用】
- この気候に適した野菜・作物
- 季節の変化を活かした栽培のコツ
- 気候の課題と自然な対策
''',
    promptTemplateEn: '''
I'm doing home gardening/natural farming in {location}.

Please tell me about the climate in this area:

【1. Basic Climate Information】
- Climate classification (Köppen or regional)
- Annual average, max, and min temperatures
- Annual precipitation and rainfall patterns

【2. Growing Calendar Guidelines】
- Last frost date / First frost date
- Growing season length (frost-free period)
- Rainy season timing and characteristics
- Typhoon/storm season

【3. Seasonal Characteristics】
- Spring: Late frost risks, planting start
- Summer: Heat waves, watering needs
- Fall: Harvest timing, fall planting window
- Winter: Cold protection, overwintering crops

【4. Natural Farming in This Climate】
- Vegetables/crops suited to this climate
- Tips for working with seasonal changes
- Climate challenges and natural solutions
''',
    exampleInputJa: '神奈川県横浜市',
    exampleInputEn: 'Yokohama, Kanagawa, Japan',
    exampleOutputJa: '''
【神奈川県横浜市の気候】

■ 1. 基本情報
気候区分：温暖湿潤気候（Cfa）
年間平均気温：約16℃
最高気温：35℃前後（8月）
最低気温：2℃前後（1月）
年間降水量：約1,600mm

■ 2. 栽培カレンダー
最終霜日：4月上旬
初霜日：11月下旬
栽培可能期間：約230日
梅雨：6月上旬〜7月中旬（約40日）
台風：8月〜10月

■ 3. 季節の特徴
【春】3-5月
- 4月上旬まで遅霜注意
- GW頃から夏野菜定植OK
- 寒暖差が大きい

【夏】6-8月
- 梅雨時は病気に注意
- 7-8月は猛暑、朝夕の水やり
- 台風対策（支柱補強）

【秋】9-11月
- 9月は残暑、秋まき開始
- 10-11月は収穫最盛期
- 11月下旬から霜対策

【冬】12-2月
- 霜よけ・トンネル必要
- ホウレンソウ、小松菜は越冬可能
- 2月後半から春の準備

■ 4. 自然農法での活用
適した野菜：トマト、ナス、キュウリ、大根、白菜
コツ：
- 梅雨前にマルチで泥はね防止
- 夏は草マルチで地温抑制
- 台風前は早めに収穫
課題と対策：
- 多湿→風通し確保、株間を広く
- 猛暑→遮光ネット、敷き藁
''',
    exampleOutputEn: '''
【Climate of Yokohama, Kanagawa】

■ 1. Basic Information
Classification: Humid subtropical (Cfa)
Annual average: ~16°C
Max temp: ~35°C (August)
Min temp: ~2°C (January)
Annual rainfall: ~1,600mm

■ 2. Growing Calendar
Last frost: Early April
First frost: Late November
Growing season: ~230 days
Rainy season: Early June - Mid July (~40 days)
Typhoons: August - October

■ 3. Seasonal Characteristics
【Spring】Mar-May
- Watch for late frost until early April
- Summer crops transplant after Golden Week
- Large temperature swings

【Summer】Jun-Aug
- Disease risk during rainy season
- Hot in Jul-Aug, water morning/evening
- Typhoon prep (stake reinforcement)

【Fall】Sep-Nov
- Lingering heat in Sep, start fall sowing
- Oct-Nov peak harvest season
- Frost protection from late November

【Winter】Dec-Feb
- Frost covers/tunnels needed
- Spinach, komatsuna can overwinter
- Start spring prep in late February

■ 4. Natural Farming Tips
Suitable crops: Tomato, eggplant, cucumber, daikon, napa cabbage
Tips:
- Mulch before rainy season to prevent splash
- Grass mulch in summer to cool soil
- Harvest early before typhoons
Challenges & solutions:
- Humidity → ensure airflow, wide spacing
- Heat → shade cloth, straw mulch
''',
    placeholders: ['location'],
  );
}

/// 栽培方法リサーチプロンプト集
class PlantCareResearchPrompts {
  static const naturalFarming = ResearchPrompt(
    id: 'care_natural',
    category: ResearchCategory.plantCare,
    titleJa: '自然農法での育て方',
    titleEn: 'Natural Farming Method',
    descriptionJa: '化学肥料・農薬を使わない栽培方法を調べます',
    descriptionEn: 'Learn chemical-free growing methods',
    promptTemplateJa: '''
{plant}を自然農法（無農薬・無化学肥料）で育てたいです。

以下について教えてください：

1. 土づくり（堆肥、緑肥など）
2. 種まき・定植のコツ
3. 水やり・管理のポイント
4. 自然な病害虫対策
5. コンパニオンプランツ
6. 収穫のタイミング

※できれば福岡正信、川口由一、木村秋則などの日本の自然農法の知見も含めてください。
''',
    promptTemplateEn: '''
I want to grow {plant} using natural farming (no pesticides, no chemical fertilizers).

Please tell me:

1. Soil preparation (compost, green manure, etc.)
2. Sowing/transplanting tips
3. Watering and care points
4. Natural pest control
5. Companion plants
6. Harvest timing

※Please include insights from Japanese natural farming pioneers like Masanobu Fukuoka if possible.
''',
    exampleInputJa: 'キュウリ',
    exampleInputEn: 'Cucumber',
    exampleOutputJa: '''
【キュウリの自然農法栽培】

1. 土づくり：
   - 完熟堆肥を2週間前に投入
   - 緑肥（クローバー）のすき込み
   - 草マルチで土を裸にしない

2. 種まき・定植：
   - 直播より育苗が安定
   - 本葉3-4枚で定植
   - 株間60cm（風通し重視）

3. 管理のポイント：
   - 敷き藁で地温安定・泥はね防止
   - 朝の水やり（葉を濡らさない）
   - つるは放任でOK（福岡式）

4. 病害虫対策：
   - うどんこ病：酢水スプレー
   - アブラムシ：テントウムシを呼ぶ
   - 木酢液で予防

5. コンパニオン：
   - ネギ類（病気予防）
   - トウモロコシ（日陰を作る）
   - マリーゴールド（線虫対策）

6. 収穫：
   - 20cm程度で若採り
   - 朝の涼しいうちに
''',
    exampleOutputEn: '''
【Natural Farming Cucumber Guide】

1. Soil prep:
   - Add mature compost 2 weeks before
   - Incorporate green manure (clover)
   - Grass mulch to protect soil

2. Sowing/transplanting:
   - Seedlings more stable than direct sow
   - Transplant at 3-4 true leaves
   - 60cm spacing (airflow)

3. Care points:
   - Straw mulch for temperature/splash
   - Morning watering (avoid leaves)
   - Let vines grow freely (Fukuoka style)

4. Pest control:
   - Powdery mildew: vinegar spray
   - Aphids: attract ladybugs
   - Wood vinegar for prevention

5. Companions:
   - Alliums (disease prevention)
   - Corn (provides shade)
   - Marigolds (nematode control)

6. Harvest:
   - Pick young at ~20cm
   - Morning harvest when cool
''',
    placeholders: ['plant'],
  );

  static const troubleshooting = ResearchPrompt(
    id: 'care_trouble',
    category: ResearchCategory.plantCare,
    titleJa: '生育トラブルの解決',
    titleEn: 'Growing Troubleshooting',
    descriptionJa: '植物の異常の原因と対策を調べます',
    descriptionEn: 'Find causes and solutions for plant problems',
    promptTemplateJa: '''
{plant}を育てていますが、以下の症状が出ています：

【症状】
{symptoms}

【栽培環境】
- 場所：{location}
- 農法：{farming_method}
- 最近の天候：{weather}

考えられる原因と、自然な方法での対策を教えてください。
''',
    promptTemplateEn: '''
I'm growing {plant} and seeing these symptoms:

【Symptoms】
{symptoms}

【Growing Environment】
- Location: {location}
- Method: {farming_method}
- Recent weather: {weather}

Please tell me possible causes and natural solutions.
''',
    exampleInputJa: '葉が黄色くなってきた、下の葉から枯れる',
    exampleInputEn: 'Leaves turning yellow, dying from bottom up',
    exampleOutputJa: '''
【考えられる原因】

1. 窒素欠乏（可能性：高）
   - 下葉から黄化は典型的な窒素不足
   - 対策：油かす、米ぬかボカシを追肥

2. 水のやりすぎ（可能性：中）
   - 根腐れで養分吸収低下
   - 対策：土の表面が乾いてから水やり

3. 老化した下葉の自然現象
   - 上部が元気なら正常
   - 対策：枯れた葉を除去して風通し確保

【観察ポイント】
- 新しい葉は正常か？
- 土を掘ると根は白いか？
- 茎はしっかりしているか？
''',
    exampleOutputEn: '''
【Possible Causes】

1. Nitrogen deficiency (high probability)
   - Yellow from bottom is typical N shortage
   - Solution: Add oil cake, rice bran bokashi

2. Overwatering (medium probability)
   - Root rot reduces nutrient uptake
   - Solution: Water when surface is dry

3. Natural aging of lower leaves
   - Normal if top growth is healthy
   - Solution: Remove dead leaves for airflow

【Observation Points】
- Are new leaves normal?
- Are roots white when you dig?
- Is the stem firm?
''',
    placeholders: ['plant', 'symptoms', 'location', 'farming_method', 'weather'],
  );
}

/// 病害虫リサーチプロンプト集
class PestDiseaseResearchPrompts {
  static const identify = ResearchPrompt(
    id: 'pest_identify',
    category: ResearchCategory.pestDisease,
    titleJa: '病害虫を特定する',
    titleEn: 'Identify Pest/Disease',
    descriptionJa: '症状から病害虫を特定し、自然な対策を調べます',
    descriptionEn: 'Identify pest/disease from symptoms and find natural solutions',
    promptTemplateJa: '''
{plant}に以下の症状が出ています：

【観察した症状】
{symptoms}

【発見した虫・病斑の特徴】
{pest_description}

以下を教えてください：
1. 考えられる病害虫名
2. 被害の進行パターン
3. 自然農法での対策方法
4. 予防方法
5. 農薬を使わない駆除方法
''',
    promptTemplateEn: '''
My {plant} is showing these symptoms:

【Observed Symptoms】
{symptoms}

【Pest/Disease Characteristics】
{pest_description}

Please tell me:
1. Likely pest/disease name
2. How damage progresses
3. Natural farming solutions
4. Prevention methods
5. Pesticide-free control methods
''',
    exampleInputJa: '葉に白い粉状のものが付いている',
    exampleInputEn: 'White powdery substance on leaves',
    exampleOutputJa: '''
【診断：うどんこ病】

1. 病名：うどんこ病（糸状菌）

2. 進行パターン：
   - 最初は小さな白い斑点
   - 徐々に葉全体に広がる
   - 光合成阻害で生育不良に

3. 自然農法での対策：
   - 酢水スプレー（酢1:水10）
   - 重曹スプレー（重曹小さじ1/L）
   - 牛乳スプレー（牛乳1:水1）

4. 予防方法：
   - 株間を広く取る（風通し）
   - 窒素過多を避ける
   - 朝の水やり（夜露を避ける）

5. 駆除方法：
   - 感染した葉は除去して処分
   - 週1回予防スプレー
   - ニームオイルも効果的
''',
    exampleOutputEn: '''
【Diagnosis: Powdery Mildew】

1. Disease: Powdery mildew (fungal)

2. Progression:
   - Starts as small white spots
   - Spreads across entire leaf
   - Reduces photosynthesis and growth

3. Natural solutions:
   - Vinegar spray (1:10 with water)
   - Baking soda spray (1 tsp/L)
   - Milk spray (1:1 with water)

4. Prevention:
   - Wide spacing (airflow)
   - Avoid excess nitrogen
   - Morning watering (avoid dew)

5. Control methods:
   - Remove infected leaves
   - Weekly preventive spray
   - Neem oil also effective
''',
    placeholders: ['plant', 'symptoms', 'pest_description'],
  );
}

/// コンパニオンプランツリサーチ
class CompanionResearchPrompts {
  static const findCompanions = ResearchPrompt(
    id: 'companion_find',
    category: ResearchCategory.companion,
    titleJa: 'コンパニオンプランツを調べる',
    titleEn: 'Find Companion Plants',
    descriptionJa: '相性の良い植物の組み合わせを調べます',
    descriptionEn: 'Find beneficial plant combinations',
    promptTemplateJa: '''
{plant}を育てる予定です。

以下について教えてください：

1. 相性の良いコンパニオンプランツ（理由も）
2. 一緒に植えてはいけない植物（理由も）
3. 自然農法でのおすすめの植え方（混植パターン）
4. 各コンパニオンの効果
   - 病気予防
   - 害虫忌避
   - 生育促進
   - 土壌改良
''',
    promptTemplateEn: '''
I plan to grow {plant}.

Please tell me:

1. Good companion plants (with reasons)
2. Plants to avoid (with reasons)
3. Recommended planting patterns for natural farming
4. Effects of each companion:
   - Disease prevention
   - Pest repellent
   - Growth promotion
   - Soil improvement
''',
    exampleInputJa: 'トマト',
    exampleInputEn: 'Tomato',
    exampleOutputJa: '''
【トマトのコンパニオンプランツ】

🟢 相性の良い植物：

1. バジル
   - 効果：アブラムシ忌避、風味向上
   - 植え方：トマトの株元に

2. ネギ・ニラ
   - 効果：土壌病害予防（連作障害軽減）
   - 植え方：畝の端に列植え

3. マリーゴールド
   - 効果：センチュウ対策、アブラムシ忌避
   - 植え方：畝の周囲に

4. パセリ
   - 効果：ハダニ忌避
   - 植え方：株間に

🔴 避けるべき植物：

1. ジャガイモ
   - 理由：疫病の相互感染

2. フェンネル
   - 理由：生育阻害物質を出す

3. トウモロコシ
   - 理由：アワノメイガ被害増加

【混植パターン例】
```
マリーゴールド ← トマト → バジル
     ↓           ↓         ↓
   ニラ      パセリ    ニラ
```
''',
    exampleOutputEn: '''
【Tomato Companion Plants】

🟢 Good companions:

1. Basil
   - Effect: Repels aphids, improves flavor
   - Placement: At tomato base

2. Alliums (green onion, chives)
   - Effect: Prevents soil diseases
   - Placement: Row at bed edge

3. Marigold
   - Effect: Nematode control, repels aphids
   - Placement: Around the bed

4. Parsley
   - Effect: Repels spider mites
   - Placement: Between plants

🔴 Plants to avoid:

1. Potato
   - Reason: Cross-infection of blight

2. Fennel
   - Reason: Growth-inhibiting compounds

3. Corn
   - Reason: Increases corn borer damage

【Planting Pattern】
```
Marigold ← Tomato → Basil
    ↓         ↓        ↓
  Chives   Parsley  Chives
```
''',
    placeholders: ['plant'],
  );
}

/// 収穫時期リサーチ
class HarvestResearchPrompts {
  static const timing = ResearchPrompt(
    id: 'harvest_timing',
    category: ResearchCategory.harvest,
    titleJa: '収穫のベストタイミング',
    titleEn: 'Best Harvest Timing',
    descriptionJa: '最適な収穫時期と見極め方を調べます',
    descriptionEn: 'Find optimal harvest timing and indicators',
    promptTemplateJa: '''
{plant}の収穫について教えてください：

1. 収穫適期のサイン（見た目、触感、色など）
2. 早採りと完熟、それぞれのメリット
3. 収穫の時間帯（朝/夕、天候など）
4. 収穫の方法（手摘み、ハサミなど）
5. 収穫後の保存方法
6. 種採り用に残す場合のポイント
''',
    promptTemplateEn: '''
Please tell me about harvesting {plant}:

1. Signs of harvest readiness (appearance, feel, color)
2. Benefits of early vs. full maturity harvest
3. Best time of day (morning/evening, weather)
4. Harvest method (hand-pick, scissors, etc.)
5. Post-harvest storage
6. Tips for saving seeds
''',
    exampleInputJa: 'キュウリ',
    exampleInputEn: 'Cucumber',
    exampleOutputJa: '''
【キュウリの収穫ガイド】

1. 収穫適期のサイン：
   - 長さ20-25cm（品種による）
   - イボイボが鋭く立っている
   - 濃い緑色で艶がある
   - 持つとずっしり重い

2. 早採り vs 完熟：
   早採り（18-20cm）：
   ✓ 皮が薄く歯切れ良い
   ✓ 種が少ない
   ✓ 株の負担軽減→長期収穫

   完熟（25cm以上）：
   ✓ 種採り用に適す
   ✗ 種が大きく食感低下
   ✗ 株が疲れやすい

3. 収穫の時間帯：
   - ベスト：早朝（水分・栄養豊富）
   - 避ける：炎天下（しおれやすい）

4. 収穫方法：
   - ハサミでヘタを切る
   - ひねって取るとツルを傷める

5. 保存方法：
   - 新聞紙で包んで野菜室
   - 立てて保存（横置き×）
   - 3-4日で食べきる

6. 種採り：
   - 完熟させ黄色くなるまで放置
   - 種を水洗いして乾燥
   - 来年用に冷暗所保存
''',
    exampleOutputEn: '''
【Cucumber Harvest Guide】

1. Readiness signs:
   - Length 20-25cm (varies by variety)
   - Sharp, prominent spines
   - Deep green with sheen
   - Heavy when held

2. Early vs. mature:
   Early (18-20cm):
   ✓ Thin skin, crisp texture
   ✓ Few seeds
   ✓ Less plant stress → longer harvest

   Mature (25cm+):
   ✓ Good for seed saving
   ✗ Large seeds, poor texture
   ✗ Exhausts the plant

3. Best time:
   - Best: Early morning (max moisture)
   - Avoid: Hot midday (wilts quickly)

4. Method:
   - Cut stem with scissors
   - Don't twist (damages vine)

5. Storage:
   - Wrap in paper, refrigerate
   - Store upright (not flat)
   - Use within 3-4 days

6. Seed saving:
   - Let fruit mature until yellow
   - Wash seeds and dry
   - Store in cool dark place
''',
    placeholders: ['plant'],
  );
}

/// 全プロンプトリスト
class AIResearchPrompts {
  static const List<ResearchPrompt> all = [
    SoilResearchPrompts.basic,
    SoilResearchPrompts.detailed,
    SoilResearchPrompts.comprehensive,
    SoilResearchPrompts.quickDiagnosis,
    ClimateResearchPrompts.growingCalendar,
    ClimateResearchPrompts.microclimate,
    ClimateResearchPrompts.comprehensive,
    PlantCareResearchPrompts.naturalFarming,
    PlantCareResearchPrompts.troubleshooting,
    PestDiseaseResearchPrompts.identify,
    CompanionResearchPrompts.findCompanions,
    HarvestResearchPrompts.timing,
  ];

  /// カテゴリ別にグループ化
  static Map<ResearchCategory, List<ResearchPrompt>> get byCategory {
    final map = <ResearchCategory, List<ResearchPrompt>>{};
    for (final prompt in all) {
      map.putIfAbsent(prompt.category, () => []).add(prompt);
    }
    return map;
  }
}
