# Local Persistence Specification

## Purpose

定義本機資料儲存層：Hive CE 的初始化、Box 配置、型別 adapter 的產生與相容性規則，以及「只有 Repository 能觸碰 Box」的邊界。這一層確保 App 離線可用、重啟後資料一致，並為未來雲端同步提供本機真相來源。

## Requirements

### Requirement: 啟動時初始化 Hive 與 Box

App 啟動時 SHALL 以應用程式文件目錄初始化 Hive、註冊所有 adapter，並開啟型別化 Box：`foodItem`（`Box<FoodItem>`）與 `usedFoodItem`（`Box<UsedFoodItem>`）。Box 開啟完成後才 SHALL 建立 Repository 與 runApp。

#### Scenario: 冷啟動

- **WHEN** App 冷啟動
- **THEN** 兩個 Box SHALL 在第一個畫面渲染前可用，Repository 可同步讀取

### Requirement: Adapter 由 build_runner 產生

`FoodItemType`、`FoodItemStatus`、`Unit`、`FoodItem`、`UsedFoodItem` 的 adapter SHALL 由 `lib/hive/hive_adapters.dart` 的 `@GenerateAdapters` 宣告並經 `build_runner` 產生；產生物 `hive_adapters.g.dart`、`hive_registrar.g.dart`、`hive_adapters.g.yaml` MUST 提交到版本庫。`hive_adapters.g.yaml` 中既有的 typeId 與欄位索引 MUST NOT 重新編號。

#### Scenario: 新增模型欄位

- **WHEN** 開發者為 `FoodItem` 新增一個欄位並重新產生
- **THEN** 既有欄位的索引 SHALL 不變，新欄位取得新的索引

### Requirement: Schema 變更向後相容

模型變更 SHALL 保證用舊版 App 寫入的 Box 仍可被新版開啟：新增欄位必須可為 null 或有預設值；列舉只能在尾端新增值，不得刪除或重排；移除欄位前必須先有一個版本停止讀取它。

#### Scenario: 舊資料開啟

- **WHEN** 使用者從舊版升級到新增了欄位的新版
- **THEN** 既有食物 SHALL 全部可讀，新欄位為預設值

#### Scenario: 列舉新增值

- **WHEN** `FoodItemType` 在尾端新增一個類型
- **THEN** 舊資料中的類型 SHALL 對應到原本的值

### Requirement: 只有 Repository 存取 Box

Bloc、Cubit 與 pages MUST NOT 直接持有或操作 Hive Box；所有讀寫 SHALL 經由 `FoodItemRepository`、`UsedFoodItemRepository`（及未來的 Repository）。Repository 的寫入 SHALL `await` Box 操作完成後才回傳。

#### Scenario: 新增資料來源

- **WHEN** 開發者需要新的持久化資料（例如通知設定）
- **THEN** SHALL 新增對應 Repository 而非在 Cubit 中直接開 Box
