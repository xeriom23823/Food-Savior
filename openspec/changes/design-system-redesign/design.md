## Context

現況：`ThemeCubit` 內以 `ThemeData` 硬寫兩套主題；pages 大量硬編碼顏色、字級、字串；`food_item_list_page.dart` 超過 1000 行並含商業邏輯；底部導覽使用 `curved_labeled_navigation_bar`。設計系統重製要在**不改任何行為**的前提下重寫呈現層，因此先補 Bloc 測試當安全網，再分頁替換。

## Goals / Non-Goals

- Goals：token 化、元件庫、五分頁重製、三態、明暗與 zh／en 一次到位、pages 邏輯下沉。
- Non-Goals：新功能、資料模型變更、平板版面、動態取色。

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

## Risks / Trade-offs

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
