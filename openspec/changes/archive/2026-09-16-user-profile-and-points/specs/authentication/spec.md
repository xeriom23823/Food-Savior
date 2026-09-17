## MODIFIED Requirements

### Requirement: 顯示使用者資訊

使用者頁 SHALL 顯示目前使用者的頭像（無圖片時顯示預設圖示）、Email 與顯示名稱。顯示名稱為空時 SHALL 顯示可點擊的「設定名稱」提示而不是一片空白。使用者更新顯示名稱後，畫面 SHALL 在不重新登入的情況下立即反映新名稱。

#### Scenario: Google 帳號有頭像

- **WHEN** 使用者以有頭像的 Google 帳號登入
- **THEN** 使用者頁 SHALL 顯示該頭像、Email 與名稱

#### Scenario: Email 註冊沒有名稱

- **WHEN** 使用者以 Email 註冊且從未設定名稱
- **THEN** 使用者頁 SHALL 顯示「設定名稱」的提示而不是空白

#### Scenario: 改名後立即反映

- **WHEN** 使用者更新顯示名稱
- **THEN** 使用者頁 SHALL 立即顯示新名稱，MUST NOT 需要重新登入

## ADDED Requirements

### Requirement: 重設密碼

系統 SHALL 允許使用者以 Email 要求重設密碼信，入口同時存在於登入頁與用戶頁。送出後 SHALL 顯示「已寄出」的回饋。Email 格式錯誤或該帳號不存在時 SHALL 顯示對應訊息。

#### Scenario: 從登入頁寄出

- **WHEN** 使用者在登入頁輸入 Email 後點「忘記密碼」
- **THEN** 系統 SHALL 寄出重設信並顯示成功回饋

#### Scenario: Email 格式錯誤

- **WHEN** 使用者輸入不是 Email 的字串
- **THEN** 系統 SHALL 顯示 `invalidEmail` 且不寄信

### Requirement: 刪除帳號

系統 SHALL 提供刪除 Firebase 帳號的能力。近期未登入而被拒絕時 SHALL 以專屬的失敗原因回報，供 UI 顯示「請重新登入後再試」。刪除帳號 MUST NOT 清除本機的食物與使用紀錄。

#### Scenario: 刪除成功

- **WHEN** 刪除成功
- **THEN** 使用者串流 SHALL 發射 `User.empty`，路由回到登入畫面

#### Scenario: 需要近期登入

- **WHEN** Firebase 回報 `requires-recent-login`
- **THEN** 系統 SHALL 回報專屬失敗原因，帳號 SHALL 保留

### Requirement: 更新顯示名稱

系統 SHALL 提供更新 Firebase 顯示名稱的能力。更新完成後 SHALL 重新載入使用者並在 `user` 串流上再發射一次，使 UI 不需重新登入就能看到新名稱。

#### Scenario: 串流再次發射

- **WHEN** 顯示名稱由空改為「小明」
- **THEN** `user` 串流 SHALL 發射一個 `name` 為「小明」的 `User`

### Requirement: 登入與註冊頁使用設計系統

登入頁與註冊頁 MUST NOT 使用 `Colors.*`、`Color(0x…)` 或硬編碼字級；錯誤訊息 SHALL 顯示在表單上方的固定區塊（不用會蓋住按鈕的 SnackBar），成功回饋走 `AppSnackBar`。兩頁在明暗主題與 zh／en 下 SHALL 都可讀且不溢出，鍵盤彈出時輸入欄 MUST 不被遮擋。

#### Scenario: 深色模式下的登入失敗

- **WHEN** 深色模式下登入失敗
- **THEN** 錯誤訊息 SHALL 出現在表單上方且配色符合深色主題，MUST NOT 出現白底黑字

#### Scenario: 鍵盤彈出

- **WHEN** 使用者在小螢幕上點選密碼欄
- **THEN** 該欄位與主要動作 SHALL 仍在可視範圍內
