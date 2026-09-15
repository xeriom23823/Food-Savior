## 1. 實作

- [x] 1.1 `LocaleCubit`：注入 `Future<SharedPreferences>`、啟動時讀取 `localeLanguageCode` 並對應回支援的完整 Locale、`setLocale` 正規化後寫入、不支援語系忽略
- [x] 1.2 `test/cubits/locale_cubit_test.dart`：預設 zh_TW、切換 en_US 立即生效並寫入、以既有偏好建立時還原、只有語言碼的 Locale 正規化、不支援語系忽略且不寫入

## 2. 驗證

- [x] 2.1 `dart format`、`flutter analyze --no-pub`（0 issue）
- [x] 2.2 `flutter test` 全綠
- [x] 2.3 `openspec validate --all --strict --no-interactive`
- [ ] 2.4 實機：切到 English → 關閉 App → 重開仍為英文（待使用者回到電腦）
