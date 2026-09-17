## 1. 替換與交接

- [x] 1.1 保存舊圖、替換正式 PNG、產生 Android／iOS 圖示，檢查圖檔及來源 hash。
- [x] 1.2 登入頁引用正式品牌圖，檢查 diff 僅資源路徑變更。
- [x] 1.3 更新盤點交接，記錄已接受 v4、延後其他素材直到 Claude 開發完成。

## 2. 驗證

- [x] 2.1 執行 stop-verify（format、analyze、flutter test）與 OpenSpec strict 驗證並記錄結果。
- [x] 2.2 Android debug APK 建置並檢查產生圖示。
- [x] 2.3 裝置檢視 launcher 與登入圖片明暗／zh／en（2026-09-16，SM T500 / Android 12，使用者授權登出後完成四種組合＋App 抽屜圖示；證據與方法見 verification.md）。iOS launcher 仍需 macOS，無法在本機執行。
