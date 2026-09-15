import 'package:food_savior/models/food_item.dart';

/// 期限的值物件：把「四種精度」收斂成 earliest／latest 兩個日期（design D10）。
///
/// 表單與快速新增都用它建構，[FoodItem] 只存三個扁平欄位給 Hive。
class ExpiryValue {
  const ExpiryValue._(this.earliest, this.latest, this.precision);

  /// 精確到日。
  factory ExpiryValue.exact(DateTime date) {
    final day = dateOnly(date);
    return ExpiryValue._(day, day, ExpiryPrecision.exact);
  }

  /// 區間（「大約 3〜5 天後」）。
  ///
  /// 刻意**不**自動對調順序：顛倒的區間是使用者的輸入錯誤，
  /// 應該由驗證器告訴他，而不是靜靜地改掉他填的東西。
  factory ExpiryValue.range(DateTime from, DateTime to) =>
      ExpiryValue._(dateOnly(from), dateOnly(to), ExpiryPrecision.range);

  /// 只知道月份：涵蓋該月 1 日到月底。
  factory ExpiryValue.month(int year, int month) {
    final first = DateTime(year, month);
    final last = DateTime(year, month + 1, 0);
    return ExpiryValue._(first, last, ExpiryPrecision.monthOnly);
  }

  /// 完全不知道。照樣可以入庫，之後再補。
  const ExpiryValue.unknown()
      : earliest = null,
        latest = null,
        precision = ExpiryPrecision.unknown;

  /// 從既有項目讀回，供編輯表單使用。
  factory ExpiryValue.of(FoodItem item) => ExpiryValue._(
        item.expiryEarliest,
        item.expiryLatest,
        item.expiryPrecision,
      );

  final DateTime? earliest;
  final DateTime? latest;
  final ExpiryPrecision precision;

  bool get isKnown => precision != ExpiryPrecision.unknown;

  /// 是否為近似期限（區間或只到月）。UI 要用不同語氣呈現。
  bool get isApproximate =>
      precision == ExpiryPrecision.range ||
      precision == ExpiryPrecision.monthOnly;

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  bool operator ==(Object other) =>
      other is ExpiryValue &&
      other.earliest == earliest &&
      other.latest == latest &&
      other.precision == precision;

  @override
  int get hashCode => Object.hash(earliest, latest, precision);
}
