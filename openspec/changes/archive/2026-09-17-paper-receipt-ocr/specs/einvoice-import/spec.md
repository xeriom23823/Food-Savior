## MODIFIED Requirements

### Requirement: 掃描入口僅在支援的平台出現

掃描功能依賴行動裝置的相機能力，系統 SHALL 僅在 Android 與 iOS 顯示掃描入口。其他平台 SHALL NOT 顯示入口，且專案 SHALL 維持可編譯。

匯入的來源不只一種，因此入口 SHALL 先讓使用者選擇來源：掃描電子發票的二維條碼，或拍攝紙本收據。兩者 SHALL 有各自的說明，讓使用者知道手上的單據該選哪一個。

在有掃描入口的每一個平台上，「前往系統設定」這個出口 SHALL 實際開啟該平台的應用程式設定頁；SHALL NOT 顯示一顆按下去沒有反應的按鈕。無法開啟時 SHALL NOT 拋出例外。

#### Scenario: 在桌面平台開啟食物分頁

- **WHEN** App 執行於桌面或 Web 平台
- **THEN** 食物分頁 SHALL NOT 顯示掃描發票入口，其餘功能不受影響

#### Scenario: 選擇掃描電子發票

- **WHEN** 使用者在來源選擇中選「掃描電子發票」
- **THEN** 系統 SHALL 進入二維條碼掃描流程，行為與先前一致

#### Scenario: 選擇拍攝紙本收據

- **WHEN** 使用者在來源選擇中選「拍攝紙本收據」
- **THEN** 系統 SHALL 進入收據拍照與辨識流程

#### Scenario: 取消來源選擇

- **WHEN** 使用者關閉來源選擇而不選任何一項
- **THEN** 系統 SHALL 回到食物清單，SHALL NOT 開啟相機

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
