part of 'import_bloc.dart';

/// 事件是 Equatable：草稿編輯的事件帶索引與內容，值相等才能在測試裡精確驗證
/// 「派發了哪一個」，而不是只能驗證「派發了某個同型別的東西」。
sealed class ImportEvent extends Equatable {
  const ImportEvent();

  @override
  List<Object?> get props => const [];
}

/// 進入掃描頁：要求相機權限並開始接收掃描結果。
final class ImportStarted extends ImportEvent {
  const ImportStarted();
}

/// 掃到一個碼。左右碼的判定與配對在 Bloc 裡做（design D4）。
final class ImportCodeScanned extends ImportEvent {
  const ImportCodeScanned({required this.code});

  final String code;

  @override
  List<Object?> get props => [code];
}

/// 編輯某一列草稿。
final class ImportDraftChanged extends ImportEvent {
  const ImportDraftChanged({required this.index, required this.draft});

  final int index;
  final FoodItemDraft draft;

  @override
  List<Object?> get props => [index, draft];
}

/// 排除／恢復某一列。
final class ImportDraftToggled extends ImportEvent {
  const ImportDraftToggled({required this.index});

  final int index;

  @override
  List<Object?> get props => [index];
}

/// 重複發票的警告中選擇「仍要匯入」。
final class ImportDuplicateConfirmed extends ImportEvent {
  const ImportDuplicateConfirmed();
}

/// 把未被排除的草稿寫入清單。
final class ImportSubmitted extends ImportEvent {
  const ImportSubmitted();
}

/// 從失敗或重複警告回到掃描狀態重來。
final class ImportRestarted extends ImportEvent {
  const ImportRestarted();
}
