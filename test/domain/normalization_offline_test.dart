import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_suggestion.dart';

/// 「名稱推導完全離線」（item-normalization 規格）。
///
/// 這是**架構約束**，不是某個函式的行為，所以用靜態檢查來鎖：推導路徑上的檔案
/// 一旦 import 了網路相關的東西，這個測試就會紅。
///
/// 為什麼值得測：這條規格是整個 change 的前提（不走後端、不走 LLM、零 API 成本）。
/// 沒有這道防線，日後有人「順手」加一個查詢 API 不會有任何東西擋他。
void main() {
  /// 推導路徑上的所有檔案。
  const pathsOnNormalizationPath = [
    'lib/models/food_suggestion.dart',
    'lib/models/food_preset.dart',
    'lib/domain/import/product_name_cleaner.dart',
    'lib/domain/import/invoice_draft_mapper.dart',
    'lib/domain/import/food_item_draft.dart',
    'lib/repositories/food_preset_repository.dart',
    'lib/repositories/product_noise_terms_repository.dart',
  ];

  /// 會把推導帶出裝置的東西。
  const networkMarkers = [
    "import 'dart:io'",
    'package:http',
    'package:dio',
    'cloud_firestore',
    'cloud_functions',
    'firebase_',
    'HttpClient',
    'WebSocket',
  ];

  test('推導路徑上的檔案都沒有網路相依', () {
    final offenders = <String>[];

    for (final path in pathsOnNormalizationPath) {
      final source = File(path).readAsStringSync();
      for (final marker in networkMarkers) {
        if (source.contains(marker)) {
          offenders.add('$path 含有「$marker」');
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('推導在沒有任何外部相依的情況下得到確定結果', () {
    // 同一份資料、同一個輸入，推導結果必須完全一致——沒有任何來自外部的變因。
    const engine = FoodSuggestionEngine(presets: []);
    final now = DateTime(2026, 9, 15);

    final first = engine.suggest(name: '雞蛋', now: now);
    final second = engine.suggest(name: '雞蛋', now: now);

    expect(first.type, second.type);
    expect(first.expiry, second.expiry);
    expect(first.source, second.source);
  });

  test('空名稱不拋出例外，回傳未命中', () {
    const engine = FoodSuggestionEngine();

    expect(engine.presetFor(''), isNull);
    expect(engine.presetFor('   '), isNull);
    expect(
      engine.suggest(name: '  ', now: DateTime(2026, 9, 15)).source,
      SuggestionSource.none,
    );
  });

  test('未命中時退回 others 與期限未知，並標示為未命中', () {
    const engine = FoodSuggestionEngine();

    final suggestion = engine.suggest(
      name: '環保購物袋',
      now: DateTime(2026, 9, 15),
    );

    expect(suggestion.type, FoodItemType.others);
    expect(suggestion.expiry.isKnown, isFalse);
    expect(suggestion.source, SuggestionSource.none);
  });
}
