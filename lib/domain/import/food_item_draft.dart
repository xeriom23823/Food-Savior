import 'package:equatable/equatable.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';

/// 匯入流程的中介模型（design D7）。
///
/// 承載「這一列被排除」「這一列沒命中建議、待確認」這些**只存在於匯入流程**的
/// 狀態；直接用 [FoodItem] 會逼我們在正式模型上加匯入專用欄位。
class FoodItemDraft extends Equatable {
  const FoodItemDraft({
    required this.sourceLine,
    required this.name,
    required this.type,
    required this.expiry,
    required this.storageDate,
    this.amount,
    this.unit,
    this.storageLocationId,
    this.priceTotal,
    this.excluded = false,
    this.needsReview = false,
  });

  /// 發票上的原始品名。使用者要能對照著發票看，所以一定要留著。
  final String sourceLine;

  /// 清洗後的名稱，可編輯。
  final String name;

  final FoodItemType type;
  final ExpiryValue expiry;

  /// 存放日期 = 發票開立日期（design D11）。
  final DateTime storageDate;

  final double? amount;
  final Unit? unit;
  final String? storageLocationId;
  final int? priceTotal;

  /// 使用者把這一列排除了（塑膠袋、面紙不是食物）。
  final bool excluded;

  /// 建議機制沒命中，類型與期限是預設值，UI 要標示待確認。
  final bool needsReview;

  /// 可以匯入：沒被排除，且名稱與數量通過既有的欄位要求（food-inventory 規格）。
  bool get isImportable =>
      !excluded && name.trim().isNotEmpty && (amount == null || amount! > 0);

  FoodItemDraft copyWith({
    String? name,
    FoodItemType? type,
    ExpiryValue? expiry,
    double? amount,
    Unit? unit,
    String? storageLocationId,
    int? priceTotal,
    bool? excluded,
    bool? needsReview,
    bool clearStorageLocation = false,
    bool clearAmount = false,
  }) {
    return FoodItemDraft(
      sourceLine: sourceLine,
      name: name ?? this.name,
      type: type ?? this.type,
      expiry: expiry ?? this.expiry,
      storageDate: storageDate,
      // 明確給值優先於 clear 旗標：clear 只負責「沒給值時清成 null」，
      // 與 FoodItem.copyWith 的語意一致。
      amount: amount ?? (clearAmount ? null : this.amount),
      unit: unit ?? this.unit,
      storageLocationId: storageLocationId ??
          (clearStorageLocation ? null : this.storageLocationId),
      priceTotal: priceTotal ?? this.priceTotal,
      excluded: excluded ?? this.excluded,
      needsReview: needsReview ?? this.needsReview,
    );
  }

  /// 轉成正式的 [FoodItem]。id 由呼叫端提供（與既有新增一致，用 uuid）。
  ///
  /// 狀態交給 [FoodItem.withDerivedStatus] 依 [now] 推導，不在這裡自己算。
  FoodItem toFoodItem({required String id, required DateTime now}) {
    return FoodItem(
      id: id,
      name: name.trim(),
      type: type,
      status: FoodItemStatus.unknownExpiry,
      storageDate: storageDate,
      amount: amount,
      unit: unit,
      expiryEarliest: expiry.earliest,
      expiryLatest: expiry.latest,
      expiryPrecision: expiry.precision,
      storageLocationId: storageLocationId,
      priceTotal: priceTotal,
    ).withDerivedStatus(now);
  }

  @override
  List<Object?> get props => [
        sourceLine,
        name,
        type,
        expiry,
        storageDate,
        amount,
        unit,
        storageLocationId,
        priceTotal,
        excluded,
        needsReview,
      ];
}
