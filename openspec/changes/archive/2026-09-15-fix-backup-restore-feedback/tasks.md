## 1. 實作

- [x] 1.1 `lib/repositories/backup_repository.dart`：`BackupRepository`（backup／restore、15 秒 timeout、`Source.server`）、`BackupFailure`、`BackupSnapshot`
- [x] 1.2 `lib/main.dart` 提供 `BackupRepository`
- [x] 1.3 `lib/pages/user_page.dart` 重寫：先取後清、失敗回饋、按鈕互斥、全部字串 l10n
- [x] 1.4 `FoodItemListLoad`／`UsedFoodItemListLoad` 改為整批取代（先清空再寫入）
- [x] 1.5 l10n：新增 11 個 key 到三個 ARB 並重新產生
- [x] 1.6 dev 相依 `fake_cloud_firestore`

## 2. 測試

- [x] 2.1 `test/repositories/backup_repository_test.dart`：寫入格式、往返相等、覆蓋、沒有備份、不同使用者、缺欄位容錯、`BackupFailure.from` 對應
- [x] 2.2 兩個 Bloc 測試新增「還原整批取代既有資料」案例

## 3. 驗證

- [x] 3.1 `dart format`、`flutter analyze --no-pub`（0 issue）
- [x] 3.2 `flutter test` 全綠
- [x] 3.3 `openspec validate --all --strict --no-interactive`
- [x] 3.4 `flutter build apk --debug` 並安裝到 SM-T500
- [x] 3.5 實機（使用者，SM-T500，2026-09-15）：備份與還原成功；原 Wi-Fi 下 Firestore 連不上的情境已由 timeout / 錯誤訊息涵蓋（Repository 測試對應）
