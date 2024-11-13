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
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
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
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Food Savior`
  String get title {
    return Intl.message(
      'Food Savior',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get userNavigationBarTitle {
    return Intl.message(
      'User',
      name: 'userNavigationBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `Chart`
  String get chartAndStatisticsNavigationBarTitle {
    return Intl.message(
      'Chart',
      name: 'chartAndStatisticsNavigationBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `Food`
  String get foodItemListNavigationBarTitle {
    return Intl.message(
      'Food',
      name: 'foodItemListNavigationBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `Records`
  String get usedFoodItemListNavigationBarTitle {
    return Intl.message(
      'Records',
      name: 'usedFoodItemListNavigationBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsNavigationBarTitle {
    return Intl.message(
      'Settings',
      name: 'settingsNavigationBarTitle',
      desc: '',
      args: [],
    );
  }

  /// `Vegetable`
  String get foodItemTypeVegetable {
    return Intl.message(
      'Vegetable',
      name: 'foodItemTypeVegetable',
      desc: '',
      args: [],
    );
  }

  /// `Fruit`
  String get foodItemTypeFruit {
    return Intl.message(
      'Fruit',
      name: 'foodItemTypeFruit',
      desc: '',
      args: [],
    );
  }

  /// `Meat`
  String get foodItemTypeMeat {
    return Intl.message(
      'Meat',
      name: 'foodItemTypeMeat',
      desc: '',
      args: [],
    );
  }

  /// `Egg and Milk`
  String get foodItemTypeEggAndMilk {
    return Intl.message(
      'Egg and Milk',
      name: 'foodItemTypeEggAndMilk',
      desc: '',
      args: [],
    );
  }

  /// `Seafood`
  String get foodItemTypeSeafood {
    return Intl.message(
      'Seafood',
      name: 'foodItemTypeSeafood',
      desc: '',
      args: [],
    );
  }

  /// `Canned Food`
  String get foodItemTypeCannedFood {
    return Intl.message(
      'Canned Food',
      name: 'foodItemTypeCannedFood',
      desc: '',
      args: [],
    );
  }

  /// `Cooked Food`
  String get foodItemTypeCookedFood {
    return Intl.message(
      'Cooked Food',
      name: 'foodItemTypeCookedFood',
      desc: '',
      args: [],
    );
  }

  /// `Drink`
  String get foodItemTypeDrink {
    return Intl.message(
      'Drink',
      name: 'foodItemTypeDrink',
      desc: '',
      args: [],
    );
  }

  /// `Snack`
  String get foodItemTypeSnack {
    return Intl.message(
      'Snack',
      name: 'foodItemTypeSnack',
      desc: '',
      args: [],
    );
  }

  /// `Bread`
  String get foodItemTypeBread {
    return Intl.message(
      'Bread',
      name: 'foodItemTypeBread',
      desc: '',
      args: [],
    );
  }

  /// `Others`
  String get foodItemTypeOthers {
    return Intl.message(
      'Others',
      name: 'foodItemTypeOthers',
      desc: '',
      args: [],
    );
  }

  /// `Fresh`
  String get foodItemStatusFresh {
    return Intl.message(
      'Fresh',
      name: 'foodItemStatusFresh',
      desc: '',
      args: [],
    );
  }

  /// `Near Expiry`
  String get foodItemStatusNearExpired {
    return Intl.message(
      'Near Expiry',
      name: 'foodItemStatusNearExpired',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get foodItemStatusExpired {
    return Intl.message(
      'Expired',
      name: 'foodItemStatusExpired',
      desc: '',
      args: [],
    );
  }

  /// `Consumed`
  String get foodItemStatusConsumed {
    return Intl.message(
      'Consumed',
      name: 'foodItemStatusConsumed',
      desc: '',
      args: [],
    );
  }

  /// `Wasted`
  String get foodItemStatusWasted {
    return Intl.message(
      'Wasted',
      name: 'foodItemStatusWasted',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get foodItemStatusUnknown {
    return Intl.message(
      'Unknown',
      name: 'foodItemStatusUnknown',
      desc: '',
      args: [],
    );
  }

  /// `gram`
  String get unitGram {
    return Intl.message(
      'gram',
      name: 'unitGram',
      desc: '',
      args: [],
    );
  }

  /// `milliliter`
  String get unitMilliliter {
    return Intl.message(
      'milliliter',
      name: 'unitMilliliter',
      desc: '',
      args: [],
    );
  }

  /// `piece`
  String get unitPiece {
    return Intl.message(
      'piece',
      name: 'unitPiece',
      desc: '',
      args: [],
    );
  }

  /// `Food List`
  String get foodItemListViewTitle {
    return Intl.message(
      'Food List',
      name: 'foodItemListViewTitle',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Expire`
  String get expire {
    return Intl.message(
      'Expire',
      name: 'expire',
      desc: '',
      args: [],
    );
  }

  /// `Batch Use`
  String get batchUse {
    return Intl.message(
      'Batch Use',
      name: 'batchUse',
      desc: '',
      args: [],
    );
  }

  /// `Use All`
  String get useAll {
    return Intl.message(
      'Use All',
      name: 'useAll',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load, please try again`
  String get foodItemListError {
    return Intl.message(
      'Failed to load, please try again',
      name: 'foodItemListError',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `Add Food`
  String get addFoodItem {
    return Intl.message(
      'Add Food',
      name: 'addFoodItem',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Name cannot be empty`
  String get nameCannotBeEmpty {
    return Intl.message(
      'Name cannot be empty',
      name: 'nameCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantity {
    return Intl.message(
      'Quantity',
      name: 'quantity',
      desc: '',
      args: [],
    );
  }

  /// `Quantity cannot be empty`
  String get quantityCannotBeEmpty {
    return Intl.message(
      'Quantity cannot be empty',
      name: 'quantityCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Quantity must be positive`
  String get quantityMustBePositive {
    return Intl.message(
      'Quantity must be positive',
      name: 'quantityMustBePositive',
      desc: '',
      args: [],
    );
  }

  /// `Quantity must be a number`
  String get quanityMustBeANumber {
    return Intl.message(
      'Quantity must be a number',
      name: 'quanityMustBeANumber',
      desc: '',
      args: [],
    );
  }

  /// `Unit`
  String get unit {
    return Intl.message(
      'Unit',
      name: 'unit',
      desc: '',
      args: [],
    );
  }

  /// `Please select a unit`
  String get unitCannotBeEmpty {
    return Intl.message(
      'Please select a unit',
      name: 'unitCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Storage Date`
  String get storageDate {
    return Intl.message(
      'Storage Date',
      name: 'storageDate',
      desc: '',
      args: [],
    );
  }

  /// `Expiration Date`
  String get expirationDate {
    return Intl.message(
      'Expiration Date',
      name: 'expirationDate',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Added`
  String get added {
    return Intl.message(
      'Added',
      name: 'added',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Edit Food`
  String get editFoodItem {
    return Intl.message(
      'Edit Food',
      name: 'editFoodItem',
      desc: '',
      args: [],
    );
  }

  /// `Updated`
  String get updated {
    return Intl.message(
      'Updated',
      name: 'updated',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Use Food`
  String get useFoodItem {
    return Intl.message(
      'Use Food',
      name: 'useFoodItem',
      desc: '',
      args: [],
    );
  }

  /// `Use`
  String get use {
    return Intl.message(
      'Use',
      name: 'use',
      desc: '',
      args: [],
    );
  }

  /// `Used Date`
  String get usedDate {
    return Intl.message(
      'Used Date',
      name: 'usedDate',
      desc: '',
      args: [],
    );
  }

  /// `User Page`
  String get userPageTitle {
    return Intl.message(
      'User Page',
      name: 'userPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Settings Page`
  String get settingsPageTitle {
    return Intl.message(
      'Settings Page',
      name: 'settingsPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message(
      'Dark Mode',
      name: 'darkMode',
      desc: '',
      args: [],
    );
  }

  /// `Show Notification`
  String get showNotification {
    return Intl.message(
      'Show Notification',
      name: 'showNotification',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up Failed`
  String get signUpFailure {
    return Intl.message(
      'Sign Up Failed',
      name: 'signUpFailure',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Email`
  String get invalidEmail {
    return Intl.message(
      'Invalid Email',
      name: 'invalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Password`
  String get invalidPassword {
    return Intl.message(
      'Invalid Password',
      name: 'invalidPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordsDoNotMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signUp {
    return Intl.message(
      'Sign Up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up Page`
  String get signUpPageTitle {
    return Intl.message(
      'Sign Up Page',
      name: 'signUpPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Log In Failed`
  String get logInFailure {
    return Intl.message(
      'Log In Failed',
      name: 'logInFailure',
      desc: '',
      args: [],
    );
  }

  /// `Log In`
  String get logIn {
    return Intl.message(
      'Log In',
      name: 'logIn',
      desc: '',
      args: [],
    );
  }

  /// `Sign In with Google`
  String get signInWithGoogle {
    return Intl.message(
      'Sign In with Google',
      name: 'signInWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Log In Page`
  String get loginPageTitle {
    return Intl.message(
      'Log In Page',
      name: 'loginPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Wasted`
  String get wasted {
    return Intl.message(
      'Wasted',
      name: 'wasted',
      desc: '',
      args: [],
    );
  }

  /// `Consumed`
  String get consumed {
    return Intl.message(
      'Consumed',
      name: 'consumed',
      desc: '',
      args: [],
    );
  }

  /// `Expire Today`
  String get expireToday {
    return Intl.message(
      'Expire Today',
      name: 'expireToday',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get expired {
    return Intl.message(
      'Expired',
      name: 'expired',
      desc: '',
      args: [],
    );
  }

  /// `Quantity exceeds available`
  String get quantityExceedsAvailable {
    return Intl.message(
      'Quantity exceeds available',
      name: 'quantityExceedsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `days`
  String get days {
    return Intl.message(
      'days',
      name: 'days',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'messages'),
      Locale.fromSubtags(languageCode: 'zh'),
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
