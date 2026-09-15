// 編譯煙霧測試：把 main.dart 可達的所有程式碼（含第三方套件）交給 Dart 編譯器。
// 目的：flutter analyze 不會回報 pub 套件內的錯誤（例如套件 extends 了已變成 final 的
// Flutter 類別），這個測試在 flutter test 階段就能抓到，不必等 flutter build。
// 不啟動 App（需要 Firebase），只確認符號可解析。
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/main.dart' as app;

void main() {
  test('main.dart 與其相依可編譯', () {
    expect(app.main, isA<Function>());
    expect(const app.FoodSavior(), isA<app.FoodSavior>());
  });
}
