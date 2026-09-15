# Food Inventory Specification

## Purpose

定義「現存食物清單」的建立、檢視、編輯、刪除、排序與狀態推導。這是 App 的核心資料：使用者記錄家中每一項生鮮食物的數量、單位、存放日與到期日，系統依到期日推導新鮮／快過期／已過期狀態並持久化在本機。

## Requirements

### Requirement: 新增食物需通過欄位驗證

系統 SHALL 允許使用者以名稱、類型、數量、單位、描述、存放日期、到期日期建立一筆 `FoodItem`，並在儲存前驗證：名稱不可為空、數量必須是正整數、單位必須選擇。驗證失敗時 SHALL 以對應 l10n key（`nameCannotBeEmpty`、`quantityCannotBeEmpty`、`quanityMustBeANumber`、`quantityMustBePositive`、`unitCannotBeEmpty`）顯示錯誤，且不得寫入資料。

#### Scenario: 有效輸入新增成功

- **WHEN** 使用者填入名稱「牛奶」、類型 `eggAndMilk`、數量 1、單位 `milliliter`、存放日今天、到期日 7 天後並送出
- **THEN** 系統 SHALL 產生唯一 id（UUID v4）、將項目寫入本機儲存、關閉表單並以 `added` 訊息提示

#### Scenario: 名稱為空

- **WHEN** 使用者未填名稱即送出
- **THEN** 系統 SHALL 顯示 `nameCannotBeEmpty` 且不新增項目

#### Scenario: 數量不是正整數

- **WHEN** 使用者在數量輸入「abc」或「0」或「-3」
- **THEN** 系統 SHALL 分別顯示 `quanityMustBeANumber` 或 `quantityMustBePositive`，且不新增項目

#### Scenario: 未選擇單位

- **WHEN** 使用者未選擇單位即送出
- **THEN** 系統 SHALL 顯示 `unitCannotBeEmpty`

### Requirement: 食物類型與單位為固定列舉

`FoodItemType` SHALL 包含 vegetable、fruit、meat、eggAndMilk、seafood、cannedFood、cookedFood、drink、snack、bread、others 共 11 種；`Unit` SHALL 包含 gram、milliliter、piece 三種。每種類型 SHALL 有固定圖示與代表色；類型、單位的顯示名稱 SHALL 經由 l10n（`foodItemType*`、`unit*`）取得。

#### Scenario: 顯示數量與單位

- **WHEN** 一筆食物數量為 500、單位為 gram、語系為 zh-TW
- **THEN** 清單 SHALL 顯示「500 公克」（`quantity` 與 `unitGram` 組合）

### Requirement: 依到期日推導狀態

系統 SHALL 以裝置當地時間為準推導 `FoodItemStatus`：到期日早於現在為 `expired`；到期日在現在起 3 天內為 `nearExpired`；其餘為 `fresh`。狀態推導 SHALL 在載入清單時對所有項目執行，並在新增項目時對該項目執行。

#### Scenario: 到期日在 2 天後

- **WHEN** 使用者新增到期日為 2 天後的食物
- **THEN** 該項目狀態 SHALL 為 `nearExpired`

#### Scenario: 到期日在 10 天後

- **WHEN** 使用者新增到期日為 10 天後的食物
- **THEN** 該項目狀態 SHALL 為 `fresh`

#### Scenario: 載入時發現已過期

- **WHEN** App 載入清單且某項目的到期日早於現在
- **THEN** 該項目狀態 SHALL 更新為 `expired` 並寫回本機儲存，並進入過期處理流程（見 expired-food-processing）

### Requirement: 清單依到期日排序並顯示剩餘天數

清單 SHALL 依到期日由近到遠排序。每列 SHALL 顯示名稱與數量單位、類型圖示（以狀態色著色）、描述，以及剩餘天數：到期日為今天顯示 `expireToday`；已過期顯示 `expired`；否則顯示 `expire` 與剩餘天數加 `days`。

#### Scenario: 新增後重新排序

- **WHEN** 清單有到期日 5 天後與 10 天後的項目，使用者新增到期日 7 天後的項目
- **THEN** 清單順序 SHALL 為 5 天、7 天、10 天

#### Scenario: 今日到期

- **WHEN** 某項目到期日為今天
- **THEN** 該列剩餘天數欄 SHALL 顯示 `expireToday`

### Requirement: 檢視詳情

系統 SHALL 在使用者點擊清單項目時顯示詳情，包含名稱、類型、數量與單位、存放日期與到期日期（格式 `yyyy-MM-dd`）、描述。

#### Scenario: 點擊項目

- **WHEN** 使用者點擊一筆食物
- **THEN** 系統 SHALL 顯示該項目的詳情對話框，不改變資料

### Requirement: 編輯食物

系統 SHALL 允許使用者長按項目或使用「編輯」滑動動作開啟編輯表單，套用與新增相同的驗證規則；儲存後 SHALL 保留原 id、寫回本機儲存、重新排序並以 `updated` 提示。

#### Scenario: 修改到期日

- **WHEN** 使用者將某項目到期日從 10 天後改為 2 天後並儲存
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
