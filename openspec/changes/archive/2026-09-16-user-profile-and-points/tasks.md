## 1. 成績計算（純 Dart）

- [x] 1.1 `lib/models/food_points_summary.dart`：`FoodPointsSummary.from(items, now:)`，含總分、本週淨分、等級與進度、距上次浪費天數、里程碑
- [x] 1.2 `PointsLevel` 與 `PointsMilestone` 列舉與門檻常數（集中一處，方便調整）
- [x] 1.3 單元測試：等級門檻邊界、本週的週一界線、距上次浪費天數（含沒有浪費、完全沒紀錄）、六個里程碑各自的達成與未達成

## 2. 帳號功能

- [x] 2.1 `AuthenticationRepository.user` 改為可手動推播（合流 `authStateChanges` 與內部控制器）
- [x] 2.2 `updateDisplayName`、`sendPasswordResetEmail`、`deleteAccount` 三個方法與各自的 Failure 型別（含 `requires-recent-login`）
- [x] 2.3 repository 測試：改名後串流會再發射、刪帳號的近期登入失敗、重設信的錯誤碼對應

## 3. 用戶頁

- [x] 3.1 `FoodPointsCubit`（讀 `UsedFoodItemRepository`，`now` 可注入）與測試
- [x] 3.2 `lib/pages/user/` 子元件：`LevelCard`、`PointsStatRow`、`MilestoneGrid`、`AccountSection`
- [x] 3.3 用戶頁重製：成績區 + 帳號區；沒有紀錄時成績區換成 EmptyState
- [x] 3.4 改名 sheet、刪除帳號的二次確認（寫清楚不會刪本機食物資料）
- [x] 3.5 用戶頁 widget test：有／無紀錄、等級進度、里程碑灰階、明暗與 zh／en

## 4. 登入／註冊頁

- [x] 4.1 登入頁重製：token 化、錯誤訊息固定區塊、忘記密碼入口
- [x] 4.2 註冊頁重製：同上，並在成功後回到登入狀態流程
- [x] 4.3 移除白底 SnackBar 與硬編碼顏色；`grep` 確認 `lib/login`、`lib/sign_up` 無 `Colors.`／`fontSize:`
- [x] 4.4 widget test：錯誤訊息呈現、忘記密碼、明暗與 zh／en

## 5. l10n

- [x] 5.1 新增等級名稱、里程碑名稱與條件、帳號動作、登入頁文案的 key（zh／en）
- [x] 5.2 `dart run intl_utils:generate`

## 6. 驗證

- [x] 6.1 `dart format`、`flutter analyze --no-pub`（0 error／0 warning／0 info）
- [x] 6.2 `flutter test` 全綠
- [x] 6.3 `flutter build apk --debug`
- [x] 6.4 實機（SM-T500）：用戶頁成績區（等級卡、進度條、三個數字、六個里程碑含灰階未達成）、帳號區五個動作、改名 sheet。**未實機驗**：重設密碼（會真的寄信）、刪除帳號（會真的刪帳號）、登入／註冊頁（需要先登出）
- [x] 6.5 `openspec validate --all --strict --no-interactive`

## 7. 美術（交由 Codex）

- [x] 7.1 在 `art-requests.md` 追加 G 組：6 個里程碑徽章（達成／未達成兩態）
