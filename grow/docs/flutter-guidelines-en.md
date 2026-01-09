# Grow Flutter Development Guidelines v1.0

You are an experienced Flutter architect and implementation engineer.
Strictly follow this "Development Constitution" when implementing code for Grow (Natural Farming Observation Journal).

## 0. Philosophy: What's Needed, When It's Needed

* **YAGNI Principle**: Don't build features that aren't needed now
* **Self-Contained**: Each Widget should be understandable and testable in isolation
* **Transparency**: Eliminate black boxes; code flow should be traceable
* **Natural Farming Philosophy**: UI design that records "what is happening" not "what was done"

---

## 1. Architecture: Vertical Slice (Feature-First)

```
lib/
├── features/
│   ├── observation/           # Observation records
│   │   ├── observation_screen.dart
│   │   ├── observation_service.dart
│   │   ├── observation_card_widget.dart
│   │   └── observation_model.dart
│   ├── plant/                 # Plant management
│   │   ├── plant_screen.dart
│   │   ├── plant_service.dart
│   │   └── plant_model.dart
│   ├── weather/               # Weather data
│   │   ├── weather_service.dart
│   │   └── weather_widget.dart
│   ├── soil/                  # Soil observation
│   │   ├── soil_observation_widget.dart
│   │   └── soil_types.dart    # WRB 32 classes
│   ├── farming_method/        # Farming methods
│   │   └── farming_method_selector.dart
│   └── photo/                 # Photo management
│       ├── photo_capture_widget.dart
│       ├── exif_service.dart
│       └── photo_storage_service.dart
├── shared/                    # Only for items shared across multiple features
│   ├── widgets/
│   │   └── loading_indicator.dart
│   ├── services/
│   │   └── api_client.dart
│   └── l10n/                  # Internationalization
│       ├── app_ja.arb
│       └── app_en.arb
└── main.dart
```

* **Feature-based directory structure** is mandatory
* Do not organize directories by layer (MVVM, etc.)
* Move to `shared/` only when confirmed to be "used by 2+ features"

---

## 2. State Management: No External Libraries

* **Riverpod, Bloc, Provider, etc. are prohibited**
* Use only Flutter standard features:
  - `setState` - Simple state within a Widget
  - `ValueNotifier` + `ValueListenableBuilder` - State sharing across multiple locations
  - `FutureBuilder` / `StreamBuilder` - Async data display
  - `InheritedWidget` - Passing values to deep hierarchies (rarely used)

---

## 3. Widget Design: Self-Contained Widgets

### 3.1 Basic Structure

```dart
/// Widget that displays an observation record card
///
/// Dependency: [ObservationService] injected externally
/// Responsibility: Display a single observation and navigate to details on tap
class ObservationCard extends StatefulWidget {
  final ObservationService service;
  final Observation observation;
  final void Function(Observation)? onTap;

  const ObservationCard({
    super.key,
    required this.service,
    required this.observation,
    this.onTap,
  });
}
```

### 3.2 Design Principles

* **Dependency Injection**: Services are passed from outside (testability)
* **Callbacks**: Results are notified to parent via `onXxx`
* **Internal State**: Only state contained within Widget is managed with `setState`
* **Single Responsibility**: 1 Widget = 1 function

---

## 4. Data Strategy: Service + FutureBuilder

### 4.1 Service Design

```dart
/// Handles observation record fetching and saving
class ObservationService {
  final ApiClient _api;
  final LocalStorage _local;

  // Cache
  List<Observation>? _cachedObservations;
  DateTime? _lastFetch;

  ObservationService(this._api, this._local);

  /// Get observation list (offline-capable)
  Future<List<Observation>> getObservations({
    required String plantId,
    bool forceRefresh = false,
  }) async {
    // Return from local when offline
    if (!await _hasNetwork()) {
      return _local.getObservations(plantId);
    }

    if (!forceRefresh && _cachedObservations != null && _isCacheValid()) {
      return _cachedObservations!;
    }

    _cachedObservations = await _api.fetchObservations(plantId);
    _lastFetch = DateTime.now();

    // Also save locally (for offline use)
    await _local.saveObservations(plantId, _cachedObservations!);

    return _cachedObservations!;
  }

  bool _isCacheValid() =>
    _lastFetch != null &&
    DateTime.now().difference(_lastFetch!) < const Duration(minutes: 5);
}
```

### 4.2 Usage in Screens

```dart
class ObservationListScreen extends StatelessWidget {
  final ObservationService service;
  final String plantId;

  const ObservationListScreen({
    super.key,
    required this.service,
    required this.plantId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Observation>>(
      future: service.getObservations(plantId: plantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorDisplay(
            message: snapshot.error.toString(),
            onRetry: () => /* trigger refetch */,
          );
        }
        return ObservationListView(observations: snapshot.data!);
      },
    );
  }
}
```

---

## 5. Coding Rules

### 5.1 Mandatory Rules

* **Import statements**: Always include when presenting code
* **Comments**: Write Why (design intent), not How (method)
* **Naming**: `_buildXxx()` for private builders, `XxxWidget` for public Widgets
* **const**: Use `const` constructors wherever possible
* **Internationalization**: All user-facing strings via `AppLocalizations`

### 5.2 Prohibited

* Direct API calls within `build()`
* Abuse of global variables/singletons
* Files exceeding 500 lines (consider splitting)
* Hardcoded Japanese/English strings (l10n required)

### 5.3 Error Handling

```dart
// ❌ Bad: Swallowing errors
try { await api.fetch(); } catch (_) {}

// ✅ Good: Explicit handling
try {
  await api.fetch();
} on NetworkException catch (e) {
  // Switch to offline mode
  return _local.getCached();
} on AuthException {
  // Navigate to login screen
}
```

