import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/receipt_import/receipt_import_bloc.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/pages/import/import_drafts_page.dart';
import 'package:food_savior/services/ocr/receipt_image_picker.dart';
import 'package:food_savior/services/scanner/app_settings_opener.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/widgets/empty_state.dart';

/// 拍攝紙本收據並確認辨識出的品項。
///
/// 相機與相簿是系統介面（`image_picker`），這一頁沒有自己的預覽，
/// 所以不像 `ScanInvoicePage` 需要 `previewBuilder` 注入點。
class ScanReceiptPage extends StatelessWidget {
  const ScanReceiptPage({
    super.key,
    this.settingsOpener = const AppSettingsOpener(),
  });

  /// 權限被永久拒絕時唯一的出路。測試可注入替身。
  final AppSettingsOpener settingsOpener;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return BlocConsumer<ReceiptImportBloc, ReceiptImportState>(
      listenWhen: (previous, current) => current is ReceiptImportDone,
      listener: (context, state) {
        if (state is ReceiptImportDone) {
          Navigator.of(context).pop(state.importedCount);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state is ReceiptImportDrafts
                  ? strings.einvoiceDraftsTitle
                  : strings.receiptScanTitle,
            ),
          ),
          body: SafeArea(child: _body(context, state, strings)),
        );
      },
    );
  }

  Widget _body(BuildContext context, ReceiptImportState state, S strings) {
    return switch (state) {
      ReceiptImportChoosingSource() => const _SourceView(),
      ReceiptImportRecognizing() => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.md),
              Text(
                strings.receiptRecognizing,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ReceiptImportSubmitting() =>
        const Center(child: CircularProgressIndicator()),
      ReceiptImportBlocked(:final reason) => _BlockedView(
          reason: reason,
          settingsOpener: settingsOpener,
        ),
      ReceiptImportEmpty(:final kind) => _EmptyView(kind: kind),
      ReceiptImportDrafts() => ImportDraftsPage(
          drafts: state.drafts,
          locations: state.locations,
          now: state.now ?? DateTime.now(),
          subtitle: strings.receiptDraftsHint,
          onToggle: (index) => context
              .read<ReceiptImportBloc>()
              .add(ReceiptImportDraftToggled(index: index)),
          onChanged: (index, draft) => context
              .read<ReceiptImportBloc>()
              .add(ReceiptImportDraftChanged(index: index, draft: draft)),
          onSubmit: () => context
              .read<ReceiptImportBloc>()
              .add(const ReceiptImportSubmitted()),
        ),
      // 匯入完成的瞬間就會被 listener 關掉這一頁，不需要畫面。
      ReceiptImportDone() => const SizedBox.shrink(),
    };
  }
}

/// 拍照前的提示與兩個來源。
///
/// 提示放在按鈕之前而不是失敗之後：整張入鏡、光線、反光是辨識品質的
/// 決定因素，事後再講就已經浪費了一次拍照。
class _SourceView extends StatelessWidget {
  const _SourceView();

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: strings.receiptTips,
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            onPressed: () => context.read<ReceiptImportBloc>().add(
                const ReceiptImportSourceChosen(ReceiptImageSource.camera)),
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(strings.receiptTakePhoto),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => context.read<ReceiptImportBloc>().add(
                  const ReceiptImportSourceChosen(ReceiptImageSource.gallery),
                ),
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(strings.receiptPickFromGallery),
          ),
        ],
      ),
    );
  }
}

class _BlockedView extends StatelessWidget {
  const _BlockedView({required this.reason, required this.settingsOpener});

  final ReceiptImportBlock reason;
  final AppSettingsOpener settingsOpener;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    // 兩種原因，兩種出口——使用者能做的事不同（receipt-ocr-import 規格）。
    final (icon, title) = switch (reason) {
      ReceiptImportBlock.permissionDenied => (
          Icons.no_photography_outlined,
          strings.receiptPhotoPermissionDenied,
        ),
      ReceiptImportBlock.recognizerNotReady => (
          Icons.hourglass_empty,
          strings.receiptRecognizerNotReady,
        ),
    };

    return EmptyState(
      icon: icon,
      title: title,
      // 不管哪一種原因，都一定要留手動新增的出口，不能把人關在門外。
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (reason == ReceiptImportBlock.permissionDenied)
            FilledButton(
              // 永久拒絕後叫不出權限對話框了，只能把人送到系統設定。
              onPressed: settingsOpener.open,
              child: Text(strings.einvoicePermissionOpenSettings),
            ),
          // 模型還在下載這種事，等一下再試通常就好了。
          if (reason == ReceiptImportBlock.recognizerNotReady)
            FilledButton(
              onPressed: () => context
                  .read<ReceiptImportBloc>()
                  .add(const ReceiptImportRetried()),
              child: Text(strings.receiptRetry),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.einvoiceManualEntry),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.kind});

  final ReceiptImportEmptyKind kind;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    // 「沒有文字」大概是拍到桌子了，重拍就好；
    // 「有文字沒品項」是版面看不懂，重拍不一定有用，手動新增要擺得更近。
    final (icon, title) = switch (kind) {
      ReceiptImportEmptyKind.noText => (
          Icons.image_search_outlined,
          strings.receiptNoTextFound,
        ),
      ReceiptImportEmptyKind.noItems => (
          Icons.receipt_long_outlined,
          strings.receiptNoItemsFound,
        ),
    };

    return EmptyState(
      icon: icon,
      title: title,
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            onPressed: () => context
                .read<ReceiptImportBloc>()
                .add(const ReceiptImportRetried()),
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(strings.receiptRetake),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.einvoiceManualEntry),
          ),
        ],
      ),
    );
  }
}
