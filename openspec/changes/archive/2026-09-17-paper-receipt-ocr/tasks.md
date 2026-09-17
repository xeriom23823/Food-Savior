## 1. 解析基準（先做，design D7）

- [x] 1.1 `lib/domain/receipt/ocr_result.dart`：`OcrResult`／`OcrTextElement`（`text` + `Rect`），純 Dart，**不是 ML Kit 的型別**（design D2）
- [x] 1.2 `test/fixtures/receipts/*.json`：8 張——4 張自造版面 + **4 張依使用者提供的真實收據照片建立**（麥當勞、台糖量販、電子發票明細、大買家收銀機發票）
- [x] 1.3 `test/domain/receipt_parser_benchmark_test.dart`：正確解析品項數 ÷ 標註品項數，取所有收據平均；門檻寫成常數並註明實測值
- [x] 1.4 基準歷程：初版 66.7%／50.0% → 修店名誤判與落單金額後三張自造 fixture 都 100% → 補一張刁鑽版面掉到 75%／75% → 修小數 round 與品名尾端數字後 93.75%／90.0% → **加入三張真實收據後崩到 39.3%／37.1%** → 修掉稅別後綴、分隔符、`20*2`、欄位順序四項後 96.4%／94.3% → **第四張真實收據（大買家）又是 0 分** → 重寫為 token 分類＋雙向配對＋以像品項的列界定表頭表尾：**96.9%／95.0%，四張真實收據全部 100%／100%**。門檻 0.90／0.85

## 2. 版面解析（純 Dart，design D1）

- [x] 2.1 `lib/domain/receipt/receipt_layout_parser.dart`：token 分類（數字／識別碼／稅別運算符／短代碼／文字）、垂直重疊分列、列內依 `left` 排序
- [x] 2.2 從右往左取數值尾段（稅別與運算符可跳、短代碼在有數字後可跳、`20*2` 拆兩個）；3 個數字時數量取較小者；落單數字列**雙向**配回品名列；條碼記在 `ReceiptItem.barcode`
- [x] 2.3 `assets/data/receipt_noise_terms.json`：表頭表尾與結帳資訊關鍵字（資料不寫死在程式裡）
- [x] 2.4 過濾非品項的列：雜訊詞（忽略中文間空格）、`標籤:值` 中繼資料、無字元的列；表頭區與表尾宣導以「像品項的列」為界
- [x] 2.5 `lib/domain/receipt/receipt_date_parser.dart`：西元與民國、有分隔符與無分隔符（`20120323`）；排除發票期別（`101年3-4月份`）；找不到用今天；未來日期視為辨識錯誤
- [x] 2.6 `lib/domain/receipt/receipt_draft_mapper.dart`：解析結果 → `FoodItemDraft`，重用 `ProductNameCleaner` 與 `FoodSuggestionEngine`，**每一列都標 `needsReview`**（design D4）
- [x] 2.7 單元測試：分列、分欄、四種數值尾段、品名含數字不被誤切、同列跨 TextBlock、噪音過濾、日期四種情境
- [x] 2.8 資料健檢測試：`receipt_noise_terms.json` 的詞不得與 `food_presets.json` 的關鍵字衝突（比照既有的雜訊詞健檢）

## 3. 文字辨識服務

- [x] 3.1 `pubspec.yaml` 新增 `google_mlkit_text_recognition: ^0.17.1` 與 `image_picker`
- [x] 3.2 `lib/services/ocr/text_recognition_service.dart`：介面 + sealed `RecognitionResult`（成功／元件尚未就緒）；權限由 `ReceiptImagePicker` 的 `ImagePickResult` 回報（ML Kit 沒有事前查詢可用性的 API，見 design D2）
- [x] 3.3 `lib/services/ocr/mlkit_text_recognition_service.dart`：唯一 import ML Kit 的檔案；`TextRecognitionScript.chinese`；轉成自家的 `OcrResult`
- [x] 3.4 `AndroidManifest.xml` 的 `com.google.mlkit.vision.DEPENDENCIES` 值加上 `ocr`
- [x] 3.5 iOS `Info.plist` 加 `NSPhotoLibraryUsageDescription`，字串走既有的 `InfoPlist.strings`（zh／en）
- [x] 3.6 `image_picker` 設 `maxWidth`／`imageQuality` 上限，避免 2.64 GiB 機器 OOM（design D3）
- [x] 3.7 `test/helpers/fake_text_recognition_service.dart`：可餵 fixture 的測試替身

