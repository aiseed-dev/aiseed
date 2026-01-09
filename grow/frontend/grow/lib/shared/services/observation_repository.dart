import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/observation.dart';

/// 観察記録データリポジトリ
///
/// 責務: 観察記録データの永続化と取得
class ObservationRepository {
  static const String _storageKey = 'grow_observations';

  SharedPreferences? _prefs;

  /// シングルトンインスタンス
  static final ObservationRepository _instance = ObservationRepository._internal();
  factory ObservationRepository() => _instance;
  ObservationRepository._internal();

  /// 初期化
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// すべての観察記録を取得
  Future<List<Observation>> getAll() async {
    await init();
    final jsonString = _prefs!.getString(_storageKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Observation.fromJson(json)).toList();
  }

  /// IDで観察記録を取得
  Future<Observation?> getById(String id) async {
    final observations = await getAll();
    try {
      return observations.firstWhere((obs) => obs.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 植物IDで観察記録を取得
  Future<List<Observation>> getByPlantId(String plantId) async {
    final observations = await getAll();
    return observations
        .where((obs) => obs.plantId == plantId)
        .toList()
      ..sort((a, b) => b.observedAt.compareTo(a.observedAt));
  }

  /// 観察記録を保存（新規作成または更新）
  Future<Observation> save(Observation observation) async {
    await init();
    final observations = await getAll();

    final index = observations.indexWhere((o) => o.id == observation.id);
    final updatedObservation = observation.copyWith(updatedAt: DateTime.now());

    if (index >= 0) {
      observations[index] = updatedObservation;
    } else {
      observations.add(updatedObservation);
    }

    await _saveAll(observations);
    return updatedObservation;
  }

  /// 観察記録を削除
  Future<void> delete(String id) async {
    await init();
    final observations = await getAll();
    observations.removeWhere((obs) => obs.id == id);
    await _saveAll(observations);
  }

  /// 植物の観察記録をすべて削除
  Future<void> deleteByPlantId(String plantId) async {
    await init();
    final observations = await getAll();
    observations.removeWhere((obs) => obs.plantId == plantId);
    await _saveAll(observations);
  }

  /// すべての観察記録を保存
  Future<void> _saveAll(List<Observation> observations) async {
    final jsonList = observations.map((obs) => obs.toJson()).toList();
    await _prefs!.setString(_storageKey, json.encode(jsonList));
  }

  /// 観察記録数を取得
  Future<int> count() async {
    final observations = await getAll();
    return observations.length;
  }

  /// 植物ごとの観察記録数を取得
  Future<int> countByPlantId(String plantId) async {
    final observations = await getByPlantId(plantId);
    return observations.length;
  }

  /// 最近の観察記録を取得
  Future<List<Observation>> getRecent({int limit = 10}) async {
    final observations = await getAll();
    observations.sort((a, b) => b.observedAt.compareTo(a.observedAt));
    return observations.take(limit).toList();
  }
}
