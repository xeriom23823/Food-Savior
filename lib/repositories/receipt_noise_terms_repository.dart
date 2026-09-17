import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:food_savior/repositories/food_preset_repository.dart'
    show AssetLoader;

/// 載入收據表頭表尾與結帳資訊的雜訊詞表（design D1 第 5 步）。
///
/// 詞表是**資料不是程式**：要讓某家店的表尾不被當成品項，改 JSON 就好。
/// 讀 asset 的部分沿用 [AssetLoader]，測試才不需要 Flutter binding。
class ReceiptNoiseTermsRepository {
  ReceiptNoiseTermsRepository({AssetLoader? loader})
      : _loader = loader ?? rootBundle.loadString;

  static const String assetKey = 'assets/data/receipt_noise_terms.json';

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
      // 讀不到就不濾表頭表尾——會多出幾列給使用者排除，但不該讓匯入失敗。
      _cache = const [];
    }
    return _cache!;
  }
}
