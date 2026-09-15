import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/domain/einvoice/einvoice.dart';
import 'package:food_savior/domain/einvoice/einvoice_parse_failure.dart';
import 'package:food_savior/domain/einvoice/einvoice_qr_parser.dart';

/// Fixture 驅動（design D3）：官方規格改版時先加 fixture 重現問題，再改實作。
String fixture(String name) =>
    File('test/fixtures/einvoice/$name').readAsStringSync();

EInvoice parseOk(String left, {String? right}) {
  final result = EInvoiceQrParser.parse(left, right: right);
  expect(result, isA<EInvoiceParseSuccess>(), reason: '$result');
  return (result as EInvoiceParseSuccess).invoice;
}

ParseFailureReason parseFail(String left, {String? right}) {
  final result = EInvoiceQrParser.parse(left, right: right);
  expect(result, isA<EInvoiceParseFailure>(), reason: '$result');
  return (result as EInvoiceParseFailure).reason;
}

void main() {
  group('左碼固定欄位', () {
    test('解析發票號碼與民國日期', () {
      final invoice = parseOk(fixture('utf8_left.txt'));

      expect(invoice.invoiceNumber, 'AB12345678');
      expect(invoice.issuedDate, DateTime(2026, 9, 15));
    });

    test('總計額以 16 進位記載', () {
      expect(parseOk(fixture('utf8_left.txt')).totalAmount, 500);
    });

    test('內容太短時回報 tooShort', () {
      expect(parseFail(fixture('too_short.txt')), ParseFailureReason.tooShort);
    });

    test('日期不合法時回報 malformed', () {
      final left = fixture('utf8_left.txt');
      // 民國 115 年 13 月 45 日：長度合法但日期不存在。
      final broken = left.replaceRange(10, 17, '1151345');

      expect(parseFail(broken), ParseFailureReason.malformed);
    });

    test('筆數欄位不是數字時回報 malformed', () {
      final left =
          fixture('utf8_left.txt').replaceFirst(':02:04:1:', ':xx:04:1:');

      expect(parseFail(left), ParseFailureReason.malformed);
    });
  });

  group('品項切割', () {
    test('左碼載明的品項依發票順序解析', () {
      final invoice = parseOk(fixture('utf8_left.txt'));

      expect(invoice.items.map((e) => e.name).toList(), ['牛奶', '雞蛋']);
      expect(invoice.items.first.quantity, 1);
      expect(invoice.items.first.unitPrice, 65);
    });

    test('品名內含冒號時以品目筆數為準，不被 split 切壞', () {
      final invoice = parseOk(fixture('colon_name_left.txt'));

      expect(invoice.items, hasLength(1));
      expect(invoice.items.single.name, '蔬菜:高麗菜');
      expect(invoice.items.single.unitPrice, 45);
    });

    test('小計由數量與單價推算', () {
      final invoice = parseOk(
        fixture('utf8_left.txt'),
        right: fixture('utf8_right.txt'),
      );
      final pork = invoice.items.firstWhere((e) => e.name == '梅花豬肉片');

      expect(pork.quantity, 2);
      expect(pork.unitPrice, 120);
      expect(pork.subtotal, 240);
    });

    test('數量無法解析時該欄為未知，其餘品項不受影響', () {
      final left =
          fixture('utf8_left.txt').replaceFirst(':牛奶:1:65', ':牛奶:abc:65');
      final invoice = parseOk(left);

      expect(invoice.items.first.name, '牛奶');
      expect(invoice.items.first.quantity, isNull);
      expect(invoice.items.first.subtotal, isNull);
      expect(invoice.items.last.name, '雞蛋');
      expect(invoice.items.last.quantity, 1);
    });
  });

  group('左右碼合併', () {
    test('左碼 + 右碼得到完整品項', () {
      final invoice = parseOk(
        fixture('utf8_left.txt'),
        right: fixture('utf8_right.txt'),
      );

      expect(invoice.items.map((e) => e.name).toList(),
          ['牛奶', '雞蛋', '高麗菜', '梅花豬肉片']);
      expect(invoice.isComplete, isTrue);
    });

    test('只有左碼時 isComplete 為 false', () {
      final invoice = parseOk(fixture('partial_left.txt'));

      expect(invoice.items, hasLength(2));
      expect(invoice.declaredItemCount, 4);
      expect(invoice.isComplete, isFalse);
    });

    test('左碼已涵蓋宣告筆數時就算完整', () {
      final invoice = parseOk(fixture('base64_left.txt'));

      expect(invoice.declaredItemCount, 2);
      expect(invoice.isComplete, isTrue);
    });

    test('傳入的右碼不以 ** 起始時回報 codeMismatch', () {
      final reason = parseFail(
        fixture('utf8_left.txt'),
        right: fixture('colon_name_left.txt'),
      );

      expect(reason, ParseFailureReason.codeMismatch);
    });

    test('實際品項少於宣告筆數時照樣回傳已解析的品項', () {
      final invoice = parseOk(
        fixture('short_items_left.txt'),
        right: fixture('short_items_right.txt'),
      );

      expect(invoice.declaredItemCount, 5);
      expect(invoice.items, hasLength(3));
      expect(invoice.isComplete, isFalse);
    });

    test('isRightCode 依 ** 前綴判定', () {
      expect(EInvoiceQrParser.isRightCode(fixture('utf8_right.txt')), isTrue);
      expect(EInvoiceQrParser.isRightCode(fixture('utf8_left.txt')), isFalse);
    });
  });

  group('中文編碼參數', () {
    test('Base64 品名會被解碼', () {
      final invoice = parseOk(fixture('base64_left.txt'));

      expect(invoice.items.map((e) => e.name).toList(),
          ['統一AB優酪乳400ML特價', '量販-雞蛋10入']);
    });

    test('Big5 不猜測解碼結果，回報 unsupportedBig5', () {
      expect(parseFail(fixture('big5_left.txt')),
          ParseFailureReason.unsupportedBig5);
    });

    test('宣告 Base64 但內容不是時退回原字串，不整張失敗', () {
      final left = fixture('base64_left.txt').replaceFirst(
          RegExp(r':[A-Za-z0-9+/=]+:1:32'), ':!!!not-base64!!!:1:32');
      final invoice = parseOk(left);

      expect(invoice.items.first.name, '!!!not-base64!!!');
    });
  });
}
