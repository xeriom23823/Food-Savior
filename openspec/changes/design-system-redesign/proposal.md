## Why

Food Savior 的核心是「記錄家中食物與到期日」，但目前這件事只被記成 `name / type / quantity(int) / unit(3 種) / description / storageDate / expirationDate`：到期日必填且必須精確、份量只能是整數、沒有存放位置、沒有開封概念、沒有成本、浪費只知道「丟了」不知道「為什麼丟」。使用者實際的情境（「這包絞肉大概這週吧」「醬油開了剩半瓶」「上週一盒蛋今天又一盒」「忘記冰箱底層還有青椒」）在現行模型裡全都記不下來，只能硬填一個假日期或乾脆不記——而不記錄，整個點數與統計就失去意義。

視覺面同時是「Material 預設 + 綠色 AppBar」：頁面內大量硬編碼顏色與字級、暗色主題只是換 surface、五個分頁各自長相不一致，新增／編輯食物用 `AlertDialog` 塞下七個欄位。

本 change 要驗證的假設：**先把「一項食物」這個資料模型做對，再用一套 token 化的設計系統把它呈現出來**。兩者一起做，是因為新欄位（模糊期限、剩餘比例、自訂位置、成本、浪費原因）若先用現有的 `AlertDialog` 硬塞，之後重製時等於整個表單再寫一次；而設計系統若照現行七欄位做完，新欄位進來又要再改一輪。使用者在 2026-09-15 的釐清中確認合併範圍。

> 命名備註：本 change 原本只涵蓋設計系統，合併後範圍包含資料模型。目錄名維持 `design-system-redesign` 以免既有引用（AGENTS.md、archive 紀錄）失效。

## What Changes

### A. 食物記錄模型（新）

- **期限改為四種精度**：`exact`（精確到日）、`range`（約 3〜5 天後）、`monthOnly`（只知道 2026-10）、`unknown`（完全不知道，照樣可入庫）。統一存成 `expiryEarliest` / `expiryLatest`（皆可為 null）+ `expiryPrecision`。狀態推導、排序、提醒一律以 `expiryEarliest` 為準，`expiryLatest` 用來表達不確定區間。
- **開封後效期**：新增 `openedDate` 與 `shelfLifeAfterOpenDays`；開封後的有效期限取「原期限」與「開封日 + 開封後天數」較早者。
- **份量可小數、單位擴充、或改記剩餘比例**：`amount`（double?）取代 `quantity`（int，直接移除）；`Unit` 尾端新增 `pack`、`box`、`bottle`、`bag`、`can`、`serving`；不可量化的東西改用 `RemainingFraction`（滿／大部分／一半／不多／剩一點）。同一筆二選一。
- **自訂存放位置**：新 capability `storage-locations`，使用者可自建、命名、排序、刪除位置（「冰箱上層」「蔬果室」「儲藏櫃」），每個位置有 `kind`（冷藏／冷凍／常溫／其他）供效期建議使用。首次啟動種下冷藏／冷凍／常溫三筆預設。
- **成本**：新增選填的 `priceTotal`（整數，新台幣元）；部分使用時依數量比例攤提。
- **預設效期建議**：內建 `assets/food_presets.json`（名稱關鍵字 → 類型 + 依位置 kind 的保存天數），供快速新增與表單自動帶入，全部離線可算。

### B. 輸入流程（新）

- **一行快速新增**：只打名稱即可入庫。類型與期限的決定順序為「使用者常用模板（由歷史推導）→ 內建名稱對照表 → 存成 `unknown` 待補」。鍵盤不收起，可連續輸入多筆。
- **常用食物模板**：由既有 `FoodItem` 與 `UsedFoodItem` 歷史推導最近常用項目，一點即帶入名稱、類型、單位、預設效期與位置；不新增 Box。
- **待補完標記**：期限為 `unknown` 的項目照常出現在主清單，帶「待補期限」徽章並集中在專屬分群，點一下就能補。

### C. 清單呈現（新）

- **可切換分群**：預設依到期急迫度（已過期／今天／3 天內／一週內／充裕／期限未知），可切換為依存放位置或依類型，選擇持久化。
- **同名批次自動合併顯示**：同名稱 + 同位置 + 同單位的多筆收合成一張卡（「雞蛋 18 個」），展開見各批次期限；食用時預設從最早到期的批次扣（FEFO）。**資料仍是多筆，只是呈現合併**。

### D. 使用紀錄與回饋（新）

- `UsedFoodItem` 新增 `wasteReason`（忘記吃／買太多／壞掉／不好吃／放到過期太久／其他）、`disposalMethod`（吃掉／冒風險吃掉／送人／堆肥／丟棄）、`priceTotal`。
- **一次操作可同時記食用與丟棄**（「吃了 3 個、丟了 2 個」），資料上產生兩筆 `UsedFoodItem`。
- **點數改為依時效加權**：即期救援 +3、正常食用 +2、過期後才吃掉 +1、送人 +2、堆肥 −1〜−2、未過期就丟 −3、過期才丟 −2；每日加分上限沿用 10，但改以「當日加分總和」計算（不再被浪費扣分抵銷）。既有紀錄不追溯重算。
- **統計頁**：圓餅圖的計量單位從「點數」改為「筆數」（點數加權後不再適合當比例），並新增浪費率趨勢、最常浪費食物 Top 5、浪費原因分佈、金額損益四張圖。

