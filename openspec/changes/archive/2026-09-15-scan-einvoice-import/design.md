## Context

動機見 proposal.md「Why」。這裡只記錄影響實作方式的現況與限制：

- **建議機制已經存在**。`FoodSuggestionEngine`（`lib/models/food_suggestion.dart`）已經實作「名稱 → 類型／單位／到期日」的三段式推導（使用者歷史模板 → 內建 `assets/data/food_presets.json` 對照表 → 未知），並且已經用「最長命中關鍵字優先」處理過「牛奶 vs 牛奶糖」這類問題。本 change **不重寫這一段**。
- **名稱正規化已經存在**。`normalizeFoodName()`（`lib/models/food_item.dart`）已處理全形轉半形、空白收斂、小寫化，且分群、模板比對、排行榜都共用它。品名清洗必須接在它後面，不能另起一套。
- **`FoodItem` 已有本 change 需要的所有欄位**：`priceTotal`、`storageDate`、四種精度的期限（`ExpiryValue`）、`storageLocationId`。**不需要動 Hive schema**。
- **偏好設定已有去處**。`PreferencesRepository`（SharedPreferences）已經在管「清單分群方式」「位置是否種過」這類不需備份的小設定。
- **測試慣例已定**：`HiveTestEnv` + `makeFood`／`makeUsed` fixture、`wrapForTest()` 提供 l10n delegates 與明暗主題、widget test 用 `mocktail` 的 MockBloc 取代真實 Bloc。
- **限制**：桌面與 Web 沒有 `mobile_scanner` 的相機實作，但專案必須維持可編譯（AGENTS.md）。

## Goals / Non-Goals

**Goals:**

- 發票解析與品名清洗是**純 Dart、零 Flutter 依賴**，可以用文字 fixture 完整測試，不需要相機、不需要 widget binding。
- 任何一步失敗都有明確的、使用者看得懂的出口；**永遠不會卡死在掃描頁**。
- 掃描與解析解耦：Bloc 不知道 `mobile_scanner` 的存在，測試不需要相機。

**Non-Goals:**

- 不追求高命中率的品名對應。命中率由 `food_presets.json` 的規模決定，那是 `offline-item-normalization` 的題目；本 change 只負責把管線接起來，並保證**沒命中也能順利匯入**（類型 `others` + 期限未知，使用者自己改）。
- 不做掃描的效能最佳化（連續掃描節流、對焦控制）除非實機上明顯有問題。
- 不處理發票作廢、折讓、退貨。

## Decisions

### D1：只做發票 QR，不做商品條碼、不做 OCR

發票 QR 是**唯一**免費、離線、結構化且涵蓋整筆採購的資料來源。商品條碼一次只有一項且需要外部商品資料庫（台灣商品在 Open Food Facts 的命中率低）；OCR 需要模型或雲端服務。先把投報率最高的做完。

**替代方案**：條碼 + Open Food Facts 查詢 → 命中率不足以支撐「取代手動輸入」的假設，留待獨立評估。

### D2：`mobile_scanner` 7.4.2

BSD-3、pub points 160/160、2300+ likes、月下載約 139 萬、publisher `steenbakker.dev` 持續維護。Android 走 CameraX + ML Kit，iOS 走 AVFoundation。

- **版本約束**：`mobile_scanner: ^7.4.2`。
- **平台需求**：Android 需 `CAMERA` 權限與 `minSdk >= 21`（專案用 `flutter.minSdkVersion`，Flutter 3.47 的預設值已高於此，實作時以 `flutter build apk --debug` 實際確認，若被擋則在 `android/app/build.gradle` 明確指定並記錄於此）。iOS 需 `NSCameraUsageDescription`；該字串走 `InfoPlist.strings` 以支援 zh／en。
- **APK 體積**：ML Kit barcode scanning 會讓 APK 變大約 2–3 MB。若實測超出可接受範圍，改用 Google Play Services 動態下載版本（`play-services-mlkit-barcode-scanning`），代價是首次掃描需要下載模型。先用預設的 bundled 版本，量到再說。
  - **實測（2026-09-15）**：bundled 模型在 debug APK 內約 **14.3 MB（未壓縮）**，遠高於這裡估的 2–3 MB。最終 `minSdkVersion=24`（Flutter 預設值即滿足需求，不必手動指定）。發 release 前應評估切換到動態下載版本——見「後續事項」。

