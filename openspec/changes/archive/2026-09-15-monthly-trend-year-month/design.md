## Context

彙總邏輯目前寫在頁面 `State` 的私有方法裡，無法測試；同時是頁面含商業邏輯的違規樣板。

## Decisions

- **純函式 `monthlyTrend(Iterable<UsedFoodItem>, {int maxMonths = 12})`** 回傳 `List<MonthlyTrendPoint>`（`year`、`month`、`consumed`、`wasted`、`label`），依時間排序、補 0、截到最近 `maxMonths` 個月。放在 `lib/statistics/`，不依賴 Flutter。
- **X 軸用索引 0..n-1** 當 `FlSpot.x`，刻度文字從 `_monthlyTrend[i].label` 取，避免 fl_chart 以 `year*12+month` 當 x 造成刻度稀疏；`interval: 1`，超過 6 個點時每隔 `ceil(n/6)` 個顯示一個標籤，避免重疊。
- **浪費線維持負值**（現行語意），不取絕對值。
- **l10n**：新增 `chartAndStatisticsPageTitle`、`consumedFoodPointsByType`、`wastedFoodPointsByType`、`monthlyTrend`、`noData`；`pubspec.yaml` 補上 `flutter_intl` 設定讓 `dart run intl_utils:generate` 可用（先前產生流程只靠 IDE 外掛）。

## Risks

- `intl_messages.arb` 被 intl_utils 視為一個叫 `messages` 的語系（既有現象，產生 `messages_messages.dart`），本 change 同步在該檔加 key 以免缺 key 警告；是否移除該檔留給之後。
