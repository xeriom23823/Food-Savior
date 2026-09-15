# Food Points Specification

## Purpose

定義食物點數（Food Point）的獎懲規則：食用加分、浪費扣分、每日食用加分有上限。點數記錄在每筆使用紀錄的 `affectFoodPoint` 欄位，供統計圖表與未來的獎勵機制使用。

## Requirements

### Requirement: 食用加一分、浪費扣一分

每筆狀態為 `consumed` 的使用紀錄 SHALL 帶有 `affectFoodPoint = +1`；每筆狀態為 `wasted` 的使用紀錄 SHALL 帶有 `affectFoodPoint = -1`。點數與數量無關，以「筆」計算。

#### Scenario: 食用一筆

- **WHEN** 使用者全部使用一筆食物
- **THEN** 新增的使用紀錄 `affectFoodPoint` SHALL 為 +1

#### Scenario: 浪費一筆

- **WHEN** 使用者將一筆食物標記為浪費
- **THEN** 新增的使用紀錄 `affectFoodPoint` SHALL 為 -1

### Requirement: 每日食用加分上限為 10

以使用日期的當地日曆日為單位，若該日既有紀錄的 `affectFoodPoint` 總和已達 10 或以上，新增的 `consumed` 紀錄 SHALL 帶有 `affectFoodPoint = 0`。浪費紀錄 SHALL 不受上限影響，永遠為 -1。

#### Scenario: 當日已達上限

- **WHEN** 某日已有 10 筆 `consumed` 紀錄（總和 10），使用者再新增一筆該日的食用紀錄
- **THEN** 新紀錄的 `affectFoodPoint` SHALL 為 0

#### Scenario: 當日尚未達上限

- **WHEN** 某日既有點數總和為 9，使用者新增一筆該日的食用紀錄
- **THEN** 新紀錄的 `affectFoodPoint` SHALL 為 +1

#### Scenario: 上限不影響浪費

- **WHEN** 某日既有點數總和為 12，使用者新增一筆該日的浪費紀錄
- **THEN** 新紀錄的 `affectFoodPoint` SHALL 為 -1

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
