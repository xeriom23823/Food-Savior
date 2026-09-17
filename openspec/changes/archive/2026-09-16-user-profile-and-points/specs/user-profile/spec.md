## ADDED Requirements

### Requirement: 用戶分頁分為成績與帳號兩區

用戶分頁 SHALL 由上到下分為「我的成績」與「帳號」兩區。成績區 SHALL 顯示等級卡（等級名稱、進度條、距離下一級的點數）、三個數字（累計總分、本週淨分、距離上次浪費的天數）與里程碑清單。帳號區 SHALL 顯示頭像、顯示名稱、Email，以及備份、還原、登出、刪除帳號四個動作。

#### Scenario: 有紀錄的使用者

- **WHEN** 使用者已有使用紀錄並開啟用戶分頁
- **THEN** 頁面 SHALL 依序顯示等級卡、三個數字、里程碑清單、帳號區

#### Scenario: 距離上次浪費無法計算

- **WHEN** 使用紀錄為空或無法計算天數
- **THEN** 該數字 SHALL 不顯示，其餘欄位照常呈現

### Requirement: 沒有紀錄時不顯示成績

使用紀錄為空時，成績區 SHALL 以 `EmptyState` 取代，內含引導文字與「去記第一樣食物」的動作，MUST NOT 顯示 0 分的等級卡或全部未達成的里程碑。

#### Scenario: 全新使用者

- **WHEN** 使用者從未記錄任何食物
- **THEN** 成績區 SHALL 顯示空狀態與前往食物分頁的動作，帳號區照常顯示

### Requirement: 修改顯示名稱

使用者 SHALL 可於帳號區修改顯示名稱。名稱不可為空白（`nameCannotBeEmpty`），長度上限 30 字。儲存成功後畫面上的名稱 SHALL 立即更新，並以成功回饋提示；失敗時 SHALL 顯示錯誤訊息且不改變原名稱。

#### Scenario: Email 註冊的使用者第一次設定名稱

- **WHEN** 使用者原本沒有顯示名稱，輸入「小明」並儲存
- **THEN** 帳號區 SHALL 立即顯示「小明」

#### Scenario: 空白名稱

- **WHEN** 使用者送出只有空白的名稱
- **THEN** 系統 SHALL 顯示 `nameCannotBeEmpty` 且不送出

### Requirement: 刪除帳號需二次確認並說明影響

刪除帳號 SHALL 先顯示確認介面，明確說明：帳號與雲端備份會被刪除，**本機的食物清單與使用紀錄不會被刪除**。確認後才執行刪除。Firebase 要求近期登入而失敗時，系統 SHALL 顯示「請重新登入後再試」而不是通用錯誤。

#### Scenario: 確認刪除

- **WHEN** 使用者在確認介面選擇刪除
- **THEN** 系統 SHALL 刪除帳號並回到登入畫面

#### Scenario: 需要重新登入

- **WHEN** Firebase 回報 `requires-recent-login`
- **THEN** 系統 SHALL 顯示「請重新登入後再試」，帳號 SHALL 不被刪除

#### Scenario: 取消

- **WHEN** 使用者在確認介面選擇取消
- **THEN** 帳號與資料 SHALL 都不改變

### Requirement: 用戶分頁的視覺一律走設計系統

用戶分頁與其子元件 MUST NOT 使用 `Colors.*`、`Color(0x…)` 或硬編碼字級與中文字串；顏色取自 `ColorScheme` 與 `FoodStatusColors`，間距取自 `AppSpacing`，回饋一律走 `AppSnackBar`，破壞性確認走 `ConfirmSheet`。

#### Scenario: 靜態檢查

- **WHEN** 對 `lib/pages/user` 搜尋 `Colors\.`、`Color(0x`、`fontSize:`
- **THEN** SHALL 沒有任何結果
