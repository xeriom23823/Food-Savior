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

每筆紀錄 SHALL 顯示名稱、份量（數量加單位或剩餘比例）、處理方式（`eaten`、`eatenAtRisk`、`givenAway`、`composted`、`discarded`，以語意色與類型圖示呈現）、使用日期（`yyyy-MM-dd`）與該筆點數。`wasteReason` 與 `priceTotal` 若有值 SHALL 一併顯示。點擊紀錄 SHALL 顯示詳情，詳情中 SHALL 包含該筆當時的有效期限，使使用者能看出點數的由來。

#### Scenario: 顯示一筆浪費紀錄

- **WHEN** 某日有一筆 `wasted` 的牛奶紀錄
- **THEN** 該列 SHALL 以浪費語意色呈現類型圖示並顯示使用日期

#### Scenario: 顯示一筆丟棄紀錄

- **WHEN** 某日有一筆 `discarded`、原因為「忘記吃」、金額 45 元的牛奶紀錄
- **THEN** 該列 SHALL 以浪費語意色呈現類型圖示，並顯示處理方式、原因、金額與點數

#### Scenario: 沒填的欄位不佔版面

- **WHEN** 某筆紀錄沒有 `wasteReason` 也沒有 `priceTotal`
- **THEN** 該列 MUST NOT 顯示這兩個欄位的佔位文字

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

### Requirement: 紀錄可依處理方式篩選

紀錄頁 SHALL 提供篩選，讓使用者只看食用類（`eaten`、`eatenAtRisk`、`givenAway`）或只看浪費類（`composted`、`discarded`）的紀錄。篩選 SHALL 作用於當前所選日期的清單，並在切換日期時保持。

#### Scenario: 只看浪費

- **WHEN** 使用者選擇只看浪費類
- **THEN** 清單 SHALL 只顯示 `composted` 與 `discarded` 的紀錄

#### Scenario: 切換日期保持篩選

- **WHEN** 使用者在只看浪費的狀態下切換到昨天
- **THEN** 篩選 SHALL 仍為只看浪費

### Requirement: 補記浪費原因

對已存在但 `wasteReason` 為 null 的浪費紀錄，系統 SHALL 允許使用者事後補選原因並寫回本機儲存。補記 MUST NOT 改變該筆的點數。

#### Scenario: 事後補原因

- **WHEN** 使用者對一筆沒有原因的浪費紀錄選擇「買太多」
- **THEN** 該筆 SHALL 更新 `wasteReason`，`affectFoodPoint` 保持不變