**替代方案**：`ai_barcode_scanner`（包了一層 UI，但我們要自己的掃描 UI，多一層沒有好處）、`simple_barcode_scanner`（pub points 較低、維護較弱）、`flutter_qr_bar_scanner`（依賴已停用的 Firebase Mobile Vision）。

### D3：解析器是純 Dart，以 fixture 驅動

`lib/domain/einvoice/` 不 import 任何 `package:flutter`。`EInvoiceQrParser.parse(left, right)` 吃兩個字串、吐 `EInvoice`（含 `EInvoiceItem` 清單）或 `EInvoiceParseFailure`。

真實掃到的字串（**去除統編與加密驗證資訊**）存成 `test/fixtures/einvoice/*.txt`，測試從檔案讀。理由：官方規格會改版，改版時只要加 fixture 就能重現問題，不必翻實作。

### D4：雙碼配對放在 Bloc 的狀態機，不放在解析器

解析器是無狀態的純函式；「已經掃到左碼、還在等右碼」是**互動狀態**，屬於 `ImportBloc`：

```
ImportInitial
  → ImportScanning(left?, right?, message)     掃到一個就更新，兩個齊了自動前進
  → ImportDrafts(invoiceNumber, drafts)        逐列編輯／排除
  → ImportSubmitting → ImportDone(count)
  → ImportFailure(reason)                      每種 reason 對應一個 l10n key
```

配對規則：右碼以 `**` 起始。左碼的發票號碼是配對鍵——右碼本身不含發票號碼，所以「同一張」的判定改為**同一次掃描工作階段內**取得，並在左碼宣告的品目筆數已被涵蓋時直接前進（見 spec 的「左碼宣告的品目筆數已由左碼完整涵蓋」情境）。這比 skill 裡「10 秒內」的時間窗更可靠：使用者對焦慢不該讓已掃到的碼失效。

`ImportScanning` 之外的狀態都不持有相機。

### D5：品名清洗是保守的剝除，不是猜測

`ProductNameCleaner.clean(raw)` → `CleanedProductName(coreName, amount?, unit?)`，四步：

1. `normalizeFoodName()`（沿用既有）
2. 剝除 `【】()（）[]` 與其內容
3. 剝除雜訊詞表：促銷（特價、量販、加購、第二件、促、折）、通路前綴、溫層（冷藏、冷凍、常溫）、常見品牌。雜訊詞表是**資料**，放 `assets/data/`，不是寫死在程式裡
4. 以正則抽規格：`(\d+(?:\.\d+)?)\s*(ml|cc|公撮|毫升)` → milliliter、`(g|公克|克)` → gram、`(\d+)\s*(入|顆|個|包|盒|罐|瓶|條)` → 對應 `Unit`

**清洗只做剝除，不做替換或推論**。剝到空字串就退回原始品名（spec 有此情境）。理由：錯誤的剝除會讓使用者看到一個他不認識的名字，比看到冗長的原始品名更糟。

### D6：重用 `FoodSuggestionEngine`，不寫第二套 mapper

`InvoiceDraftMapper` 只做三件事：呼叫 cleaner、把 `coreName` 丟給 `FoodSuggestionEngine.suggest()`、把發票的日期與金額疊上去。規格抽出的 amount／unit **覆蓋**建議機制的值（spec 明定）。

這讓「品名對應變準」這件事有單一施力點：把 `food_presets.json` 做大，快速新增與發票匯入**同時**變準。如果另寫一套 mapper，兩條路徑會漸行漸遠。

### D7：`FoodItemDraft` 是可編輯的中介模型，不是 `FoodItem`

草稿需要承載「這一列還沒確認」「這一列被排除」「這一列的名稱是清洗失敗的原始值」這些**只存在於匯入流程**的狀態。直接用 `FoodItem` 會逼我們在正式模型上加匯入專用欄位。

