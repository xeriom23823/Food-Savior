## Why

`scan-einvoice-import` 只涵蓋**有二維條碼的電子發票證明聯**。但使用者的採購有一大塊不在這個範圍裡：傳統收據、傳統市場的手寫單、小吃店的出單機、沒開發票的攤商。這些人回到家一樣要記錄，而他們唯一的選擇是一項一項手打——也就是本 App 最大的摩擦點，原封不動。

OCR 是補上這塊的方式，而且**這條路的基礎設施你已經蓋好了**：草稿確認頁、品名清洗、`FoodSuggestionEngine`、期限快速選項、`ScannerService` 介面、Play Services 動態下載，全部可以直接重用。真正新的只有兩件事——把影像變成文字，以及把文字變回品項。

本 change 要驗證的假設：**即使解析結果不完美，「拍一張照片再改幾個欄位」仍然遠快於全手打。**

### 為什麼是 OCR 而不是語言模型

這是刻意的取捨，延續 `offline-item-normalization` 的決定。ML Kit Text Recognition 是**專用模型**：幾 MB、毫秒級、只做一件事而且做得很好。本地語言模型在測試機（SM-T500，Snapdragon 662，**2.64 GiB RAM**）上光載入就會被系統殺掉，而且它對「把版面變成欄位」這件事並沒有比幾何規則更強。

## What Changes

### A. 拍照取得收據文字（新）

- 使用者從食物分頁的掃描入口選擇「拍收據」，拍一張靜態照片（或從相簿選）。
- ML Kit Text Recognition（中文 script）在裝置上辨識，得到每一段文字的內容、**版面座標**與信心值。
- 不做即時串流 OCR：收據要拿穩、對焦、整張入鏡，一張靜態照片的品質遠高於串流的任一幀。

### B. 版面解析：把文字變回品項（新，本 change 的難處）

發票 QR 有規格，收據沒有。但收據有**版面**——品名靠左、數字靠右、一列一項。所以解析靠的是幾何而不是正則：

- 依 `boundingBox` 的垂直重疊把文字元素分群成「列」。
- 每一列從右往左取連續的數字當數值尾段（數量／單價／金額），其餘是品名。
- 過濾表頭表尾（店名、統編、發票號碼、總計、找零、謝謝光臨、電話、地址）。
- 盡力從整張收據找出日期（民國或西元），作為 `storageDate`；找不到就用今天。

### C. 草稿一律標示待確認（**與發票匯入的差別**）

OCR 的可信度遠低於 QR，所以：

- 收據匯入產生的**每一列**預設都是待確認，不像發票匯入只有未命中建議的列才標。
- 使用者必須逐列看過。這不是保守，是誠實——解析錯了而使用者沒發現，比要求他多看一眼糟得多。

### 範圍上限

一個新畫面（拍照與辨識中的狀態）、一個純 Dart 的版面解析器、兩個新套件、複用既有的草稿確認頁。**不改資料模型、不改 `FoodItemDraft`、不改既有的發票匯入流程。**

### 非目標

- **不使用任何語言模型**，不呼叫任何後端。
- 不做即時相機串流 OCR。
- 不做手寫辨識（ML Kit 的印刷體模型對手寫幾乎無效；傳統市場的手寫單這一輪不支援）。
- 不做影像前處理（去斜、增強對比、裁切）。先看原始照片的命中率，不夠再說。
- 不做多張照片拼接（長收據）。超出畫面的部分這一輪拍不到就是拍不到。
- 不支援英文以外的拉丁語系收據版面差異（國外收據能辨識就辨識，版面解析以台灣收據為準）。

## Capabilities

### New Capabilities

- `receipt-ocr-import`：從紙本收據照片建立食物草稿的完整流程——影像取得與權限、文字辨識的可用性狀態、版面解析成品項、日期擷取、信心標示，以及每一種失敗的退路。

### Modified Capabilities

- `einvoice-import`：掃描入口從「直接進入 QR 掃描」改為「先選擇掃發票或拍收據」。既有的 QR 掃描流程本身不變。

## Impact

- **Code**：`lib/domain/receipt/`（版面解析，純 Dart，新）、`lib/services/ocr/`（`TextRecognitionService` 介面 + ML Kit 實作，新）、`lib/bloc/receipt_import/`（新）、`lib/pages/import/`（拍照與辨識狀態的畫面、入口選單）、`lib/l10n/*.arb`。
- **資料模型**：**不變**。產出的是既有的 `FoodItemDraft`，走既有的草稿確認頁與 `FoodItemListAdd`。
- **Bloc 狀態**：新增 `ReceiptImportBloc`。`ImportBloc` 與 `FoodItemListBloc` 都不改。
- **l10n**：新增約 12 個 key（入口選單兩項、拍照提示、辨識中、辨識不到文字、模型尚未就緒、解析不出品項、相片權限被拒等）。
- **平台權限**：Android 已有 `CAMERA`；讀相簿在 Android 13+ 走 Photo Picker 不需權限。iOS 需 `NSPhotoLibraryUsageDescription`（`CAMERA` 的說明已存在）。
- **Dependencies**：新增 `google_mlkit_text_recognition`（412 likes、月下載約 26.9 萬、publisher `flutter-ml.dev`）與 `image_picker`（AGENTS.md 已記錄「未來做頭像上傳時再加回」，現在提前加回）。**兩個套件是本 change 的範圍上限。**
- **APK 體積**：中文辨識模型同樣走 Play Services 動態下載（沿用 `unbundled-scanner-model` 已設好的 `com.google.mlkit.vision.DEPENDENCIES`，值加上 `ocr`），不打包進 APK。
- **Risk**：**解析品質是本 change 唯一的實質風險**，而且無法用單元測試證明——測試只能證明解析器對已知版面的行為正確，不能證明真實收據的命中率。必須以真實收據照片建立基準（做法比照 `offline-item-normalization` 的命中率基準）。
- **實機**：必須用真實紙本收據驗證，且至少涵蓋熱感應紙（超商、連鎖店）與點陣列印（傳統店家）兩種。