### E. 設計系統（原範圍，不變）

- `lib/theme/`：`AppTheme`（seed `#3E8E5A`）、`FoodStatusColors`、`AppSpacing`、`AppRadius`、`AppDurations`；`ThemeCubit` 只持有 `ThemeMode`。
- `lib/widgets/` 元件庫：`FoodItemTile`、`StatusChip`、`ExpiryCountdown`、`AmountLabel`、`EmptyState`、`SectionHeader`、`AppSnackBar`、`ConfirmSheet`、`ExpiryField`、`LocationPicker`、`AppScaffold`。
- 五個分頁重製、三態（loading／empty／error）、移除所有硬編碼 `Colors.*`／`Color(0x…)`／`fontSize:`／中文字串。
- 底部導覽改用 Material 3 `NavigationBar`，移除 `curved_labeled_navigation_bar`。

### 範圍上限

五個既有分頁 + 新增／編輯表單頁 + 快速新增列 + 使用 sheet + 位置管理頁；不引入新的第三方 UI 套件（可移除一個）；平台以 Android／iOS 驗證。

### 非目標

- **條碼掃描與電子發票 QR 匯入**：使用者確認留待後續獨立 change（`barcode-einvoice` skill 已有規劃）。本 change 只保證資料模型不擋路（`FoodItem` 預留可由外部來源建立草稿的路徑）。
- **到期提醒（本機通知）**：使用者確認留待 `local-notifications` 獨立 change。本 change 只負責把模糊期限的「該在哪天提醒」定義清楚（以 `expiryEarliest` 為準），不做排程與權限。
- AI 猜測食物類型／效期（離線對照表已足夠）、雲端同步、onboarding、動態主題色、平板／桌面版面、重畫 Lottie 與 App icon。

## Capabilities

### New Capabilities

- `design-system`：色彩／字級／間距／圓角／動態 token、狀態語意色、元件庫契約、三態規則、可及性與明暗／多語檢查要求。
- `storage-locations`：使用者自訂存放位置的建立、命名、排序、刪除、預設種子與刪除時的項目處理。

### Modified Capabilities

- `food-inventory`：期限四精度、開封後效期、小數份量與剩餘比例、擴充單位、存放位置、成本、快速新增、待補完、可切換分群、同名批次合併呈現；驗證規則隨之改寫。
- `food-consumption`：一次操作可同時記食用與丟棄、浪費原因與處理方式、批次合併卡的 FEFO 扣減、部分使用的金額攤提。
- `food-points`：依時效加權的點數規則、每日上限改以加分總和計算。
- `usage-history`：紀錄列新增原因／處理方式／金額的呈現與篩選。
- `statistics-charts`：圓餅圖改以筆數計量，新增四張圖。
- `local-persistence`：新 Box `storageLocation`、`quantity`→`amount` 的一次性遷移、新列舉與欄位的 typeId／索引規則。
- `expired-food-processing`：處理頁套用元件與 l10n，並支援新的浪費原因欄位；流程不變。
- `app-shell-navigation`：底部導覽列元件替換。
- `localization`：消除既有硬編碼字串，新增全部新欄位與新畫面的 key。

## Impact

- **Code**：`lib/models/food_item.dart`（大幅擴充，拆成 `lib/models/`）、`lib/models/storage_location.dart`（新）、`lib/hive/`（新 adapter 與遷移）、`lib/repositories/`（新增 `StorageLocationRepository`、`FoodPresetRepository`）、`lib/bloc/`（新增事件與分群／合併邏輯）、`lib/theme/`（新）、`lib/widgets/`（新）、`lib/pages/*`（大幅重寫，`food_item_list_page.dart` 拆成 `food_item_list/`）、`lib/l10n/*.arb`、`assets/food_presets.json`（新）。
- **Tests**：期限精度與有效期限推算、點數加權、遷移、分群與合併、FEFO 扣減的單元測試；元件與五分頁 widget test；既有 Bloc 行為以 bloc_test 當安全網。
- **Dependencies**：移除 `curved_labeled_navigation_bar`；新增 dev 相依 `mocktail`（頁面 widget test 用 `MockBloc` 取代真實 Bloc——真實 Bloc 會做 Hive 磁碟 I/O，而 `testWidgets` 的 fake async 不會讓那些 Future 完成）。App 端不新增任何套件。
- **舊資料**：使用者決定完全忽略。Box 改用新名稱（`foodItems`／`usedFoodItems`），舊 Box 永不開啟，因此不寫任何遷移程式碼，模型可自由重構（改型別、刪欄位、重排列舉）。升級後清單為空是被接受的代價。
- **Risk**：點數規則改變會讓歷史統計的語意前後不一致（舊紀錄 ±1、新紀錄加權）。決定不追溯重算，改在統計頁標示規則變更日期。
