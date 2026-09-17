## Why

使用者已接受黑褐吉娃娃 v4，要求替換現行圖示並保留美術計畫，待 Claude 功能開發完成再盤點。讓 App launcher 與登入頁使用相同品牌圖，驗證替換後資源可載入且能正常建置。

## What Changes

- 以已接受 v4 替換品牌 PNG，沿用 flutter_launcher_icons 產生 Android／iOS 圖示。
- 登入頁改引用品牌圖，保留原尺寸與登入流程。
- 保存歷史圖與美術交接計畫。
- 非目標：新插圖、動畫、adaptive icon、啟動畫面重製、其他功能開發。
- 範圍上限：1 頁、0 資料欄位、Android／iOS launcher、0 新套件。

## Capabilities

### New Capabilities

無。

### Modified Capabilities

無。僅視覺資源替換，現有行為規格不變，設定 skip_specs。

## Impact

影響 assets/icons、Android／iOS 衍生圖、login_form 與交接文件；Hive、Firestore、Bloc、l10n、權限均無變更。
