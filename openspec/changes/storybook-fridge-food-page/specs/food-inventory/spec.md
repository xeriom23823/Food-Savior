## MODIFIED Requirements

### Requirement: 清單依到期日排序並顯示剩餘天數

清單 SHALL 依有效期限由近到遠排序，有效期限為 null 者 SHALL 排在最後。每列 SHALL 顯示名稱與份量（數量加單位或剩餘比例）、類型（在食物頁及其子頁以該類型的食物角色插畫呈現，其他頁以類型圖示並以狀態語意色著色）、存放位置（若有）、描述，以及期限資訊：期限未知顯示 `expiryUnknown`；已過期顯示 `expired`；今天到期顯示 `expireToday`；否則顯示剩餘天數。期限資訊 SHALL 以狀態語意色加文字的貼紙呈現。`range` 與 `monthOnly` 精度 SHALL 以近似語氣呈現（`expireApproximately` 加天數），使其與精確期限可區分。

#### Scenario: 期限未知排在最後

- **WHEN** 清單同時有 3 天後到期與期限未知的項目
- **THEN** 3 天後到期者 SHALL 排在期限未知者之前

#### Scenario: 區間期限的呈現

- **WHEN** 某項目期限為「3 天後到 5 天後」的區間
- **THEN** 該列 SHALL 以近似語氣呈現（例如「約 3 天後到期」），不得顯示成與精確期限相同的樣子

#### Scenario: 新增後重新排序

- **WHEN** 清單有有效期限 5 天後與 10 天後的項目，使用者新增有效期限 7 天後的項目
- **THEN** 清單順序 SHALL 為 5 天、7 天、10 天

#### Scenario: 今日到期

- **WHEN** 某項目有效期限為今天
- **THEN** 該列期限欄 SHALL 顯示 `expireToday`

#### Scenario: 食物頁的類型呈現

- **WHEN** 一筆 `vegetable` 類型的食物出現在食物頁清單
- **THEN** 該列 SHALL 顯示蔬菜角色插畫，名稱、份量、位置與期限貼紙照常顯示在同一列

### Requirement: 清單分群方式可切換並持久化

清單 SHALL 支援三種分群方式：依到期急迫度（預設）、依存放位置、依食物類型。每個分群 SHALL 以一層「層架」呈現：層架標籤（含分群名稱與該群筆數）、該群的食物列、架板。依到期急迫度時分群 SHALL 依序為：已過期、今天到期、3 天內、一週內、充裕、期限未知，層架標籤 SHALL 使用對應狀態的語意色與圖示；依存放位置時層架外觀 SHALL 依位置的 `kind` 區分（`frozen` 帶霜、`ambient` 為木質櫥架、`refrigerated` 為預設架板、`other` 為中性），並同時顯示 kind 圖示，沒有位置的項目歸入「未指定位置」層架；依食物類型時層架標籤 SHALL 帶該類型的角色插畫。空的分群 SHALL 不顯示。使用者的選擇 SHALL 持久化，重啟後維持。分群方式的切換 MUST NOT 改變任何項目的排序規則、狀態或資料。

#### Scenario: 切換為依位置

- **WHEN** 使用者將分群方式切換為依存放位置
- **THEN** 清單 SHALL 以各存放位置為層架，冷凍位置的架板帶霜、常溫位置為木質櫥架，沒有位置的項目歸入「未指定位置」層架

#### Scenario: 重啟後維持

- **WHEN** 使用者選擇依類型分群後關閉並重新開啟 App
- **THEN** 清單 SHALL 仍以類型分群

#### Scenario: 空分群不顯示

- **WHEN** 沒有任何已過期項目
- **THEN** 清單 MUST NOT 顯示「已過期」層架

#### Scenario: 層架標籤含筆數

- **WHEN** 「3 天內」分群有 4 筆食物
- **THEN** 該層架標籤 SHALL 顯示 `urgencyWithinThreeDays` 名稱與 `itemCount(4)`

#### Scenario: 位置只靠圖示以外的線索也能分辨

- **WHEN** 使用者依位置分群且有冷凍與冷藏兩層
- **THEN** 兩層 SHALL 同時以架板外觀、kind 圖示與位置名稱區分，不得只靠顏色

## ADDED Requirements

### Requirement: 冰箱外框與快速新增列

食物頁在一般清單狀態下 SHALL 以冰箱外框包住層架清單：頂部一道冰箱燈、兩側內牆，快速新增列 SHALL 位於外框底部並維持既有的「只輸入名稱即可送出、送出後鍵盤保持開啟」行為。外框 SHALL 隨主題呈現（淺色全亮、深色微亮），MUST NOT 減少可捲動清單的內容寬度超過 `AppSpacing.lg` 的兩倍。空狀態與錯誤狀態 SHALL 仍顯示在外框之內。每次 App 啟動後第一次顯示清單時，層架 SHALL 由上而下依序進場；本次啟動內再回到食物頁 MUST NOT 重播進場。

#### Scenario: 一般清單

- **WHEN** 清單有資料且使用者進入食物頁
- **THEN** 畫面 SHALL 顯示頂部冰箱燈、兩側內牆、中間的層架清單與底部的快速新增列

#### Scenario: 空冰箱

- **WHEN** 清單為空
- **THEN** 外框內 SHALL 顯示 `EmptyState`（含既有的空冰箱插畫與 `addFoodItem` 動作），快速新增列照常可用

#### Scenario: 本次啟動第二次進入

- **WHEN** 使用者在同一次 App 啟動內從紀錄頁切回食物頁
- **THEN** 層架 SHALL 直接顯示，不重播進場動態
