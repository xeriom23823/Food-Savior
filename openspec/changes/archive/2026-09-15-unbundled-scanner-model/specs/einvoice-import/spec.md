## MODIFIED Requirements

### Requirement: 相機權限被拒時提供可操作的出口

系統 SHALL 在開啟掃描畫面前請求相機權限。權限被拒時 SHALL 顯示 `einvoicePermissionDenied` 說明與兩個出口：前往系統設定、改用手動新增。SHALL NOT 顯示空白畫面或直接關閉。

掃描無法進行的原因不只一種，系統 SHALL 依原因給不同的訊息與不同的出口，因為使用者能做的事不同：

| 原因 | 訊息 | 出口 |
|---|---|---|
| 權限被拒 | `einvoicePermissionDenied` | 前往系統設定、改為手動新增 |
| 裝置沒有相機 | `einvoiceCameraUnavailable` | 改為手動新增（不可重試） |
| 掃描元件尚未就緒 | `einvoiceScannerNotReady` | 重試、改為手動新增 |

「掃描元件尚未就緒」涵蓋條碼解碼元件需要由系統服務準備、而準備尚未完成或無法完成的情形。系統 SHALL NOT 把這種情形顯示為「沒有相機」——相機是好的，而且使用者稍後重試通常就能成功；顯示成不可回復的錯誤會讓他放棄。

#### Scenario: 使用者拒絕相機權限

- **WHEN** 使用者拒絕相機權限
- **THEN** 系統 SHALL 顯示 `einvoicePermissionDenied` 與「前往設定」、「改為手動新增」兩個動作

#### Scenario: 裝置沒有可用相機

- **WHEN** 裝置不具備可用的相機
- **THEN** 系統 SHALL 顯示 `einvoiceCameraUnavailable` 並提供「改為手動新增」，且 SHALL NOT 提供重試

#### Scenario: 掃描元件尚未就緒

- **WHEN** 條碼解碼元件尚未準備完成
- **THEN** 系統 SHALL 顯示 `einvoiceScannerNotReady` 並同時提供「重試」與「改為手動新增」

#### Scenario: 重試後成功

- **GIVEN** 先前因為掃描元件尚未就緒而無法掃描
- **WHEN** 使用者按下重試且元件此時已就緒
- **THEN** 系統 SHALL 進入掃描狀態並顯示相機預覽

#### Scenario: 不把尚未就緒誤報為沒有相機

- **WHEN** 掃描無法進行的原因是元件尚未就緒
- **THEN** 系統 SHALL NOT 顯示 `einvoiceCameraUnavailable`

### Requirement: 掃描入口僅在支援的平台出現

掃描功能依賴行動裝置的相機能力，系統 SHALL 僅在 Android 與 iOS 顯示掃描入口。其他平台 SHALL NOT 顯示入口，且專案 SHALL 維持可編譯。

在有掃描入口的每一個平台上，「前往系統設定」這個出口 SHALL 實際開啟該平台的應用程式設定頁；SHALL NOT 顯示一顆按下去沒有反應的按鈕。無法開啟時 SHALL NOT 拋出例外。

#### Scenario: 在桌面平台開啟食物分頁

- **WHEN** App 執行於桌面或 Web 平台
- **THEN** 食物分頁 SHALL NOT 顯示掃描發票入口，其餘功能不受影響

#### Scenario: Android 上前往系統設定

- **GIVEN** 相機權限已被拒絕且掃描畫面顯示 `einvoicePermissionDenied`
- **WHEN** 使用者按下「前往設定」
- **THEN** 系統 SHALL 開啟本 App 的系統設定頁

#### Scenario: iOS 上前往系統設定

- **GIVEN** 相機權限已被拒絕且掃描畫面顯示 `einvoicePermissionDenied`
- **WHEN** 使用者在 iOS 上按下「前往設定」
- **THEN** 系統 SHALL 開啟本 App 的系統設定頁

#### Scenario: 沒有原生實作的平台

- **WHEN** 在沒有對應原生實作的平台上請求開啟系統設定
- **THEN** 系統 SHALL 回報未能開啟，SHALL NOT 拋出例外或中斷畫面
