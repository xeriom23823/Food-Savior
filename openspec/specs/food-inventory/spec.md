# Food Inventory Specification

## Purpose

定義「現存食物清單」的建立、檢視、編輯、刪除、分群與狀態推導。這是 App 的核心資料：使用者記錄家中每一項生鮮食物的名稱、份量或剩餘比例、單位、存放位置、成本與保存期限；期限支援精確、區間、只到月份、完全未知四種精度，系統依有效期限推導新鮮／快過期／已過期／期限未知狀態並持久化在本機。

## Requirements

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

### Requirement: 刪除與清空

系統 SHALL 提供移除單一項目（`FoodItemListRemove`）與清空全部（`FoodItemListClear`）的能力；兩者都 SHALL 同步反映到本機儲存。清空僅供還原流程使用，不直接暴露為一般 UI 操作。

#### Scenario: 移除項目

- **WHEN** 某項目被移除
- **THEN** 該項目 SHALL 不再出現在清單，且本機儲存中不再有該 id

### Requirement: 載入失敗可重試

當清單進入錯誤狀態時，系統 SHALL 顯示 `foodItemListError` 訊息與 `refresh` 動作，重試時重新從本機儲存載入。

#### Scenario: 錯誤後重試

- **WHEN** 清單顯示錯誤，使用者按下 `refresh`
- **THEN** 系統 SHALL 重新執行從本機載入的流程

### Requirement: 所有變更寫穿至本機儲存

清單的每一次新增、更新、移除、清空 SHALL 立即寫入 Hive Box `foodItem`（以 id 為 key），使 App 重新啟動後資料一致。

#### Scenario: 重啟後資料保留

- **WHEN** 使用者新增一筆食物後關閉並重新開啟 App
- **THEN** 該食物 SHALL 仍出現在清單中且欄位不變

### Requirement: FoodItem 以欄位值判定相等

`FoodItem` 與 `UsedFoodItem` 的 `==` SHALL 比較全部欄位（含 id），`hashCode` MUST 與 `==` 一致；`UsedFoodItem` 與 `FoodItem` 即使 id 相同也 SHALL 不相等。這使 Bloc 狀態（Equatable）能正確偵測清單內容變化。

#### Scenario: 欄位相同

- **WHEN** 兩個 `FoodItem` 所有欄位相同
- **THEN** 兩者 SHALL 相等且 `hashCode` 相同，放入 Set 只保留一個

#### Scenario: 數量不同

- **WHEN** 兩個 `FoodItem` 只有數量不同
- **THEN** 兩者 SHALL 不相等

### Requirement: copyWith 保留未指定的欄位

`FoodItem.copyWith` 與 `UsedFoodItem.copyWith` 未提供的參數 SHALL 保留原值，包含 `id`；不得以空字串或其他預設值覆蓋。

#### Scenario: 只改狀態

- **WHEN** 對 id 為 `abc` 的食物呼叫 `copyWith(status: expired)`
- **THEN** 結果的 id SHALL 仍為 `abc`，其餘欄位不變

#### Scenario: 還原時的批次狀態推導

- **WHEN** 還原流程對多筆未過期食物推導 `nearExpired` 狀態並寫入 Box
- **THEN** 每筆 SHALL 以各自原本的 id 儲存，不互相覆蓋

### Requirement: 支援批次建立食物

除了單筆表單新增之外，系統 SHALL 支援一次建立多筆 `FoodItem`。批次建立的每一筆 SHALL 與單筆新增套用相同的欄位要求（名稱不可為空、數量為正數、單位必須存在）與相同的狀態推導規則，且 SHALL 各自取得唯一 id。批次來源（例如發票匯入）SHALL NOT 繞過這些規則，也 SHALL NOT 在使用者確認前寫入。

#### Scenario: 一次加入多筆

