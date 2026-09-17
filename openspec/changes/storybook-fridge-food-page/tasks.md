## 0. 前置與美術方向

- [ ] 0.1 確認 `paper-receipt-ocr` 已 archive 或協調好：本 change 的 1.x～3.x（token、元件、服務、Bloc）不碰 `food_item_list_page.dart` 與 `import_drafts_page.dart`，4.x 頁面整合等它 archive 後再做；在本檔記下實際順序
- [ ] 0.2 Codex 試作 3 張（P1 吐司、P2 蛋奶、P3 吉娃娃開心探頭）存入 `AgentAudit/genart/storybook-fridge-food-page-20260917/probe/`，使用者確認風格方向；不通過就調整 art-requests 的風格基調後重做，通過才進 0.3
- [ ] 0.3 Codex 批次產出 A 組 11 張食物角色、B 組 5 張吉娃娃反應、D1 過期處理插圖（1024×1024 RGBA master），逐張人工核對「不是既有繪本／商標角色的變體」，並用淺／深 surface 預覽與 40 px 縮圖確認 11 個角色彼此可區分
- [ ] 0.4 Codex 產出 C 組 3 張 256×256 無縫紋理（紙紋、霜、木紋），確認四邊無縫且不含深色像素
- [ ] 0.5 取得 6 段音效（使用者同意下載 kenney.nl CC0 包，或使用者自備），轉成 WAV 44.1 kHz 16-bit mono、各 ≤ 1.5 秒 ≤ 150 KB，放 `assets/audio/`，來源與授權記入 art-requests 入庫紀錄

## 1. 套件、資源與 token

- [ ] 1.1 `pubspec.yaml` 新增 `audioplayers: ^6.8.1` 與 `assets/audio/`；`flutter pub get` 成功，`flutter build apk --debug` 通過（驗證 `audioplayers_android` 與 AGP 9.1／內建 Kotlin 相容；失敗則記錄並依 design D7 把音效降級為後續 change）
- [ ] 1.2 插畫入庫：master 縮成 1x／2x／3x 放 `assets/images/{,2.0x/,3.0x/}`（角色 64／128／192、反應 96／192／288、過期插圖 192／384／576、紋理只放 1x）；`AppAssets` 新增角色反應、紋理、過期插圖、6 個音效路徑；`FoodItemVisuals.characterAssetOf(FoodItemType)`；`test/theme/app_assets_test.dart` 驗證每個路徑三個變體都能從 bundle 載入
- [ ] 1.3 新增 `lib/theme/storybook_theme.dart`：`StorybookTheme` ThemeExtension 明暗兩組（紙紋／霜／木紋路徑與不透明度、內牆、冰箱燈、架板、架板前緣、冷光、貼紙紙色／墨色、角色圓片）與 `context.storybook`；掛進 `AppTheme.light/dark`；單元測試驗證 `lerp` 與明暗值都存在
- [ ] 1.4 `test/theme/storybook_contrast_test.dart`：以紙紋最深像素疊上 `surface` 後對 `onSurface`／`onSurfaceVariant` 計算對比，明暗都 ≥ 4.5；架板上貼紙墨色對貼紙紙色 ≥ 4.5
- [ ] 1.5 回填 `art-requests.md` 入庫紀錄與 `docs/art-asset-inventory.md`（檔名、尺寸、來源、授權）

## 2. 元件庫

