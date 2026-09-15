---
name: food-savior-architecture
description: Food Savior（Flutter + flutter_bloc + Hive CE + Firebase）的分層架構、Bloc/Repository 慣例、Hive adapter 與 l10n 產生流程、新功能標準步驟與指令速查。任何新增或修改功能、重構頁面、調整資料模型前先讀。
---

# Food Savior 架構指引

## 何時使用

- 要新增功能、修改行為、調整 `FoodItem` 模型、重構 `lib/pages/` 時。
- 不確定某段邏輯該放 page、Bloc 還是 Repository 時。
- 要跑 build_runner、intl_utils 等產生流程時。

## 分層與資料流

```
pages（純 UI：BlocBuilder/BlocConsumer、派發 event、顯示 state）
  ↓ event                      ↑ state（Equatable，不可變）
Bloc / Cubit（商業邏輯：狀態推導、點數計算、日期判斷、排序）
  ↓ 呼叫                       ↑ 回傳 model / List<model>
Repository（唯一觸碰資料來源：Hive Box、Firestore、SharedPreferences）
  ↓
Hive CE Box（本機真相）／Firebase
```

規則：
1. **pages 不寫商業邏輯**。現有 `food_item_list_page.dart` 在頁面裡建立 `UsedFoodItem`、計算剩餘數量、決定狀態 —— 這是技術債，新程式碼不得沿用；接觸到時把邏輯下沉到 Bloc（新增 event，例如 `FoodItemListConsume(foodItem, quantity, usedDate)`）。
2. **一個 Bloc 對應一個聚合**：`FoodItemListBloc`（現存清單）、`UsedFoodItemListBloc`（使用紀錄）。跨聚合的操作（食用一筆 → 清單移除 + 紀錄新增）由 page 派發兩個 event，或由新的協調層（例如 `ConsumptionCubit`）處理；不要讓一個 Bloc 直接持有另一個 Bloc。
3. **Repository 不回傳 UI 型別**，不 import `flutter/material.dart`。
4. **時間可注入**：新 Bloc／Repository 建構子接受 `DateTime Function() now = DateTime.now`，測試時傳固定時間。現有程式碼直接呼叫 `DateTime.now()`，重構時順手改。

## 目錄慣例

| 東西 | 位置 | 命名 |
|---|---|---|
| Bloc | `lib/bloc/<feature>/<feature>_bloc.dart` + `_event.dart` + `_state.dart`（`part of`） | `FooBloc`、event `FooLoad`/`FooAdd`、state `FooInitial`/`FooLoading`/`FooLoaded`/`FooError` |
| Cubit | `lib/cubits/<name>_cubit.dart` | `FooCubit` |
| Repository | `lib/repositories/<name>_repository.dart` | `FooRepository` |
| Model | `lib/models/<name>.dart` | 純 Dart + Hive 註解由 `hive_adapters.dart` 集中宣告 |
| Page | `lib/pages/<name>_page.dart`；子 widget 拆到 `lib/pages/<name>/widgets/` | `FooPage` |
| 共用 widget | `lib/widgets/` | |
| 服務（通知、掃描、同步引擎） | `lib/services/<name>_service.dart`（新增） | 介面 + 實作，方便測試替換 |
| 測試 | `test/<layer>/<name>_test.dart`，鏡射 lib 結構 | `foo_bloc_test.dart` |

## Bloc / State 慣例

- state 用 `final class ... extends Equatable`，`props` 必須列出**所有**影響 UI 的欄位（現有 `FoodItemListNeedProcessing.props` 漏了 `isConsumed`，是 bug 樣板，不要學）。
- 集合欄位在 emit 前建立新 List（`List.of(...)`），不要就地修改舊 state 的 List。
- 非同步 handler 用 `async` + `await repository.xxx()`，中間 emit `Loading` 只在 UI 需要時做（頻繁 Loading 會閃爍）。
- 錯誤：catch 後 emit `FooError(message)`，message 用 l10n key 名稱或錯誤碼，由 page 轉成文字。
- 需要初始載入時在建構子 `add(FooLoadFromDevice())`（現有做法），測試時可用 `skip: 1`。

## Repository 慣例

```dart
class FooRepository {
  FooRepository({required Box<Foo> box, DateTime Function()? now})
      : _box = box, _now = now ?? DateTime.now;
  final Box<Foo> _box;
  final DateTime Function() _now;

  List<Foo> getAll() => _box.values.toList();
  Future<void> save(Foo item) => _box.put(item.id, item);   // 一定 await / 回傳 Future
  Future<void> delete(String id) => _box.delete(id);
}
```

## Hive 流程

