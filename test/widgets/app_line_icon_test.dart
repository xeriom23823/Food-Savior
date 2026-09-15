import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/widgets/app_line_icon.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  testWidgets('C/D 線性圖示可在明亮主題繪製', (tester) async {
    await tester.pumpWidget(wrapForTest(
      Scaffold(
        body: Wrap(
          children: AppLineIconKind.values
              .map((kind) => AppLineIcon(kind: kind))
              .toList(),
        ),
      ),
    ));

    expect(
        find.byType(AppLineIcon), findsNWidgets(AppLineIconKind.values.length));
    expect(tester.takeException(), isNull);
  });

  testWidgets('C/D 線性圖示可在深色主題與小尺寸繪製', (tester) async {
    await tester.pumpWidget(wrapForTest(
      Scaffold(
        body: Wrap(
          children: AppLineIconKind.values
              .map((kind) => AppLineIcon(kind: kind, size: 16))
              .toList(),
        ),
      ),
      brightness: Brightness.dark,
      locale: Locale('en', 'US'),
    ));

    expect(
        find.byType(AppLineIcon), findsNWidgets(AppLineIconKind.values.length));
    expect(tester.takeException(), isNull);
  });
}
