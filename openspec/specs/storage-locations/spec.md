# Storage Locations Specification

## Purpose

定義使用者自訂的食物存放位置：建立、命名、排序、刪除，以及每個位置的 `kind`（冷藏／冷凍／常溫／其他）如何供保存期限建議使用。首次啟動會種下三筆預設位置。位置是 food-inventory 的分群依據之一，刪除位置不得連帶刪除食物。

## Requirements

### Requirement: 使用者自訂存放位置

系統 SHALL 允許使用者建立、重新命名、排序與刪除存放位置。每個位置 SHALL 有唯一 id、名稱（不可為空，`locationNameCannotBeEmpty`）、`kind`（`refrigerated`、`frozen`、`ambient`、`other`）與排序值。名稱由使用者自由輸入（「冰箱上層」「蔬果室」「儲藏櫃」）；`kind` 是唯一參與程式判斷的欄位，供保存期限建議使用，名稱 MUST NOT 參與任何邏輯判斷。

#### Scenario: 建立位置

- **WHEN** 使用者新增名稱「蔬果室」、kind 為 `refrigerated` 的位置
- **THEN** 系統 SHALL 建立該位置並出現在食物表單的位置選擇中

#### Scenario: 名稱為空

- **WHEN** 使用者送出空白名稱
- **THEN** 系統 SHALL 顯示 `locationNameCannotBeEmpty` 且不建立位置

#### Scenario: 重新排序

- **WHEN** 使用者拖曳調整位置順序
- **THEN** 新順序 SHALL 持久化，並套用到選擇器與清單分群的排列

### Requirement: 首次啟動種下預設位置

首次啟動（`storageLocation` Box 為空且未曾種過）時，系統 SHALL 建立三筆預設位置：冷藏（`refrigerated`）、冷凍（`frozen`）、常溫（`ambient`）。預設名稱 SHALL 取自當時的語系並**存成字串**，使用者事後改名或刪除後 MUST NOT 被重新建立。

#### Scenario: 新使用者

- **WHEN** 使用者第一次開啟 App
- **THEN** 位置清單 SHALL 有冷藏、冷凍、常溫三筆

#### Scenario: 刪光後不重生

- **WHEN** 使用者刪除全部預設位置後重新啟動 App
- **THEN** 系統 MUST NOT 重新建立預設位置

#### Scenario: 改名不隨語系變動

- **WHEN** 使用者將「冷藏」改名為「大冰箱」後切換語系為英文
- **THEN** 該位置名稱 SHALL 仍為「大冰箱」

### Requirement: 刪除位置不刪食物

刪除存放位置時，系統 SHALL 先以確認介面告知有多少筆食物使用該位置；確認後 SHALL 將這些食物的 `storageLocationId` 設為 null 並保留食物本身。

#### Scenario: 刪除有食物的位置

- **WHEN** 使用者刪除一個有 4 筆食物的位置並確認
- **THEN** 該位置 SHALL 消失，4 筆食物 SHALL 保留並歸入「未指定位置」

#### Scenario: 取消刪除

- **WHEN** 使用者在確認介面選擇取消
- **THEN** 位置與食物 SHALL 都不改變

### Requirement: 位置的持久化與存取邊界

存放位置 SHALL 以 id 為 key 寫入 Hive Box `storageLocation`，並只經由 `StorageLocationRepository` 讀寫；Bloc、Cubit 與 pages MUST NOT 直接操作該 Box。

#### Scenario: 重啟後保留

- **WHEN** 使用者新增一個位置後重新啟動 App
- **THEN** 該位置 SHALL 仍存在且順序不變
