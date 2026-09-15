## Context

`ThemeCubit` 已用 SharedPreferences 持久化明暗模式；`LocaleCubit` 沿用同一做法即可，維持兩者對稱，等 design-system-redesign 1.4 再一起抽成 `SettingsRepository`。

## Decisions

- **只存語言碼**（`zh`／`en`），還原時對應回 `supportedLocales` 中的完整 Locale。原因：設定頁 `DropdownButton<Locale>` 的 `value` 必須與 `DropdownMenuItem` 的 `Locale('en', 'US')`／`Locale('zh', 'TW')` 相等，若直接還原 `Locale('en')` 會觸發 Dropdown assertion。
- **可注入 `Future<SharedPreferences>`**（建構子參數），測試用 `SharedPreferences.setMockInitialValues`。
- **載入與使用者操作的競態**：若 `setLocale` 在非同步載入完成前被呼叫，載入結果不覆蓋使用者選擇（以 `_userHasChosen` 旗標判斷）。
- `isSupported(Locale)` 保留（以語言碼判定），供其他呼叫端使用。

## Risks

- 無資料遷移；舊版沒有此 key，首次啟動走預設。
