import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_savior/domain/einvoice/einvoice.dart';
import 'package:food_savior/domain/einvoice/einvoice_parse_failure.dart';
import 'package:food_savior/domain/einvoice/einvoice_qr_parser.dart';
import 'package:food_savior/domain/import/food_item_draft.dart';
import 'package:food_savior/domain/import/invoice_draft_mapper.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/models/storage_location.dart';
import 'package:food_savior/repositories/preferences_repository.dart';
import 'package:food_savior/services/scanner/scanner_service.dart';
import 'package:uuid/uuid.dart';

part 'import_event.dart';
part 'import_state.dart';

/// 發票匯入流程（design D4）。
///
/// 雙碼配對是**互動狀態**，所以放在這裡，而不是無狀態的解析器裡。
/// 這個 Bloc 不知道 `mobile_scanner` 的存在——它只拿到一個 [ScannerService]。
class ImportBloc extends Bloc<ImportEvent, ImportState> {
  ImportBloc({
    required this.scannerService,
    required this.mapper,
    required this.preferencesRepository,
    required this.onItemReady,
    this.locationKind,
    this.defaultLocationId,
    this.locations = const [],
    Uuid? uuid,
  })  : _uuid = uuid ?? const Uuid(),
        super(const ImportInitial()) {
    on<ImportStarted>(_onStarted);
    on<ImportCodeScanned>(_onCodeScanned);
    on<ImportDraftChanged>(_onDraftChanged);
    on<ImportDraftToggled>(_onDraftToggled);
    on<ImportDuplicateConfirmed>(_onDuplicateConfirmed);
    on<ImportSubmitted>(_onSubmitted);
    on<ImportRestarted>(_onRestarted);
  }

  final ScannerService scannerService;
  final InvoiceDraftMapper mapper;
  final PreferencesRepository preferencesRepository;

  /// 每產生一筆就交給呼叫端派發 `FoodItemListAdd`。
  ///
  /// 刻意不直接依賴 `FoodItemListBloc`：Bloc 之間互相持有會讓兩邊都難測。
  final void Function(FoodItem item) onItemReady;

  final LocationKind? locationKind;
  final String? defaultLocationId;

  /// 草稿編輯的存放位置選單來源。Bloc 不解讀它，只是轉交給畫面。
  final List<StorageLocation> locations;
  final Uuid _uuid;

  StreamSubscription<String>? _subscription;

  /// 已掃到的左碼原文。右碼沒有發票號碼，所以配對鍵是「同一次掃描工作階段」。
  String? _leftCode;
  String? _rightCode;

  /// 解析完成但還沒確認的發票（重複警告時暫存在這裡）。
  EInvoice? _pendingInvoice;

  Future<void> _onStarted(
      ImportStarted event, Emitter<ImportState> emit) async {
    final permission = await scannerService.ensurePermission();
    if (permission != ScannerPermission.granted) {
      emit(ImportPermissionBlocked(permission: permission));
      return;
    }

    _resetCodes();
    emit(const ImportScanning());
    await _subscription?.cancel();
    _subscription = scannerService.codes.listen(
      (code) => add(ImportCodeScanned(code: code)),
    );
  }

  Future<void> _onCodeScanned(
    ImportCodeScanned event,
    Emitter<ImportState> emit,
  ) async {
    // 只有掃描狀態才接受新的碼；草稿頁還開著時掃到東西不該把它蓋掉。
    if (state is! ImportScanning) return;

    final code = event.code.trim();
    if (code.isEmpty) return;

    if (EInvoiceQrParser.isRightCode(code)) {
      _rightCode = code;
    } else {
      _leftCode = code;
    }

    final left = _leftCode;
    if (left == null) {
      // 先掃到右碼：留著等左碼，順序不影響結果（einvoice-import 規格）。
      emit(const ImportScanning(hasRightCode: true));
      return;
    }

    final result = EInvoiceQrParser.parse(left, right: _rightCode);
    switch (result) {
      case EInvoiceParseFailure(:final reason):
        _onParseFailure(reason, emit);
      case EInvoiceParseSuccess(:final invoice):
        if (!invoice.isComplete && _rightCode == null) {
          // 左碼還沒涵蓋宣告的品目筆數，繼續等右碼。
          emit(const ImportScanning(hasLeftCode: true));
          return;
        }
        await _presentInvoice(invoice, emit);
    }
  }

