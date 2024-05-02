import 'package:flutter/widgets.dart';
import 'package:food_savior/app/app.dart';
import 'package:food_savior/login/login.dart';
import 'package:food_savior/main.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppStatus state,
  List<Page<dynamic>> pages,
) {
  switch (state) {
    case AppStatus.authenticated:
      return [FoodSavior.page()];
    case AppStatus.unauthenticated:
      return [LoginPage.page()];
  }
}
