## Why

「食物點數」是這個 App 的核心獎懲機制，但**累計值在整個 App 裡沒有任何地方看得到**：吃掉一樣東西時 SnackBar 閃過「+3 點」，然後就消失了。統計頁有月趨勢，但那是分析，不是「我做得怎麼樣」。使用者沒有任何理由回來看自己的成果。

同時，「用戶」分頁是五個分頁裡最空的一個：頭像、Email、兩顆備份／還原按鈕、一個登出圖示。它佔了五分之一的導覽列，卻沒有被點開的理由。

帳號功能也有實質缺口：Email 註冊的使用者沒有顯示名稱（畫面上是一片空白）、忘記密碼就回不來、想刪帳號沒有入口（App Store 與 Play 都要求這個功能）。登入／註冊頁還是重製前的舊程式：白底 SnackBar（深色模式下刺眼）、按鈕沒套 token。那是使用者看到的第一個畫面。

本 change 要驗證的假設：把「點數」變成一個看得到、有進展感的東西，並把用戶分頁補成「成績 + 帳號」，使用者才有理由持續記錄。

## What Changes

### A. 食物點數的累計呈現（新）

- 新增 `FoodPointsSummary`（純 Dart，`now` 可注入）：累計總分、本週淨分、等級與下一級進度、距離上次浪費的天數、里程碑達成狀態。全部由既有的 `UsedFoodItem.affectFoodPoint` 推導，**不新增任何持久化欄位**。
- 五個等級（見習生 → 零浪費大師），門檻 0／50／150／350／700，名稱與說明走 l10n。
- 「連續天數」定義為**距離上次浪費紀錄的天數**（不是登入連續天數）：沒開 App 的日子不會被懲罰，語意也誠實——那幾天確實沒記錄到浪費。
- 六個一次性里程碑：第一筆紀錄、救回 10 項即期食物、累計 100 點、連續 7 天沒浪費、連續 30 天沒浪費、累計 500 點。

### B. 用戶分頁重製（新）

- 上半「我的成績」：等級卡（等級名稱 + 進度條 + 距離下一級還差多少）、三個數字（累計點數／本週淨分／距上次浪費天數）、里程碑格狀清單（未達成的以灰階呈現並寫出達成條件）。
- 下半「帳號」：頭像與名稱（可編輯）、Email、備份／還原、登出、刪除帳號。
- 空狀態：完全沒有紀錄時不顯示 0 分的成績卡，改成引導去記第一樣食物。

### C. 帳號功能（新）

- **修改顯示名稱**：Email 註冊的使用者可以自己設一個名字；更新後使用者串流要立刻反映（Firebase 的 `authStateChanges` 不會因為 profile 更新而觸發，所以 `AuthenticationRepository.user` 改為可手動推播）。
- **重設密碼**：在登入頁與用戶頁都能寄出重設信。
- **刪除帳號**：二次確認 + 明確說明會刪掉什麼；Firebase 要求近期登入，遇到 `requires-recent-login` 要回報「請重新登入後再試」而不是丟出例外。

### D. 登入／註冊頁重製（新）

- 套用 `AppTheme` token 與 `AppSnackBar`，移除白底 SnackBar 與硬編碼顏色。
- 版面：品牌圖示、標題、輸入欄、主要動作、Google 登入、次要動作（註冊／忘記密碼），錯誤訊息固定位置。
- 鍵盤彈出時欄位不被遮擋；zh／en 與明暗都可用。

### 範圍上限

用戶頁、登入頁、註冊頁三個畫面 + 一個純 Dart 的成績計算 + 三個帳號動作。不新增第三方套件、不改 Hive schema、不改食物與紀錄的既有行為。

### 非目標

- 不做訪客模式（使用者未選；仍維持強制登入）。
- 不做點數兌換、排行榜、社群比較。
- 不做頭像上傳（需要 `image_picker`，留待之後）。
- 不做自動雲端同步（那是 firestore-sync 的獨立 change）。

## Capabilities

### New Capabilities

- `user-profile`：用戶分頁的內容與結構（成績區、帳號區）、空狀態、修改顯示名稱與刪除帳號的流程。

### Modified Capabilities

- `food-points`：新增累計統計的定義（總分、本週淨分、等級、距上次浪費天數、里程碑）。既有的加權與每日上限規則不變。
- `authentication`：新增重設密碼、刪除帳號、更新顯示名稱；使用者資訊顯示的要求擴充；登入／註冊頁的呈現改用設計系統。

## Impact

- **Code**：`lib/models/food_points_summary.dart`（新）、`lib/cubits/food_points_cubit.dart`（新）、`lib/pages/user_page.dart`（重寫）、`lib/pages/user/`（新的子元件）、`lib/login/`、`lib/sign_up/`、`packages/authentication_repository`（新增三個方法與可推播的 user 串流）、`lib/l10n/*.arb`。
- **Tests**：`food_points_summary_test`（等級門檻、週界線、距上次浪費天數、里程碑）、`food_points_cubit_test`、用戶頁與登入頁的 widget test、`authentication_repository` 的新方法測試。
- **Dependencies**：不新增。
- **Risk**：`AuthenticationRepository.user` 從單純的 `authStateChanges()` 改為可手動推播的串流，寫錯會讓登入狀態路由失效 → 以既有的 `app_bloc` 測試與新的 repository 測試鎖定。
- **美術**：里程碑徽章需要 6 個圖示（見 `art-requests.md` 追加的 G 組），未完成前以 Material 圖示 + 灰階呈現。
