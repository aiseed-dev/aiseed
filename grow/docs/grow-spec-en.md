# Grow - Natural Farming Observation Journal

**Specification Document**

Created: January 9, 2025

---

## 0. Internationalization

### 0.1 Supported Languages

| Language | Status | Notes |
|----------|--------|-------|
| Japanese | Primary | UI and content |
| English | Supported | UI, spec, farming methods, soil classification |

### 0.2 Why This App Matters Globally

Japanese natural farming methods (Fukuoka, Okada, Shizen Saibai, Shizen-no, Carbon Cycling) are gaining worldwide attention, but no app exists to systematically record and compare these approaches. This app brings Japanese agricultural wisdom to the world.

| Japanese Wisdom | Global Recognition |
|-----------------|-------------------|
| Fukuoka Natural Farming | Famous as "The One-Straw Revolution" |
| Okada Natural Farming | Expanding as MOA Natural Farming |
| Natural Cultivation | A form of Regenerative Agriculture |
| Carbon Cycling Agriculture | Recognized for Soil Carbon Sequestration |

---

## 1. Concept

### 1.1 Background

Existing cultivation recording apps are designed for conventional farming, focusing on recording fertilizer and pesticide application amounts and timing. In natural farming—especially Masanobu Fukuoka's approach—what matters is not "what you did" but "what is happening." Existing apps cannot support this.

The difficulty of Fukuoka's natural farming lies not in following a cultivation manual, but in understanding plant ecology, soil biology, and weather.

### 1.2 Purpose

To provide a tool for accumulating data about your own field and discovering farming methods optimized for that specific location. By combining weather data with observation records, we aim to accelerate the accumulation of experience and approach true natural farming.

### 1.3 Positioning: A Tool for Collaboration

This app serves as a shared foundation for people practicing natural farming to collaborate.

| Form of Collaboration | Description |
|----------------------|-------------|
| Knowledge Sharing | Learn regional patterns from published observation records |
| Data Accumulation | Individual records combine to generate scientific insights into natural farming |
| AI Training Contribution | Use public data to develop AI models specialized for natural farming |
| Bridging Technology and Farming | Provide tools that natural farming practitioners need through IT |

In natural farming, soil and weather data are crucial. Recording and analyzing them enables reproducibility, contributing to the advancement of natural farming.

### 1.4 Design Philosophy

| Principle | Description |
|-----------|-------------|
| Your Data is Yours | No service termination risk; you manage where everything is |
| Distributed Management | No single master; utilize multiple storage destinations |
| User Choice | Public/private, coordinate handling, thermometers—user decides |
| Specialized | Not generalized; focused on natural farming observation records |
| Minimal | Add only what's needed, when it's needed |
| Public Priority | Publish what can be published; maximize free storage |

---

## 2. System Architecture

### 2.1 Distributed Management Approach

When handling photos and videos, maintaining a "single master" is impractical. Photos taken on smartphones are automatically backed up to Google Photos or iCloud. This app adopts a distributed management approach, managing "where everything is" through metadata.

### 2.2 Storage Priority

Cloudflare Pages takes priority. Public content is free with unlimited capacity, so making vegetable photos public allows it to serve as the primary storage.

| Priority | Storage | Capacity | Use |
|----------|---------|----------|-----|
| 1 | Cloudflare Pages | Unlimited | Public photos (vegetables) → Primary |
| 2 | Cloudflare R2 | 10GB free | Private photos (people, landscapes) |
| 3 | Local (SQLite/IndexedDB) | Device-dependent | Offline viewing cache |
| 4 | Google Photos, etc. | 15GB shared | Optional backup for original data |

### 2.3 Metadata Management

Metadata is stored in D1, managing where photos are located.

| Field | Content |
|-------|---------|
| Photo ID | Unique identifier |
| Storage Location | pages / r2 / local / google, etc. |
| URL or Path | Actual file location |
| Observation Notes | Free-form description |
| Climate Data | Weather, temperature, humidity, etc. |
| Soil Observation | Grass, color/smell, texture, etc. |

### 2.4 Operational Flow

```
Photo Capture
  ↓
Import in App → EXIF Processing → To Pages (default)
  ↓
Want to keep private → To R2
  ↓
Want to keep original → Optional backup to Google Photos, etc.
```

