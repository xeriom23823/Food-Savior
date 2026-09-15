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

  /// `期限未知`
  String get foodItemStatusUnknownExpiry {
    return Intl.message(
      '期限未知',
      name: 'foodItemStatusUnknownExpiry',
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

  /// `包`
  String get unitPack {
    return Intl.message('包', name: 'unitPack', desc: '', args: []);
  }

  /// `盒`
  String get unitBox {
    return Intl.message('盒', name: 'unitBox', desc: '', args: []);
  }

  /// `瓶`
  String get unitBottle {
    return Intl.message('瓶', name: 'unitBottle', desc: '', args: []);
  }

  /// `袋`
  String get unitBag {
    return Intl.message('袋', name: 'unitBag', desc: '', args: []);
  }

  /// `罐`
  String get unitCan {
    return Intl.message('罐', name: 'unitCan', desc: '', args: []);
  }

  /// `份`
  String get unitServing {
    return Intl.message('份', name: 'unitServing', desc: '', args: []);
  }

  /// `滿的`
  String get remainingFractionFull {
    return Intl.message(
      '滿的',
      name: 'remainingFractionFull',
      desc: '',
      args: [],
    );
  }

  /// `大部分`
  String get remainingFractionMostly {
    return Intl.message(
      '大部分',
      name: 'remainingFractionMostly',
      desc: '',
      args: [],
    );
  }

  /// `約一半`
  String get remainingFractionHalf {
    return Intl.message(
      '約一半',
      name: 'remainingFractionHalf',
      desc: '',
      args: [],
    );
  }

  /// `不多了`
  String get remainingFractionLow {
    return Intl.message(
      '不多了',
      name: 'remainingFractionLow',
      desc: '',
      args: [],
    );
  }

  /// `剩一點`
  String get remainingFractionAlmostGone {
    return Intl.message(
      '剩一點',
      name: 'remainingFractionAlmostGone',
      desc: '',
      args: [],
    );
  }

  /// `確定日期`
  String get expiryPrecisionExact {
    return Intl.message(
      '確定日期',
      name: 'expiryPrecisionExact',
      desc: '',
      args: [],
    );
  }

  /// `大約區間`
  String get expiryPrecisionRange {
    return Intl.message(
      '大約區間',
      name: 'expiryPrecisionRange',
      desc: '',
      args: [],
    );
  }

  /// `只到月份`
  String get expiryPrecisionMonthOnly {
    return Intl.message(
      '只到月份',
      name: 'expiryPrecisionMonthOnly',
      desc: '',
      args: [],
    );
  }

  /// `不知道`
  String get expiryPrecisionUnknown {
    return Intl.message(
      '不知道',
      name: 'expiryPrecisionUnknown',
      desc: '',
      args: [],
    );
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

  /// `部分處理`
  String get batchUse {
    return Intl.message('部分處理', name: 'batchUse', desc: '', args: []);
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

  /// `編輯食物`
  String get editFoodItem {
    return Intl.message('編輯食物', name: 'editFoodItem', desc: '', args: []);
  }

  /// `類型`
  String get foodType {
    return Intl.message('類型', name: 'foodType', desc: '', args: []);
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

  /// `份量`
  String get amount {
    return Intl.message('份量', name: 'amount', desc: '', args: []);
  }

  /// `請填份量或選剩餘比例`
  String get amountCannotBeEmpty {
    return Intl.message(
      '請填份量或選剩餘比例',
      name: 'amountCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `份量必須大於 0`
  String get amountMustBePositive {
    return Intl.message(
      '份量必須大於 0',
      name: 'amountMustBePositive',
      desc: '',
      args: [],
    );
  }

  /// `份量必須是數字`
  String get amountMustBeANumber {
    return Intl.message(
      '份量必須是數字',
      name: 'amountMustBeANumber',
      desc: '',
      args: [],
    );
  }

  /// `超過現有份量`
  String get amountExceedsAvailable {
    return Intl.message(
      '超過現有份量',
      name: 'amountExceedsAvailable',
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

  /// `改用剩餘比例`
  String get recordByFraction {
    return Intl.message('改用剩餘比例', name: 'recordByFraction', desc: '', args: []);
  }

  /// `改用數量`
  String get recordByAmount {
    return Intl.message('改用數量', name: 'recordByAmount', desc: '', args: []);
  }

  /// `描述`
  String get description {
    return Intl.message('描述', name: 'description', desc: '', args: []);
  }

  /// `存放日期`
  String get storageDate {
    return Intl.message('存放日期', name: 'storageDate', desc: '', args: []);
  }

  /// `到期日期`
  String get expirationDate {
    return Intl.message('到期日期', name: 'expirationDate', desc: '', args: []);
  }

  /// `最早`
  String get expiryEarliest {
    return Intl.message('最早', name: 'expiryEarliest', desc: '', args: []);
  }

  /// `最晚`
  String get expiryLatest {
    return Intl.message('最晚', name: 'expiryLatest', desc: '', args: []);
  }

  /// `最晚日期不能早於最早日期`
  String get expiryRangeInvalid {
    return Intl.message(
      '最晚日期不能早於最早日期',
      name: 'expiryRangeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `期限未知`
  String get expiryUnknown {
    return Intl.message('期限未知', name: 'expiryUnknown', desc: '', args: []);
  }

  /// `待補期限`
  String get pendingExpiry {
    return Intl.message('待補期限', name: 'pendingExpiry', desc: '', args: []);
  }

  /// `補期限`
  String get fillExpiry {
    return Intl.message('補期限', name: 'fillExpiry', desc: '', args: []);
  }

  /// `今日到期`
  String get expireToday {
    return Intl.message('今日到期', name: 'expireToday', desc: '', args: []);
  }

  /// `已過期`
  String get expired {
    return Intl.message('已過期', name: 'expired', desc: '', args: []);
  }

  /// `天`
  String get days {
    return Intl.message('天', name: 'days', desc: '', args: []);
  }

  /// `已開封`
  String get opened {
    return Intl.message('已開封', name: 'opened', desc: '', args: []);
  }

  /// `標記開封`
  String get markOpened {
    return Intl.message('標記開封', name: 'markOpened', desc: '', args: []);
  }

  /// `開封日期`
  String get openedDate {
    return Intl.message('開封日期', name: 'openedDate', desc: '', args: []);
  }

  /// `開封後可放（天）`
  String get shelfLifeAfterOpen {
    return Intl.message(
      '開封後可放（天）',
      name: 'shelfLifeAfterOpen',
      desc: '',
      args: [],
    );
  }

  /// `金額（元）`
  String get price {
    return Intl.message('金額（元）', name: 'price', desc: '', args: []);
  }

  /// `選填`
  String get priceOptional {
    return Intl.message('選填', name: 'priceOptional', desc: '', args: []);
  }

  /// `金額必須是 0 或正整數`
  String get priceMustBeNonNegative {
    return Intl.message(
      '金額必須是 0 或正整數',
      name: 'priceMustBeNonNegative',
      desc: '',
      args: [],
    );
  }

  /// `存放位置`
  String get storageLocation {
    return Intl.message('存放位置', name: 'storageLocation', desc: '', args: []);
  }

  /// `存放位置`
  String get storageLocations {
    return Intl.message('存放位置', name: 'storageLocations', desc: '', args: []);
  }

  /// `未指定位置`
  String get noLocation {
    return Intl.message('未指定位置', name: 'noLocation', desc: '', args: []);
  }

  /// `位置名稱不能為空`
  String get locationNameCannotBeEmpty {
    return Intl.message(
      '位置名稱不能為空',
      name: 'locationNameCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `新增位置`
  String get addLocation {
    return Intl.message('新增位置', name: 'addLocation', desc: '', args: []);
  }

  /// `編輯位置`
  String get editLocation {
    return Intl.message('編輯位置', name: 'editLocation', desc: '', args: []);
  }

  /// `刪除位置`
  String get deleteLocation {
    return Intl.message('刪除位置', name: 'deleteLocation', desc: '', args: []);
  }

  /// `冷藏`
  String get locationKindRefrigerated {
    return Intl.message(
      '冷藏',
      name: 'locationKindRefrigerated',
      desc: '',
      args: [],
    );
  }

  /// `冷凍`
  String get locationKindFrozen {
    return Intl.message('冷凍', name: 'locationKindFrozen', desc: '', args: []);
  }

  /// `常溫`
  String get locationKindAmbient {
    return Intl.message('常溫', name: 'locationKindAmbient', desc: '', args: []);
  }

  /// `其他`
  String get locationKindOther {
    return Intl.message('其他', name: 'locationKindOther', desc: '', args: []);
  }

  /// `冷藏`
  String get defaultLocationRefrigerated {
    return Intl.message(
      '冷藏',
      name: 'defaultLocationRefrigerated',
      desc: '',
      args: [],
    );
  }

  /// `冷凍`
  String get defaultLocationFrozen {
    return Intl.message(
      '冷凍',
      name: 'defaultLocationFrozen',
      desc: '',
      args: [],
    );
  }

  /// `常溫`
  String get defaultLocationAmbient {
    return Intl.message(
      '常溫',
      name: 'defaultLocationAmbient',
      desc: '',
      args: [],
    );
  }

  /// `快速新增`
  String get quickAdd {
    return Intl.message('快速新增', name: 'quickAdd', desc: '', args: []);
  }

  /// `輸入名稱就能存，細節之後再補`
  String get quickAddHint {
    return Intl.message(
      '輸入名稱就能存，細節之後再補',
      name: 'quickAddHint',
      desc: '',
      args: [],
    );
  }

  /// `分群`
  String get grouping {
    return Intl.message('分群', name: 'grouping', desc: '', args: []);
  }

  /// `依到期急迫度`
  String get groupByUrgency {
    return Intl.message('依到期急迫度', name: 'groupByUrgency', desc: '', args: []);
  }

  /// `依存放位置`
  String get groupByLocation {
    return Intl.message('依存放位置', name: 'groupByLocation', desc: '', args: []);
  }

  /// `依食物類型`
  String get groupByType {
    return Intl.message('依食物類型', name: 'groupByType', desc: '', args: []);
  }

  /// `已過期`
  String get urgencyExpired {
    return Intl.message('已過期', name: 'urgencyExpired', desc: '', args: []);
  }

  /// `今天到期`
  String get urgencyToday {
    return Intl.message('今天到期', name: 'urgencyToday', desc: '', args: []);
  }

  /// `3 天內`
  String get urgencyWithinThreeDays {
    return Intl.message(
      '3 天內',
      name: 'urgencyWithinThreeDays',
      desc: '',
      args: [],
    );
  }

  /// `一週內`
  String get urgencyWithinWeek {
    return Intl.message('一週內', name: 'urgencyWithinWeek', desc: '', args: []);
  }

  /// `充裕`
  String get urgencyPlenty {
    return Intl.message('充裕', name: 'urgencyPlenty', desc: '', args: []);
  }

  /// `期限未知`
  String get urgencyUnknownExpiry {
    return Intl.message(
      '期限未知',
      name: 'urgencyUnknownExpiry',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get cancel {
    return Intl.message('取消', name: 'cancel', desc: '', args: []);
  }

  /// `確認`
  String get confirm {
    return Intl.message('確認', name: 'confirm', desc: '', args: []);
  }

  /// `刪除`
  String get delete {
    return Intl.message('刪除', name: 'delete', desc: '', args: []);
  }

  /// `已新增`
  String get added {
    return Intl.message('已新增', name: 'added', desc: '', args: []);
  }

  /// `新增`
  String get add {
    return Intl.message('新增', name: 'add', desc: '', args: []);
  }

  /// `已更新`
  String get updated {
    return Intl.message('已更新', name: 'updated', desc: '', args: []);
  }

  /// `已刪除`
  String get deleted {
    return Intl.message('已刪除', name: 'deleted', desc: '', args: []);
  }

  /// `儲存`
  String get save {
    return Intl.message('儲存', name: 'save', desc: '', args: []);
  }

  /// `關閉`
  String get close {
    return Intl.message('關閉', name: 'close', desc: '', args: []);
  }

  /// `詳細資料`
  String get details {
    return Intl.message('詳細資料', name: 'details', desc: '', args: []);
  }

  /// `使用食物`
  String get useFoodItem {
    return Intl.message('使用食物', name: 'useFoodItem', desc: '', args: []);
  }

  /// `使用`
  String get use {
    return Intl.message('使用', name: 'use', desc: '', args: []);
  }

  /// `丟棄`
  String get waste {
    return Intl.message('丟棄', name: 'waste', desc: '', args: []);
  }

  /// `使用日期`
  String get usedDate {
    return Intl.message('使用日期', name: 'usedDate', desc: '', args: []);
  }

  /// `食用份量`
  String get consumedAmount {
    return Intl.message('食用份量', name: 'consumedAmount', desc: '', args: []);
  }

  /// `丟棄份量`
  String get wastedAmount {
    return Intl.message('丟棄份量', name: 'wastedAmount', desc: '', args: []);
  }

  /// `剩餘`
  String get remaining {
    return Intl.message('剩餘', name: 'remaining', desc: '', args: []);
  }

  /// `處理方式`
  String get disposalMethod {
    return Intl.message('處理方式', name: 'disposalMethod', desc: '', args: []);
  }

  /// `吃掉`
  String get disposalEaten {
    return Intl.message('吃掉', name: 'disposalEaten', desc: '', args: []);
  }

  /// `過期後吃掉`
  String get disposalEatenAtRisk {
    return Intl.message(
      '過期後吃掉',
      name: 'disposalEatenAtRisk',
      desc: '',
      args: [],
    );
  }

  /// `送人`
  String get disposalGivenAway {
    return Intl.message('送人', name: 'disposalGivenAway', desc: '', args: []);
  }

  /// `堆肥`
  String get disposalComposted {
    return Intl.message('堆肥', name: 'disposalComposted', desc: '', args: []);
  }

  /// `丟棄`
  String get disposalDiscarded {
    return Intl.message('丟棄', name: 'disposalDiscarded', desc: '', args: []);
  }

  /// `浪費原因`
  String get wasteReason {
    return Intl.message('浪費原因', name: 'wasteReason', desc: '', args: []);
  }

  /// `忘記吃`
  String get wasteReasonForgotten {
    return Intl.message(
      '忘記吃',
      name: 'wasteReasonForgotten',
      desc: '',
      args: [],
    );
  }

  /// `買太多`
  String get wasteReasonBoughtTooMuch {
    return Intl.message(
      '買太多',
      name: 'wasteReasonBoughtTooMuch',
      desc: '',
      args: [],
    );
  }

  /// `壞掉了`
  String get wasteReasonSpoiled {
    return Intl.message('壞掉了', name: 'wasteReasonSpoiled', desc: '', args: []);
  }

  /// `不好吃`
  String get wasteReasonDisliked {
    return Intl.message('不好吃', name: 'wasteReasonDisliked', desc: '', args: []);
  }

  /// `放到過期太久`
  String get wasteReasonExpiredTooLong {
    return Intl.message(
      '放到過期太久',
      name: 'wasteReasonExpiredTooLong',
      desc: '',
      args: [],
    );
  }

  /// `其他`
  String get wasteReasonOther {
    return Intl.message('其他', name: 'wasteReasonOther', desc: '', args: []);
  }

  /// `未填原因`
  String get noWasteReason {
    return Intl.message('未填原因', name: 'noWasteReason', desc: '', args: []);
  }

  /// `略過`
  String get skip {
    return Intl.message('略過', name: 'skip', desc: '', args: []);
  }

  /// `食物點數`
  String get foodPoints {
    return Intl.message('食物點數', name: 'foodPoints', desc: '', args: []);
  }

  /// `今天的加分已達上限，休息一下也很好`
  String get dailyFoodPointsCapReached {
    return Intl.message(
      '今天的加分已達上限，休息一下也很好',
      name: 'dailyFoodPointsCapReached',
      desc: '',
      args: [],
    );
  }

  /// `點數規則自 2026-09-15 起改為依時效加權`
  String get pointsRuleChanged {
    return Intl.message(
      '點數規則自 2026-09-15 起改為依時效加權',
      name: 'pointsRuleChanged',
      desc: '',
      args: [],
    );
  }

  /// `全部`
  String get filterAll {
    return Intl.message('全部', name: 'filterAll', desc: '', args: []);
  }

  /// `食用`
  String get filterConsumed {
    return Intl.message('食用', name: 'filterConsumed', desc: '', args: []);
  }

  /// `浪費`
  String get filterWasted {
    return Intl.message('浪費', name: 'filterWasted', desc: '', args: []);
  }

  /// `我的`
  String get userPageTitle {
    return Intl.message('我的', name: 'userPageTitle', desc: '', args: []);
  }

  /// `設定頁面`
  String get settingsPageTitle {
    return Intl.message('設定頁面', name: 'settingsPageTitle', desc: '', args: []);
  }

  /// `偏好設定`
  String get settingsSection {
    return Intl.message('偏好設定', name: 'settingsSection', desc: '', args: []);
  }

  /// `關於`
  String get aboutSection {
    return Intl.message('關於', name: 'aboutSection', desc: '', args: []);
  }

  /// `版本`
  String get version {
    return Intl.message('版本', name: 'version', desc: '', args: []);
  }

  /// `開放原始碼`
  String get openSource {
    return Intl.message('開放原始碼', name: 'openSource', desc: '', args: []);
  }

  /// `在 GitHub 上查看`
  String get viewOnGitHub {
    return Intl.message(
      '在 GitHub 上查看',
      name: 'viewOnGitHub',
      desc: '',
      args: [],
    );
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

  /// `圖表與統計`
  String get chartAndStatisticsPageTitle {
    return Intl.message(
      '圖表與統計',
      name: 'chartAndStatisticsPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `食用筆數分布`
  String get consumedFoodByType {
    return Intl.message(
      '食用筆數分布',
      name: 'consumedFoodByType',
      desc: '',
      args: [],
    );
  }

  /// `浪費筆數分布`
  String get wastedFoodByType {
    return Intl.message('浪費筆數分布', name: 'wastedFoodByType', desc: '', args: []);
  }

  /// `每月趨勢`
  String get monthlyTrend {
    return Intl.message('每月趨勢', name: 'monthlyTrend', desc: '', args: []);
  }

  /// `浪費率趨勢`
  String get statisticsWasteRate {
    return Intl.message(
      '浪費率趨勢',
      name: 'statisticsWasteRate',
      desc: '',
      args: [],
    );
  }

  /// `最常浪費的食物`
  String get statisticsTopWasted {
    return Intl.message(
      '最常浪費的食物',
      name: 'statisticsTopWasted',
      desc: '',
      args: [],
    );
  }

  /// `浪費原因分佈`
  String get statisticsWasteReasons {
    return Intl.message(
      '浪費原因分佈',
      name: 'statisticsWasteReasons',
      desc: '',
      args: [],
    );
  }

  /// `金額損益`
  String get statisticsMoney {
    return Intl.message('金額損益', name: 'statisticsMoney', desc: '', args: []);
  }

  /// `救回`
  String get moneySaved {
    return Intl.message('救回', name: 'moneySaved', desc: '', args: []);
  }

  /// `浪費`
  String get moneyLost {
    return Intl.message('浪費', name: 'moneyLost', desc: '', args: []);
  }

  /// `填寫金額後就能看到這裡的統計`
  String get addPriceHint {
    return Intl.message(
      '填寫金額後就能看到這裡的統計',
      name: 'addPriceHint',
      desc: '',
      args: [],
    );
  }

  /// `尚無資料`
  String get noData {
    return Intl.message('尚無資料', name: 'noData', desc: '', args: []);
  }

  /// `過期食物清單`
  String get expiredFoodListTitle {
    return Intl.message(
      '過期食物清單',
      name: 'expiredFoodListTitle',
      desc: '',
      args: [],
    );
  }

  /// `食物資訊`
  String get foodInfo {
    return Intl.message('食物資訊', name: 'foodInfo', desc: '', args: []);
  }

  /// `已食用`
  String get isConsumed {
    return Intl.message('已食用', name: 'isConsumed', desc: '', args: []);
  }

  /// `處理完成`
  String get processComplete {
    return Intl.message('處理完成', name: 'processComplete', desc: '', args: []);
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

  /// `冰箱還空著`
  String get emptyFoodListTitle {
    return Intl.message(
      '冰箱還空著',
      name: 'emptyFoodListTitle',
      desc: '',
      args: [],
    );
  }

  /// `用下面那一行輸入名稱，就能記下第一樣食物`
  String get emptyFoodListDescription {
    return Intl.message(
      '用下面那一行輸入名稱，就能記下第一樣食物',
      name: 'emptyFoodListDescription',
      desc: '',
      args: [],
    );
  }

  /// `這天沒有紀錄`
  String get emptyUsedFoodListTitle {
    return Intl.message(
      '這天沒有紀錄',
      name: 'emptyUsedFoodListTitle',
      desc: '',
      args: [],
    );
  }

  /// `吃掉或丟掉食物後，紀錄會出現在這裡`
  String get emptyUsedFoodListDescription {
    return Intl.message(
      '吃掉或丟掉食物後，紀錄會出現在這裡',
      name: 'emptyUsedFoodListDescription',
      desc: '',
      args: [],
    );
  }

  /// `還沒有存放位置`
  String get emptyLocationsTitle {
    return Intl.message(
      '還沒有存放位置',
      name: 'emptyLocationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `建立「冰箱上層」「儲藏櫃」之類的位置，清單就能依位置分群`
  String get emptyLocationsDescription {
    return Intl.message(
      '建立「冰箱上層」「儲藏櫃」之類的位置，清單就能依位置分群',
      name: 'emptyLocationsDescription',
      desc: '',
      args: [],
    );
  }

  /// `{days} 天後到期`
  String expireInDays(Object days) {
    return Intl.message(
      '$days 天後到期',
      name: 'expireInDays',
      desc: '',
      args: [days],
    );
  }

  /// `約 {days} 天後到期`
  String expireApproximatelyInDays(Object days) {
    return Intl.message(
      '約 $days 天後到期',
      name: 'expireApproximatelyInDays',
      desc: '',
      args: [days],
    );
  }

  /// `已過期 {days} 天`
  String expiredDaysAgo(Object days) {
    return Intl.message(
      '已過期 $days 天',
      name: 'expiredDaysAgo',
      desc: '',
      args: [days],
    );
  }

  /// `{count} 項`
  String itemCount(Object count) {
    return Intl.message('$count 項', name: 'itemCount', desc: '', args: [count]);
  }

  /// `{count} 批`
  String batchCount(Object count) {
    return Intl.message(
      '$count 批',
      name: 'batchCount',
      desc: '',
      args: [count],
    );
  }

  /// `有 {count} 項食物放在這個位置，刪除後它們會歸為「未指定位置」，食物本身不會被刪除。`
  String deleteLocationMessage(Object count) {
    return Intl.message(
      '有 $count 項食物放在這個位置，刪除後它們會歸為「未指定位置」，食物本身不會被刪除。',
      name: 'deleteLocationMessage',
      desc: '',
      args: [count],
    );
  }

  /// `涵蓋率 {percent}%`
  String coverageLabel(Object percent) {
    return Intl.message(
      '涵蓋率 $percent%',
      name: 'coverageLabel',
      desc: '',
      args: [percent],
    );
  }

  /// `開封後 {days} 天`
  String afterOpenDaysLabel(Object days) {
    return Intl.message(
      '開封後 $days 天',
      name: 'afterOpenDaysLabel',
      desc: '',
      args: [days],
    );
  }

  /// `{points} 點`
  String pointsLabel(Object points) {
    return Intl.message(
      '$points 點',
      name: 'pointsLabel',
      desc: '',
      args: [points],
    );
  }

  /// `{amount} 元`
  String priceLabel(Object amount) {
    return Intl.message(
      '$amount 元',
      name: 'priceLabel',
      desc: '',
      args: [amount],
    );
  }

  /// `浪費 {count} 次`
  String wastedCountLabel(Object count) {
    return Intl.message(
      '浪費 $count 次',
      name: 'wastedCountLabel',
      desc: '',
      args: [count],
    );
  }

  /// `我的成績`
  String get myScore {
    return Intl.message('我的成績', name: 'myScore', desc: '', args: []);
  }

  /// `帳號`
  String get accountSection {
    return Intl.message('帳號', name: 'accountSection', desc: '', args: []);
  }

  /// `食物見習生`
  String get levelNoviceName {
    return Intl.message('食物見習生', name: 'levelNoviceName', desc: '', args: []);
  }

  /// `冰箱管理員`
  String get levelKeeperName {
    return Intl.message('冰箱管理員', name: 'levelKeeperName', desc: '', args: []);
  }

  /// `惜食者`
  String get levelSaverName {
    return Intl.message('惜食者', name: 'levelSaverName', desc: '', args: []);
  }

  /// `食物守護者`
  String get levelGuardianName {
    return Intl.message('食物守護者', name: 'levelGuardianName', desc: '', args: []);
  }

  /// `零浪費大師`
  String get levelMasterName {
    return Intl.message('零浪費大師', name: 'levelMasterName', desc: '', args: []);
  }

  /// `累計點數`
  String get totalPoints {
    return Intl.message('累計點數', name: 'totalPoints', desc: '', args: []);
  }

  /// `本週`
  String get weeklyNet {
    return Intl.message('本週', name: 'weeklyNet', desc: '', args: []);
  }

  /// `距上次浪費`
  String get daysSinceLastWaste {
    return Intl.message(
      '距上次浪費',
      name: 'daysSinceLastWaste',
      desc: '',
      args: [],
    );
  }

  /// `已達最高等級`
  String get maxLevelReached {
    return Intl.message('已達最高等級', name: 'maxLevelReached', desc: '', args: []);
  }

  /// `里程碑`
  String get milestones {
    return Intl.message('里程碑', name: 'milestones', desc: '', args: []);
  }

  /// `踏出第一步`
  String get milestoneFirstRecordName {
    return Intl.message(
      '踏出第一步',
      name: 'milestoneFirstRecordName',
      desc: '',
      args: [],
    );
  }

  /// `記下第一樣食物`
  String get milestoneFirstRecordCondition {
    return Intl.message(
      '記下第一樣食物',
      name: 'milestoneFirstRecordCondition',
      desc: '',
      args: [],
    );
  }

  /// `即期救援隊`
  String get milestoneTenRescuesName {
    return Intl.message(
      '即期救援隊',
      name: 'milestoneTenRescuesName',
      desc: '',
      args: [],
    );
  }

  /// `在到期前 3 天內用掉 10 樣食物`
  String get milestoneTenRescuesCondition {
    return Intl.message(
      '在到期前 3 天內用掉 10 樣食物',
      name: 'milestoneTenRescuesCondition',
      desc: '',
      args: [],
    );
  }

  /// `百分達成`
  String get milestoneHundredPointsName {
    return Intl.message(
      '百分達成',
      name: 'milestoneHundredPointsName',
      desc: '',
      args: [],
    );
  }

  /// `累計 100 點`
  String get milestoneHundredPointsCondition {
    return Intl.message(
      '累計 100 點',
      name: 'milestoneHundredPointsCondition',
      desc: '',
      args: [],
    );
  }

  /// `一週零浪費`
  String get milestoneWeekWithoutWasteName {
    return Intl.message(
      '一週零浪費',
      name: 'milestoneWeekWithoutWasteName',
      desc: '',
      args: [],
    );
  }

  /// `連續 7 天沒有浪費`
  String get milestoneWeekWithoutWasteCondition {
    return Intl.message(
      '連續 7 天沒有浪費',
      name: 'milestoneWeekWithoutWasteCondition',
      desc: '',
      args: [],
    );
  }

  /// `一個月零浪費`
  String get milestoneMonthWithoutWasteName {
    return Intl.message(
      '一個月零浪費',
      name: 'milestoneMonthWithoutWasteName',
      desc: '',
      args: [],
    );
  }

  /// `連續 30 天沒有浪費`
  String get milestoneMonthWithoutWasteCondition {
    return Intl.message(
      '連續 30 天沒有浪費',
      name: 'milestoneMonthWithoutWasteCondition',
      desc: '',
      args: [],
    );
  }

  /// `五百俱樂部`
  String get milestoneFiveHundredPointsName {
    return Intl.message(
      '五百俱樂部',
      name: 'milestoneFiveHundredPointsName',
      desc: '',
      args: [],
    );
  }

  /// `累計 500 點`
  String get milestoneFiveHundredPointsCondition {
    return Intl.message(
      '累計 500 點',
      name: 'milestoneFiveHundredPointsCondition',
      desc: '',
      args: [],
    );
  }

  /// `還沒有成績可以看`
  String get emptyScoreTitle {
    return Intl.message(
      '還沒有成績可以看',
      name: 'emptyScoreTitle',
      desc: '',
      args: [],
    );
  }

  /// `記下食物、吃掉它，點數就會開始累積`
  String get emptyScoreDescription {
    return Intl.message(
      '記下食物、吃掉它，點數就會開始累積',
      name: 'emptyScoreDescription',
      desc: '',
      args: [],
    );
  }

  /// `去記第一樣食物`
  String get goToFoodList {
    return Intl.message('去記第一樣食物', name: 'goToFoodList', desc: '', args: []);
  }

  /// `設定名稱`
  String get setName {
    return Intl.message('設定名稱', name: 'setName', desc: '', args: []);
  }

  /// `修改名稱`
  String get editName {
    return Intl.message('修改名稱', name: 'editName', desc: '', args: []);
  }

  /// `名稱不能超過 30 個字`
  String get nameTooLong {
    return Intl.message(
      '名稱不能超過 30 個字',
      name: 'nameTooLong',
      desc: '',
      args: [],
    );
  }

  /// `名稱已更新`
  String get nameUpdated {
    return Intl.message('名稱已更新', name: 'nameUpdated', desc: '', args: []);
  }

  /// `名稱更新失敗`
  String get nameUpdateFailure {
    return Intl.message(
      '名稱更新失敗',
      name: 'nameUpdateFailure',
      desc: '',
      args: [],
    );
  }

  /// `刪除帳號`
  String get deleteAccount {
    return Intl.message('刪除帳號', name: 'deleteAccount', desc: '', args: []);
  }

  /// `帳號與雲端備份會被永久刪除，且無法復原。這台裝置上的食物清單與使用紀錄不會被刪除。`
  String get deleteAccountMessage {
    return Intl.message(
      '帳號與雲端備份會被永久刪除，且無法復原。這台裝置上的食物清單與使用紀錄不會被刪除。',
      name: 'deleteAccountMessage',
      desc: '',
      args: [],
    );
  }

  /// `為了安全，請重新登入後再試一次`
  String get deleteAccountRequiresRecentLogin {
    return Intl.message(
      '為了安全，請重新登入後再試一次',
      name: 'deleteAccountRequiresRecentLogin',
      desc: '',
      args: [],
    );
  }

  /// `刪除帳號失敗`
  String get deleteAccountFailure {
    return Intl.message(
      '刪除帳號失敗',
      name: 'deleteAccountFailure',
      desc: '',
      args: [],
    );
  }

  /// `登出`
  String get logOut {
    return Intl.message('登出', name: 'logOut', desc: '', args: []);
  }

  /// `重設密碼`
  String get resetPassword {
    return Intl.message('重設密碼', name: 'resetPassword', desc: '', args: []);
  }

  /// `忘記密碼？`
  String get forgotPassword {
    return Intl.message('忘記密碼？', name: 'forgotPassword', desc: '', args: []);
  }

  /// `重設密碼的信已寄出，請到信箱查看`
  String get resetPasswordSent {
    return Intl.message(
      '重設密碼的信已寄出，請到信箱查看',
      name: 'resetPasswordSent',
      desc: '',
      args: [],
    );
  }

  /// `無法寄出重設信`
  String get resetPasswordFailure {
    return Intl.message(
      '無法寄出重設信',
      name: 'resetPasswordFailure',
      desc: '',
      args: [],
    );
  }

  /// `電子郵件`
  String get email {
    return Intl.message('電子郵件', name: 'email', desc: '', args: []);
  }

  /// `密碼`
  String get password {
    return Intl.message('密碼', name: 'password', desc: '', args: []);
  }

  /// `歡迎回來`
  String get loginWelcome {
    return Intl.message('歡迎回來', name: 'loginWelcome', desc: '', args: []);
  }

  /// `建立你的帳號`
  String get signUpWelcome {
    return Intl.message('建立你的帳號', name: 'signUpWelcome', desc: '', args: []);
  }

  /// `還沒有帳號？`
  String get noAccountYet {
    return Intl.message('還沒有帳號？', name: 'noAccountYet', desc: '', args: []);
  }

  /// `距下一級還差 {points} 點`
  String pointsToNextLevel(Object points) {
    return Intl.message(
      '距下一級還差 $points 點',
      name: 'pointsToNextLevel',
      desc: '',
      args: [points],
    );
  }

  /// `{days} 天`
  String daysCount(Object days) {
    return Intl.message('$days 天', name: 'daysCount', desc: '', args: [days]);
  }

  /// `{points} 點`
  String signedPoints(Object points) {
    return Intl.message(
      '$points 點',
      name: 'signedPoints',
      desc: '',
      args: [points],
    );
  }

  /// `已達成 {achieved} / {total}`
  String milestoneProgress(Object achieved, Object total) {
    return Intl.message(
      '已達成 $achieved / $total',
      name: 'milestoneProgress',
      desc: '',
      args: [achieved, total],
    );
  }

  /// `掃描發票`
  String get einvoiceScanEntry {
    return Intl.message('掃描發票', name: 'einvoiceScanEntry', desc: '', args: []);
  }

  /// `掃描電子發票`
  String get einvoiceScanTitle {
    return Intl.message(
      '掃描電子發票',
      name: 'einvoiceScanTitle',
      desc: '',
      args: [],
    );
  }

  /// `對準發票證明聯上的兩個二維條碼`
  String get einvoiceScanHint {
    return Intl.message(
      '對準發票證明聯上的兩個二維條碼',
      name: 'einvoiceScanHint',
      desc: '',
      args: [],
    );
  }

  /// `左側條碼：待掃描`
  String get einvoiceLeftCodePending {
    return Intl.message(
      '左側條碼：待掃描',
      name: 'einvoiceLeftCodePending',
      desc: '',
      args: [],
    );
  }

  /// `左側條碼：已取得`
  String get einvoiceLeftCodeDone {
    return Intl.message(
      '左側條碼：已取得',
      name: 'einvoiceLeftCodeDone',
      desc: '',
      args: [],
    );
  }

  /// `右側條碼：待掃描`
  String get einvoiceRightCodePending {
    return Intl.message(
      '右側條碼：待掃描',
      name: 'einvoiceRightCodePending',
      desc: '',
      args: [],
    );
  }

  /// `右側條碼：已取得`
  String get einvoiceRightCodeDone {
    return Intl.message(
      '右側條碼：已取得',
      name: 'einvoiceRightCodeDone',
      desc: '',
      args: [],
    );
  }

  /// `這是另一張發票的條碼，請掃描同一張的另一側`
  String get einvoiceCodeMismatch {
    return Intl.message(
      '這是另一張發票的條碼，請掃描同一張的另一側',
      name: 'einvoiceCodeMismatch',
      desc: '',
      args: [],
    );
  }

  /// `讀不到發票內容，請再試一次`
  String get einvoiceParseFailed {
    return Intl.message(
      '讀不到發票內容，請再試一次',
      name: 'einvoiceParseFailed',
      desc: '',
      args: [],
    );
  }

  /// `這張發票使用的文字編碼無法解讀，請改為手動新增`
  String get einvoiceEncodingUnsupported {
    return Intl.message(
      '這張發票使用的文字編碼無法解讀，請改為手動新增',
      name: 'einvoiceEncodingUnsupported',
      desc: '',
      args: [],
    );
  }

  /// `發票上還有品項沒讀到，請自行補齊`
  String get einvoiceItemsIncomplete {
    return Intl.message(
      '發票上還有品項沒讀到，請自行補齊',
      name: 'einvoiceItemsIncomplete',
      desc: '',
      args: [],
    );
  }

  /// `需要相機權限才能掃描發票`
  String get einvoicePermissionDenied {
    return Intl.message(
      '需要相機權限才能掃描發票',
      name: 'einvoicePermissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `前往設定`
  String get einvoicePermissionOpenSettings {
    return Intl.message(
      '前往設定',
      name: 'einvoicePermissionOpenSettings',
      desc: '',
      args: [],
    );
  }

  /// `這台裝置沒有可用的相機`
  String get einvoiceCameraUnavailable {
    return Intl.message(
      '這台裝置沒有可用的相機',
      name: 'einvoiceCameraUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `改為手動新增`
  String get einvoiceManualEntry {
    return Intl.message(
      '改為手動新增',
      name: 'einvoiceManualEntry',
      desc: '',
      args: [],
    );
  }

  /// `重新掃描`
  String get einvoiceRetry {
    return Intl.message('重新掃描', name: 'einvoiceRetry', desc: '', args: []);
  }

  /// `這張發票已經匯入過了`
  String get einvoiceAlreadyImported {
    return Intl.message(
      '這張發票已經匯入過了',
      name: 'einvoiceAlreadyImported',
      desc: '',
      args: [],
    );
  }

  /// `仍要匯入`
  String get einvoiceImportAnyway {
    return Intl.message(
      '仍要匯入',
      name: 'einvoiceImportAnyway',
      desc: '',
      args: [],
    );
  }

  /// `確認匯入的食物`
  String get einvoiceDraftsTitle {
    return Intl.message(
      '確認匯入的食物',
      name: 'einvoiceDraftsTitle',
      desc: '',
      args: [],
    );
  }

  /// `可以逐項修改或排除，確認後再加入清單`
  String get einvoiceDraftsSubtitle {
    return Intl.message(
      '可以逐項修改或排除，確認後再加入清單',
      name: 'einvoiceDraftsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `待確認`
  String get einvoiceDraftNeedsReview {
    return Intl.message(
      '待確認',
      name: 'einvoiceDraftNeedsReview',
      desc: '',
      args: [],
    );
  }

  /// `已排除`
  String get einvoiceDraftExcluded {
    return Intl.message(
      '已排除',
      name: 'einvoiceDraftExcluded',
      desc: '',
      args: [],
    );
  }

  /// `排除這項`
  String get einvoiceDraftExclude {
    return Intl.message(
      '排除這項',
      name: 'einvoiceDraftExclude',
      desc: '',
      args: [],
    );
  }

  /// `加回這項`
  String get einvoiceDraftInclude {
    return Intl.message(
      '加回這項',
      name: 'einvoiceDraftInclude',
      desc: '',
      args: [],
    );
  }

  /// `發票品名：{name}`
  String einvoiceSourceLine(Object name) {
    return Intl.message(
      '發票品名：$name',
      name: 'einvoiceSourceLine',
      desc: '',
      args: [name],
    );
  }

  /// `全部加入（{count}）`
  String einvoiceImportAll(Object count) {
    return Intl.message(
      '全部加入（$count）',
      name: 'einvoiceImportAll',
      desc: '',
      args: [count],
    );
  }

  /// `已匯入 {count} 項食物`
  String einvoiceImported(Object count) {
    return Intl.message(
      '已匯入 $count 項食物',
      name: 'einvoiceImported',
      desc: '',
      args: [count],
    );
  }

  /// `這張發票沒有可匯入的品項`
  String get einvoiceNoDrafts {
    return Intl.message(
      '這張發票沒有可匯入的品項',
      name: 'einvoiceNoDrafts',
      desc: '',
      args: [],
    );
  }

  /// `掃描功能還在準備中，請稍後再試`
  String get einvoiceScannerNotReady {
    return Intl.message(
      '掃描功能還在準備中，請稍後再試',
      name: 'einvoiceScannerNotReady',
      desc: '',
      args: [],
    );
  }

  /// `今天`
  String get expiryQuickToday {
    return Intl.message('今天', name: 'expiryQuickToday', desc: '', args: []);
  }

  /// `明天`
  String get expiryQuickTomorrow {
    return Intl.message('明天', name: 'expiryQuickTomorrow', desc: '', args: []);
  }

  /// `3 天後`
  String get expiryQuickThreeDays {
    return Intl.message(
      '3 天後',
      name: 'expiryQuickThreeDays',
      desc: '',
      args: [],
    );
  }

  /// `1 週後`
  String get expiryQuickOneWeek {
    return Intl.message('1 週後', name: 'expiryQuickOneWeek', desc: '', args: []);
  }

  /// `2 週後`
  String get expiryQuickTwoWeeks {
    return Intl.message(
      '2 週後',
      name: 'expiryQuickTwoWeeks',
      desc: '',
      args: [],
    );
  }

  /// `1 個月後`
  String get expiryQuickOneMonth {
    return Intl.message(
      '1 個月後',
      name: 'expiryQuickOneMonth',
      desc: '',
      args: [],
    );
  }

  /// `修改這一項`
  String get einvoiceEditDraft {
    return Intl.message('修改這一項', name: 'einvoiceEditDraft', desc: '', args: []);
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
