import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/repositories/receipt_noise_terms_repository.dart';

void main() {
  test('載入後把所有群組攤平成一份清單', () async {
    final repository = ReceiptNoiseTermsRepository(
      loader: (_) async => '{"header":["統一編號","電話"],"checkout":["總計"]}',
    );

    expect(repository.terms, isEmpty);
    expect(await repository.load(), ['統一編號', '電話', '總計']);
    expect(repository.terms, ['統一編號', '電話', '總計']);
  });

  test('只讀一次 asset', () async {
    var loads = 0;
    final repository = ReceiptNoiseTermsRepository(
      loader: (_) async {
        loads++;
        return '{"header":["統一編號"]}';
      },
    );

    await repository.load();
    await repository.load();
    expect(loads, 1);
  });

  test('asset 壞掉時回空清單而不是丟例外', () async {
    final repository = ReceiptNoiseTermsRepository(
      loader: (_) async => 'not json',
    );

    expect(await repository.load(), isEmpty);
  });

  test('讀的是收據雜訊詞表', () {
    expect(
      ReceiptNoiseTermsRepository.assetKey,
      'assets/data/receipt_noise_terms.json',
    );
  });
}
