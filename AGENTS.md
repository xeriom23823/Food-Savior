# Food Savior 食物救世主 — Agent 工作指引

本檔是 Claude Code 與 Codex 共用的專案指引（CLAUDE.md 會 `@AGENTS.md` 引入）。以繁體中文撰寫；技術名詞保留英文。

## 專案事實

- 產品：記錄家中生鮮食物保存期限、提醒即將過期，並以「食物點數」獎勵食用、懲罰浪費的手機 App。
- 平台：Android 優先，iOS 次之；macOS / Windows / Linux / Web 只需維持可編譯，不需驗證 UX。
- 技術棧：Flutter 3.47 / Dart 3.13、flutter_bloc 9、Equatable、Hive CE 2.20、firebase_core 4 / firebase_auth 6 / cloud_firestore 6、google_sign_in 7、intl + intl_utils（zh-TW 預設、en）、fl_chart、flutter_slidable、Lottie、Font Awesome 11、Material 3、flutter_lints 6。2026-09-15 全部升到最新可解析版本；`build_runner`／`mockito`／`hive_ce_generator`／`intl_utils` 受 SDK 的 `test_api` 與 analyzer 版本鏈牽制，非最新。
- `pubspec.yaml` 的 `dependency_overrides: objective_c: 9.6.0` 是暫時的：9.6.1 的 build hook 引用尚未發布的 `code_assets` API，會讓 `flutter test` 編譯失敗。objective_c 出新版時先移除 override 試試。
- Android 工具鏈：Gradle 9.3.1、AGP 9.1.0、Kotlin 2.4.0、google-services 4.5.0（對齊 Flutter 3.47 範本）；`android/gradle.properties` 的 `android.newDsl=false` 是 Flutter migrator 為 AGP 9 加的，不要移除；`android.builtInKotlin` 已於 2026-09-15 改為 `true`（AGP 內建 Kotlin 編譯），`app/build.gradle` 因此不再套用 `kotlin-android`，jvmTarget 改由頂層 `kotlin { compilerOptions { … } }` 指定，`android/build.gradle` 的舊 `buildscript` classpath（AGP 8.6.1／KGP 2.1.10／google-services 4.3.10）已刪除，版本一律由 `settings.gradle` 的 `plugins` 區塊決定。App 以 Java 21 為目標，本機用 Android Studio 附帶 JBR（Java 25）建置即可；CI 用 Temurin 21。Flutter 3.47 拒絕 Gradle < 8.14。
- 規格：OpenSpec（`openspec/`）。`openspec/specs/` 是系統現況的唯一真相；行為變更必須經由 change 的 delta spec。
- 文件語言：AGENTS、specs、skills 一律繁體中文。

## 目錄地圖

| 路徑 | 內容 |
|---|---|
| `lib/main.dart` | 啟動流程（Firebase → 等待首個 auth 狀態 → Hive → runApp）與五分頁外殼 `FoodSavior` |
| `lib/app/` | `AppBloc`（登入狀態）、`App`/`AppView`（MaterialApp、Theme、Locale）、`routes.dart`（FlowBuilder 路由） |
| `lib/bloc/food_item_list/` | 現存食物清單 Bloc（含過期處理流程） |
| `lib/bloc/used_food_item_list/` | 使用／浪費紀錄 Bloc（含每日點數上限） |
| `lib/cubits/` | `ThemeCubit`（明暗主題、SharedPreferences）、`LocaleCubit`（語系，未持久化） |
| `lib/models/food_item.dart` | `FoodItem`、`UsedFoodItem`、`FoodItemType`／`FoodItemStatus`／`Unit` 列舉與 UI 擴充 |
| `lib/repositories/` | `FoodItemRepository`、`UsedFoodItemRepository`（唯一觸碰 Hive Box 的層） |
| `lib/hive/` | `hive_adapters.dart`（`@GenerateAdapters`）、`*.g.dart`、`hive_adapters.g.yaml`（typeId 登錄，必須提交、不可重編號） |
| `lib/pages/` | 五個分頁；`food_item_list_page.dart` 超過 1000 行且含商業邏輯，是重構首選 |
| `lib/login/`、`lib/sign_up/` | Cubit + View（formz 驗證） |
| `lib/l10n/*.arb` → `lib/generated/` | 多語系來源與產生物（`dart run intl_utils:generate`） |
| `packages/authentication_repository`、`packages/form_inputs`、`packages/cache` | 內部套件 |
| `test/` | `helpers/hive_test_helper.dart`（`HiveTestEnv`、`makeFood`／`makeUsed` fixture）、`bloc/`、`repositories/`、`models/`、`app_compiles_test.dart`（編譯煙霧：抓套件層級錯誤）；新測試放 `test/<layer>/<name>_test.dart` |
| `openspec/` | `config.yaml`、`specs/<capability>/spec.md`、`changes/<name>/` |
| `.claude/skills/`、`.agents/skills/` | 專案 skills（前者給 Claude Code，後者給 Codex；內容相同，見「Skills」） |
| `.claude/hooks/*.cjs` | 品質關卡腳本（Claude Code 與 Codex 共用） |

