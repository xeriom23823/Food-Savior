## Purpose

定義以台灣電子發票證明聯的二維條碼批次建立食物的完整流程：相機掃描與雙碼配對、發票內容解析、POS 品名清洗、草稿產生與使用者確認、重複發票防護，以及每一種失敗情境的退路。整段流程完全在裝置上完成，不呼叫任何外部服務。

## ADDED Requirements

### Requirement: 掃描發票需同時取得左右兩個二維條碼

電子發票證明聯的品項資料橫跨左右兩個二維條碼，系統 SHALL 在兩者都取得後才產生草稿。掃描期間 SHALL 持續顯示左碼與右碼各自的取得狀態（`einvoiceLeftCodePending`／`einvoiceLeftCodeDone`／`einvoiceRightCodePending`／`einvoiceRightCodeDone`），使用者才知道還差哪一個。右碼以 `**` 起始；不以 `**` 起始且長度不足的內容 SHALL 視為左碼候選。

#### Scenario: 先掃左碼再掃右碼

- **WHEN** 使用者先掃到左碼、再掃到同一張發票的右碼
- **THEN** 系統 SHALL 合併兩者的品項並進入草稿確認畫面

#### Scenario: 先掃右碼再掃左碼

- **WHEN** 使用者先掃到以 `**` 起始的右碼、再掃到左碼
- **THEN** 系統 SHALL 得到與相反順序完全相同的草稿結果

#### Scenario: 只掃到左碼

- **WHEN** 使用者只掃到左碼且尚未掃到右碼
- **THEN** 系統 SHALL 停留在掃描畫面並顯示 `einvoiceRightCodePending`，且 SHALL NOT 產生草稿

#### Scenario: 左碼宣告的品目筆數已由左碼完整涵蓋

- **WHEN** 左碼宣告該發票品目總筆數為 2，且左碼本身已載有 2 筆品項
- **THEN** 系統 SHALL 直接產生草稿，不要求使用者再掃右碼

#### Scenario: 掃到另一張發票的右碼

- **GIVEN** 已掃到發票 A 的左碼
- **WHEN** 掃到的右碼所屬發票號碼與 A 不符
- **THEN** 系統 SHALL 忽略該右碼並顯示 `einvoiceCodeMismatch`，且 SHALL 保留已取得的左碼

### Requirement: 相機權限被拒時提供可操作的出口

系統 SHALL 在開啟掃描畫面前請求相機權限。權限被拒時 SHALL 顯示 `einvoicePermissionDenied` 說明與兩個出口：前往系統設定、改用手動新增。SHALL NOT 顯示空白畫面或直接關閉。

#### Scenario: 使用者拒絕相機權限

- **WHEN** 使用者拒絕相機權限
- **THEN** 系統 SHALL 顯示 `einvoicePermissionDenied` 與「前往設定」、「改為手動新增」兩個動作

#### Scenario: 裝置沒有可用相機

- **WHEN** 裝置不具備可用的相機
- **THEN** 系統 SHALL 顯示 `einvoiceCameraUnavailable` 並提供「改為手動新增」

### Requirement: 左碼解析出發票識別資料

系統 SHALL 從左碼固定長度的前段解析出發票字軌與號碼（10 字）、開立日期（民國 `yyyMMdd`，7 字）、隨機碼（4 字）、銷售額與總計額（各 8 字，16 進位）、買方與賣方統一編號（各 8 字）。開立日期 SHALL 以民國年加 1911 換算為西元年，並以**裝置當地日期**建構為當日零時。

#### Scenario: 民國日期換算

- **WHEN** 左碼的日期欄位為 `1150915`
- **THEN** 系統 SHALL 解析為當地時間 2026 年 9 月 15 日零時

#### Scenario: 金額為 16 進位

- **WHEN** 左碼的總計額欄位為 `000001f4`
- **THEN** 系統 SHALL 解析為 500

#### Scenario: 左碼長度不足

- **WHEN** 掃到的內容不以 `**` 起始且長度少於 77 字
- **THEN** 系統 SHALL 回報 `einvoiceParseFailed` 並停留在掃描畫面等待重掃

### Requirement: 品項切割以品目筆數為準

品名內可能含有分隔字元 `:`，因此系統 SHALL 以左碼宣告的「二維條碼記載品目筆數」與「該張發票品目總筆數」為準切割品項三元組（品名、數量、單價），SHALL NOT 以分隔字元的出現次數決定品項數。數量與單價無法解析為數字時，該欄 SHALL 視為未知而非讓整張發票解析失敗。

#### Scenario: 品名內含冒號

- **WHEN** 某品項的品名為 `蔬菜:高麗菜` 且左碼宣告該區有 1 筆品項
- **THEN** 系統 SHALL 產生 1 筆品項，其品名為 `蔬菜:高麗菜`

#### Scenario: 單價無法解析

- **WHEN** 某品項的單價欄位不是數字
- **THEN** 系統 SHALL 保留該品項且其金額為未知，其餘品項不受影響

#### Scenario: 實際品項數少於宣告筆數

- **WHEN** 左碼宣告品目總筆數為 5，但左右碼合計只解析出 3 筆
- **THEN** 系統 SHALL 以實際解析到的 3 筆產生草稿，並顯示 `einvoiceItemsIncomplete` 提醒使用者自行補齊

### Requirement: 中文編碼參數決定品名解碼方式

