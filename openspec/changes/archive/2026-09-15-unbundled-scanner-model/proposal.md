## Why

`scan-einvoice-import` 帶進來的 ML Kit 條碼模型是**打包進 APK** 的版本，實測佔約 **14.3 MB（未壓縮）**——遠高於當初 design D2 估的 2–3 MB。對一個記錄冰箱食物的 App 來說，為了「偶爾掃一張發票」讓每個使用者多下載十幾 MB 並不合理，尤其掃描功能不是每個人都會用。

`mobile_scanner` 支援改用 Google Play Services 動態下載模型（`dev.steenbakker.mobile_scanner.useUnbundled`）。代價是模型要在裝置上準備好才能掃，但這個代價可以用安裝時預先下載壓到很小。

同時補上 `scan-einvoice-import` 留下的一個平台缺口：「前往設定」目前只有 Android 原生端，iOS 上按了不會有反應。

本 change 要驗證的假設：**用安裝時預先下載換掉 14 MB 的體積，使用者感受不到差別。**

## What Changes

### A. 改用動態下載的 ML Kit 模型

- `android/gradle.properties` 加 `dev.steenbakker.mobile_scanner.useUnbundled=true`。
- `AndroidManifest.xml` 加 `com.google.mlkit.vision.DEPENDENCIES` meta-data，讓 Play Services 在**安裝時**就把模型抓好，而不是等第一次掃描才抓。
- 量測並記錄體積差。

### B. 新增「掃描元件尚未就緒」狀態（**行為變更**）

動態下載帶來一個打包版本沒有的失敗情境：模型還沒下載完、或裝置沒有 Google Play Services。

目前的程式會把這種情況映成 `einvoiceCameraUnavailable`（「這台裝置沒有可用的相機」）——**這是錯的訊息**，相機好好的，而且它暗示使用者無能為力，但其實等一下或連個網就好了。

- 新增 `ScannerPermission.scannerUnavailable` 與對應的 l10n 訊息，提供「重試」與「改為手動新增」。
- 錯誤碼映射：`unsupported` → 沒有相機（不變）；`genericError`／`controllerInitializing` → 掃描元件尚未就緒（新）。

### C. 補上 iOS 的「前往設定」

`AppSettingsOpener` 目前只有 Android 原生端。補上 iOS 的 `UIApplication.openSettingsURLString`，讓 `einvoice-import` 規格裡「提供前往系統設定的出口」這條在 iOS 上也成立。

### 範圍上限

一個 Gradle property、一個 manifest meta-data、一個新的錯誤狀態與兩個 l10n 字串、iOS 的 AppDelegate 加一個 MethodChannel handler。**不新增套件、不新增畫面、不改資料模型、不改 Bloc 事件。**

### 非目標

- 不做「模型下載進度」的 UI。Play Services 在背景處理，我們只需要在還沒好的時候說清楚並提供重試。
- 不處理「裝置完全沒有 Google Play Services」的替代方案（例如改用其他解碼器）。那種裝置直接走手動新增。
- 不改 iOS 的掃描實作（iOS 走 AVFoundation，不受 ML Kit 打包方式影響）。

## Capabilities

### Modified Capabilities

- `einvoice-import`：「相機權限被拒時提供可操作的出口」擴充為涵蓋「掃描元件尚未就緒」這個新的不可用情境——它與「沒有相機」必須給不同的訊息與不同的出口（可重試 vs 不可重試）。

## Impact

- **Code**：`android/gradle.properties`、`android/app/src/main/AndroidManifest.xml`、`ios/Runner/AppDelegate.swift`、`lib/services/scanner/scanner_service.dart`（新增列舉值）、`lib/services/scanner/mobile_scanner_service.dart`（錯誤碼映射）、`lib/pages/import/scan_invoice_page.dart`（新狀態的畫面）、`lib/l10n/*.arb`。
- **資料模型**：不變。
- **Bloc 狀態**：`ImportPermissionBlocked` 的 `permission` 多一個可能值，狀態類別本身不變。
- **l10n**：新增 2 個 key（`einvoiceScannerNotReady`、`einvoiceScannerRetry` 視實作決定是否重用既有的 `einvoiceRetry`）。
- **平台權限**：不變。
- **Dependencies**：不新增套件；改變的是 `mobile_scanner` 內部選用的 ML Kit artifact。
- **Tests**：新狀態的 widget test；錯誤碼映射的單元測試。既有的掃描頁測試必須維持全綠。
- **Risk**：模型沒下載好時掃不了，是真實的退步。以安裝時預先下載 + 明確可重試的訊息降低衝擊；若實機上等待明顯，回滾只需拿掉一個 Gradle property。
- **實機**：必須在 SM-T500 上重裝並確認第一次掃描就能用（驗證安裝時預先下載有生效）。
