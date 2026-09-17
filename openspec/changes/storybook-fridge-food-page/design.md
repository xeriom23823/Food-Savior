## Context

現況（見 proposal.md 的 Why）：食物頁是 `Scaffold` + `ListView`，每個分群一個 `SectionHeader`、每個合併組一張 `Card` 包 `Slidable` 包 `FoodItemGroupCard`；底部 `_QuickAddBar`。回饋只有 `BlocConsumer.listener` 裡的 `AppSnackBar.show`（可帶 Lottie 或靜態插圖）。沒有任何觸覺、音效、Hero 或列進出場動畫；唯一的動畫是合併卡展開的 `AnimatedSize`。

約束：

- design-system 規格：pages／widgets 不得寫死顏色、字級、間距、資源路徑；狀態不可只靠顏色；三態齊全；動態走 `AppDurations`；尊重 `disableAnimations`。
- 資料層不動：Hive schema、Box、`FoodItem`、分群與排序邏輯全部沿用。
- 測試裝置 SM-T500（Snapdragon 662、Android 12）是使用者的日常裝置，Hive 裡是真實資料；效能與「不要替使用者處理他的食物」都是硬約束。
- `paper-receipt-ocr` change 尚在進行（37／40），同樣改 `food_item_list_page.dart` 與 `import_drafts_page.dart`。
- 美術由 Codex 的 imagegen 產出（既有流程：master 存 `AgentAudit/genart/<change>-<date>/masters/`，縮成 1x／2x／3x 入 `assets/`，紀錄寫入 `art-requests.md` 與 `docs/art-asset-inventory.md`）。Codex 不能產音效。

## Goals / Non-Goals

**Goals:**

- 「冰箱」是一組可重用的呈現元件（外框、層架、角色、角色反應），套在**既有的** `FoodItemListLoaded.sections` 上，不改 Bloc 的資料推導。
- 回饋是一條單向管線：`FoodItemFeedback` → 對應表 → 視覺／觸覺／音效／角色四個輸出；每個輸出可獨立關閉、可用假物件測試。
- 資料寫入永遠在動畫之前；列的進出場靠「畫面對舊新狀態做差異」而不是「延後派發事件」。
- 低階裝置上 60 fps 捲動；紋理是小圖重複貼、角色是小尺寸 PNG、每列零 Lottie。

**Non-Goals:**

- 不做通用動畫框架或主題切換系統；`StorybookTheme` 只服務食物頁及其子頁。
- 不做音效混音、音量控制、背景音樂。
- 不引入向量（SVG）執行時套件；角色與紋理一律 PNG。

## Decisions

### D1. 繪本質感進 `StorybookTheme` ThemeExtension，不新增 ThemeMode

- 新增 `lib/theme/storybook_theme.dart`：`StorybookTheme extends ThemeExtension<StorybookTheme>`，明暗各一組常數：`paperTexture`（asset 路徑）、`paperOpacity`、`interiorWall`、`interiorLight`、`shelfPlank`、`shelfPlankEdge`、`shelfGlow`、`frostTexture`／`frostTint`、`woodTexture`／`woodTint`、`stickerPaper`、`stickerInk`、`characterBackdrop`（深色圓片色；淺色為透明）。取用 `context.storybook`。
- 理由：符合「所有視覺數值來自 token」；食物頁與子頁共用一個來源；深色只需改一組值。
- 捨棄：第三個 `ThemeMode`（會影響全 App）；在頁面內 `switch (brightness)`（違反 token 規則）。

### D2. `FridgeFrame`：外框是版面，不是圖片

- `FridgeFrame({required child, required bottomBar, overlay})`：`Column[ _InteriorLight, Expanded(Row[ _Wall, Expanded(child), _Wall ]), bottomBar ]`，整體以 `Stack` 疊 `overlay`（給 `ChihuahuaPeek` 用）。
- 冰箱燈：一條 `AppSpacing.sm` 高的 `Container`，顏色 `interiorLight`，下方一個 `BoxShadow`（顏色 `shelfGlow`）當光暈——這是唯一允許的陰影用法，且顏色來自 token。內牆各 `AppSpacing.md` 寬、`interiorWall` 底色疊 `paperTexture`（`DecorationImage(repeat: ImageRepeat.repeat, opacity: paperOpacity)`）。
- 理由：外框由版面繪出，任何螢幕寬度、任何主題都成立，不需要 9-patch 或多張背景圖；內容寬度只少 `AppSpacing.md × 2`（規格上限為 `lg × 2`）。
- 捨棄：整張冰箱背景圖（不同螢幕比例會變形、深色需另一張、擋文字對比）。