系統 SHALL 依左碼的中文編碼參數解碼品名：`1` 為 UTF-8、`2` 為 Base64 編碼的 UTF-8。編碼參數為 `0`（Big5）時系統 SHALL NOT 猜測解碼結果，而是回報 `einvoiceEncodingUnsupported` 並提供「改為手動新增」。

#### Scenario: Base64 編碼的品名

- **WHEN** 編碼參數為 `2` 且品名欄位為合法 Base64
- **THEN** 系統 SHALL 解碼為對應的 UTF-8 文字

#### Scenario: Big5 編碼

- **WHEN** 編碼參數為 `0`
- **THEN** 系統 SHALL 顯示 `einvoiceEncodingUnsupported` 並提供「改為手動新增」，SHALL NOT 顯示亂碼品名

### Requirement: POS 品名清洗為核心名稱與規格

系統 SHALL 將發票品名清洗為「核心名稱」與可選的「規格」。清洗 SHALL 移除括號內容、促銷與通路雜訊詞、溫層標示，並抽出可辨識的規格轉為數量與單位。清洗結果為空字串時 SHALL 退回使用原始品名，SHALL NOT 產生無名稱的草稿。

#### Scenario: 剝除促銷字樣

- **WHEN** 發票品名為 `統一AB優酪乳400ML特價`
- **THEN** 核心名稱 SHALL 包含 `優酪乳`，且數量 SHALL 為 400、單位 SHALL 為 `milliliter`

#### Scenario: 剝除溫層與括號

- **WHEN** 發票品名為 `【冷藏】梅花豬肉片(約300g)`
- **THEN** 核心名稱 SHALL 包含 `梅花豬肉片`，且數量 SHALL 為 300、單位 SHALL 為 `gram`

#### Scenario: 以「入」表示的件數

- **WHEN** 發票品名為 `量販-雞蛋10入`
- **THEN** 核心名稱 SHALL 包含 `雞蛋`，且數量 SHALL 為 10、單位 SHALL 為 `piece`

#### Scenario: 清洗後為空

- **WHEN** 發票品名清洗後不剩任何文字
- **THEN** 系統 SHALL 以原始品名作為草稿名稱

### Requirement: 草稿欄位沿用既有的建議機制

系統 SHALL 以清洗後的核心名稱透過既有的食物建議機制（使用者歷史模板優先、其次內建保存期限對照表）決定草稿的類型、單位與建議到期日；兩者都沒有命中時類型 SHALL 為 `others` 且期限 SHALL 為未知。草稿的存放日期 SHALL 為發票開立日期；有單價與數量時草稿金額 SHALL 為兩者乘積四捨五入為整數。品名清洗抽出的規格 SHALL 優先於建議機制提供的數量與單位。

#### Scenario: 名稱命中內建對照表

- **WHEN** 清洗後名稱為 `雞蛋` 且發票日期為 2026 年 9 月 15 日
- **THEN** 草稿類型 SHALL 為 `eggAndMilk`，存放日期 SHALL 為 2026 年 9 月 15 日，到期日 SHALL 依對照表推算

#### Scenario: 名稱未命中任何來源

- **WHEN** 清洗後名稱不命中任何模板與對照表項目
- **THEN** 草稿類型 SHALL 為 `others`、期限 SHALL 為未知，且該列 SHALL 以 `einvoiceDraftNeedsReview` 標示待確認

#### Scenario: 規格優先於建議單位

- **WHEN** 清洗抽出 400 milliliter，而對照表對該名稱建議單位為 `bottle`
- **THEN** 草稿數量 SHALL 為 400、單位 SHALL 為 `milliliter`

#### Scenario: 金額由單價與數量推算

- **WHEN** 某品項數量為 2、單價為 45
- **THEN** 草稿金額 SHALL 為 90

### Requirement: 草稿在使用者確認前不得寫入

系統 SHALL 在批次匯入前顯示草稿清單，每一列 SHALL 可編輯名稱、類型、數量、單位、期限與存放位置，且 SHALL 可被逐列排除。使用者未執行匯入動作前 SHALL NOT 有任何項目寫入本機儲存。全部列都被排除時匯入動作 SHALL 停用。

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

### Requirement: 重複匯入需經使用者確認

系統 SHALL 記錄已成功匯入的發票號碼。再次掃到同一發票號碼時 SHALL 顯示 `einvoiceAlreadyImported` 並要求使用者明確選擇是否再匯入一次；使用者未確認前 SHALL NOT 產生草稿。

#### Scenario: 掃到已匯入過的發票

- **WHEN** 使用者掃到先前已成功匯入的發票號碼
- **THEN** 系統 SHALL 顯示 `einvoiceAlreadyImported` 並提供「仍要匯入」與「取消」

#### Scenario: 使用者選擇仍要匯入

- **WHEN** 使用者在重複警告中選擇「仍要匯入」
- **THEN** 系統 SHALL 照常產生草稿並允許完成匯入

### Requirement: 掃描入口僅在支援的平台出現

掃描功能依賴行動裝置的相機能力，系統 SHALL 僅在 Android 與 iOS 顯示掃描入口。其他平台 SHALL NOT 顯示入口，且專案 SHALL 維持可編譯。

#### Scenario: 在桌面平台開啟食物分頁

- **WHEN** App 執行於桌面或 Web 平台
- **THEN** 食物分頁 SHALL NOT 顯示掃描發票入口，其餘功能不受影響
