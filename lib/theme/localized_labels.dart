import 'package:flutter/widgets.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/expiry_quick_pick.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_list_grouping.dart';
import 'package:food_savior/models/food_item_form_validator.dart';
import 'package:food_savior/models/storage_location.dart';

/// 列舉的顯示名稱一律走這裡（localization 規格）。
///
/// 注意：擴充方法不可命名為 `name`，那會遮蔽 Dart 的 `Enum.name` 並讓 JSON 序列化壞掉。
extension FoodItemTypeLabel on FoodItemType {
  String localizedName(BuildContext context) => switch (this) {
        FoodItemType.vegetable => S.of(context).foodItemTypeVegetable,
        FoodItemType.fruit => S.of(context).foodItemTypeFruit,
        FoodItemType.meat => S.of(context).foodItemTypeMeat,
        FoodItemType.eggAndMilk => S.of(context).foodItemTypeEggAndMilk,
        FoodItemType.seafood => S.of(context).foodItemTypeSeafood,
        FoodItemType.cannedFood => S.of(context).foodItemTypeCannedFood,
        FoodItemType.cookedFood => S.of(context).foodItemTypeCookedFood,
        FoodItemType.drink => S.of(context).foodItemTypeDrink,
        FoodItemType.snack => S.of(context).foodItemTypeSnack,
        FoodItemType.bread => S.of(context).foodItemTypeBread,
        FoodItemType.others => S.of(context).foodItemTypeOthers,
      };
}

extension FoodItemStatusLabel on FoodItemStatus {
  String localizedName(BuildContext context) => switch (this) {
        FoodItemStatus.fresh => S.of(context).foodItemStatusFresh,
        FoodItemStatus.nearExpired => S.of(context).foodItemStatusNearExpired,
        FoodItemStatus.expired => S.of(context).foodItemStatusExpired,
        FoodItemStatus.consumed => S.of(context).foodItemStatusConsumed,
        FoodItemStatus.wasted => S.of(context).foodItemStatusWasted,
        FoodItemStatus.unknownExpiry =>
          S.of(context).foodItemStatusUnknownExpiry,
      };
}

extension UnitLabel on Unit {
  String localizedName(BuildContext context) => switch (this) {
        Unit.gram => S.of(context).unitGram,
        Unit.milliliter => S.of(context).unitMilliliter,
        Unit.piece => S.of(context).unitPiece,
        Unit.pack => S.of(context).unitPack,
        Unit.box => S.of(context).unitBox,
        Unit.bottle => S.of(context).unitBottle,
        Unit.bag => S.of(context).unitBag,
        Unit.can => S.of(context).unitCan,
        Unit.serving => S.of(context).unitServing,
      };
}

extension RemainingFractionLabel on RemainingFraction {
  String localizedName(BuildContext context) => switch (this) {
        RemainingFraction.full => S.of(context).remainingFractionFull,
        RemainingFraction.mostly => S.of(context).remainingFractionMostly,
        RemainingFraction.half => S.of(context).remainingFractionHalf,
        RemainingFraction.low => S.of(context).remainingFractionLow,
        RemainingFraction.almostGone =>
          S.of(context).remainingFractionAlmostGone,
      };
}

extension ExpiryPrecisionLabel on ExpiryPrecision {
  String localizedName(BuildContext context) => switch (this) {
        ExpiryPrecision.exact => S.of(context).expiryPrecisionExact,
        ExpiryPrecision.range => S.of(context).expiryPrecisionRange,
        ExpiryPrecision.monthOnly => S.of(context).expiryPrecisionMonthOnly,
        ExpiryPrecision.unknown => S.of(context).expiryPrecisionUnknown,
      };
}

extension WasteReasonLabel on WasteReason {
  String localizedName(BuildContext context) => switch (this) {
        WasteReason.forgotten => S.of(context).wasteReasonForgotten,
        WasteReason.boughtTooMuch => S.of(context).wasteReasonBoughtTooMuch,
        WasteReason.spoiled => S.of(context).wasteReasonSpoiled,
        WasteReason.disliked => S.of(context).wasteReasonDisliked,
        WasteReason.expiredTooLong => S.of(context).wasteReasonExpiredTooLong,
        WasteReason.other => S.of(context).wasteReasonOther,
      };
}

extension DisposalMethodLabel on DisposalMethod {
  String localizedName(BuildContext context) => switch (this) {
        DisposalMethod.eaten => S.of(context).disposalEaten,
        DisposalMethod.eatenAtRisk => S.of(context).disposalEatenAtRisk,
        DisposalMethod.givenAway => S.of(context).disposalGivenAway,
        DisposalMethod.composted => S.of(context).disposalComposted,
        DisposalMethod.discarded => S.of(context).disposalDiscarded,
      };
}

extension LocationKindLabel on LocationKind {
  String localizedName(BuildContext context) => switch (this) {
        LocationKind.refrigerated => S.of(context).locationKindRefrigerated,
        LocationKind.frozen => S.of(context).locationKindFrozen,
        LocationKind.ambient => S.of(context).locationKindAmbient,
        LocationKind.other => S.of(context).locationKindOther,
      };
}

extension UrgencyBucketLabel on UrgencyBucket {
  String localizedName(BuildContext context) => switch (this) {
        UrgencyBucket.expired => S.of(context).urgencyExpired,
        UrgencyBucket.today => S.of(context).urgencyToday,
        UrgencyBucket.withinThreeDays => S.of(context).urgencyWithinThreeDays,
        UrgencyBucket.withinWeek => S.of(context).urgencyWithinWeek,
        UrgencyBucket.plenty => S.of(context).urgencyPlenty,
        UrgencyBucket.unknownExpiry => S.of(context).urgencyUnknownExpiry,
      };
}

extension FoodListGroupingLabel on FoodListGrouping {
  String localizedName(BuildContext context) => switch (this) {
        FoodListGrouping.urgency => S.of(context).groupByUrgency,
        FoodListGrouping.location => S.of(context).groupByLocation,
        FoodListGrouping.type => S.of(context).groupByType,
      };
}

extension FoodFormErrorLabel on FoodFormError {
  String localizedMessage(BuildContext context) => switch (this) {
        FoodFormError.nameCannotBeEmpty => S.of(context).nameCannotBeEmpty,
        FoodFormError.amountCannotBeEmpty => S.of(context).amountCannotBeEmpty,
        FoodFormError.amountMustBeANumber => S.of(context).amountMustBeANumber,
        FoodFormError.amountMustBePositive =>
          S.of(context).amountMustBePositive,
        FoodFormError.unitCannotBeEmpty => S.of(context).unitCannotBeEmpty,
        FoodFormError.expiryRangeInvalid => S.of(context).expiryRangeInvalid,
        FoodFormError.priceMustBeNonNegative =>
          S.of(context).priceMustBeNonNegative,
        FoodFormError.amountExceedsAvailable =>
          S.of(context).amountExceedsAvailable,
      };
}

extension ExpiryQuickPickLabel on ExpiryQuickPick {
  String localizedName(BuildContext context) => switch (this) {
        ExpiryQuickPick.today => S.of(context).expiryQuickToday,
        ExpiryQuickPick.tomorrow => S.of(context).expiryQuickTomorrow,
        ExpiryQuickPick.threeDays => S.of(context).expiryQuickThreeDays,
        ExpiryQuickPick.oneWeek => S.of(context).expiryQuickOneWeek,
        ExpiryQuickPick.twoWeeks => S.of(context).expiryQuickTwoWeeks,
        ExpiryQuickPick.oneMonth => S.of(context).expiryQuickOneMonth,
      };
}
