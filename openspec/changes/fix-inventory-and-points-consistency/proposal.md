## Why

在為既有功能建立 baseline specs 與 bloc_test 安全網時，發現四個資料層 bug 讓實作與規格不一致，且會造成使用者可見的資料錯亂：過期食物處理完成後下次啟動又跳出、批次寫入的紀錄不套用點數上限、還原後的食物互相覆蓋、`FoodItem` 的相等性契約被破壞。這些都在 UI 重製之前修正，否則重製時的重構會把 bug 一起搬進新程式碼；同時這是驗證「規格 → 測試 → 修正」流程的第一個 change。

## What Changes

- **過期處理完成後刪除已處理項目**：`FoodItemListProcessComplete` 將 `tempFoodItems` 從 Hive Box 移除，再載入未過期清單。
- **批次寫入紀錄套用點數規則**：新增 `UsedFoodItemListAddAll` event，逐筆套用每日上限；過期處理頁改用它。`UsedFoodItemListLoad` 保留給還原流程（不重算點數）。
- **`FoodItem.copyWith` 不再把 id 預設為空字串**：`id` 參數預設 `null`，未提供時保留原 id。
- **`FoodItem` / `UsedFoodItem` 改為值相等**：`==` 與 `hashCode` 比較全部欄位且彼此一致，`UsedFoodItem` 與 `FoodItem` 不互相相等。
- **`toJson()` / `fromJson()` 實際可用**：`FoodItemType`／`FoodItemStatus`／`Unit` 的擴充方法 `name(BuildContext)` 遮蔽了 Dart 內建的 `Enum.name`，使 `toJson()` 把函式寫進 JSON、`fromJson()` 必定失敗（備份走 `toJsonString` 才沒被發現）。擴充方法改名 `localizedName`，所有呼叫端同步更新。這是 firestore-sync 的前置條件。
- **Repository 寫入一律 `await`**：`put`／`delete`／`clear` 未等待完成就回傳，清空後立刻讀取仍有資料（違反 local-persistence 規格）。
- **清單載入後依到期日排序**：`LoadFoodItemListFromDevice` 與處理完成後的清單不再是 Hive 插入順序，而是 food-inventory 規格要求的到期日順序。
- **升級 Flutter 3.47 的相容性修正**（同一批提交，否則 App 無法編譯）：`material_design_icons_flutter` 因繼承已變成 `final` 的 `IconData` 而無法再使用且已停止維護，改用既有相依 `font_awesome_flutter` 11 的對應圖示（carrot、appleWhole、drumstickBite、egg、fish、jar、bowlFood、mugSaucer、cookieBite、breadSlice、utensils；浪費動作 trashCan）；Google 登入圖示改為 `FaIcon`。**圖示外觀因此略有不同**，待 design-system-redesign 一併重新審視。
- **Android 工具鏈對齊 Flutter 3.47 範本**：Flutter 3.47 的 Gradle 插件拒絕 Gradle < 8.14，且本機 Android Studio 附帶的 JDK 25 需要 Gradle ≥ 9.1。依 Flutter 範本升到 Gradle 9.3.1／AGP 9.1.0／Kotlin 2.4.0，並更新 google-services 插件；`android/gradle.properties` 保留 Flutter migrator 自動加入的 `android.newDsl=false` 與 `android.builtInKotlin=false`（維持舊 DSL 與外掛 Kotlin，AGP 9 下才能套用 Flutter Gradle 插件）。
- **相依套件全面升級**（使用者要求）：Firebase 4／6 系列、google_sign_in 7（需遷移 `authentication_repository` 的登入流程：`initialize` + `authenticate` + 僅 ID token）、flutter_lints 6、hive_ce 2.20 等；移除未使用的 `intl_translation` 與誤放在 dependencies 的 `test`；以 `dependency_overrides` 暫時把 `objective_c` 釘在 9.6.0（9.6.1 的 build hook 與已發布的 `code_assets` 不相容）。**Google 登入流程換了底層 SDK，必須實機驗證。**
- 順帶：`DropdownButtonFormField.value` → `initialValue`（消除 4 個 deprecation info）；新增 `test/app_compiles_test.dart` 讓套件層級的編譯錯誤在 `flutter test` 就被抓到。
- **行為不變的部分**：點數 ±1 與每日上限 10 的規則本身不變；還原保留備份點數不變；UI 版面不變。

### 範圖上限

只動 `lib/models/food_item.dart`、兩個 Bloc、`food_item_list_page.dart` 中一行 event 派發；不新增套件、不改 Hive schema、不改 l10n。

### 非目標

- `LocaleCubit` 持久化、月趨勢圖跨年（另開 change，涉及行為決策）。
- 兩套 JSON 格式整併（留給 firestore-sync）。
- 頁面邏輯下沉（留給 design-system-redesign D8）。

## Capabilities

### New Capabilities

無。

### Modified Capabilities

- `expired-food-processing`：處理完成後已處理項目必須離開本機儲存（補明確 Scenario）。
- `food-points`：批次寫入路徑逐筆套用上限；還原保留點數（補 Scenario）。
- `food-inventory`：新增「FoodItem 以欄位值判定相等」與「copyWith 保留 id」需求。

## Impact

- **Code**：`lib/models/food_item.dart`（copyWith、==、hashCode）、`lib/bloc/food_item_list/food_item_list_bloc.dart`（ProcessComplete）、`lib/bloc/used_food_item_list/*`（AddAll event + 共用點數計算）、`lib/pages/food_item_list_page.dart`（改派發 AddAll、initialValue）。
- **Tests**：`test/bloc/food_item_list_bloc_test.dart`、`test/bloc/used_food_item_list_bloc_test.dart`、`test/models/food_item_test.dart`、`test/repositories/*` 作為安全網，其中 4 個案例在修正前失敗。
- **Risk**：值相等會讓 Equatable 狀態比較更嚴格，可能讓原本「內容相同」的重複 emit 被去重；現有 handler 都在中間 emit `Loading`，不受影響。
