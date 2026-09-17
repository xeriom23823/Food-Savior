part of 'receipt_import_bloc.dart';

sealed class ReceiptImportState extends Equatable {
  const ReceiptImportState();

  @override
  List<Object?> get props => const [];
}

/// 來源選擇：拍照或相簿，並說明取得好結果的條件。
final class ReceiptImportChoosingSource extends ReceiptImportState {
  const ReceiptImportChoosingSource();
}

/// 照片已取得，辨識與解析中。
final class ReceiptImportRecognizing extends ReceiptImportState {
  const ReceiptImportRecognizing();
}

/// 為什麼不能繼續。每一個值對應不同的訊息與不同的出口（receipt-ocr-import 規格）。
enum ReceiptImportBlock {
  /// 相機或相簿權限被拒 → 前往設定、改為手動新增。
  permissionDenied,

  /// 辨識元件還沒就緒（模型下載中）→ 重試、改為手動新增。
  recognizerNotReady,
}

final class ReceiptImportBlocked extends ReceiptImportState {
  const ReceiptImportBlocked({required this.reason});

  final ReceiptImportBlock reason;

  @override
  List<Object?> get props => [reason];
}

/// 辨識完成但沒有東西。兩種原因給不同訊息：使用者能做的事不同。
enum ReceiptImportEmptyKind {
  /// 照片裡完全沒有文字 → 大概拍到桌子了，重拍。
  noText,

  /// 有文字但解析不出任何品項 → 版面看不懂，重拍或手動新增。
  noItems,
}

final class ReceiptImportEmpty extends ReceiptImportState {
  const ReceiptImportEmpty({required this.kind});

  final ReceiptImportEmptyKind kind;

  @override
  List<Object?> get props => [kind];
}

/// 草稿確認中。**每一列預設都是待確認**（design D4）。
final class ReceiptImportDrafts extends ReceiptImportState {
  const ReceiptImportDrafts({
    required this.drafts,
    required this.receiptDate,
    this.locations = const [],
    this.now,
  });

  final List<FoodItemDraft> drafts;

  /// 從收據擷取到的日期（找不到就是今天），也是每一筆的存放日期。
  final DateTime receiptDate;

  /// 供草稿編輯的存放位置選單用。
  final List<StorageLocation> locations;

  /// 草稿產生當下的時間，供期限快速選項計算相對日期。
  /// 放在 state 而不是讓畫面呼叫 `DateTime.now()`，widget test 才能決定「今天」。
  final DateTime? now;

  List<FoodItemDraft> get importable =>
      drafts.where((draft) => draft.isImportable).toList();

  bool get canSubmit => importable.isNotEmpty;

  ReceiptImportDrafts copyWith({List<FoodItemDraft>? drafts}) =>
      ReceiptImportDrafts(
        drafts: drafts ?? this.drafts,
        receiptDate: receiptDate,
        locations: locations,
        now: now,
      );

  @override
  List<Object?> get props => [drafts, receiptDate, locations, now];
}

final class ReceiptImportSubmitting extends ReceiptImportState {
  const ReceiptImportSubmitting();
}

final class ReceiptImportDone extends ReceiptImportState {
  const ReceiptImportDone({required this.importedCount});

  final int importedCount;

  @override
  List<Object?> get props => [importedCount];
}