### D3. `FridgeShelf` 是「列」的組合，不是巢狀容器

- 為了讓列能個別進出場（D6），層架**不**是包住多列的一個 widget，而是三種列：`ShelfLabelRow`（貼紙標籤）、`ShelfItemRow`（既有 `Card`+`Slidable`+`FoodItemGroupCard`）、`ShelfPlankRow`（架板，`CustomPainter` 畫板面、前緣、下方陰影線）。`FridgeShelf` 是把一個 `FoodListSection` 展開成這三種列的純函式加一組樣式（`ShelfSkin`）。
- `ShelfSkin` 由分群決定：急迫度 → `FoodStatusColors.of(status)` 當貼紙墨色＋狀態圖示；位置 → 依 `LocationKind`：`frozen` 疊 `frostTexture`＋`frostTint`、`ambient` 疊 `woodTexture`＋`woodTint`、`refrigerated` 預設、`other` 中性，並帶 `FoodItemVisuals.locationIconOf`；類型 → 標籤帶 `FoodCharacter(size: 24)`。
- 貼紙標籤：`stickerPaper` 底、`stickerInk` 文字、`AppRadius.sm` 圓角、文字不旋轉（可讀性優先）。筆數沿用 `itemCount`。
- 捨棄：`Sliver` 巢狀（`SliverAnimatedList` 不能跨 section 做移除動畫）；把架板畫在 `ShelfItemRow` 底部（列離場時架板會跟著飛走）。

### D4. `FoodCharacter` 與資源對照

- `FoodItemVisuals.characterAssetOf(FoodItemType)` 回傳 `assets/images/food_character_<name>.png`；`FoodCharacter({type, size})` 用 `Image.asset(..., cacheWidth: size × devicePixelRatio)`，深色主題外包 `characterBackdrop` 圓片。`FoodItemTile` 新增 `leading` 插槽（預設仍是現有的圓形 `FoodTypeIcon`），食物頁與子頁傳入 `FoodCharacter`，其他頁不傳。
- 尺寸：清單列 56 dp、批次展開列 40 dp、sheet 頁首 72 dp、表單頁首 96 dp、標籤 24 dp。資源出 64／128／192 px 三個變體（對應 1x／2x／3x 的 64 dp），表單頁首 96 dp 用 3x 圖縮放即可。
- 列高：`FoodItemTile` 由 `AppSpacing.md` 垂直 padding + 56 dp 角色 = 80 dp，超過規格 56–72 dp 上限；改成垂直 padding `AppSpacing.sm`，列高 72 dp。
- 捨棄：11 種 × 6 種狀態的表情圖（66 張，維護成本與規格「狀態不可只靠角色」衝突）。

### D5. 回饋管線：`FeedbackChoreographer` + `FeedbackCue`

```
FoodItemFeedback (Bloc state)
   └─> FeedbackChoreographer.on(feedback, context)
         ├─> FeedbackCue = mapCue(feedback)   // 純函式，單元測試
         ├─> HapticService.play(cue.haptic)   // 受 FeedbackPreferences.haptics 控制
         ├─> SoundEffects.play(cue.sound)     // 受 FeedbackPreferences.sound 控制
         ├─> ChihuahuaPeekController.show(cue.reaction)  // 受 disableAnimations 控制
         └─> ShelfMotion(itemIds, cue.motion) // 交給 AnimatedShelfList（D6）
```

