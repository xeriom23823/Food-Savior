# 美術需求清單（交由 Codex 以 imagegen skill 產出）

本檔記錄 `design-system-redesign` 需要的視覺素材。**所有素材必須同時在淺色與深色主題上可辨識**，並與品牌色一致：主色沉穩綠 `#3E8E5A`、強調暖黃 `#E0A100`、App icon 為黑褐吉娃娃（已存在，不重畫）。

風格基調：**扁平、圓潤、低飽和、無漸層濫用、無 3D 質感**；線條粗細一致；避免「AI 插畫感」的過度光暈與粒子。所有插畫類素材主角為食物或吉娃娃，不出現人臉。

## A. 空狀態插畫（優先，阻擋 3.x 頁面完成）

| # | 用途 | 內容 | 規格 |
|---|---|---|---|
| A1 | 食物清單空 | 空冰箱 + 吉娃娃探頭，語氣輕鬆不責備 | 透明背景 PNG，1024×1024 產出後縮至 @1x/@2x/@3x |
| A2 | 使用紀錄空（某日無紀錄） | 空盤子與餐具，安靜中性 | 同上 |
| A3 | 統計無資料 | 空的圖表框線 + 小吉娃娃坐在旁邊 | 同上 |
| A4 | 搜尋／篩選無結果 | 放大鏡與一顆滾走的番茄 | 同上 |
| A5 | 存放位置尚未建立 | 冰箱門打開，三個空層架 | 同上 |

## B. 狀態與回饋動畫（Lottie；imagegen 先出關鍵影格供描圖）

| # | 用途 | 內容 | 備註 |
|---|---|---|---|
| B1 | 食用成功 | 食物被吃掉 → 吉娃娃滿足表情 | 現有 Lottie 若堪用可保留，先評估 |
| B2 | 丟棄 | 食物落入回收桶，中性不羞辱 | 語氣重要：不要哭臉、不要紅色警報 |
| B3 | 即期救援（+3 分） | 食物在最後一刻被接住，暖黃星光 | 這是產品最想鼓勵的行為，值得一個獨立回饋 |
| B4 | 每日上限已達 | 溫和的「今天夠了」提示 | 可用靜態插圖代替 |

## C. 期限精度的視覺語彙（icon set，SVG→IconData 或 asset）

| # | 用途 | 內容 |
|---|---|---|
| C1 | `exact` 精確期限 | 實心日曆 |
| C2 | `range` 區間期限 | 日曆 + 波浪線（約略） |
| C3 | `monthOnly` 只到月 | 日曆只顯示月份格 |
| C4 | `unknown` 期限未知 | 日曆 + 問號（這是「待補期限」徽章的圖示） |
| C5 | 已開封 | 開口的包裝／掀蓋 |

全部 24×24 線性圖示，`currentColor` 可著色，線寬與 Material Symbols 一致。

## D. 存放位置 kind 圖示

| # | kind | 內容 |
|---|---|---|
| D1 | `refrigerated` | 冷藏室（雪花以外的辨識，例如溫度計低溫） |
| D2 | `frozen` | 雪花 |
| D3 | `ambient` | 櫥櫃／室溫 |
| D4 | `other` | 通用箱子 |

24×24 線性，同 C 組風格。

## E. 食物類型圖示（評估後再決定是否重畫）

現行使用 Font Awesome 11（11 種類型）。風格與上述線性圖示不一致（FA 偏實心、比例不同）。
**待決策**：是否請 Codex 產一套 11 個同風格的線性食物圖示取代。決定前不要動。

## F. 浪費原因的小圖示（低優先）

`forgotten`（時鐘）、`boughtTooMuch`（購物袋滿出來）、`spoiled`（波浪線）、`disliked`（餐具放下）、`expiredTooLong`（日曆加叉）、`other`（三點）。16×16 或 20×20，可只用文字先上線。

## G. 里程碑徽章（user-profile-and-points change 需要）

六個徽章，每個要**達成**與**未達成**兩態（未達成可由達成版去飽和度產生，但輪廓要清楚）：

| # | 里程碑 | 內容 |
|---|---|---|
| G1 | 踏出第一步 | 一顆被記下的食物 + 小旗子 |
| G2 | 即期救援隊 | 一隻手在最後一刻接住食物 |
| G3 | 百分達成 | 數字 100 與月桂葉 |
| G4 | 一週零浪費 | 七格日曆全部打勾 |
| G5 | 一個月零浪費 | 月曆 + 星星 |
| G6 | 五百俱樂部 | 獎牌 + 500 |

