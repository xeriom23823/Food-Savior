## Context

現況：`ThemeCubit` 內以 `ThemeData` 硬寫兩套主題；pages 大量硬編碼顏色、字級、字串；`food_item_list_page.dart` 超過 1000 行並含商業邏輯；底部導覽使用 `curved_labeled_navigation_bar`。設計系統重製要在**不改任何行為**的前提下重寫呈現層，因此先補 Bloc 測試當安全網，再分頁替換。

## Goals / Non-Goals

- Goals：把「一項食物」的資料模型做到能記下真實情境（模糊期限、開封、剩餘比例、自訂位置、成本、浪費原因），並以 token 化的設計系統與元件庫呈現；五分頁重製、三態、明暗與 zh／en 一次到位、pages 邏輯下沉。
- Non-Goals：條碼掃描與發票匯入、本機通知排程、AI 猜測、雲端同步、平板版面、動態取色、onboarding。

> 範圍變更紀錄（2026-09-15）：原本明列「不新增資料欄位／不改 Hive schema」，經使用者釐清後改為與資料模型一起做。理由與取捨見 proposal 的 Why。

## Decisions

### D1. 色彩來源：`ColorScheme.fromSeed` + 少量手動覆寫

- 決定：以品牌綠（現行 `#4CAF50`，可在實作時微調到更沉穩的 `#3E8E5A` 系）為 seed 產生明暗 `ColorScheme`（`dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot`），再手動覆寫 `tertiary`（暖黃強調）。
- 理由：M3 產生器保證對比與 surface 階層一致；手寫 12 個角色容易漏。
- 捨棄：完全手動調色（現況）—— 深色版本品質不穩。
- **已決定（2026-09-15）**：採「沉穩綠」。seed 定為 `#3E8E5A`（實作時可在 `#3A8759`–`#43955F` 間微調以達對比要求），`tertiary` 覆寫為暖黃 `#E0A100` 系；不保留現行鮮綠 `#4CAF50`。

### D2. 語意色以 `ThemeExtension<FoodStatusColors>` 提供

- fresh：綠；nearExpired：琥珀；expired：紅；consumed：藍；wasted：中性灰。明暗各一組，每組同時提供 `color` 與 `onColor`／`container`。
- 取用：`context.foodStatusColors.of(status)`（extension method）。

### D3. 字體與字級

- `NotoSansTC` 維持；`TextTheme` 用 M3 預設尺寸，`bodyMedium` 行高 1.5；數字使用 `FontFeature.tabularFigures()`。英文回退 `Roboto`（系統）。
- 不再在 `AppBarTheme.titleTextStyle` 寫死 20／w600，改用 `titleLarge`。

### D4. 間距／圓角／時長 token

- `AppSpacing`：xs 4、sm 8、md 12、lg 16、xl 24、xxl 32（`ThemeExtension` 或 `abstract final class` 常數；選常數，因為不需隨主題變）。
- `AppRadius`：sm 8、md 12、lg 16；卡片 md、sheet 上緣 lg、chip 全圓。
- `AppDurations`：short 150、medium 250、long 400 ms；curve `Curves.easeOutCubic`。

### D5. 元件庫位置與 API

- `lib/widgets/<name>.dart`，每個元件一檔、無業務相依（只吃 model 與 callback）。
- `FoodItemTile({item, onTap, onLongPress, trailing})`；`StatusChip(status)`；`ExpiryCountdown(expirationDate, now)`（`now` 可注入以便 golden／widget 測試）；`EmptyState({icon, title, description, action})`；`AppSnackBar.show(context, kind, message, {lottieAsset})`。
- `AppScaffold({title, actions, body, fab})` 統一 AppBar 樣式（`centerTitle`、無 elevation、surface tint）。

### D6. 表單：全螢幕頁

- 新增／編輯食物 → `FoodItemFormPage`（`Navigator.push`，回傳 `FoodItem?`）。理由：七個欄位 + 兩個日期選擇器，sheet 在小螢幕會捲到看不見按鈕。
- 部分使用 → `ConsumeSheet`（bottom sheet，兩個欄位）。
- 表單驗證邏輯抽到 `FoodItemFormValidator`（純 Dart，單元測試），頁面只顯示結果。

### D7. 底部導覽：改用 Material 3 `NavigationBar`

