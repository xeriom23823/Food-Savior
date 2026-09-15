## 1. 發票解析（純 Dart，零 Flutter 依賴）

- [x] 1.1 `lib/domain/einvoice/einvoice.dart`：`EInvoice`（發票號碼、開立日期、總計額、品項）與 `EInvoiceItem`（品名、數量、單價）
- [x] 1.2 `lib/domain/einvoice/einvoice_parse_failure.dart`：`ParseFailureReason`（`tooShort`／`unsupportedBig5`／`codeMismatch`／`malformed`）
- [x] 1.3 `lib/domain/einvoice/einvoice_qr_parser.dart`：左碼固定欄位解析（字軌號碼、民國日期換算、16 進位金額、統編）
- [x] 1.4 品項區解析：以品目筆數切割（品名內可含 `:`）、UTF-8 與 Base64 解碼、Big5 回報不支援
- [x] 1.5 右碼（`**` 起始）合併，與左右順序無關
- [x] 1.6 `test/fixtures/einvoice/*.txt`：至少 5 個去識別化 fixture（UTF-8、Base64、品名含冒號、只有左碼、品項數不足）
- [x] 1.7 單元測試 `test/domain/einvoice_qr_parser_test.dart`：fixture 驅動，涵蓋 1.3–1.5 的每一條規則與四種失敗原因

## 2. 品名清洗與草稿轉換（純 Dart）

- [x] 2.1 `assets/data/product_noise_terms.json`：促銷／通路／溫層／品牌雜訊詞表（資料不寫死在程式裡）
- [x] 2.2 `lib/domain/import/product_name_cleaner.dart`：四步清洗，回傳 `CleanedProductName(coreName, amount?, unit?)`；剝到空字串退回原始品名
- [x] 2.3 規格抽取：`ml`／`cc`／`毫升` → milliliter、`g`／`公克` → gram、`入`／`顆`／`包`／`盒`／`罐`／`瓶` → 對應 `Unit`
- [x] 2.4 `lib/domain/import/food_item_draft.dart`：`FoodItemDraft`（含 `sourceLine`、`excluded`、`needsReview`）與 `toFoodItem()`
- [x] 2.5 `lib/domain/import/invoice_draft_mapper.dart`：呼叫 cleaner → `FoodSuggestionEngine.suggest()` → 疊上發票日期與金額；`now` 可注入；規格覆蓋建議的 amount／unit
- [x] 2.6 單元測試 `test/domain/product_name_cleaner_test.dart`：design D5 的四步各至少兩案例，含清洗後為空
- [x] 2.7 單元測試 `test/domain/invoice_draft_mapper_test.dart`：命中模板／命中對照表／未命中（`needsReview`）、金額 = 單價 × 數量、規格優先於建議、`storageDate` 為發票日期

## 3. 掃描服務（唯一接觸 mobile_scanner 的層）

- [x] 3.1 `pubspec.yaml` 新增 `mobile_scanner: ^7.4.2`
- [x] 3.2 `lib/services/scanner/scanner_service.dart`：`ScannerService` 介面、`ScannerPermission` 列舉
- [x] 3.3 `lib/services/scanner/mobile_scanner_service.dart`：實作，只接受 `BarcodeFormat.qrCode`
- [x] 3.4 Android `AndroidManifest.xml` 加 `CAMERA` 權限
- [x] 3.5 iOS `Info.plist` 加 `NSCameraUsageDescription`，字串走 `InfoPlist.strings`（zh／en）
- [x] 3.6 `test/helpers/fake_scanner_service.dart`：可手動餵字串的測試替身

## 4. ImportBloc