- `FeedbackCue { HapticLevel? haptic; SoundCue? sound; ChihuahuaReaction? reaction; RowMotion motion; }`；`mapCue` 是純函式，輸入 `FoodItemFeedback`，對應表直接照 interaction-feedback 規格寫，單元測試逐行驗證。
- 匯入多筆：Bloc 對批次新增只發**一個** `FoodItemFeedback(kind: added, itemIds: [...])`，所以觸覺與音效自然只有一次。
- `HapticService`／`SoundEffects` 是抽象介面 + 真實實作 + `Recording` 假實作；以 `RepositoryProvider` 在 `App` 層注入，widget test 用假實作斷言呼叫序列。
- 「開冰箱門」音效與層架進場由 `FeedbackChoreographer.onFirstLoaded()` 觸發，以 App 生命週期內的靜態旗標（`SessionOnce`）保證每次啟動只一次。
- 捨棄：在 Bloc 裡發副作用（Bloc 不該知道觸覺與聲音）；每個 sheet 自己呼叫觸覺（會散落且難測）。

### D6. 列的進出場：畫面對新舊狀態做差異的 `AnimatedShelfList`

- 頁面把 `state.sections` 展開成 `List<ShelfRow>`（鍵：`label:<sectionKey>`、`item:<groupKey>`、`plank:<sectionKey>`；`groupKey` = 正規化名稱＋位置 id＋單位，與 `FoodItemGroup` 的合併鍵相同）。`AnimatedShelfList` 持有上一版 rows，收到新 rows 時以鍵做差異：被移除的鍵用 `AnimatedList.removeItem` 帶著**舊 widget** 播離場（`useAll` 縮小＋向右滑、`waste`／`removed` 向下滑＋淡出、其餘淡出）；新增的鍵 `insertItem` 播進場（自上方滑入）；留下的鍵若在 `feedback.itemIds` 內就播對應的原位動態（彈跳、蓋章、高亮）。
- 離場方向來自最近一次 `FeedbackCue.motion`；沒有 feedback 的差異（例如切換分群）一律淡入淡出。
- 資料流：Bloc 事件**立刻**派發，Hive 立刻寫；動畫完全由畫面差異驅動，因此 App 在動畫中被殺也不會遺失操作（interaction-feedback「回饋不改變資料結果」）。
- `disableAnimations` 時 `AnimatedShelfList` 把所有時長設為零。
- 捨棄：先播 `Slidable.dismiss()` 再派發事件（違反資料優先）；`implicitly_animated_list` 等套件（不新增 UI 套件）；`AnimatedSwitcher` 包整個 `ListView`（無法做單列動態）。

### D7. 音效：`audioplayers ^6.8.1` + `AudioPool`

- 套件：`audioplayers 6.8.1`（Flutter ≥ 3.44、Dart ≥ 3.6；`audioplayers_android` minSdk 19；iOS／macOS 無權限需求）。本專案 Flutter 3.47、minSdk 用 Flutter 預設（≥ 21）。
- 用法：`SoundEffects.ensureLoaded()` 在食物頁第一次 build 時以 `AudioPool.create` 預載 6 個 cue（每個 pool `maxPlayers: 2`）；`play(cue)` 即發即忘、`catchError` 靜默。`AudioContext`：Android `contentType: sonification`、`usageType: assistanceSonification`、`audioFocus: none`（不搶其他 App 音樂焦點）；iOS `category: ambient`（尊重靜音鍵、與音樂混音）。
- 格式：WAV 44.1 kHz 16-bit mono，每段 ≤ 1.5 秒、≤ 150 KB；Android 與 iOS 都原生支援，避免 OGG（iOS 不支援）與 MP3（短音效有起始延遲）。放 `assets/audio/`。
- 來源：CC0（例如 kenney.nl 的 Interface Sounds／UI Audio 包）——**下載前需使用者同意**；或使用者自備。Codex 不能產生音效。
- 捨棄：`just_audio`（面向串流與播放清單，短音效延遲較高、體積較大）；`flutter_soloud`（原生引擎、二進位大、對 6 個短音效過重）；`SystemSound.play`（只有 click／alert 兩種，且 Android 行為不一致）。
- 風險：`audioplayers_android` 在 AGP 9.1 + 內建 Kotlin 的相容性未驗證 → 加套件後立刻 `flutter build apk --debug`（tasks 1.x），失敗則退回只保留觸覺並把音效改為後續 change。

### D8. 觸覺：`HapticFeedback` 三級