- **WHEN** 使用者確認匯入 5 筆已通過欄位要求的草稿
- **THEN** 系統 SHALL 建立 5 筆 `FoodItem`、各自取得唯一 id、依到期日推導狀態並寫入本機儲存

#### Scenario: 批次中有名稱為空的項目

- **WHEN** 批次中某一筆的名稱為空
- **THEN** 系統 SHALL 以 `nameCannotBeEmpty` 標示該筆、SHALL NOT 建立該筆，其餘通過驗證的項目不受影響

#### Scenario: 批次中期限未知的項目

- **WHEN** 批次中某一筆的期限為未知
- **THEN** 該筆 SHALL 照常建立，狀態 SHALL 為 `unknownExpiry` 並列入待補期限

#### Scenario: 批次建立後的清單排序

- **WHEN** 批次建立完成
- **THEN** 清單 SHALL 依既有排序規則重新排序，不因來源是批次而有不同順序

### Requirement: 期限提供快速選項

在「精確到日」的期限輸入中，系統 SHALL 提供一排相對於**裝置當地今天**的快速選項：今天、明天、3 天後、1 週後、2 週後、1 個月後。選擇任一項 SHALL 立即把期限設為該日期的當天零時，且 SHALL NOT 需要開啟完整日期選擇器。

完整日期選擇器 SHALL 保留，供快速選項涵蓋不到的日期使用。

目前的期限值剛好等於某個快速選項所對應的日期時，該選項 SHALL 呈現選中狀態；都不相符時 SHALL 沒有任何選項呈現選中狀態。

快速選項 SHALL 只在「精確到日」模式出現；「區間」「只到月」「不知道」三種模式 SHALL NOT 顯示。

#### Scenario: 選擇今天

- **GIVEN** 裝置當地日期為 2026 年 9 月 15 日
- **WHEN** 使用者點選「今天」
- **THEN** 期限 SHALL 為 2026 年 9 月 15 日零時，精度 SHALL 為精確到日

#### Scenario: 選擇一週後

- **GIVEN** 裝置當地日期為 2026 年 9 月 15 日
- **WHEN** 使用者點選「1 週後」
- **THEN** 期限 SHALL 為 2026 年 9 月 22 日零時

#### Scenario: 目前值等於某個選項時該選項呈現選中

- **GIVEN** 裝置當地日期為 2026 年 9 月 15 日，且目前期限為 2026 年 9 月 16 日
- **WHEN** 使用者檢視期限輸入
- **THEN** 「明天」SHALL 呈現選中狀態，其餘選項 SHALL NOT 呈現選中狀態

#### Scenario: 目前值不等於任何選項

- **GIVEN** 目前期限是一個不等於任何快速選項的日期
- **WHEN** 使用者檢視期限輸入
- **THEN** SHALL 沒有任何快速選項呈現選中狀態，且期限值 SHALL 維持不變

#### Scenario: 切換到其他精度時不顯示快速選項

- **WHEN** 使用者把精度切換為「區間」、「只到月」或「不知道」
- **THEN** 系統 SHALL NOT 顯示快速選項

#### Scenario: 快速選項不取代完整選擇器

- **WHEN** 使用者需要一個快速選項涵蓋不到的日期
- **THEN** 系統 SHALL 仍可經由完整日期選擇器設定該日期

### Requirement: 期限可設為今天或過去

系統 SHALL 允許把期限設為裝置當地的今天或更早的日期。今天到期與已經過期都是真實情況，SHALL NOT 以驗證或選擇器的可選範圍阻擋。

#### Scenario: 期限設為今天

- **WHEN** 使用者把某項食物的期限設為今天
- **THEN** 系統 SHALL 接受並儲存，該項目 SHALL 依既有規則推導為 `nearExpired`

#### Scenario: 期限設為昨天

- **WHEN** 使用者把某項食物的期限設為昨天
- **THEN** 系統 SHALL 接受並儲存，該項目 SHALL 依既有規則推導為 `expired`

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
