---
name: flutter-verification
description: Food Savior 的驗證證據層級（format → analyze → bloc/unit test → widget test → build → 實機）、bloc_test/Hive/Firebase 測試配方、Dart MCP 實機檢查方式與回報格式。寫測試、宣稱「完成」、回報驗證結果前必讀。
---

# Flutter 驗證與測試

## 證據層級（不可互相替代，回報時逐層寫明）

| 層級 | 做什麼 | 何時必做 |
|---|---|---|
| L0 | `dart format .`（hook 自動） | 永遠 |
| L1 | `flutter analyze --no-pub`，0 error / 0 warning；info 要列出 | 永遠 |
| L2 | `flutter test`：Bloc、Cubit、Repository、純邏輯（日期、點數、解析器） | 改到上述任何一個 |
| L3 | widget test：頁面能渲染、關鍵互動會派發正確 event | 新頁面或改互動流程 |
| L4 | `flutter build apk --debug`（改 Gradle／權限／原生套件時加 `flutter build ios --no-codesign`） | 改 pubspec、android/、ios/ |
| L5 | 實機或模擬器實際操作變更到的畫面：明／暗主題、zh／en、小螢幕 | 任何 UI 變更 |
| L6 | `openspec validate --all --strict --no-interactive` | archive 前 |

一鍵 L0–L2：`node .claude/hooks/stop-verify.cjs --manual`

**沒做的層級就寫「未執行（原因）」**。編譯成功 ≠ 測試通過 ≠ 實機正常。

## Dart MCP（優先於手動 flutter run）

- `list_devices` → `launch_app`（帶 device id、`lib/main.dart`）→ 操作後 `get_runtime_errors`、`get_app_logs`。
- 改 UI 後 `hot_reload`；改 main／DI 後 `hot_restart`。
- `widget_inspector` 查 widget tree 確認 token 是否套用（例如是否還有硬編碼 `Color`）。
- `run_tests` 可跑單一測試檔；`analyze_files` 用於快速檢查單檔（比命令列 `dart analyze` 穩定）。
- 完成後 `stop_app`。

## 測試配方

### Bloc + Hive（temp 目錄）

```dart
import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:food_savior/hive/hive_registrar.g.dart';
import 'package:food_savior/models/food_item.dart';
import 'package:food_savior/repositories/food_item_repository.dart';
import 'package:food_savior/bloc/food_item_list/food_item_list_bloc.dart';

void main() {
  late Directory dir;
  late Box<FoodItem> box;
  final now = DateTime(2026, 9, 15, 12);

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('fs_test_');
    Hive
      ..init(dir.path)
      ..registerAdapters();
  });
  setUp(() async => box = await Hive.openBox<FoodItem>('foodItem_${DateTime.now().microsecondsSinceEpoch}'));
  tearDown(() async => box.deleteFromDisk());
  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  FoodItem item(String id, int daysToExpire) => FoodItem(
        id: id, name: id, type: FoodItemType.vegetable, status: FoodItemStatus.fresh,
        quantity: 1, unit: Unit.piece, description: '',
        storageDate: now, expirationDate: now.add(Duration(days: daysToExpire)),
      );

  blocTest<FoodItemListBloc, FoodItemListState>(
    '到期日 2 天內的新項目標記為 nearExpired',
    build: () => FoodItemListBloc(foodItemRepository: FoodItemRepository(foodItemBox: box)),
    skip: 2, // 建構子自動 add(LoadFromDevice) 產生的 Loading + Loaded
    act: (bloc) => bloc.add(FoodItemListAdd(foodItem: item('a', 2))),
    expect: () => [
      const FoodItemListLoading(),
      isA<FoodItemListLoaded>().having((s) => s.foodItems.single.status, 'status', FoodItemStatus.nearExpired),
    ],
  );
}
```