- `HapticLevel { light, confirm, warning }` → `HapticFeedback.lightImpact`／`mediumImpact`／`heavyImpact`。Android 不需 `VIBRATE` 權限（走 `View.performHapticFeedback`），iOS 直接可用；桌面／Web 為 no-op。
- 由 `FeedbackPreferencesCubit.state.haptics` 控制；關閉時 `HapticService` 直接回傳。

### D9. `ChihuahuaPeek`：頁面 `Stack` 內的定位 widget，不用 Overlay

- `FridgeFrame.overlay` 放 `ChihuahuaPeek(controller)`：右下角、快速新增列上方、`IgnorePointer`；進場 `AppDurations.medium` 自下滑上、停留 1200 ms、退場 `AppDurations.medium`，總計 ≤ 1.7 秒（規格上限 2 秒）。`controller.show(reaction)` 若已有角色就重設計時器並換圖。
- 5 張靜態圖（happy／celebrate／neutral／nod／sleepy），`Semantics(image: true, label: S.reactionX)`。
- `disableAnimations` 時 `show` 為 no-op（既有 SnackBar 靜態插圖仍在）。
- 理由：`Stack` 比 `Overlay` 好測（widget test 直接 `find.byType`）、不會在頁面 dispose 後殘留。

### D10. 貼紙與冷光：只在列上做，成本固定

- 「蓋章」：`ExpiryCountdown`／`PendingExpiryBadge` 外包 `StickerStamp(trigger)`，`TweenAnimationBuilder` 從 scale 1.3、opacity 0 到 1／1，`AppDurations.medium`；`trigger` 由 `feedback.revision` 變化驅動，只有 `itemIds` 命中的列會動。
- 「冷光閃一下」：`ShelfPlankRow` 的 `CustomPainter` 多一個 `glow` 參數（0–1），由 `AnimatedShelfList` 在該 section 有新列時以 `AppDurations.long` 從 1 降到 0。
- 兩者都是隱式動畫，不佔用 ticker 常駐。

### D11. 紋理：三張 256×256 無縫小圖

- `paperTexture`（紙紋，低對比灰）、`frostTexture`（霜點）、`woodTexture`（木紋）；以 `DecorationImage(repeat)` 貼滿、不透明度由 token 控制（淺色 ≤ 0.08、深色 ≤ 0.05）。三張圖只載入一次；`RepaintBoundary` 包每一列。
- 對比驗證：在 `test/theme/storybook_contrast_test.dart` 以 token 值計算「紙紋最深像素疊在 surface 上」的合成色對 `onSurface` 的對比，斷言 ≥ 4.5。

### D12. Bloc 的唯一改動：`FoodItemFeedback.itemIds`

- 新增 `final List<String> itemIds`（預設空），所有發出 feedback 的 handler 填入受影響的 `FoodItem.id`；批次新增（匯入）填全部。`props` 加入。bloc_test 補斷言。
- 理由：畫面需要知道「哪幾列」該動，用 id 而不是名稱（同名批次可能多筆）。

### D13. `FeedbackPreferencesCubit`

- `state = FeedbackPreferences({sound: bool, haptics: bool})`，SharedPreferences key `soundEffectsEnabled`／`hapticFeedbackEnabled`，預設 true；`toggleSound()`／`toggleHaptics()`。在 `App` 層提供，設定頁與 `FeedbackChoreographer` 讀取。沿用 `ThemeCubit` 的模式與測試寫法。

### D14. 子頁面的最小侵入

- 詳情／使用／浪費 sheet：頁首加 `Row[ FoodCharacter(72), Expanded(名稱 + StatusChip) ]`，其餘不動；背景用 `StorybookTheme` 紙紋（透過 `BottomSheetTheme` 的頁面級覆寫，不改全域 theme）。
- 過期處理頁：`ListView` 頂部加 `_ExpiredIntroHeader`（插圖 + `expiredProcessingIntro`），每列 `SwitchListTile.secondary` 換 `FoodCharacter(40)`；處理完成後由清單頁的 feedback（`mixed`／`wasted`）給觸覺與音效。
- 表單頁：頁首 `FoodCharacter(96)` 跟隨 `type` 欄位，切換類型時 `AnimatedSwitcher`（`AppDurations.short`）；送出成功的回饋由清單頁 `added`／`updated` 管線負責，表單頁不自己發。
- 匯入草稿頁：不改頁面；`ImportRoute`／`ReceiptImportRoute` 回到清單後既有的 `einvoiceImported` SnackBar 保留，進場與觸覺由批次新增的 `FoodItemFeedback(added, itemIds)` 驅動。

