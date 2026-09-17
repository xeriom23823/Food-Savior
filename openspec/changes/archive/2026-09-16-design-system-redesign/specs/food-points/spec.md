## REMOVED Requirements

### Requirement: 食用加一分、浪費扣一分

**Reason**: 固定 ±1 無法區分「即期救援」與「還沒過期就丟」，而這正是產品要鼓勵與嚇阻的兩種行為。由下方新增的「點數依時效與處理方式加權」取代。

**Migration**: 2026-09-15 之前寫入的紀錄保留原 `affectFoodPoint`，不追溯重算；統計頁標示規則變更日期。

## ADDED Requirements

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

## MODIFIED Requirements

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