- [x] 4.1 `lib/bloc/import/import_event.dart`：`ImportStarted`、`ImportCodeScanned`、`ImportDraftChanged`、`ImportDraftToggled`、`ImportSubmitted`、`ImportDuplicateConfirmed`
- [x] 4.2 `lib/bloc/import/import_state.dart`：`ImportInitial`／`ImportScanning`／`ImportDrafts`／`ImportSubmitting`／`ImportDone`／`ImportFailure`（`final class` + Equatable，`props` 含所有影響 UI 的欄位）
- [x] 4.3 `lib/bloc/import/import_bloc.dart`：雙碼配對狀態機（design D4）、重複發票檢查、批次派發 `FoodItemListAdd`
- [x] 4.4 `PreferencesRepository` 加 `importedInvoiceNumbers` 與 `markInvoiceImported`（上限 200 筆 FIFO）
- [x] 4.5 bloc_test `test/bloc/import_bloc_test.dart`：左→右、右→左、只有左碼、碼不配對、重複發票（拒絕與確認兩路）、逐列排除、全部排除、送出成功
- [x] 4.6 單元測試 `test/repositories/preferences_repository_test.dart` 補上發票號碼的讀寫與 200 筆上限

## 5. 畫面

- [x] 5.1 `lib/pages/import/scan_invoice_page.dart`：相機預覽、左右碼進度、權限被拒與無相機的兩種說明畫面（各含「改為手動新增」）
- [x] 5.2 `lib/pages/import/import_drafts_page.dart`：草稿列表、逐列編輯（名稱／類型／數量／單位／期限／位置）、排除、`needsReview` 標示、「全部加入」
- [x] 5.3 食物分頁新增掃描入口，以 `Theme.of(context).platform` 限定 Android／iOS（design D10）；`test/pages/import_route_test.dart` 覆蓋五種平台
- [x] 5.4 只用 `Theme.of(context).colorScheme.*`／`textTheme.*` 與 design-system token；`grep` 確認 `lib/pages/import` 無 `Colors.`／`Color(0x`／`fontSize:`
- [x] 5.5 widget test `test/pages/scan_invoice_page_test.dart`：掃描進度、權限被拒畫面、明暗 × zh／en
- [x] 5.6 widget test `test/pages/import_drafts_page_test.dart`：草稿呈現、排除後「全部加入」停用、`needsReview` 標示、明暗 × zh／en

## 6. l10n

- [x] 6.1 `lib/l10n/intl_zh.arb` 與 `intl_en.arb` 新增 spec 中出現的所有 key（`einvoiceLeftCodePending`、`einvoiceRightCodePending`、`einvoiceCodeMismatch`、`einvoiceParseFailed`、`einvoiceEncodingUnsupported`、`einvoiceItemsIncomplete`、`einvoicePermissionDenied`、`einvoiceCameraUnavailable`、`einvoiceAlreadyImported`、`einvoiceDraftNeedsReview`、`einvoiceImported` 等）
- [x] 6.2 `dart run intl_utils:generate`，接著 `dart format lib/generated`（產生器輸出不符合 format，會擋 Stop hook）
- [x] 6.3 `grep` 確認 `lib/pages/import`、`lib/bloc/import` 無硬編碼中文或英文字串

## 7. 驗證

- [x] 7.1 `dart format .`
- [x] 7.2 `flutter analyze --no-pub`（0 error／0 warning，info 如實回報）
- [x] 7.3 `flutter test` 全綠
- [x] 7.4 `flutter build apk --debug` 通過。最終 `minSdkVersion=24`（Flutter 預設值，未手動指定即滿足 mobile_scanner 的 21）；合併後的 manifest 含 `android.permission.CAMERA`。**ML Kit bundled 模型在 APK 內約 14.3 MB（未壓縮）**，高於 design D2 估的 2–3 MB → 見下方後續事項
- [~] 7.5 實機（SM-T500，Android 12 / API 31，zh-TW、亮色）。**已驗**：掃描入口只在 Android 出現；權限對話框正常跳出；允許後相機預覽啟動且雙碼進度正確顯示；拒絕後顯示 `einvoicePermissionDenied` 與「前往設定」「改為手動新增」兩個出口；「前往設定」確實開啟系統設定頁（`InstalledAppDetails`）。**修正兩個實機才會現形的缺陷**：`ensurePermission()` 的雞生蛋（design D9 附註）、「前往設定」原本只做重試（design D13）。**未驗**：掃真實紙本發票（需實體發票，左→右／右→左、重複掃同一張、逐列排除後匯入）、暗色主題、en 語系（後三者由 widget test 覆蓋）
- [x] 7.6 `openspec validate --all --strict --no-interactive`
