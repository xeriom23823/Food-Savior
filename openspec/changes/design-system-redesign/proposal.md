## Why

Food Savior 目前的視覺是「Material 預設 + 綠色 AppBar」：頁面內大量硬編碼顏色與字級（白底黑字的 SnackBar、`fontSize: 24` 標題、`Colors.grey` 圖示）、暗色主題只是把 surface 換成 `#121212`、五個分頁各自長相不一致，新增／編輯食物用 `AlertDialog` 塞下七個欄位。這讓每一次 UI 修改都變成「再硬寫一個數值」，也讓 AI agent 無從判斷什麼是「對的樣子」。

本 change 要驗證的假設：先建立一套以 token 為核心的設計系統（顏色、字級、間距、圓角、狀態語意色、元件庫），並重製五個分頁，之後所有 UI 工作（包含 roadmap 的提醒、掃描、同步、AI 推薦）都能只引用 token 與元件完成，且明暗、zh／en 一次到位。

## What Changes

- 新增 `lib/theme/`：`AppTheme`（light／dark `ThemeData` 由 `ColorScheme` 與 token 組成）、`ThemeExtension` 的 `FoodStatusColors`、`AppSpacing`、`AppRadius`、`AppDurations`；`ThemeCubit` 改為只切換模式，不再持有 `ThemeData` 定義。
- 新增 `lib/widgets/` 元件庫：`FoodItemTile`、`StatusChip`、`ExpiryCountdown`、`QuantityWithUnit`、`EmptyState`、`SectionHeader`、`AppSnackBar`、`ConfirmSheet`、`DatePickerField`、`AppScaffold`。
- 重製五個分頁的版面與互動：新增／編輯食物改為全螢幕表單頁或可捲動 bottom sheet；部分使用改為 bottom sheet；過期處理頁、使用者頁、設定頁、統計頁套用元件與 token；所有清單具備 loading／empty／error 三態。
- 移除 pages 內所有硬編碼 `Colors.*`、`Color(0x…)`、`fontSize:`、硬編碼中文字串（同步補齊 l10n key）。
- 底部導覽列：評估以 Material 3 `NavigationBar` 取代 `curved_labeled_navigation_bar`（決策放在 design.md）。
- **行為不變**：所有既有 spec 的 Scenario（食物 CRUD、過期處理、食用／浪費、點數、紀錄、統計、登入、備份還原、設定）結果一致；本 change 只改呈現與互動形式。

### 範圖上限

五個既有分頁 + 兩個表單頁（新增／編輯食物）+ 一個部分使用 sheet；不新增功能、不新增資料欄位、不新增第三方 UI 套件（可移除一個）；平台以 Android／iOS 為驗證對象。

### 非目標

- 不做過期提醒、掃描、同步、AI 推薦的任何功能。
- 不改 Hive schema、Firestore 結構、Bloc 事件語意（允許新增 event 把頁面內邏輯下沉，但結果不變）。
- 不做 onboarding、動態主題色（Material You 取色）、平板／桌面版面。
- 不重畫 Lottie 動畫與 App icon。

## Capabilities

### New Capabilities

- `design-system`：色彩／字級／間距／圓角／動態 token、狀態語意色、元件庫契約、三態規則、可及性與明暗／多語檢查要求。

### Modified Capabilities

- `food-inventory`：新增／編輯／詳情的呈現形式（全螢幕表單或 sheet 取代 AlertDialog）、清單三態；欄位與驗證規則不變。
- `food-consumption`：部分使用改為 bottom sheet；回饋改用 `AppSnackBar`；動作與資料結果不變。
- `expired-food-processing`：處理頁改用元件與 l10n；流程不變。
- `app-shell-navigation`：底部導覽列元件替換（若 design.md 決定採用 `NavigationBar`）；分頁順序與預設分頁不變。
- `localization`：消除既有硬編碼字串，新增對應 key。

## Impact

- **Code**：`lib/theme/`（新）、`lib/widgets/`（新增多個）、`lib/cubits/theme_cubit.dart`、`lib/pages/*`（大幅重寫，`food_item_list_page.dart` 拆成 `food_item_list/` 子目錄）、`lib/l10n/*.arb`。
- **Tests**：`theme_cubit_test.dart` 更新；新增元件 widget test（明暗各一）、五個分頁的渲染與關鍵互動 widget test；既有 Bloc 行為以 bloc_test 補齊作為重構安全網。
- **Dependencies**：可能移除 `curved_labeled_navigation_bar`；不新增套件。
- **Risk**：頁面邏輯下沉到 Bloc 時可能改變時序（例如 SnackBar 觸發時機）；以 bloc_test + widget test 鎖定。
