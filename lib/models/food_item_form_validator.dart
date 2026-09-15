import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';

/// 表單錯誤。值就是 l10n key，頁面只負責把它翻成文字（design D6）。
enum FoodFormError {
  nameCannotBeEmpty,
  amountCannotBeEmpty,
  amountMustBeANumber,
  amountMustBePositive,
  unitCannotBeEmpty,
  expiryRangeInvalid,
  priceMustBeNonNegative,
  amountExceedsAvailable,
}

/// 新增／編輯食物的驗證（food-inventory 規格）。
///
/// 除名稱與份量外全部選填：欄位變多了，但「存得下去」不能因此變難。
class FoodItemFormValidator {
  const FoodItemFormValidator();

  FoodFormError? validateName(String name) =>
      name.trim().isEmpty ? FoodFormError.nameCannotBeEmpty : null;

  /// [rawAmount] 是使用者輸入的原始字串；以比例記錄時傳入 [remainingFraction]。
  FoodFormError? validateAmount({
    required String rawAmount,
    required Unit? unit,
    RemainingFraction? remainingFraction,
  }) {
    final trimmed = rawAmount.trim();
    if (trimmed.isEmpty) {
      return remainingFraction == null
          ? FoodFormError.amountCannotBeEmpty
          : null;
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null) return FoodFormError.amountMustBeANumber;
    if (parsed <= 0) return FoodFormError.amountMustBePositive;
    if (unit == null) return FoodFormError.unitCannotBeEmpty;
    return null;
  }

  FoodFormError? validateExpiry(ExpiryValue expiry) {
    final earliest = expiry.earliest;
    final latest = expiry.latest;
    if (expiry.precision != ExpiryPrecision.range) return null;
    if (earliest == null || latest == null) return null;
    return latest.isBefore(earliest) ? FoodFormError.expiryRangeInvalid : null;
  }

  FoodFormError? validatePrice(String rawPrice) {
    final trimmed = rawPrice.trim();
    if (trimmed.isEmpty) return null;
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return FoodFormError.priceMustBeNonNegative;
    }
    return null;
  }

  /// 部分處理：食用與丟棄份量至少其一大於 0，合計不得超過現有份量。
  FoodFormError? validatePortion({
    required String rawConsumed,
    required String rawWasted,
    required double? available,
  }) {
    final consumed = _parsePortion(rawConsumed);
    final wasted = _parsePortion(rawWasted);
    if (consumed == null || wasted == null) {
      return FoodFormError.amountMustBeANumber;
    }
    if (consumed == 0 && wasted == 0) return FoodFormError.amountCannotBeEmpty;
    if (consumed < 0 || wasted < 0) return FoodFormError.amountMustBePositive;
    if (available != null && consumed + wasted > available) {
      return FoodFormError.amountExceedsAvailable;
    }
    return null;
  }

  double? _parsePortion(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 0;
    return double.tryParse(trimmed);
  }
}
