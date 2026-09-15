## 1. 改用動態下載的模型

- [x] 1.1 `android/gradle.properties` 加 `dev.steenbakker.mobile_scanner.useUnbundled=true`
- [x] 1.2 `AndroidManifest.xml` 加 `com.google.mlkit.vision.DEPENDENCIES` meta-data，讓模型在安裝時就備妥（design D1）
- [x] 1.3 體積實測：ML Kit 打包檔案 **7 個／14.3 MB → 1 個／0 MB**；debug APK 259.0 → **227.4 MB**。`barhopper`（打包的原生模型）已完全消失，合併後的 manifest 含 `com.google.mlkit.vision.DEPENDENCIES`

## 2. 「掃描元件尚未就緒」狀態

- [x] 2.1 `ScannerPermission` 新增 `scannerUnavailable`，並在列舉註解說明它涵蓋的範圍（design D2）
- [x] 2.2 `MobileScannerService` 錯誤碼映射：`unsupported` → `noCamera`；`genericError`／`controllerInitializing`／其餘 → `scannerUnavailable`
- [x] 2.3 掃描頁：新狀態顯示 `einvoiceScannerNotReady`，同時提供「重試」（派發既有的 `ImportRestarted`）與「改為手動新增」
- [x] 2.4 確認「沒有相機」**不**提供重試（真的沒相機，重試無意義）
- [x] 2.5 widget test：三種不可用原因各自的訊息與出口；重試會派發 `ImportRestarted`；明暗 × zh／en

## 3. iOS 的「前往設定」

- [x] 3.1 `ios/Runner/AppDelegate.swift` 加 `food_savior/app_settings` 的 handler，用 `UIApplication.openSettingsURLString`
- [x] 3.2 確認 channel 名稱與 Android 一致，Dart 端 `AppSettingsOpener` 不需修改
- [x] 3.3 單元測試：channel 未實作時回傳 false 不拋例外（既有行為，補測試鎖住）

## 4. l10n

- [x] 4.1 `intl_zh.arb`／`intl_en.arb` 新增 `einvoiceScannerNotReady`
- [x] 4.2 `dart run intl_utils:generate`，接著 `dart format lib/generated`

## 5. 驗證

- [x] 5.1 `dart format .`
- [x] 5.2 `flutter analyze --no-pub`（0 error／0 warning）
- [x] 5.3 `flutter test` 全綠
- [x] 5.4 同 1.3
- [~] 5.5 實機（SM-T500）：已完整移除並重新安裝，App 正常啟動。**「第一次掃描就能用」未驗**——完整移除同時清掉登入狀態，掃描入口在登入後的食物分頁，而我不能代使用者輸入帳密。logcat 目前只見 Firebase Analytics 的 Dynamite 模組載入，條碼模組尚未被請求（Play Services 會自行排程背景下載）。**待使用者登入後驗證第一次掃描**
- [~] 5.6 iOS：**無法在本機驗證**（沒有 macOS 建置環境）。`AppDelegate.swift` 的 handler 未經編譯驗證；Dart 端契約已由 `test/services/app_settings_opener_test.dart` 覆蓋（含未實作平台回傳 false 不拋例外）。待使用者在 macOS 上建置驗證
- [x] 5.7 `openspec validate --all --strict --no-interactive`
