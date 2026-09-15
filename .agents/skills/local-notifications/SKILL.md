---
name: local-notifications
description: Food Savior 的過期提醒（本機通知）實作指引：flutter_local_notifications + timezone 設定、Android 13+/14 權限與 exact alarm 政策、iOS 授權、每日摘要排程策略、可測試的排程器設計、設定頁整合。開發「過期提醒」相關 change 時必讀。
---

# 過期提醒（本機通知）

## 目標與非目標

- 目標：即將到期（3 天內）或已過期的食物，在使用者選定時間以本機通知提醒；不依賴後端。
- 非目標（第一版）：推播（FCM）、每項食物各一則通知、背景自動更新資料。

## 套件

| 套件 | 用途 | 備註 |
|---|---|---|
| `flutter_local_notifications` | 排程與顯示 | 在 design.md 記錄實際採用版本；Android 需 core library desugaring |
| `timezone` + `flutter_timezone` | 以裝置時區排程 `zonedSchedule` | 啟動時 `tz.initializeTimeZones()` 並 `setLocalLocation` |
| `permission_handler`（可選） | 統一權限請求 UI | 若只需通知權限，用 plugin 自帶的 `requestNotificationsPermission` 即可 |

不建議第一版就加 `workmanager`／`android_alarm_manager_plus`：排程在 App 開啟時重算即可滿足需求，且能避開 OEM 背景限制。

## 平台設定

### Android
- `android/app/build.gradle`：`compileOptions { isCoreLibraryDesugaringEnabled = true }`、`dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.x") }`；`minSdk ≥ 21`（專案已是）。
- `AndroidManifest.xml`：
  - `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>`（API 33+ 執行期請求）
  - `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>` + plugin 的 `ScheduledNotificationBootReceiver`，重開機後保留排程
  - **不要**申請 `SCHEDULE_EXACT_ALARM`／`USE_EXACT_ALARM`：Android 14 起前者預設不授權、後者只允許鬧鐘／日曆類 App。提醒用 `AndroidScheduleMode.inexactAllowWhileIdle`，誤差數分鐘可接受。
- 通知頻道：id `expiration_reminders`、importance high、name／description 走 l10n。
- 小圖示：`@drawable/ic_notification`（單色、透明背景），不要用彩色 launcher icon。

### iOS
- `AppDelegate.swift`：`UNUserNotificationCenter.current().delegate = self`（plugin README 範例）。
- 首次啟用時 `requestPermissions(alert: true, badge: true, sound: true)`；被拒後導向系統設定（`openAppSettings`）。
- 待排程通知上限 64 則 → 只能排「每日摘要」而非每項一則。

## 排程策略（寫進 spec）

1. 一天一則「每日摘要」，時間可設（預設 09:00，當地時間）。內容：`N 項今天到期、M 項 3 天內到期、K 項已過期`（l10n 帶參數）。沒有任何項目符合時**不排**。
2. 通知 id 固定（例如 `1001`），每次重算先 `cancel(1001)` 再排；最多預排未來 7 天（每天 id 1001 + 偏移）。
3. 重算時機：App 進前景、現存清單有任何變更（Bloc 監聽）、設定變更（開關／時間）、權限授予。
4. 點通知開 App 到食物分頁（payload `"tab:food"`）。
5. 設定持久化：`notificationsEnabled`（bool）、`notificationHour`／`notificationMinute`（int），透過新的 `SettingsRepository`（SharedPreferences）而非直接在 Cubit 讀寫。

## 可測試的架構

```
ExpirationReminderScheduler（純 Dart）
  List<ReminderPlan> plan({required List<FoodItem> items, required DateTime now, required TimeOfDay at, int days = 7})
    → 只做日期計算，回傳「哪幾天幾點、內容摘要數字」；100% 單元測試

NotificationService（介面）
  requestPermission() / schedule(ReminderPlan) / cancelAll() / pendingIds()
  ├─ FlutterLocalNotificationsService（實作，包 plugin）
  └─ FakeNotificationService（測試）

ReminderCubit / 或在 SettingsCubit 中
  監聯 FoodItemListBloc 狀態 + 設定 → 呼叫 scheduler.plan → service.schedule
```

規則：plugin 只在 `FlutterLocalNotificationsService` 內出現；Bloc／Cubit 不 import plugin。

## 測試

- `ExpirationReminderScheduler`：邊界 —— 到期日 = 今天、= 今天 + 3 天、已過期、跨午夜、空清單不排；固定 `now`。
- Cubit：`FakeNotificationService` 記錄呼叫，驗證開關關閉時 `cancelAll`、開啟時 `schedule`。
- 實機（必做，L5）：Android 13+ 首次開啟要看到權限對話框；把系統時間調到排程前 1 分鐘等通知；重開機後通知仍在（`pendingNotificationRequests`）。
- 常見失敗：Doze／OEM 省電殺掉排程（小米、華為）→ 在設定頁加「若收不到通知」說明連結；模擬器時間跳躍不觸發 inexact alarm，要用真機或縮短測試時間。

## 與現有程式的接點

- `settings_page.dart` 已有 `showNotification` 開關（目前 no-op），改為綁 `ReminderCubit`；新增時間選擇列。
- `FoodItemListBloc` 每次 `Loaded` 都是重算來源；不要在 Bloc 內直接呼叫通知 service，改由 Cubit 監聽（`BlocListener` 或 `bloc.stream.listen`）。
- 需要 spec：`expiration-reminders`（新能力）+ `app-settings` MODIFIED（通知開關不再是預留）。
