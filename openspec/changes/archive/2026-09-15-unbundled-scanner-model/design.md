## Context

動機見 proposal.md「Why」。影響作法的現況：

- `mobile_scanner` 7.4.2 的 `android/build.gradle.kts` 用一個 Gradle property 選擇 ML Kit 的 artifact：

  ```kotlin
  val useUnbundled = findProperty("dev.steenbakker.mobile_scanner.useUnbundled")?.toString() ?: "false"
  if (useUnbundled.toBoolean()) {
      implementation("com.google.android.gms:play-services-mlkit-barcode-scanning:18.3.1")
  } else {
      implementation("com.google.mlkit:barcode-scanning:17.3.0")
  }
  ```

  所以切換不需要改套件、不需要 fork，只要在 `android/gradle.properties` 設一行。

- **`MobileScannerErrorCode` 沒有「模型尚未就緒」這個碼**。列舉只有 `controllerAlreadyInitialized`、`controllerDisposed`、`controllerUninitialized`、`genericError`、`permissionDenied`、`unsupported`、`controllerInitializing`、`controllerNotAttached`。動態下載失敗會以 `genericError` 浮出來。

- 目前 `MobileScannerService._permissionFor` 是 `permissionDenied → denied`、其餘一律 `→ noCamera`。改成動態下載後，這個 catch-all 會把「模型還在下載」講成「這台裝置沒有可用的相機」。

- iOS 的 `AppSettingsOpener` 沒有原生端；`MissingPluginException` 被吃掉回傳 false，所以 iOS 上那顆按鈕按了沒反應。

## Goals / Non-Goals

**Goals:**

- 把 14.3 MB 拿掉，而使用者感受不到差別。
- 掃描不可用時，訊息要**對應使用者真正能做的事**：能重試的就給重試，不能的就不要給。
- 讓「前往系統設定」在兩個有掃描功能的平台上都真的能用。

**Non-Goals:**

- 不做模型下載進度 UI。
- 不為沒有 Google Play Services 的裝置做替代解碼器。
- 不改 iOS 的掃描實作（AVFoundation 不受 ML Kit 打包方式影響，本 change 對 iOS 掃描是零影響）。

## Decisions

### D1：靠安裝時預先下載，而不是靠第一次掃描時才抓

只設 `useUnbundled=true` 的話，模型會在**第一次使用掃描時**才下載——那正好是使用者最沒耐心的時刻（他手上拿著發票）。

加上 manifest meta-data 讓 Play Services 在安裝後就準備好：

```xml
<meta-data
    android:name="com.google.mlkit.vision.DEPENDENCIES"
    android:value="barcode" />
```

這樣絕大多數使用者第一次掃描時模型早就到位，「尚未就緒」只會出現在剛裝好就立刻掃、或裝置離線安裝的邊緣情況。

### D2：新增一個狀態，而不是重用「沒有相機」

把「模型還沒好」講成「這台裝置沒有可用的相機」有兩個問題：訊息是假的，而且它暗示無解，使用者會直接放棄。

新增 `ScannerPermission.scannerUnavailable`：

| 錯誤碼 | 對應狀態 | 出口 |
|---|---|---|
| `permissionDenied` | `denied` | 前往設定 + 手動新增 |
| `unsupported` | `noCamera` | 手動新增（不給重試——真的沒有相機，重試無意義） |
| `genericError`、`controllerInitializing`、其餘 | `scannerUnavailable` | **重試** + 手動新增 |

catch-all 從 `noCamera` 改成 `scannerUnavailable` 是刻意的：未知錯誤「可能是暫時的」比「你的裝置不行」更接近事實，也給了使用者一個動作。

> 列舉名稱用 `ScannerPermission` 已經不準確（它現在裝的是「掃描為什麼不能用」），但改名要動到 Bloc 狀態與既有測試，收益只是名稱好看一點。留著，在列舉的文件註解說明它涵蓋的範圍。

### D3：重試就是重新跑一次既有的啟動流程

`ImportRestarted` 已經存在（失敗畫面在用），它會重新 `ensurePermission()` 並重新訂閱。「尚未就緒」的重試直接重用它，不需要新事件。

### D4：iOS 的設定跳轉放在 AppDelegate，與 Android 對稱

Android 的 handler 在 `MainActivity.kt`，iOS 放在 `AppDelegate.swift`，用同一個 channel 名稱 `food_savior/app_settings`。Dart 端 `AppSettingsOpener` 完全不用改——它本來就只是發一個 method call，未實作的平台回 false。

這也是當初把它做成 MethodChannel 而不是直接寫在頁面裡的回報：補平台只要加原生端，Dart 與測試都不動。

## Risks / Trade-offs

- **模型沒下載好就掃不了** → 這是真實的退步，不是零成本。以 D1 的安裝時預先下載把窗口壓到很小，並以 D2 的可重試訊息讓剩下的情況不至於讓使用者放棄。實機必須驗證「重裝後第一次掃描就能用」。
- **沒有 Google Play Services 的裝置無法掃描** → 這類裝置（部分中國市場機型、去 Google 化的 ROM）會停在「尚未就緒」。接受：這個 App 本來就依賴 Firebase，那些裝置連登入都有問題。
- **`genericError` 是 catch-all，可能蓋住真正的永久性錯誤** → 代價是使用者多按一次重試才放棄，比反過來（把可回復的講成不可回復）好。
- **iOS 無法在本機驗證** → 沒有 macOS 建置環境。Swift 端會寫成最小且標準的形式，並在 tasks 明確標記為未驗證。

## Migration Plan

- **上線**：加 Gradle property 與 manifest meta-data → `flutter build apk --debug` 量體積 → 實機**重新安裝**（不是熱更新）確認第一次掃描可用。
- **回滾**：拿掉 `android/gradle.properties` 那一行即可退回打包版本；其餘改動（新狀態、iOS 設定跳轉）與打包方式無關，可以留著。
