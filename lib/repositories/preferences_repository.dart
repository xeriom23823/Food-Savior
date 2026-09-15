import 'package:food_savior/models/food_list_grouping.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 小型偏好設定（清單分群方式、預設位置是否種過）。
///
/// 不放 Hive：這些是純設定，沒有查詢需求，也不需要跟著備份走。
class PreferencesRepository {
  PreferencesRepository({required SharedPreferences preferences})
      : _preferences = preferences;

  static const String _groupingKey = 'foodList.grouping';
  static const String _seededKey = 'storageLocations.seeded.v1';
  static const String _importedInvoicesKey = 'einvoice.imported';

  /// 已匯入發票號碼的保留上限（design D8）。只是防重複，不需要無限成長。
  static const int importedInvoiceLimit = 200;

  final SharedPreferences _preferences;

  FoodListGrouping get grouping {
    final raw = _preferences.getString(_groupingKey);
    return FoodListGrouping.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => FoodListGrouping.urgency,
    );
  }

  Future<void> setGrouping(FoodListGrouping grouping) =>
      _preferences.setString(_groupingKey, grouping.name);

  /// 使用者刪光預設位置後不該再被種回來，所以種子只跑一次。
  bool get hasSeededLocations => _preferences.getBool(_seededKey) ?? false;

  Future<void> markLocationsSeeded() => _preferences.setBool(_seededKey, true);

  /// 已成功匯入過的發票號碼（design D8）。
  ///
  /// 不放 Hive：純設定性資料、不需查詢，也**不該跟著備份走**——換裝置後重掃
  /// 同一張舊發票是合理行為。
  List<String> get importedInvoiceNumbers =>
      _preferences.getStringList(_importedInvoicesKey) ?? const [];

  bool hasImportedInvoice(String invoiceNumber) =>
      importedInvoiceNumbers.contains(invoiceNumber);

  /// 記下一張已匯入的發票。超過上限時捨棄最舊的（FIFO）。
  Future<void> markInvoiceImported(String invoiceNumber) {
    final current = List<String>.of(importedInvoiceNumbers)
      ..remove(invoiceNumber)
      ..add(invoiceNumber);
    final trimmed = current.length > importedInvoiceLimit
        ? current.sublist(current.length - importedInvoiceLimit)
        : current;
    return _preferences.setStringList(_importedInvoicesKey, trimmed);
  }
}
