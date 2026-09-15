import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_list_grouping.dart';
import 'package:food_savior/repositories/preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<PreferencesRepository> build() async => PreferencesRepository(
        preferences: await SharedPreferences.getInstance(),
      );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('分群方式預設為到期急迫度', () async {
    final repo = await build();

    expect(repo.grouping, FoodListGrouping.urgency);
  });

  test('分群方式會持久化，重新建立仍讀得回來', () async {
    final repo = await build();

    await repo.setGrouping(FoodListGrouping.location);

    expect((await build()).grouping, FoodListGrouping.location);
  });

  test('無法辨識的值退回預設，不讓壞資料弄壞畫面', () async {
    SharedPreferences.setMockInitialValues({'foodList.grouping': 'nonsense'});

    expect((await build()).grouping, FoodListGrouping.urgency);
  });

  test('預設位置的種子旗標只標記一次', () async {
    final repo = await build();
    expect(repo.hasSeededLocations, isFalse);

    await repo.markLocationsSeeded();

    expect(repo.hasSeededLocations, isTrue);
    expect((await build()).hasSeededLocations, isTrue);
  });

  group('已匯入的發票號碼', () {
    test('一開始是空的', () async {
      final repo = await build();

      expect(repo.importedInvoiceNumbers, isEmpty);
      expect(repo.hasImportedInvoice('AB12345678'), isFalse);
    });

    test('記下之後查得到，且會持久化', () async {
      final repo = await build();

      await repo.markInvoiceImported('AB12345678');

      expect(repo.hasImportedInvoice('AB12345678'), isTrue);
      expect((await build()).hasImportedInvoice('AB12345678'), isTrue);
    });

    test('重複記同一張不會變成兩筆', () async {
      final repo = await build();

      await repo.markInvoiceImported('AB12345678');
      await repo.markInvoiceImported('AB12345678');

      expect(repo.importedInvoiceNumbers, ['AB12345678']);
    });

    test('超過上限時捨棄最舊的', () async {
      final repo = await build();
      const limit = PreferencesRepository.importedInvoiceLimit;

      for (var i = 0; i < limit + 5; i++) {
        await repo.markInvoiceImported('INV${i.toString().padLeft(6, '0')}');
      }

      expect(repo.importedInvoiceNumbers, hasLength(limit));
      expect(repo.hasImportedInvoice('INV000000'), isFalse);
      expect(repo.hasImportedInvoice('INV000004'), isFalse);
      expect(repo.hasImportedInvoice('INV000005'), isTrue);
      expect(repo.hasImportedInvoice('INV000204'), isTrue);
    });
  });
}
