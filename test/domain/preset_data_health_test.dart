import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_preset.dart';
import 'package:food_savior/models/storage_location.dart';

/// 對照表與雜訊詞表的資料健檢（item-normalization 規格）。
///
/// `FoodPreset.fromJson` 對未知的 `type`／`unit` 字串有退路（`others`／`piece`），
/// 好處是資料寫錯不會讓 App 起不來，壞處是**錯字會安靜地變成 `others`**。
/// 這個測試就是那道防線。
void main() {
  late List<Map<String, dynamic>> raw;
  late List<FoodPreset> presets;
  late List<String> noiseTerms;
  late List<String> receiptNoiseTerms;

  setUpAll(() {
    raw = (json.decode(
      File('assets/data/food_presets.json').readAsStringSync(),
    ) as List)
        .cast<Map<String, dynamic>>();
    presets = raw.map(FoodPreset.fromJson).toList();

    final noise = json.decode(
      File('assets/data/product_noise_terms.json').readAsStringSync(),
    ) as Map;
    noiseTerms = [
      for (final group in noise.values) ...(group as List).cast<String>(),
    ];

    final receiptNoise = json.decode(
      File('assets/data/receipt_noise_terms.json').readAsStringSync(),
    ) as Map;
    receiptNoiseTerms = [
      for (final group in receiptNoise.values)
        ...(group as List).cast<String>(),
    ];
  });

  test('每一筆都有非空的關鍵字，且關鍵字沒有前後空白', () {
    for (final entry in raw) {
      final keywords = (entry['keywords'] as List).cast<String>();
      expect(keywords, isNotEmpty, reason: '${entry['type']} 有一筆沒有關鍵字');
      for (final keyword in keywords) {
        expect(keyword.trim(), keyword, reason: '「$keyword」有多餘的前後空白');
        expect(keyword, isNotEmpty);
      }
    }
  });

  test('type 字串都是合法的 FoodItemType，沒有因為錯字被吞成 others', () {
    final valid = FoodItemType.values.map((e) => e.name).toSet();

    for (final entry in raw) {
      expect(
        valid,
        contains(entry['type']),
        reason: '「${entry['type']}」不是合法的 FoodItemType，'
            '會被安靜地當成 others（keywords: ${entry['keywords']}）',
      );
    }
  });

  test('unit 字串都是合法的 Unit', () {
    final valid = Unit.values.map((e) => e.name).toSet();

    for (final entry in raw) {
      final unit = entry['unit'];
      if (unit == null) continue;
      expect(valid, contains(unit),
          reason: '「$unit」不是合法的 Unit（keywords: ${entry['keywords']}）');
    }
  });

  test('每一筆都能推導出常溫保存天數，且天數為正整數', () {
    for (final preset in presets) {
      final ambient = preset.daysFor(LocationKind.ambient);
      expect(ambient, isNotNull, reason: '${preset.keywords} 缺常溫天數，會推導不出期限');
      expect(ambient, greaterThan(0), reason: '${preset.keywords} 的天數不是正整數');
    }
  });

  test('缺冷藏或冷凍天數時退回常溫天數，不會變成期限未知', () {
    for (final preset in presets) {
      for (final kind in LocationKind.values) {
        expect(preset.daysFor(kind), isNotNull,
            reason: '${preset.keywords} 在 $kind 推導不出天數');
      }
    }
  });

  test('關鍵字不重複：同一個關鍵字出現在兩筆會讓推導變成看順序', () {
    final seen = <String, String>{};
    final dupes = <String>[];

    for (final entry in raw) {
      for (final keyword in (entry['keywords'] as List).cast<String>()) {
        final owner = seen[keyword];
        if (owner != null) {
          dupes.add('「$keyword」同時屬於 $owner 與 ${entry['type']}');
        }
        seen[keyword] = entry['type'] as String;
      }
    }

    expect(dupes, isEmpty, reason: dupes.join('\n'));
  });

  test('雜訊詞不得包含任何對照表關鍵字，否則會把食物名稱剝掉', () {
    final keywords = <String>{
      for (final entry in raw)
        ...(entry['keywords'] as List).cast<String>().map(normalizeFoodName),
    };
    final clashes = <String>[];

    for (final term in noiseTerms) {
      final normalized = normalizeFoodName(term);
      for (final keyword in keywords) {
        if (normalized.contains(keyword)) {
          clashes.add('雜訊詞「$term」包含對照表關鍵字「$keyword」');
        }
      }
    }

    expect(clashes, isEmpty, reason: clashes.join('\n'));
  });

  test('對照表規模足以支撐命中率', () {
    // 規模掉下來通常代表有人不小心截斷了檔案。
    expect(presets.length, greaterThanOrEqualTo(150));
    expect(
      presets.expand((p) => p.keywords).length,
      greaterThanOrEqualTo(250),
    );
  });

  test('每一種 FoodItemType 都有對照表條目（others 除外可為少數）', () {
    final covered = presets.map((p) => p.type).toSet();

    for (final type in FoodItemType.values) {
      expect(covered, contains(type), reason: '$type 在對照表裡沒有任何條目');
    }
  });

  group('收據雜訊詞表', () {
    test('不得包含任何對照表關鍵字，否則會把整列真食物濾掉', () {
      // 收據雜訊詞是拿去跟**整列品名**做 contains 比對的，
      // 一旦某個詞含有食物關鍵字，那一整列就會被當成表頭表尾丟掉。
      final keywords = <String>{
        for (final entry in raw)
          ...(entry['keywords'] as List).cast<String>().map(normalizeFoodName),
      };
      final clashes = <String>[];

      for (final term in receiptNoiseTerms) {
        final normalized = normalizeFoodName(term);
        for (final keyword in keywords) {
          if (normalized.contains(keyword)) {
            clashes.add('收據雜訊詞「$term」包含對照表關鍵字「$keyword」');
          }
        }
      }

      expect(clashes, isEmpty, reason: clashes.join('\n'));
    });

    test('沒有前後空白、沒有空字串', () {
      for (final term in receiptNoiseTerms) {
        expect(term.trim(), term, reason: '「$term」有多餘的前後空白');
        expect(term, isNotEmpty);
      }
    });

    test('詞不重複', () {
      expect(receiptNoiseTerms.toSet(), hasLength(receiptNoiseTerms.length));
    });

    test('涵蓋表頭、結帳與客套三類', () {
      final receiptNoise = json.decode(
        File('assets/data/receipt_noise_terms.json').readAsStringSync(),
      ) as Map;

      expect(receiptNoise.keys, containsAll(['header', 'checkout', 'misc']));
      expect(receiptNoiseTerms.length, greaterThanOrEqualTo(40));
    });
  });
}
