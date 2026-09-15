## Why

2026-09-15 實機測試：按下備份／還原後進度指示一直轉。裝置 log 顯示 Firestore 在 10 秒內連不上後端而進入離線模式，接著備份程式碼拋出 `[cloud_firestore/unavailable]`，但備份流程沒有任何錯誤處理，`_isBackingUp` 永遠不會歸零；還原流程更危險：在向雲端讀取之前就先清空本機資料，讀取失敗時使用者的資料已經沒了。Firestore 直接寫在頁面裡也違反「只有 Repository 能觸碰 Firebase」的架構規則，無法測試。

## What Changes

- 新增 `BackupRepository`：唯一觸碰 `backups/{uid}` 的層，每個操作 15 秒 timeout，所有失敗轉成 `BackupFailure`（offline／timeout／permissionDenied／unknown）。
- 備份：成功／失敗都會結束進度狀態並顯示對應訊息；備份文件多記 `updatedAt`。
- 還原：**先向伺服器讀取，成功取得資料後才覆蓋本機**；沒有備份或失敗時本機資料不動並顯示訊息。還原一律讀伺服器（`Source.server`），離線時失敗而不是還原到過期快取。
- 「整批取代」搬進 Bloc：`FoodItemListLoad`／`UsedFoodItemListLoad` 先清空 Box 再寫入，頁面不再另外派發 `Clear`（避免兩個事件競態）。
- 使用者頁的備份／還原按鈕在任一操作進行中都停用；所有字串改為 l10n（`backup`、`restore`、`backupSuccess`、`backupFailure`、`restoreSuccess`、`restoreFailure`、`restoreNoBackup`、`errorOffline`、`errorTimeout`、`errorPermissionDenied`、`errorUnknown`）。
- 新增 dev 相依 `fake_cloud_firestore` 供 Repository 測試。

### 範圈上限

使用者頁、兩個 Bloc 的 Load handler、一個新 Repository、l10n；不改 Firestore 結構（仍是 `backups/{uid}` 整包 JSON 字串）。

### 非目標

- 修好裝置連不上 Firestore 的網路問題（App 端無法解決；見 design.md 的診斷建議）。
- 雙向同步（firestore-sync）。

## Capabilities

### New Capabilities

無。

### Modified Capabilities

- `cloud-backup-restore`：備份失敗回饋、還原先取後清、沒有備份時保留本機、逾時。
- `localization`：無需求變更，但本 change 消除使用者頁的硬編碼字串。

## Impact

- **Code**：`lib/repositories/backup_repository.dart`（新）、`lib/pages/user_page.dart`（重寫）、`lib/main.dart`（提供 Repository）、兩個 Bloc 的 Load handler、ARB 與產生物。
- **Tests**：`test/repositories/backup_repository_test.dart`（fake_cloud_firestore）、兩個 Bloc 測試新增「整批取代」案例。
- **Risk**：`FoodItemListLoad` 現在會清空 Box，只有還原流程使用它；其他呼叫端不存在（已 grep）。
