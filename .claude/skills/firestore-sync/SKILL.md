---
name: firestore-sync
description: Food Savior 的 Hive ↔ Cloud Firestore 雙向同步設計指引：每使用者集合結構、updatedAt/tombstone 的 last-write-wins、離線優先與 outbox 佇列、Security Rules、從舊版整包備份遷移、fake_cloud_firestore 與 Emulator 測試、成本控管。開發雲端同步或改動備份還原時必讀。
---

# Hive ↔ Firestore 雙向同步

## 原則

1. **Hive 永遠是 UI 的資料來源**；Firestore 是多裝置間的交換與備援。UI 不直接讀 Firestore。
2. **離線優先**：所有寫入先落 Hive，再進 outbox 佇列非同步推送；沒網路時 App 行為與現在完全相同。
3. **同步邏輯只住在 Repository 層**（或其下的 `SyncEngine`），Bloc 不知道 Firestore 存在。
4. 一次只做一種衝突策略：**last-write-wins by `updatedAt`**，刪除用 tombstone。夠用且可解釋。

## Firestore 結構

```
users/{uid}
  ├─ foodItems/{id}          FoodItem.toJson() + updatedAt (server timestamp) + deletedAt (null | timestamp) + deviceId
  ├─ usedFoodItems/{id}      UsedFoodItem.toJson() + updatedAt + deletedAt + deviceId
  └─ meta/sync               lastPullAt、schemaVersion
backups/{uid}                （舊版整包備份，唯讀，僅供遷移；遷移完成後可刪）
```

- 用 `toJson()`（列舉存 `name`），不用 `toJsonString()`。
- 日期存 ISO 8601 字串（與現有 JSON 一致）或 `Timestamp`；二選一並寫進 spec，不要混用。
- `updatedAt` 一律 `FieldValue.serverTimestamp()`；本機比較時用伺服器回填值，尚未回填（pending write）視為最新。
- 每個裝置有 `deviceId`（uuid，存 SharedPreferences），用來忽略自己剛推上去又被 snapshot 推回來的變更。

## 本機結構

- `FoodItem`／`UsedFoodItem` 新增欄位：`updatedAt`（DateTime，預設 = 建立時間）、`deletedAt`（DateTime?）。Hive 相容：可 null／有預設值，只加索引不改舊索引。
- 新 Box `syncOutbox`（`Box<SyncOp>`）：`{id, collection, docId, op: upsert|delete, enqueuedAt}`；重複 docId 只保留最後一筆。
- 現有 Repository 的 `save/delete` 改為：寫 Hive → 記 outbox → 通知 `SyncEngine`；讀取一律過濾 `deletedAt != null`（tombstone 不顯示）。

## SyncEngine

```
start(uid)
  ├─ pushLoop：監聽 outbox，有網路時批次（≤ 500）寫 Firestore（WriteBatch），成功後移除 outbox 項目；失敗指數退避
  └─ pullLoop：collection.snapshots(includeMetadataChanges: false)
        for each change:
          if change.deviceId == myDeviceId → skip
          local = box.get(id)
          if local == null || remote.updatedAt > local.updatedAt → box.put(remote)   （含 tombstone）
stop() on logout；logout 時清 outbox 並保留 Hive（或依 spec 決定是否清本機）
purge：deletedAt 超過 30 天的 tombstone 本機與雲端都刪
```

- 啟用 Firestore 離線持久化（行動平台預設開；Web 需 `enablePersistence`）。
- 首次登入 / 新裝置：先 `get()` 全量拉取再開 listener；有 `backups/{uid}` 且 `foodItems` 空 → 詢問是否從舊備份匯入（一次性遷移，寫入時 `updatedAt = now`）。
- 帳號切換：uid 變更時 stop → 清 Hive Box（本機資料屬於帳號）→ start 新 uid。此行為要在 spec 明示。

## Security Rules（`firestore.rules`，隨 change 一起提交）

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    match /backups/{uid} {
      allow read: if request.auth != null && request.auth.uid == uid;
      allow write: if false;   // 舊備份改為唯讀
    }
  }
}
```

進階：對 `foodItems` 加欄位驗證（`request.resource.data.keys().hasAll([...])`、`quantity is int && quantity > 0`）。部署：`firebase deploy --only firestore:rules`（需 firebase CLI 與登入）。

## 成本與效能

- 免費額度約每日 5 萬讀／2 萬寫（以官方頁面為準）。一個使用者一天幾十筆變更遠低於此；主要風險是**全量重拉**與**listener 重連**。
- 不要在每次啟動都 `get()` 全集合；用 `where('updatedAt', isGreaterThan: lastPullAt)` 增量拉，`lastPullAt` 存 `meta/sync`。
- 使用紀錄只增不改（除了刪除），可考慢只同步最近 12 個月。

## 測試

- Repository／SyncEngine 單元測試：`fake_cloud_firestore` 的 `FakeFirebaseFirestore()` + Hive temp 目錄；案例：本機新增→推送、遠端新增→拉取、兩端同 id 不同 updatedAt→新者勝、tombstone 覆蓋本機、deviceId 相同→忽略、離線累積 outbox→上線後清空。
- 時間注入：`updatedAt` 比較用注入的 clock；fake Firestore 的 serverTimestamp 行為要在測試中固定。
- 整合：Firebase Emulator（`npm i -g firebase-tools`、`firebase emulators:start --only firestore,auth`；App 端 `FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080)` 在 Android 模擬器）。
- 實機：兩台裝置同帳號互改；飛航模式下操作再恢復；登出登入。

## UI 接點

- 使用者頁的「備份／還原」改為「同步狀態」：上次同步時間、待推送筆數、手動「立即同步」；舊備份存在時顯示「匯入舊備份」。
- 新 l10n key：`syncStatus*`、`importLegacyBackup*`。
- 需要 spec：`cloud-sync`（新）、`cloud-backup-restore` MODIFIED 或 REMOVED、`local-persistence` MODIFIED（新增欄位與 Box）、`authentication` MODIFIED（登出／切換帳號對本機資料的影響）。

## Firebase MCP（可選）

需要直接查看／修改 Firestore 資料或規則時，安裝 firebase CLI 並登入後，在 `.mcp.json` 加：

```json
"firebase": { "command": "npx", "args": ["-y", "firebase-tools@latest", "mcp"] }
```
