## MODIFIED Requirements

### Requirement: 新增食物需通過欄位驗證

系統 SHALL 允許使用者以名稱、類型、份量、單位、描述、存放日期、期限、存放位置、開封資訊、金額建立一筆 `FoodItem`。除名稱與份量外所有欄位 SHALL 為選填。儲存前 SHALL 驗證：名稱不可為空（`nameCannotBeEmpty`）；`amount` 與 `remainingFraction` MUST 至少其一有值（`amountCannotBeEmpty`）；填了 `amount` 時 MUST 為大於 0 的數（`amountMustBePositive`、`amountMustBeANumber`）且 MUST 選擇單位（`unitCannotBeEmpty`）；`expiryPrecision` 為 `range` 時 `expiryLatest` MUST 不早於 `expiryEarliest`（`expiryRangeInvalid`）；`priceTotal` 若有值 MUST 為非負整數（`priceMustBeNonNegative`）。驗證失敗時 SHALL 顯示對應訊息且不得寫入資料。

#### Scenario: 只填名稱即可入庫

- **WHEN** 使用者以快速新增只輸入「牛奶」並送出
- **THEN** 系統 SHALL 建立一筆 `FoodItem`，份量與期限由建議機制決定（見「快速新增」），不得因欄位不全而拒絕儲存

#### Scenario: 份量與剩餘比例都沒填

- **WHEN** 使用者在完整表單清空份量且未選擇剩餘比例即送出
- **THEN** 系統 SHALL 顯示 `amountCannotBeEmpty` 且不新增項目

#### Scenario: 份量為小數

- **WHEN** 使用者輸入份量 0.5、單位 `bottle`
- **THEN** 系統 SHALL 接受並儲存 `amount = 0.5`

#### Scenario: 期限區間顛倒

- **WHEN** 使用者選擇區間期限，最早 2026-10-10、最晚 2026-10-05
- **THEN** 系統 SHALL 顯示 `expiryRangeInvalid` 且不新增項目

#### Scenario: 有效輸入新增成功

- **WHEN** 使用者填入名稱「牛奶」、類型 `eggAndMilk`、份量 1、單位 `bottle`、存放日今天、精確到期日 7 天後並送出
- **THEN** 系統 SHALL 產生唯一 id（UUID v4）、將項目寫入本機儲存、關閉表單並以 `added` 訊息提示

#### Scenario: 名稱為空

- **WHEN** 使用者未填名稱即送出
- **THEN** 系統 SHALL 顯示 `nameCannotBeEmpty` 且不新增項目

#### Scenario: 數量不是正整數

- **WHEN** 使用者在份量輸入「abc」或「0」或「-3」
- **THEN** 系統 SHALL 分別顯示 `amountMustBeANumber` 或 `amountMustBePositive`，且不新增項目。份量 SHALL 接受小數（例如 0.5），不再限制為整數

#### Scenario: 未選擇單位

- **WHEN** 使用者填了數字份量但未選擇單位即送出
- **THEN** 系統 SHALL 顯示 `unitCannotBeEmpty`

### Requirement: 食物類型與單位為固定列舉

`FoodItemType` SHALL 包含 vegetable、fruit、meat、eggAndMilk、seafood、cannedFood、cookedFood、drink、snack、bread、others 共 11 種；`Unit` SHALL 包含 gram、milliliter、piece、pack、box、bottle、bag、can、serving 共 9 種（後 6 種為尾端新增）。`RemainingFraction` SHALL 包含 full、mostly、half、low、almostGone 五級。每種類型 SHALL 有固定圖示與語意色；所有顯示名稱 SHALL 經由 l10n（`foodItemType*`、`unit*`、`remainingFraction*`）取得。

#### Scenario: 顯示小數份量

- **WHEN** 一筆食物 `amount` 為 0.5、單位為 `bottle`、語系為 zh-TW
- **THEN** 清單 SHALL 顯示「0.5 瓶」，且整數份量 SHALL 顯示為「1 瓶」而非「1.0 瓶」

#### Scenario: 顯示剩餘比例

- **WHEN** 一筆食物以 `remainingFraction = half` 記錄
- **THEN** 清單 SHALL 顯示 `remainingFractionHalf`（zh-TW：「約一半」），不顯示數字與單位

#### Scenario: 顯示數量與單位

- **WHEN** 一筆食物份量為 500、單位為 gram、語系為 zh-TW
- **THEN** 清單 SHALL 顯示「500 公克」（份量與 `unitGram` 組合）

### Requirement: 依到期日推導狀態