### D15. 效能預算與量測

- 目標：SM-T500 上有 30 筆食物、6 層層架時，捲動 raster + UI 每幀 ≤ 16 ms、無 jank；首次進場動畫期間允許 ≤ 3 個掉幀。
- 手段：紋理小圖重複貼；角色 `cacheWidth`；每列 `RepaintBoundary`；`AnimatedShelfList` 只對差異列建動畫；角色反應與貼紙為隱式動畫。
- 量測：Dart MCP `launch_app` + DevTools Performance 錄 5 秒捲動；結果記入 tasks 的驗證節。任務順序刻意先做外框與層架並量測，再加角色與音效，超標時先降紋理不透明度或關閉深色圓片。

### D16. 美術製作流程與原創性守則

- 由 Codex imagegen 產出，prompt 與規格見 `art-requests.md`；master 存 `AgentAudit/genart/storybook-fridge-food-page-20260917/masters/`，縮成 `assets/images/{,2.0x/,3.0x/}`，回填 `art-requests.md` 與 `docs/art-asset-inventory.md`。
- 風格語彙：蠟筆／色鉛筆質感、粗而柔的深褐外框、暖色、半睜眼小嘴。**只借筆觸與表情語彙，不得重製《麵包小偷》或任何既有角色的造型**；每張入庫前人工核對「不是原作角色的變體」。
- 先以 3 張試作（麵包角色、蛋奶雙人組、吉娃娃開心探頭）確認方向，使用者點頭後才批次產 20 張。

## Risks / Trade-offs

- [紙紋與插畫降低文字對比] → token 不透明度上限 + `storybook_contrast_test` 自動驗證 + 實機明暗截圖。
- [SM-T500 捲動掉幀] → D15 預算與先量測再加料的任務順序；退路是降紋理、關深色圓片、把層架進場改為單次淡入。
- [音效惱人或在安靜場合出聲] → 預設開但 iOS 尊重靜音鍵、不搶音樂焦點；設定頁一鍵關閉；捲動與瀏覽永不出聲。
- [`audioplayers_android` 與 AGP 9.1／內建 Kotlin 不相容] → 加套件後立刻 L4 建置；失敗則音效降級為後續 change，本 change 其餘不受影響。
- [被誤認為抄襲《麵包小偷》] → D16 守則、角色全部是食物與品牌吉娃娃、art-requests 明寫禁止複製原作角色。
- [與 `paper-receipt-ocr` 改同一檔案衝突] → 本 change 先做 token／元件／服務層（不碰 `food_item_list_page.dart` 與 `import_drafts_page.dart`），頁面整合等該 change archive 後進行。
- [`AnimatedShelfList` 差異演算法出錯造成列重複或消失] → 以鍵為準的單元測試涵蓋插入、移除、移動、分群切換；並保留「差異失敗就整表重建」的保險路徑。
- [列高從 64 dp 變 72 dp，可見筆數變少] → 接受；仍在規格 56–72 dp 內，且角色是本次的核心價值。

## Migration Plan

- 無資料遷移。功能以一個 PR 整體上線；回滾即 revert。
- 設定 key 不存在時視為開啟，舊使用者升級後預設有音效與觸覺。
- 美術與音效資源缺失時：角色退回 `FoodTypeIcon`（`FoodCharacter` 內建 `errorBuilder`）、音效靜默、紋理不顯示——畫面仍完整可用。

## Open Questions

- 音效來源：使用 kenney.nl CC0 包（需使用者同意下載）或使用者自備 6 段 WAV？不影響規格與任務，只影響 tasks 2.x 的素材步驢。
- 貼紙標籤是否要帶極小角度（±1.5°）的手貼感？預設不旋轉；實機看過後再決定，不影響任務拆解。
- 過期處理完成後是否也讓吉娃娃探頭？規格目前依 feedback kind（`mixed`／`wasted`）自然涵蓋，若使用者覺得在該情境不合適可在對應表關掉，一行改動。
