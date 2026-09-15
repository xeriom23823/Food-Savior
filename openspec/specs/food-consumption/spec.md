# Food Consumption Specification

## Purpose

定義使用者如何把現存食物標記為「已食用」或「已浪費」：全部使用、部分使用、直接浪費三種操作，以及它們如何同時更新現存清單與使用紀錄。這些操作是食物點數的主要來源。

## Requirements

### Requirement: 滑動操作面板

每筆現存食物 SHALL 提供滑動操作：起始側為 `edit`；結束側依序為 `expire`（標記浪費）、`batchUse`（部分使用）、`useAll`（全部使用）。操作後面板 SHALL 自動收合。

#### Scenario: 展開結束側面板

- **WHEN** 使用者向左滑動一筆食物
- **THEN** 系統 SHALL 顯示 `expire`、`batchUse`、`useAll` 三個動作

### Requirement: 全部使用

使用者選擇 `useAll` 時，系統 SHALL 從現存清單移除該項目，並新增一筆 `UsedFoodItem`：狀態 `consumed`、數量為該項目全部數量、使用日期為當下、id 為新 UUID。系統 SHALL 以「名稱 + 數量單位 + `consumed`」訊息與食用動畫提示。

#### Scenario: 全部使用一筆食物

- **WHEN** 使用者對數量 3 個的雞蛋選擇 `useAll`
- **THEN** 雞蛋 SHALL 從清單消失，使用紀錄新增一筆數量 3、狀態 `consumed` 的雞蛋

### Requirement: 標記浪費

使用者選擇 `expire` 時，系統 SHALL 從現存清單移除該項目，並新增一筆狀態 `wasted`、數量為全部、使用日期為當下的 `UsedFoodItem`，以「名稱 + `wasted`」訊息與丟棄動畫提示。

#### Scenario: 丟棄一筆食物

- **WHEN** 使用者對一筆食物選擇 `expire`
- **THEN** 該食物 SHALL 從清單消失，使用紀錄新增一筆 `wasted` 紀錄

### Requirement: 部分使用需驗證數量與日期

使用者選擇 `batchUse` 時，系統 SHALL 顯示表單要求使用數量與使用日期（預設今天，可選擇）。使用數量 MUST 為正整數且不得超過現有數量，否則分別顯示 `quantityCannotBeEmpty`、`quantityMustBePositive`、`quantityExceedsAvailable`。送出後：剩餘數量大於 0 時 SHALL 更新該項目數量並保留在清單；剩餘為 0 時 SHALL 移除該項目。系統 SHALL 新增一筆數量為使用數量、狀態 `consumed`、使用日期為所選日期的 `UsedFoodItem`。

#### Scenario: 使用部分數量

- **WHEN** 使用者對數量 5 的蘋果輸入使用 2、日期今天並送出
- **THEN** 清單中蘋果數量 SHALL 變為 3，使用紀錄新增一筆數量 2 的 `consumed` 蘋果

#### Scenario: 使用全部數量

- **WHEN** 使用者對數量 5 的蘋果輸入使用 5
- **THEN** 蘋果 SHALL 從清單移除，使用紀錄新增一筆數量 5 的 `consumed` 紀錄

#### Scenario: 數量超過現有

- **WHEN** 使用者對數量 5 的蘋果輸入使用 6
- **THEN** 系統 SHALL 顯示 `quantityExceedsAvailable` 且不改變任何資料

#### Scenario: 指定過去日期

- **WHEN** 使用者將使用日期選為 3 天前
- **THEN** 新增的使用紀錄 SHALL 以該日期為使用日期，並影響該日的食物點數計算
