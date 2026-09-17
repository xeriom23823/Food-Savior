import 'package:flutter/material.dart';
import 'package:food_savior/domain/import/food_item_draft.dart';
import 'package:food_savior/generated/l10n.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/pages/import/import_draft_sheet.dart';
import 'package:food_savior/theme/app_tokens.dart';
import 'package:food_savior/theme/localized_labels.dart';
import 'package:food_savior/widgets/empty_state.dart';
import 'package:food_savior/widgets/food_type_icon.dart';

/// 草稿確認。**沒有任何一列在使用者按下匯入前寫入**（einvoice-import 規格）。
///
/// 不綁任何 Bloc：發票匯入（`ImportBloc`）與收據匯入（`ReceiptImportBloc`）
/// 共用這一頁，各自把事件接到自己的 Bloc（paper-receipt-ocr 任務 5.3）。
class ImportDraftsPage extends StatelessWidget {
  const ImportDraftsPage({
    super.key,
    required this.drafts,
    required this.locations,
    required this.now,
    required this.onToggle,
    required this.onChanged,
    required this.onSubmit,
    this.itemsIncomplete = false,
    this.subtitle,
  });

  final List<FoodItemDraft> drafts;
  final List<StorageLocation> locations;
  final DateTime now;

  /// 實際解析到的品項少於宣告的筆數，提醒使用者自行補齊。
  final bool itemsIncomplete;

  /// 頁首說明。預設是發票匯入的版本；收據匯入要提醒「辨識可能認錯字」。
  final String? subtitle;

  final ValueChanged<int> onToggle;
  final void Function(int index, FoodItemDraft draft) onChanged;
  final VoidCallback onSubmit;

  List<FoodItemDraft> get _importable =>
      drafts.where((draft) => draft.isImportable).toList();

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);

    if (drafts.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: strings.einvoiceNoDrafts,
        action: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.einvoiceManualEntry),
        ),
      );
    }

    final importable = _importable;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle ?? strings.einvoiceDraftsSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (itemsIncomplete) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  strings.einvoiceItemsIncomplete,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: drafts.length,
            itemBuilder: (context, index) => _DraftTile(
              draft: drafts[index],
              locations: locations,
              now: now,
              onToggle: () => onToggle(index),
              onChanged: (draft) => onChanged(index, draft),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: FilledButton.icon(
              onPressed: importable.isEmpty ? null : onSubmit,
              icon: const Icon(Icons.playlist_add_check),
              label: Text(strings.einvoiceImportAll(importable.length)),
            ),
          ),
        ),
      ],
    );
  }
}

class _DraftTile extends StatelessWidget {
  const _DraftTile({
    required this.draft,
    required this.locations,
    required this.now,
    required this.onToggle,
    required this.onChanged,
  });

  final FoodItemDraft draft;
  final List<StorageLocation> locations;
  final DateTime now;
  final VoidCallback onToggle;
  final ValueChanged<FoodItemDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final muted = draft.excluded;

    return Opacity(
      opacity: muted ? 0.5 : 1,
      child: ListTile(
        leading: FoodTypeIcon(
          type: draft.type,
          size: 24,
          color: muted
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.primary,
        ),
        title: Text(
          draft.name,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: muted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _subtitle(context, strings),
              style: theme.textTheme.bodySmall,
            ),
            // 原始品名一定要看得到，使用者才能對照單據確認我們沒改錯東西。
            Text(
              strings.einvoiceSourceLine(draft.sourceLine),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (draft.needsReview) ...[
              const SizedBox(height: AppSpacing.xs),
              _ReviewChip(label: strings.einvoiceDraftNeedsReview),
            ],
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(
              muted ? Icons.add_circle_outline : Icons.remove_circle_outline),
          tooltip: muted
              ? strings.einvoiceDraftInclude
              : strings.einvoiceDraftExclude,
          onPressed: onToggle,
        ),
        // 已排除的列不開編輯——他已經表示不要這一項了。
        onTap: muted ? null : () => _edit(context),
      ),
    );
  }

  String _subtitle(BuildContext context, S strings) {
    final parts = <String>[
      draft.type.localizedName(context),
      if (draft.amount != null && draft.unit != null)
        '${_formatAmount(draft.amount!)} ${draft.unit!.localizedName(context)}',
      if (draft.priceTotal != null) 'NT\$${draft.priceTotal}',
    ];
    return parts.join('  ·  ');
  }

  static String _formatAmount(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  Future<void> _edit(BuildContext context) async {
    final updated = await ImportDraftSheet.show(
      context,
      draft: draft,
      locations: locations,
      now: now,
    );
    if (updated != null) onChanged(updated);
  }
}

class _ReviewChip extends StatelessWidget {
  const _ReviewChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sm)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}
