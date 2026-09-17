# Food Savior 美術資源盤點與製作建議

## 2026-09-16 原生 Splash 入庫（目前狀態）

- 已依黑褐 Chihuahua 品牌方向產出 `splash_illustration`：透明 RGBA 交付母檔位於 `AgentAudit/genart/optimize-native-splash-screen-20260916/masters/splash_illustration_master.png`，角色主體約佔 58%，保留跨平台安全留白。
- Flutter 盤點輸出：`assets/images/splash_illustration.png`、`assets/images/2.0x/splash_illustration.png`、`assets/images/3.0x/splash_illustration.png`；原生 consuming resources 分別為 Android `res/drawable/splash_illustration.png` 與 iOS `LaunchImage.imageset` 的 1x／2x／3x。
- Android 已改為品牌綠 `#3E8E5A`、夜間深綠 `#1F4D31`，以 AndroidX `Theme.SplashScreen`／`windowSplashScreenAnimatedIcon` 接通 Android 12+，並由 Flutter `BootstrapSplash` 銜接長初始化；iOS storyboard 已改為品牌綠並使用同一主圖系列。
- 原生預覽保存於 `AgentAudit/genart/optimize-native-splash-screen-20260916/previews/`；實機與 build 驗收以 `openspec/changes/optimize-native-splash-screen/` 的任務及證據為準。

## 交接狀態：黑褐吉娃娃已接受，後續美術待開發完成再盤點

- 使用者已接受 v4 黑褐吉娃娃：保留黑褐毛色、兩塊獨立眉斑、金黃披風、抱麵包姿態與溫暖繪本風格。
- 正式來源為 `assets/icons/food_savior_logo.png`；Android／iOS 圖示由 `dart run flutter_launcher_icons` 產生，登入頁共用此圖。
- 使用者接下來先使用 Claude 開發功能；待開發完成，再依實際畫面及最新規格重新盤點與產出美術。下方資源清單保留為待辦，不表示要立即製作，也不用重新選圖示方向。
- 下次優先：檢查新畫面與三態 → 核對資源是否已被開發取代 → 排列空狀態／動畫／新功能插圖 → 分批生成與實際畫面驗收。
- v2／v3／v4 與原始圖保存於 `docs/art/`；實作與驗證見 `openspec/changes/adopt-chihuahua-brand-icon/`。
- 以下為替換前的盤點與探索紀錄，遇到狀態矛盾時以本節最新交接為準。

盤點日期：2026-09-15。依據目前檔案、程式引用、主規格與尚未完成的 `design-system-redesign` change。

這是資源盤點與建議，不是新增功能的規格承諾。沒有改動 App 或替換現行素材；真正實作時依 OpenSpec 流程辦理。使用者後續要求重新生成 App 圖示，已用內建 image_gen 產出 [v2 候選圖](art/food-savior-app-icon-v2.png)，生成紀錄與完整 prompt 見 [圖示紀錄](art/food-savior-app-icon-v2.md)，尚未套用到 App。

## 結論

最新配色修訂：[v4 黑褐吉娃娃](art/food-savior-app-icon-v4.png)，依使用者照片採黑色主毛與兩塊獨立棕褐眉斑，保留披風與抱麵包姿態；[生成紀錄](art/food-savior-app-icon-v4.md)。尚未整合正式 launcher。

後續圖示方向：使用者要求加入吉娃娃、Savior 與《麵包小偷》的繪本感，已產出 [v3 吉娃娃食物守護者](art/food-savior-app-icon-v3.png)；詳見 [生成紀錄](art/food-savior-app-icon-v3.md)。此方向優先於下文最初的品牌探索建議，尚未整合正式 launcher。

現有素材足以支撐功能原型；最值得先補的是品牌一致性、空狀態與素材交付規範。11 種食物圖示、一般操作圖示、字型皆可沿用，不必先製作大量食材照片或角色動畫。

設計讀法：一般家庭每天快速查看食物期限的工具，清爽、可靠、有一點溫度。設計重製已選沉穩綠 seed `#3E8E5A`、暖黃強調；這是待落地的設計決策，不能當作現行畫面已完成。

## 1. 已有資源

