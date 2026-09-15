# Statistics Charts Specification

## Purpose

定義「圖表」分頁的行為：以使用紀錄與食物點數為資料來源，呈現食用與浪費依食物類型的分布（圓餅圖）與依月份的趨勢（折線圖），讓使用者看見自己減少浪費的成效與行為模式。圖表必須隨紀錄變動更新，並在沒有資料時給出明確提示。

## Requirements

### Requirement: 依類型的食用與浪費圓餅圖

圖表頁 SHALL 顯示兩個圓餅圖：食用點數依 `FoodItemType` 分布、浪費點數（取絕對值）依 `FoodItemType` 分布。每個扇形 SHALL 使用該類型的代表色。任一圓餅圖沒有資料時 SHALL 顯示「尚無資料」提示而非空白。

#### Scenario: 有食用紀錄

- **WHEN** 使用紀錄含 3 筆 `consumed` 蔬菜（點數 +1 各一）與 1 筆 `consumed` 水果
- **THEN** 食用圓餅圖 SHALL 顯示蔬菜 3、水果 1 兩個扇形

#### Scenario: 沒有浪費紀錄

- **WHEN** 使用紀錄沒有任何 `wasted`
- **THEN** 浪費圓餅圖位置 SHALL 顯示「尚無資料」

### Requirement: 月趨勢折線圖

圖表頁 SHALL 顯示折線圖，以使用日期的月份為 X 軸、該月點數總和為 Y 軸，分別繪出食用（綠）與浪費（紅）兩條線，並顯示資料點與格線。

#### Scenario: 兩個月的資料

- **WHEN** 使用紀錄在 3 月有食用點數 5、浪費 -2，在 4 月有食用 3
- **THEN** 食用線 SHALL 有 (3, 5)、(4, 3) 兩點，浪費線有 (3, -2) 一點

### Requirement: 圖表隨紀錄即時更新

圖表 SHALL 監聽使用紀錄狀態；紀錄新增、刪除或還原後，圓餅圖與折線圖 SHALL 在下一次進入或停留在圖表頁時反映最新資料。

#### Scenario: 刪除紀錄後

- **WHEN** 使用者在紀錄頁刪除一筆 `consumed` 蔬菜後切到圖表頁
- **THEN** 蔬菜扇形 SHALL 減少 1 點