- 理由：`curved_labeled_navigation_bar` 與 M3 色彩系統不相容、無法跟隨 `NavigationBarTheme`、英文標籤易截斷。
- 影響：`app-shell-navigation` spec 只需 MODIFIED「以動畫切換」的描述（`NavigationBar` 有內建指示器動畫）；分頁順序與預設不變。
- **已決定（2026-09-15）**：改用 Material 3 `NavigationBar`，移除 `curved_labeled_navigation_bar`。

### D8. 頁面邏輯下沉

- 新增 event：`FoodItemListConsume({foodItem, quantity, usedDate})`、`FoodItemListWaste(foodItem)`；由 `FoodItemListBloc` 更新清單，並透過新的 `ConsumptionCoordinator`（或 page 同時派發 `UsedFoodItemListAdd`）寫紀錄。結果與現行 Scenario 完全一致，先以 bloc_test 鎖定。
- 剩餘數量、`UsedFoodItem` 建立、狀態推導全部離開 pages。

### D9. l10n

- 所有硬編碼字串補 key：`expiredFoodListTitle`、`foodInfo`、`isConsumed`、`processComplete`、`backup`、`restore`、`backupSuccess`、`restoreSuccess`、`restoreFailure`、`settingsSection`、`aboutSection`、`version`、`openSource`、`viewOnGitHub`、`noData`、`usedDateLabel`、`addFoodItemEmptyTitle`、`addFoodItemEmptyDescription` 等；帶參數者改用 placeholder。

### D10. 期限：四種精度，統一存成區間

- 模型：`expiryEarliest: DateTime?`、`expiryLatest: DateTime?`、`expiryPrecision: ExpiryPrecision { exact, range, monthOnly, unknown }`。
  - `exact`：earliest == latest == 該日。
  - `range`：earliest < latest（「大約 3〜5 天後」）。
  - `monthOnly`：earliest = 該月 1 日、latest = 該月最後一日。
  - `unknown`：兩者皆 null。
- **所有時間判斷一律以 `expiryEarliest` 為準**（保守估計，寧可提早提醒），`expiryLatest` 只用於呈現不確定區間與統計的「最晚可能」。
- 理由：一個欄位組同時涵蓋四種情況，狀態推導、排序、提醒只需處理「有沒有 earliest」一個分支，不必為每種精度寫一套邏輯。
- 捨棄：`DateTime? + isApproximate: bool`（無法表達月份與區間寬度）；為每種精度開一個 sealed class（Hive 不友善）。
- 舊欄位 `expirationDate` 直接移除（見 D22）。

### D11. 有效期限（effectiveExpiry）是唯一的推導入口

```
effectiveExpiry(item) =
  openedDate != null && shelfLifeAfterOpenDays != null
    ? min(expiryEarliest ?? ∞, openedDate + shelfLifeAfterOpenDays)
    : expiryEarliest
```

- 回傳 `DateTime?`；為 null 表示期限未知。
- 狀態推導、排序、分群、點數、提醒（未來）全部只呼叫這個函式，禁止任何頁面自己算。放在 `lib/models/expiry.dart` 的純函式，`now` 由呼叫端傳入。

### D12. 狀態新增 `unknownExpiry`

- `FoodItemStatus` 尾端新增 `unknownExpiry`（index 5）。`effectiveExpiry == null` 時狀態為 `unknownExpiry`，語意色為中性、圖示為問號。
- 理由：待補完是使用者要看見並行動的狀態，而不是「假裝新鮮」。放進既有列舉可讓 `StatusChip` 與分群邏輯不必特例。

### D13. 份量：`amount`(double?) 取代 `quantity`，舊欄位直接移除

- `quantity`(int) 移除，改為 `amount: double?` 與 `remainingFraction: RemainingFraction?`（滿／大部分／一半／不多／剩一點）。同一筆二選一，至少其一非 null（驗證規則）。
- `Unit` 新增 `pack`、`box`、`bottle`、`bag`、`can`、`serving`。
- 可以就地改型別是因為 D22 放棄了舊資料相容。
- 顯示：`AmountLabel` 元件負責 `1` 顯示為「1」而非「1.0」，`0.5` 顯示為「0.5」，比例模式顯示為「約一半」。

### D14. 存放位置：獨立 capability 與獨立 Box

