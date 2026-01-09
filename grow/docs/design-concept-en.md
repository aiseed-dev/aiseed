# Grow Design Concept

## 1. Design Philosophy

### 1.1 Core Concept: Design that Helps You "See"

```
The Essence of Natural Farming:
  Observe "what is happening" rather than "what was done"

The Role of Design:
  Don't interfere with observation, help with recording, prompt awareness
```

### 1.2 Design Principles

| Principle | Description | Example |
|-----------|-------------|---------|
| **Quietness** | Don't disturb observation in nature | Subtle colors, minimal animation |
| **Transparency** | Soil, plants, sky are the main actors; UI is background | Large photos, semi-transparent UI |
| **Texture** | Express the feeling of touching soil digitally | Soft rounded corners, natural shadows |
| **White Space** | Breathing room, not cramped | Sufficient padding, line spacing |
| **Flow of Time** | Feel growth and change | Timeline display, seasonal feel |

---

## 2. Color Palette

### 2.1 Primary Colors: Earth and Green

```
Earth - Main Color
┌─────────────────────────────────────┐
│  #3E2723  Dark Soil                 │  ← Text, important elements
│  #5D4037  Rich Soil                 │  ← Headers, accents
│  #8D6E63  Dry Soil                  │  ← Secondary
│  #D7CCC8  Light Soil                │  ← Backgrounds, borders
└─────────────────────────────────────┘

Green - Accent Color
┌─────────────────────────────────────┐
│  #2E7D32  Deep Green                │  ← Success, growth
│  #4CAF50  Life Green                │  ← Buttons, emphasis
│  #81C784  Young Leaf                │  ← Hover, selection
│  #C8E6C9  Pale Green                │  ← Background accent
└─────────────────────────────────────┘
```

### 2.2 Semantic Colors

```
Status Colors
┌─────────────────────────────────────┐
│  #FF8F00  Warning (sunburn, dry)    │  Amber
│  #D32F2F  Problem (disease, pests)  │  Red
│  #1976D2  Water (watering, rain)    │  Blue
│  #7B1FA2  Harvest                   │  Purple
└─────────────────────────────────────┘
```

### 2.3 Dark Mode

```
For use in fields at night or early morning
┌─────────────────────────────────────┐
│  #121212  Background                │
│  #1E1E1E  Card                      │
│  #2D2D2D  Input                     │
│  #E0E0E0  Text                      │
│  #81C784  Accent                    │  ← Maintain green
└─────────────────────────────────────┘
```

---

## 3. Typography

### 3.1 Font Selection

```
Japanese:
  Noto Sans JP (body)
  - Natural and readable, Google Font
  - Weight: 400 (body), 500 (emphasis), 700 (headings)

English:
  Noto Sans (body)
  - Harmonizes with Japanese, multilingual support

Numbers/Data:
  Roboto Mono
  - Temperature, dates, statistics
```

### 3.2 Font Sizes

```
Hierarchy
┌─────────────────────────────────────┐
│  Heading 1   24sp / 32sp (tablet)   │  Plant name, screen title
│  Heading 2   20sp / 24sp            │  Section
│  Body        16sp / 18sp            │  Observation notes
│  Secondary   14sp / 16sp            │  Dates, labels
│  Caption     12sp / 14sp            │  Hints, notes
└─────────────────────────────────────┘
```

---

## 4. Component Design

### 4.1 Card (Observation Record)

```
┌────────────────────────────────────────┐
│ ┌──────────────────────────────────┐  │
│ │                                  │  │
│ │         📷 Photo Area            │  │  ← 16:9 or 4:3
│ │         (Tap to enlarge)         │  │
│ │                                  │  │
│ └──────────────────────────────────┘  │
│                                        │
│  2024.01.09  09:30   ☀️ 12°C          │  ← Date/time, weather, temp
│                                        │
│  The leaves are turning yellow.        │  ← Observation note
│  Drainage might be poor.               │
│                                        │
│  ┌────────┐ ┌────────┐               │
│  │ 💧 Water│ │ 🌱 Growth│              │  ← Tags (auto-extracted)
│  └────────┘ └────────┘               │
│                                        │
└────────────────────────────────────────┘

Design Specs:
- Border radius: 16dp
- Shadow: elevation 2dp (light) / 0dp (dark)
- Padding: 16dp
- Photo to text spacing: 12dp
```

### 4.2 Plant Card (List)

