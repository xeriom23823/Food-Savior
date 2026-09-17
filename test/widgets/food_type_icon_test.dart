import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/theme/food_item_visuals.dart';
import 'package:food_savior/widgets/food_type_icon.dart';

import '../helpers/widget_test_helper.dart';

void main() {
  test('每個 FoodItemType 都對到唯一的 E 組 asset', () {
    final assets = FoodItemType.values
        .map(FoodItemVisuals.assetOf)
        .toList(growable: false);

    expect(assets.toSet().length, FoodItemType.values.length,
        reason: '兩個類型共用同一張圖示會讓使用者分不出來');
    for (final asset in assets) {
      expect(asset, startsWith('assets/icons/food_type_'));
      expect(asset, endsWith('.png'));
    }
  });

  test('E 組 asset 與 2.0x／3.0x variant 都能從 bundle 讀出來', () async {
    for (final type in FoodItemType.values) {
      final asset = FoodItemVisuals.assetOf(type);
      final variants = [
        asset,
        asset.replaceFirst('assets/icons/', 'assets/icons/2.0x/'),
        asset.replaceFirst('assets/icons/', 'assets/icons/3.0x/'),
      ];
      for (final variant in variants) {
        final data = await rootBundle.load(variant);
        expect(data.lengthInBytes, greaterThan(0), reason: '$variant 是空檔');
      }
    }
  });

  testWidgets('11 個食物類型圖示可在明亮主題繪製', (tester) async {
    await tester.pumpWidget(wrapForTest(
      Scaffold(
        body: Wrap(
          children: FoodItemType.values
              .map((type) => FoodTypeIcon(type: type))
              .toList(),
        ),
      ),
    ));

    expect(
        find.byType(FoodTypeIcon), findsNWidgets(FoodItemType.values.length));
    expect(tester.takeException(), isNull);
  });

  testWidgets('11 個食物類型圖示可在深色主題與 16 px 繪製', (tester) async {
    await tester.pumpWidget(wrapForTest(
      Scaffold(
        body: Wrap(
          children: FoodItemType.values
              .map((type) => FoodTypeIcon(type: type, size: 16))
              .toList(),
        ),
      ),
      brightness: Brightness.dark,
      locale: const Locale('en', 'US'),
    ));

    expect(
        find.byType(FoodTypeIcon), findsNWidgets(FoodItemType.values.length));
    expect(tester.takeException(), isNull);
  });

  testWidgets('圖示以 IconTheme 顏色著色，深淺主題不會沿用圖檔本身的綠', (tester) async {
    await tester.pumpWidget(wrapForTest(
      const IconTheme(
        data: IconThemeData(color: Color(0xFF123456)),
        child: Scaffold(body: FoodTypeIcon(type: FoodItemType.vegetable)),
      ),
    ));

    final filtered = tester.widget<ColorFiltered>(
      find.descendant(
        of: find.byType(FoodTypeIcon),
        matching: find.byType(ColorFiltered),
      ),
    );

    expect(
      filtered.colorFilter,
      const ColorFilter.mode(Color(0xFF123456), BlendMode.srcIn),
    );
  });

  testWidgets('顯式 color 參數優先於 IconTheme', (tester) async {
    await tester.pumpWidget(wrapForTest(
      const IconTheme(
        data: IconThemeData(color: Color(0xFF123456)),
        child: Scaffold(
          body: FoodTypeIcon(
            type: FoodItemType.meat,
            color: Color(0xFFABCDEF),
          ),
        ),
      ),
    ));

    final filtered = tester.widget<ColorFiltered>(
      find.descendant(
        of: find.byType(FoodTypeIcon),
        matching: find.byType(ColorFiltered),
      ),
    );

    expect(
      filtered.colorFilter,
      const ColorFilter.mode(Color(0xFFABCDEF), BlendMode.srcIn),
    );
  });

  test('pubspec 有宣告 E 組會用到的三個 asset 目錄', () async {
    final pubspec = await rootBundle.loadString('pubspec.yaml').then(
          (value) => value,
          onError: (_) => '',
        );
    // pubspec 本身不在 bundle 裡時跳過：這條只在能讀到時當額外保險。
    if (pubspec.isEmpty) return;
    for (final dir in const [
      'assets/icons/',
      'assets/icons/2.0x/',
      'assets/icons/3.0x/',
    ]) {
      expect(
          const LineSplitter()
              .convert(pubspec)
              .any((line) => line.trim() == '- $dir'),
          isTrue,
          reason: '$dir 沒有在 pubspec 宣告，release build 會讀不到');
    }
  });
}
