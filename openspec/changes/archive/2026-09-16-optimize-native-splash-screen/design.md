## Context

目前 Android `LaunchTheme` 只引用 `launch_background.xml` 的白色／系統背景，Android 12+ 沒有明確的 system splash icon 設定；iOS storyboard 雖引用 `LaunchImage`，但 1x／2x／3x 都是 1×1 全透明佔位圖。現有品牌母圖是滿版綠底 RGB PNG，不適合直接當跨平台中央 splash 素材。

## Goals / Non-Goals

**Goals:**

- 產出一張有真實 alpha、四周保留安全區的中央角色圖，供兩平台共用。
- 以原生資源完成 Android 舊版／Android 12+ 與 iOS 的品牌綠背景和中央圖 binding。
- 在 async 初始化期間以同一張 Flutter bootstrap surface 延續品牌視覺，避免 native splash 退場至 App 首幀之間出現空白。
- 明暗模式有不同背景色，角色仍保持足夠對比；不把平台裁切規則交給 Flutter widget。
- 保存母檔、衍生尺寸、原始佔位圖與靜態檢查結果，並以 Android debug build／實機冷啟動確認。

**Non-Goals:**

- 不引入 `flutter_native_splash` 或其他 Flutter splash 套件；原生端只新增 AndroidX `core-splashscreen:1.0.1` 相容層。不調整 Firebase／Auth／Hive 初始化順序；Flutter bootstrap 只負責靜態首幀，不持有或改寫初始化狀態。
- 不改 launcher icon、登入頁、App 內畫面、動畫、資料模型、Bloc、l10n 或 E/F 圖示。
- Windows 不執行 iOS build；iOS 本次只做資源與 storyboard 靜態檢查。

## Decisions

### 1. 透明中央主圖 + 原生純色背景

使用 imagegen 以已接受的黑褐 Chihuahua＋金色披風＋抱麵包方向產出透明 RGBA PNG，再以腳本在外層增加安全留白。Android／iOS 各自提供品牌綠背景；這比把綠底烘焙進圖片更容易維持裁切穩定、夜間切換和日後換背景。

替代方案：直接重用 `food_savior_logo.png`。放棄原因是它是 RGB 滿版綠底、角色占比過大，Android 12 system splash 可能裁切耳朵／披風；也不適合 iOS storyboard 的透明疊合。

### 2. Android 分層資源與 API 31 override

`drawable/launch_background.xml` 與 `drawable-v21/launch_background.xml` 使用品牌色 layer-list 和中央 bitmap；`LaunchTheme` 改用 AndroidX `Theme.SplashScreen`，以 `windowSplashScreenBackground`、`windowSplashScreenAnimatedIcon`、`postSplashScreenTheme` 由 `installSplashScreen()` 接管 Android 12+ 與舊版相容路徑。色彩集中在 `colors.xml`／`values-night/colors.xml`，不依賴 Flutter assets。

替代方案：只使用 platform API 31 attribute。放棄原因是 SM T500 的 starting surface 對目前 legacy Flutter theme 沒有穩定呈現中央 icon；AndroidX `core-splashscreen:1.0.1` 是官方相容層，且只增加一個小型原生依賴。

### 3. iOS storyboard 保持系統啟動流程

保留 `LaunchScreen.storyboard` 的中央 image view 和 `LaunchImage` 名稱，只將背景改成品牌綠並把 1x／2x／3x 佔位圖替換為相同母檔的正方形衍生檔；文字不烘焙在圖片內，避免多語與小尺寸模糊。

替代方案：只把圖片放進 Flutter-level surface。放棄原因是它不能改善 process 啟動前的空白階段，因此仍需保留原生 storyboard 作為第一段啟動畫面。

### 4. Flutter bootstrap surface 僅作首幀銜接

在 `main()` 完成 `WidgetsFlutterBinding.ensureInitialized()` 後立即 `runApp(const BootstrapSplash())`，再照原順序等待 Firebase、Auth、Hive 與資料載入，準備完成後以既有 `App` 取代它。surface 使用 `AppTheme`、`AppAssets` 與 `AppIllustrationSize` token，沒有登入狀態、Repository 或 Bloc；因此不會改變初始化資料流，只補足 Android 12 system splash 過早退場時的可見畫面。

替代方案：只依賴 API 31 `windowSplashScreenAnimatedIcon`。實機診斷在 async 初始化期間觀察到只剩背景，無法穩定覆蓋整段等待時間，因此不足以完成本需求。

## Risks / Trade-offs

- [Android 12 system icon 會依 OS 規則縮放或加遮罩] → 主圖保留透明安全區，並以 API 31 resource override 與實機冷啟動截圖確認不裁切。
- [生成圖的半透明邊緣在深綠背景上可能產生白邊] → 檢查 alpha extrema、在品牌綠／夜間深綠合成預覽後再入庫。
- [Windows 無法編譯 iOS] → 以 storyboard／asset catalog／PNG 尺寸與 alpha 靜態檢查，明確不宣稱 iOS runtime 通過。
- [原生資源命名或 API 31 attribute 錯誤會在 build 才暴露] → 執行 `flutter build apk --debug --no-pub`，失敗時只回滾 splash 相關 XML／圖片。

## Migration Plan

1. 在 `AgentAudit/genart/design-system-redesign-20260916/` 保存原始 iOS 佔位圖、imagegen 母檔與合成預覽。
2. 產生 production PNG，複製到 Android drawable、iOS LaunchImage 及資產盤點需要的 `assets/images/`。
3. 修改 Android／iOS 原生 splash binding，執行資源檢查與 debug APK build。
4. 對測試 Android 裝置做 force-stop 後冷啟動截圖與 runtime error 檢查。
5. 若需 rollback，恢復 audit 中的 XML、storyboard 與 iOS 1×1 佔位圖；不影響 Flutter 資料或使用者狀態。
