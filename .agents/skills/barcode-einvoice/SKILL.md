---
name: barcode-einvoice
description: Food Savior 的條碼／QR 掃描與台灣電子發票整合指引：mobile_scanner 設定與權限、電子發票證明聯 QR 結構解析、財政部電子發票 API（載具／手機條碼）串接架構、發票品項對應成 FoodItem 草稿、隱私與測試 fixture。開發掃描或載具綁定 change 時必讀。
---

# 條碼／QR 掃描與電子發票載具

> 財政部 API 與 QR 規格會改版。實作前務必到「財政部電子發票整合服務平台」下載最新的《電子發票證明聯二維條碼規格》與《電子發票應用 API 規格》，並在 change 的 design.md 記錄版本與日期。以下是架構與已知結構，不是官方文件的替代品。

## 兩條路徑

| 路徑 | 使用者做什麼 | 得到什麼 | 難度 |
|---|---|---|---|
| A. 掃描發票 QR | 對紙本發票左右兩個 QR 掃描 | 發票號碼、日期、品項名稱／數量／單價 | 中（離線可解） |
| B. 載具綁定 | 輸入手機條碼 + 驗證碼授權 | 該載具下所有發票與明細（雲端） | 高（需 AppID、後端代理、法規） |

建議順序：A 先做（獨立、無後端），B 作為獨立 change。

## 掃描（路徑 A 與商品條碼）

- 套件：`mobile_scanner`（Android ML Kit / iOS AVFoundation）。權限：Android `CAMERA`；iOS `NSCameraUsageDescription`（字串走 l10n 需在 Info.plist 用 `InfoPlist.strings` 多語）。
- 格式白名單：發票用 `BarcodeFormat.qrCode`；商品用 `ean13`／`ean8`／`upcA`。
- 發票需**兩個 QR 都掃到**才有完整品項：UI 顯示「左碼 ✓ 右碼 ✓」進度；同一張的判定 = 左碼的發票號碼 + 右碼以 `**` 開頭且在 10 秒內掃到。
- 商品條碼查名稱：沒有免費官方台灣商品資料庫；可用 Open Food Facts `GET https://world.openfoodfacts.org/api/v2/product/{barcode}.json`（best-effort，命中率低），查不到就讓使用者手填，並把「條碼 → 名稱／類型」存在本機 Box `barcodeMemory` 供下次自動帶入。

## 電子發票 QR 結構（依官方規格核對）

**左碼**（固定 77 字後接 `:` 分隔區）：

| 位置 | 長度 | 內容 |
|---|---|---|
| 1–10 | 10 | 發票字軌（2 英文）+ 號碼（8 數字） |
| 11–17 | 7 | 開立日期，民國 `yyyMMdd`（例 `1150915` = 2026-09-15） |
| 18–21 | 4 | 隨機碼 |
| 22–29 | 8 | 銷售額（16 進位） |
| 30–37 | 8 | 總計額（16 進位） |
| 38–45 | 8 | 買方統編（無則 `00000000`） |
| 46–53 | 8 | 賣方統編 |
| 54–77 | 24 | 加密驗證資訊 |
| 之後 | — | `:營業人自行使用區(10):二維條碼記載品目筆數(2):該張發票品目總筆數(2):中文編碼參數(1):品名:數量:單價:品名:數量:單價…` |

**右碳**：以 `**` 開頭，接續剩餘的 `品名:數量:單價` 三元組。

- 中文編碼參數：`0` Big5、`1` UTF-8、`2` Base64（UTF-8）。Big5 需 `charset_converter` 或 `fast_gbk` 類套件，或在解析器中以查表處理；先支援 1 與 2，遇 0 提示手動輸入。
- 品名內可能含 `:`（規格允許以其他方式轉義）→ 解析器要以「品目筆數」為準切割，不要單純 split。
- 把真實掃到的字串（去除統編／驗證碼）存成 `test/fixtures/einvoice/*.txt`，解析器測試以 fixture 驅動。

## 載具 API（路徑 B）架構

- 平台：財政部電子發票整合服務平台「電子發票應用 API」。需以營業人或開發者身分申請 **AppID**；API 有 `cardEncrypt`（載具驗證碼）等敏感參數 → **必須經 Cloud Functions 代理**，App 不持有 AppID。
- 常用 action（消費者查詢，以手機條碼 `cardType=3J0002`）：
  - `carrierInvChk`：查詢載具在期間內的發票表頭（`startDate`／`endDate` 民國格式、`onlyWinningInv`）
  - `carrierInvDetail`：查單張發票明細（品名、數量、單價）
  - 共用參數：`version`、`cardType`、`cardNo`（手機條碼 `/` + 7 碼）、`expTimeStamp`、`timeStamp`、`uuid`、`appID`、`cardEncrypt`
- 使用者流程：輸入手機條碼與驗證碼 → 後端驗證並回傳最近 N 天發票 → App 列出可匯入的品項 → 使用者勾選 → 轉為 `FoodItem` 草稿。
- 隱私：發票明細是個人消費資料。要有明確同意畫面、只保存轉成食物的品項、提供「解除綁定並刪除」；驗證碡不落地（只在單次請求中使用，或以 Secret Manager 加密保存且可撤銷）。
- 節流：API 有頻率限制；後端快取表頭 24 小時。

## 品項 → FoodItem 草稿

- `name` ← 品名（去除促銷字樣，可用簡單規則），使用者可改。
- `quantity` ← 數量（四捨五入為整數）；`unit` 預設 `piece`；品名含「g」「公克」「ml」時對應 `gram`／`milliliter`。
- `storageDate` ← 發票日期；`expirationDate` ← 依類型的預設保存天數表（放在 spec，例如蔬菜 5、水果 7、肉類 3、蛋奶 10、罐頭 365）；使用者確認時可改。
- `type` ← 關鍵字表猜測（「雞」「豬」「牛」→ meat；「奶」「蛋」→ eggAndMilk …），猜不到 → `others` 並在 UI 標示待確認。
- 匯入畫面：草稿清單 + 每列可編輯 + 「全部加入」；加入走既有 `FoodItemListAdd`（一筆一 event 或新增 `FoodItemListAddMany`）。

## 架構與檔案

```
lib/services/scanner/         mobile_scanner 封裝（ScannerService 介面 + 實作）
lib/domain/einvoice/          EInvoiceQrParser（純 Dart，fixture 測試）、EInvoice/EInvoiceItem model
lib/domain/import/            FoodItemDraftMapper（品項 → 草稿，純 Dart，單元測試）
lib/bloc/import/              ImportBloc（掃描進度、草稿清單、確認匯入）
lib/pages/import/             掃描頁、草稿確認頁
functions/                    （路徑 B）Cloud Functions 代理
```

## 測試

- 解析器：fixture 驅動，涵蓋 UTF-8／Base64、品名含冒號、只有左碼、右碼先掃到。
- Mapper：每種類型關鍵字至少一案例；預設天數表。
- Bloc：`FakeScannerService` 餵事件。
- 實機：真紙本發票（光線不足、反光）、Android 與 iOS 各一台；相機權限拒絕後的畫面。
