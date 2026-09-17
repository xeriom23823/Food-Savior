## MODIFIED Requirements

### Requirement: 載入時偵測過期並進入處理狀態

當清單從本機載入或由還原流程載入時，若存在狀態為 `expired` 的項目，系統 SHALL 進入 `FoodItemListNeedProcessing` 狀態，並保存三組資料：未過期的剩餘項目、待處理的過期項目，以及每個過期項目「是否食用」的勾選狀態（預設全部未勾選）。此狀態下 SHALL 顯示過期處理畫面而非一般清單。

過期處理畫面 SHALL 在頁首顯示「吉娃娃幫你清冰箱」的品牌插圖與一句中性說明（`expiredProcessingIntro`），語氣 MUST NOT 責備；每筆過期食物 SHALL 以該類型的食物角色插畫呈現，並保留名稱、份量、到期日與「已食用」切換。畫面 SHALL 使用與食物頁相同的繪本層。插圖與說明 MUST NOT 改變任何預設值、勾選行為或處理完成的結果。

#### Scenario: 啟動時有過期食物

- **WHEN** App 啟動且本機有 2 筆到期日早於現在的食物
- **THEN** 系統 SHALL 顯示過期處理畫面，頁首有插圖與 `expiredProcessingIntro`，列出這 2 筆並預設皆為未食用

#### Scenario: 啟動時無過期食物

- **WHEN** App 啟動且沒有任何過期食物
- **THEN** 系統 SHALL 直接進入一般清單

#### Scenario: 過期列的呈現

- **WHEN** 過期處理畫面列出一筆 `meat` 類型的食物
- **THEN** 該列 SHALL 顯示肉類角色插畫、名稱、份量、到期日與「已食用」切換
