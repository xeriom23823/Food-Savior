part of 'import_bloc.dart';

sealed class ImportState extends Equatable {
  const ImportState();

  @override
  List<Object?> get props => const [];
}

final class ImportInitial extends ImportState {
  const ImportInitial();
}

/// 相機不能用。`permission` 決定顯示哪一種說明（拒絕／沒有相機）。
final class ImportPermissionBlocked extends ImportState {
  const ImportPermissionBlocked({required this.permission});

  final ScannerPermission permission;

  @override
  List<Object?> get props => [permission];
}

/// 掃描中。[hasLeftCode]／[hasRightCode] 驅動畫面上的左右碼進度。
final class ImportScanning extends ImportState {
  const ImportScanning({
    this.hasLeftCode = false,
    this.hasRightCode = false,
    this.notice,
  });

  final bool hasLeftCode;
  final bool hasRightCode;

  /// 掃到不相干的碼時的提示（例如左右碼不是同一張）。不是失敗，掃描繼續。
  final ImportNotice? notice;

  @override
  List<Object?> get props => [hasLeftCode, hasRightCode, notice];
}

/// 這張發票先前已匯入過，等使用者決定（einvoice-import 規格）。
final class ImportDuplicateWarning extends ImportState {
  const ImportDuplicateWarning({required this.invoiceNumber});

  final String invoiceNumber;

  @override
  List<Object?> get props => [invoiceNumber];
}

/// 草稿確認中。
final class ImportDrafts extends ImportState {
  const ImportDrafts({
    required this.invoiceNumber,
    required this.drafts,
    this.itemsIncomplete = false,
    this.locations = const [],
    this.now,
  });

  final String invoiceNumber;
  final List<FoodItemDraft> drafts;

  /// 供草稿編輯的存放位置選單用。
  final List<StorageLocation> locations;

  /// 草稿產生當下的時間，供期限快速選項計算相對日期。
  /// 放在 state 而不是讓畫面呼叫 `DateTime.now()`，widget test 才能決定「今天」。
  final DateTime? now;

  /// 實際解析到的品項少於發票宣告的筆數，提醒使用者自行補齊。
  final bool itemsIncomplete;

  /// 會被寫入的草稿。
  List<FoodItemDraft> get importable =>
      drafts.where((draft) => draft.isImportable).toList();

  bool get canSubmit => importable.isNotEmpty;

  ImportDrafts copyWith({List<FoodItemDraft>? drafts}) => ImportDrafts(
        invoiceNumber: invoiceNumber,
        drafts: drafts ?? this.drafts,
        itemsIncomplete: itemsIncomplete,
        locations: locations,
        now: now,
      );

  @override
  List<Object?> get props =>
      [invoiceNumber, drafts, itemsIncomplete, locations, now];
}

final class ImportSubmitting extends ImportState {
  const ImportSubmitting();
}

final class ImportDone extends ImportState {
  const ImportDone({required this.importedCount});

  final int importedCount;

  @override
  List<Object?> get props => [importedCount];
}

/// 解析失敗。[reason] 一對一映射到一個 l10n key（design D12）。
final class ImportFailure extends ImportState {
  const ImportFailure({required this.reason});

  final ParseFailureReason reason;

  @override
  List<Object?> get props => [reason];
}

/// 掃描過程中的非阻斷提示。
enum ImportNotice { codeMismatch }
