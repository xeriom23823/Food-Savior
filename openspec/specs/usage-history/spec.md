# Usage History Specification

## Purpose

定義「使用紀錄」分頁：依日期瀏覽已食用與已浪費的食物、查看詳情、刪除紀錄，以及紀錄在本機的持久化方式。統計圖表與食物點數皆以此資料為基礎。

## Requirements

### Requirement: 依日期瀏覽紀錄

紀錄頁 SHALL 預設顯示今天的紀錄，並提供以所選日期為基準的一週（週一到週日）日期列；點擊任一日 SHALL 切換為該日的紀錄。系統 SHALL 另提供日期選擇器（範圍 2021 至 2101 年）跳到任意日期。今天的日期 SHALL 有明顯標示，所選日期 SHALL 與其他日期區分。

#### Scenario: 切換到昨天

- **WHEN** 使用者點擊日期列中昨天的日期
- **THEN** 清單 SHALL 只顯示使用日期為昨天的紀錄

#### Scenario: 以日期選擇器跳到上個月

- **WHEN** 使用者以日期選擇器選擇上個月的某一天
- **THEN** 日期列 SHALL 切換為該日所在的一週，清單顯示該日的紀錄

### Requirement: 紀錄列顯示內容

每筆紀錄 SHALL 顯示名稱、數量與單位、狀態（`consumed` 或 `wasted`，以狀態色與類型圖示呈現）以及使用日期（`yyyy-MM-dd`）。點擊紀錄 SHALL 顯示詳情。

#### Scenario: 顯示一筆浪費紀錄

- **WHEN** 某日有一筆 `wasted` 的牛奶紀錄
- **THEN** 該列 SHALL 以 `wasted` 狀態色呈現類型圖示並顯示使用日期

### Requirement: 刪除紀錄需確認

使用者 SHALL 可刪除單筆紀錄；系統 SHALL 先顯示確認對話框，確認後從本機儲存移除並重新載入當前日期的清單。

#### Scenario: 確認刪除

- **WHEN** 使用者選擇刪除某筆紀錄並確認
- **THEN** 該紀錄 SHALL 從清單與本機儲存消失，該日的統計與點數隨之更新

#### Scenario: 取消刪除

- **WHEN** 使用者在確認對話框選擇取消
- **THEN** 紀錄 SHALL 保持不變

### Requirement: 紀錄持久化與排序

所有 `UsedFoodItem` SHALL 以 id 為 key 寫入 Hive Box `usedFoodItem`；新增或更新後 SHALL 依使用日期由舊到新排序。批次寫入（過期處理、還原）SHALL 保留每筆原有的 id 與使用日期。

#### Scenario: 重啟後紀錄保留

- **WHEN** 使用者新增數筆紀錄後重新啟動 App
- **THEN** 所有紀錄 SHALL 仍可依日期查到
