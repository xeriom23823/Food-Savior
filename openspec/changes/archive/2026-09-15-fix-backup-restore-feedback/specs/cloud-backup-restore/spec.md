## MODIFIED Requirements

### Requirement: 手動備份到 Firestore

使用者頁 SHALL 提供 `backup` 動作。執行時系統 SHALL 將所有 `FoodItem` 與 `UsedFoodItem` 序列化為 JSON 字串陣列，寫入 Firestore 文件 `backups/{uid}` 的 `foodItems` 與 `usedFoodItems` 欄位並記錄 `updatedAt`，覆蓋既有備份。備份進行中 SHALL 顯示進度並停用備份與還原按鈕；完成 SHALL 提示 `backupSuccess`。寫入 MUST 在 15 秒內完成，否則視為失敗。任何失敗 SHALL 結束進度狀態並顯示 `backupFailure` 與原因（`errorOffline`、`errorTimeout`、`errorPermissionDenied` 或錯誤訊息）。

#### Scenario: 首次備份

- **WHEN** 已登入使用者按下備份
- **THEN** Firestore SHALL 出現 `backups/{uid}` 文件，內含目前所有食物與紀錄，並提示 `backupSuccess`

#### Scenario: 再次備份

- **WHEN** 使用者已有備份且再次按下備份
- **THEN** 舊備份 SHALL 被新內容完全取代

#### Scenario: 連不上雲端

- **WHEN** 裝置無法連線到 Firestore 後端
- **THEN** 系統 SHALL 在 15 秒內結束進度狀態並顯示 `backupFailure` 與 `errorOffline`（或 `errorTimeout`），按鈕恢復可用

### Requirement: 從 Firestore 還原

使用者頁 SHALL 提供 `restore` 動作。執行時系統 SHALL 先向伺服器（不使用快取）讀取 `backups/{uid}`，讀取 MUST 在 15 秒內完成。只有在成功取得備份內容後，系統才 SHALL 以備份內容整批取代本機的現存清單與使用紀錄；載入的現存清單 SHALL 重新推導狀態（過期者進入過期處理流程）；使用紀錄 SHALL 保留原 id、日期與點數。沒有備份時 SHALL 顯示 `restoreNoBackup` 且本機資料不變；讀取失敗時 SHALL 顯示 `restoreFailure` 與原因且本機資料不變。進行中 SHALL 顯示進度並停用兩個按鈕；結束後 SHALL 恢復。

#### Scenario: 還原成功

- **WHEN** 使用者按下還原且雲端有備份
- **THEN** 本機資料 SHALL 與備份一致，並提示 `restoreSuccess`

#### Scenario: 雲端沒有備份

- **WHEN** 使用者按下還原但 `backups/{uid}` 不存在
- **THEN** 系統 SHALL 顯示 `restoreNoBackup`，本機的食物與紀錄 SHALL 完全不變

#### Scenario: 網路失敗

- **WHEN** 還原過程中無法連線到 Firestore 後端
- **THEN** 系統 SHALL 在 15 秒內顯示 `restoreFailure` 與 `errorOffline`（或 `errorTimeout`）、解除進度狀態，且本機資料 SHALL 完全不變

#### Scenario: 整批取代

- **WHEN** 本機有備份中沒有的食物，使用者成功還原
- **THEN** 那些食物 SHALL 從本機消失，本機內容只剩備份中的項目