要點：
- 專案已有 `test/helpers/hive_test_helper.dart`（`HiveTestEnv`、`makeFood`、`makeUsed`、`daysFromNow`、`ids`），直接用，不要重造。
- Box 名稱加流水號避免測試間互相污染；`tearDown` 用 `box.deleteFromDisk()`。
- 現有 Bloc 用 `DateTime.now()`，測試只能用相對日期；重構後注入 `now` 就能用固定時間。
- 建構子自動載入導致初始 emit：`act` 內先 `await untilLoaded(bloc)`，並用 `skip: 2` 跳過 Loading + Loaded。
- **派發事件後要等 Bloc 回到穩定狀態**：Repository 的寫入是真正 `await` Hive I/O，`bloc_test` 在 `act` 結束後立刻 `close()`，會把還沒 emit 的 Loaded 丟掉。用測試檔內的 `bloc.settle(() => bloc.add(event))`（`stream.firstWhere(穩定狀態)` 先訂閱再 add），不要用 `wait: Duration(...)` 猜時間。
- `bloc_test` 的 `setUp:` 參數在 `build` 前執行，適合塞 Box 種子資料。

### Repository 純測試

不需要 Bloc，直接對 Repository 斷言 Box 內容；適合 `updateAllFoodItemsStatus`、`filterByDate` 這類邏輯。

### Cubit + SharedPreferences

`SharedPreferences.setMockInitialValues({})`（見 `test/bloc/theme_cubit_test.dart`）。

### Firebase

- Auth：`firebase_auth_mocks`（`MockFirebaseAuth(mockUser: ..., signedIn: true)`）注入 `AuthenticationRepository(firebaseAuth: ...)`。
- Firestore：`fake_cloud_firestore`（`FakeFirebaseFirestore()`），Repository 建構子接受 `FirebaseFirestore` 參數。
- Functions：以介面包一層 `RecipeApi`，測試用 fake 實作；不要 mock `HttpsCallable`。
- 這些套件都是 dev_dependencies，加入前在 change 的 design.md 記錄版本。

### Widget test

```dart
Widget wrap(Widget child, {required FoodItemListBloc bloc}) => MaterialApp(
      localizationsDelegates: const [S.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      supportedLocales: S.delegate.supportedLocales,
      locale: const Locale('zh', 'TW'),
      theme: ThemeCubit.lightTheme,
      home: BlocProvider.value(value: bloc, child: child),
    );
```
- 用 `bloc_test` 的 `MockBloc` + `whenListen` 餵狀態，不要在 widget test 開 Hive。
- Lottie／網路圖片在測試中用 `mockNetworkImagesFor` 或以 `Key` 找 widget、不斷言動畫。
- 明暗主題各跑一次（`theme: ThemeCubit.darkTheme`），確認不會拋 assertion。

### 時間相關邏輯

- 純函式化：`FoodItemStatus deriveStatus(DateTime expiration, DateTime now)` 放在 model 或 `lib/domain/`，直接單元測試邊界：到期日 = now、now + 3 天整、跨午夜。
- 期限判斷以「日曆日」還是「時間差」為準要在 spec 寫清楚，測試據此覆蓋。

## 何時一定要加測試（Stop hook 會擋）

- 改了 `lib/**/*_bloc.dart`、`*_cubit.dart`、`*_repository.dart` → `test/**/<同名>_test.dart` 必須存在（新檔或既有檔皆可，但必須包含這次行為）。
- 修 bug → 先寫會失敗的測試重現，再修。

## 回報格式

```
驗證：
- L0/L1 format+analyze：通過（info 4 個：deprecated DropdownButtonFormField.value）
- L2 flutter test：12 通過 / 0 失敗（新增 food_item_list_bloc_test.dart 5 案例）
- L3 widget：未執行（本次未改頁面）
- L4 build apk --debug：通過
- L5 實機：Pixel 8 模擬器 Android 15，明/暗、zh/en 各操作一次，無 runtime error
- L6 openspec validate：通過
```
