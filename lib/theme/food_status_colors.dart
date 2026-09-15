import 'package:flutter/material.dart';
import 'package:food_savior/models/food_item.dart';

/// 食物狀態的語意色（design D2）。明暗各一組，每組同時提供前景與容器色。
///
/// 任何呈現狀態的地方都必須同時有圖示或文字，不得只靠顏色。
@immutable
class FoodStatusColors extends ThemeExtension<FoodStatusColors> {
  const FoodStatusColors({
    required this.fresh,
    required this.onFresh,
    required this.freshContainer,
    required this.nearExpired,
    required this.onNearExpired,
    required this.nearExpiredContainer,
    required this.expired,
    required this.onExpired,
    required this.expiredContainer,
    required this.consumed,
    required this.onConsumed,
    required this.consumedContainer,
    required this.wasted,
    required this.onWasted,
    required this.wastedContainer,
    required this.unknown,
    required this.onUnknown,
    required this.unknownContainer,
  });

  final Color fresh;
  final Color onFresh;
  final Color freshContainer;
  final Color nearExpired;
  final Color onNearExpired;
  final Color nearExpiredContainer;
  final Color expired;
  final Color onExpired;
  final Color expiredContainer;
  final Color consumed;
  final Color onConsumed;
  final Color consumedContainer;
  final Color wasted;
  final Color onWasted;
  final Color wastedContainer;
  final Color unknown;
  final Color onUnknown;
  final Color unknownContainer;

  static const FoodStatusColors light = FoodStatusColors(
    fresh: Color(0xFF2E7D4F),
    onFresh: Color(0xFFFFFFFF),
    freshContainer: Color(0xFFD7EFE0),
    nearExpired: Color(0xFF9A6400),
    onNearExpired: Color(0xFFFFFFFF),
    nearExpiredContainer: Color(0xFFFCE9C4),
    expired: Color(0xFFB3261E),
    onExpired: Color(0xFFFFFFFF),
    expiredContainer: Color(0xFFF9DEDC),
    consumed: Color(0xFF2E6C8E),
    onConsumed: Color(0xFFFFFFFF),
    consumedContainer: Color(0xFFD6E9F3),
    wasted: Color(0xFF5F6368),
    onWasted: Color(0xFFFFFFFF),
    wastedContainer: Color(0xFFE3E4E6),
    unknown: Color(0xFF6B5E8A),
    onUnknown: Color(0xFFFFFFFF),
    unknownContainer: Color(0xFFE7E1F3),
  );

  static const FoodStatusColors dark = FoodStatusColors(
    fresh: Color(0xFF8ED8A9),
    onFresh: Color(0xFF00351A),
    freshContainer: Color(0xFF1F4A33),
    nearExpired: Color(0xFFF2C05C),
    onNearExpired: Color(0xFF3F2E00),
    nearExpiredContainer: Color(0xFF574200),
    expired: Color(0xFFF2B8B5),
    onExpired: Color(0xFF601410),
    expiredContainer: Color(0xFF8C1D18),
    consumed: Color(0xFF9CCBE4),
    onConsumed: Color(0xFF00344B),
    consumedContainer: Color(0xFF1C4A63),
    wasted: Color(0xFFC4C7CA),
    onWasted: Color(0xFF2B2F31),
    wastedContainer: Color(0xFF42474A),
    unknown: Color(0xFFCCC2E6),
    onUnknown: Color(0xFF362D4D),
    unknownContainer: Color(0xFF4C4267),
  );

  Color of(FoodItemStatus status) => switch (status) {
        FoodItemStatus.fresh => fresh,
        FoodItemStatus.nearExpired => nearExpired,
        FoodItemStatus.expired => expired,
        FoodItemStatus.consumed => consumed,
        FoodItemStatus.wasted => wasted,
        FoodItemStatus.unknownExpiry => unknown,
      };

  Color onOf(FoodItemStatus status) => switch (status) {
        FoodItemStatus.fresh => onFresh,
        FoodItemStatus.nearExpired => onNearExpired,
        FoodItemStatus.expired => onExpired,
        FoodItemStatus.consumed => onConsumed,
        FoodItemStatus.wasted => onWasted,
        FoodItemStatus.unknownExpiry => onUnknown,
      };

