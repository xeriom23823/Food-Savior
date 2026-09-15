# Authentication Specification

## Purpose

定義帳號驗證：以 Firebase Auth 提供 Email／密碼登入、Google 登入、註冊、登出，以及登入狀態如何決定 App 顯示登入頁或主畫面。備份還原與未來的雲端同步都依賴登入使用者的 uid。

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

使用者頁 SHALL 顯示目前使用者的頭像（無圖片時顯示預設圖示）、Email 與顯示名稱。

#### Scenario: Google 帳號有頭像

- **WHEN** 使用者以有頭像的 Google 帳號登入
- **THEN** 使用者頁 SHALL 顯示該頭像、Email 與名稱
