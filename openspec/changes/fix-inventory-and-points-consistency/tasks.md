## 1. 安全網（先紅）

- [x] 1.1 `test/helpers/hive_test_helper.dart`：暫存目錄 Hive、fixture 工廠
- [x] 1.2 `test/bloc/food_item_list_bloc_test.dart`：載入／新增／編輯／移除／清空／過期處理／還原載入（含「處理完成後 Box 不含已處理項目」「還原保留各自 id」兩個修正前失敗案例）
- [x] 1.3 `test/bloc/used_food_item_list_bloc_test.dart`：載入／依日期／點數 ±1／每日上限／批次 AddAll（修正前無法編譯）／還原保留點數／移除更新清空
- [x] 1.4 `test/repositories/*_repository_test.dart`：狀態推導邊界、篩選、刪除、清空
- [x] 1.5 `test/models/food_item_test.dart`：值相等、copyWith 保留 id（修正前失敗）、toUsedFoodItem 點數、JSON 往返（修正前失敗：列舉欄位被序列化成函式）
- [x] 1.6 `test/app_compiles_test.dart`：編譯煙霧測試（抓套件層級錯誤）

## 2. 修正

- [x] 2.1 `FoodItem.copyWith` 的 `id` 預設改為 null
- [x] 2.2 `FoodItem` / `UsedFoodItem` 改為值相等（`==` + `Object.hash`，含 runtimeType）
- [x] 2.3 `FoodItemListProcessComplete` 刪除 `tempFoodItems` 的 Box 項目
- [x] 2.4 新增 `UsedFoodItemListAddAll` event 與共用 `_pointFor`；`Add` 改用共用方法
- [x] 2.5 過期處理頁「處理完成」改派發 `UsedFoodItemListAddAll`
- [x] 2.6 `DropdownButtonFormField.value` → `initialValue`（4 處）
- [x] 2.7 載入與處理完成後的清單依到期日排序（`_sortedByExpiration`）
- [x] 2.8 Flutter 3.47 相容：移除 `material_design_icons_flutter`，食物類型與浪費動作圖示改用 `font_awesome_flutter` 11（`FontAwesomeIcons.x.data`），Google 登入改 `FaIcon`
- [x] 2.9 Repository 所有寫入（put／delete／clear）改為 `await` 後才回傳（local-persistence 規格；未 await 的 `clear()` 讓清空後立即讀取仍有資料）
- [x] 2.10 列舉擴充的 `name(BuildContext)` 改名 `localizedName`：原名遮蔽 Dart 的 `Enum.name`，導致 `toJson()` 把函式而非名稱寫進 JSON（`fromJson` 一直無法使用）；13 個呼叫端同步更新
- [x] 2.11 Android 工具鏈對齊 Flutter 3.47 範本（Flutter 3.47 要求 Gradle ≥ 8.14）：Gradle wrapper 8.11.1 → 9.3.1、AGP 8.6.1 → 9.1.0、Kotlin 2.4.0、google-services 4.5.0；保留 migrator 加入的 `android.newDsl=false`／`android.builtInKotlin=false`；CI 的 build-android 改用 JDK 21（app 以 Java 21 為目標）

## 4. 相依套件更新（使用者要求「能更新就更新」）

- [x] 4.1 根專案與 `packages/*` 以 `flutter pub upgrade --major-versions` + `--tighten` 升到最新可解析版本：firebase_core 4、firebase_auth 6、cloud_firestore 6、google_sign_in 7、image_cropper 12、google_fonts 8、flutter_lints 6、hive_ce 2.20、fl_chart 1.2、lottie 3.5、equatable 2.1 等
- [x] 4.2 `authentication_repository` 遷移到 google_sign_in 7：`GoogleSignIn.instance` + 一次性 `initialize()`、`authenticate()`、只用 ID token 建 Firebase credential、`GoogleSignInException` 對應成 `LogInWithGoogleFailure`；Web 仍走 Firebase popup，登出時 Web 不呼叫 GoogleSignIn
- [x] 4.3 移除未使用且阻擋解析的 `intl_translation`（dev）與 `test`（誤放在 dependencies）；解鎖 intl_utils、hive_ce_generator 升級
- [x] 4.4 `dependency_overrides: objective_c: 9.6.0`：9.6.1 的 build hook 引用尚未發布的 `code_assets` API（`Architecture.arm64e`），會讓 `flutter test` 編譯失敗；待 objective_c 修正後移除
- [x] 4.5 重新產生 Hive adapters（hive_ce_generator 1.11：新增 `IsolatedHiveRegistrar`；typeId 與欄位索引不變）
- [ ] 4.6 仍非最新且無法升級：`build_runner` 2.16、`mockito` 5.8、`hive_ce_generator` 1.11.3、`intl_utils` 2.8.16 —— 受 `flutter_test`（SDK）固定的 `test_api` 與各自的 `analyzer` 版本鏈互相牽制，等 SDK 下一版
- [x] 4.7 移除未使用的套件（使用者 2026-09-15 決定）：`image_cropper`、`image_picker`、`dotted_border`、`google_fonts`

## 3. 驗證

- [x] 3.1 `dart format`、`flutter analyze --no-pub`（0 error／0 warning／0 info）
- [x] 3.2 `flutter test` 全綠：52 個測試（修正前 7 個失敗 + 1 檔無法編譯）
- [x] 3.3 `openspec validate --all --strict --no-interactive`
- [x] 3.4 `flutter build apk --debug` 成功（2026-09-15，Flutter 3.47.4 + Gradle 9.3.1 + AGP 9.1.0 + Android Studio JBR 25，179 秒）
- [ ] 3.5 實機（待使用者回到電腦）：製造一筆過期食物 → 處理完成 → 重啟 App 不再跳出處理頁；備份含多筆 2 天內到期食物 → 還原後筆數正確；食物類型圖示改為 Font Awesome 後的外觀確認