## 開發流程（必守）

1. **非 trivial 變更一律先開 OpenSpec change**：新功能、行為變更、資料模型變更、UI 重製。純 typo、註解、格式化、單行 bug fix 可直接改，但若修 bug 改變了 spec 描述的行為，仍要補 delta spec。
   - Claude Code：`/opsx:new`、`/opsx:continue`、`/opsx:apply`、`/opsx:verify`、`/opsx:archive`
   - Codex：`$openspec-new-change`、`$openspec-continue-change`、`$openspec-apply-change`、`$openspec-verify-change`、`$openspec-archive-change`
2. 動手前先讀受影響能力的 `openspec/specs/<capability>/spec.md`，以及對應的 skill（見下表）。
3. 實作順序：model／Hive → Repository → Bloc（event、state）→ page → l10n → 測試 → 驗證。
4. 每完成一項就勾 `tasks.md`；結束前執行 `node .claude/hooks/stop-verify.cjs --manual` 並如實回報結果。
5. archive 前必須 `flutter test` 全綠、`openspec validate --all --strict --no-interactive` 通過（hook 會強制）。

## 架構規則

- **分層**：pages 只做 UI 與派發事件；商業邏輯（狀態推導、點數計算、日期判斷、資料轉換）放在 Bloc／Cubit 或 Repository。現有 pages 有違規（例如在頁面裡建立 `UsedFoodItem`、計算剩餘數量），新程式碼不得沿用，重構時順手下沉。
- **狀態**：state 是 `final class` + Equatable，`props` 必須包含所有影響 UI 的欄位；event 命名 `<Feature><動作>`。
- **Repository**：唯一接觸 Hive Box / Firestore 的層；同步讀、非同步寫且 `await box.put`。不回傳 Flutter UI 型別。
- **Hive**：新增欄位必須有預設值或可為 null；列舉只能在尾端新增值；改完 `dart run build_runner build --delete-conflicting-outputs` 並提交 `.g.dart` 與 `hive_adapters.g.yaml`；以舊資料實際開啟驗證。
- **時間**：新程式碼中的 `DateTime.now()` 必須可注入（建構子傳入 `DateTime Function() now`），否則無法測試期限邏輯。
- **l10n**：所有使用者可見文字進 `intl_zh.arb` 與 `intl_en.arb`，再 `dart run intl_utils:generate`；不得硬編碼中文或英文。
- **主題**：只用 `Theme.of(context).colorScheme.*`／`textTheme.*` 與 design-system 定義的 token；pages 不寫 `Colors.*`、`Color(0x…)`、`fontSize:` 數值。設計系統重製完成前，新 UI 也要遵守此規則。
- **圖示**：Material `Icons` 為主；食物類型用 `font_awesome_flutter`，取 `FontAwesomeIcons.x.data` 得到 `IconData`（或直接用 `FaIcon` widget）。不可引入 `material_design_icons_flutter`。
- **列舉顯示名稱**：用擴充方法 `localizedName(context)`；不要在列舉擴充上定義名為 `name` 的成員，它會遮蔽 Dart 的 `Enum.name` 並讓 JSON 序列化壞掉。
- **Firebase**：金鑰與後端呼叫不可放在 App；Claude API 等第三方 API 一律經 Cloud Functions 代理。
- **套件**：新增套件要在 change 的 design.md 記錄版本約束、平台需求與替代方案；不要為單一功能引入大型框架。

## 驗證證據層級（不可互相替代）

