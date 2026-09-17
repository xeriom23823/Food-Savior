## MODIFIED Requirements

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

## ADDED Requirements

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
