## Why

統計頁的「每月趨勢」以 `usedDate.month`（1–12）為鍵彙總點數，2025 年 12 月與 2026 年 12 月的資料會疊在同一點；使用超過一年後圖表就失真。使用者於 2026-09-15 決定改為年月粒度。

## What Changes

- 月趨勢改以「年月」彙總：從有資料的最早月份連續列到最晚月份，中間無資料月份補 0，最多顯示最近 12 個月；X 軸刻度標示 `yyyy/MM`。
- 彙總邏輯抽成純 Dart 函式 `monthlyTrend()`（`lib/statistics/monthly_trend.dart`），可單元測試；頁面只負責畫圖。
- 沒有任何紀錄時折線圖顯示 `noData` 而非空白（與圓餅圖一致）。
- 依 localization 規格，接觸到統計頁時把頁面內硬編碼字串改為 l10n（頁標題、三張卡片標題、`noData`）。
- **行為不變的部分**：食用線／浪費線的顏色與正負值語意、圓餅圖。

### 範圍上限

只動統計頁、一個新的純函式檔、ARB 新增 5 個 key；不新增套件。

### 非目標

- 統計頁版面重製、圖表色 token 化（留給 design-system-redesign 3.3）。
- 週／年等其他粒度切換。

## Capabilities

### New Capabilities

無。

### Modified Capabilities

- `statistics-charts`：月趨勢折線圖需求改為年月粒度、補 0、最多 12 個月、空資料提示。

## Impact

- **Code**：`lib/statistics/monthly_trend.dart`（新）、`lib/pages/char_and_statistics_page.dart`、`lib/l10n/intl_*.arb` 與產生物。
- **Tests**：`test/statistics/monthly_trend_test.dart`（跨年不疊加、補 0、12 個月上限、空清單）。
