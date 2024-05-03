import 'package:flutter/material.dart';
import 'package:food_savior/app/app.dart';
import 'package:food_savior/main.dart';
import 'package:food_savior/login/login.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('onGenerateAppViewPages', () {
    test('returns [HomePage] when authenticated', () {
      expect(
        onGenerateAppViewPages(AppStatus.authenticated, []),
        [
          isA<MaterialPage<void>>().having(
            (p) => p.child,
            'child',
            isA<FoodSavior>(),
          ),
        ],
      );
    });

    test('returns [LoginPage] when unauthenticated', () {
      expect(
        onGenerateAppViewPages(AppStatus.unauthenticated, []),
        [
          isA<MaterialPage<void>>().having(
            (p) => p.child,
            'child',
            isA<LoginPage>(),
          ),
        ],
      );
    });
  });
}
