## Context

四個 bug 全在資料層，且 baseline specs 已描述正確行為；本 change 的目的是讓實作對齊規格，並以 bloc_test 鎖定。

## Decisions

### D1. ProcessComplete 直接刪 Box 項目，而不是改用「已處理」狀態

- 刪除最簡單且與規格一致（過期處理後項目「離開」清單）；使用紀錄已保存完整資訊。
- 實作：`for (item in tempFoodItems) await repo.deleteFoodItem(item.id)`，再 `getNonExpiredFoodItems()`。還原路徑（`FoodItemListLoad`）的過期項目本來就沒寫進 Box，刪不存在的 key 無害。

### D2. 新 event `UsedFoodItemListAddAll` 而不是改 `Load` 的語意

- `Load` 語意是「整批替換／匯入既有紀錄」（還原用，保留點數）；`AddAll` 是「新事件批次進帳」（套用規則）。兩者目的不同，拆開比加 flag 清楚。
- 點數計算抽成 Bloc 私有方法 `_pointFor(UsedFoodItem item, List<UsedFoodItem> existing)`，`Add` 與 `AddAll` 共用；`AddAll` 逐筆把前一筆加入 `existing` 再算下一筆。
- `AddAll` 不檢查 `state is Loaded`（過期處理頁在啟動時就派發，此時紀錄 Bloc 可能仍在載入），直接以 Repository 內容計算。

### D3. `copyWith({String? id})` 預設 null

- 現行 `String? id = ''` 是筆誤；所有呼叫端都手動傳 `id: x.id` 才能繞過。改成 null 後既有呼叫不受影響。

### D4. 值相等

- `==`：`identical || (other is FoodItem && runtimeType == other.runtimeType && 所有欄位相等)`；`hashCode`：`Object.hash(...)`。`UsedFoodItem` 覆寫時加入 `usedDate`、`affectFoodPoint`。
- 不改用 Equatable mixin，因為 `FoodItem extends HiveObject`（單一繼承），且 `EquatableMixin` 需 `props`，維護成本相同。

## Risks / Trade-offs

- 值相等後，`FoodItemListUpdate` 以 `foodItem == event.originalFoodItem` 找項目：呼叫端傳的是清單中的同一實例，仍成立；若未來傳「同 id 但已修改」的物件會找不到 → 後續 D8（design-system-redesign）改為以 id 比對。
- `AddAll` 逐筆 `await put` 在大量批次時較慢（過期處理一般 < 20 筆，可接受）。

## Migration Plan

無資料遷移。既有 Box 中因舊 `copyWith` 產生的 id 為空字串的項目（若有）會在下次載入時正常顯示，使用者可手動刪除；不另寫修復程式。
