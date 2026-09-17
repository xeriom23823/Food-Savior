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
- [x] 4.3 更新 README 功能清單（重寫為五組：記錄食物／看清楚／用掉或丟掉／其他／規劃中，補上四精度、位置、批次合併、加權點數、等級里程碑、發票掃描；修正「條碡」錯字與過期的點數描述）
- [ ] 4.4 README 截圖（使用者 2026-09-16 決定本輪先不放：僅有 SM T500 平板可用，比例不具代表性；改由使用者自備手機截圖後再嵌入）

## 5. 驗證

- [x] 5.1 `dart format`、`flutter analyze --no-pub`（0 error／0 warning）
- [x] 5.2 `flutter test` 全綠（Bloc、元件、頁面 widget test、遷移、點數、期限推導）
- [x] 5.3 `flutter build apk --debug`（已通過）；`flutter build ios --no-codesign` 待 macOS
- [x] 5.4 實機（SM-T500 / Android 12，zh-TW ＋ en、明亮＋深色）：冷啟動無例外、空狀態與主要動作、一行快速新增連續輸入（鍵盤不收起、preset 命中 milk→瓶/7 天、beef→公克/3 天、未命中→待補期限徽章）、點徽章補期限（四精度分段按鈕英文不截斷）、依急迫度／依位置分群切換、同名批次合併卡（2 bottle · 2 batches）與展開、滑動操作面板（Throw out／Partial／Use all）、Use all 的即期救援 +3 分、紀錄頁週日期列與篩選、統計頁六個區塊、存放位置頁與三筆預設種子、詳情 sheet、重啟後資料保留
- [x] 5.5 `openspec validate --all --strict --no-interactive` 通過（20 passed / 0 failed）；2026-09-16 archive 時已將 9 份 delta 併入主規格（新增 `design-system`、`storage-locations` 兩個 capability）

## 6. 美術（交由 Codex 以 imagegen 產出）

- [x] 6.1 依 `art-requests.md` 產出素材，逐項回填檔名與實際尺寸（A–E 已完成；F 維持低優先）
- [x] 6.2 素材入庫 `assets/`、更新 `pubspec.yaml`、明暗主題各截一張確認（E：24／48／72 px variants 與 1024 master 已入庫；2026-09-16 SM-T500 實機明暗各截一張完成，見 `runtime-e-light.png`／`runtime-e-dark.png`）
- [x] 6.3 補 `FoodTypeIcon` widget test（2.6 的元件測試標準）：11 個類型 asset 唯一、三個 variant 都讀得到、明亮／深色可繪製、IconTheme 與顯式 color 的著色優先序、pubspec 目錄宣告

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

- 4.3 README 功能清單：**已完成**（2026-09-16）。
- 4.4 README 截圖：使用者 2026-09-16 決定本輪先不放。本機僅連著 SM T500 平板、無 emulator、App 強制登入且無 demo seed 路徑，平板比例不能代表手機優先的設計；改由使用者自備手機截圖後再嵌入。
- 5.4 實機驗證：**已完成**（見上）。
- 5.5：**已完成**（2026-09-16）。主規格同步 20 ADDED／19 MODIFIED／1 REMOVED，並更新 food-inventory、food-consumption、food-points、statistics-charts 四份 Purpose；validate 20 passed / 0 failed。
- 6.1／6.2 美術素材：A1–A5、B–D 與 E 已產出並入庫；B1／B2 沿用既有 Lottie。E 已保留 24／48／72 px runtime variants 與 1024 master，且已替換 `FoodItemVisuals` binding，並補上 `food_type_icon_test.dart`（7 項全過）。實機明暗 A/B 已於 2026-09-16 使用者解鎖後完成（`runtime-e-light.png`／`runtime-e-dark.png`），圖示依 `FoodStatusColors.unknown` 正確著色；當時真實庫存只有一筆 `others`，故實機僅直接驗到 11 個中的 1 個，其餘由 24 px 預覽與 widget test 涵蓋。先前全黑的 `runtime-sm-t500-after-binding.png` 已刪除。F 浪費原因 icon 維持低優先。
- `flutter build ios --no-codesign`：需要 macOS，本機無法執行。