- `StorageLocation { id, name, kind: LocationKind { refrigerated, frozen, ambient, other }, sortOrder }`，Box `storageLocation`，由 `StorageLocationRepository` 管理。
- 首次啟動種下三筆預設（冷藏／冷凍／常溫），名稱取自 l10n 但存成字串（使用者可改名，改名後不隨語系變動）。
- `FoodItem.storageLocationId: String?`（選填）。刪除位置時，該位置的食物 `storageLocationId` 設為 null，不刪食物；刪除前以 `ConfirmSheet` 告知影響筆數。
- `kind` 是效期建議的輸入（同一個名稱在冷凍與冷藏的建議天數不同），也是唯一需要程式判讀的欄位——使用者自訂的 `name` 永遠不參與邏輯。

### D15. 效期建議表：離線 asset

- `assets/food_presets.json`：`[{ "keywords": ["牛奶","milk"], "type": "eggAndMilk", "days": { "refrigerated": 7, "frozen": 90, "ambient": 1 }, "afterOpenDays": 3 }, …]`
- 比對規則：名稱正規化（trim、全形轉半形、小寫）後找 keyword **包含**關係，取最長 keyword 命中者；沒命中就退回類型層級的預設天數；再沒有就 `unknown`。
- 使用者若在表單裡手動改過某名稱的期限，下次同名的建議以「使用者最近一次的實際設定」優先（由歷史推導，見 D16）。
- 理由：完全離線、可單元測試、沒有 API 成本；使用者選擇不走 AI 猜測。

### D16. 常用食物模板由歷史推導，不新增 Box

- `FoodTemplateService`（純 Dart）掃 `FoodItem` + `UsedFoodItem`，以名稱正規化後分組，依「出現次數 desc、最近使用時間 desc」排序取前 N（預設 12），帶出最近一次使用的類型、單位、位置、以及「存放日到期限的天數差」當預設效期。
- 理由：零額外 schema、零維護；使用者不必管理一份清單。
- 取捨：歷史為空時（新使用者）退回內建 preset 表；這也讓快速新增在第一天就可用。

### D17. 快速新增的決定順序

1. 使用者模板（D16）命中 → 帶入全部欄位。
2. 內建 preset 表（D15）命中 → 帶入類型與依預設位置 kind 的天數。
3. 都沒命中 → `expiryPrecision = unknown`、`type = others`，項目標為待補期限。

任何一步都不阻擋送出；「存得下去」永遠優先於「存得完整」。

### D18. 同名批次合併只在呈現層

- Bloc 產生 `List<FoodItemGroup>`：以 `(正規化名稱, storageLocationId, unit)` 為 key 分組，組內依 `effectiveExpiry` 由近到遠排序（null 排最後）。
- 卡片顯示組內 `amount` 總和與**最早**的期限狀態；展開列出各批次。
- 食用／丟棄作用在群組時，依 FEFO 從最早到期的批次逐筆扣減，跨批次時產生多筆 `UsedFoodItem`（各自帶自己的期限，點數才算得對）。
- 資料層完全不變，所以備份、還原、未來的同步都不受影響。

### D19. 點數：依時效加權

以 `effectiveExpiry`（D11）與 `usedDate` 判定，`disposalMethod` 決定正負向：

| 情境 | 點數 |
|---|---|
| 食用／送人，到期前 3 天內用完（即期救援） | +3 |
| 食用／送人，距到期還有 3 天以上 | +2 |
| 食用／送人，期限未知 | +2 |
| 食用，已過期後才吃掉（`eatenAtRisk`） | +1 |
| 堆肥，已過期 | −1 |
| 堆肥，未過期 | −2 |
| 丟棄，已過期 | −2 |
| 丟棄，未過期或期限未知 | −3 |

- 每日上限維持 10，但改以**當日加分總和**計算（既有規則把浪費的負分也算進總和，等於「多浪費就能多得分」）。
- 既有紀錄不追溯重算；統計頁標示規則自 2026-09-15 起變更。
- 實作放 `FoodPointCalculator`（純 Dart，`now` 注入），所有寫入路徑共用。

### D20. 統計圓餅圖改以筆數計量

- 點數加權後，「蔬菜佔 40% 的點數」不再等於「蔬菜佔 40% 的行為」。圓餅圖改數**筆數**；數量不可跨單位加總，金額則另有專屬圖。
- 新增四張圖：浪費率趨勢（每月 `wasted 筆數 ÷ 總筆數`）、最常浪費食物 Top 5（依正規化名稱）、浪費原因分佈、金額損益（救回金額 vs 浪費金額，只統計有填價格者並標示涵蓋率）。

### D21. 待補完的定義

