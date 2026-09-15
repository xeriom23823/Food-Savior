## Why

使用者在設定頁切換語言後，App 重新啟動就回到預設的繁體中文，因為 `LocaleCubit` 只把選擇放在記憶體。深色模式早已持久化，語言卻沒有，是既有設定頁的一致性缺口；使用者於 2026-09-15 決定補上。

## What Changes

- `LocaleCubit` 將語言選擇寫入 SharedPreferences（key `localeLanguageCode`，只存語言碼 `zh`／`en`），啟動時還原。
- 還原時一律對應回專案支援的完整 Locale（`zh_TW`、`en_US`），確保設定頁 Dropdown 的 value 與選項相符。
- 不支援的語系維持忽略，且不寫入。
- **行為不變**：預設語系仍為 zh_TW；切換仍立即生效。

### 範圍上限

只動 `lib/cubits/locale_cubit.dart` 與其測試；不新增套件、不改 UI。

### 非目標

- 跟隨系統語系（system locale）。
- 把 SharedPreferences 存取抽成 `SettingsRepository`（留給 design-system-redesign 1.4 一併處理 ThemeCubit 時）。

## Capabilities

### New Capabilities

無。

### Modified Capabilities

- `app-settings`：語言切換需求加入持久化與重啟還原。

## Impact

- **Code**：`lib/cubits/locale_cubit.dart`。
- **Tests**：新增 `test/cubits/locale_cubit_test.dart`（預設、切換、持久化還原、不支援語系）。
