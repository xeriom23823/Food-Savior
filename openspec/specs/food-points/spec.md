# Food Points Specification

## Purpose

定義食物點數（Food Point）的獎懲規則：依「使用日期與有效期限的關係」與處理方式加權計分，每日加分總和有上限。點數記錄在每筆使用紀錄的 `affectFoodPoint` 欄位，供統計圖表與等級／里程碑機制使用。

## Requirements

### Requirement: 每日食用加分上限為 10

以使用日期的當地日曆日為單位，上限 SHALL 依該日既有紀錄中**正分的總和**計算（負分不計入）。若該日正分總和已達 10 或以上，新增的加分紀錄 SHALL 帶有 `affectFoodPoint = 0`；若加上新紀錄會超過 10，該筆 SHALL 取「10 減去當日已累積正分」的差額。扣分紀錄 SHALL 不受上限影響。

#### Scenario: 當日已達上限

- **WHEN** 某日既有紀錄的正分總和為 10，使用者再新增一筆該日的食用紀錄
- **THEN** 新紀錄的 `affectFoodPoint` SHALL 為 0

#### Scenario: 當日尚未達上限

- **WHEN** 某日既有正分總和為 6，使用者新增一筆該日的一般食用紀錄
- **THEN** 新紀錄的 `affectFoodPoint` SHALL 為 +2

#### Scenario: 差額截斷

- **WHEN** 某日既有正分總和為 9，使用者新增一筆本該得 +3 的即期救援紀錄
- **THEN** 新紀錄的 `affectFoodPoint` SHALL 為 1

#### Scenario: 浪費不放寬上限

- **WHEN** 某日既有正分總和為 10、並有一筆 −3 的浪費紀錄（總和為 7）
- **THEN** 新增的食用紀錄 SHALL 仍為 0，MUST NOT 因為負分而重新獲得加分空間

#### Scenario: 上限不影響浪費

- **WHEN** 某日既有正分總和為 12，使用者新增一筆該日已過期食物的丟棄紀錄
- **THEN** 新紀錄的 `affectFoodPoint` SHALL 為 −2

### Requirement: 所有寫入路徑套用相同規則

無論使用紀錄是由滑動操作、部分處理表單、合併卡片的 FEFO 扣減或過期處理流程寫入，點數規則 SHALL 一致；批次寫入時 SHALL 逐筆依序計算，前一筆的點數計入後一筆的當日正分總和。還原流程 SHALL 保留備份中既有的 `affectFoodPoint`，不重新計算。

#### Scenario: 過期處理產生的紀錄

- **WHEN** 過期處理將 3 筆已過期食物標記為食用（各 +1），且當日既有正分總和為 9
- **THEN** 三筆紀錄的點數 SHALL 依序為 +1、0、0

#### Scenario: 批次中含浪費

- **WHEN** 過期處理同時產生食用與丟棄紀錄，且當日正分已達上限
- **THEN** 食用紀錄 SHALL 為 0，丟棄紀錄 SHALL 依加權規則為 −2（已過期）

#### Scenario: 合併卡片跨批次

- **WHEN** 使用者對合併卡片一次用掉兩個批次
- **THEN** 兩筆紀錄 SHALL 各依自己批次的有效期限計算點數，不得共用同一個期限

#### Scenario: 還原保留原點數

- **WHEN** 備份中某筆紀錄的 `affectFoodPoint` 為 5，使用者執行還原
- **THEN** 還原後該筆 SHALL 仍為 5，即使當日總和已超過上限

### Requirement: 點數依時效與處理方式加權

點數 SHALL 依「使用日期與有效期限的關係」與 `disposalMethod` 加權計算，由單一 `FoodPointCalculator`（純函式，`now` 可注入）決定，所有寫入路徑共用。有效期限定義見 food-inventory。規則如下：

| `disposalMethod` | 條件 | `affectFoodPoint` |
|---|---|---|
| `eaten`／`givenAway` | 使用日在有效期限前 3 天內（含當日） | +3 |
| `eaten`／`givenAway` | 使用日距有效期限超過 3 天 | +2 |
| `eaten`／`givenAway` | 有效期限未知 | +2 |
| `eatenAtRisk` | 有效期限已過 | +1 |
| `composted` | 有效期限已過 | −1 |
| `composted` | 未過期或未知 | −2 |
| `discarded` | 有效期限已過 | −2 |
| `discarded` | 未過期或未知 | −3 |

點數 SHALL 與份量、金額無關，以「筆」計算。本規則自 2026-09-15 起生效。

#### Scenario: 即期救援

- **WHEN** 使用者在有效期限前 1 天把一筆食物吃完
- **THEN** 新紀錄的 `affectFoodPoint` SHALL 為 +3

#### Scenario: 一般食用

- **WHEN** 使用者在有效期限前 10 天把一筆食物吃完
- **THEN** 新紀錄的 `affectFoodPoint` SHALL 為 +2

#### Scenario: 期限未知的食用

- **WHEN** 使用者食用一筆 `unknownExpiry` 的食物
- **THEN** 新紀錄的 `affectFoodPoint` SHALL 為 +2

#### Scenario: 過期後才吃掉

- **WHEN** 使用者對已過期的食物選擇食用（`eatenAtRisk`）
- **THEN** 新紀錄的 `affectFoodPoint` SHALL 為 +1

#### Scenario: 還沒過期就丟掉

- **WHEN** 使用者把一筆尚未過期的食物丟棄
- **THEN** 新紀錄的 `affectFoodPoint` SHALL 為 −3

#### Scenario: 過期後丟棄

- **WHEN** 使用者把一筆已過期的食物丟棄
- **THEN** 新紀錄的 `affectFoodPoint` SHALL 為 −2

#### Scenario: 堆肥優於丟棄

- **WHEN** 使用者把一筆已過期的食物標記為 `composted`
- **THEN** 新紀錄的 `affectFoodPoint` SHALL 為 −1，優於同情境的丟棄（−2）

#### Scenario: 送人不扣分

- **WHEN** 使用者將一筆尚有 5 天期限的食物標記為 `givenAway`
- **THEN** 新紀錄的 `affectFoodPoint` SHALL 為 +2

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
