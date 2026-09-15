## MODIFIED Requirements

### Requirement: 所有寫入路徑套用相同規則

無論使用紀錄是由滑動操作、部分使用表單或過期處理流程寫入，點數規則 SHALL 一致；批次寫入時 SHALL 逐筆依序計算，前一筆的點數計入後一筆的當日總和。還原流程 SHALL 保留備份中既有的 `affectFoodPoint`，不重新計算。

#### Scenario: 過期處理產生的紀錄

- **WHEN** 過期處理將 3 筆食物標記為食用，且當日既有點數總和為 9
- **THEN** 三筆紀錄的點數 SHALL 依序為 +1、0、0

#### Scenario: 批次中含浪費

- **WHEN** 過期處理同時產生食用與浪費紀錄，且當日已達上限
- **THEN** 食用紀錄 SHALL 為 0，浪費紀錄 SHALL 為 -1

#### Scenario: 還原保留原點數

- **WHEN** 備份中某筆紀錄的 `affectFoodPoint` 為 5，使用者執行還原
- **THEN** 還原後該筆 SHALL 仍為 5，即使當日總和已超過上限