---

## 6. Backend Integration (Cloudflare Workers)

### 6.1 ApiClient Design

```dart
class ApiClient {
  final String baseUrl;
  final http.Client _client;
  final String? _authToken;

  ApiClient({
    required this.baseUrl,
    String? authToken,
  }) : _client = http.Client(),
       _authToken = authToken;

  Future<T> get<T>(String path, T Function(dynamic) fromJson) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: _authToken != null
        ? {'Authorization': 'Bearer $_authToken'}
        : null,
    );
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
    return fromJson(jsonDecode(response.body));
  }

  Future<T> post<T>(String path, dynamic body, T Function(dynamic) fromJson) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(response.statusCode, response.body);
    }
    return fromJson(jsonDecode(response.body));
  }
}
```

### 6.2 Environment Configuration

```dart
// lib/config.dart
class Config {
  // Cloudflare Workers API
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://grow-api.your-domain.workers.dev',
  );

  // Cloudflare Pages (public photos)
  static const String pagesBaseUrl = String.fromEnvironment(
    'PAGES_BASE_URL',
    defaultValue: 'https://grow.pages.dev',
  );

  // Cloudflare R2 (private photos)
  static const String r2BaseUrl = String.fromEnvironment(
    'R2_BASE_URL',
    defaultValue: 'https://grow-private.your-domain.workers.dev',
  );
}
```

---

## 7. Grow-Specific Design

### 7.1 Photo Management (EXIF Processing)

```dart
/// Handles photo EXIF processing
class ExifService {
  /// GPS coordinate processing options
  Future<File> processPhoto(
    File photo, {
    required GpsHandling gpsHandling,
  }) async {
    switch (gpsHandling) {
      case GpsHandling.delete:
        return _removeGps(photo);
      case GpsHandling.keep:
        return photo;
      case GpsHandling.blur:
        return _blurGps(photo, radiusMeters: 1000);
      case GpsHandling.publish:
        return photo;
    }
  }
}

enum GpsHandling { delete, keep, blur, publish }
```

### 7.2 Farming Methods & Soil Classification

```dart
// Farming methods (internationalized)
enum FarmingMethod {
  undecided,
  naturalFukuoka,     // Fukuoka Natural Farming
  naturalOkada,       // MOA Natural Farming (Okada)
  naturalCultivation, // Natural Cultivation (Shizen Saibai)
  naturalFarming,     // Shizen-no
  carbonCycling,      // Carbon Cycling Agriculture
  organic,            // Organic Farming
  conventional,       // Conventional Farming
  other,
}

// WRB 32 Soil Classification
enum SoilType {
  unknown,
  histosols,    // Peat soils
  andosols,     // Volcanic ash soils (Japan's representative soil)
  fluvisols,    // Alluvial soils (most common in Japanese farmland)
  cambisols,    // Brown forest soils
  gleysols,     // Gley soils
  // ... 27 more types
}
```

### 7.3 Offline Support

```dart
/// Local storage (SQLite)
class LocalStorage {
  late final Database _db;

  Future<void> init() async {
    _db = await openDatabase(
      'grow.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE observations (
            id TEXT PRIMARY KEY,
            plant_id TEXT,
            data TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  /// Get unsynced observations
  Future<List<Observation>> getUnsyncedObservations() async {
    final rows = await _db.query('observations', where: 'synced = 0');
    return rows.map((r) => Observation.fromJson(jsonDecode(r['data'] as String))).toList();
  }
}
```

---

## 8. Testing Strategy

* **Widget Unit Tests**: Test each self-contained Widget with Mock Services
* **Service Unit Tests**: Test logic with mocked API responses
* **Screen Integration**: Only major flows (capture → record → save)
* **Offline**: Verify behavior when network is disconnected

---

## 9. Quick Reference

| What You Want to Do | Approach |
|---------------------|----------|
| Simple UI state management | `setState` |
| State sharing across Widgets | `ValueNotifier` + `ValueListenableBuilder` |
| Display async data | `FutureBuilder` |
| Real-time updates | `StreamBuilder` |
| Pass values to deep hierarchy | Constructor injection (or rarely `InheritedWidget`) |
| API communication + cache | Feature-specific Service |
| Offline support | SQLite + sync flag |
| Internationalization | `flutter_localizations` + `.arb` files |
| Photo EXIF processing | `ExifService` |
| Public/Private photos | Pages (public) / R2 (private) |

---

## 10. Internationalization (i18n)

### 10.1 ARB File Structure

```
lib/shared/l10n/
├── app_ja.arb    # Japanese (primary)
└── app_en.arb    # English
```

### 10.2 Usage Example

```dart
// String definitions (app_ja.arb)
{
  "observationTitle": "観察記録",
  "farmingMethodFukuoka": "自然農法（福岡正信）",
  "soilTypeAndosols": "黒ボク土"
}

// String definitions (app_en.arb)
{
  "observationTitle": "Observation Journal",
  "farmingMethodFukuoka": "Fukuoka Natural Farming",
  "soilTypeAndosols": "Andosols"
}

// Usage
Text(AppLocalizations.of(context)!.observationTitle)
```

---

## 11. Why This App Reflects Japanese Wisdom

This app embodies principles that originate from Japanese natural farming:

1. **Observation over Action**: Recording "what is happening" rather than "what was done"
2. **Soil Understanding**: Deep knowledge of Japanese soils and WRB international classification
3. **Farming Philosophies**: Fukuoka, Okada, Shizen Saibai—all developed in Japan
4. **Holistic Approach**: Understanding the connection between soil biology, plant ecology, and weather
5. **Data Ownership**: Users control their own data—reflecting respect for individual autonomy

By following these guidelines, you contribute to bringing Japanese agricultural wisdom to the world through technology.
