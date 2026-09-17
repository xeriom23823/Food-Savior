import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/theme/food_item_visuals.dart';
import 'package:food_savior/widgets/food_type_icon.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  test('每個食物類型都有唯一的 asset 對照', () {
    final assets = FoodItemType.values.map(FoodItemVisuals.assetOf).toList();

    expect(assets, hasLength(FoodItemType.values.length));
    expect(assets.toSet(), hasLength(FoodItemType.values.length));
    expect(
      assets.every((asset) => asset.startsWith('assets/icons/food_type_')),
      isTrue,
    );
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      '11 個食物類型圖示在 ${brightness.name} 主題可渲染',
      (tester) async {
        await tester.pumpWidget(
          wrapForTest(
            Scaffold(
              body: Wrap(
                children: [
                  for (final type in FoodItemType.values)
                    FoodTypeIcon(type: type),
                ],
              ),
            ),
            brightness: brightness,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsNWidgets(FoodItemType.values.length));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
