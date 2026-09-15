import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/models/expiry.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/food_item_form_validator.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  const validator = FoodItemFormValidator();

  group('名稱', () {
    test('空白名稱被擋下', () {
      expect(validator.validateName('   '), FoodFormError.nameCannotBeEmpty);
    });

    test('有名稱就通過', () {
      expect(validator.validateName('牛奶'), isNull);
    });
  });

  group('份量', () {
    test('份量與剩餘比例都沒填時擋下', () {
      expect(
        validator.validateAmount(rawAmount: '', unit: Unit.piece),
        FoodFormError.amountCannotBeEmpty,
      );
    });

    test('只選了剩餘比例就不需要數字', () {
      expect(
        validator.validateAmount(
          rawAmount: '',
          unit: null,
          remainingFraction: RemainingFraction.half,
        ),
        isNull,
      );
    });

    test('小數是合法的', () {
      expect(
        validator.validateAmount(rawAmount: '0.5', unit: Unit.bottle),
        isNull,
      );
    });

    test('非數字與非正數被擋下', () {
      expect(
        validator.validateAmount(rawAmount: 'abc', unit: Unit.piece),
        FoodFormError.amountMustBeANumber,
      );
      expect(
        validator.validateAmount(rawAmount: '0', unit: Unit.piece),
        FoodFormError.amountMustBePositive,
      );
      expect(
        validator.validateAmount(rawAmount: '-3', unit: Unit.piece),
        FoodFormError.amountMustBePositive,
      );
    });

    test('有數字但沒選單位', () {
      expect(
        validator.validateAmount(rawAmount: '2', unit: null),
        FoodFormError.unitCannotBeEmpty,
      );
    });
  });

  group('期限', () {
    test('區間顛倒時擋下', () {
      final reversed = ExpiryValue.range(daysFromNow(5), daysFromNow(1));

      expect(
          validator.validateExpiry(reversed), FoodFormError.expiryRangeInvalid);
    });

    test('正常區間通過', () {
      final valid = ExpiryValue.range(daysFromNow(1), daysFromNow(5));

      expect(validator.validateExpiry(valid), isNull);
      expect(
          validator.validateExpiry(ExpiryValue.exact(daysFromNow(1))), isNull);
    });

    test('未知期限不是錯誤', () {
      expect(validator.validateExpiry(const ExpiryValue.unknown()), isNull);
    });
  });

  group('金額', () {
    test('留空是合法的（選填）', () {
      expect(validator.validatePrice(''), isNull);
    });

    test('負數與非整數被擋下', () {
      expect(
          validator.validatePrice('-1'), FoodFormError.priceMustBeNonNegative);
      expect(validator.validatePrice('12.5'),
          FoodFormError.priceMustBeNonNegative);
    });
  });

  group('部分處理的份量', () {
    test('兩個都是 0 時擋下', () {
      expect(
        validator.validatePortion(
            rawConsumed: '0', rawWasted: '0', available: 5),
        FoodFormError.amountCannotBeEmpty,
      );
    });

    test('合計超過現有份量', () {
      expect(
        validator.validatePortion(
            rawConsumed: '4', rawWasted: '2', available: 5),
        FoodFormError.amountExceedsAvailable,
      );
    });

    test('合計等於現有份量是合法的', () {
      expect(
        validator.validatePortion(
            rawConsumed: '3', rawWasted: '2', available: 5),
        isNull,
      );
    });

    test('留空視為 0', () {
      expect(
        validator.validatePortion(
            rawConsumed: '2', rawWasted: '', available: 5),
        isNull,
      );
    });
  });
}
