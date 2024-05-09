import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'messages_all.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['zh', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations();
  }

  // FoodSaviorPage
  String get title {
    return Intl.message(
      '食物救世主',
      name: 'title',
    );
  }

  String get userNavigationBarTitle {
    return Intl.message(
      '用戶',
      name: 'userNavigationBarTitle',
    );
  }

  String get foodItemListNavigationBarTitle {
    return Intl.message(
      '食物',
      name: 'foodItemListNavigationBarTitle',
    );
  }

  String get usedFoodItemListNavigationBarTitle {
    return Intl.message(
      '紀錄',
      name: 'usedFoodItemListNavigationBarTitle',
    );
  }

  String get settingsNavigationBarTitle {
    return Intl.message(
      '設定',
      name: 'settingsNavigationBarTitle',
    );
  }

  // FoodItem
  String get foodItemTypeVegetable {
    return Intl.message(
      '蔬菜',
      name: 'foodItemTypeVegetable',
    );
  }

  String get foodItemTypeFruit {
    return Intl.message(
      '水果',
      name: 'foodItemTypeFruit',
    );
  }

  String get foodItemTypeMeat {
    return Intl.message(
      '肉類',
      name: 'foodItemTypeMeat',
    );
  }

  String get foodItemTypeEggAndMilk {
    return Intl.message(
      '蛋奶類',
      name: 'foodItemTypeEggAndMilk',
    );
  }

  String get foodItemTypeSeafood {
    return Intl.message(
      '海鮮',
      name: 'foodItemTypeSeafood',
    );
  }

  String get foodItemTypeCannedFood {
    return Intl.message(
      '罐頭',
      name: 'foodItemTypeCannedFood',
    );
  }

  String get foodItemTypeCookedFood {
    return Intl.message(
      '熟食',
      name: 'foodItemTypeCookedFood',
    );
  }

  String get foodItemTypeDrink {
    return Intl.message(
      '飲料',
      name: 'foodItemTypeDrink',
    );
  }

  String get foodItemTypeSnack {
    return Intl.message(
      '零食',
      name: 'foodItemTypeSnack',
    );
  }

  String get foodItemTypeBread {
    return Intl.message(
      '麵包',
      name: 'foodItemTypeBread',
    );
  }

  String get foodItemTypeOthers {
    return Intl.message(
      '其他',
      name: 'foodItemTypeOthers',
    );
  }

  String get foodItemStatusFresh {
    return Intl.message(
      '新鮮',
      name: 'foodItemStatusFresh',
    );
  }

  String get foodItemStatusNearExpired {
    return Intl.message(
      '快過期',
      name: 'foodItemStatusNearExpired',
    );
  }

  String get foodItemStatusExpired {
    return Intl.message(
      '已過期',
      name: 'foodItemStatusExpired',
    );
  }

  String get foodItemStatusConsumed {
    return Intl.message(
      '已使用',
      name: 'foodItemStatusConsumed',
    );
  }

  String get foodItemStatusWasted {
    return Intl.message(
      '已浪費',
      name: 'foodItemStatusWasted',
    );
  }

  String get foodItemStatusUnknown {
    return Intl.message(
      '未知',
      name: 'foodItemStatusUnknown',
    );
  }

  String get unitGram {
    return Intl.message(
      '公克',
      name: 'unitGram',
    );
  }

  String get unitMilliliter {
    return Intl.message(
      '毫升',
      name: 'unitMilliliter',
    );
  }

  String get unitPiece {
    return Intl.message(
      '個',
      name: 'unitPiece',
    );
  }

  // Food Item List Page
  String get foodItemListViewTitle {
    return Intl.message(
      '食物清單',
      name: 'foodItemListViewTitle',
    );
  }

  String get edit {
    return Intl.message(
      '編輯',
      name: 'edit',
    );
  }

  String get expire {
    return Intl.message(
      '過期',
      name: 'expire',
    );
  }

  String get batchUse {
    return Intl.message(
      '批量使用',
      name: 'batchUse',
    );
  }

  String get useAll {
    return Intl.message(
      '全部使用',
      name: 'useAll',
    );
  }

  String get foodItemListError {
    return Intl.message(
      '載入失敗，請重試',
      name: 'foodItemListError',
    );
  }

  String get refresh {
    return Intl.message(
      '重新整理',
      name: 'refresh',
    );
  }

  String get addFoodItem {
    return Intl.message(
      '新增食物',
      name: 'addFoodItem',
    );
  }

  String get name {
    return Intl.message(
      '名稱',
      name: 'name',
    );
  }

  String get nameCannotBeEmpty {
    return Intl.message(
      '名稱不能為空',
      name: 'nameCannotBeEmpty',
    );
  }

  String get quantity {
    return Intl.message(
      '數量',
      name: 'quantity',
    );
  }

  String get quantityCannotBeEmpty {
    return Intl.message(
      '數量不能為空',
      name: 'quantityCannotBeEmpty',
    );
  }

  String get quantityMustBePositive {
    return Intl.message(
      '數量必須為正數',
      name: 'quantityMustBePositive',
    );
  }

  String get quanityMustBeANumber {
    return Intl.message(
      '數量必須為數字',
      name: 'quanityMustBeANumber',
    );
  }

  String get quantityExceedsAvailable {
    return Intl.message(
      '數量超過可用數量',
      name: 'quantityExceedsAvailable',
    );
  }

  String get unit {
    return Intl.message(
      '單位',
      name: 'unit',
    );
  }

  String get unitCannotBeEmpty {
    return Intl.message(
      '請選擇單位',
      name: 'unitCannotBeEmpty',
    );
  }

  String get description {
    return Intl.message(
      '描述',
      name: 'description',
    );
  }

  String get storageDate {
    return Intl.message(
      '存放日期',
      name: 'storageDate',
    );
  }

  String get expirationDate {
    return Intl.message(
      '過期日期',
      name: 'expirationDate',
    );
  }

  String get cancel {
    return Intl.message(
      '取消',
      name: 'cancel',
    );
  }

  String get added {
    return Intl.message(
      '已新增',
      name: 'added',
    );
  }

  String get add {
    return Intl.message(
      '新增',
      name: 'add',
    );
  }

  String get editFoodItem {
    return Intl.message(
      '編輯食物',
      name: 'editFoodItem',
    );
  }

  String get updated {
    return Intl.message(
      '已更新',
      name: 'updated',
    );
  }

  String get wasted {
    return Intl.message(
      '已浪費',
      name: 'wasted',
    );
  }

  String get consumed {
    return Intl.message(
      '已食用',
      name: 'consumed',
    );
  }

  String get save {
    return Intl.message(
      '儲存',
      name: 'save',
    );
  }

  String get useFoodItem {
    return Intl.message(
      '使用食物',
      name: 'useFoodItem',
    );
  }

  String get use {
    return Intl.message(
      '使用',
      name: 'use',
    );
  }

  String get usedDate {
    return Intl.message(
      '使用日期',
      name: 'usedDate',
    );
  }

  // User Page
  String get userPageTitle {
    return Intl.message(
      '使用者頁面',
      name: 'userPageTitle',
    );
  }

  // Settings Page
  String get settingsPageTitle {
    return Intl.message(
      '設定頁面',
      name: 'settingsPageTitle',
    );
  }

  String get language {
    return Intl.message(
      '語言',
      name: 'language',
    );
  }

  String get darkMode {
    return Intl.message(
      '黑夜模式',
      name: 'darkMode',
    );
  }

  String get showNotification {
    return Intl.message(
      '顯示通知',
      name: 'showNotification',
    );
  }

  // Sign up form
  String get signUpFailure {
    return Intl.message(
      '註冊失敗',
      name: 'signUpFailure',
    );
  }

  String get invalidEmail {
    return Intl.message(
      '無效的電子郵件',
      name: 'invalidEmail',
    );
  }

  String get invalidPassword {
    return Intl.message(
      '無效的密碼',
      name: 'invalidPassword',
    );
  }

  String get confirmPassword {
    return Intl.message(
      '確認密碼',
      name: 'confirmPassword',
    );
  }

  String get passwordsDoNotMatch {
    return Intl.message(
      '密碼不相符',
      name: 'passwordsDoNotMatch',
    );
  }

  String get signUp {
    return Intl.message(
      '註冊',
      name: 'signUp',
    );
  }

  String get signUpPageTitle {
    return Intl.message(
      '註冊頁面',
      name: 'signUpPageTitle',
    );
  }

  // Login form
  String get logInFailure {
    return Intl.message(
      '登入失敗',
      name: 'logInFailure',
    );
  }

  String get logIn {
    return Intl.message(
      '登入',
      name: 'logIn',
    );
  }

  String get signInWithGoogle {
    return Intl.message(
      '使用 Google 登入',
      name: 'signInWithGoogle',
    );
  }

  String get createAccount {
    return Intl.message(
      '建立帳號',
      name: 'createAccount',
    );
  }

  String get loginPageTitle {
    return Intl.message(
      '登入頁面',
      name: 'loginPageTitle',
    );
  }
}
