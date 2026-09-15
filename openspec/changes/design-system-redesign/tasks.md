## 0. 決策與安全網

- [x] 0.1 seed 色由使用者直接決定為沉穩綠 `#3E8E5A`（免截圖選色）；實作 1.1 後仍需截明暗各一張圖供微調
- [x] 0.2 使用者確認 Q2（改 NavigationBar）；Q3 採 FAB（未表態，實作後截圖確認）；design.md 已更新
- [x] 0.3 為 `FoodItemListBloc`、`UsedFoodItemListBloc` 補 bloc_test（新增／更新／移除／過期處理／點數上限），作為重構安全網（已在 change `fix-inventory-and-points-consistency` 完成，含 Repository 與 model 測試）

## M1. 資料模型與遷移（App 外觀不變）

- [x] M1.1 新增 `lib/models/expiry.dart`：`ExpiryPrecision` 列舉、`effectiveExpiry({item, now})` 純函式、四種精度的建構輔助（`ExpiryValue.exact/range/month/unknown`）；單元測試涵蓋四精度 × 開封 × 邊界日
- [x] M1.2 `FoodItem` 重構欄位：`expiryEarliest`、`expiryLatest`、`expiryPrecision`、`openedDate`、`shelfLifeAfterOpenDays`、`amount`、`remainingFraction`、`storageLocationId`、`priceTotal`；移除 `quantity`、`expirationDate`、`status`（狀態改為推導）
- [x] M1.3 `Unit` 新增 `pack`、`box`、`bottle`、`bag`、`can`、`serving`；`FoodItemStatus` 新增 `unknownExpiry`；新增 `RemainingFraction`、`WasteReason`、`DisposalMethod`、`LocationKind` 列舉
- [x] M1.4 `UsedFoodItem` 擴充：`wasteReason`、`disposalMethod`、`priceTotal`；`status` 由 `disposalMethod` 推導
- [x] M1.5 新增 `lib/models/storage_location.dart` 與 `StorageLocationRepository`（Box `storageLocation`）、首次啟動種子（冷藏／冷凍／常溫，名稱存字串）
- [x] M1.6 重建 `hive_adapters.dart`（含全部新型別）與 `hive_adapters.g.yaml`，跑 `build_runner` 並提交產生物
- [x] M1.7 Box 改名為 `foodItems`／`usedFoodItems`／`storageLocations`；舊 Box 永不開啟，不寫遷移程式碼（D22）
- [x] M1.9 `FoodPointCalculator`（純 Dart，`now` 注入）實作 D19 加權表與「當日正分總和」上限；替換所有寫入路徑的 ±1 邏輯；bloc_test 覆蓋滑動／部分處理／過期處理／還原四條路徑
- [x] M1.10 `FoodPresetRepository` 與 `assets/food_presets.json`（名稱關鍵字 → 類型 + 依 `LocationKind` 的天數 + 開封後天數）；比對規則（正規化、最長命中）單元測試
- [x] M1.11 `FoodTemplateService`：由 `FoodItem` + `UsedFoodItem` 歷史推導常用模板（出現次數 desc、最近使用 desc），歷史為空時退回 preset 表
- [x] M1.12 `FoodItemListBloc` 新增分群（急迫度／位置／類型）與同名批次合併（`FoodItemGroup`）的狀態推導，含 FEFO 扣減；分群偏好持久化（SharedPreferences）
- [x] M1.13 `FoodItemFormValidator` 改寫為新驗證規則（名稱、份量或比例擇一、單位、期限區間、金額）；純 Dart 單元測試

## 1. Theme 與 token

- [x] 1.1 新增 `lib/theme/app_theme.dart`：以 seed 產生明暗 `ColorScheme`、`TextTheme`（NotoSansTC、tabular figures）、元件主題（AppBar、Card、Button、Input、ListTile、SnackBar、NavigationBar）
- [x] 1.2 新增 `FoodStatusColors` `ThemeExtension`（明暗各一組）與 `context.foodStatusColors` extension
- [x] 1.3 新增 `AppSpacing`、`AppRadius`、`AppDurations` 常數
- [x] 1.4 `ThemeCubit` 改為只持有 `ThemeMode`（含 SharedPreferences 持久化），`AppView` 以 `theme`／`darkTheme`／`themeMode` 組裝；更新 `theme_cubit_test.dart`
- [x] 1.5 `FoodItemStatusExtension.color` 改為依 `BuildContext` 取 `FoodStatusColors`；`FoodItemTypeExtension.color` 改用 `ColorScheme` 衍生或語意色

## 2. 元件庫

- [x] 2.1 `AppScaffold`、`SectionHeader`、`EmptyState`
- [x] 2.2 `StatusChip`（含 `unknownExpiry`）、`AmountLabel`（小數不顯示 `.0`、比例模式）、`ExpiryCountdown`（`now` 可注入，區間／月份以近似語氣呈現）
- [x] 2.2b `ExpiryField`（四種精度切換的期限輸入）、`LocationPicker`、`PendingExpiryBadge`
- [x] 2.3 `FoodItemTile`（含滑動動作插槽）與 `FoodItemGroupCard`（合併卡片，可展開列出批次）
- [x] 2.4 `AppSnackBar`（success／warning／error，可選 Lottie，尊重 disableAnimations）
- [x] 2.5 `ConfirmSheet`、`DatePickerField`
- [x] 2.6 每個元件 widget test：明暗各一、zh／en 長字串不溢出

## 3. 頁面重製（由小到大）