- 「待補完」= `expiryPrecision == unknown`。**缺存放位置不算**，因為位置是選填，把它算進待補會讓從不使用位置的使用者被永久提醒。
- 呈現：主清單內的徽章 + 一個「期限未知」分群（使用者選擇「依到期急迫度」分群時）。

### D22. 放棄舊資料相容：換 Box 名稱，不寫遷移

- **使用者 2026-09-15 決定完全忽略舊資料**。因此模型可以自由重構：欄位改型別、刪除欄位、列舉重排都不受限。
- 作法：Box 名稱改為 `foodItems`、`usedFoodItems`（新名），舊的 `foodItem`／`usedFoodItem` **永遠不再開啟**。這樣既不需要遷移程式碼，也不會因為 adapter 與舊 record 的 typeId 不符而在啟動時擲例外。
- 舊 Box 的檔案留在裝置上不刪（刪除反而多一條會失敗的路徑）；它只佔幾 KB，且真的需要時還救得回來。
- 取捨：既有使用者（只有開發者自己）升級後看到空清單。這是明確被接受的代價，換來一個沒有 legacy 欄位、沒有遷移分支的乾淨模型。
- **因此 typeId 與欄位索引的「不可重新編號」限制在本 change 不適用**；本 change 之後恢復適用。

### D23. 兩個實作陷阱（實機驗證時踩到，記下來免得再犯）

- **`DropdownButtonFormField` 的項目在無限寬度下佈局**：`DropdownMenuItem` 的 child 裡放 `Expanded`／`Flexible` 會觸發
  `RenderFlex children have non-zero flex but incoming width constraints are unbounded`，整個頁面變全白（debug 下是 assert，release 下是空畫面）。
  解法：在 `DropdownButtonFormField` 上設 `isExpanded: true`，項目才會拿到有界寬度。專案內所有下拉選單都必須設。
- **`Navigator.push` 出去的路由不在原頁面的子樹**：路由掛在 `MaterialApp` 的 Navigator 底下，
  而 Bloc／Cubit 是在 `FoodSavior` 裡用 `MultiBlocProvider` 提供的，所以推出去的頁面 `context.read` 會丟
  `Could not find the correct Provider<...>`。解法：push 時用 `BlocProvider.value(value: context.read<X>(), child: …)` 把它帶過去。
  `StorageLocationPage` 有兩個入口（食物頁的貨架圖示、設定頁），兩邊都要包。

## Risks / Trade-offs

- **範圍過大**：資料模型 + 設計系統一起做，單一 change 很肥 → 以里程碑切：M1 資料模型與遷移（App 外觀不變）、M2 theme + 元件庫（不接頁面）、M3 逐頁替換。每個里程碑自己全綠。
- **升級後舊資料消失**：使用者已明確接受（D22）。代價是開發機上的既有紀錄看不到；換來零遷移程式碼與乾淨模型。
- **欄位變多讓新增食物更麻煩**：與「方便填寫」直接衝突 → 一行快速新增是預設入口，完整表單裡除名稱外全部選填且有建議值；驗證只擋「沒有名稱」與「份量與剩餘比例都沒填」。
- 一次重製五頁範圍大 → 以「元件庫 + theme 先落地並有測試」為第一個可合併里程碑，之後每頁一個 PR。
- `NavigationBar` 改變外觀辨識度 → D7 待確認。
- 邏輯下沉可能改變 SnackBar 觸發時序 → widget test 鎮定「操作後出現一次回饋」。

## Migration Plan

1. 建 `lib/theme/` 與元件庫 + 測試（不接頁面，App 外觀不變）。
2. `ThemeCubit` 改吃 `AppTheme`（外觀開始變）。
3. 逐頁替換：設定 → 使用者 → 統計 → 紀錄 → 食物（最大，最後）。
4. 移除 `curved_labeled_navigation_bar`、刪除舊硬編碡。
5. 每步都跑 `node .claude/hooks/stop-verify.cjs --manual` 與 Dart MCP 明暗／zh／en 截圖。

## Open Questions（已全部結案）

- Q1：seed 色 → **沉穩綠 `#3E8E5A`**（使用者 2026-09-15 決定）。
- Q2：底部導覽 → **改為 Material 3 `NavigationBar`**（使用者決定）。
- Q3：新增食物入口 → **FAB**（使用者未表態，採 design 建議；實作後截圖供確認，改成 AppBar 動作成本很低）。
- 補充決定：現行 Font Awesome 食物類型圖示暫時接受，不在本 change 更換。
