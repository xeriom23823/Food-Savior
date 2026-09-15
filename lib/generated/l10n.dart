// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `食物救世主`
  String get title {
    return Intl.message('食物救世主', name: 'title', desc: '', args: []);
  }

  /// `用戶`
  String get userNavigationBarTitle {
    return Intl.message(
      '用戶',
      name: 'userNavigationBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `圖表`
  String get chartAndStatisticsNavigationBarTitle {
    return Intl.message(
      '圖表',
      name: 'chartAndStatisticsNavigationBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `食物`
  String get foodItemListNavigationBarTitle {
    return Intl.message(
      '食物',
      name: 'foodItemListNavigationBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `紀錄`
  String get usedFoodItemListNavigationBarTitle {
    return Intl.message(
      '紀錄',
      name: 'usedFoodItemListNavigationBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `設定`
  String get settingsNavigationBarTitle {
    return Intl.message(
      '設定',
      name: 'settingsNavigationBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `蔬菜`
  String get foodItemTypeVegetable {
    return Intl.message(
      '蔬菜',
      name: 'foodItemTypeVegetable',
      desc: '',
      args: [],
    );
  }

  /// `水果`
  String get foodItemTypeFruit {
    return Intl.message('水果', name: 'foodItemTypeFruit', desc: '', args: []);
  }

  /// `肉類`
  String get foodItemTypeMeat {
    return Intl.message('肉類', name: 'foodItemTypeMeat', desc: '', args: []);
  }

  /// `蛋奶類`
  String get foodItemTypeEggAndMilk {
    return Intl.message(
      '蛋奶類',
      name: 'foodItemTypeEggAndMilk',
      desc: '',
      args: [],
    );
  }

  /// `海鮮`
  String get foodItemTypeSeafood {
    return Intl.message('海鮮', name: 'foodItemTypeSeafood', desc: '', args: []);
  }

  /// `罐頭`
  String get foodItemTypeCannedFood {
    return Intl.message(
      '罐頭',
      name: 'foodItemTypeCannedFood',
      desc: '',
      args: [],
    );
  }

  /// `熟食`
  String get foodItemTypeCookedFood {
    return Intl.message(
      '熟食',
      name: 'foodItemTypeCookedFood',
      desc: '',
      args: [],
    );
  }

  /// `飲料`
  String get foodItemTypeDrink {
    return Intl.message('飲料', name: 'foodItemTypeDrink', desc: '', args: []);
  }

  /// `零食`
  String get foodItemTypeSnack {
    return Intl.message('零食', name: 'foodItemTypeSnack', desc: '', args: []);
  }

  /// `麵包`
  String get foodItemTypeBread {
    return Intl.message('麵包', name: 'foodItemTypeBread', desc: '', args: []);
  }

  /// `其他`
  String get foodItemTypeOthers {
    return Intl.message('其他', name: 'foodItemTypeOthers', desc: '', args: []);
  }

  /// `新鮮`
  String get foodItemStatusFresh {
    return Intl.message('新鮮', name: 'foodItemStatusFresh', desc: '', args: []);
  }

  /// `快過期`
  String get foodItemStatusNearExpired {
    return Intl.message(
      '快過期',
      name: 'foodItemStatusNearExpired',
      desc: '',
      args: [],
    );
  }

  /// `已過期`
  String get foodItemStatusExpired {
    return Intl.message(
      '已過期',
      name: 'foodItemStatusExpired',
      desc: '',
      args: [],
    );
  }

  /// `已使用`
  String get foodItemStatusConsumed {
    return Intl.message(
      '已使用',
      name: 'foodItemStatusConsumed',
      desc: '',
      args: [],
    );
  }

  /// `已浪費`
  String get foodItemStatusWasted {
    return Intl.message(
      '已浪費',
      name: 'foodItemStatusWasted',
      desc: '',
      args: [],
    );
  }

  /// `未知`
  String get foodItemStatusUnknown {
    return Intl.message(
      '未知',
      name: 'foodItemStatusUnknown',
      desc: '',
      args: [],
    );
  }

  /// `公克`
  String get unitGram {
    return Intl.message('公克', name: 'unitGram', desc: '', args: []);
  }

  /// `毫升`
  String get unitMilliliter {
    return Intl.message('毫升', name: 'unitMilliliter', desc: '', args: []);
  }

  /// `個`
  String get unitPiece {
    return Intl.message('個', name: 'unitPiece', desc: '', args: []);
  }

  /// `食物清單`
  String get foodItemListViewTitle {
    return Intl.message(
      '食物清單',
      name: 'foodItemListViewTitle',
      desc: '',
      args: [],
    );
  }

  /// `編輯`
  String get edit {
    return Intl.message('編輯', name: 'edit', desc: '', args: []);
  }

  /// `過期`
  String get expire {
    return Intl.message('過期', name: 'expire', desc: '', args: []);
  }

  /// `批量使用`
  String get batchUse {
    return Intl.message('批量使用', name: 'batchUse', desc: '', args: []);
  }

  /// `全部使用`
  String get useAll {
    return Intl.message('全部使用', name: 'useAll', desc: '', args: []);
  }

  /// `載入失敗，請重試`
  String get foodItemListError {
    return Intl.message(
      '載入失敗，請重試',
      name: 'foodItemListError',
      desc: '',
      args: [],
    );
  }

  /// `重新整理`
  String get refresh {
    return Intl.message('重新整理', name: 'refresh', desc: '', args: []);
  }

  /// `新增食物`
  String get addFoodItem {
    return Intl.message('新增食物', name: 'addFoodItem', desc: '', args: []);
  }

  /// `名稱`
  String get name {
    return Intl.message('名稱', name: 'name', desc: '', args: []);
  }

  /// `名稱不能為空`
  String get nameCannotBeEmpty {
    return Intl.message(
      '名稱不能為空',
      name: 'nameCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `數量`
  String get quantity {
    return Intl.message('數量', name: 'quantity', desc: '', args: []);
  }

  /// `數量不能為空`
  String get quantityCannotBeEmpty {
    return Intl.message(
      '數量不能為空',
      name: 'quantityCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `數量必須為正數`
  String get quantityMustBePositive {
    return Intl.message(
      '數量必須為正數',
      name: 'quantityMustBePositive',
      desc: '',
      args: [],
    );
  }

  /// `數量必須為數字`
  String get quanityMustBeANumber {
    return Intl.message(
      '數量必須為數字',
      name: 'quanityMustBeANumber',
      desc: '',
      args: [],
    );
  }

  /// `單位`
  String get unit {
    return Intl.message('單位', name: 'unit', desc: '', args: []);
  }

  /// `請選擇單位`
  String get unitCannotBeEmpty {
    return Intl.message('請選擇單位', name: 'unitCannotBeEmpty', desc: '', args: []);
  }

  /// `描述`
  String get description {
    return Intl.message('描述', name: 'description', desc: '', args: []);
  }

  /// `存放日期`
  String get storageDate {
    return Intl.message('存放日期', name: 'storageDate', desc: '', args: []);
  }

  /// `過期日期`
  String get expirationDate {
    return Intl.message('過期日期', name: 'expirationDate', desc: '', args: []);
  }

  /// `取消`
  String get cancel {
    return Intl.message('取消', name: 'cancel', desc: '', args: []);
  }

  /// `已新增`
  String get added {
    return Intl.message('已新增', name: 'added', desc: '', args: []);
  }

  /// `新增`
  String get add {
    return Intl.message('新增', name: 'add', desc: '', args: []);
  }

  /// `編輯食物`
  String get editFoodItem {
    return Intl.message('編輯食物', name: 'editFoodItem', desc: '', args: []);
  }

  /// `已更新`
  String get updated {
    return Intl.message('已更新', name: 'updated', desc: '', args: []);
  }

  /// `儲存`
  String get save {
    return Intl.message('儲存', name: 'save', desc: '', args: []);
  }

  /// `使用食物`
  String get useFoodItem {
    return Intl.message('使用食物', name: 'useFoodItem', desc: '', args: []);
  }

  /// `使用`
  String get use {
    return Intl.message('使用', name: 'use', desc: '', args: []);
  }

  /// `使用日期`
  String get usedDate {
    return Intl.message('使用日期', name: 'usedDate', desc: '', args: []);
  }

  /// `使用者頁面`
  String get userPageTitle {
    return Intl.message('使用者頁面', name: 'userPageTitle', desc: '', args: []);
  }

  /// `設定頁面`
  String get settingsPageTitle {
    return Intl.message('設定頁面', name: 'settingsPageTitle', desc: '', args: []);
  }

  /// `語言`
  String get language {
    return Intl.message('語言', name: 'language', desc: '', args: []);
  }

  /// `黑夜模式`
  String get darkMode {
    return Intl.message('黑夜模式', name: 'darkMode', desc: '', args: []);
  }

  /// `顯示通知`
  String get showNotification {
    return Intl.message('顯示通知', name: 'showNotification', desc: '', args: []);
  }

  /// `註冊失敗`
  String get signUpFailure {
    return Intl.message('註冊失敗', name: 'signUpFailure', desc: '', args: []);
  }

  /// `無效的電子郵件`
  String get invalidEmail {
    return Intl.message('無效的電子郵件', name: 'invalidEmail', desc: '', args: []);
  }

  /// `無效的密碼`
  String get invalidPassword {
    return Intl.message('無效的密碼', name: 'invalidPassword', desc: '', args: []);
  }

  /// `確認密碼`
  String get confirmPassword {
    return Intl.message('確認密碼', name: 'confirmPassword', desc: '', args: []);
  }

  /// `密碼不相符`
  String get passwordsDoNotMatch {
    return Intl.message(
      '密碼不相符',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `註冊`
  String get signUp {
    return Intl.message('註冊', name: 'signUp', desc: '', args: []);
  }

  /// `註冊頁面`
  String get signUpPageTitle {
    return Intl.message('註冊頁面', name: 'signUpPageTitle', desc: '', args: []);
  }

  /// `登入失敗`
  String get logInFailure {
    return Intl.message('登入失敗', name: 'logInFailure', desc: '', args: []);
  }

  /// `登入`
  String get logIn {
    return Intl.message('登入', name: 'logIn', desc: '', args: []);
  }

  /// `使用 Google 登入`
  String get signInWithGoogle {
    return Intl.message(
      '使用 Google 登入',
      name: 'signInWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `建立帳號`
  String get createAccount {
    return Intl.message('建立帳號', name: 'createAccount', desc: '', args: []);
  }

  /// `登入頁面`
  String get loginPageTitle {
    return Intl.message('登入頁面', name: 'loginPageTitle', desc: '', args: []);
  }

  /// `浪費`
  String get wasted {
    return Intl.message('浪費', name: 'wasted', desc: '', args: []);
  }

  /// `使用`
  String get consumed {
    return Intl.message('使用', name: 'consumed', desc: '', args: []);
  }

  /// `今日過期`
  String get expireToday {
    return Intl.message('今日過期', name: 'expireToday', desc: '', args: []);
  }

  /// `已過期`
  String get expired {
    return Intl.message('已過期', name: 'expired', desc: '', args: []);
  }

  /// `數量超過可使用的量`
  String get quantityExceedsAvailable {
    return Intl.message(
      '數量超過可使用的量',
      name: 'quantityExceedsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `天`
  String get days {
    return Intl.message('天', name: 'days', desc: '', args: []);
  }

  /// `圖表與統計`
  String get chartAndStatisticsPageTitle {
    return Intl.message(
      '圖表與統計',
      name: 'chartAndStatisticsPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `食物點數消耗統計`
  String get consumedFoodPointsByType {
    return Intl.message(
      '食物點數消耗統計',
      name: 'consumedFoodPointsByType',
      desc: '',
      args: [],
    );
  }

  /// `食物點數浪費統計`
  String get wastedFoodPointsByType {
    return Intl.message(
      '食物點數浪費統計',
      name: 'wastedFoodPointsByType',
      desc: '',
      args: [],
    );
  }

  /// `每月趨勢`
  String get monthlyTrend {
    return Intl.message('每月趨勢', name: 'monthlyTrend', desc: '', args: []);
  }

  /// `尚無資料`
  String get noData {
    return Intl.message('尚無資料', name: 'noData', desc: '', args: []);
  }

  /// `備份`
  String get backup {
    return Intl.message('備份', name: 'backup', desc: '', args: []);
  }

  /// `還原`
  String get restore {
    return Intl.message('還原', name: 'restore', desc: '', args: []);
  }

  /// `資料備份成功`
  String get backupSuccess {
    return Intl.message('資料備份成功', name: 'backupSuccess', desc: '', args: []);
  }

  /// `備份失敗`
  String get backupFailure {
    return Intl.message('備份失敗', name: 'backupFailure', desc: '', args: []);
  }

  /// `資料還原成功`
  String get restoreSuccess {
    return Intl.message('資料還原成功', name: 'restoreSuccess', desc: '', args: []);
  }

  /// `還原失敗`
  String get restoreFailure {
    return Intl.message('還原失敗', name: 'restoreFailure', desc: '', args: []);
  }

  /// `雲端沒有備份，本機資料未變動`
  String get restoreNoBackup {
    return Intl.message(
      '雲端沒有備份，本機資料未變動',
      name: 'restoreNoBackup',
      desc: '',
      args: [],
    );
  }

  /// `目前無法連線到雲端，請確認網路後再試`
  String get errorOffline {
    return Intl.message(
      '目前無法連線到雲端，請確認網路後再試',
      name: 'errorOffline',
      desc: '',
      args: [],
    );
  }

  /// `連線逾時，請稍後再試`
  String get errorTimeout {
    return Intl.message('連線逾時，請稍後再試', name: 'errorTimeout', desc: '', args: []);
  }

  /// `沒有存取雲端資料的權限`
  String get errorPermissionDenied {
    return Intl.message(
      '沒有存取雲端資料的權限',
      name: 'errorPermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `發生未知錯誤`
  String get errorUnknown {
    return Intl.message('發生未知錯誤', name: 'errorUnknown', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'messages'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
