import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/theme/app_assets.dart';
import 'package:food_savior/widgets/empty_state.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  testWidgets('可顯示空狀態插畫資產', (tester) async {
    await tester.pumpWidget(wrapForTest(
      const Scaffold(
        body: EmptyState(
          icon: Icons.inbox_outlined,
          illustrationAsset: AppAssets.emptyFoodInventory,
          title: '尚無食物',
        ),
      ),
    ));

    expect(find.byType(Image), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                AppAssets.emptyFoodInventory,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
