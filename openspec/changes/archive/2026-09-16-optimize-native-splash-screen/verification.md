# Verification

## 2026-09-16

### Automated

- L0：`dart format .` 通過，209 files checked，0 files changed。
- L1：`flutter analyze --no-pub` 通過，`No issues found!`。
- L2：`flutter test` 通過，`585` tests passed。
- L3：`flutter test test/app_bootstrap_splash_test.dart` 通過，bootstrap surface 能找到品牌 `AssetImage`。
- L4：`flutter build apk --debug --no-pub` 通過，產出 `build/app/outputs/flutter-apk/app-debug.apk`。
- Android resource：`aapt2 dump resources` 確認 APK 含 `Theme.SplashScreen`、`windowSplashScreenBackground`、`windowSplashScreenAnimatedIcon` 與 `res/drawable/splash_illustration.png`。
- L6：`openspec validate --all --strict --no-interactive` 通過，20 items passed；本 change scoped validation 亦通過。
- Hook：`node .claude/hooks/stop-verify.cjs --manual` 通過。

### Runtime

- 裝置：Samsung SM-T500，Android 12（API 31），序號 `R9TR70VZACW`。
- force-stop 後冷啟動錄影保存於 `AgentAudit/genart/optimize-native-splash-screen-20260916/runtime/foodsavior-splash-androidx.mp4`。
- AndroidX starting surface 顯示品牌深綠背景；Flutter initialization 完成後，`androidx-after-init.png` 顯示未裁切的中央 Chihuahua／麵包插圖；等待後 `androidx-after-init-10s.png` 顯示既有 Food Savior App。
- 錄影最早可見幀是在 system splash icon 已退場後，故 native AndroidX icon 以 APK resource／build 作為 binding 證據；不把錄影誤宣稱為 native icon 的逐幀視覺證明。Flutter bootstrap 主圖則已有實機畫面證據。
- logcat 未發現 splash 相關 fatal exception。早期僅 platform API 31 attribute 的診斷截圖曾出現只有背景的情況，故保留 AndroidX 相容層與 Flutter bootstrap 作為修正。

### Boundary

- iOS build 與實機驗收未執行：目前環境為 Windows；已完成 LaunchScreen storyboard、LaunchImage 1x／2x／3x、尺寸與 RGBA alpha 靜態檢查。
- 未驗收 launcher icon、E/F 食物圖示與 App 內其他畫面；它們不在本 change 範圍。
