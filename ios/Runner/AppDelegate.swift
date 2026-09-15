import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// 與 Android 的 `MainActivity.kt` 用同一個 channel 名稱，
  /// Dart 端的 `AppSettingsOpener` 因此不需要為平台分支
  /// （unbundled-scanner-model D4）。
  private let appSettingsChannelName = "food_savior/app_settings"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    registerAppSettingsChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// 相機權限被拒之後，iOS 不會再跳權限對話框，唯一的出路是系統設定。
  private func registerAppSettingsChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: appSettingsChannelName,
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
      guard call.method == "openAppSettings" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url)
      else {
        // 開不了就回報失敗，不要丟例外——呼叫端會據此不顯示按鈕。
        result(false)
        return
      }
      UIApplication.shared.open(url, options: [:]) { opened in
        result(opened)
      }
    }
  }
}
