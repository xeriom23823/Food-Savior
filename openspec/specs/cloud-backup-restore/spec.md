# Cloud Backup Restore Specification

## Purpose

定義目前的雲端備份與還原：使用者手動將現存清單與使用紀錄整包上傳到 Firestore，或從 Firestore 整包覆蓋本機。這是未來 Hive ↔ Firestore 雙向同步（firestore-sync）的前身，屆時本規格會被 MODIFIED 或 REMOVED。

## Requirements

### Requirement: 手動備份到 Firestore

使用者頁 SHALL 提供「備份」動作。執行時系統 SHALL 將所有 `FoodItem` 與 `UsedFoodItem` 序列化為 JSON 字串陣列，寫入 Firestore 文件 `backups/{uid}` 的 `foodItems` 與 `usedFoodItems` 欄位，覆蓋既有備份。備份進行中 SHALL 顯示進度並禁止重複觸發；完成 SHALL 提示成功。

#### Scenario: 首次備份

- **WHEN** 已登入使用者按下備份
- **THEN** Firestore SHALL 出現 `backups/{uid}` 文件，內含目前所有食物與紀錄

#### Scenario: 再次備份

- **WHEN** 使用者已有備份且再次按下備份
- **THEN** 舊備份 SHALL 被新內容完全取代

### Requirement: 從 Firestore 還原

使用者頁 SHALL 提供「還原」動作。執行時系統 SHALL 先清空本機的現存清單與使用紀錄，再讀取 `backups/{uid}`：有資料時反序列化並載入；載入的現存清單 SHALL 重新推導狀態（過期者進入過期處理流程）；使用紀錄 SHALL 保留原 id、日期與點數。還原進行中 SHALL 顯示進度；失敗 SHALL 顯示錯誤並結束進度狀態。

#### Scenario: 還原成功

- **WHEN** 使用者按下還原且雲端有備份
- **THEN** 本機資料 SHALL 與備份一致，並提示成功

#### Scenario: 雲端沒有備份

- **WHEN** 使用者按下還原但 `backups/{uid}` 不存在
- **THEN** 本機資料 SHALL 已被清空且不載入任何項目

#### Scenario: 網路失敗

- **WHEN** 還原過程中 Firestore 讀取失敗
- **THEN** 系統 SHALL 顯示錯誤訊息並解除進度狀態

### Requirement: 備份 JSON 相容性

備份中的 JSON SHALL 至少包含 `FoodItem` 全部欄位與 `UsedFoodItem` 的 `usedDate`、`affectFoodPoint`；日期以 ISO 8601 字串儲存。還原 SHALL 能讀回自己寫出的格式；`affectFoodPoint` 缺失時視為 0。

#### Scenario: 缺少 affectFoodPoint

- **WHEN** 備份中某筆使用紀錄沒有 `affectFoodPoint`
- **THEN** 還原後該筆 `affectFoodPoint` SHALL 為 0

### Requirement: 需登入才可備份還原

備份與還原 SHALL 只在已登入狀態可用，且只讀寫目前使用者 uid 對應的文件。

#### Scenario: 不同使用者

- **WHEN** 使用者 A 備份後登出，使用者 B 登入並還原
- **THEN** B SHALL 只取得 `backups/{B 的 uid}` 的內容，不會取得 A 的資料
