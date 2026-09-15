import 'dart:async';

import 'package:food_savior/services/scanner/scanner_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// [ScannerService] 的實作。**這是整個專案唯一 import `mobile_scanner` 的檔案**
/// （design D9）——Bloc 與測試都只看得到介面。
///
/// [controller] 刻意外露：`MobileScanner` widget 必須拿到同一個 controller 才能
/// 附掛相機預覽。只有掃描頁會用到它，Bloc 不會。
class MobileScannerService implements ScannerService {
  MobileScannerService()
      : controller = MobileScannerController(
          // 發票只有 QR。限定格式可以讓 ML Kit 少做很多事，也避免掃到商品條碼
          // 時誤判成發票。
          formats: const [BarcodeFormat.qrCode],
          detectionSpeed: DetectionSpeed.noDuplicates,
        );

  /// 等待相機就緒的上限。超過就當成相機不可用，讓使用者走手動新增。
  static const Duration startTimeout = Duration(seconds: 10);

  final MobileScannerController controller;

  @override
  Stream<String> get codes => controller.barcodes
      .expand((capture) => capture.barcodes)
      .map((barcode) => barcode.rawValue)
      .where((value) => value != null && value.isNotEmpty)
      .cast<String>();

  /// 觀察 controller 的狀態直到相機起來或報錯。
  ///
  /// **不主動呼叫 `controller.start()`**：`mobile_scanner` 的 `start()` 會等
  /// `MobileScanner` widget 掛載，逾時就丟 `controllerNotAttached`；而那個 widget
  /// 要等權限通過才會被畫出來——先呼叫 start 會變成雞生蛋。
  /// 改成讓 `autoStart` 在 widget 掛載時自己啟動，這裡只負責把結果轉成權限狀態。
  @override
  Future<ScannerPermission> ensurePermission() async {
    final completer = Completer<ScannerPermission>();

    void check() {
      if (completer.isCompleted) return;
      final state = controller.value;
      final error = state.error;
      if (error != null) {
        completer.complete(_permissionFor(error.errorCode));
      } else if (state.isRunning) {
        completer.complete(ScannerPermission.granted);
      }
    }

    controller.addListener(check);
    // widget 可能已經先掛載並啟動完成，先檢查一次現況再等變化。
    check();
    try {
      return await completer.future.timeout(
        startTimeout,
        // 逾時多半是模型還在下載，不是沒有相機。
        onTimeout: () => ScannerPermission.scannerUnavailable,
      );
    } finally {
      controller.removeListener(check);
    }
  }

  /// 錯誤碼 → 不可用原因（unbundled-scanner-model D2）。
  ///
  /// catch-all 刻意是 [ScannerPermission.scannerUnavailable] 而不是 noCamera：
  /// 未知的錯誤「可能是暫時的」比「你的裝置不行」更接近事實，而且給了使用者一個
  /// 可以做的動作。模型改由 Play Services 動態下載後，這條路徑會真的被走到。
  static ScannerPermission _permissionFor(MobileScannerErrorCode code) =>
      switch (code) {
        MobileScannerErrorCode.permissionDenied => ScannerPermission.denied,
        // 裝置真的沒有相機，重試沒有意義。
        MobileScannerErrorCode.unsupported => ScannerPermission.noCamera,
        _ => ScannerPermission.scannerUnavailable,
      };

  @override
  Future<void> dispose() => controller.dispose();
}