96×96 透明背景 PNG（@1x/@2x/@3x），風格同 A 組（扁平、圓潤、低飽和）。未完成前畫面用 Material 圖示 + 灰階，換上後只需改 `PointsMilestoneLabel.icon` 的對應。

## 產出後的入庫步驟

1. 檔案放 `assets/images/`（插畫）、`assets/icons/`（圖示）、`assets/lottie/`（動畫）。
2. 更新 `pubspec.yaml` 的 `assets:`。
3. 每個素材在明暗主題各截一張圖確認對比與可辨識度。
4. 回填本檔的實際檔名與尺寸，並勾 `tasks.md` 的 6.1／6.2。

## 2026-09-15 入庫紀錄

第一批先完成 A 組五張空狀態插畫。使用 built-in `imagegen` 產出 RGBA master，再加上透明留白縮放成 Flutter resolution variants；頁面透過 `lib/theme/app_assets.dart` binding 到 `EmptyState.illustrationAsset`。

| 編號 | Flutter asset | master／runtime 尺寸 | binding |
|---|---|---|---|
| A1 | `assets/images/empty_food_inventory.png` | master 1024×1024；1x 320×320、2x 640×640、3x 960×960 | 食物清單空狀態 |
| A2 | `assets/images/empty_used_history.png` | master 1024×1024；1x 320×320、2x 640×640、3x 960×960 | 使用紀錄無紀錄 |
| A3 | `assets/images/empty_statistics.png` | master 1024×1024；1x 320×320、2x 640×640、3x 960×960 | 統計無資料 |
| A4 | `assets/images/empty_filter_no_results.png` | master 1024×1024；1x 320×320、2x 640×640、3x 960×960 | 使用紀錄篩選後無結果 |
| A5 | `assets/images/empty_storage_locations.png` | master 1024×1024；1x 320×320、2x 640×640、3x 960×960 | 存放位置為空 |

Master 與生成來源保留於 `AgentAudit/genart/design-system-redesign-20260915/masters/`；runtime PNG 均為 RGBA，透明留白已檢查。B 組關鍵影格、C/D icon set、E 食物類型 icon 尚未納入本批次。

明暗預覽證據：`AgentAudit/genart/design-system-redesign-20260915/preview-light.png`、`preview-dark.png`。SM T500 實機 foreground capture（當時已有食物資料，未直接命中空狀態）為 `runtime-sm-t500-foreground.png`；其用途是確認 app 啟動與 asset binding 沒有造成 runtime crash，不取代空狀態的實機畫面驗收。

## 2026-09-15 第二批入庫紀錄（B–D）

B1／B2 評估後沿用既有 Lottie，並由 `AppSnackBar` 的回饋入口實際 binding：

| 編號 | asset | binding／判斷 |
|---|---|---|
| B1 | `assets/animations/eating.json`（280×280，60 fps，180 frames） | 食用成功或含食用的混合處理回饋；尊重 `disableAnimations` |
| B2 | `assets/animations/dumping.json`（既有 Lottie） | 純浪費回饋；使用 warning 語意色，不改成羞辱式紅色警報 |
| B3 | `assets/images/feedback_rescue.png`；master `1254×1254`，runtime `320／640／960` | 實際點數含 `+3` 的即期救援回饋；暖黃星光靜態插圖 |
| B4 | `assets/images/feedback_daily_cap.png`；master `1254×1254`，runtime `320／640／960` | 任一食用紀錄因每日正分上限得到 `0` 點時顯示；文案走 zh／en l10n |

B3／B4 master 與生成來源保留於 `AgentAudit/genart/design-system-redesign-20260915/masters/`；明暗檢視為 `feedback-preview-light.png`、`feedback-preview-dark.png`。兩張 runtime PNG 均為 RGBA，alpha extrema 為 `(0,255)`。

C／D 以 24×24、`currentColor`、`stroke-width="2"` 的 SVG 作 canonical source，放在 `assets/icons/`：

- C1–C5：`expiry_exact.svg`、`expiry_range.svg`、`expiry_month_only.svg`、`expiry_unknown.svg`、`opened_package.svg`
- D1–D4：`location_refrigerated.svg`、`location_frozen.svg`、`location_ambient.svg`、`location_other.svg`