| 資源 | 數量／位置 | 使用情形與處置建議 |
|---|---|---|
| 品牌候選主圖 | `assets/icons/food_savior_logo.png`，1024 × 1024 PNG | 青綠色犬形角色與碗，有白底；作為 launcher 產生來源。可以保留角色概念，但宜補小尺寸簡化版、去底版、單色版與可編輯母檔。青綠配色與新主題的關係需要定義。 |
| 登入頁圖片 | `assets/bloc_logo_small.png` | `lib/login/view/login_form.dart` 仍引用 Bloc 立方體標誌。應改用 Food Savior 品牌資源。 |
| Android launcher | `android/app/src/main/res/mipmap-*` | 5 個密度的 `launcher_icon.png`，Manifest 實際引用此名稱；另有 5 個 `ic_launcher.png`。抽看實際 launcher 為犬形角色。未見 adaptive foreground/background 或 monochrome 資源。 |
| iOS AppIcon | `ios/Runner/Assets.xcassets/AppIcon.appiconset`，21 個 PNG | 抽看 1024 圖為同一犬形角色；這是尺寸衍生檔，不是 21 件獨立創作。未逐尺寸驗收。 |
| Web／macOS 圖示 | Web 4 個 icon 加 favicon；macOS 7 個 PNG | 抽看 Web 192 與 macOS 128 仍是 Flutter 標誌；平台不是 UX 優先，但可由同一品牌母檔統一產生。 |
| 啟動畫面 | Android `launch_background.xml`、AndroidX `Theme.SplashScreen`／Flutter `BootstrapSplash`；iOS `LaunchScreen.storyboard` / `LaunchImage.imageset` | 已綁定 `splash_illustration` 與品牌綠／夜間深綠背景；Android 實機冷啟動與 iOS runtime 仍依本 change 的驗證結果記錄。 |
| 食用動畫 | `assets/animations/eating.json` | 280 × 280、60 fps、3 秒、約 16.4 KiB；食物頁有引用。可先沿用，需另驗動畫風格、明暗背景與減少動態時的替代圖示。 |
| 丟棄動畫 | `assets/animations/dumping.json` | 720 × 792、60 fps、約 4.98 秒、約 56.2 KiB；食物頁有引用。需檢查縮小後可讀性與情緒是否過度責備；本次未播放。 |
| 食物類型圖示 | `lib/models/food_item.dart`，11 種 Font Awesome | 已完整對應固定類型；重製 design 明確暫時接受，不需本輪重畫。 |
| 導覽／操作圖示 | Material Icons、部分 Font Awesome | 五分頁、編輯、刪除、日期、設定等已有。優先統一尺寸與視覺重量，不必各畫一份。 |
| 頭像 | `lib/widgets/avatar.dart` | 使用網路頭像，沒有照片時用 `person_outline`。已有可用 fallback，客製頭像非必要。 |
| 字型 | NotoSansTC Regular／Bold，2 個 OTF | 已在 pubspec 宣告，合計約 11.2 MiB；可沿用。體積優化屬後續工程評估。 |

`assets/` 共有 6 個檔案：2 PNG、2 Lottie JSON、2 OTF。平台衍生圖示另計。未找到 SVG、Figma、AI、PSD、Sketch 母檔，也未找到逐素材的來源與授權清冊；根目錄有 `license`，不能據此確認每件外部素材的出處。

### 食物圖示對照

| 類型 | 現有 Font Awesome 圖示 |
|---|---|
| 蔬菜 | carrot |
| 水果 | appleWhole |
| 肉類 | drumstickBite |
| 蛋奶 | egg |
| 海鮮 | fish |
| 罐頭 | jar |
| 熟食 | bowlFood |
| 飲料 | mugSaucer |
| 零食 | cookieBite |
| 麵包 | breadSlice |
| 其他 | utensils |

未來若做專屬圖示，應一次完成 11 種且保留列舉映射；優先改善「蛋奶只畫蛋」及「罐頭用罐子」的辨識度。這是可選升級，不是目前功能缺口。

## 2. 建議補齊：目前產品

P0：優先確立；P1：配合 UI 重製；P2：功能推出或上架時製作。

| 優先 | 資源包 | 建議內容／數量 | 用途與界線 |
|---|---|---|---|
| P0 | 品牌基本包 | 1 套：主標誌、簡化小圖、單色版、透明底版、明暗背景示例、中英名稱組合 | 登入、App icon、關於、文件共用。先決定犬形角色要保留／簡化到什麼程度，再大量衍生。文字與圖像分離，避免多語被鎖進圖片。 |
| P0 | 平台圖示／啟動包 | 從品牌母檔衍生 Android／iOS 圖示、Android 分層與單色素材、靜態啟動標誌；Web／桌面順帶更新 | 屬同一套設計的工程輸出，不按解析度重複計創作數量。平台尺寸與裁切規則於交付前核對當時官方要求。 |
| P1 | 空狀態插圖 | 3 張：尚未加入食物、所選日期沒有紀錄、尚無統計資料 | 建議簡單冰箱／收納盒、紀錄本、圖表意象。空狀態規格允許圖示；插圖是品質提升，不是規格硬性要求。勿把「目前沒有食物」畫成「全部拯救成功」。 |
| P1 | 狀態圖示規範 | 5 種：新鮮、快過期、已過期、已食用、已浪費 | 用既有圖示搭配語意色與文字即可；沒有必要新增 5 個點陣圖。 |
| P1 | 完成回饋整理 | 檢視現有 2 個 Lottie，配 2 個靜態替代圖示 | 先檢視後決定是否重製。成功回饋輕量，丟棄採中性記錄語氣；動畫停用時仍看得懂結果。 |
| P1 | 共用異常／載入呈現 | 錯誤、重試、備份／還原狀態各定義圖示與元件樣式 | 以 Material 圖示和進度元件處理；本機載入失敗不可畫成「網路中斷」。無需大型錯誤插畫或 loading 動畫。 |
| P1 | 點數識別 | 可選 1 個簡單「食物點數」符號 | 點數總覽可用；現行沒有勳章收藏或等級機制，先不做徽章系列。 |
| P2 | 商店與說明圖片 | 建議先規劃 5 個畫面主題：清單、記錄食用、紀錄、統計、設定；再依 zh／en 產出 | UI 穩定後用真實 App 截圖組版。商店宣傳圖依目標平台交付規範另出；尚未實作功能不出現在宣傳承諾中。 |

