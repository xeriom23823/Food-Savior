## MODIFIED Requirements

### Requirement: 語言切換

設定頁 SHALL 提供語言選擇（`language`），選項為 English（en_US）與中文（zh_TW）。切換 SHALL 立即套用到整個 App，包括列舉名稱與導覽列標題，並 SHALL 持久化選擇（SharedPreferences key `localeLanguageCode`，只儲存語言碼）。App 重新啟動時 SHALL 還原上次選擇並對應回支援清單中的完整 Locale；首次啟動預設 zh_TW。不在支援清單中的語系 SHALL 被忽略且不寫入。

#### Scenario: 切換到英文

- **WHEN** 使用者選擇 English
- **THEN** 所有經 l10n 的文字 SHALL 立即以英文顯示

#### Scenario: 重啟後保留語言

- **WHEN** 使用者選擇 English 後關閉並重新開啟 App
- **THEN** App SHALL 以 en_US 啟動，設定頁的語言選項顯示 English

#### Scenario: 首次啟動

- **WHEN** 使用者首次安裝並開啟 App
- **THEN** App SHALL 以 zh_TW 顯示

#### Scenario: 不支援的語系

- **WHEN** 程式嘗試設定 `fr` 語系
- **THEN** 目前語系 SHALL 不變，且不寫入任何持久化值
