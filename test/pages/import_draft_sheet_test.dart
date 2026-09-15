import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/domain/import/food_item_draft.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/pages/import/import_draft_sheet.dart';

import '../helpers/hive_test_helper.dart';
import '../helpers/widget_test_helper.dart';

/// 六個欄位都要能改——`einvoice-import` 規格要求，而先前的實作只做了名稱。
void main() {
  final now = DateTime(2026, 9, 15, 9);
  final issued = DateTime(2026, 9, 15);

  final locations = [
    makeLocation(id: 'fridge', name: '冷藏', kind: LocationKind.refrigerated),
    makeLocation(id: 'freezer', name: '冷凍', kind: LocationKind.frozen),
  ];

  FoodItemDraft draft({
    String name = '優酪乳',
    FoodItemType type = FoodItemType.eggAndMilk,
    double? amount = 1,
    Unit? unit = Unit.bottle,
    String? locationId,
    bool needsReview = false,
  }) =>
      FoodItemDraft(
        sourceLine: '統一AB優酪乳400ML特價',
        name: name,
        type: type,
        expiry: ExpiryValue.exact(DateTime(2026, 9, 29)),
        storageDate: issued,
        amount: amount,
        unit: unit,
        storageLocationId: locationId,
        priceTotal: 32,
        needsReview: needsReview,
      );

  /// 開 sheet、操作、按儲存，回傳被送出的草稿（使用者取消則為 null）。
  Future<FoodItemDraft?> openAndSave(
    WidgetTester tester, {
    required FoodItemDraft initial,
    required Future<void> Function(WidgetTester tester) act,
    Locale locale = const Locale('zh', 'TW'),
    Brightness brightness = Brightness.light,
  }) async {
    FoodItemDraft? result;

    // 預設的 800x600 比手機矮，整張 sheet 會超出視窗導致按鈕點不到。
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(wrapForTest(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await ImportDraftSheet.show(
                context,
                draft: initial,
                locations: locations,
                now: now,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
      locale: locale,
      brightness: brightness,
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await act(tester);

    final save = find.text(locale.languageCode == 'en' ? 'Save' : '儲存');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();

    return result;
  }

  testWidgets('顯示原始品名供對照發票', (tester) async {
    await openAndSave(
      tester,
      initial: draft(),
      act: (tester) async {
        expect(find.text('發票品名：統一AB優酪乳400ML特價'), findsOneWidget);
      },
    );
  });

  testWidgets('可以改名稱', (tester) async {
    final result = await openAndSave(
      tester,
      initial: draft(),
      act: (tester) async {
        await tester.enterText(find.byType(TextField).first, '全脂鮮乳');
      },
    );

    expect(result?.name, '全脂鮮乳');
  });

  // 使用者回報的情境：兩瓶飲料想標成今天到期。
  testWidgets('可以用快速選項把期限改成今天', (tester) async {
    final result = await openAndSave(
      tester,
      initial: draft(),
      act: (tester) async {
        await tester.ensureVisible(find.text('今天'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('今天'));
        await tester.pumpAndSettle();
      },
    );

    expect(result?.expiry.earliest, DateTime(2026, 9, 15));
    expect(result?.expiry.precision, ExpiryPrecision.exact);
  });

  testWidgets('可以改類型', (tester) async {
    final result = await openAndSave(
      tester,
      initial: draft(),
      act: (tester) async {
        await tester.tap(find.byType(DropdownButtonFormField<FoodItemType>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('飲料').last);
        await tester.pumpAndSettle();
      },
    );

    expect(result?.type, FoodItemType.drink);
  });

  testWidgets('可以改數量', (tester) async {
    final result = await openAndSave(
      tester,
      initial: draft(),
      act: (tester) async {
        await tester.enterText(find.byType(TextField).last, '3');
      },
    );

    expect(result?.amount, 3);
  });

  testWidgets('清空數量真的會清成 null', (tester) async {
    final result = await openAndSave(
      tester,
      initial: draft(amount: 2),
      act: (tester) async {
        await tester.enterText(find.byType(TextField).last, '');
      },
    );

    expect(result?.amount, isNull);
  });

  testWidgets('可以改單位', (tester) async {
    final result = await openAndSave(
      tester,
      initial: draft(),
      act: (tester) async {
        await tester.tap(find.byType(DropdownButtonFormField<Unit>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('毫升').last);
        await tester.pumpAndSettle();
      },
    );

    expect(result?.unit, Unit.milliliter);
  });

  testWidgets('可以改存放位置', (tester) async {
    final result = await openAndSave(
      tester,
      initial: draft(locationId: 'fridge'),
      act: (tester) async {
        await tester.tap(find.byType(DropdownButtonFormField<String?>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('冷凍').last);
        await tester.pumpAndSettle();
      },
    );

    expect(result?.storageLocationId, 'freezer');
  });

  testWidgets('儲存後清除待確認標示', (tester) async {
    final result = await openAndSave(
      tester,
      initial: draft(needsReview: true),
      act: (tester) async {},
    );

    expect(result?.needsReview, isFalse);
  });

  testWidgets('不改任何東西直接儲存也不會弄壞草稿', (tester) async {
    final initial = draft();
    final result = await openAndSave(
      tester,
      initial: initial,
      act: (tester) async {},
    );

    expect(result?.name, initial.name);
    expect(result?.type, initial.type);
    expect(result?.amount, initial.amount);
    expect(result?.unit, initial.unit);
    expect(result?.expiry, initial.expiry);
    expect(result?.priceTotal, initial.priceTotal);
    expect(result?.sourceLine, initial.sourceLine);
  });

  group('主題與語系', () {
    testWidgets('暗色主題可繪製', (tester) async {
      await openAndSave(
        tester,
        initial: draft(),
        act: (tester) async => expect(tester.takeException(), isNull),
        brightness: Brightness.dark,
      );
    });

    testWidgets('英文語系', (tester) async {
      await openAndSave(
        tester,
        initial: draft(),
        act: (tester) async {
          expect(find.text('Edit this item'), findsOneWidget);
          expect(find.text('Today'), findsOneWidget);
        },
        locale: const Locale('en'),
      );
    });
  });
}
