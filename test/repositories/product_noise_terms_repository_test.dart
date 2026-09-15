import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/repositories/product_noise_terms_repository.dart';

void main() {
  const json = '''
{
  "promo": ["特價", "量販"],
  "brand": ["統一"]
}
''';

  test('把各分組的詞攤平成一份清單', () async {
    final repo = ProductNoiseTermsRepository(loader: (_) async => json);

    final terms = await repo.load();

    expect(terms, containsAll(['特價', '量販', '統一']));
    expect(terms, hasLength(3));
  });

  test('第二次載入用快取，不再讀 asset', () async {
    var calls = 0;
    final repo = ProductNoiseTermsRepository(loader: (_) async {
      calls++;
      return json;
    });

    await repo.load();
    await repo.load();

    expect(calls, 1);
  });

  test('讀不到 asset 時回傳空清單', () async {
    // 詞表只讓名稱更好看，讀不到就不剝雜訊，不該讓整個匯入流程失敗。
    final repo = ProductNoiseTermsRepository(
      loader: (_) async => throw Exception('missing'),
    );

    expect(await repo.load(), isEmpty);
    expect(repo.terms, isEmpty);
  });

  test('內容不是合法 JSON 時回傳空清單', () async {
    final repo = ProductNoiseTermsRepository(loader: (_) async => 'not json');

    expect(await repo.load(), isEmpty);
  });

  test('load 之前 terms 是空的', () {
    expect(
        ProductNoiseTermsRepository(loader: (_) async => json).terms, isEmpty);
  });

  test('實際的 asset 檔可被解析且不含空字串', () async {
    // 直接讀真檔：詞表改壞（尾逗號、空字串）時測試要抓得到。
    final raw = File(ProductNoiseTermsRepository.assetKey).readAsStringSync();
    final repo = ProductNoiseTermsRepository(loader: (_) async => raw);

    final terms = await repo.load();

    expect(terms, isNotEmpty);
    expect(terms.where((term) => term.trim().isEmpty), isEmpty);
    expect(json5Groups(raw), isNotEmpty);
  });
}

/// 確認 asset 仍維持「分組 → 詞陣列」的結構，而不是被改成別的形狀。
Iterable<String> json5Groups(String raw) =>
    (jsonDecode(raw) as Map).keys.cast<String>();
