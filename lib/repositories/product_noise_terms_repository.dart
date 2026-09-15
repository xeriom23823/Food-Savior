import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:food_savior/repositories/food_preset_repository.dart'
    show AssetLoader;

/// 載入 POS 品名的雜訊詞表（design D5）。
///
/// 詞表是**資料不是程式**：要加一個新的通路或品牌，改 JSON 就好。
/// 讀 asset 的部分沿用 [AssetLoader]，測試才不需要 Flutter binding。
class ProductNoiseTermsRepository {
  ProductNoiseTermsRepository({AssetLoader? loader})
      : _loader = loader ?? rootBundle.loadString;

  static const String assetKey = 'assets/data/product_noise_terms.json';

  final AssetLoader _loader;
  List<String>? _cache;

  List<String> get terms => _cache ?? const [];

  Future<List<String>> load() async {
    final cached = _cache;
    if (cached != null) return cached;
    try {
      final decoded = json.decode(await _loader(assetKey)) as Map;
      _cache = [
        for (final group in decoded.values) ...(group as List).cast<String>(),
      ];
    } catch (_) {
      // 詞表只讓名稱更好看，讀不到就不剝雜訊，不該讓匯入失敗。
      _cache = const [];
    }
    return _cache!;
  }
}
