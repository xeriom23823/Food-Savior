## Why

食物頁是使用者每天打開的那一頁，目前是乾淨但沒有個性的 Material 3 清單（實機截圖 `AgentAudit/genart/design-system-redesign-20260916/runtime-e-light.png`）：分群只是一行標題、食物只是一個單色線條圖示、操作完成後只有一條 SnackBar。品牌方向已經是繪本語彙——黑褐吉娃娃抱著麵包、A1 空狀態裡吉娃娃從冰箱探頭——但一有資料進來，這些個性就消失了。使用者在 2026-09-17 的釐清中確認：食物頁要「像一個冰箱」、每個可操作的動作都要有適當回饋、整體走《麵包小偷》式的手繪繪本風。

為何現在做：`design-system-redesign` 剛 archive，token、元件庫、三態、l10n 都已就位，這是把品牌個性落到主頁面成本最低的時刻。接下來的過期提醒、雲端同步都會往這一頁堆功能，先把「冰箱」的骨架與回饋管線定下來，之後的功能才有地方長。

要驗證的假設：**層架式的冰箱清單＋看得到、摸得到、聽得到的操作回饋**，會讓使用者更願意每天打開、記錄、把東西吃掉；同時不犧牲「10 秒看一眼」的效率與現有資訊密度（名稱、份量、位置、倒數在同一列）。

## What Changes

### A. 冰箱層架式清單（使用者決策：層架式，不做整頁擬真 grid）

- 食物頁的清單外面包一層**冰箱外框**：頂部一道冰箱燈、兩側內牆，底部的快速新增列變成冰箱門的置物格。
- 每個分群變成一層**層架**：層架標籤（貼紙造型，含分群名稱與筆數）＋食物列＋架板。三種分群都用層架呈現，層架跟著分群走：依急迫度時標籤用狀態語意色與圖示；依位置時架板外觀依 `kind` 區分（冷凍加霜、常溫變木櫥、冷藏預設、其他中性）並保留圖示；依類型時標籤帶類型角色。**不改任何分群或排序邏輯**。
- 深色模式採「冰箱燈微亮」：沿用現有 dark surface，架板留一道冷白微光，插畫加淡色圓片保對比，紙紋降不透明度。

### B. 《麵包小偷》風食物角色（使用者決策：有表情的食物角色）

- 11 種 `FoodItemType` 各一張手繪彩色角色插畫（半睜眼、小嘴的呆萌表情），**只在食物頁與其子頁**取代單色線條圖示；紀錄頁、統計頁、其他分頁維持現有 E 組線條圖示。
- 狀態仍以貼紙（`StatusChip`／`ExpiryCountdown`／`PendingExpiryBadge`）的顏色＋文字呈現，角色表情固定、不隨狀態改變（避免 11×N 張圖）。
- 繪本質感（紙紋、架板、貼紙）全部進 `StorybookTheme` token；頁面仍不得寫死任何顏色、圖片路徑或不透明度。

### C. 每個操作都有回饋（使用者決策：微動畫、觸覺、吉娃娃反應、音效四者全要）

- **微動畫**：新增的列從層架上方滑入、該層架冷光閃一下；全部使用時列縮小滑出層架才消失；丟棄時列往下滑出；部分使用時列彈跳一下；補期限／標記開封時貼紙以蓋章動態出現；切換分群時層架交叉淡入；本次啟動第一次進食物頁時層架依序進場。
- **觸覺**：三級——輕（展開、切換分群）、確認（新增、食用、補期限、開封、匯入完成）、警告（丟棄、刪除、過期處理完成）。
- **吉娃娃事件反應**：平時看不到；食用（開心）、即期救援（慶祝）、丟棄（中性聳肩，不責備）、補期限／開封（點頭）、每日上限（「今天夠了」）時從層架邊探頭約 2 秒再縮回。新增／編輯／刪除只用 SnackBar。
- **音效**：開冰箱門（本次啟動第一次進食物頁）、啵（新增）、咀嚼（食用）、輕放（丟棄）、貼紙（補期限／開封）、匯入完成一聲。
- 全部回饋都是**呈現層**：資料寫入不等動畫；系統「減少動態」開啟時略過裝飾動畫與角色反應，只留即時狀態變化與 SnackBar。

### D. 子頁面一併繪本化（使用者決策：四類子頁都做）

- 詳情 sheet、部分使用 sheet、浪費 sheet：頁首放該食物的角色插畫與貼紙，欄位與行為不變。
- 過期處理頁：頁首「吉娃娃幫你清冰箱」插圖與一句中性說明（`expiredProcessingIntro`），每列改用食物角色；流程、預設值、點數規則不變。
- 新增／編輯表單頁：頁首角色隨所選類型即時切換；送出成功的回饋由清單頁的 `added`／`updated` 管線給。
- 匯入草稿頁（發票／收據）：確認匯入後回到清單，匯入的列一起進場、觸覺一次、音效一聲；草稿確認流程本身不變。

### E. 設定

- 設定頁新增「回饋」區：`soundEffects`（預設開）與 `hapticFeedback`（預設開）兩個開關，持久化，立即生效。

### 範圍上限