### 2.5 Authentication

Using Cloudflare Access + GitHub/Google/Apple OAuth. Authentication required for D1/R2 access (both read and write) via Workers. Pages remains public.

---

## 3. Photo Management

### 3.1 Public/Private Determination

| Photo Content | Storage | Reason |
|---------------|---------|--------|
| Vegetables only | Pages (public) | No problem with EXIF removed |
| People/landscapes | R2 (private) | Location identifiable from image itself |

Note: When starting sales, it's often better to publicize the location. Publish what can be published. Use free services by understanding that "free because it's public."

### 3.2 Coordinate (GPS) Handling

User-selectable. If you have only one small field, coordinates may be meaningless. For detailed management, coordinates can be used to identify which plot in which field.

| Option | Description | Use Case |
|--------|-------------|----------|
| Delete | Completely remove coordinates from EXIF | Privacy-focused |
| Keep (private) | Retain coordinates as management data | Field plot management |
| Blur | Offset by hundreds of meters to kilometers | Want to convey regional brand |
| Public | Publish coordinates as-is | Want to publicize location as producer |

### 3.3 Gradual Transition to Producer

Start by saving privately and securely. When beginning sales, move necessary photos from R2 to Pages. Becoming a producer means you can't always prioritize privacy. The decision to publicize your face and field to gain trust is made by the user.

---

## 4. Recording Items

### 4.1 Basic Items

| Item | Content | Acquisition Method |
|------|---------|-------------------|
| Photo | Image of observation target | Camera capture |
| Date/Time | Capture date and time | Auto-extracted from EXIF |
| Coordinates | Capture location | From EXIF (selectable) |
| Observation Notes | Free-form description | Manual input |

### 4.2 Climate Data

Unlike conventional farming that controls the environment with fertilizers and pesticides, natural farming depends on soil and weather, requiring weather data. Utilizing Japan Meteorological Agency and ECMWF numerical data and ERA5.

| Item | Content | Acquisition |
|------|---------|-------------|
| Weather | Sunny, cloudy, rainy, etc. | API/manual |
| Temperature | Outdoor or greenhouse temperature | API/sensor/manual |
| Humidity | Relative humidity | API/sensor/manual |
| Precipitation | mm | API/manual |

### 4.3 Thermometer Integration

Greenhouse cultivation requires integration with digital thermometers. Support multiple methods without being tied to specific products.

| Method | Description |
|--------|-------------|
| Manual Input | Record from looking at thermometer |
| Bluetooth Thermometer | SwitchBot, Inkbird, Xiaomi, etc. |
| Wi-Fi Sensor | Constant recording, import later |
| CSV Import | Data import from other systems |

### 4.4 Soil Observation

Soil is judged from observation rather than measurement. In natural farming, sensory information that's difficult to quantify is important; daily observation records are fundamental. Specialized analysis is used only when questions arise.

| Category | Observation Content |
|----------|---------------------|
| Grass | What's growing (horsetail → acidic, etc., as indicators) |
| Color/Smell | Blackish, earthy scent, rotting smell, etc. |
| Texture | Fluffy, hard, clayey, sandy |
| Living Things | Presence of earthworms, pill bugs, mycelium |
| Water | Drainage, tendency to pool |

### 4.5 Professional Analysis

Request soil analysis from specialized institutions only when needed; link results to records. Since this isn't done frequently, storing as attachments (PDF/photos) is sufficient.

---

## 5. Differences from General Cultivation Records

| General Cultivation Records | This App (for Natural Farming) |
|-----------------------------|-------------------------------|
| When/how much fertilizer | What's the soil condition |
| How many times pesticide sprayed | What insects are present |
| Amount of watering | How grass is growing |
| Yield management | Plant-to-plant relationships |
| Recording human actions | Observing natural changes |
| Do everything preventively | Observe and do only what's needed |

In conventional farming, doing everything preventively makes it unclear what was truly necessary. In natural farming, observing and deciding makes cause-and-effect visible.

---

## 6. Data Utilization

### 6.1 Integration with AIseed Spark

The cultivation recording app operates independently; only those who wish can export metadata to AIseed Spark. Spark performs analysis to discover strengths from observation patterns.

### 6.2 Use for AI Training

