## MODIFIED Requirements

### Requirement: 依類型的食用與浪費圓餅圖

圖表頁 SHALL 顯示兩個圓餅圖：食用紀錄依 `FoodItemType` 的**筆數**分布、浪費紀錄依 `FoodItemType` 的**筆數**分布。計量單位 MUST 為筆數而非點數（點數加權後不再等比例反映行為），也 MUST NOT 跨單位加總份量。每個扇形 SHALL 使用該類型的代表色。任一圓餅圖沒有資料時 SHALL 顯示 `noData` 提示而非空白。`givenAway` 的紀錄 SHALL 計入食用側。

#### Scenario: 有食用紀錄

- **WHEN** 使用紀錄含 3 筆 `consumed` 蔬菜與 1 筆 `consumed` 水果
- **THEN** 食用圓餅圖 SHALL 顯示蔬菜 3 筆、水果 1 筆兩個扇形

#### Scenario: 加權點數不影響比例

- **WHEN** 一筆蔬菜紀錄得 +3、三筆水果紀錄各得 +1
- **THEN** 圓餅圖 SHALL 呈現蔬菜 1 筆、水果 3 筆，MUST NOT 呈現成各佔一半

#### Scenario: 沒有浪費紀錄

- **WHEN** 使用紀錄沒有任何 `wasted`
- **THEN** 浪費圓餅圖位置 SHALL 顯示 `noData`

## ADDED Requirements

### Requirement: 浪費率月趨勢

圖表頁 SHALL 顯示浪費率折線圖：X 軸為使用日期的年月、Y 軸為該月「浪費筆數 ÷ 總筆數」的百分比。X 軸 SHALL 從有資料的最早月份連續列到最晚月份，最多顯示最近 12 個月；沒有任何紀錄的月份 SHALL 呈現為斷點而非 0%（0% 代表當月完全沒浪費，與沒資料不同）。沒有任何紀錄時 SHALL 顯示 `noData`。

#### Scenario: 兩個月的浪費率

- **WHEN** 2026 年 3 月有 8 筆食用、2 筆浪費，2026 年 4 月有 9 筆食用、1 筆浪費
- **THEN** 折線 SHALL 有 (2026/03, 20%)、(2026/04, 10%) 兩點

#### Scenario: 沒資料的月份

- **WHEN** 2026 年 2 月完全沒有任何紀錄
- **THEN** 該月 MUST NOT 被畫成 0%

### Requirement: 最常浪費的食物排行

圖表頁 SHALL 顯示最常浪費食物的前 5 名：以名稱正規化後分組，依浪費筆數由多到少排序，並顯示每項的筆數與（若有金額資料）累計浪費金額。筆數相同時 SHALL 依最近一次浪費時間排序。沒有浪費紀錄時 SHALL 顯示 `noData`。

#### Scenario: 排行內容

- **WHEN** 青椒被浪費 4 次、牛奶 2 次、其餘各 1 次
- **THEN** 排行 SHALL 以青椒、牛奶為前兩名並顯示各自筆數

### Requirement: 浪費原因分佈

圖表頁 SHALL 顯示浪費原因的分佈（依 `wasteReason` 的筆數）。未填原因的紀錄 SHALL 歸入「未填原因」並顯示其佔比，使使用者知道這張圖的完整度。沒有浪費紀錄時 SHALL 顯示 `noData`。

#### Scenario: 含未填原因

- **WHEN** 10 筆浪費中有 6 筆填了原因、4 筆沒填
- **THEN** 圖表 SHALL 同時呈現 6 筆的原因分佈與 4 筆的「未填原因」

### Requirement: 金額損益

圖表頁 SHALL 顯示以月為單位的金額統計：食用類紀錄的金額總和（救回）與浪費類紀錄的金額總和（損失）。統計 SHALL 只計入有 `priceTotal` 的紀錄，並 SHALL 同時顯示涵蓋率（有金額的筆數 ÷ 總筆數），避免使用者把部分資料誤讀為全貌。沒有任何帶金額的紀錄時 SHALL 顯示 `noData` 與補填金額的引導。

#### Scenario: 顯示涵蓋率

- **WHEN** 某月 20 筆紀錄中只有 8 筆有金額
- **THEN** 圖表 SHALL 顯示該月金額總和並標示涵蓋率 40%

#### Scenario: 完全沒有金額資料

- **WHEN** 使用者從未填過金額
- **THEN** 金額損益區 SHALL 顯示 `noData` 而非 0 元

### Requirement: 標示點數規則變更

統計頁凡呈現點數的區塊 SHALL 標示「點數規則於 2026-09-15 起改為依時效加權」，使跨越該日期的趨勢不被誤讀。

#### Scenario: 跨越變更日的資料

- **WHEN** 使用者的紀錄同時涵蓋 2026-09-15 之前與之後
- **THEN** 點數相關圖表 SHALL 顯示規則變更的說明
