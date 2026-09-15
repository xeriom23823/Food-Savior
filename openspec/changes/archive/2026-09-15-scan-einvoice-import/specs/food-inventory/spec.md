## ADDED Requirements

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