| 層級 | 指令 | 說明 |
|---|---|---|
| L0 格式 | `dart format .` | PostToolUse hook 自動執行 |
| L1 分析 | `flutter analyze --no-pub` | error／warning 阻擋，info 需回報 |
| L2 單元／Bloc | `flutter test` | Bloc、Cubit、Repository 變更必須有對應 `<name>_test.dart` |
| L3 Widget | `flutter test test/pages` | 新頁面需 widget test（含 l10n delegates 與 Bloc providers） |
| L4 建置 | `flutter build apk --debug` | 改動 Gradle、原生權限、套件時必做 |
| L5 實機 | Dart MCP `launch_app`／`hot_reload`／`get_runtime_errors` 或 `flutter run` | 改動 UI 時必做，並檢查明暗主題與 zh／en |
| L6 規格 | `openspec validate --all --strict --no-interactive` | archive 前必做 |

回報時明確寫出「做了哪幾層、結果如何、哪幾層沒做及原因」。沒跑過的不要寫成通過。

## 品質關卡（hooks）

| 時機 | 腳本 | 行為 |
|---|---|---|
| 編輯 `.dart` 後 | `.claude/hooks/dart-post-edit.cjs` | `dart format` 該檔；語法錯誤即阻擋 |
| 回合結束 | `.claude/hooks/stop-verify.cjs` | 有 `.dart`／`pubspec.yaml` 異動時跑 format 檢查、`flutter analyze`、Bloc／Repository 測試對應檢查、`flutter test`；任一失敗即要求繼續修正 |
| 執行 `openspec archive` 前 | `.claude/hooks/openspec-archive-gate.cjs` | `openspec validate --all --strict`、analyze、test 全過才放行 |

Claude Code 由 `.claude/settings.json` 掛載；Codex 由 `.codex/hooks.json` 掛載，腳本相同。手動檢查：`node .claude/hooks/stop-verify.cjs --manual`。

## Skills（先讀再做）

| Skill | 何時讀 |
|---|---|
| `food-savior-architecture` | 任何功能開發前：分層、Bloc 慣例、Hive／l10n 流程、指令速查 |
| `flutter-verification` | 寫測試、回報驗證結果、使用 Dart MCP 實機檢查 |
| `flutter-ui-taste` | 任何 UI 變更；設計系統 token 與 anti-slop 檢查表 |
| `local-notifications` | 過期提醒／本機通知 |
| `barcode-einvoice` | 條碼／QR 掃描、電子發票 QR 解析、載具 API |
| `firestore-sync` | Hive ↔ Firestore 同步、Security Rules、備份遷移 |
| `ai-recipe-recommendation` | AI 料理推薦：Cloud Functions 代理、Claude API、結構化輸出、成本控管 |
| `openspec-*` | OpenSpec 各階段操作（由 `openspec init` 產生） |

Skills 的來源目錄是 `.claude/skills/`；修改後執行 `node tool/sync_skills.cjs` 同步到 `.agents/skills/` 供 Codex 使用。

## MCP

- **dart**（`.mcp.json`／`.codex/config.toml`）：`dart mcp-server`。用 `analyze_files`、`run_tests`、`pub`、`launch_app`、`hot_reload`、`get_runtime_errors`、`widget_inspector`、`list_devices`。實機驗證優先用它而非長時間阻塞的 `flutter run`。
- **Firebase**（CLI 已安裝並登入，專案 `foodsavior-792ee`；MCP 未預設啟用）：需要操作 Firestore 規則、資料或 Functions 時，在 `.mcp.json` 加 `"firebase": {"command": "firebase", "args": ["mcp"]}`。CLI 是 npm 全域套件，切換 nvm Node 版本後要重裝（`npm i -g firebase-tools`，登入狀態保存在 `~/.config/configstore`）。
- **Figma**：僅在使用者提供 Figma 連結時使用。

## 已知問題與技術債（開 change 修正，勿默默順手改）

