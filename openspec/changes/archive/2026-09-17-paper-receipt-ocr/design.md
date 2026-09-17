## Context

動機見 proposal.md「Why」。影響作法的現況：

- **管線的後半段已經存在**。`ProductNameCleaner` → `FoodSuggestionEngine` → `FoodItemDraft` → `ImportDraftsPage` → `FoodItemListAdd` 這一整條是 `scan-einvoice-import` 與 `faster-expiry-entry` 蓋好的，而且與「品項從哪來」無關。本 change 只需要接上前半段。
- **動態下載模型的機制已經設好**。`unbundled-scanner-model` 在 manifest 放了 `com.google.mlkit.vision.DEPENDENCIES`（值為 `barcode`），加上 `ocr` 就會讓中文辨識模型同樣在安裝時備妥。
- **不可用狀態的處理模式已經有前例**。`ScannerPermission` 的三態（拒絕／沒有相機／元件尚未就緒）與各自的出口，直接照抄到 OCR。
- **`google_mlkit_text_recognition` 0.17.1 提供版面座標**（已查證）：

  ```dart
  TextRecognizer({this.script = TextRecognitionScript.latin});
  enum TextRecognitionScript { latin, chinese, devanagiri, japanese, korean }

  class TextLine    { String text; List<TextElement> elements; Rect boundingBox; double? confidence; double? angle; ... }
  class TextElement { String text; List<TextSymbol> symbols;   Rect boundingBox; double? confidence; double? angle; ... }
  ```

  `boundingBox` 是本 change 整個解析策略的地基。沒有它就只剩下對一整段文字跑正則，而那對收據是行不通的。

- **測試機很弱**：SM-T500、Snapdragon 662、2.64 GiB RAM。一張高解析度照片在記憶體裡就是幾十 MB，辨識期間要小心。

## Goals / Non-Goals

**Goals:**

- 版面解析是**純 Dart、零 Flutter 依賴**，fixture 是「文字 + 座標」的 JSON 而不是圖片，所以測試不需要 ML Kit、不需要相機、不需要 widget binding。
- 解析不出來的時候誠實說「解析不出來」，而不是硬擠出幾個看起來像品項的垃圾。
- 讓「解析品質」成為一個可量測、會擋回歸的數字，比照 `offline-item-normalization` 的命中率基準。

**Non-Goals:**

- 不做影像前處理、不做長收據拼接、不做手寫辨識（見 proposal 非目標）。
- 不追求高正確率。目標是「比全手打快」，不是「不用改」。

## Decisions

### D1：版面幾何優先於正則，這是整個 change 的核心賭注

收據沒有規格，但有**版面**：品名靠左、數字靠右、一列一項。把辨識結果當成一整段文字去跑正則，會在第一張排版稍有不同的收據上崩掉；用座標分列分欄則對版面變化有韌性。

演算法（純 Dart，輸入是 `List<OcrTextElement>`，每個帶 `text` 與方框）：

1. **分類 token**：數字、識別碼（連續 8 位以上的純數字：條碼、序號、電話）、稅別與運算符（`TX`、`X`、`=`、`*`）、短代碼（`1P`）、文字。**識別碼要在數字之前判**，否則 13 碼條碼會被當成一個 4 兆元的價格。
2. **分列**：兩個元素的方框垂直重疊超過較矮者高度的一半 → 同一列。依 `top` 排序列，列內依 `left` 排序。
3. **分欄**：從最右側往左取連續的數字當數值尾段（稅別與運算符永遠可跳、短代碼只在已抓到數字後才跳），其餘是品名。品名側的識別碼不是品名——合法長度的記成條碼，其餘丟掉。
4. **配對落單的數字列**：「整列只有數字」的列配回相鄰的品名列，**上下兩個方向都試**（台糖是品名在上、大買家是金額在上），但只配到「像品項」的列上，不配到中繼資料上。
5. **表頭表尾**：第一個像品項的列之前全部丟掉（店名、地址、電話）；最後一個像品項的列之後、沒有數字的列全部丟掉（稅務宣導、會員資訊）。「像品項」= 有字、不是雜訊詞、不是 `標籤:值`。
6. **解讀數值尾段**：3 個 → 數量、單價、金額，**數量取兩者較小的**（各家欄位順序不同：麥當勞單價在前、台糖數量在前）；2 個 → 單價、金額；1 個 → 金額；0 個 → 都未知。

