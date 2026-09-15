## Why

手動記錄是這個 App 最大的摩擦點。使用者從超市回來，手上一張發票、袋子裡十樣東西，要一項一項開表單填名稱、類型、數量、單位、到期日——大多數人做兩次就放棄了。沒有記錄就沒有提醒，沒有提醒就沒有減少浪費，整個產品的價值鏈斷在第一步。

台灣的電子發票證明聯上，左右兩個 QR 已經印著**品名、數量、單價**。這是現成的、免費的、離線就能解析的結構化資料。掃兩下取代填十次表單。

本 change 要驗證的假設：**把「記錄一次採購」的成本從數分鐘降到數秒，使用者才會持續記錄。** 如果掃描匯入的使用率高於手動新增，這個假設成立，後續的提醒、統計、料理推薦才有資料基礎。

## What Changes

### A. 掃描發票 QR（新）

- 新增掃描頁：相機預覽 + 左右碼掃描進度提示。發票證明聯的品項資料橫跨兩個 QR，**兩個都掃到才有完整品項**，UI 必須讓使用者知道還差哪一個。
- 只接受 `qrCode` 格式；相機權限被拒時顯示可操作的說明與「前往設定」，不是空白畫面。
- 同一張發票的判定：右碼以 `**` 開頭，且與左碼在同一次掃描工作階段內取得。

### B. 電子發票 QR 解析（新，純 Dart）

- `EInvoiceQrParser`：左碼固定 77 字（發票字軌號碼、民國日期、隨機碼、銷售額與總計額為 16 進位、買賣方統編、加密驗證資訊），其後為 `:` 分隔的品項區；右碼以 `**` 起始，接續剩餘的 `品名:數量:單價` 三元組。
- 中文編碼參數支援 UTF-8（`1`）與 Base64（`2`）；Big5（`0`）不解碼，回報 `unsupportedEncoding` 並引導手動輸入。
- **品名內可能含 `:`**：切割一律以左碼宣告的「品目筆數」為準，不做 naive split。

### C. POS 品名清洗與草稿轉換（新，純 Dart）

- `ProductNameCleaner`：把 `統一AB優酪乳400ML特價` 這種 POS 品名拆成「核心名稱 + 規格」。四步——全半形正規化（沿用既有 `normalizeFoodName`）、剝除括號內容、剝除促銷／通路／溫層雜訊詞、抽出規格（`400ML` → 400 milliliter、`10入` → 10 piece、`約300g` → 300 gram）。
- `InvoiceDraftMapper`：清洗後的名稱餵給**既有的** `FoodSuggestionEngine`（模板 → 內建對照表 → 未知），得到類型、單位、建議到期日；發票日期作為 `storageDate`，單價 × 數量作為 `priceTotal`。
- 不新增任何猜測機制：類型與效期的來源仍然是 design D15／D17 已經決定的離線對照表。

### D. 草稿確認與批次加入（新）

- 匯入頁列出草稿，每列可編輯名稱、類型、數量、單位、期限、位置；可逐列排除（發票上的塑膠袋、面紙不是食物）。
- 「全部加入」一次派發；沒有任何一列在使用者確認前寫入資料。
- 重複匯入防護：已匯入過的發票號碼記在 `PreferencesRepository`，再次掃到同一張時明確告知並讓使用者決定要不要再匯入一次。

### 範圍上限

兩個新畫面（掃描頁、草稿確認頁）、一個新 Bloc、三個純 Dart 類別、一個新套件（`mobile_scanner`）、一個 Android 權限（`CAMERA`）。不改 Hive schema、不改既有的新增／編輯／處理流程。

### 非目標

- **不做載具綁定**（財政部電子發票 API）：需要 AppID、後端代理與法規處理，是獨立 change。
- **不做商品條碼掃描**：EAN/UPC 查名稱是另一條路徑（需要外部商品資料庫），本 change 只做發票 QR。
- **不做 OCR 紙本收據**：非電子發票的收據留待之後評估。
- **不使用任何 LLM 或後端服務**：品名對應完全離線，延續 design D15 的決定。
- 不做匯入紀錄的歷史頁面（只防重複，不做可瀏覽的清單）。

## Capabilities

### New Capabilities

- `einvoice-import`：電子發票證明聯 QR 的掃描、解析、品名清洗、草稿產生與批次匯入，含相機權限、雙碼掃描進度、重複發票防護與各種解析失敗的處理。

### Modified Capabilities

- `food-inventory`：新增「批次匯入」作為建立食物的第三種途徑（既有的單筆表單與一行快速新增不變）。既有的欄位驗證規則在匯入時同樣適用，且匯入產生的草稿在使用者確認前不得寫入。

## Impact

- **Code**：`lib/domain/einvoice/`（`EInvoiceQrParser`、`EInvoice`／`EInvoiceItem`，新）、`lib/domain/import/`（`ProductNameCleaner`、`InvoiceDraftMapper`、`FoodItemDraft`，新）、`lib/services/scanner/`（`ScannerService` 介面 + `mobile_scanner` 實作，新）、`lib/bloc/import/`（新）、`lib/pages/import/`（新兩頁）、`lib/repositories/preferences_repository.dart`（加兩個方法）、食物分頁的匯入入口、`lib/l10n/*.arb`。
- **資料模型**：**不改 Hive schema、不新增 typeId、不改任何既有欄位**。已匯入的發票號碼存在 SharedPreferences（純設定、不需備份），沿用既有的 `PreferencesRepository`。匯入產生的是一般的 `FoodItem`，走既有的 `FoodItemListAdd`。
- **Bloc 狀態**：新增 `ImportBloc`（掃描進度 → 草稿清單 → 逐列編輯 → 批次送出）。既有的 `FoodItemListBloc` 不改事件與狀態，只是多一個呼叫端。
- **l10n**：新增約 25 個 key（掃描提示、左右碼進度、權限被拒、解析失敗的四種原因、草稿頁動作、重複發票警告），zh／en 各一份。
- **平台權限**：Android `CAMERA`（`AndroidManifest.xml`）；iOS `NSCameraUsageDescription`（`Info.plist`，多語走 `InfoPlist.strings`）。minSdk 需符合 `mobile_scanner` 要求，若現行設定較低則一併調整並記在 design.md。
- **Dependencies**：新增 `mobile_scanner`（Android ML Kit／iOS AVFoundation）。這是本 change 唯一的新套件。
- **Risk**：官方 QR 規格會改版，且真實 POS 品名格式五花八門。以 fixture 驅動的解析器測試 + 「解析失敗一律可退回手動輸入」兩道防線處理；任何一步都不得讓使用者卡死在掃描頁。
- **平台**：桌面與 Web 沒有 `mobile_scanner` 支援 → 掃描入口在非行動平台隱藏，但專案仍須可編譯。