- [x] 3.1 設定頁：分區、`ListTile` 主題化、移除硬編碼字串（新增 l10n key）
- [x] 3.2 使用者頁：頭像／資訊區、備份／還原改為有狀態的按鈕列 + `AppSnackBar`，字串進 l10n
- [x] 3.3 統計頁：圖表容器卡、`EmptyState` 取代「尚無資料」、圖表色改用 token；圓餅圖改以筆數計量；新增浪費率趨勢、最常浪費 Top 5、浪費原因分佈、金額損益（含涵蓋率）與點數規則變更說明
- [x] 3.4 紀錄頁：週日期列元件化、`FoodItemTile` 重用、刪除改 `ConfirmSheet`、三態；新增處理方式／原因／金額呈現、食用｜浪費篩選、補記浪費原因
- [x] 3.5 食物頁拆分為 `lib/pages/food_item_list/`：清單頁（三態、FAB、分群切換、合併卡片）、`FoodItemFormPage`（新增／編輯，含期限精度、開封、位置、金額）、`QuickAddBar`（一行快速新增，鍵盤不收起、連續輸入）、`UseSheet`（同時記食用與丟棄）、`WasteReasonSheet`、過期處理頁
- [x] 3.5b `StorageLocationPage`：位置的新增／改名／拖曳排序／刪除（刪除前告知影響筆數，食物歸為未指定）
- [x] 3.6 新增 `FoodItemListUseAll`／`FoodItemListPartialUse` event，將頁面內建立 `UsedFoodItem`、剩餘數量計算下沉到 Bloc；bloc_test 覆蓋
- [x] 3.7 底部導覽改為 `NavigationBar`（依 Q2），移除 `curved_labeled_navigation_bar`

## 4. 清理

- [x] 4.1 `grep` 確認 `lib/pages`、`lib/widgets` 無 `Colors.`、`Color(0x`、`fontSize:`、硬編碼中文
- [x] 4.2 更新 `intl_zh.arb`／`intl_en.arb` 並重新產生；刪除不再使用的 key
- [ ] 4.3 更新 README 截圖與功能清單

## 5. 驗證

- [x] 5.1 `dart format`、`flutter analyze --no-pub`（0 error／0 warning）
- [x] 5.2 `flutter test` 全綠（Bloc、元件、頁面 widget test、遷移、點數、期限推導）
- [x] 5.3 `flutter build apk --debug`（已通過）；`flutter build ios --no-codesign` 待 macOS
- [x] 5.4 實機（SM-T500 / Android 12，zh-TW ＋ en、明亮＋深色）：冷啟動無例外、空狀態與主要動作、一行快速新增連續輸入（鍵盤不收起、preset 命中 milk→瓶/7 天、beef→公克/3 天、未命中→待補期限徽章）、點徽章補期限（四精度分段按鈕英文不截斷）、依急迫度／依位置分群切換、同名批次合併卡（2 bottle · 2 batches）與展開、滑動操作面板（Throw out／Partial／Use all）、Use all 的即期救援 +3 分、紀錄頁週日期列與篩選、統計頁六個區塊、存放位置頁與三筆預設種子、詳情 sheet、重啟後資料保留
- [ ] 5.5 `openspec validate --all --strict --no-interactive`；更新受影響主規格（`/opsx:sync` 或 archive）

## 6. 美術（交由 Codex 以 imagegen 產出）

- [ ] 6.1 依 `art-requests.md` 產出素材，逐項回填檔名與實際尺寸
- [ ] 6.2 素材入庫 `assets/`、更新 `pubspec.yaml`、明暗主題各截一張確認

## 6b. 驗證回合修正（2026-09-15）

- [x] 6b.1 修正 `DropdownButtonFormField` 未設 `isExpanded` 造成新增食物頁全白（`LocationPicker`、類型、單位三處）
- [x] 6b.2 修正 `StorageLocationPage` 由 `Navigator.push` 開啟時找不到 `StorageLocationCubit`（食物頁與設定頁兩個入口都用 `BlocProvider.value` 帶過去）
- [x] 6b.3 新增表單的份量預設為 1，避免一送出就吃到「請填份量」
- [x] 6b.4 `pubspec.yaml` 補宣告 `assets/data/`，否則 release 讀不到保存期限對照表
- [x] 6b.5 統計頁補回月點數趨勢折線圖（主規格仍要求）
- [x] 6b.6 過期處理頁補上選填的浪費原因，並補 delta spec
- [x] 6b.7 食物清單空狀態補主要動作、合併卡尊重 `disableAnimations`、紀錄頁補 error 三態
- [x] 6b.11 修正浪費率圖 Y 軸 `100` 被折成兩行（`reservedSize` 不足），改為 `100%`／`0%` 並補回歸測試
- [x] 6b.10 英文語系與其餘互動的實機走查（見 5.4）
- [x] 6b.9 修正食物詳情把「類型」標成「描述」的標籤錯誤（實機截圖發現）
- [x] 6b.8 新增 `food_item_form_page_test`、`statistics_page_test`、`storage_location_page_test`，並補「連續快速新增保持聚焦」「過期處理帶原因」測試

## 7. 未完成項目與原因（如實紀錄）

- 4.3 README：等實機截圖才有東西可放。
- 5.4 實機驗證：**已完成**（見上）。
- 5.5：`openspec validate --all --strict` 已通過；主規格待同步。
- 6.1／6.2 美術素材：A1–A5 與 B–D 已產出、入庫並 binding；B1／B2 沿用既有 Lottie，E 食物類型 icon 仍待決策，F 浪費原因 icon 維持低優先。
- `flutter build ios --no-codesign`：需要 macOS，本機無法執行。
