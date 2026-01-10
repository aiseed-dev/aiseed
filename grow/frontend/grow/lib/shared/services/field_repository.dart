import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/field.dart';

/// 畑（栽培場所）データリポジトリ
///
/// 責務: 畑データの永続化と取得
class FieldRepository {
  static const String _storageKey = 'grow_fields';

  SharedPreferences? _prefs;

  /// シングルトンインスタンス
  static final FieldRepository _instance = FieldRepository._internal();
  factory FieldRepository() => _instance;
  FieldRepository._internal();

  /// 初期化
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// すべての畑を取得
  Future<List<Field>> getAll() async {
    await init();
    final jsonString = _prefs!.getString(_storageKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Field.fromJson(json)).toList();
  }

  /// IDで畑を取得
  Future<Field?> getById(String id) async {
    final fields = await getAll();
    try {
      return fields.firstWhere((field) => field.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 畑を保存（新規作成または更新）
  Future<Field> save(Field field) async {
    await init();
    final fields = await getAll();

    final index = fields.indexWhere((f) => f.id == field.id);
    final updatedField = field.copyWith(updatedAt: DateTime.now());

    if (index >= 0) {
      fields[index] = updatedField;
    } else {
      fields.add(updatedField);
    }

    await _saveAll(fields);
    return updatedField;
  }

  /// 畑を削除
  Future<void> delete(String id) async {
    await init();
    final fields = await getAll();
    fields.removeWhere((field) => field.id == id);
    await _saveAll(fields);
  }

  /// すべての畑を保存
  Future<void> _saveAll(List<Field> fields) async {
    final jsonList = fields.map((field) => field.toJson()).toList();
    await _prefs!.setString(_storageKey, json.encode(jsonList));
  }

  /// 畑数を取得
  Future<int> count() async {
    final fields = await getAll();
    return fields.length;
  }

  /// デフォルトの畑があるかチェック
  Future<bool> hasFields() async {
    final count = await this.count();
    return count > 0;
  }
}
