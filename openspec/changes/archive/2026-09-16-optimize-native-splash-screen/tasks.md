## 1. 美術資產

- [x] 1.1 保存現有 iOS `LaunchImage` 佔位圖與生成母檔，產出透明 RGBA splash 主圖並驗證四周安全留白、alpha 與品牌綠／夜間深綠合成預覽
- [x] 1.2 產生 Android drawable、iOS LaunchImage 1x／2x／3x 與 Flutter 盤點用 PNG，驗證尺寸、格式與檔案可讀

## 2. Android binding

- [x] 2.1 將品牌綠／夜間深綠與中央主圖接入 legacy `launch_background.xml`／`drawable-v21`，驗證 resource 引用完整
- [x] 2.2 加入 AndroidX `core-splashscreen:1.0.1`，以 `Theme.SplashScreen`／`installSplashScreen()` 接通 `windowSplashScreenBackground`、`windowSplashScreenAnimatedIcon`、`postSplashScreenTheme`，以 Android debug APK build 驗證資源可編譯
- [x] 2.3 在 async 初始化前繪製 tokenized Flutter bootstrap surface，驗證既有初始化順序不變且 widget test 能找到品牌圖片

## 3. iOS binding 與文件

- [x] 3.1 將 `LaunchScreen.storyboard` 背景與中央圖片更新為新資產，驗證 storyboard、asset catalog 與 1x／2x／3x 檔案一致
- [x] 3.2 更新 `art-requests.md`、`docs/art-asset-inventory.md` 與 change 證據，明確記錄用途、母檔、輸出、原生 consuming path 與未做 iOS runtime 的界線

## 4. 驗證

- [x] 4.1 執行 `dart format .`、`flutter analyze --no-pub`、`flutter test` 與 `openspec validate --all --strict --no-interactive`，如有既有無關 change 阻擋需分開記錄
- [x] 4.2 在 Android 實機 force-stop 後冷啟動，檢查 splash 不裁切、品牌背景正確且無 runtime error；記錄 iOS 因 Windows 無法 build／實機驗收
- [x] 4.3 執行 `node .claude/hooks/stop-verify.cjs --manual`，保存最終通過／阻擋證據並確認 change 任務與 git diff 範圍
