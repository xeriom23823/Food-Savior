import 'package:flutter/services.dart';

/// 開啟本 App 的系統設定頁。
///
/// 相機權限被永久拒絕（Android 的 `USER_FIXED`）之後，App 再也叫不出權限對話框，
/// 唯一的出路是系統設定。為此引入 `permission_handler` 這類套件並不划算，
/// 一個 MethodChannel 就夠——原生端在 `MainActivity.kt`。
///
/// iOS 尚未實作（需要 `UIApplication.openSettingsURLString`），
/// 未實作的平台回傳 false，呼叫端據此決定要不要顯示按鈕。
class AppSettingsOpener {
  const AppSettingsOpener({
    MethodChannel channel = const MethodChannel('food_savior/app_settings'),
  }) : _channel = channel;

  final MethodChannel _channel;

  Future<bool> open() async {
    try {
      return await _channel.invokeMethod<bool>('openAppSettings') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      // 桌面與測試環境沒有原生端，不該因此丟例外。
      return false;
    }
  }
}