  Color containerOf(FoodItemStatus status) => switch (status) {
        FoodItemStatus.fresh => freshContainer,
        FoodItemStatus.nearExpired => nearExpiredContainer,
        FoodItemStatus.expired => expiredContainer,
        FoodItemStatus.consumed => consumedContainer,
        FoodItemStatus.wasted => wastedContainer,
        FoodItemStatus.unknownExpiry => unknownContainer,
      };

  @override
  FoodStatusColors copyWith({
    Color? fresh,
    Color? onFresh,
    Color? freshContainer,
    Color? nearExpired,
    Color? onNearExpired,
    Color? nearExpiredContainer,
    Color? expired,
    Color? onExpired,
    Color? expiredContainer,
    Color? consumed,
    Color? onConsumed,
    Color? consumedContainer,
    Color? wasted,
    Color? onWasted,
    Color? wastedContainer,
    Color? unknown,
    Color? onUnknown,
    Color? unknownContainer,
  }) {
    return FoodStatusColors(
      fresh: fresh ?? this.fresh,
      onFresh: onFresh ?? this.onFresh,
      freshContainer: freshContainer ?? this.freshContainer,
      nearExpired: nearExpired ?? this.nearExpired,
      onNearExpired: onNearExpired ?? this.onNearExpired,
      nearExpiredContainer: nearExpiredContainer ?? this.nearExpiredContainer,
      expired: expired ?? this.expired,
      onExpired: onExpired ?? this.onExpired,
      expiredContainer: expiredContainer ?? this.expiredContainer,
      consumed: consumed ?? this.consumed,
      onConsumed: onConsumed ?? this.onConsumed,
      consumedContainer: consumedContainer ?? this.consumedContainer,
      wasted: wasted ?? this.wasted,
      onWasted: onWasted ?? this.onWasted,
      wastedContainer: wastedContainer ?? this.wastedContainer,
      unknown: unknown ?? this.unknown,
      onUnknown: onUnknown ?? this.onUnknown,
      unknownContainer: unknownContainer ?? this.unknownContainer,
    );
  }

  @override
  FoodStatusColors lerp(ThemeExtension<FoodStatusColors>? other, double t) {
    if (other is! FoodStatusColors) return this;
    return FoodStatusColors(
      fresh: Color.lerp(fresh, other.fresh, t)!,
      onFresh: Color.lerp(onFresh, other.onFresh, t)!,
      freshContainer: Color.lerp(freshContainer, other.freshContainer, t)!,
      nearExpired: Color.lerp(nearExpired, other.nearExpired, t)!,
      onNearExpired: Color.lerp(onNearExpired, other.onNearExpired, t)!,
      nearExpiredContainer:
          Color.lerp(nearExpiredContainer, other.nearExpiredContainer, t)!,
      expired: Color.lerp(expired, other.expired, t)!,
      onExpired: Color.lerp(onExpired, other.onExpired, t)!,
      expiredContainer:
          Color.lerp(expiredContainer, other.expiredContainer, t)!,
      consumed: Color.lerp(consumed, other.consumed, t)!,
      onConsumed: Color.lerp(onConsumed, other.onConsumed, t)!,
      consumedContainer:
          Color.lerp(consumedContainer, other.consumedContainer, t)!,
      wasted: Color.lerp(wasted, other.wasted, t)!,
      onWasted: Color.lerp(onWasted, other.onWasted, t)!,
      wastedContainer: Color.lerp(wastedContainer, other.wastedContainer, t)!,
      unknown: Color.lerp(unknown, other.unknown, t)!,
      onUnknown: Color.lerp(onUnknown, other.onUnknown, t)!,
      unknownContainer:
          Color.lerp(unknownContainer, other.unknownContainer, t)!,
    );
  }
}

extension FoodStatusColorsX on BuildContext {
  FoodStatusColors get foodStatusColors =>
      Theme.of(this).extension<FoodStatusColors>() ?? FoodStatusColors.light;
}