## 3. 隨 roadmap 準備的素材

以下對應未來功能，並不表示現在已實作，也不應提前塞進現有 UI。

| 功能 | 建議素材 | 可共用或免畫的部分 |
|---|---|---|
| 過期提醒 | 1 個通知用單色識別；可選 1 張提醒說明小插圖 | 權限被拒用系統圖示與設定入口，不需每種權限各畫一張。 |
| 條碼／電子發票 | 可選 2 張操作示意：商品條碼、發票 QR 位置 | 掃描框以元件繪製；說明圖用無真實個資的示例，避免把示意碼呈現為正式可掃資料。 |
| 載具綁定 | 可選 1 張載具位置或綁定說明圖 | 錯誤、載入與成功沿用共用元件。 |
| 雲端同步 | 雲端／同步中／成功／離線／失敗的圖示映射 | 優先 Material Icons；不需 5 張插畫。 |
| AI 料理推薦 | 可選 1 張推薦空狀態、1 張料理卡通用封面 | 先用通用料理意象或分類圖示；尚不確定圖片來源與成本前，不建大型逐菜照片庫。 |

## 4. 製作順序與範圍

1. 定義品牌基本包及插畫筆觸：沉穩綠、暖黃少量點綴；角色細节縮減到小尺寸仍可辨識。犬形角色是否延續屬待定方向，本盤點不替使用者定案。
2. 由同一母檔產生登入、平台圖示、啟動畫面所需版本。
3. 做 3 張空狀態插圖；沿用現有 11 種分類圖示與 Material 操作圖示。
4. 播放現有 2 個 Lottie 並在實際回饋容器中審查，必要時才重製。
5. UI 穩定後擷取真實畫面，製作商店圖與 README 圖片。
6. 通知、掃描、同步、AI 素材跟隨各自 change 製作。

第一輪建議預算範圍：**1 套品牌基本包 + 3 張空狀態插圖 + 既有 2 個動畫檢視／修整**。平台尺寸為衍生輸出；點數符號可選。不需同時投入 11 種客製食物圖示、數十張食材照片、角色表情全集或成就徽章。

## 5. 素材交付要求

- 每件資源記錄 ID、用途、原始作者／來源、授權條款、可否修改、母檔、輸出版本與使用頁面。
- 品牌與圖示優先留可編輯向量母檔；Flutter 當前未宣告 SVG 顯示套件，執行時格式需依既有能力決定，不為盤點先加依賴。
- 插圖提供乾淨透明背景、足夠留白，文字由 l10n 顯示；同時檢視明暗 surface，不把白底當透明。
- 24 dp 圖示與實際插圖容器都要看；大型原圖漂亮不代表縮小後可辨識。
- Lottie 提供靜態替代、播放設定與背景適配說明；確認不依賴遺失的外部圖片或字型。
- 狀態不可只靠顏色；減少動態設定需保留靜態回饋。
- 最終 UI 在明／暗、zh／en、360 × 640 與 412 × 915 檢視。素材檔檢查不能替代實機驗收。

## 6. 盤點證據與限制

- 已讀取 `pubspec.yaml`、`lib` 素材引用、11 類型映射、Android Manifest／啟动資源、iOS storyboard、README、主規格與設計重製文件。
- 已直接查看品牌原圖、登入 Bloc 圖、Android launcher 代表尺寸、iOS 1024 圖、Web 192 圖、macOS 128 圖。
- Lottie 僅解析尺寸、影格率、時間與引用；沒有播放驗收。其他平台尺寸未逐一視覺檢查。
- 本次不包含 App 操作或明暗／多語截圖。後續新增了 App 圖示 v2 候選圖，其餘新增資源數量都是建議。
- 已依 flutter-verification skill 執行 `node .claude/hooks/stop-verify.cjs --manual`：L0 格式／L1 analyze（無 error、warning）／測試對應／L2 flutter test 通過。L3 未獨立執行；L4 建置、L5 實機、L6 規格驗證未執行，因本次僅新增盤點文件與候選圖片，沒有修改 UI 或 archive change。
