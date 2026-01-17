import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// HP（ホームページ）データモデル
class HpData {
  final String id;
  final String name;
  final String html;
  final String? prompt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HpData({
    required this.id,
    required this.name,
    required this.html,
    this.prompt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HpData.fromJson(Map<String, dynamic> json) {
    return HpData(
      id: json['id'] as String,
      name: json['name'] as String,
      html: json['html'] as String,
      prompt: json['prompt'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'html': html,
      'prompt': prompt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  HpData copyWith({
    String? id,
    String? name,
    String? html,
    String? prompt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HpData(
      id: id ?? this.id,
      name: name ?? this.name,
      html: html ?? this.html,
      prompt: prompt ?? this.prompt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// HPデータのリポジトリ
class HpRepository {
  static const _storageKey = 'hp_list';
  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();

  HpRepository(this._prefs);

  /// 全てのHPを取得
  Future<List<HpData>> getAll() async {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => HpData.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// HPを保存
  Future<HpData> save({
    String? id,
    required String name,
    required String html,
    String? prompt,
  }) async {
    final list = await getAll();
    final now = DateTime.now();

    HpData hp;
    if (id != null) {
      // 更新
      final index = list.indexWhere((e) => e.id == id);
      if (index >= 0) {
        hp = list[index].copyWith(
          name: name,
          html: html,
          prompt: prompt,
          updatedAt: now,
        );
        list[index] = hp;
      } else {
        // 存在しない場合は新規作成
        hp = HpData(
          id: _uuid.v4(),
          name: name,
          html: html,
          prompt: prompt,
          createdAt: now,
          updatedAt: now,
        );
        list.add(hp);
      }
    } else {
      // 新規作成
      hp = HpData(
        id: _uuid.v4(),
        name: name,
        html: html,
        prompt: prompt,
        createdAt: now,
        updatedAt: now,
      );
      list.add(hp);
    }

    await _saveList(list);
    return hp;
  }

  /// HPを削除
  Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((e) => e.id == id);
    await _saveList(list);
  }

  /// IDでHPを取得
  Future<HpData?> getById(String id) async {
    final list = await getAll();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// HTMLをファイルとしてエクスポート
  Future<String> exportToFile(HpData hp) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${hp.name.replaceAll(RegExp(r'[^\w\s]'), '_')}_${hp.id.substring(0, 8)}.html';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(hp.html);
    return file.path;
  }

  /// 一時ファイルとしてプレビュー用にエクスポート
  Future<String> exportForPreview(String html) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/preview_${DateTime.now().millisecondsSinceEpoch}.html');
    await file.writeAsString(html);
    return file.path;
  }

  Future<void> _saveList(List<HpData> list) async {
    final jsonString = json.encode(list.map((e) => e.toJson()).toList());
    await _prefs.setString(_storageKey, jsonString);
  }
}
