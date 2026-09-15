import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/pages/import/import_route.dart';

/// einvoice-import 規格：「掃描入口僅在支援的平台出現」。
///
/// 用 `Theme.of(context).platform` 而不是 `dart:io` 的 `Platform`，
/// 一來 Web 上 `dart:io` 會編譯失敗，二來它可以像這樣被測試覆蓋（design D10）。
void main() {
  Future<bool> supportedOn(WidgetTester tester, TargetPlatform platform) async {
    late bool supported;

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(platform: platform),
      home: Builder(
        builder: (context) {
          supported = ImportRoute.isSupportedOn(context);
          return const SizedBox.shrink();
        },
      ),
    ));

    return supported;
  }

  testWidgets('Android 顯示掃描入口', (tester) async {
    expect(await supportedOn(tester, TargetPlatform.android), isTrue);
  });

  testWidgets('iOS 顯示掃描入口', (tester) async {
    expect(await supportedOn(tester, TargetPlatform.iOS), isTrue);
  });

  testWidgets('桌面平台不顯示掃描入口', (tester) async {
    for (final platform in const [
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
    ]) {
      expect(
        await supportedOn(tester, platform),
        isFalse,
        reason: '$platform 沒有 mobile_scanner 的相機實作',
      );
    }
  });

  testWidgets('fuchsia 也不顯示', (tester) async {
    expect(await supportedOn(tester, TargetPlatform.fuchsia), isFalse);
  });
}