系統 SHALL 以裝置當地時間與**有效期限**推導 `FoodItemStatus`。有效期限定義為：`openedDate` 與 `shelfLifeAfterOpenDays` 皆有值時取 `min(expiryEarliest, openedDate + shelfLifeAfterOpenDays)`，否則為 `expiryEarliest`。有效期限為 null 時狀態 SHALL 為 `unknownExpiry`；早於現在為 `expired`；在現在起 3 天內為 `nearExpired`；其餘為 `fresh`。推導 SHALL 在載入清單時對所有項目執行，並在新增或編輯項目時對該項目執行。`expiryLatest` MUST NOT 參與狀態推導。

#### Scenario: 期限未知

- **WHEN** 使用者以快速新增建立一筆沒有期限的食物
- **THEN** 該項目狀態 SHALL 為 `unknownExpiry`，且 MUST NOT 被視為 `fresh` 或 `expired`

#### Scenario: 區間期限以最早日判定

- **WHEN** 一筆食物期限為「2 天後到 6 天後」的區間
- **THEN** 該項目狀態 SHALL 為 `nearExpired`（依最早日 2 天後判定）

#### Scenario: 開封縮短期限

- **WHEN** 一筆鮮奶原期限為 10 天後，使用者標記今天開封且開封後可放 3 天
- **THEN** 有效期限 SHALL 為 3 天後，狀態 SHALL 為 `nearExpired`

#### Scenario: 只到月份

- **WHEN** 使用者選擇期限「只到 2026-10」
- **THEN** 系統 SHALL 存成 `expiryEarliest = 2026-10-01`、`expiryLatest = 2026-10-31`、`expiryPrecision = monthOnly`，並以 10-01 推導狀態

#### Scenario: 載入時發現已過期

- **WHEN** App 載入清單且某項目的有效期限早於現在
- **THEN** 該項目狀態 SHALL 更新為 `expired` 並寫回本機儲存，並進入過期處理流程（見 expired-food-processing）

#### Scenario: 到期日在 2 天後

- **WHEN** 使用者新增精確到期日為 2 天後的食物
- **THEN** 該項目狀態 SHALL 為 `nearExpired`

#### Scenario: 到期日在 10 天後

- **WHEN** 使用者新增精確到期日為 10 天後的食物
- **THEN** 該項目狀態 SHALL 為 `fresh`

### Requirement: 清單依到期日排序並顯示剩餘天數

清單 SHALL 依有效期限由近到遠排序，有效期限為 null 者 SHALL 排在最後。每列 SHALL 顯示名稱與份量（數量加單位或剩餘比例）、類型圖示（以狀態語意色著色）、存放位置（若有）、描述，以及期限資訊：期限未知顯示 `expiryUnknown`；已過期顯示 `expired`；今天到期顯示 `expireToday`；否則顯示剩餘天數。`range` 與 `monthOnly` 精度 SHALL 以近似語氣呈現（`expireApproximately` 加天數），使其與精確期限可區分。

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

### Requirement: 檢視詳情

系統 SHALL 在使用者點擊清單項目時顯示詳情，包含名稱、類型、份量、存放位置、存放日期、期限（依精度呈現：精確為 `yyyy-MM-dd`、區間為兩個日期、只到月為 `yyyy-MM`、未知為 `expiryUnknown`）、開封日與開封後效期（若有）、金額（若有）、描述。

#### Scenario: 點擊項目

- **WHEN** 使用者點擊一筆食物
- **THEN** 系統 SHALL 顯示該項目的詳情，不改變資料

### Requirement: 編輯食物

系統 SHALL 允許使用者從詳情或「編輯」滑動動作開啟編輯表單，套用與新增相同的驗證規則；儲存後 SHALL 保留原 id、寫回本機儲存、重新推導狀態與排序並以 `updated` 提示。系統 SHALL 另提供「補期限」的輕量入口：對狀態為 `unknownExpiry` 的項目，一次點擊即可只填期限並儲存，不需開啟完整表單。

#### Scenario: 補上期限

- **WHEN** 使用者對一筆 `unknownExpiry` 的項目點擊「補期限」並選擇 5 天後
- **THEN** 該項目 SHALL 保留原 id 與其他欄位、狀態重新推導為 `fresh`，且清單重新排序

#### Scenario: 標記開封

- **WHEN** 使用者對一筆未開封項目點擊「標記開封」
- **THEN** 系統 SHALL 以今天為 `openedDate`，若該食物有建議的開封後效期則一併帶入，並重新推導狀態

#### Scenario: 修改到期日

