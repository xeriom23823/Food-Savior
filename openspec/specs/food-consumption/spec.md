# Food Consumption Specification

## Purpose

定義使用者如何把現存食物標記為「已食用」或「已浪費」：全部使用、部分使用、直接浪費，以及一次操作同時記錄食用與丟棄。每筆紀錄帶有處理方式與浪費原因，並同時更新現存清單與使用紀錄。這些操作是食物點數的主要來源。

## Requirements

### Requirement: 滑動操作面板

每筆現存食物（或合併後的卡片）SHALL 提供滑動操作：起始側為 `edit`；結束側依序為 `waste`（記錄丟棄）、`partialUse`（部分處理）、`useAll`（全部使用）。操作後面板 SHALL 自動收合。對合併卡片操作時，SHALL 依有效期限由早到晚（FEFO）作用於組內各批次。

#### Scenario: 展開結束側面板

- **WHEN** 使用者向左滑動一筆食物
- **THEN** 系統 SHALL 顯示 `waste`、`partialUse`、`useAll` 三個動作

#### Scenario: 對合併卡片全部使用

- **WHEN** 使用者對「雞蛋 18 個」（10 個 3 天後到期、8 個 10 天後到期）選擇 `useAll`
- **THEN** 系統 SHALL 產生兩筆 `UsedFoodItem`，各自帶自己的期限，並各自計算點數

### Requirement: 全部使用

使用者選擇 `useAll` 時，系統 SHALL 從現存清單移除該項目，並新增一筆 `UsedFoodItem`：`disposalMethod` 為 `eaten`（有效期限已過時為 `eatenAtRisk`）、狀態 `consumed`、份量為該項目全部份量、使用日期為當下、id 為新 UUID、`priceTotal` 沿用該項目金額。系統 SHALL 以「名稱 + 份量 + `consumed`」訊息與食用回饋提示。

#### Scenario: 全部使用一筆食物

- **WHEN** 使用者對份量 3 個的雞蛋選擇 `useAll`
- **THEN** 雞蛋 SHALL 從清單消失，使用紀錄新增一筆份量 3、狀態 `consumed`、`disposalMethod` 為 `eaten` 的雞蛋

#### Scenario: 過期後才吃掉

- **WHEN** 使用者對一筆已過期的食物選擇 `useAll`
- **THEN** 新紀錄的 `disposalMethod` SHALL 為 `eatenAtRisk`

### Requirement: 標記浪費

使用者選擇 `waste` 時，系統 SHALL 顯示輕量的原因選擇（`forgotten`、`boughtTooMuch`、`spoiled`、`disliked`、`expiredTooLong`、`other`）與處理方式（`discarded`、`composted`、`givenAway`，預設 `discarded`），兩者皆 SHALL 可跳過。確認後 SHALL 從現存清單移除該項目，並新增一筆 `UsedFoodItem`：份量為全部、使用日期為當下、`wasteReason` 與 `disposalMethod` 為所選值、狀態依 `disposalMethod` 推導（`givenAway` 為 `consumed`，其餘為 `wasted`）。

#### Scenario: 丟棄並選原因

- **WHEN** 使用者對一筆食物選擇 `waste`，原因選「忘記吃」、處理方式保持「丟棄」
- **THEN** 使用紀錄 SHALL 新增一筆 `wasted`、`wasteReason = forgotten`、`disposalMethod = discarded` 的紀錄

#### Scenario: 跳過原因

- **WHEN** 使用者選擇 `waste` 後直接確認而不選原因
- **THEN** 系統 SHALL 建立 `wasteReason` 為 null 的紀錄，MUST NOT 阻擋操作

#### Scenario: 送給別人不算浪費

- **WHEN** 使用者將處理方式選為 `givenAway`
- **THEN** 新紀錄狀態 SHALL 為 `consumed`，且在統計中 MUST NOT 計入浪費筆數

#### Scenario: 丟棄一筆食物

- **WHEN** 使用者對一筆食物選擇 `waste` 並確認
- **THEN** 該食物 SHALL 從清單消失，使用紀錄新增一筆 `wasted` 紀錄

### Requirement: 部分使用需驗證數量與日期

使用者選擇 `partialUse` 時，系統 SHALL 顯示表單，可同時填寫「食用份量」與「丟棄份量」與使用日期（預設今天，可選擇）。兩個份量 SHALL 至少其一大於 0，且兩者合計 MUST NOT 超過現有份量，否則分別顯示 `amountCannotBeEmpty`、`amountMustBePositive`、`amountExceedsAvailable`。送出後：剩餘份量大於 0 時 SHALL 更新該項目份量並保留在清單；剩餘為 0 時 SHALL 移除該項目。系統 SHALL 為食用與丟棄**各新增一筆** `UsedFoodItem`（份量為 0 者不建立），使用日期為所選日期。若該項目有 `priceTotal`，新紀錄的金額 SHALL 依份量比例攤提並四捨五入為整數。

#### Scenario: 同時食用與丟棄

- **WHEN** 使用者對份量 5 的蘋果輸入食用 3、丟棄 2 並送出
- **THEN** 蘋果 SHALL 從清單移除，使用紀錄 SHALL 新增兩筆：份量 3 的 `consumed` 與份量 2 的 `wasted`

#### Scenario: 只食用部分

- **WHEN** 使用者對份量 5 的蘋果輸入食用 2、丟棄 0
- **THEN** 清單中蘋果份量 SHALL 變為 3，使用紀錄新增一筆份量 2 的 `consumed`，MUST NOT 建立份量 0 的紀錄

#### Scenario: 使用部分數量

- **WHEN** 使用者對份量 5 的蘋果輸入食用 2、日期今天並送出
- **THEN** 清單中蘋果份量 SHALL 變為 3，使用紀錄新增一筆份量 2 的 `consumed` 蘋果

#### Scenario: 使用全部數量

- **WHEN** 使用者對份量 5 的蘋果輸入食用 5
- **THEN** 蘋果 SHALL 從清單移除，使用紀錄新增一筆份量 5 的 `consumed` 紀錄

#### Scenario: 數量超過現有

- **WHEN** 使用者對份量 5 的蘋果輸入食用 6
- **THEN** 系統 SHALL 顯示 `amountExceedsAvailable` 且不改變任何資料

#### Scenario: 合計超過現有

- **WHEN** 使用者對份量 5 的蘋果輸入食用 4、丟棄 2
- **THEN** 系統 SHALL 顯示 `amountExceedsAvailable` 且不改變任何資料

#### Scenario: 金額依比例攤提

- **WHEN** 一筆份量 10、金額 100 元的食物被使用 3
- **THEN** 新紀錄的 `priceTotal` SHALL 為 30，清單中剩餘項目的 `priceTotal` SHALL 為 70

#### Scenario: 以剩餘比例記錄的項目

- **WHEN** 使用者對以 `remainingFraction` 記錄的項目選擇 `partialUse`
- **THEN** 表單 SHALL 改為選擇「用掉後還剩多少」的比例，剩餘為 `almostGone` 以下（即用完）時該項目 SHALL 從清單移除

#### Scenario: 指定過去日期

- **WHEN** 使用者將使用日期選為 3 天前
- **THEN** 新增的使用紀錄 SHALL 以該日期為使用日期，並影響該日的食物點數計算
