## ADDED Requirements

### Requirement: 所有視覺數值來自 token

App 的顏色、字級、間距、圓角、動畫時長 SHALL 由集中定義的 token 提供：`ColorScheme`（Material 3 角色）、`TextTheme`、`ThemeExtension` 的 `FoodStatusColors`、`AppSpacing`、`AppRadius`、`AppDurations`。`lib/pages/` 與 `lib/widgets/` MUST NOT 直接使用 `Colors.*`、`Color(0x…)`、`fontSize:` 數值或魔術數字 padding。

#### Scenario: 靜態檢查

- **WHEN** 對 `lib/pages` 與 `lib/widgets` 搜尋 `Colors\.`、`Color(0x`、`fontSize:`
- **THEN** SHALL 沒有任何結果（`lib/theme/` 除外）

#### Scenario: 調整品牌色

- **WHEN** 開發者只修改 `lib/theme/` 中的主色 seed
- **THEN** 所有分頁、元件、SnackBar、導覽列 SHALL 一致變色，無需修改任何 page

### Requirement: 明暗主題完整且對比達標

系統 SHALL 提供淺色與深色兩套完整主題；每個 token 在兩套主題都有值。文字與背景對比 MUST ≥ 4.5:1（大標題 ≥ 3:1）；深色主題 SHALL 使用 surface 階層（`surfaceContainerLow/High` 等）區分層級，而非陰影。

#### Scenario: 深色模式下的 SnackBar

- **WHEN** 深色模式下觸發成功回饋
- **THEN** SnackBar SHALL 使用深色主題的 `inverseSurface`／`onInverseSurface`，不出現白底黑字

### Requirement: 食物狀態以語意色加圖示或文字呈現

`FoodStatusColors` SHALL 定義 fresh、nearExpired、expired、consumed、wasted 五種語意色（明暗各一組）。任何呈現狀態的地方 MUST 同時提供圖示或文字，不得只靠顏色。

#### Scenario: 快過期的清單列

- **WHEN** 一筆食物狀態為 `nearExpired`
- **THEN** 該列 SHALL 顯示 `nearExpired` 語意色的 `StatusChip`，chip 內含狀態文字（`foodItemStatusNearExpired`）

### Requirement: 元件庫是唯一的 UI 積木

系統 SHALL 提供並在所有分頁重用以下元件：`AppScaffold`、`FoodItemTile`、`StatusChip`、`ExpiryCountdown`、`QuantityWithUnit`、`EmptyState`、`SectionHeader`、`AppSnackBar`（success／warning／error）、`ConfirmSheet`、`DatePickerField`。同一種資訊在不同分頁 SHALL 以同一元件呈現。

#### Scenario: 食物列在清單與過期處理頁

- **WHEN** 同一筆食物出現在現存清單與過期處理頁
- **THEN** 兩處 SHALL 使用 `FoodItemTile`，只有尾端動作不同

### Requirement: 清單三態

每個清單畫面 SHALL 具備 loading、empty、error 三種狀態的專屬呈現：loading 使用骨架或進度指示；empty 使用 `EmptyState`（圖示、一句說明、主要動作）；error 顯示訊息與重試。

#### Scenario: 沒有任何食物

- **WHEN** 現存清單為空
- **THEN** SHALL 顯示 `EmptyState`，內含「新增食物」主要動作

### Requirement: 表單使用全螢幕頁或可捲動 sheet

含三個以上欄位的表單（新增／編輯食物）SHALL 以全螢幕頁面或 `isScrollControlled` 的 bottom sheet 呈現；`AlertDialog` SHALL 只用於確認或單一選擇。鍵盤彈出時欄位 MUST 不被遮擋。

#### Scenario: 新增食物

- **WHEN** 使用者點擊新增
- **THEN** SHALL 開啟全螢幕表單頁（或 sheet），欄位順序：名稱、類型、數量與單位、存放日、到期日、描述

### Requirement: 觸控目標與版面節律

可點擊元素 SHALL ≥ 48×48 dp；清單列高 56–72 dp；內容與螢幕邊距 16 dp；間距只使用 `AppSpacing` 的 4／8／12／16／24／32。

#### Scenario: 滑動動作按鈕

- **WHEN** 展開清單列的滑動動作
- **THEN** 每個動作的可點擊區域 SHALL ≥ 48 dp 寬

### Requirement: 多語文字不截斷

所有元件在 zh-TW 與 en 下 SHALL 不截斷、不溢出；按鈕與 chip 文字長度增加 50% 時仍可完整顯示或自動換行。

#### Scenario: 英文下的導覽列與按鈕

- **WHEN** 語系切換為 en
- **THEN** 底部導覽列標題、滑動動作標籤、表單按鈕 SHALL 完整可讀

### Requirement: 動態節制且可停用

過場與回饋動畫 SHALL 使用 `AppDurations`（短 150 ms、中 250 ms、長 400 ms）；Lottie 只用於食用／丟棄完成的回饋；當 `MediaQuery.disableAnimations` 為 true 時 SHALL 略過裝飾性動畫。

#### Scenario: 系統關閉動畫

- **WHEN** 裝置的無障礙設定關閉動畫
- **THEN** 頁面切換 SHALL 立即完成，Lottie 以靜態圖示取代