  void _onParseFailure(ParseFailureReason reason, Emitter<ImportState> emit) {
    switch (reason) {
      case ParseFailureReason.codeMismatch:
        // 掃到別張發票的右碼：丟掉右碼、保留左碼，掃描繼續（規格要求）。
        _rightCode = null;
        emit(const ImportScanning(
          hasLeftCode: true,
          notice: ImportNotice.codeMismatch,
        ));
      case ParseFailureReason.tooShort:
        // 掃到非發票的 QR 很常見，不該中斷掃描。
        _leftCode = null;
        emit(ImportScanning(hasRightCode: _rightCode != null));
      case ParseFailureReason.unsupportedBig5:
      case ParseFailureReason.malformed:
        _stopScanning();
        emit(ImportFailure(reason: reason));
    }
  }

  Future<void> _presentInvoice(
    EInvoice invoice,
    Emitter<ImportState> emit,
  ) async {
    _stopScanning();
    if (preferencesRepository.hasImportedInvoice(invoice.invoiceNumber)) {
      _pendingInvoice = invoice;
      emit(ImportDuplicateWarning(invoiceNumber: invoice.invoiceNumber));
      return;
    }
    emit(_draftsFor(invoice));
  }

  ImportDrafts _draftsFor(EInvoice invoice) => ImportDrafts(
        invoiceNumber: invoice.invoiceNumber,
        drafts: mapper.draftsFrom(
          invoice,
          locationKind: locationKind,
          defaultLocationId: defaultLocationId,
        ),
        itemsIncomplete: !invoice.isComplete,
        locations: locations,
        now: mapper.now,
      );

  void _onDuplicateConfirmed(
    ImportDuplicateConfirmed event,
    Emitter<ImportState> emit,
  ) {
    final invoice = _pendingInvoice;
    if (invoice == null) return;
    _pendingInvoice = null;
    emit(_draftsFor(invoice));
  }

  void _onDraftChanged(ImportDraftChanged event, Emitter<ImportState> emit) {
    final current = state;
    if (current is! ImportDrafts) return;
    if (event.index < 0 || event.index >= current.drafts.length) return;

    final drafts = List<FoodItemDraft>.of(current.drafts);
    drafts[event.index] = event.draft;
    emit(current.copyWith(drafts: drafts));
  }

  void _onDraftToggled(ImportDraftToggled event, Emitter<ImportState> emit) {
    final current = state;
    if (current is! ImportDrafts) return;
    if (event.index < 0 || event.index >= current.drafts.length) return;

    final drafts = List<FoodItemDraft>.of(current.drafts);
    final target = drafts[event.index];
    drafts[event.index] = target.copyWith(excluded: !target.excluded);
    emit(current.copyWith(drafts: drafts));
  }

  Future<void> _onSubmitted(
    ImportSubmitted event,
    Emitter<ImportState> emit,
  ) async {
    final current = state;
    if (current is! ImportDrafts || !current.canSubmit) return;

    emit(const ImportSubmitting());
    final now = mapper.now;
    final importable = current.importable;
    for (final draft in importable) {
      onItemReady(draft.toFoodItem(id: _uuid.v4(), now: now));
    }
    await preferencesRepository.markInvoiceImported(current.invoiceNumber);
    emit(ImportDone(importedCount: importable.length));
  }

  Future<void> _onRestarted(
    ImportRestarted event,
    Emitter<ImportState> emit,
  ) async {
    _pendingInvoice = null;
    add(const ImportStarted());
  }

  void _resetCodes() {
    _leftCode = null;
    _rightCode = null;
    _pendingInvoice = null;
  }

  void _stopScanning() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await scannerService.dispose();
    return super.close();
  }
}
