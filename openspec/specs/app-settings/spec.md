# App Settings Specification

## Purpose

定義「設定」分頁的行為：語言切換（zh-TW／en）、深色模式及其持久化、通知開關（目前為預留項目，將由過期提醒功能取代）以及關於區塊的版本與開源連結。設定變更必須立即反映在整個 App，且需持久化的項目在重新啟動後保持一致。

## Requirements

### Requirement: 語言切換

設定頁 SHALL 提供語言選擇（`language`），選項為 English（en_US）與中文（zh_TW）。切換 SHALL 立即套用到整個 App，包括列舉名稱與導覽列標題。不在支援清單中的語系 SHALL 被忽略。

#### Scenario: 切換到英文

- **WHEN** 使用者選擇 English
- **THEN** 所有經 l10n 的文字 SHALL 立即以英文顯示

### Requirement: 深色模式持久化

設定頁 SHALL 提供深色模式開關（`darkMode`）。切換 SHALL 立即套用主題，並將選擇持久化（SharedPreferences key `isDark`）；App 重新啟動時 SHALL 還原上次選擇，預設為淺色。

#### Scenario: 開啟深色模式後重啟

- **WHEN** 使用者開啟深色模式後關閉並重新開啟 App
- **THEN** App SHALL 以深色主題啟動

#### Scenario: 首次啟動

- **WHEN** 使用者首次安裝並開啟 App
- **THEN** App SHALL 使用淺色主題

### Requirement: 通知開關為預留項目

設定頁 SHALL 顯示 `showNotification` 開關，但目前 SHALL 不啟用任何通知功能，開關狀態固定為關閉。此需求將由過期提醒功能的 change 取代。

#### Scenario: 切換通知開關

- **WHEN** 使用者切換通知開關
- **THEN** 系統 SHALL 不排程任何通知，開關維持關閉

### Requirement: 關於區塊

設定頁 SHALL 顯示 App 版本與開源專案連結項目。

#### Scenario: 查看版本

- **WHEN** 使用者進入設定頁
- **THEN** 關於區塊 SHALL 顯示版本字串
