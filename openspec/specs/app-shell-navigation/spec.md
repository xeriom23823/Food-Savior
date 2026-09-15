# App Shell Navigation Specification

## Purpose

定義主畫面外殼：五個分頁的組成與順序、底部導覽列行為、螢幕方向限制、啟動順序，以及 Bloc／Repository 的提供範圍。

## Requirements

### Requirement: 五個分頁與預設分頁

主畫面 SHALL 包含五個分頁，順序為：使用者（`userNavigationBarTitle`）、圖表（`chartAndStatisticsNavigationBarTitle`）、食物（`foodItemListNavigationBarTitle`）、紀錄（`usedFoodItemListNavigationBarTitle`）、設定（`settingsNavigationBarTitle`）。登入後 SHALL 預設顯示第三個分頁「食物」。

#### Scenario: 登入後的初始畫面

- **WHEN** 使用者登入完成
- **THEN** 系統 SHALL 顯示食物清單分頁，底部導覽列選中「食物」

### Requirement: 底部導覽列切換

底部導覽列 SHALL 顯示五個含圖示與標題的項目；點擊 SHALL 以動畫切換到對應分頁。分頁內容 SHALL 不可左右滑動切換。

#### Scenario: 點擊設定

- **WHEN** 使用者點擊「設定」
- **THEN** 系統 SHALL 顯示設定頁並更新導覽列選中狀態

#### Scenario: 左右滑動

- **WHEN** 使用者在分頁內容上左右滑動
- **THEN** 分頁 SHALL 不切換

### Requirement: 直向鎖定

App SHALL 鎖定為直向（portrait up）。

#### Scenario: 旋轉裝置

- **WHEN** 使用者將裝置轉為橫向
- **THEN** 畫面 SHALL 維持直向

### Requirement: 啟動順序

App SHALL 依序：初始化 Firebase → 等待第一個 Auth 狀態 → 初始化 Hive 並開啟 Box → 建立 Repository → runApp。任何一步失敗 SHALL 不進入主畫面。

#### Scenario: 正常啟動

- **WHEN** 所有初始化成功
- **THEN** 系統 SHALL 依登入狀態顯示登入頁或主畫面

### Requirement: Bloc 與 Repository 的提供範圍

`FoodItemRepository` 與 `UsedFoodItemRepository` SHALL 在 App 根層提供；`FoodItemListBloc` 與 `UsedFoodItemListBloc` SHALL 在主畫面外殼層建立並於建立時自本機載入資料，供五個分頁共用同一個實例。`ThemeCubit` 與 `LocaleCubit` SHALL 在 MaterialApp 之上提供。

#### Scenario: 跨分頁共享狀態

- **WHEN** 使用者在食物分頁使用一筆食物後切到紀錄分頁
- **THEN** 紀錄分頁 SHALL 看到同一個 Bloc 實例中的新紀錄，無需重新載入 App
