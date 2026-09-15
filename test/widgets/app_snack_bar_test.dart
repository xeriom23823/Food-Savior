import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/theme/app_assets.dart';
import 'package:food_savior/widgets/app_snack_bar.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  testWidgets('B4 每日上限回饋可顯示靜態插圖', (tester) async {
    await tester.pumpWidget(wrapForTest(const Scaffold(body: SizedBox())));

    AppSnackBar.show(
      tester.element(find.byType(SizedBox)),
      message: '今日已足夠',
      illustrationAsset: AppAssets.feedbackDailyCap,
    );
    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                AppAssets.feedbackDailyCap,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('B1 食用成功回饋可載入既有 Lottie', (tester) async {
    await tester.pumpWidget(wrapForTest(const Scaffold(body: SizedBox())));

    AppSnackBar.show(
      tester.element(find.byType(SizedBox)),
      message: '已使用',
      lottieAsset: AppAssets.feedbackEating,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });
}