- [ ] 2.1 `FoodCharacter({type, size})`：`Image.asset` + `cacheWidth`、深色主題外包 `characterBackdrop` 圓片、`errorBuilder` 退回 `FoodTypeIcon`、`Semantics` 標籤為類型名；widget test 明暗各一、11 種類型、資源缺失時退回
- [ ] 2.2 `FoodItemTile` 新增 `leading` 插槽（預設維持現有圓形 `FoodTypeIcon`），垂直 padding 改為 `AppSpacing.sm` 使列高 ≤ 72 dp；`FoodItemGroupCard` 透傳 `leading`；既有 widget test 更新並新增「傳入 `FoodCharacter` 時列高 ≤ 72」
- [ ] 2.3 `FridgeFrame({child, bottomBar, overlay})`：冰箱燈條、兩側內牆（紙紋）、底部列、`Stack` overlay；widget test 驗證內容寬度只減 `AppSpacing.md × 2`、明暗都能 build、overlay 不攔截觸控
- [ ] 2.4 `FridgeShelf`：把 `FoodListSection` 展開成 `ShelfLabelRow`／`ShelfItemRow`／`ShelfPlankRow` 的純函式與 `ShelfSkin`（急迫度語意色＋圖示、位置依 kind 的霜／木／預設／中性＋圖示、類型帶 `FoodCharacter(24)`）；`ShelfPlankRow` 的 `CustomPainter` 含 `glow` 參數；widget test 涵蓋三種分群外觀、標籤含 `itemCount`、深色有冷白微光
- [ ] 2.5 `AnimatedShelfList`：以鍵（`label:`／`item:`／`plank:`）對新舊 rows 做差異，`AnimatedList` 插入自上滑入、移除依 `RowMotion` 播縮小右滑／下滑淡出／淡出並帶舊 widget、留存列依 `itemIds` 播彈跳／蓋章／高亮、section 有新列時 plank 冷光 1→0；`disableAnimations` 時所有時長為零；差異失敗退回整表重建。單元測試涵蓋插入、移除、移動、分群切換、多筆同時進場錯開總時長 ≤ `AppDurations.long × 2`
- [ ] 2.6 `StickerStamp(trigger, child)`：scale 1.3→1、opacity 0→1、`AppDurations.medium`；包住 `ExpiryCountdown`／`PendingExpiryBadge`／開封圖示；widget test 驗證 trigger 變化才動、`disableAnimations` 不動
- [ ] 2.7 `ChihuahuaPeek(controller)` 與 `ChihuahuaPeekController`：右下角、`IgnorePointer`、進 `medium`／停 1200 ms／退 `medium`、同時最多一隻、新事件取代舊的、5 種反應各自 `Semantics` 標籤；widget test 驗證出現→消失時序、取代、`disableAnimations` 為 no-op、不攔截下方按鈕的點擊
- [ ] 2.8 每個新元件補 zh／en 長字串不溢出與 360×640 版面測試

## 3. 回饋服務與狀態

- [ ] 3.1 `lib/feedback/feedback_cue.dart`：`HapticLevel`、`SoundCue`、`ChihuahuaReaction`、`RowMotion`、`FeedbackCue` 與純函式 `mapCue(FoodItemFeedback)`；單元測試逐行對照 interaction-feedback 規格的對應表（含即期救援 +3 → celebrate、每日上限 → sleepy、丟棄 → neutral、新增／編輯／刪除 → 無角色）
- [ ] 3.2 `HapticService`（介面＋`HapticFeedback` 實作＋`RecordingHapticService`）；桌面／Web no-op；單元測試驗證三級對應與關閉時不呼叫
- [ ] 3.3 `SoundEffects`（介面＋`audioplayers` `AudioPool` 實作＋`RecordingSoundEffects`）：`ensureLoaded` 預載 6 cue、`play` 即發即忘並靜默錯誤、`AudioContext` 設 Android sonification／assistanceSonification／audioFocus none、iOS ambient；單元測試驗證關閉時不呼叫、載入失敗不拋出
- [ ] 3.4 `FeedbackPreferencesCubit`（`soundEffectsEnabled`／`hapticFeedbackEnabled`，預設 true，SharedPreferences 持久化）；`test/cubits/feedback_preferences_cubit_test.dart` 驗證預設、切換、重啟還原（沿用 `theme_cubit_test` 寫法）
- [ ] 3.5 `FeedbackChoreographer`：接 `FoodItemFeedback` → `mapCue` → 觸覺／音效（受 Cubit 控制）／`ChihuahuaPeekController`（受 `disableAnimations` 控制）／回傳 `RowMotion` 與 `itemIds` 給 `AnimatedShelfList`；`onFirstLoaded` 以 `SessionOnce` 保證每次啟動只播一次開門音效與層架進場；widget test 用 Recording 假物件斷言每種 feedback 的呼叫序列與「匯入多筆只一次」
- [ ] 3.6 `FoodItemFeedback` 新增 `itemIds`（預設空、進 `props`），所有發 feedback 的 handler 填受影響 id，批次新增填全部；bloc_test 補斷言（quick add、add、update、remove、fillExpiry、markOpened、useAll、partialUse、批次新增、過期處理完成）
- [ ] 3.7 在 `App` 層以 `RepositoryProvider`／`BlocProvider` 提供 `HapticService`、`SoundEffects`、`FeedbackPreferencesCubit`；`app_compiles_test` 仍通過

