import 'dart:async';

import 'package:food_savior/services/scanner/scanner_service.dart';

/// 測試替身（design D9）：可以手動餵掃描結果，所以 bloc_test 不需要相機、
/// 不需要 widget binding。
class FakeScannerService implements ScannerService {
  FakeScannerService({this.permission = ScannerPermission.granted});

  ScannerPermission permission;

  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  bool disposed = false;
  int permissionRequests = 0;

  @override
  Stream<String> get codes => _controller.stream;

  @override
  Future<ScannerPermission> ensurePermission() async {
    permissionRequests++;
    return permission;
  }

  /// 模擬掃到一個碼。
  void emit(String code) => _controller.add(code);

  @override
  Future<void> dispose() async {
    disposed = true;
    await _controller.close();
  }
}
