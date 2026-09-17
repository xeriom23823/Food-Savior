# Authentication Specification

## Purpose

定義帳號驗證與帳號管理：以 Firebase Auth 提供 Email／密碼登入、Google 登入、註冊、登出、重設密碼、更新顯示名稱與刪除帳號，以及登入狀態如何決定 App 顯示登入頁或主畫面。備份還原與未來的雲端同步都依賴登入使用者的 uid。

## Requirements

### Requirement: 登入狀態決定路由

App 啟動時 SHALL 等待 Firebase Auth 的第一個狀態後才顯示畫面。已登入時 SHALL 顯示主畫面（五分頁外殼）；未登入時 SHALL 顯示登入頁。登入狀態變化 SHALL 即時切換畫面。

#### Scenario: 已登入使用者重新開啟 App

- **WHEN** 上次登入的使用者重新開啟 App
- **THEN** 系統 SHALL 直接顯示主畫面，不要求再次登入

#### Scenario: 登出

- **WHEN** 使用者在使用者頁按下登出
- **THEN** 系統 SHALL 呼叫 Firebase 登出（含 Google 登出）並切換到登入頁

### Requirement: Email 與密碼登入

登入頁 SHALL 提供 Email 與密碼欄位，以 formz 即時驗證：Email 格式不正確顯示 `invalidEmail`，密碼不符合規則顯示 `invalidPassword`；欄位皆有效前登入按鈕 SHALL 不可按。登入失敗時 SHALL 顯示錯誤訊息（Firebase 錯誤對應的訊息，否則 `logInFailure`）。

#### Scenario: 帳密正確

- **WHEN** 使用者輸入有效且正確的 Email 與密碼並按登入
- **THEN** 系統 SHALL 進入主畫面

#### Scenario: 密碼錯誤

- **WHEN** 使用者輸入存在的 Email 但錯誤的密碼
- **THEN** 系統 SHALL 顯示對應錯誤訊息並停留在登入頁

### Requirement: Google 登入

登入頁 SHALL 提供 `signInWithGoogle`。在 Web 上 SHALL 使用彈出視窗流程；在行動平台 SHALL 使用原生 Google Sign-In 取得憑證後交給 Firebase。失敗時 SHALL 顯示對應錯誤訊息。

#### Scenario: Google 登入成功

- **WHEN** 使用者完成 Google 帳號選擇
- **THEN** 系統 SHALL 以該帳號登入並進入主畫面

### Requirement: 註冊

註冊頁 SHALL 要求 Email、密碼與確認密碼；兩次密碼不一致顯示 `passwordsDoNotMatch`。所有欄位有效才可送出；成功後 SHALL 自動成為登入狀態；失敗顯示對應訊息或 `signUpFailure`。

#### Scenario: 兩次密碼不一致

- **WHEN** 使用者輸入的確認密碼與密碼不同
- **THEN** 系統 SHALL 顯示 `passwordsDoNotMatch` 且送出按鈕不可按

#### Scenario: Email 已被使用

- **WHEN** 使用者以已註冊的 Email 註冊
- **THEN** 系統 SHALL 顯示帳號已存在的錯誤訊息

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