```
┌────────────────────────────────────────┐
│ ┌────────┐                            │
│ │  📷    │  Cherry Tomato             │  ← Plant name
│ │ Latest │  Aiko (variety)            │  ← Variety
│ │ Photo  │                            │
│ └────────┘  🌱 Day 45                  │  ← Days elapsed
│             📍 Balcony                 │  ← Location
│             🌿 Natural Cultivation     │  ← Farming method
│                                        │
│  ━━━━━━━━━━━━━━━━━━ 60%              │  ← Growth progress (optional)
│                                        │
└────────────────────────────────────────┘
```

### 4.3 Capture Button (FAB)

```
      ╭─────────╮
     ╱           ╲
    │    📷      │    ← Fixed at bottom center
    │            │    ← Size: 64dp
     ╲           ╱    ← Color: Life Green (#4CAF50)
      ╰─────────╯    ← Shadow: elevation 6dp

On tap:
  - Light haptic feedback
  - Launch camera
```

### 4.4 Input Form

```
Observation Note Input
┌────────────────────────────────────────┐
│  What is happening?                    │  ← Placeholder
│                                        │
│                                        │
│                                        │
│                                        │
└────────────────────────────────────────┘
  500 characters remaining                 ← Counter

Design Specs:
- Border radius: 12dp
- Border: 1dp, Light Soil
- On focus: 2dp, Life Green
- Padding: 16dp
- Min height: 120dp (multi-line expected)
```

---

## 5. Screen Structure

### 5.1 Home Screen

```
┌────────────────────────────────────────┐
│  ☰  Grow              🔔  👤          │  ← Header
├────────────────────────────────────────┤
│                                        │
│  Good morning                          │  ← Greeting (changes by time)
│  Let's enjoy observing today           │
│                                        │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                        │
│  🌱 Your Plants                        │  ← Section
│                                        │
│  ┌──────────┐ ┌──────────┐           │
│  │  Tomato  │ │  Basil   │           │  ← Plant cards (horizontal scroll)
│  │  Day 45  │ │  Day 12  │           │
│  └──────────┘ └──────────┘           │
│                                        │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                        │
│  📝 Recent Observations                │  ← Section
│                                        │
│  ┌────────────────────────────────┐  │
│  │ [Observation Card]              │  │
│  └────────────────────────────────┘  │
│                                        │
│                                        │
│                                        │
├────────────────────────────────────────┤
│              ┌────┐                   │
│   🏠    🌿   │ 📷 │   📊    ⚙️        │  ← Navigation
│              └────┘                   │
└────────────────────────────────────────┘
```

### 5.2 Record Observation Screen

```
┌────────────────────────────────────────┐
│  ←  Record Observation                 │  ← Header
├────────────────────────────────────────┤
│                                        │
│  ┌──────────────────────────────────┐│
│  │                                  ││
│  │       📷 Tap to capture          ││  ← Photo area
│  │       or select                  ││
│  │                                  ││
│  └──────────────────────────────────┘│
│                                        │
│  ┌──────────────────────────────────┐│
│  │ What is happening?               ││  ← Note input
│  │                                  ││
│  └──────────────────────────────────┘│
│                                        │
│  🌤️ Weather     ┌─────────────────┐  │
│                │ ☀️ ⛅ ☁️ 🌧️ ❄️   │  │  ← Weather selection
│                └─────────────────┘  │
│                                        │
│  🌡️ Temperature [ 12 ] °C            │  ← Temperature input
│                                        │
│  💧 Watered     ○ Yes  ● No          │  ← Toggle
│                                        │
│  🌿 Soil        ▼ Enter details       │  ← Expandable section
│                                        │
│                                        │
│  ┌──────────────────────────────────┐│
│  │           Record                 ││  ← Save button
│  └──────────────────────────────────┘│
│                                        │
└────────────────────────────────────────┘
```

### 5.3 Plant Detail Screen