1. 改 `lib/models/food_item.dart`（新增欄位必須可 null 或有預設值；列舉只在尾端加值）。
2. 若新增型別，在 `lib/hive/hive_adapters.dart` 的 `@GenerateAdapters` 加 `AdapterSpec<T>()`。
3. `dart run build_runner build --delete-conflicting-outputs`
4. 檢查 `lib/hive/hive_adapters.g.yaml`：既有 typeId／欄位索引不得改變；提交所有 `.g.dart` 與 yaml。
5. 用含舊資料的裝置或測試（先以舊 adapter 寫入再以新 adapter 讀）驗證相容。
6. 新的持久化資料（設定、同步佇列）開新 Box + 新 Repository，不塞進既有 Box。

## l10n 流程

1. 在 `lib/l10n/intl_zh.arb` 與 `intl_en.arb` 同時加 key（camelCase；動詞開頭的是按鈕、名詞是標籤、`*Title` 是標題、`*Error` 是錯誤）。
2. `dart run intl_utils:generate`
3. 程式用 `S.of(context).key`；帶參數用 ARB placeholder，不用字串串接（現有 `'${name} ${S.of(context).wasted}'` 這種串接在英文語序下會出錯，接觸到就改）。
4. 列舉顯示名稱走 `extension` 的 `name(context)`，不直接顯示 `enum.name`。

## 新功能標準步驟

1. `/opsx:new <name>`（或 Codex `$openspec-new-change`）→ proposal → delta specs → design → tasks。
2. 讀 `openspec/specs/` 相關能力與本 skill 對應的領域 skill。
3. 依序實作：model／Hive → Repository（+ 測試）→ Bloc（+ bloc_test）→ page（+ widget test）→ l10n → 更新 `openspec/specs` 以外的文件（README 功能清單）。
4. `node .claude/hooks/stop-verify.cjs --manual`，再用 Dart MCP `launch_app` 實機看一次（明暗、zh/en）。
5. 勾 tasks → `/opsx:verify` → `/opsx:archive`。

## 指令速查

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run intl_utils:generate
flutter analyze --no-pub
flutter test
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html   # 需 lcov
flutter build apk --debug
flutter run -d <deviceId>            # 或用 Dart MCP launch_app
openspec status --change <name>
openspec validate --all --strict --no-interactive
```

## 已知陷阱

- `FoodItem`／`UsedFoodItem` 是**值相等**（所有欄位 + runtimeType）。`FoodItemListUpdate` 用 `==` 找原項目，所以呼叫端要傳清單中的同一實例；別先 `copyWith` 再當 original 傳。
- 列舉的顯示名稱是 `localizedName(context)`。**絕對不要**在列舉 extension 上宣告名為 `name` 的成員：它會遮蔽 `Enum.name`，`toJson()` 就會把函式塞進 JSON（這個 bug 存在了很久才被測試抓到）。
- `toJsonString()`（列舉存 `FoodItemType.x`，備份用）與 `toJson()`（列舉存 `name`，同步用）兩套並存；新程式一律用 `toJson/fromJson`，遷移時要能讀兩種。
- 食物類型圖示來自 `font_awesome_flutter` 11：`FontAwesomeIcons.carrot.data` 才是 `IconData`；`FontAwesomeIcons.carrot` 本身是 `FaIconData`，只能給 `FaIcon` 用。
- Repository 寫入回傳的是 Hive 的 Future，一定要 `await`；`box.clear()` 尤其是非同步完成的。
- google_sign_in 7：`GoogleSignIn.instance` 是單例，任何方法前要先 `initialize()` 一次（`AuthenticationRepository._ensureGoogleSignInInitialized`）；`authenticate()` 只給 ID token，access token 要另走 `authorizationClient`；使用者取消會丟 `GoogleSignInException(code: canceled)`。
- `pubspec.yaml` 有 `dependency_overrides: objective_c: 9.6.0`（9.6.1 的 hook 與已發布的 `code_assets` 不相容）；升級相依時先拿掉 override 試 `flutter test`，能過就刪。
- 升級相依用 `flutter pub upgrade --major-versions` 再 `--tighten`；`packages/*` 各自也要跑，否則 path 套件的舊約束會卡住根專案。
- 測試裡派發事件後用 `bloc.settle(() => bloc.add(...))` 等穩定狀態（見 `test/bloc/*_test.dart`），否則 `bloc_test` 會在 Hive 寫完前 close。
- `flutter_slidable` 的 `SlidableController` 需要 `TickerProvider`（頁面 mixin `TickerProviderStateMixin`）。
- `showDialog` 內用外層 `context.read<Bloc>()` 前先在 builder 外取好參考，避免 dialog 關閉後 context 失效。
- Windows 上 `dart analyze <單檔>` 偶爾因 analysis server 暫存檔鎖定而崩潰；改跑 `flutter analyze --no-pub` 全專案。
