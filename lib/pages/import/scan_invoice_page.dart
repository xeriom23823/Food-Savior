import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/bloc/import/import_bloc.dart';
import 'package:food_savior/domain/einvoice/einvoice_parse_failure.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/services/scanner/app_settings_opener.dart';
import 'package:food_savior/pages/import/import_drafts_page.dart';
import 'package:food_savior/services/scanner/scanner_service.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/widgets/empty_state.dart';

/// 掃描發票。
///
/// [previewBuilder] 是相機預覽的注入點：正式使用時由 `ImportRoute` 傳入
/// `MobileScanner` widget，widget test 傳入一個佔位 widget，測試才不需要相機。
class ScanInvoicePage extends StatelessWidget {
  const ScanInvoicePage({
    super.key,
    required this.previewBuilder,
    this.settingsOpener = const AppSettingsOpener(),
  });

  final WidgetBuilder previewBuilder;

  /// 權限被永久拒絕時唯一的出路。測試可注入替身。
  final AppSettingsOpener settingsOpener;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return BlocConsumer<ImportBloc, ImportState>(
      listenWhen: (previous, current) => current is ImportDone,
      listener: (context, state) {
        if (state is ImportDone) Navigator.of(context).pop(state.importedCount);
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state is ImportDrafts
                  ? strings.einvoiceDraftsTitle
                  : strings.einvoiceScanTitle,
            ),
          ),
          body: SafeArea(child: _body(context, state, strings)),
        );
      },
    );
  }

  Widget _body(BuildContext context, ImportState state, S strings) {
    return switch (state) {
      // 相機預覽必須在這一刻就掛載：`mobile_scanner` 的 autoStart 要等 widget
      // 進入樹才會啟動，而權限結果正是從啟動結果推得的（design D9）。
      ImportInitial() => Stack(
          fit: StackFit.expand,
          children: [
            previewBuilder(context),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      ImportSubmitting() => const Center(child: CircularProgressIndicator()),
      ImportPermissionBlocked(:final permission) => _PermissionBlockedView(
          permission: permission,
          settingsOpener: settingsOpener,
        ),
      ImportScanning() => _ScanningView(
          state: state,
          previewBuilder: previewBuilder,
        ),
      ImportDuplicateWarning() => _DuplicateWarningView(state: state),
      ImportFailure(:final reason) => _FailureView(reason: reason),
      ImportDrafts() => ImportDraftsPage(
          drafts: state.drafts,
          locations: state.locations,
          now: state.now ?? DateTime.now(),
          itemsIncomplete: state.itemsIncomplete,
          onToggle: (index) =>
              context.read<ImportBloc>().add(ImportDraftToggled(index: index)),
          onChanged: (index, draft) => context
              .read<ImportBloc>()
              .add(ImportDraftChanged(index: index, draft: draft)),
          onSubmit: () =>
              context.read<ImportBloc>().add(const ImportSubmitted()),
        ),
      // 匯入完成的瞬間就會被 listener 關掉這一頁，不需要畫面。
      ImportDone() => const SizedBox.shrink(),
    };
  }
}

class _ScanningView extends StatelessWidget {
  const _ScanningView({required this.state, required this.previewBuilder});

  final ImportScanning state;
  final WidgetBuilder previewBuilder;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(child: previewBuilder(context)),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.einvoiceScanHint,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              // 兩個碼都要掃到才有完整品項，所以進度必須看得見。
              _CodeProgress(
                done: state.hasLeftCode,
                label: state.hasLeftCode
                    ? strings.einvoiceLeftCodeDone
                    : strings.einvoiceLeftCodePending,
              ),
              const SizedBox(height: AppSpacing.xs),
              _CodeProgress(
                done: state.hasRightCode,
                label: state.hasRightCode
                    ? strings.einvoiceRightCodeDone
                    : strings.einvoiceRightCodePending,
              ),
              if (state.notice == ImportNotice.codeMismatch) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  strings.einvoiceCodeMismatch,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CodeProgress extends StatelessWidget {
  const _CodeProgress({required this.done, required this.label});

  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        done ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: color,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: color)),
      ],
    );
  }
}

class _PermissionBlockedView extends StatelessWidget {
  const _PermissionBlockedView({
    required this.permission,
    required this.settingsOpener,
  });

  final ScannerPermission permission;
  final AppSettingsOpener settingsOpener;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    // 三種原因，三種出口——使用者能做的事不同（unbundled-scanner-model D2）。
    final (icon, title) = switch (permission) {
      ScannerPermission.denied => (
          Icons.no_photography_outlined,
          strings.einvoicePermissionDenied,
        ),
      ScannerPermission.scannerUnavailable => (
          Icons.hourglass_empty,
          strings.einvoiceScannerNotReady,
        ),
      _ => (
          Icons.videocam_off_outlined,
          strings.einvoiceCameraUnavailable,
        ),
    };

    return EmptyState(
      icon: icon,
      title: title,
      // 不管哪一種原因，都一定要留手動新增的出口，不能把人關在門外。
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (permission == ScannerPermission.denied)
            FilledButton(
              // 永久拒絕後叫不出權限對話框了，只能把人送到系統設定。
              onPressed: settingsOpener.open,
              child: Text(strings.einvoicePermissionOpenSettings),
            ),
          // 模型還在下載這種事，等一下再試通常就好了。
          // 「沒有相機」刻意不給重試——重試無論如何都不會成功。
          if (permission == ScannerPermission.scannerUnavailable)
            FilledButton(
              onPressed: () =>
                  context.read<ImportBloc>().add(const ImportRestarted()),
              child: Text(strings.einvoiceRetry),
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

class _DuplicateWarningView extends StatelessWidget {
  const _DuplicateWarningView({required this.state});

  final ImportDuplicateWarning state;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);

    return EmptyState(
      icon: Icons.replay_outlined,
      title: strings.einvoiceAlreadyImported,
      description: state.invoiceNumber,
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: () => context
                .read<ImportBloc>()
                .add(const ImportDuplicateConfirmed()),
            child: Text(strings.einvoiceImportAnyway),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
        ],
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.reason});

  final ParseFailureReason reason;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final message = switch (reason) {
      ParseFailureReason.unsupportedBig5 => strings.einvoiceEncodingUnsupported,
      _ => strings.einvoiceParseFailed,
    };

    return EmptyState(
      icon: Icons.qr_code_scanner_outlined,
      title: message,
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: () =>
                context.read<ImportBloc>().add(const ImportRestarted()),
            child: Text(strings.einvoiceRetry),
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