- **WHEN** 使用者將某項目精確到期日從 10 天後改為 2 天後並儲存
- **THEN** 該項目 SHALL 保留原 id、狀態重新推導為 `nearExpired`，且清單重新排序

## ADDED Requirements

### Requirement: 快速新增只需名稱

系統 SHALL 在食物清單頁提供一行快速新增輸入列：使用者只輸入名稱即可建立項目，送出後鍵盤 SHALL 保持開啟以便連續輸入。類型與期限 SHALL 依下列順序決定，任一步都不得阻擋送出：

1. 使用者歷史推導的常用模板命中（同名稱正規化後）→ 帶入該模板的類型、單位、份量、位置與依「存放日到期限的天數差」推得的期限。
2. 內建離線對照表命中 → 帶入類型與依預設位置 kind 的保存天數。
3. 皆未命中 → 類型為 `others`、`expiryPrecision` 為 `unknown`、份量預設為 1 `piece`。

#### Scenario: 命中使用者歷史

- **WHEN** 使用者過去記過「牛奶」且當時期限為存放後 7 天
- **AND** 使用者以快速新增輸入「牛奶」
- **THEN** 新項目 SHALL 帶入類型 `eggAndMilk`、期限為今天起 7 天後、精度 `exact`

#### Scenario: 完全沒有依據

- **WHEN** 使用者快速新增「阿嬤給的東西」且歷史與對照表皆未命中
- **THEN** 系統 SHALL 建立狀態為 `unknownExpiry` 的項目並標為待補期限，不得顯示錯誤

#### Scenario: 連續新增

- **WHEN** 使用者在快速新增列連續送出三個名稱
- **THEN** 三筆 SHALL 全部建立，輸入列 SHALL 清空且保持聚焦

### Requirement: 待補期限的項目要被看見

`expiryPrecision` 為 `unknown` 的項目 SHALL 照常出現在主清單，並帶有「待補期限」徽章與一鍵補期限的動作。缺少存放位置 MUST NOT 被視為待補完。當清單以到期急迫度分群時，SHALL 有獨立的「期限未知」分群。

#### Scenario: 徽章與補齊入口

- **WHEN** 清單中有一筆 `unknownExpiry` 的項目
- **THEN** 該列 SHALL 顯示待補期限徽章，點擊徽章 SHALL 直接開啟期限選擇

#### Scenario: 缺位置不算待補

- **WHEN** 某項目有精確期限但沒有存放位置
- **THEN** 該項目 MUST NOT 顯示待補期限徽章

### Requirement: 清單分群方式可切換並持久化

清單 SHALL 支援三種分群方式：依到期急迫度（預設）、依存放位置、依食物類型。依到期急迫度時分群 SHALL 依序為：已過期、今天到期、3 天內、一週內、充裕、期限未知；空的分群 SHALL 不顯示。每個分群標題 SHALL 顯示該群筆數。使用者的選擇 SHALL 持久化，重啟後維持。

#### Scenario: 切換為依位置

- **WHEN** 使用者將分群方式切換為依存放位置
- **THEN** 清單 SHALL 以各存放位置為標題分群，沒有位置的項目歸入「未指定位置」群

#### Scenario: 重啟後維持

- **WHEN** 使用者選擇依類型分群後關閉並重新開啟 App
- **THEN** 清單 SHALL 仍以類型分群

#### Scenario: 空分群不顯示

- **WHEN** 沒有任何已過期項目
- **THEN** 清單 MUST NOT 顯示「已過期」分群標題

### Requirement: 同名批次在呈現層合併

名稱（正規化後）、存放位置、單位三者皆相同的多筆 `FoodItem` SHALL 在清單中收合為單一卡片，顯示份量總和與組內**最早**有效期限所對應的狀態；展開後 SHALL 逐筆列出各批次的份量與期限。合併 MUST 只發生在呈現層，本機儲存 SHALL 維持多筆獨立紀錄，各自保有 id 與期限。

#### Scenario: 兩次購買合併顯示

- **WHEN** 清單有「雞蛋 10 個（3 天後到期）」與「雞蛋 8 個（10 天後到期）」且位置與單位相同
- **THEN** 清單 SHALL 顯示一張「雞蛋 18 個」的卡片、狀態為 `nearExpired`，展開 SHALL 看到兩筆批次

#### Scenario: 位置不同不合併

- **WHEN** 一筆雞蛋在「冷藏」、另一筆在「冷凍」
- **THEN** 兩者 SHALL 顯示為兩張卡片

#### Scenario: 合併不改變儲存

- **WHEN** 兩筆同名項目被合併顯示
- **THEN** 本機儲存 SHALL 仍為兩筆，各自的 id 與期限不變
