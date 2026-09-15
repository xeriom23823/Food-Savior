import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_savior/services/scanner/app_settings_opener.dart';

/// `AppSettingsOpener` 的原生端在 Android 的 `MainActivity.kt` 與 iOS 的
/// `AppDelegate.swift`，兩邊共用同一個 channel 名稱。
///
/// 這裡測的是 Dart 端的契約：**未實作的平台必須安靜地回傳 false，不能拋例外**。
/// 桌面與測試環境都沒有原生端，如果這裡會炸，掃描頁在那些平台就會整個壞掉。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test/app_settings');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('原生端回傳 true 時視為成功開啟', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'openAppSettings');
      return true;
    });

    expect(await const AppSettingsOpener(channel: channel).open(), isTrue);
  });

  test('原生端回傳 false 時視為未開啟', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => false);

    expect(await const AppSettingsOpener(channel: channel).open(), isFalse);
  });

  test('原生端回傳 null 時不當成成功', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => null);

    expect(await const AppSettingsOpener(channel: channel).open(), isFalse);
  });

  test('沒有原生端（桌面、測試）時回傳 false，不拋例外', () async {
    // 不註冊任何 handler：這正是桌面與測試環境的狀態。
    expect(await const AppSettingsOpener(channel: channel).open(), isFalse);
  });

  test('原生端丟 PlatformException 時回傳 false，不讓例外冒到 UI', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'FAILED');
    });

    expect(await const AppSettingsOpener(channel: channel).open(), isFalse);
  });

  test('預設使用與原生端一致的 channel 名稱', () {
    // 名稱對不上就是按了沒反應，而且不會有任何錯誤——所以要鎖住。
    const production = MethodChannel('food_savior/app_settings');
    messenger.setMockMethodCallHandler(production, (call) async => true);
    addTearDown(() => messenger.setMockMethodCallHandler(production, null));

    expect(const AppSettingsOpener().open(), completion(isTrue));
  });
}