Public data can be used for AI training with permission. Since you control your own data, you choose whether to provide it for training.

| Level | Method | Use |
|-------|--------|-----|
| Personal | Include in prompts | Advice based on your records |
| Community | RAG | Search similar cases from multiple people's records |
| Full-scale | Fine-tuning | Natural farming specialized model |

### 6.3 Use for Sales Websites

Public photos on Cloudflare Pages can be used directly as materials for sales websites. Growth process photos generate credibility and story, leading to sales where the producer's face is visible.

---

## 7. Comparison with Existing Services

| Item | Existing Services | This App |
|------|-------------------|----------|
| Data Ownership | Platform | Yourself |
| Service Termination Risk | Yes | No |
| Offline | No | Yes |
| Public/Private | Platform-dependent | User controls per photo |
| Privacy | Depends on terms | EXIF deletion, people photos private |
| AI Training Use | Depends on terms | You decide |

---

## 8. Free Tier

| Service | Free Tier | Notes |
|---------|-----------|-------|
| Cloudflare Pages | Unlimited | Public content → Primary |
| Cloudflare R2 | 10GB/month | Only private photos, should fit |
| Cloudflare D1 | 5GB | Sufficient for metadata |
| Cloudflare Workers | 100K requests/day | Sufficient for personal use |
| Cloudflare Access | 50 users | 1 user for personal |
| Google Photos | 15GB (shared) | Optional backup |

By publishing what can be published, you can use unlimited capacity for free. Understand and utilize the mechanism where "free because it's viewable."

---

## 9. Technical Stack

| Area | Technology |
|------|------------|
| Mobile | Flutter (iOS / Android) ← Primary platforms |
| Backend | Cloudflare Workers |
| Database | Cloudflare D1 (SQLite) |
| Storage | Cloudflare Pages (public) / R2 (private) |
| Authentication | Cloudflare Access + GitHub/Google/Apple OAuth |
| Local Storage | SQLite (mobile) / IndexedDB (web) |
| Internationalization | Flutter intl / arb files |

### 9.1 Platform Priority

| Platform | Priority | Reason |
|----------|----------|--------|
| iOS | High | Essential for camera/photo capture |
| Android | High | Essential for camera/photo capture |
| Web | Low | Future consideration for viewing |

### 9.2 Farming Method Classification (Implemented)

| Code | Japanese | English |
|------|----------|---------|
| natural_fukuoka | 自然農法（福岡正信） | Fukuoka Natural Farming |
| natural_okada | 自然農法（岡田茂吉） | MOA Natural Farming |
| natural_cultivation | 自然栽培 | Natural Cultivation |
| natural_farming | 自然農 | Shizen-no (Natural Farming) |
| carbon_cycling | 炭素循環農法 | Carbon Cycling Agriculture |
| organic | 一般有機農業 | Organic Farming |
| conventional | 慣行農業 | Conventional Farming |

### 9.3 Soil Classification (WRB 32 Classes - Implemented)

Adopts the international standard WRB (World Reference Base for Soil Resources 2022). Japanese names follow Japanese Agricultural Soil Classification.

Common soils in Japan (18 types):
- Andosols (黒ボク土) ← Japan's representative soil, from volcanic ash
- Fluvisols (沖積土) ← Most common in Japanese farmland
- Cambisols (褐色森林土)
- Gleysols (グライ土)
- And 14 others

---

## 10. Future Extensions

The following features are under consideration:

- Soil temperature sensor support
- Multi-device synchronization
- Community data sharing
- Weather forecast integration
- AI-powered observation suggestions

---

## 11. Why This App Can Only Come from Japan

This app embodies knowledge that could only originate from Japan:

1. **Japanese Natural Farming Origins**: Fukuoka, Okada, and other natural farming philosophies were developed in Japan
2. **Deep Soil Knowledge**: Understanding of Japanese soil classification and its correspondence to international WRB standards
3. **Observation Philosophy**: "What is happening" vs "what you did" reflects Japanese agricultural thinking
4. **Holistic Understanding**: Connection between soil biology, plant ecology, and weather is core to Japanese natural farming
5. **Collaboration Culture**: The spirit of "helping each other" (協力し合う) in agriculture

Japan has the unique position to bridge traditional natural farming wisdom with modern technology and share it with the world.
