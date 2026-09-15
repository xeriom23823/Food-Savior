## 1. 期限快速選項

- [x] 1.1 `lib/models/expiry_quick_pick.dart`：六個選項的定義（今天、明天、3 天、1 週、2 週、1 個月）與 `dateFrom(now)`，純 Dart
- [x] 1.2 `ExpiryField` 在 `exact` 模式顯示一排快速選項，單行可橫向捲動，不擠掉日期按鈕（design D2）
- [x] 1.3 選中狀態以日期相等判定（雙方都對齊當天零時，走 `ExpiryValue.exact`，design D3）
- [x] 1.4 `range`／`monthOnly`／`unknown` 三種精度不顯示快速選項
- [x] 1.5 單元測試 `test/models/expiry_quick_pick_test.dart`：六個選項各自的日期、跨月與跨年邊界、都對齊零時
- [x] 1.6 widget test `test/widgets/expiry_field_test.dart`：點「今天」後的值、選中狀態、值不符時無選中、切精度後不顯示、完整選擇器仍可用；明暗 × zh／en

## 2. 草稿列可完整編輯（補實作）

- [x] 2.1 `lib/pages/import/import_draft_sheet.dart`：一張 sheet 改完名稱、類型、數量、單位、期限、存放位置（design D4）
- [x] 2.2 期限用既有的 `ExpiryField`，位置用既有的 `LocationPicker`，不另寫元件
- [x] 2.3 草稿列點擊改為開啟這張 sheet；排除按鈕維持在列上
- [x] 2.4 確認後派發一次 `ImportDraftChanged`（既有事件，不新增）
- [x] 2.5 任一欄位被編輯即清除 `needsReview`
- [x] 2.6 已排除的列不開啟編輯入口
- [x] 2.7 widget test `test/pages/import_draft_sheet_test.dart`：六個欄位各自可改並反映到派發的草稿；明暗 × zh／en
- [x] 2.8 `test/pages/import_drafts_page_test.dart` 補：點擊列會開啟 sheet、已排除的列不會、編輯後 `needsReview` 消失

## 3. l10n

- [x] 3.1 `intl_zh.arb`／`intl_en.arb` 新增六個快速選項標籤與草稿編輯 sheet 的標題
- [x] 3.2 `dart run intl_utils:generate`，接著 `dart format lib/generated`
- [x] 3.3 `grep` 確認新程式無硬編碼中文或英文

## 4. 驗證

- [x] 4.1 `dart format .`
- [x] 4.2 `flutter analyze --no-pub`（0 error／0 warning）
- [x] 4.3 `flutter test` 全綠；特別確認既有的 `expiry_field`、`import_drafts_page`、`food_item_form_page` 測試沒被改壞
- [~] 4.4 實機（SM-T500，Android 12，zh-TW 亮色）。**已驗**：補期限 sheet 的六個選項都出現；預設值 `2026-09-22` 讓「1 週後」正確呈現選中；點「今天」→ 儲存後，該項目從「期限未知」移到「今天到期」分群並顯示「今日到期」，回饋 SnackBar 正常。用的是使用者實際掃進來的兩瓶飲料（三十三茶王、紅柚翡翠），正是回報的情境。**未驗**：草稿頁的編輯 sheet（需要再掃一張未匯入過的發票）、新增表單的快速選項、暗色與 en（後兩者由 widget test 覆蓋）
- [x] 4.5 `openspec validate --all --strict --no-interactive`

> 不需要 `flutter build apk --debug`：本 change 不動套件、原生權限或 Gradle。
