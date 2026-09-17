part of 'receipt_import_bloc.dart';

/// 事件是 Equatable：草稿編輯的事件帶索引與內容，值相等才能在測試裡精確驗證
/// 「派發了哪一個」（與 `ImportEvent` 同一個理由）。
sealed class ReceiptImportEvent extends Equatable {
  const ReceiptImportEvent();

  @override
  List<Object?> get props => const [];
}

/// 進入流程：顯示來源選擇。
final class ReceiptImportStarted extends ReceiptImportEvent {
  const ReceiptImportStarted();
}

/// 使用者選了拍照或相簿。取得照片 → 辨識 → 解析 → 草稿，一路走到底。
final class ReceiptImportSourceChosen extends ReceiptImportEvent {
  const ReceiptImportSourceChosen(this.source);

  final ReceiptImageSource source;

  @override
  List<Object?> get props => [source];
}

/// 從不可用、空結果或草稿頁回到來源選擇重來。
final class ReceiptImportRetried extends ReceiptImportEvent {
  const ReceiptImportRetried();
}

/// 編輯某一列草稿。
final class ReceiptImportDraftChanged extends ReceiptImportEvent {
  const ReceiptImportDraftChanged({required this.index, required this.draft});

  final int index;
  final FoodItemDraft draft;

  @override
  List<Object?> get props => [index, draft];
}

/// 排除／恢復某一列。
final class ReceiptImportDraftToggled extends ReceiptImportEvent {
  const ReceiptImportDraftToggled({required this.index});

  final int index;

  @override
  List<Object?> get props => [index];
}

/// 把未被排除的草稿寫入清單。
final class ReceiptImportSubmitted extends ReceiptImportEvent {
  const ReceiptImportSubmitted();
}
