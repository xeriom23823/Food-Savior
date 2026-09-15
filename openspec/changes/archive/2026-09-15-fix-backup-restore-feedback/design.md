## Context

裝置 log（SM-T500，2026-09-15）：

```
W Firestore: Could not reach Cloud Firestore backend. Backend didn't respond within 10 seconds ... operate in offline mode
E flutter : Unhandled Exception: [cloud_firestore/unavailable] Failed to get document because the client is offline.
            #4 _UserPageState.backupData (user_page.dart:158)
```

同一台裝置 ping `firestore.googleapis.com` 正常、時間正確、Google 登入（Auth 走 HTTPS/1.1 REST）成功，只有 Firestore 的 gRPC／HTTP2 連線建立不起來。這是網路環境問題（常見於封鎖 HTTP2 或 IPv6 有問題的 Wi-Fi），App 端做不到的事不假裝能解，但 App 必須在有限時間內明確回報，且不能因此弄丟本機資料。

## Decisions

- **`BackupRepository` + `BackupFailure`**：Firestore 例外（`FirebaseException.code`）與 `TimeoutException` 在 Repository 邊界統一轉成四種原因，UI 只做 l10n 對應。timeout 15 秒（Firestore 自己的離線判定是 10 秒）。
- **還原先取後清**：拿到 `BackupSnapshot` 才派發 Load；null（沒有備份）與失敗都不碰本機。原規格「先清空再讀取」被改掉，因為那是資料遺失風險，不是需求。
- **`Source.server`**：還原不接受快取，避免離線時「成功還原」到一份舊資料。
- **Load 事件內含清空**：`FoodItemListLoad`／`UsedFoodItemListLoad` 先 `clearAll()` 再寫入。原本頁面先派發 `Clear` 再派發 `Load`，兩個非同步 handler 若交錯，`Clear` 的 `Loaded([])` 可能在 `Load` 之後 emit 而把剛還原的清單蓋掉。
- **按鈕互斥**：備份與還原進行中互相停用，避免同時寫入與整批取代。
- **fake_cloud_firestore 4.2.0**（dev）：Repository 測試不需真實 Firebase；`Source.server` 與 `FieldValue.serverTimestamp()` 在 fake 中皆可用。

## 網路診斷建議（給使用者）

1. 平板改用手機熱點再試備份：若成功，就是原 Wi-Fi 封鎖 gRPC／HTTP2 或 IPv6 有問題。
2. 若熱點也失敗，檢查 Firebase 專案的 Firestore Security Rules（拒絕會是 `permission-denied`，App 現在會明確顯示）與 App Check 是否被啟用強制。
3. 可用 `adb logcat --pid=$(adb shell pidof com.example.food_savior) | grep -E "Firestore|flutter"` 觀察。

## Risks

- 15 秒對慢速網路可能偏短；若實測常逾時可調 `BackupRepository.timeout`。
- `FoodItemListLoad` 語意變為「取代」：目前只有還原使用；未來 firestore-sync 會以新的同步機制取代整個備份流程。
