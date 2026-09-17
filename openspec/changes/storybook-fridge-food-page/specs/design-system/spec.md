## MODIFIED Requirements

### Requirement: 所有視覺數值來自 token

App 的顏色、字級、間距、圓角、動畫時長 SHALL 由集中定義的 token 提供：`ColorScheme`（Material 3 角色）、`TextTheme`、`ThemeExtension` 的 `FoodStatusColors` 與 `StorybookTheme`（紙紋、架板、冰箱燈光、貼紙的顏色、資源路徑與不透明度）、`AppSpacing`、`AppRadius`、`AppDurations`。插畫與紋理的資源路徑 SHALL 集中於 `AppAssets` 與 `FoodItemVisuals`。`lib/pages/` 與 `lib/widgets/` MUST NOT 直接使用 `Colors.*`、`Color(0x…)`、`fontSize:` 數值、魔術數字 padding、寫死的資源路徑字串或寫死的不透明度數值。

#### Scenario: 靜態檢查

- **WHEN** 對 `lib/pages` 與 `lib/widgets` 搜尋 `Colors\.`、`Color(0x`、`fontSize:`、`'assets/`
- **THEN** SHALL 沒有任何結果（`lib/theme/` 除外）

#### Scenario: 調整品牌色

- **WHEN** 開發者只修改 `lib/theme/` 中的主色 seed
- **THEN** 所有分頁、元件、SnackBar、導覽列 SHALL 一致變色，無需修改任何 page

#### Scenario: 調整紙紋強度

- **WHEN** 開發者只修改 `StorybookTheme` 的紙紋不透明度
- **THEN** 食物頁及其子頁的所有紙紋表面 SHALL 一致變化，無需修改任何 page 或 widget

### Requirement: 元件庫是唯一的 UI 積木

系統 SHALL 提供並在所有分頁重用以下元件：`AppScaffold`、`FoodItemTile`、`FoodItemGroupCard`、`StatusChip`、`PendingExpiryBadge`、`ExpiryCountdown`、`AmountLabel`、`EmptyState`、`SectionHeader`、`AppSnackBar`（success／warning／error）、`ConfirmSheet`、`ExpiryField`、`ExpirySheet`、`LocationPicker`、`FridgeFrame`（冰箱外框）、`FridgeShelf`（層架）、`FoodCharacter`（食物角色插畫）、`ChihuahuaPeek`（角色事件反應）。同一種資訊在不同分頁 SHALL 以同一元件呈現。

`AmountLabel` 同時負責數量加單位與剩餘比例兩種呈現（份量有兩種記法，見 food-inventory）；期限輸入由 `ExpiryField` 統一處理四種精度，因此沒有通用的日期欄位元件。`FoodCharacter` 只用於食物頁及其子頁；其他分頁的類型圖示 SHALL 繼續使用 `FoodTypeIcon`。

#### Scenario: 食物列在清單與過期處理頁

- **WHEN** 同一筆食物出現在現存清單與過期處理頁
- **THEN** 兩處 SHALL 使用 `FoodItemTile`，只有尾端動作不同

#### Scenario: 同一種食物在食物頁與紀錄頁

- **WHEN** 一筆「麵包」類型的食物出現在食物頁清單與使用紀錄頁
- **THEN** 食物頁 SHALL 以 `FoodCharacter` 呈現，紀錄頁 SHALL 以 `FoodTypeIcon` 呈現，兩者對應同一個 `FoodItemType`

### Requirement: 動態節制且可停用

過場與回饋動畫 SHALL 使用 `AppDurations`（短 150 ms、中 250 ms、長 400 ms）；層架進場的錯開間隔 SHALL 不超過 `AppDurations.short` 的一半，整頁進場 SHALL 在 `AppDurations.long` 的兩倍內完成；角色事件反應（`ChihuahuaPeek`）含進出場 SHALL 不超過 2 秒。Lottie 只用於食用／丟棄完成的回饋；列的進出場、貼紙、層架冷光 SHALL 以程式動畫實作，MUST NOT 每列各放一段 Lottie。當 `MediaQuery.disableAnimations` 為 true 時 SHALL 略過裝飾性動畫（層架進場、列進出場、貼紙蓋章、冷光、角色反應），狀態變化立即完成。

#### Scenario: 系統關閉動畫

- **WHEN** 裝置的無障礙設定關閉動畫
- **THEN** 頁面切換 SHALL 立即完成，Lottie 以靜態圖示取代，層架與列不播放進出場，角色不出現

#### Scenario: 十層層架的進場

- **WHEN** 清單有 10 層層架且本次啟動第一次顯示
- **THEN** 全部層架 SHALL 在 `AppDurations.long` 的兩倍內定位完成，不因層數增加而拉長

## ADDED Requirements

### Requirement: 食物頁繪本層

食物頁及其子頁（詳情 sheet、使用 sheet、浪費 sheet、過期處理頁、新增／編輯表單頁、匯入草稿頁）SHALL 使用 `StorybookTheme` 提供的紙紋表面、架板與貼紙樣式，呈現手繪繪本質感。紙紋 SHALL 只以 token 定義的不透明度疊在既有 surface 之上，疊加後文字與背景對比 MUST 仍 ≥ 4.5:1（大標題 ≥ 3:1）。其他四個分頁與登入頁 MUST NOT 使用繪本層，維持 Material 3 預設 surface。淺色主題 SHALL 為「冰箱燈全亮」：奶油色內牆、淺色架板；深色主題 SHALL 為「冰箱燈微亮」：沿用深色 surface 階層，架板保留一道冷白微光，紙紋不透明度低於淺色。

#### Scenario: 淺色食物頁

- **WHEN** 淺色主題下顯示有資料的食物頁
- **THEN** 清單背景 SHALL 有紙紋、每層層架有架板、分群標籤為貼紙樣式，且任一列的名稱文字對比 ≥ 4.5:1

#### Scenario: 深色食物頁

- **WHEN** 深色主題下顯示有資料的食物頁
- **THEN** 背景 SHALL 為深色 surface，架板 SHALL 有一道冷白微光，食物角色背後 SHALL 有淡色圓片，名稱文字對比 ≥ 4.5:1

#### Scenario: 其他分頁不受影響

- **WHEN** 使用者切換到紀錄頁或統計頁
- **THEN** 該頁 MUST NOT 出現紙紋、架板或貼紙樣式

### Requirement: 食物角色插畫

系統 SHALL 為 11 種 `FoodItemType` 各提供一張手繪彩色角色插畫（`FoodCharacter`），表情固定、不隨狀態改變。每張 SHALL 提供 1x／2x／3x 三個解析度並可在 40 dp 下辨識類型。角色 SHALL 只承載「類型」資訊；狀態 MUST 仍以語意色加文字的貼紙呈現，MUST NOT 以角色表情或角色著色表達狀態。深色主題下角色背後 SHALL 有 `StorybookTheme` 定義的淡色圓片。角色為本專案原創設計，MUST NOT 重製任何既有繪本或商標角色的造型。

#### Scenario: 快過期的麵包

- **WHEN** 一筆 `bread` 類型、狀態為 `nearExpired` 的食物出現在食物頁
- **THEN** 該列 SHALL 顯示麵包角色插畫，並在尾端顯示 `nearExpired` 語意色與文字的倒數貼紙；角色本身 MUST 與新鮮時相同

#### Scenario: 小尺寸辨識

- **WHEN** 合併卡展開後的批次列以 40 dp 顯示角色
- **THEN** 11 種角色 SHALL 仍可彼此區分