**為什麼從右往左**：品名長度不定，數字欄位固定靠右。從左往右要先知道品名在哪裡結束，那是循環論證。

**為什麼不用 `TextLine` 直接當列**：ML Kit 的 `TextLine` 是它自己的分行結果，收據上品名與金額常常被分在不同的 `TextBlock`（中間隔著大片空白）。用 `TextElement` 加自己的垂直重疊判定才抓得到同一列。spec 有對應的 Scenario。

**為什麼 `標籤:值` 一律是中繼資料**：`NO:80050683`、`TEL:02-8953-9111`、`機:020102`、`頁:2`、`店名:台北店`——店家與 POS 系統不可能窮舉，但「開頭一到六個字接冒號」這個形式非常穩定，而且真的品名幾乎不會長這樣。

> 這一段不是一開始就長這樣。原始設計只有第 2、3、6 步，而且第 6 步假設數量在前。
> 四張真實收據（麥當勞、台糖量販、電子發票明細、大買家收銀機發票）**每一張都是 0 分**
> 進來的，各自打破一個假設，才長出第 1、4、5 步。細節見基準測試的歷程註記。

### D2：`TextRecognitionService` 介面隔離 ML Kit

與 `ScannerService` 同一個手法：

```dart
abstract interface class TextRecognitionService {
  Future<RecognizerAvailability> ensureAvailable();
  Future<OcrResult> recognize(String imagePath);   // OcrResult 是我們自己的純 Dart 型別
  Future<void> dispose();
}
```

`OcrResult` / `OcrTextElement` 是本專案的型別，**不是 ML Kit 的**。這讓版面解析器與 Bloc 完全不知道 ML Kit 存在，fixture 也就能是純 JSON。唯一 import `google_mlkit_text_recognition` 的是實作檔。

**實作備註（2026-09-16）**：原本畫的 `ensureAvailable()` 拿掉了。ML Kit 沒有「模型是否已就緒」的查詢 API，只有 `processImage` 失敗時才知道，所以介面只剩 `recognize(path)` 回傳 sealed `RecognitionResult`（`RecognitionSuccess` ／ `RecognitionUnavailable`）與 `dispose()`。相機／相簿權限則由另一個介面 `ReceiptImagePicker` 以 `ImagePickResult`（`ImagePicked` ／ `ImagePickCancelled` ／ `ImagePickDenied`）回報——權限是取照片的事，不是辨識的事。

**Gradle 相依（2026-09-16 實作時發現）**：`google_mlkit_text_recognition` 0.17.1 的 Android 端把 Latin 模型以 `implementation("com.google.mlkit:text-recognition")` **內建**進 APK，中文等其他文字系統只有 `compileOnly`——App 不自己加相依，`TextRecognizer(script: chinese)` 在實機會直接失敗。本專案在 `android/app/build.gradle` 加 `play-services-mlkit-text-recognition-chinese:16.0.1`（Play Services 動態下載版），並用 `configurations.all { exclude group: 'com.google.mlkit', module: 'text-recognition' }` 把 plugin 內建的 Latin 換成 `play-services-mlkit-text-recognition:19.0.1`，與條碼模型同一套「APK 不帶模型」策略（見 `unbundled-scanner-model`）。iOS 端 plugin 的 podspec 同樣只帶 Latin，需在 `ios/Podfile` 加 `pod 'GoogleMLKit/TextRecognitionChinese'`（待 macOS 上建置驗證）。

**實機驗證的 fixture 倒出**：`node tool/dump_receipt_fixture.cjs <name>` 從 `adb logcat` 撈最後一次辨識的 `[receipt-ocr-fixture]` 行，寫成 `test/fixtures/receipts/<name>.json`，`expected` 留白等人手標註。

### D3：影像來源用 `image_picker`，不用 `camera`

只需要一張靜態照片，`image_picker` 一個呼叫就給完（含系統相機 UI、Android 13+ 的 Photo Picker）。`camera` 套件要自己管生命週期、預覽、對焦、旋轉——為了拍一張照片不值得。

AGENTS.md 已記錄「未來做頭像上傳時再加回 `image_picker`」，這裡提前加回。

**記憶體**：`image_picker` 的 `maxWidth` / `imageQuality` 要設限（初步取長邊 2000px），否則在 2.64 GiB 的機器上一張原圖加辨識緩衝容易觸發 OOM。實機量到再調。

### D4：每一列都標待確認，與發票匯入不同

