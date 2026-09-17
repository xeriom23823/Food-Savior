import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/domain/import/food_item_draft.dart';
import 'package:food_savior/domain/receipt/receipt_date_parser.dart';
import 'package:food_savior/domain/receipt/receipt_draft_mapper.dart';
import 'package:food_savior/domain/receipt/receipt_layout_parser.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/services/ocr/receipt_image_picker.dart';
import 'package:food_savior/services/ocr/text_recognition_service.dart';
import 'package:uuid/uuid.dart';

part 'receipt_import_event.dart';
part 'receipt_import_state.dart';

/// 紙本收據匯入流程：取得照片 → 辨識 → 版面解析 → 草稿 → 寫入。
///
/// 這個 Bloc 不知道 `image_picker` 與 ML Kit 的存在——它只拿到兩個介面。
/// 解析與轉草稿是純 Dart（`ReceiptLayoutParser`、`ReceiptDraftMapper`），
/// 所以整條流程用 fixture 就能測到底。
class ReceiptImportBloc extends Bloc<ReceiptImportEvent, ReceiptImportState> {
  ReceiptImportBloc({
    required this.imagePicker,
    required this.recognizer,
    required this.parser,
    required this.mapper,
    required this.onItemReady,
    this.locationKind,
    this.defaultLocationId,
    this.locations = const [],
    DateTime Function()? now,
    Uuid? uuid,
  })  : _now = now ?? DateTime.now,
        _uuid = uuid ?? const Uuid(),
        super(const ReceiptImportChoosingSource()) {
    on<ReceiptImportStarted>(_onStarted);
    on<ReceiptImportSourceChosen>(_onSourceChosen);
    on<ReceiptImportRetried>(_onRetried);
    on<ReceiptImportDraftChanged>(_onDraftChanged);
    on<ReceiptImportDraftToggled>(_onDraftToggled);
    on<ReceiptImportSubmitted>(_onSubmitted);
  }

  final ReceiptImagePicker imagePicker;
  final TextRecognitionService recognizer;
  final ReceiptLayoutParser parser;
  final ReceiptDraftMapper mapper;

  /// 每產生一筆就交給呼叫端派發 `FoodItemListAdd`。
  ///
  /// 刻意不直接依賴 `FoodItemListBloc`：Bloc 之間互相持有會讓兩邊都難測
  /// （與 `ImportBloc` 同一個決定）。
  final void Function(FoodItem item) onItemReady;

  final LocationKind? locationKind;
  final String? defaultLocationId;

  /// 草稿編輯的存放位置選單來源。Bloc 不解讀它，只是轉交給畫面。
  final List<StorageLocation> locations;

  final DateTime Function() _now;
  final Uuid _uuid;

  void _onStarted(
    ReceiptImportStarted event,
    Emitter<ReceiptImportState> emit,
  ) {
    emit(const ReceiptImportChoosingSource());
  }

  Future<void> _onSourceChosen(
    ReceiptImportSourceChosen event,
    Emitter<ReceiptImportState> emit,
  ) async {
    // 系統相機／相簿介面開著的時候維持在來源選擇狀態，等結果回來再前進。
    final picked = await imagePicker.pick(event.source);
    switch (picked) {
      case ImagePickCancelled():
        emit(const ReceiptImportChoosingSource());
        return;
      case ImagePickDenied():
        emit(const ReceiptImportBlocked(
          reason: ReceiptImportBlock.permissionDenied,
        ));
        return;
      case ImagePicked(:final path):
        emit(const ReceiptImportRecognizing());
        await _recognize(path, emit);
    }
  }

  Future<void> _recognize(
    String path,
    Emitter<ReceiptImportState> emit,
  ) async {
    final recognition = await recognizer.recognize(path);
    final result = switch (recognition) {
      RecognitionUnavailable() => null,
      RecognitionSuccess(:final result) => result,
    };
    if (result == null) {
      emit(const ReceiptImportBlocked(
        reason: ReceiptImportBlock.recognizerNotReady,
      ));
      return;
    }

    // 兩種「空」分開講：拍到桌子（沒有文字）與版面看不懂（有文字沒品項）
    // 使用者能做的事不同（receipt-ocr-import 規格）。
    if (result.isEmpty) {
      emit(const ReceiptImportEmpty(kind: ReceiptImportEmptyKind.noText));
      return;
    }
    final items = parser.parse(result);
    if (items.isEmpty) {
      emit(const ReceiptImportEmpty(kind: ReceiptImportEmptyKind.noItems));
      return;
    }

    final now = _now();
    // 日期不是阻擋匯入的理由：找不到就用今天（design D5）。
    final receiptDate = ReceiptDateParser.parse(result.plainText, now: now);
    emit(ReceiptImportDrafts(
      drafts: mapper.draftsFrom(
        items,
        receiptDate: receiptDate,
        locationKind: locationKind,
        defaultLocationId: defaultLocationId,
      ),
      receiptDate: receiptDate,
      locations: locations,
      now: now,
    ));
  }

  void _onRetried(
    ReceiptImportRetried event,
    Emitter<ReceiptImportState> emit,
  ) {
    emit(const ReceiptImportChoosingSource());
  }

  void _onDraftChanged(
    ReceiptImportDraftChanged event,
    Emitter<ReceiptImportState> emit,
  ) {
    final current = state;
    if (current is! ReceiptImportDrafts) return;
    if (event.index < 0 || event.index >= current.drafts.length) return;

    final drafts = List<FoodItemDraft>.of(current.drafts);
    drafts[event.index] = event.draft;
    emit(current.copyWith(drafts: drafts));
  }

  void _onDraftToggled(
    ReceiptImportDraftToggled event,
    Emitter<ReceiptImportState> emit,
  ) {
    final current = state;
    if (current is! ReceiptImportDrafts) return;
    if (event.index < 0 || event.index >= current.drafts.length) return;

    final drafts = List<FoodItemDraft>.of(current.drafts);
    final target = drafts[event.index];
    drafts[event.index] = target.copyWith(excluded: !target.excluded);
    emit(current.copyWith(drafts: drafts));
  }

  Future<void> _onSubmitted(
    ReceiptImportSubmitted event,
    Emitter<ReceiptImportState> emit,
  ) async {
    final current = state;
    if (current is! ReceiptImportDrafts || !current.canSubmit) return;

    emit(const ReceiptImportSubmitting());
    final now = _now();
    final importable = current.importable;
    for (final draft in importable) {
      onItemReady(draft.toFoodItem(id: _uuid.v4(), now: now));
    }
    emit(ReceiptImportDone(importedCount: importable.length));
  }

  @override
  Future<void> close() async {
    await recognizer.dispose();
    return super.close();
  }
}
