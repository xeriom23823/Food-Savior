## 0. 決策與安全網

- [x] 0.1 seed 色由使用者直接決定為沉穩綠 `#3E8E5A`（免截圖選色）；實作 1.1 後仍需截明暗各一張圖供微調
- [x] 0.2 使用者確認 Q2（改 NavigationBar）；Q3 採 FAB（未表態，實作後截圖確認）；design.md 已更新
- [x] 0.3 為 `FoodItemListBloc`、`UsedFoodItemListBloc` 補 bloc_test（新增／更新／移除／過期處理／點數上限），作為重構安全網（已在 change `fix-inventory-and-points-consistency` 完成，含 Repository 與 model 測試）

## 1. Theme 與 token

- [ ] 1.1 新增 `lib/theme/app_theme.dart`：以 seed 產生明暗 `ColorScheme`、`TextTheme`（NotoSansTC、tabular figures）、元件主題（AppBar、Card、Button、Input、ListTile、SnackBar、NavigationBar）
- [ ] 1.2 新增 `FoodStatusColors` `ThemeExtension`（明暗各一組）與 `context.foodStatusColors` extension
- [ ] 1.3 新增 `AppSpacing`、`AppRadius`、`AppDurations` 常數
- [ ] 1.4 `ThemeCubit` 改為只持有 `ThemeMode`（含 SharedPreferences 持久化），`AppView` 以 `theme`／`darkTheme`／`themeMode` 組裝；更新 `theme_cubit_test.dart`
- [ ] 1.5 `FoodItemStatusExtension.color` 改為依 `BuildContext` 取 `FoodStatusColors`；`FoodItemTypeExtension.color` 改用 `ColorScheme` 衍生或語意色

## 2. 元件庫

- [ ] 2.1 `AppScaffold`、`SectionHeader`、`EmptyState`
- [ ] 2.2 `StatusChip`、`QuantityWithUnit`、`ExpiryCountdown`（`now` 可注入）
- [ ] 2.3 `FoodItemTile`（含滑動動作插槽）
- [ ] 2.4 `AppSnackBar`（success／warning／error，可選 Lottie，尊重 disableAnimations）
- [ ] 2.5 `ConfirmSheet`、`DatePickerField`
- [ ] 2.6 每個元件 widget test：明暗各一、zh／en 長字串不溢出

## 3. 頁面重製（由小到大）

- [ ] 3.1 設定頁：分區、`ListTile` 主題化、移除硬編碼字串（新增 l10n key）
- [ ] 3.2 使用者頁：頭像／資訊區、備份／還原改為有狀態的按鈕列 + `AppSnackBar`，字串進 l10n
- [ ] 3.3 統計頁：圖表容器卡、`EmptyState` 取代「尚無資料」、圖表色改用 token
- [ ] 3.4 紀錄頁：週日期列元件化、`FoodItemTile` 重用、刪除改 `ConfirmSheet`、三態
- [ ] 3.5 食物頁拆分為 `lib/pages/food_item_list/`：清單頁（三態、FAB）、`FoodItemFormPage`（新增／編輯）、`ConsumeSheet`（部分使用）、過期處理頁
- [ ] 3.6 新增 `FoodItemListConsume`／`FoodItemListWaste` event，將頁面內建立 `UsedFoodItem`、剩餘數量計算下沉到 Bloc；bloc_test 覆蓋
- [ ] 3.7 底部導覽改為 `NavigationBar`（依 Q2），移除 `curved_labeled_navigation_bar`

## 4. 清理

- [ ] 4.1 `grep` 確認 `lib/pages`、`lib/widgets` 無 `Colors.`、`Color(0x`、`fontSize:`、硬編碼中文
- [ ] 4.2 更新 `intl_zh.arb`／`intl_en.arb` 並重新產生；刪除不再使用的 key
- [ ] 4.3 更新 README 截圖與功能清單

## 5. 驗證

- [ ] 5.1 `dart format`、`flutter analyze --no-pub`（0 error／0 warning）
- [ ] 5.2 `flutter test` 全綠（Bloc、元件、頁面 widget test）
- [ ] 5.3 `flutter build apk --debug` 與 `flutter build ios --no-codesign`（macOS 可用時）
- [ ] 5.4 Dart MCP 實機：五分頁 × 明暗 × zh／en 截圖，檢查三態、觸控大小、對比、鍵盤遮擋
- [ ] 5.5 `openspec validate --all --strict --no-interactive`；更新受影響主規格（`/opsx:sync` 或 archive）