## 4. 頁面整合（等 `paper-receipt-ocr` archive 後）

- [ ] 4.1 食物清單主頁：`Scaffold.body` 改為 `FridgeFrame(child: AnimatedShelfList(rows: FridgeShelf.expand(state.sections, skin)), bottomBar: _QuickAddBar, overlay: ChihuahuaPeek)`；`BlocConsumer.listener` 改呼叫 `FeedbackChoreographer`；空狀態與錯誤狀態仍在外框內；`FoodItemGroupCard` 傳入 `FoodCharacter(56)`；widget test 更新（三態、三種分群、快速新增後列出現、`useAll` 後列離場、減少動態時直接更新）
- [ ] 4.2 詳情 sheet、使用 sheet、浪費 sheet：頁首 `FoodCharacter(72)` + 名稱 + `StatusChip`，sheet 背景套紙紋（頁面級 `BottomSheetTheme` 覆寫）；三個 sheet 的既有 widget test 通過並新增頁首斷言
- [ ] 4.3 過期處理頁：頂部 `_ExpiredIntroHeader`（`expiredProcessingHero` + `expiredProcessingIntro`）、每列 `FoodCharacter(40)`、背景紙紋；widget test 驗證預設未勾選與處理完成行為不變、頁首存在
- [ ] 4.4 表單頁：頁首 `FoodCharacter(96)` 隨 `type` 以 `AnimatedSwitcher(AppDurations.short)` 切換；widget test 驗證切換類型時角色跟著換、送出結果與現況相同
- [ ] 4.5 匯入回到清單：確認批次新增只發一個 `FoodItemFeedback(added, itemIds)`，`einvoiceImported` SnackBar 保留；widget test 驗證匯入 5 筆時 Recording 假物件只記到一次觸覺與一次音效、0 筆時沒有任何回饋
- [ ] 4.6 設定頁新增「回饋」區兩個開關接 `FeedbackPreferencesCubit`；widget test 驗證切換後 Cubit 狀態改變

## 5. l10n

- [ ] 5.1 `intl_zh.arb`／`intl_en.arb` 新增 `feedbackSection`、`soundEffects`、`hapticFeedback`、`expiredProcessingIntro`、`reactionHappy`、`reactionCelebrate`、`reactionNeutral`、`reactionNod`、`reactionSleepy`；`dart run intl_utils:generate`；en 版在設定頁與過期處理頁不截斷

## 6. 效能與清理

- [ ] 6.1 SM-T500 實機以 Dart MCP `launch_app` + DevTools Performance 錄 5 秒捲動（30 筆、6 層），UI 與 raster 每幀 ≤ 16 ms；超標時依 design D15 依序降紋理不透明度、關深色圓片、簡化進場，並記錄最終數值
- [ ] 6.2 `grep -rn "Colors\.\|Color(0x\|fontSize:\|'assets/" lib/pages lib/widgets` 無新增結果（`lib/theme/` 除外）；`node tool/sync_skills.cjs` 不需執行（未改 skills）
- [ ] 6.3 更新 `docs/art-asset-inventory.md` 的交接狀態與 README 功能清單（冰箱層架、回饋、設定開關）

## 7. 驗證

- [ ] 7.1 `dart format .`、`flutter analyze --no-pub`（0 error／0 warning，info 逐條回報）
- [ ] 7.2 `flutter test` 全綠（含新增的 theme、widgets、feedback、cubit、bloc_test、pages 測試）
- [ ] 7.3 `flutter build apk --debug` 通過
- [ ] 7.4 SM-T500 實機（先截圖確認食物頁在一般清單狀態，若被過期處理流程擋住則把裝置驗證留給使用者）：淺／深 × zh／en 各截食物頁、詳情 sheet、設定頁；逐一操作快速新增、全部使用、部分使用、標記浪費、補期限、標記開封、切換分群，確認視覺／觸覺／音效／角色反應與規格對應表一致；關閉音效與觸覺後再操作一次確認不出聲不震動；開啟系統「減少動態」確認無裝飾動畫且資料照常更新
- [ ] 7.5 `openspec validate --all --strict --no-interactive` 通過；`node .claude/hooks/stop-verify.cjs --manual` 通過並如實回報做了哪幾層、哪幾層沒做及原因
