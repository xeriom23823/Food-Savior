## Why

目前 Android 啟動畫面仍使用白色／系統背景，iOS `LaunchImage` 是 1×1 透明佔位圖，品牌角色在 App 啟動期間不可見，且兩平台的視覺不一致。現在已確立 Food Savior 的黑褐 Chihuahua＋麵包品牌方向，應補上可安全縮放的原生 splash 主圖並完成平台 binding。

## What Changes

- 產出一張透明 RGBA 的 Food Savior splash 中央主圖，保留黑褐 Chihuahua、金色披風與抱麵包姿態，並加入跨平台安全留白。
- Android 使用品牌綠背景、夜間深綠背景及中央主圖，補上 Android 12+ system splash 資源設定。
- iOS `LaunchScreen.storyboard` 使用品牌綠背景與同一中央主圖，更新 `LaunchImage.imageset` 的 1x／2x／3x 衍生檔。
- 在既有 async 初始化期間先繪製同一品牌主圖的 Flutter bootstrap surface，避免 Android 12 system splash 退場後到 App 首幀前顯示空白。
- 保存生成母檔、原始 iOS 佔位圖與尺寸／alpha／binding 記錄，供後續美術交接。
- **非目標**：不修改 launcher icon、登入頁、Firebase／Auth／Hive 初始化順序、App 內頁、動畫、資料模型、Bloc、l10n 或其他 E/F 美術項目。
- **範圍上限**：0 頁、0 資料欄位、Android／iOS 原生啟動資源、1 個 AndroidX 原生依賴；桌面／Web 不做 UX 驗收。

## Capabilities

### New Capabilities

無。這是原生啟動畫面資源與設定的視覺交付，不新增 App 行為能力。

### Modified Capabilities

無。以 `skip_specs: true` 記錄為不改變規格的資源／平台設定變更。

## Impact

影響 `android/app/src/main/res/`、`android/app/build.gradle`、`android/app/src/main/kotlin/`、`ios/Runner/Base.lproj/LaunchScreen.storyboard`、iOS `LaunchImage.imageset`、`AgentAudit/genart/`、美術盤點與 OpenSpec 任務文件。新增 AndroidX `core-splashscreen:1.0.1`；無 pubspec 套件、Hive／Firestore、Bloc、l10n 或平台權限變更。Windows 無法執行 iOS build，iOS 需保留靜態資源檢查並標示未做 runtime 驗收。
