import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/app/view/bootstrap_splash.dart';

void main() {
  testWidgets('bootstrap splash renders the branded illustration', (
    tester,
  ) async {
    await tester.pumpWidget(const BootstrapSplash());

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(
      tester.widget<Image>(find.byType(Image)).image,
      isA<AssetImage>(),
    );
  });
}