1. ~~`LocaleCubit` 未持久化~~ 已修正並 archive（`persist-locale-selection`）。
2. ~~月趨勢圖跨年疊加~~ 已修正並 archive（`monthly-trend-year-month`）；統計頁字串已 l10n。
3. 備份使用 `toJsonString`（列舉以 `FoodItemType.x` 字串序列化）；`toJson`／`fromJson`（以 `name` 序列化）已可用，firestore-sync 時整併並提供讀取兩種格式的遷移。
4. `food_item_list_page.dart` 超過 1000 行、頁面內含商業邏輯與硬編碼中文（「過期食物清單」、「處理完成」、「備份」、「還原」等）；由 design-system-redesign D8 處理。
5. `.github/workflows/flutter_ci.yml` 已更新到 actions v4／Flutter 3.47.4／build-android 用 JDK 21，但尚未在 GitHub 上實際跑過；本機 `flutter build apk --debug` 已通過。
6. 食物類型圖示已從停止維護的 `material_design_icons_flutter` 換成 `font_awesome_flutter` 11（Flutter 3.47 相容性所迫），外觀待 design-system-redesign 一併審視；不可再引入 MDI。
7. `FoodItemListUpdate` 以值相等尋找原項目；呼叫端必須傳清單中的同一實例。design-system-redesign D8 改為以 id 比對。
8. Google 登入已遷移到 google_sign_in 7（`GoogleSignIn.instance.initialize()` → `authenticate()` → 只用 ID token）。Android 依賴 google-services.json 內的 web OAuth client 自動當 serverClientId，**且 Firebase Android app 必須登錄該機器簽章的 SHA-1**（2026-09-15 首次實機測試出現「Sign in was cancelled」就是因為沒有登錄；已用 `firebase apps:android:sha:create` 登錄本機 debug keystore 的 SHA-1／SHA-256，並重新下載 google-services.json，現在含 Android OAuth client）。換電腦、換 keystore 或發 release 時要再登錄對應 SHA：`keytool -list -v -keystore <keystore>`，然後 `firebase apps:android:sha:create 1:376153272412:android:f98c38314b3282de043699 <SHA> --project foodsavior-792ee`，再 `firebase apps:sdkconfig android <appId> --project foodsavior-792ee --out <暫存檔>` 覆蓋 `android/app/google-services.json`。iOS／macOS 設定需在 macOS 上建置驗證。
9. `image_cropper`、`image_picker`、`dotted_border`、`google_fonts` 已於 2026-09-15 移除（未使用）；未來做頭像上傳時再加回 `image_picker`。

已修正並 archive（2026-09-15）：`fix-inventory-and-points-consistency`（過期處理後項目未刪除、批次寫入不套用點數上限、`copyWith` 把 id 清成空字串、`==`／`hashCode` 契約、Repository 未 `await` 寫入、列舉擴充 `name()` 遮蔽 `Enum.name` 使 `toJson` 失效、載入未排序、4 個 deprecation、工具鏈與套件升級）、`fix-backup-restore-feedback`（備份失敗無回饋、還原先清空後讀取的資料遺失風險；Firestore 存取移入 `BackupRepository`）。
10. 使用者的測試 Wi-Fi 曾讓 Firestore gRPC 連不上後端（Auth 的 HTTPS 正常）；App 現在會在 15 秒內顯示 `errorOffline`。若再遇到，先換網路（手機熱點）排除環境因素。
11. `flutter build`／`flutter run` 仍會印出「Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): firebase_auth, firebase_core」。這是 Flutter 工具的誤判：firebase_core 4.15.0／firebase_auth 6.7.0 的 `android/build.gradle` 只有在 `android.builtInKotlin=false` 時才會套用 KGP，但 Flutter 是用正規表示式掃描檔案文字（`FlutterPluginUtils.kt` 的 `kgpRegexGroovy`），看不出那行在 `if` 裡面。本機無解，要等 FlutterFire 移除該行；不要為此修改 pub cache。
12. `android/gradlew`、`android/gradlew.bat` 被 `android/.gitignore` 排除，兩者的 `DEFAULT_JVM_OPTS` 已加上 `--enable-native-access=ALL-UNNAMED`，用來消掉 JDK 24+（本機 JBR 25）對 Gradle native-platform 的 restricted-method 警告。因為未進版控，換電腦或 Flutter 重新產生 wrapper 後要重加；或改設使用者層級環境變數 `GRADLE_OPTS`。CI 用 JDK 21，本來就不會出現該警告。

## 指令速查

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Hive adapters
dart run intl_utils:generate                               # l10n
flutter analyze --no-pub
flutter test
node .claude/hooks/stop-verify.cjs --manual
openspec validate --all --strict --no-interactive
openspec list && openspec status --change <name>
```

## Codex 使用者注意

- Codex 讀取本檔與 `.agents/skills/`；hooks 在 `.codex/hooks.json`（需 Codex 將此專案設為 trusted）。若 hooks 未生效，結束前務必手動執行 `node .claude/hooks/stop-verify.cjs --manual`。
- Dart MCP 若未自動載入，把 `.codex/config.toml` 的 `[mcp_servers.dart]` 區塊貼到 `~/.codex/config.toml`。