發票匯入只有未命中建議的列才標 `needsReview`，因為 QR 的資料是確定的。OCR 不是——它可能把「8」讀成「B」、把兩列併成一列、把金額當成數量。

所以收據草稿**全部**標待確認。這會讓使用者多看幾眼，但那正是重點：解析錯了而他沒發現，比要求他多看一眼糟得多。這條寫進了 spec，不是實作細節。

### D5：解析器不猜，不夠就說不夠

沒有數值尾段的列**仍然**產生品項（品名本身就有價值，數量期限使用者本來就要填）；但整張收據解析不出任何品項時，明確回報 `receiptNoItemsFound` 並提供重拍，不硬擠。

同理，日期擷取失敗就用今天並照常進行——日期不是阻擋匯入的理由。擷取到未來日期視為辨識錯誤（`8` 讀成 `9` 之類），也改用今天。

### D6：fixture 是座標 JSON，不是圖片

```json
{
  "name": "convenience-store-thermal",
  "elements": [
    {"text": "鮮奶", "left": 40, "top": 300, "right": 140, "bottom": 336},
    {"text": "2",    "left": 420, "top": 302, "right": 448, "bottom": 334},
    {"text": "65",   "left": 500, "top": 302, "right": 556, "bottom": 334},
    {"text": "130",  "left": 620, "top": 302, "right": 700, "bottom": 334}
  ],
  "expected": [{"name": "鮮奶", "quantity": 2, "amount": 130}]
}
```

好處：測試完全不需要 ML Kit、不需要圖片、跑得飛快，而且真實收據的辨識結果可以**直接倒出來變成 fixture**——實機上辨識一次，把 `OcrResult` 序列化存檔，就得到一個真實版面的迴歸案例。

這也是把「解析品質」變成數字的方法（spec 的最後一條 Requirement）。

### D7：先做基準，再調解析器

比照 `offline-item-normalization` 的教訓：先建立基準與門檻，再動邏輯。否則無從判斷調整是進步還是退步，也無從發現「修好 A 版面弄壞 B 版面」。

門檻的定義：對每張基準收據，**正確解析出的品項數 ÷ 人工標註的品項數**，取所有收據的平均。品名字串要完全相符（清洗前），數量與金額有標註才比。

## Risks / Trade-offs

- **這是整個 roadmap 上風險最高的一個 change**。發票 QR 有官方規格，字典有明確的正確答案，但「收據長什麼樣」沒有上界。緩解：基準測試 + 每列待確認 + 隨時可退回手動。**如果真實收據的正確率低到使用者寧願手打，這個 change 應該被回滾而不是繼續加規則。**
- **熱感應紙褪色、皺摺、反光** → OCR 品質直接崩。緩解只有拍照前的提示；影像前處理列為後續事項。
- **ML Kit 中文模型對台灣收據的字體（點陣、窄體）表現未知** → 必須實機驗證，不能只靠 fixture。
- **品名與金額分屬不同 `TextBlock`** → 正是 D1 用 `TextElement` 而非 `TextLine` 的原因；spec 有 Scenario 鎖住。
- **一列被 OCR 拆成上下兩列**（品名太長換行）→ 目前會變成兩個品項，其中一個沒有數值尾段。接受；使用者在草稿頁排除或合併。
- **記憶體**：2.64 GiB 的機器 + 高解析度照片 + 辨識緩衝。緩解見 D3；實機必須測大張照片。
- **隱私**：收據含店名、消費金額、有時有統編。照片不落地、辨識結果不落地，只有使用者確認後的食物品項會存下來——與發票匯入的處理一致。

## Migration Plan

無資料遷移：不改資料模型、不改既有流程。

- **上線**：加兩個套件 → manifest 的 `DEPENDENCIES` 加 `ocr` → iOS 加 `NSPhotoLibraryUsageDescription` → 建置 → 實機拍真實收據。
- **回滾**：移除食物分頁入口選單裡的「拍收據」即可停用整個功能（解析器是純函式，留著不影響任何既有行為）。完整回滾再移除兩個套件與權限宣告。

## Open Questions

- 拍照前的提示要做成什麼形式（純文字說明、還是帶取景框的引導）？**實機拍過真實收據再決定**，只影響拍照頁的視覺呈現，不影響 specs、資料流或任務拆解。
- 是否需要影像前處理（去斜、增強對比）？**先量原始照片的正確率再說**。若基準顯示大部分失敗來自影像品質而非解析邏輯，再開獨立 change。
