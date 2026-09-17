# Splash Screen 美術需求與入庫紀錄

## 2026-09-16 產出

| 欄位 | 內容 |
|---|---|
| Asset ID | `splash_illustration` |
| 用途 | Android／iOS 原生啟動畫面中央主圖；不含文字，避免 zh-TW／en 被鎖在圖片內 |
| 視覺 | 已接受的黑褐 Chihuahua、兩塊獨立眉斑、金色披風、抱麵包姿態、溫暖繪本筆觸 |
| 原始生成 | imagegen 新生成；以 `docs/art/food-savior-app-icon-v4.png` 作為角色方向參考 |
| 生成母檔 | `AgentAudit/genart/optimize-native-splash-screen-20260916/masters/splash_illustration_imagegen.png` |
| 清理母檔 | `AgentAudit/genart/optimize-native-splash-screen-20260916/masters/splash_illustration_cutout.png` |
| 交付母檔 | `AgentAudit/genart/optimize-native-splash-screen-20260916/masters/splash_illustration_master.png`，2048 × 2048 RGBA |
| Safe area | 角色主體約佔交付母檔 58%；耳朵、披風、麵包完整落在透明留白內 |
| Flutter 盤點輸出 | `assets/images/splash_illustration.png` 320 × 320、`2.0x` 640 × 640、`3.0x` 960 × 960 |
| Android consuming path | `android/app/src/main/res/drawable/splash_illustration.png`；legacy `launch_background.xml` 與 AndroidX `Theme.SplashScreen`／`windowSplashScreenAnimatedIcon` 使用 |
| iOS consuming path | `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png`、`@2x`、`@3x`；`LaunchScreen.storyboard` 使用 |
| 背景 | Android／Flutter 預覽 `#3E8E5A`；Android night `#1F4D31`；iOS storyboard `#3E8E5A` |
| 預覽 | `AgentAudit/genart/optimize-native-splash-screen-20260916/previews/splash-preview-light.png`、`splash-preview-dark.png` |

## QC 與界線

- imagegen 原始輸出保留於 audit；其棋盤格背景被視為烘焙 RGB，不直接交付，已另做去背與 alpha 檢查。
- 交付檔全部為 PNG RGBA，alpha extrema 為 `(0, 255)`；iOS 原先的 1×1 全透明佔位圖保存於 `AgentAudit/.../preexisting/`。
- 新增 AndroidX `androidx.core:core-splashscreen:1.0.1` 原生依賴與極薄 Flutter `BootstrapSplash` 首幀 surface；未改資料模型、Bloc、l10n 或權限，也未變更 launcher icon 與 E/F 圖示。
- Android debug APK build、Flutter bootstrap widget test 與 SM T500 實機冷啟動均通過；`androidx-after-init.png` 可見中央主圖，`androidx-after-init-10s.png` 可見既有 App，且 logcat 無 splash 相關 fatal error。
- Windows 無法執行 iOS build／實機驗收；iOS 僅完成 storyboard／asset catalog／PNG 尺寸與 alpha 靜態檢查。
