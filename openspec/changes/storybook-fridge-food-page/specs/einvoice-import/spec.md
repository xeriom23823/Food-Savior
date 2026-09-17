## ADDED Requirements

### Requirement: 匯入完成回到清單時有回饋

使用者確認匯入後回到食物清單時，系統 SHALL 顯示 `einvoiceImported` 訊息，匯入建立的每一列 SHALL 以進場動態出現在各自所屬的層架（依當時的分群方式），觸覺回饋 SHALL 只觸發一次「確認」級，音效 SHALL 只播放一次「啵」，MUST NOT 依筆數重複。匯入 0 筆時 MUST NOT 有任何上述回饋。系統「減少動態」開啟時列 SHALL 直接出現。匯入的資料結果 MUST 與回饋無關，由既有的「草稿在使用者確認前不得寫入」與批次建立規則決定。

#### Scenario: 匯入五筆

- **WHEN** 使用者確認匯入 5 筆草稿並回到清單
- **THEN** 系統 SHALL 顯示 `einvoiceImported(5)`，5 列依序進場，觸覺一次、音效一聲

#### Scenario: 取消匯入

- **WHEN** 使用者在草稿頁取消而未匯入任何一筆
- **THEN** 回到清單時 MUST NOT 顯示 `einvoiceImported`，也不觸發觸覺或音效
