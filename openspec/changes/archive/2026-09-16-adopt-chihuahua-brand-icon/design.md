## Context

pubspec 已以 assets/icons/food_savior_logo.png 產生 Android launcher_icon 與 iOS AppIcon；登入頁仍引用 Bloc 圖。v4 已獲使用者接受。

## Goals / Non-Goals

目標與範圍依 proposal；不調整其他頁面、主題或登入狀態。

## Decisions

- 保留既有來源路徑，複製 v4 為正式 PNG；舊圖先存 docs/art 供歷史查閱。
- 使用既有 flutter_launcher_icons，避免手動維護多尺寸與新增套件。
- 登入頁僅修改 Image.asset 路徑，保持 120 高度；無新增文字。
- Bloc、Repository、錯誤／離線／權限流程與資料流不變。
- 盤點文件新增已接受方向、正式路徑與 Claude 開發後再盤點的交接說明。

## Risks / Trade-offs

- 圖案占比較大：本次維持使用者接受的原圖，不再生成；實機驗證記錄實際外觀。
- Windows 無法執行 iOS build；產生圖不等於 iOS 實機驗收。
- Web／桌面圖示與 adaptive／splash 保留下一輪盤點。
