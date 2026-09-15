## ADDED Requirements

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
