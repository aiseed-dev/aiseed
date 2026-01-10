import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plant.dart';

/// 植物データリポジトリ
///
/// 責務: 植物データの永続化と取得
class PlantRepository {
  static const String _storageKey = 'grow_plants';

  SharedPreferences? _prefs;

  /// シングルトンインスタンス
  static final PlantRepository _instance = PlantRepository._internal();
  factory PlantRepository() => _instance;
  PlantRepository._internal();

  /// 初期化
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// すべての植物を取得
  Future<List<Plant>> getAll() async {
    await init();
    final jsonString = _prefs!.getString(_storageKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Plant.fromJson(json)).toList();
  }

  /// IDで植物を取得
  Future<Plant?> getById(String id) async {
    final plants = await getAll();
    try {
      return plants.firstWhere((plant) => plant.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 植物を保存（新規作成または更新）
  Future<Plant> save(Plant plant) async {
    await init();
    final plants = await getAll();

    final index = plants.indexWhere((p) => p.id == plant.id);
    final updatedPlant = plant.copyWith(updatedAt: DateTime.now());

    if (index >= 0) {
      plants[index] = updatedPlant;
    } else {
      plants.add(updatedPlant);
    }

    await _saveAll(plants);
    return updatedPlant;
  }

  /// 植物を削除
  Future<void> delete(String id) async {
    await init();
    final plants = await getAll();
    plants.removeWhere((plant) => plant.id == id);
    await _saveAll(plants);
  }

  /// すべての植物を保存
  Future<void> _saveAll(List<Plant> plants) async {
    final jsonList = plants.map((plant) => plant.toJson()).toList();
    await _prefs!.setString(_storageKey, json.encode(jsonList));
  }

  /// 植物数を取得
  Future<int> count() async {
    final plants = await getAll();
    return plants.length;
  }

  /// 最近更新された植物を取得
  Future<List<Plant>> getRecent({int limit = 5}) async {
    final plants = await getAll();
    plants.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return plants.take(limit).toList();
  }
}