因 proposal 明定 App 端不新增 package，runtime 由 `lib/widgets/app_line_icon.dart` 的 `CustomPainter` 以同一幾何語彙 binding，顏色從 `IconTheme`／`ColorScheme` 取得。C 組已接到 `ExpiryField`、`ExpiryCountdown`、待補期限徽章、詳情操作；D 組已接到 `LocationPicker`、存放位置頁與位置編輯器。`AppLineIcon` widget test 已涵蓋明亮／深色主題與 9 個圖示。

## 2026-09-16 第三批入庫紀錄（E）

使用者決定製作 E 組。以 built-in `imagegen` 逐張產出 11 個線性食物類型圖示，再統一清除近黑背景、抑制生成光暈、重建真正 alpha、重設品牌色與留白。候選素材放在 `AgentAudit/genart/design-system-redesign-20260916/`，runtime variants 入庫 `assets/icons/`：

| FoodItemType | 24×24 | 48×48 | 72×72 | master |
|---|---|---|---|---|
| vegetable | `food_type_vegetable.png` | `2.0x/food_type_vegetable.png` | `3.0x/food_type_vegetable.png` | `food_type_vegetable_master.png` |
| fruit | `food_type_fruit.png` | `2.0x/food_type_fruit.png` | `3.0x/food_type_fruit.png` | `food_type_fruit_master.png` |
| meat | `food_type_meat.png` | `2.0x/food_type_meat.png` | `3.0x/food_type_meat.png` | `food_type_meat_master.png` |
| eggAndMilk | `food_type_egg_milk.png` | `2.0x/food_type_egg_milk.png` | `3.0x/food_type_egg_milk.png` | `food_type_egg_milk_master.png` |
| seafood | `food_type_seafood.png` | `2.0x/food_type_seafood.png` | `3.0x/food_type_seafood.png` | `food_type_seafood_master.png` |
| cannedFood | `food_type_canned_food.png` | `2.0x/food_type_canned_food.png` | `3.0x/food_type_canned_food.png` | `food_type_canned_food_master.png` |
| cookedFood | `food_type_cooked_food.png` | `2.0x/food_type_cooked_food.png` | `3.0x/food_type_cooked_food.png` | `food_type_cooked_food_master.png` |
| drink | `food_type_drink.png` | `2.0x/food_type_drink.png` | `3.0x/food_type_drink.png` | `food_type_drink_master.png` |
| snack | `food_type_snack.png` | `2.0x/food_type_snack.png` | `3.0x/food_type_snack.png` | `food_type_snack_master.png` |
| bread | `food_type_bread.png` | `2.0x/food_type_bread.png` | `3.0x/food_type_bread.png` | `food_type_bread_master.png` |
| others | `food_type_others.png` | `2.0x/food_type_others.png` | `3.0x/food_type_others.png` | `food_type_others_master.png` |

亮／暗 surface 預覽與 24 px 可讀性檢查：`AgentAudit/genart/design-system-redesign-20260916/food-types-preview-light.png`、`food-types-preview-dark.png`、`food-types-24px-preview-light.png`、`food-types-24px-preview-dark.png`。E 已由 `FoodItemVisuals.assetOf` + `FoodTypeIcon` 替換原本的 Font Awesome food-type binding；`font_awesome_flutter` 仍保留給 Google 登入等其他用途。F 組仍維持低優先。

### 2026-09-16 實機驗收（SM-T500）

使用者解鎖裝置後完成明暗各一張的實機截圖：`runtime-e-light.png`、`runtime-e-dark.png`（食物清單頁，1200×2000）。E 組圖示在兩種主題都正常繪製、24 dp 下輪廓清楚，並依 `FoodStatusColors.unknown`（亮 `#6B5E8A`／暗 `#CCC2E6`）著色，證實 `ColorFiltered` 的 `srcIn` 著色有生效、沒有殘留圖檔本身的品牌綠。

**涵蓋範圍限制**：裝置上的真實庫存當時只有一筆 `others` 類型的食物，因此實機只直接看到 11 個圖示中的 1 個。其餘 10 個由 `food-types-24px-preview-light/dark.png` 與 `test/widgets/food_type_icon_test.dart`（asset 唯一性、三個 variant 都能從 bundle 讀出、明暗可繪製、著色優先序）涵蓋；不另外造假資料去湊滿 11 種。

先前的 `runtime-sm-t500-after-binding.png` 是裝置鎖定時截到的全黑畫面（與 20260915 失敗截圖同 MD5），已刪除以免被誤引為證據。
