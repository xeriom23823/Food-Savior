## 1. 實作

- [x] 1.1 `lib/statistics/monthly_trend.dart`：`MonthlyTrendPoint` 與 `monthlyTrend()`（年月鍵、補 0、最近 12 個月）
- [x] 1.2 `test/statistics/monthly_trend_test.dart`：跨年不疊加、補 0、12 個月上限、空清單、食用／浪費分開加總
- [x] 1.3 統計頁改用 `monthlyTrend()`；X 軸索引 + `yyyy/MM` 刻度；空資料顯示 `noData`
- [x] 1.4 l10n：新增 5 個 key 到 `intl_zh.arb`／`intl_en.arb`／`intl_messages.arb`，補 `flutter_intl` 設定並重新產生；頁面硬編碼字串全部改為 `S.of(context)`

## 2. 驗證

- [x] 2.1 `dart format`、`flutter analyze --no-pub`（0 issue）
- [x] 2.2 `flutter test` 全綠
- [x] 2.3 `openspec validate --all --strict --no-interactive`
- [ ] 2.4 實機：有跨年紀錄時折線圖 X 軸顯示 `yyyy/MM`；zh／en 切換後卡片標題跟著變（待使用者回到電腦）