```
┌────────────────────────────────────────┐
│  ←  Cherry Tomato              ⋮      │
├────────────────────────────────────────┤
│  ┌──────────────────────────────────┐│
│  │                                  ││
│  │         Latest Photo             ││  ← Hero image
│  │                                  ││
│  └──────────────────────────────────┘│
│                                        │
│  ┌────────┬────────┬────────┐        │
│  │ Day 45 │  23    │   3    │        │  ← Stats
│  │Growing │ Obs.   │ Harvest│        │
│  └────────┴────────┴────────┘        │
│                                        │
│  📋 Basic Info                         │
│  ├─ Variety: Aiko                     │
│  ├─ Location: Balcony                 │
│  ├─ Method: Natural Cultivation       │
│  └─ Soil: Andosols                    │
│                                        │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                        │
│  📅 Observation Timeline               │
│                                        │
│  ● 1/9  Leaves turning yellow         │
│  │                                     │
│  ● 1/7  First flower bloomed!         │
│  │                                     │
│  ● 1/5  Added support stake           │
│  │                                     │
│  ○ ...                                │
│                                        │
│              ┌────┐                   │
│              │ 📷 │                   │  ← Add observation FAB
│              └────┘                   │
└────────────────────────────────────────┘
```

---

## 6. Icons & Illustrations

### 6.1 Icon Style

```
Style: Rounded (soft lines)
Weight: 2dp
Size: 24dp (standard), 20dp (small), 32dp (large)

Icon Sets:
- Material Icons Rounded (base)
- Custom icons (farming methods, soil types)
```

### 6.2 Custom Icons

```
Farming Method Icons
┌─────────────────────────────────────┐
│  🌾 Fukuoka Natural    Rice motif   │
│  🌸 MOA Natural        Flower motif │
│  🌱 Natural Cultivation Sprout      │
│  🌿 Shizen-no          Grass motif  │
│  ♻️ Carbon Cycling     Cycle motif  │
│  🍃 Organic            Leaf motif   │
│  🚜 Conventional       Tractor      │
└─────────────────────────────────────┘

Soil Icons (Simplified)
┌─────────────────────────────────────┐
│  ⬛ Andosols (Black volcanic)       │
│  🟫 Cambisols (Brown forest)        │
│  🔵 Gleysols (Waterlogged)          │
│  🟡 Fluvisols (Alluvial)            │
└─────────────────────────────────────┘
```

---

## 7. Animation & Interaction

### 7.1 Principles

```
- Subtle: Don't disturb nature observation
- Meaningful: Communicate state changes
- Fast: Within 200-300ms
```

### 7.2 Specific Examples

| Action | Animation | Duration |
|--------|-----------|----------|
| Card appearance | Fade in + slide up | 200ms |
| Button tap | Ripple + scale | 150ms |
| Screen transition | Slide (iOS) / Fade (Android) | 300ms |
| Photo zoom | Hero animation | 300ms |
| Success notification | Slide in from top | 250ms |
| Pull to refresh | Plant growing animation | Custom |

---

## 8. Responsive Design

### 8.1 Breakpoints

```
Phone (portrait): < 600dp
Phone (landscape): 600-840dp
Tablet: 840-1200dp
```

### 8.2 Layout Adjustments

```
Phone:
  - Single column
  - Bottom navigation
  - FAB at bottom center

Tablet:
  - Two columns (list + detail)
  - Side navigation
  - FAB at bottom right
```

---

## 9. Accessibility

### 9.1 Requirements

```
- Contrast ratio: 4.5:1+ (body text), 3:1+ (large text)
- Tap target: 48dp × 48dp minimum
- Font size: Follow system settings
- Screen reader: Labels on all elements
- Color blindness: Don't convey info by color alone
```

### 9.2 Considerations

```
- Field use: High contrast for bright outdoor visibility
- Dirty hands: Large tap areas
- Elderly users: Scalable UI
```

---

## 10. Brand Identity

### 10.1 Logo Concept

```
      🌱
     Grow

Simple sprout icon + Grow text
- Symbolizes growth
- Expresses natural power
- Minimal elements
```

### 10.2 Tone & Manner

```
- Warm: No cold technology feel
- Humble: Respect for nature
- Practical: Not over-decorated
- Trustworthy: Caring attitude toward data
```

### 10.3 Copywriting

```
Good examples:
  "Let's enjoy observing today"
  "What is happening?"
  "Record"

Avoid:
  "Record now!" (pushy)
  "Enter data" (clerical)
  "Registration complete!" (system-like)
```

---

## 11. Implementation Priority

### Phase 1: MVP
- Home screen
- Plant registration
- Observation record (photo + note)
- Basic colors & typography

### Phase 2: Feature Expansion
- Weather/temperature integration
- Soil observation form
- Timeline display
- Dark mode

### Phase 3: Polish
- Custom icons
- Animations
- Tablet support
- Onboarding
