import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:food_savior/models/food_preset.dart';

/// 載入內建的保存期限對照表（design D15）。
///
/// 讀 asset 的部分抽成 [AssetLoader]，測試才不需要 Flutter binding。
typedef AssetLoader = Future<String> Function(String key);

class FoodPresetRepository {
  FoodPresetRepository({AssetLoader? loader})
      : _loader = loader ?? rootBundle.loadString;

  static const String assetKey = 'assets/data/food_presets.json';

  final AssetLoader _loader;
  List<FoodPreset>? _cache;

  List<FoodPreset> get presets => _cache ?? const [];

  Future<List<FoodPreset>> load() async {
    final cached = _cache;
    if (cached != null) return cached;
    try {
      final raw = await _loader(assetKey);
      final decoded = json.decode(raw) as List;
      _cache = decoded
          .cast<Map<String, dynamic>>()
          .map(FoodPreset.fromJson)
          .toList();
    } catch (_) {
      // 對照表只是建議來源，讀不到就退回「期限未知」，不該讓 App 起不來。
      _cache = const [];
    }
    return _cache!;
  }
}
