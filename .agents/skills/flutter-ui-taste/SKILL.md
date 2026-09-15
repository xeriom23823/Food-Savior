---
name: flutter-ui-taste
description: Food Savior 的 UI 品味與設計系統守則：Material 3 token 化（顏色、字級、間距、圓角、狀態色）、行動端 anti-slop 清單、空／載入／錯誤狀態、明暗主題與 zh/en 檢查表。任何新增或修改畫面、widget、主題、動畫前必讀；設計系統重製 change 期間也以此為準。
---

# Flutter UI 品味與設計系統

## 讀取順序

1. `openspec/specs/design-system/spec.md`（archive 後才存在）—— token 與元件契約的權威來源。
2. 尚未 archive 時讀 `openspec/changes/design-system-redesign/`（proposal、design、specs delta）。
3. 現行主題：`lib/cubits/theme_cubit.dart`（`lightTheme` / `darkTheme`，綠色主色 `#4CAF50`、NotoSansTC）。

## 先寫一行「設計讀法」再動手

> 讀法：Food Savior 是給一般家庭、每天打開 10 秒看一眼冰箱狀況的工具型 App；語言是「清爽、可靠、有一點溫度」，不是遊戲化炫技也不是企業後台。

每次 UI 任務開頭寫出這一行（可依 change 微調），所有取捨都回到它。

## 硬規則（違反即不通過）

1. **只用 token**：`Theme.of(context).colorScheme.*`、`textTheme.*`，以及設計系統定義的 `ThemeExtension`（例如 `FoodStatusColors`、`AppSpacing`、`AppRadius`）。pages／widgets 內禁止 `Colors.*`、`Color(0x…)`、`TextStyle(fontSize: …)`、魔術數字 padding。
2. **狀態色不可只靠顏色**：fresh／nearExpired／expired／consumed／wasted 一律「顏色 + 圖示或文字」同時呈現（色弱使用者）。
3. **每個清單三態齊全**：loading（骨架或指示器）、empty（插圖或圖示 + 一句話 + 主要動作）、error（訊息 + 重試）。空狀態不是空白。
4. **觸控目標 ≥ 48dp**，列高 56–72dp，內容距螢幕邊 16dp，8pt 網格。
5. **明暗主題同時設計**；暗色不是把白換黑，surface 層級用 `surfaceContainer*`。
6. **zh/en 都要通**：英文字串通常長 30–50%，按鈕與 chip 不得截斷；不用全大寫。
7. **動畫節制**：150–300ms、`Curves.easeOutCubic`；Lottie 只用在「完成食用／丟棄」這類回饋瞬間；尊重 `MediaQuery.disableAnimations`。
8. **主要流程不用 `AlertDialog` 塞表單**：新增／編輯食物用全螢幕頁或 `showModalBottomSheet(isScrollControlled: true)`；`AlertDialog` 只放確認／單一選擇。
9. **SnackBar 用主題**：不寫 `backgroundColor: Colors.white`（現有寫法在暗色下會刺眼）。
10. **Semantics**：圖示按鈕給 `tooltip`；自訂可點 widget 加 `Semantics(button: true, label: …)`。

## 行動端 anti-defaults（不要做）

- 漸層 hero 卡、AI 紫、玻璃擬態、無意義的巨大圓角（>20dp）。
- 三張一模一樣的統計卡排一列。
- Emoji 當圖示；顏色當唯一資訊。
- 每列都放三個 icon button；滑動操作超過 3 個。
- 「歡迎回來，使用者！」式的填充文字。
- 把後台儀表板搬到手機上（密度過高、字級 < 12sp）。

## 設計系統應包含的 token（重製 change 需落地）

| 類別 | 內容 |
|---|---|
| 色彩 | `ColorScheme.fromSeed` 或手動調色：primary（品牌綠）、secondary、tertiary（強調），surface 階層；語意色 ThemeExtension `FoodStatusColors {fresh, nearExpired, expired, consumed, wasted}` 明暗各一組，對比 ≥ 4.5:1 |
| 字級 | Material 3 `TextTheme` + NotoSansTC；zh 行高 1.4–1.5；數字用 `FontFeature.tabularFigures()` |
| 間距 | `AppSpacing` 4/8/12/16/24/32 |
| 圓角 | `AppRadius` sm 8 / md 12 / lg 16；同層級元件同圓角 |
| 高度 | Material 3 tonal elevation，少用陰影 |
| 圖示 | Material Symbols 為主，`font_awesome_flutter`（11+，取 `FontAwesomeIcons.x.data` 得到 `IconData`）只補食物類型；不可再引入 `material_design_icons_flutter`（已停止維護且與 Flutter 3.47 不相容）；統一 24dp、同一 weight |
| 動態 | duration／curve token |

## 元件清單（重製時建立，之後所有頁面重用）

`FoodItemTile`、`StatusChip`、`ExpiryCountdown`、`QuantityWithUnit`、`EmptyState`、`SectionHeader`、`AppSnackBar`（含成功／警告／錯誤三種）、`ConfirmSheet`、`DatePickerField`、`AppScaffold`（統一 AppBar 樣式）。

## UI 完成前的 pre-flight

- [ ] 沒有新增硬編碼顏色／字級／字串（`grep -n "Colors\.\|Color(0x\|fontSize:" lib/pages lib/widgets` 沒有新增行）
- [ ] 明／暗、zh／en、360×640 與 412×915 各截圖一次（Dart MCP `launch_app` + 模擬器）
- [ ] 三態（loading／empty／error）都能看到
- [ ] 滑動、長按、點擊各有可見回饋
- [ ] 文字對比、觸控大小、`tooltip` 齊
- [ ] `flutter analyze` 無 warning；相關 widget test 通過
