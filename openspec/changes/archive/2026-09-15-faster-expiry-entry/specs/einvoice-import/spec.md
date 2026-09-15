## MODIFIED Requirements

### Requirement: 草稿在使用者確認前不得寫入

系統 SHALL 在批次匯入前顯示草稿清單，每一列 SHALL 可編輯名稱、類型、數量、單位、期限與存放位置，且 SHALL 可被逐列排除。使用者未執行匯入動作前 SHALL NOT 有任何項目寫入本機儲存。全部列都被排除時匯入動作 SHALL 停用。

「可編輯」指每一個欄位都 SHALL 有實際可達的入口，而不只是顯示。使用者編輯任一欄位後，該列的待確認標示 SHALL 被清除——他已經看過這一列了。

#### Scenario: 編輯名稱

- **WHEN** 使用者在草稿列開啟名稱編輯並改成別的名稱
- **THEN** 該列 SHALL 顯示新名稱，且匯入時 SHALL 寫入新名稱

#### Scenario: 編輯期限

- **WHEN** 使用者在草稿列開啟期限編輯並設為今天
- **THEN** 該列的期限 SHALL 為今天，且匯入後該項目 SHALL 依既有規則推導狀態

#### Scenario: 編輯類型

- **WHEN** 使用者在草稿列把類型改成別的 `FoodItemType`
- **THEN** 該列 SHALL 以新類型的圖示與名稱呈現，且匯入時 SHALL 寫入新類型

#### Scenario: 編輯數量與單位

- **WHEN** 使用者在草稿列修改數量或單位
- **THEN** 該列 SHALL 顯示新的數量與單位，且匯入時 SHALL 寫入新值

#### Scenario: 編輯存放位置

- **WHEN** 使用者在草稿列選擇另一個存放位置
- **THEN** 匯入時 SHALL 以該位置建立項目

#### Scenario: 編輯後清除待確認標示

- **GIVEN** 某一列因為未命中建議而標示 `einvoiceDraftNeedsReview`
- **WHEN** 使用者編輯該列的任一欄位
- **THEN** 該列 SHALL NOT 再顯示 `einvoiceDraftNeedsReview`

#### Scenario: 已排除的列不可編輯

- **WHEN** 使用者對已排除的列嘗試編輯
- **THEN** 系統 SHALL NOT 開啟編輯入口，該列 SHALL 維持排除狀態

#### Scenario: 使用者排除非食物品項

- **WHEN** 使用者將「塑膠袋」該列排除後執行匯入
- **THEN** 系統 SHALL 只寫入未被排除的品項

#### Scenario: 離開草稿頁不寫入

- **WHEN** 使用者在草稿確認畫面按返回
- **THEN** 系統 SHALL NOT 寫入任何項目

#### Scenario: 全部排除

- **WHEN** 使用者排除了所有品項
- **THEN** 匯入動作 SHALL 停用

#### Scenario: 匯入成功的回饋

- **WHEN** 使用者匯入 7 筆品項且全部成功
- **THEN** 系統 SHALL 回到食物清單並以 `einvoiceImported` 顯示匯入筆數
