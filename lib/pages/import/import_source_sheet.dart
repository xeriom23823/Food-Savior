import 'package:flutter/material.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/theme/app_tokens.dart';

/// 使用者要匯入的單據種類。
enum ImportSource { einvoice, receipt }

/// 匯入來源選擇：掃電子發票，或拍紙本收據。
///
/// 兩條路徑差很多（發票是精確資料、收據是猜的），入口就要講清楚各自的
/// 適用情形，使用者才不會拿沒有二維條碌的收據去掃碼、或拿發票去拍照
/// （einvoice-import 規格「掃描入口」）。
abstract final class ImportSourceSheet {
  static Future<ImportSource?> show(BuildContext context) {
    return showModalBottomSheet<ImportSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final strings = S.of(sheetContext);
        final theme = Theme.of(sheetContext);

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Text(
                  strings.importSourceTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: Text(strings.importSourceEinvoice),
                subtitle: Text(strings.importSourceEinvoiceHint),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImportSource.einvoice),
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text(strings.importSourceReceipt),
                subtitle: Text(strings.importSourceReceiptHint),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImportSource.receipt),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }
}
