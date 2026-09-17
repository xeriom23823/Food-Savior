## ADDED Requirements

### Requirement: 回饋設定

設定頁 SHALL 提供「回饋」區（`feedbackSection`），含兩個開關：音效（`soundEffects`，SharedPreferences key `soundEffectsEnabled`）與觸覺回饋（`hapticFeedback`，SharedPreferences key `hapticFeedbackEnabled`）。兩者預設 SHALL 為開啟；切換 SHALL 立即生效並持久化，App 重新啟動後 SHALL 還原上次選擇。關閉音效 MUST NOT 影響觸覺與視覺回饋；關閉觸覺 MUST NOT 影響音效與視覺回饋。

#### Scenario: 首次啟動

- **WHEN** 使用者首次安裝並開啟 App
- **THEN** 音效與觸覺回饋 SHALL 皆為開啟

#### Scenario: 關閉音效後重啟

- **WHEN** 使用者關閉音效後關閉並重新開啟 App
- **THEN** 設定頁的音效開關 SHALL 顯示為關閉，且食物頁操作不播放音效

#### Scenario: 只關閉觸覺

- **WHEN** 使用者關閉觸覺回饋但保留音效
- **THEN** 食物頁操作 SHALL 仍播放音效與視覺回饋，但不觸發觸覺