```dart
class FoodItemDraft {
  final String sourceLine;      // 原始品名，供使用者對照發票
  final String name;            // 清洗後（可編輯）
  final FoodItemType type;
  final double? amount; final Unit? unit;
  final ExpiryValue expiry;
  final String? storageLocationId;
  final int? priceTotal;
  final bool excluded;
  final bool needsReview;       // 建議機制沒命中
  FoodItem toFoodItem({required String id, required DateTime storageDate});
}
```

`toFoodItem()` 產生 id（`uuid`，與既有新增一致）後走既有的 `FoodItemListAdd`。**不新增 Bloc 事件**——批次就是連續派發，`FoodItemListBloc` 完全不需要改。

> 若實機上批次派發造成明顯的逐筆重繪，再評估新增 `FoodItemListAddMany`；先不預先最佳化。

### D8：已匯入發票號碼存 SharedPreferences，不進 Hive

發票號碼是**純設定性資料**：不需查詢、不需排序、不該進備份（換裝置後重掃同一張舊發票是合理行為）。放 Hive 要付 typeId、adapter、build_runner、遷移驗證的成本，換不到任何好處。

`PreferencesRepository` 加兩個方法，並**保留上限 200 筆**（FIFO）避免無限成長：

```dart
List<String> get importedInvoiceNumbers;
Future<void> markInvoiceImported(String invoiceNumber);
```

### D9：`ScannerService` 介面隔離相機

```dart
abstract interface class ScannerService {
  Stream<String> get codes;    // 掃到的原始字串
  Future<ScannerPermission> ensurePermission();
  Future<void> dispose();
}
```

`MobileScannerService` 是唯一 import `mobile_scanner` 的檔案。測試用 `FakeScannerService` 直接往 stream 餵 fixture 字串——**Bloc 測試完全不需要相機、不需要 widget binding**。

> **實機修正（2026-09-15，SM-T500）**：`ensurePermission()` 原本直接呼叫
> `controller.start()`，結果在實機上永遠回報「沒有可用的相機」。原因是
> `mobile_scanner` 的 `start()` 會等 `MobileScanner` widget 掛載，逾時（500ms）
> 就丟 `controllerNotAttached`；而那個 widget 在原本的設計裡要等權限通過才會被畫出來
> ——雞生蛋。
>
> 改法有兩處，缺一不可：
> 1. controller 用預設的 `autoStart`，`ensurePermission()` **不主動呼叫 start**，
>    改為監聽 controller 的 `ValueNotifier`，等 `isRunning` 或 `error` 出現再轉成權限狀態（10 秒逾時）。
> 2. `ScanInvoicePage` 在 `ImportInitial` 就要把預覽掛進樹裡（上面疊一個 spinner），
>    否則 `autoStart` 永遠不會被觸發。
>
> 這是單元測試與 widget test 都抓不到的一類問題（兩者都沒有真正的平台通道），
> 只有實機會現形。`scan_invoice_page_test.dart` 已補上「初始狀態必須掛載預覽」的迴歸測試。

### D10：平台閘門在入口，不在 Bloc

食物分頁的掃描入口以 `Theme.of(context).platform` 判斷（`TargetPlatform.android`／`iOS` 才顯示），而不是 `dart:io` 的 `Platform`——後者在 Web 上會編譯失敗。Bloc 與 domain 層完全平台無關。

### D13：「前往設定」用 MethodChannel，不引入權限套件

Android 上使用者選「不允許」後權限會被標成 `USER_FIXED`，App 再也叫不出權限對話框
——此時「重試」毫無意義，唯一的出路是系統設定。

為此引入 `permission_handler` 或 `app_settings` 不划算（proposal 的範圍上限是一個新套件）。
改用一個 MethodChannel（`food_savior/app_settings`）：原生端在 `MainActivity.kt`，
發 `ACTION_APPLICATION_DETAILS_SETTINGS` intent；Dart 端是 `AppSettingsOpener`，
未實作的平台（iOS、桌面、測試）回傳 false 而不丟例外。

iOS 端尚未實作（需要 `UIApplication.openSettingsURLString`），列為後續事項。

### D11：時鐘可注入

