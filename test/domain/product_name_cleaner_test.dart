import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/domain/import/product_name_cleaner.dart';
import 'package:food_savior/models/food_item.dart';

/// 直接讀 asset 檔（純 Dart 測試不需要 rootBundle），確保程式與資料同步：
/// 詞表少了一個詞，測試就會抓到。
List<String> loadNoiseTerms() {
  final decoded = json.decode(
      File('assets/data/product_noise_terms.json').readAsStringSync()) as Map;
  return [
    for (final group in decoded.values) ...(group as List).cast<String>(),
  ];
}

void main() {
  late ProductNameCleaner cleaner;

  setUp(() => cleaner = ProductNameCleaner(noiseTerms: loadNoiseTerms()));

  group('規格抽取', () {
    test('毫升', () {
      final result = cleaner.clean('統一AB優酪乳400ML特價');

      expect(result.coreName, contains('優酪乳'));
      expect(result.amount, 400);
      expect(result.unit, Unit.milliliter);
    });

    test('公克，且括號內的規格不會連同括號被丟掉', () {
      final result = cleaner.clean('【冷藏】梅花豬肉片(約300g)');

      expect(result.coreName, contains('梅花豬肉片'));
      expect(result.amount, 300);
      expect(result.unit, Unit.gram);
    });

    test('件數以「入」表示', () {
      final result = cleaner.clean('量販-雞蛋10入');

      expect(result.coreName, contains('雞蛋'));
      expect(result.amount, 10);
      expect(result.unit, Unit.piece);
    });

    test('公斤換算為公克', () {
      final result = cleaner.clean('白米2kg');

      expect(result.amount, 2000);
      expect(result.unit, Unit.gram);
    });

    test('公升換算為毫升', () {
      final result = cleaner.clean('鮮乳1公升');

      expect(result.amount, 1000);
      expect(result.unit, Unit.milliliter);
    });

    test('kg 不會被當成 k + g', () {
      expect(cleaner.clean('麵粉1kg').amount, 1000);
    });

    test('沒有數字的計價單位也拿得到單位', () {
      final result = cleaner.clean('新鮮 高麗菜/顆');

      expect(result.coreName, contains('高麗菜'));
      expect(result.amount, 1);
      expect(result.unit, Unit.piece);
    });

    test('沒有規格時 amount 與 unit 都是 null', () {
      final result = cleaner.clean('香蕉');

      expect(result.coreName, '香蕉');
      expect(result.hasSpec, isFalse);
    });
  });

  group('雜訊剝除', () {
    test('剝除促銷字樣', () {
      expect(cleaner.clean('特價蘋果').coreName, '蘋果');
    });

    test('剝除通路前綴', () {
      expect(cleaner.clean('全聯-青花菜').coreName, '青花菜');
    });

    test('剝除溫層標示', () {
      expect(cleaner.clean('冷凍鮭魚').coreName, '鮭魚');
    });

    test('剝除品牌', () {
      expect(cleaner.clean('林鳳營鮮奶').coreName, '鮮奶');
    });

    test('較長的詞優先剝除，不會剩下殘段', () {
      // 「統一超商」若先被「統一」吃掉，會剩下「超商」。
      expect(cleaner.clean('統一超商飯糰').coreName, '飯糰');
    });

    test('剝除括號與其內容', () {
      expect(cleaner.clean('雞胸肉(去骨)').coreName, '雞胸肉');
    });
  });

  group('退路', () {
    test('清洗後為空時退回原始品名', () {
      // 整串都是雜訊詞。
      final result = cleaner.clean('特價促銷');

      expect(result.coreName, isNotEmpty);
      expect(result.coreName, contains('特價'));
    });

    test('空字串不會產生無名稱的結果', () {
      expect(cleaner.clean('   ').coreName, isEmpty);
    });

    test('沒有雜訊詞表時仍可運作，只是不剝雜訊', () {
      final bare = ProductNameCleaner(noiseTerms: const []);
      final result = bare.clean('統一AB優酪乳400ML特價');

      expect(result.amount, 400);
      expect(result.coreName, contains('優酪乳'));
    });
  });
}
