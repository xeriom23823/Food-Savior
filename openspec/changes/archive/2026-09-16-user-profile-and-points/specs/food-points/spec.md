## ADDED Requirements

### Requirement: 點數累計成績由紀錄推導

系統 SHALL 由既有的 `UsedFoodItem.affectFoodPoint` 推導出成績摘要，MUST NOT 另外持久化任何累計欄位。摘要 SHALL 包含：累計總分（全部紀錄的點數總和）、本週淨分（以裝置當地時間的週一 00:00 為界）、等級與下一級進度、距離上次浪費的天數、六個里程碑的達成狀態。計算 SHALL 為純函式且 `now` 可注入。

#### Scenario: 累計總分是全部紀錄的總和

- **WHEN** 使用紀錄有 +3、+2、−2 三筆
- **THEN** 累計總分 SHALL 為 3

#### Scenario: 總分可以是負的

- **WHEN** 使用者只有兩筆 −3 的浪費紀錄
- **THEN** 累計總分 SHALL 為 −6 並照實顯示

#### Scenario: 本週以週一為界

- **WHEN** 今天是週三，週一有 +2、上週日有 +5
- **THEN** 本週淨分 SHALL 為 2

#### Scenario: 還原備份後成績跟著變

- **WHEN** 使用者還原了一份含 20 筆紀錄的備份
- **THEN** 成績 SHALL 立即反映還原後的紀錄，不需要任何額外的重算步驟

### Requirement: 等級依累計總分推導且不倒退為負

系統 SHALL 提供五個等級，門檻為 0、50、150、350、700 點。等級 SHALL 依 `max(累計總分, 0)` 對照門檻決定，因此總分為負時等級為第一級而不是「沒有等級」。等級名稱 SHALL 經由 l10n 取得。最高級時 SHALL 不再顯示下一級進度。

#### Scenario: 剛好達到門檻

- **WHEN** 累計總分為 50
- **THEN** 等級 SHALL 為第 2 級，進度顯示距離第 3 級還差 100 點

#### Scenario: 總分為負

- **WHEN** 累計總分為 −10
- **THEN** 等級 SHALL 為第 1 級，且 MUST NOT 顯示為錯誤或空白

#### Scenario: 已達最高級

- **WHEN** 累計總分為 800
- **THEN** 等級 SHALL 為第 5 級且 MUST NOT 顯示下一級進度

### Requirement: 距離上次浪費的天數

系統 SHALL 計算「距離上次浪費的天數」＝今天減去最後一筆浪費紀錄（`disposalMethod` 為 `composted` 或 `discarded`）的日期。沒有任何浪費紀錄但有其他紀錄時 SHALL 從最早一筆紀錄算起；完全沒有紀錄時 SHALL 為 null 且不顯示。此數值 MUST NOT 因為某天沒有任何紀錄而中斷。

#### Scenario: 三天前浪費過

- **WHEN** 最後一筆浪費紀錄是 3 天前
- **THEN** 天數 SHALL 為 3

#### Scenario: 中間有幾天完全沒開 App

- **WHEN** 最後一筆浪費是 10 天前，其間有 6 天完全沒有任何紀錄
- **THEN** 天數 SHALL 仍為 10

#### Scenario: 從來沒有浪費過

- **WHEN** 使用者有 5 筆食用紀錄、0 筆浪費，最早一筆在 8 天前
- **THEN** 天數 SHALL 為 8

#### Scenario: 完全沒有紀錄

- **WHEN** 使用紀錄為空
- **THEN** 天數 SHALL 為 null

### Requirement: 六個一次性里程碑

系統 SHALL 提供六個里程碑：第一筆紀錄、救回 10 項即期食物（單筆點數為 +3 的紀錄達 10 筆）、累計 100 點、連續 7 天沒浪費、連續 30 天沒浪費、累計 500 點。每個里程碑 SHALL 有達成狀態與 l10n 的名稱與達成條件。未達成的里程碑 SHALL 仍然顯示（以灰階與條件文字呈現），MUST NOT 隱藏。

#### Scenario: 救回十項

- **WHEN** 使用紀錄中有 10 筆點數為 +3 的紀錄
- **THEN** 「救回 10 項即期食物」SHALL 為已達成

#### Scenario: 未達成也看得見

- **WHEN** 使用者只達成了 2 個里程碑
- **THEN** 用戶頁 SHALL 顯示全部 6 個，未達成者以灰階與達成條件呈現

#### Scenario: 刪除紀錄後退回

- **WHEN** 使用者刪除了紀錄，使累計點數低於 100
- **THEN** 「累計 100 點」SHALL 退回未達成
