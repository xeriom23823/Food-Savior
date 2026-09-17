# Expired Food Processing Specification

## Purpose

定義 App 載入或還原資料時，對「已過期」食物的強制處理流程：使用者必須逐項決定過期食物是已食用還是已浪費，處理完成後這些項目才會離開現存清單並進入使用紀錄。此流程是食物點數獎懲的來源之一。

## Requirements

### Requirement: 載入時偵測過期並進入處理狀態

當清單從本機載入或由還原流程載入時，若存在狀態為 `expired` 的項目，系統 SHALL 進入 `FoodItemListNeedProcessing` 狀態，並保存三組資料：未過期的剩餘項目、待處理的過期項目，以及每個過期項目「是否食用」的勾選狀態（預設全部未勾選）。此狀態下 SHALL 顯示過期處理畫面而非一般清單。

#### Scenario: 啟動時有過期食物

- **WHEN** App 啟動且本機有 2 筆到期日早於現在的食物
- **THEN** 系統 SHALL 顯示過期處理畫面，列出這 2 筆並預設皆為未食用

#### Scenario: 啟動時無過期食物

- **WHEN** App 啟動且沒有任何過期食物
- **THEN** 系統 SHALL 直接進入一般清單

### Requirement: 逐項切換是否食用

在處理畫面中，使用者 SHALL 可對每筆過期食物切換「已食用／未食用」勾選；切換 SHALL 只影響該筆。

#### Scenario: 勾選其中一筆

- **WHEN** 使用者點擊第 2 筆的勾選框
- **THEN** 第 2 筆 SHALL 變為已食用，其餘維持不變

### Requirement: 處理完成後轉入使用紀錄並離開清單

使用者按下「處理完成」時，系統 SHALL 為每筆過期食物建立一筆 `UsedFoodItem`：勾選者 `disposalMethod` 為 `eatenAtRisk`（狀態 `consumed`）、未勾選者為 `discarded`（狀態 `wasted`），使用日期為當下、使用份量為全部、id 為新的 UUID；點數 SHALL 逐筆依 food-points 的加權規則計算，前一筆計入後一筆的當日正分總和。處理頁 SHALL 在有未勾選項目時提供選填的浪費原因（套用到該批所有丟棄紀錄），使用者可以不選。已處理的過期項目 SHALL 從現存清單**與 Hive Box `foodItems`** 移除，系統回到只含未過期項目的一般清單。

#### Scenario: 一筆食用一筆浪費

- **WHEN** 有 2 筆過期食物，使用者勾選第 1 筆後按處理完成
- **THEN** 使用紀錄 SHALL 新增 1 筆 `consumed`（+1）與 1 筆 `wasted`（−2），現存清單不再包含這 2 筆，且重新啟動後也不再要求處理它們

#### Scenario: 選填浪費原因

- **WHEN** 有未勾選的項目，使用者選擇「忘記吃」後按處理完成
- **THEN** 該批所有丟棄紀錄的 `wasteReason` SHALL 為 `forgotten`

#### Scenario: 跳過浪費原因

- **WHEN** 使用者未選擇任何原因即按處理完成
- **THEN** 系統 SHALL 照常完成處理，丟棄紀錄的 `wasteReason` 為 null

#### Scenario: 全部勾選為已食用時不問原因

- **WHEN** 所有過期項目都被勾選為已食用
- **THEN** 處理頁 MUST NOT 顯示浪費原因選項

#### Scenario: 處理完成後的本機儲存

- **WHEN** 處理完成
- **THEN** Hive Box `foodItems` SHALL 不再含有任何已處理項目的 id，未過期項目全部保留

#### Scenario: 處理完成後的清單內容

- **WHEN** 處理完成
- **THEN** 一般清單 SHALL 只顯示未過期項目，排序與狀態依 food-inventory 規格
