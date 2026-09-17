## MODIFIED Requirements

### Requirement: 滑動操作面板

每筆現存食物（或合併後的卡片）SHALL 提供滑動操作：起始側為 `edit`；結束側依序為 `waste`（記錄丟棄）、`partialUse`（部分處理）、`useAll`（全部使用）。操作後面板 SHALL 自動收合。對合併卡片操作時，SHALL 依有效期限由早到晚（FEFO）作用於組內各批次。

操作確認後的列呈現 SHALL 如下：`useAll` 與 `waste` 使該列離開清單時，該列 SHALL 先以離場動態離開層架（`useAll` 縮小滑出、`waste` 往下滑出），其餘列平順補位後才完全消失；`partialUse` 後該列 SHALL 留在原位，以短暫動態標示份量已變（若剩餘為 0 則同 `useAll` 離場）。資料寫入 MUST 在操作確認當下完成，不等離場動態；離場動態進行中 SHALL 可對其他列操作。系統「減少動態」開啟時列 SHALL 直接消失或直接更新。

#### Scenario: 展開結束側面板

- **WHEN** 使用者向左滑動一筆食物
- **THEN** 系統 SHALL 顯示 `waste`、`partialUse`、`useAll` 三個動作

#### Scenario: 對合併卡片全部使用

- **WHEN** 使用者對「雞蛋 18 個」（10 個 3 天後到期、8 個 10 天後到期）選擇 `useAll`
- **THEN** 系統 SHALL 產生兩筆 `UsedFoodItem`，各自帶自己的期限，並各自計算點數

#### Scenario: 全部使用的離場

- **WHEN** 使用者對一筆食物選擇 `useAll`
- **THEN** 該列 SHALL 縮小滑出層架後消失，其餘列平順補位；使用紀錄在操作當下即有對應紀錄

#### Scenario: 部分使用後留在原位

- **WHEN** 使用者對份量 5 個的食物部分使用 2 個
- **THEN** 該列 SHALL 留在原位、彈跳一下，份量顯示更新為 3 個

#### Scenario: 減少動態

- **GIVEN** 裝置的無障礙設定要求減少動態
- **WHEN** 使用者對一筆食物選擇 `waste` 並確認
- **THEN** 該列 SHALL 直接從清單消失，不播放離場動態
