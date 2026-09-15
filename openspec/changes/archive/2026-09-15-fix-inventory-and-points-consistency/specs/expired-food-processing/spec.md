## MODIFIED Requirements

### Requirement: 處理完成後轉入使用紀錄並離開清單

使用者按下「處理完成」時，系統 SHALL 為每筆過期食物建立一筆 `UsedFoodItem`：勾選者狀態為 `consumed`、未勾選者為 `wasted`，使用日期為當下、使用數量為全部數量、id 為新的 UUID；這些紀錄 SHALL 以批次新增（逐筆套用食物點數規則）寫入使用紀錄。已處理的過期項目 SHALL 從現存清單**與 Hive Box `foodItem`** 移除，系統回到只含未過期項目的一般清單。

#### Scenario: 一筆食用一筆浪費

- **WHEN** 有 2 筆過期食物，使用者勾選第 1 筆後按處理完成
- **THEN** 使用紀錄 SHALL 新增 1 筆 `consumed` 與 1 筆 `wasted`，現存清單不再包含這 2 筆，且重新啟動後也不再要求處理它們

#### Scenario: 處理完成後的本機儲存

- **WHEN** 處理完成
- **THEN** Hive Box `foodItem` SHALL 不再含有任何已處理項目的 id，未過期項目全部保留

#### Scenario: 處理完成後的清單內容

- **WHEN** 處理完成
- **THEN** 一般清單 SHALL 只顯示未過期項目，排序與狀態依 food-inventory 規格
