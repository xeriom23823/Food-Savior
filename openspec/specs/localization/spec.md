# Localization Specification

## Purpose

定義多語系機制：支援的語系、字串來源（ARB）、產生流程，以及「所有使用者可見文字必須經由 l10n」的規則。

## Requirements

### Requirement: 支援 zh-TW 與 en

App SHALL 支援繁體中文（預設，`Locale('zh', 'TW')`）與英文（`Locale('en', 'US')`），並註冊 Material、Widgets、Cupertino 的本地化 delegate。未支援的語系 SHALL 回退到預設。

#### Scenario: 預設語系

- **WHEN** 使用者首次開啟 App
- **THEN** 介面 SHALL 以繁體中文顯示

### Requirement: 字串來源為 ARB 檔

所有字串 SHALL 定義於 `lib/l10n/intl_zh.arb` 與 `lib/l10n/intl_en.arb`（範本 `intl_messages.arb`），以 camelCase key 命名，並經 `dart run intl_utils:generate` 產生 `lib/generated/l10n.dart` 的 `S` 類別。程式碼 SHALL 以 `S.of(context).<key>` 取用。

#### Scenario: 新增字串

- **WHEN** 開發者需要新的使用者可見文字
- **THEN** SHALL 同時在 zh 與 en 的 ARB 新增相同 key 並重新產生，兩個語系都不得缺 key

### Requirement: 列舉與狀態名稱本地化

`FoodItemType`、`FoodItemStatus`、`Unit` 的顯示名稱 SHALL 透過 l10n key（`foodItemType*`、`foodItemStatus*`、`unit*`）取得，不得使用列舉的程式名稱直接顯示。

#### Scenario: 英文下的類型名稱

- **WHEN** 語系為 en 且顯示 `eggAndMilk` 類型
- **THEN** SHALL 顯示 `foodItemTypeEggAndMilk` 的英文值

### Requirement: 禁止硬編碼文字

pages 與 widgets MUST NOT 硬編碼使用者可見的中文或英文字串。既有的硬編碼字串（例如過期處理頁標題、備份還原按鈕、設定頁區塊標題、統計頁「尚無資料」）視為技術債，接觸到該畫面的 change SHALL 一併改為 l10n。

#### Scenario: 切換語系後無殘留

- **WHEN** 使用者切換到英文並瀏覽所有分頁
- **THEN** 不 SHALL 出現任何仍為中文的固定文字