- 頁面：食物清單主頁＋詳情／使用／浪費三個 sheet＋過期處理頁＋表單頁＋匯入草稿頁（只改頁首與回饋）。
- 新套件：**1 個**（`audioplayers`），只用於短音效。
- 美術：≤ 22 張靜態 PNG（11 食物角色、5 吉娃娃反應、3 紋理、1 過期處理插圖、備用 2）＋ 6 段 ≤ 1.5 秒的音效；不新增 Lottie。
- 資料：Hive schema、Box、`FoodItem` 欄位**完全不動**；Bloc 只在 `FoodItemFeedback` 增加 `itemIds`；SharedPreferences 新增 2 個 key。
- 平台：Android 實機（SM-T500）驗證；iOS 只保證可編譯與音效 category 設定正確。

### 非目標

- 其他四個分頁換皮、seed 色或字型變更、App icon／Splash 重製。
- 整頁擬真冰箱 grid、兩種視圖切換、強制依位置分群。
- 角色常駐、閒置動畫、對話泡泡文字。
- 角色表情隨狀態變化（11×N 張圖）。
- Lottie 重製（B1／B2 沿用）、里程碑徽章、通知音。
- 任何資料模型、點數、分群、排序、驗證規則的行為變更。

## Capabilities

### New Capabilities

- `interaction-feedback`：食物頁及其子頁每個使用者操作對應的視覺、觸覺、音效與角色反應；回饋與資料寫入的分離；「減少動態」與使用者設定對回饋的影響。

### Modified Capabilities

- `design-system`：token 來源新增 `StorybookTheme`（紙紋、架板、冰箱燈、貼紙）；新增「食物頁繪本層」與「食物角色插畫」的要求；元件庫新增 `FridgeFrame`、`FridgeShelf`、`FoodCharacter`、`ChihuahuaPeek`；動態節制條款涵蓋層架進場與角色反應。
- `food-inventory`：分群以層架呈現（標籤含筆數、位置層架依 kind 區分外觀）；清單列的類型圖示在食物頁改為角色插畫；新增冰箱外框與快速新增列的位置要求。
- `food-consumption`：滑動操作後的列離場動態（useAll／waste 先離開層架再消失、partialUse 留在原位標示份量已變），動畫期間不阻擋操作。
- `expired-food-processing`：處理畫面加入吉娃娃清冰箱插圖與中性說明，每列以角色呈現；流程不變。
- `app-settings`：新增音效與觸覺兩個開關及其持久化。
- `einvoice-import`：確認匯入後回到清單的回饋（匯入列一起進場、觸覺一次、音效一聲）。

## Impact

- **Code**：`lib/theme/`（新 `storybook_theme.dart`、`AppAssets` 新路徑、`FoodItemVisuals.characterAssetOf`）、`lib/widgets/`（新 `fridge_frame.dart`、`fridge_shelf.dart`、`food_character.dart`、`chihuahua_peek.dart`、`animated_shelf_list.dart`）、`lib/feedback/`（新 `feedback_choreographer.dart`、`haptic_service.dart`、`sound_effects.dart`、`feedback_cue.dart`）、`lib/cubits/feedback_preferences_cubit.dart`（新）、`lib/bloc/food_item_list/`（`FoodItemFeedback.itemIds`）、`lib/pages/food_item_list/*`（主頁、三個 sheet、過期處理頁、表單頁）、`lib/pages/import/import_drafts_page.dart`、`lib/pages/settings_page.dart`、`lib/l10n/*.arb`、`pubspec.yaml`（套件與 `assets/audio/`）。
- **Tests**：`FeedbackChoreographer` 對應表（以假的觸覺／音效服務錄下呼叫）、`AnimatedShelfList` 鍵值差異（插入／移除）、`FridgeShelf` 三種分群外觀、`FoodCharacter` 11 張 ×3 變體可載入、`ChihuahuaPeek` 出現／消失與減少動態、`FeedbackPreferencesCubit` 持久化、`FoodItemListBloc` 的 `itemIds`（bloc_test）、食物頁 widget test 更新。
- **Dependencies**：新增 `audioplayers ^6.8.1`（Flutter ≥ 3.44；Android minSdk 19，本專案 minSdk 依 Flutter 預設 ≥ 21；iOS 無需權限；音效 category 設為 ambient 以尊重靜音鍵）。不新增其他 UI 套件。
- **Assets**：`assets/images/`（角色、反應、紋理、插圖，各 1x／2x／3x）、`assets/audio/`（6 個 WAV）。美術由 Codex imagegen 產出並保存於 `AgentAudit/genart/storybook-fridge-food-page-20260917/`；音效需 CC0 來源（下載前需使用者同意）或使用者自備。
- **l10n**：新增 `feedbackSection`、`soundEffects`、`hapticFeedback`、`expiredProcessingIntro`、五個角色反應的無障礙標籤（`reactionHappy`、`reactionCelebrate`、`reactionNeutral`、`reactionNod`、`reactionSleepy`）。
- **平台**：Android 無新權限（`HapticFeedback` 不需 VIBRATE）；iOS 無新 Info.plist 項目。`flutter build apk --debug` 需重跑確認 `audioplayers_android` 與 AGP 9.1／內建 Kotlin 相容。
- **與進行中 change 的關係**：`paper-receipt-ocr`（37／40 任務）與本 change 都會改 `food_item_list_page.dart` 與 `import_drafts_page.dart`。本 change 的實作應在該 change archive 之後開始，或先只做 token／元件／服務層（不碰這兩個檔案）。
- **風險**：低階裝置（SM-T500，Snapdragon 662）的捲動效能、紙紋降低文字對比、音效惱人、繪本風被誤認為抄襲原作角色。對策見 design.md。