`InvoiceDraftMapper({DateTime Function() now})`。發票日期來自發票本身，但「建議到期日 = now + 對照表天數」要用可注入的時鐘，否則期限邏輯無法測試（AGENTS.md 硬性要求）。

> 注意：草稿的 `storageDate` 用**發票日期**，建議到期日則從發票日期起算，不是從 `now` 起算——使用者可能隔幾天才掃。`now` 只用於狀態推導。

### D12：失敗分類與 l10n 一一對應

```
ParseFailureReason.tooShort          → einvoiceParseFailed
ParseFailureReason.unsupportedBig5   → einvoiceEncodingUnsupported
ParseFailureReason.codeMismatch      → einvoiceCodeMismatch
ParseFailureReason.itemsIncomplete   → einvoiceItemsIncomplete（警告，非阻斷）
PermissionResult.denied              → einvoicePermissionDenied
PermissionResult.noCamera            → einvoiceCameraUnavailable
```

`itemsIncomplete` 是**警告不是失敗**：解析到幾筆就匯入幾筆，提醒使用者自行補齊，比整張作廢好。

## Risks / Trade-offs

- **官方 QR 規格改版，解析器失效** → fixture 驅動的測試讓改版可重現；`einvoiceParseFailed` 永遠提供「改為手動新增」，規格改版不會讓使用者完全無法記錄。實作前到財政部電子發票整合服務平台下載當期《電子發票證明聯二維條碼規格》並在本檔記錄版本與日期。
- **真實 POS 品名格式無法窮舉，清洗結果不理想** → 清洗只做保守剝除且每一列都可編輯；`needsReview` 讓沒命中的列在 UI 上被看見。最壞情況等於「名稱要自己改，但數量、日期、金額都省了」，仍優於全手動。
- **Big5 品名無法解碼** → 明確告知並退回手動輸入，不顯示亂碼。若實機遇到 Big5 的比例偏高，再評估引入查表解碼（`charset_converter` 之類），列為後續 change。
- **ML Kit 讓 APK 變大** → 先量再決定是否改用動態下載版本（見 D2）。
- **相機權限被拒後使用者流失** → 權限說明畫面必須給「改為手動新增」的出口，不是只給「前往設定」。
- **發票上有非食物品項（塑膠袋、面紙）** → 逐列排除是預設互動，不是隱藏功能；`needsReview` 標示通常正好落在這些品項上。
- **隱私**：發票含買方／賣方統一編號與加密驗證資訊。這些**只在記憶體中存在於解析當下**，不寫入任何儲存、不進備份；只有發票號碼（用於防重複）與使用者確認後的食物品項會落地。測試 fixture 必須先去識別化。

## Migration Plan

無資料遷移：不改 Hive schema、不改既有資料的讀寫。

- **上線**：新增套件 → Android／iOS 權限設定 → `flutter build apk --debug` 確認 Gradle 與 minSdk → 實機掃真實發票。
- **回滾**：移除食物分頁的掃描入口即可停用整個功能（domain 層是純函式，留著不影響任何既有行為）；完整回滾再移除套件與權限宣告。

## 後續事項（實機驗證後確認，不阻擋本 change）

1. **ML Kit 體積**：bundled 模型佔約 14.3 MB。發 release 前評估改用 `play-services-mlkit-barcode-scanning` 動態下載版本（Gradle 設定差異，代價是首次掃描要下載模型）。
2. **iOS 的「前往設定」**：`AppSettingsOpener` 目前只有 Android 原生端，iOS 需補 `UIApplication.openSettingsURLString`；未實作時回傳 false 不會丟例外。
3. **真實發票的解析命中率**：尚未以真紙本發票驗證過（見 tasks 7.5）。第一次拿到真實字串時存成 fixture 並補測試。
4. **品名對應命中率**：`food_presets.json` 目前的規模只涵蓋常見品項，未命中就是 `others` + 期限未知。這是 `offline-item-normalization` 的題目。

## Open Questions

- 實機上「兩個 QR 都要掃」的引導是否夠清楚，或需要更明顯的圖示提示？初版用兩行文字進度，**待真實使用後再決定**是否需要圖示；只影響掃描頁的視覺呈現，不影響 specs、資料流或任務拆解。