## 4. ReceiptImportBloc

- [x] 4.1 `lib/bloc/receipt_import/`：event（開始、選擇來源、影像取得、重試、草稿編輯／排除、送出）與 state（`final class` + Equatable）
- [x] 4.2 辨識不可用的三種狀態與各自出口（比照 `ScannerPermission` 的處理）
- [x] 4.3 沒有文字／沒有品項兩種空結果的分別回報
- [x] 4.4 草稿送出走既有的 `onItemReady` 回呼，**不新增 `FoodItemListBloc` 事件**
- [x] 4.5 bloc_test：完整成功流程、取消取得影像、辨識不可用三態、沒有文字、沒有品項、逐列排除、送出

## 5. 畫面

- [x] 5.1 食物分頁的掃描入口改為來源選擇（掃發票／拍收據），各有說明
- [x] 5.2 `lib/pages/import/scan_receipt_page.dart`：拍照前提示、辨識中、三種不可用狀態、兩種空結果
- [x] 5.3 草稿確認**重用既有的 `ImportDraftsPage`**，不另寫一頁
- [x] 5.4 只用 design-system token；`grep` 確認新程式無 `Colors.`／`Color(0x`／`fontSize:`
- [x] 5.5 widget test：來源選擇、拍照提示、三種不可用狀態、兩種空結果；明暗 × zh／en
- [x] 5.6 `grep` 確認新程式無硬編碼中文或英文

## 6. l10n

- [x] 6.1 `intl_zh.arb`／`intl_en.arb` 新增 spec 出現的所有 key（`receiptRecognizerNotReady`、`receiptNoTextFound`、`receiptNoItemsFound`、來源選擇兩項、拍照提示、辨識中等）
- [x] 6.2 `dart run intl_utils:generate`，接著 `dart format lib/generated`

## 7. 驗證

- [x] 7.1 `dart format .`
- [x] 7.2 `flutter analyze --no-pub`（0 error／0 warning）
- [x] 7.3 `flutter test` 全綠
- [x] 7.4 `flutter build apk --debug`（新增套件與權限，必做；記錄 APK 體積變化）— debug APK 238.4 MB → 248.1 MB（+9.7 MB：ML Kit 文字辨識 client + image_picker，模型不在 APK 內；若沿用 plugin 內建 Latin 模型會是 271.8 MB）
- [x] 7.5 **實機拍真實收據**（SM-T500）：至少一張熱感應紙（超商／連鎖）與一張點陣列印（傳統店家）；記錄實際正確率 — 使用者於 2026-09-17 以 debug 建置實測後指示 archive；正確率數字未留下記錄，接續由 7.6 的 fixture 補量
- [ ] 7.6 把實機辨識結果倒成 fixture 加進基準，重跑 1.3 並記錄調整前後對照（design D6）— **未完成**：實測時的 logcat 在裝置重新連線後已清空，沒有撈到 `[receipt-ocr-fixture]`。工具 `tool/dump_receipt_fixture.cjs` 已就位，下次拍完立刻執行即可；列入 AGENTS.md 技術債
- [x] 7.7 實機記憶體：拍一張高解析度照片辨識，確認不 OOM — 使用者實測未回報閃退；image_picker 已限制長邊 2000px／品質 85（design D3）
- [x] 7.8 `openspec validate --all --strict --no-interactive`

> **停損點**：7.5 的實際正確率若低到使用者寧願手打，回報並建議回滾，不要繼續加規則硬撐（design「Risks」）。
