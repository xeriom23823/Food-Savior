# Food-Savior 食物救世主

這是一個紀錄生鮮食物保存期限並給予使用者提醒的手機應用程式，希望使用者使用後可以清楚知道家裡生鮮食物的保存期限狀況，並透過獎勵與懲罰機制希望使用者不要浪費食物。

## 功能

### 記錄食物

- [x] 一行快速新增：只打名稱就能入庫，類型／單位／效期由常用模板與內建對照表離線推導，未命中則標記「待補期限」
- [x] 四種期限精度：精確到日、區間（約 3〜5 天）、只知道月份、完全未知——不確定的也能先記下來
- [x] 開封後效期（`openedDate` + 開封後天數，取較早者）、小數份量或剩餘比例（滿／大部分／一半／不多／剩一點）、選填成本
- [x] 自訂存放位置（冷藏／冷凍／常溫／其他），可建立、命名、排序、刪除
- [x] 掃描台灣電子發票證明聯 QR 批次建立食物（雙碼配對、POS 品名清洗，全程離線）

### 看清楚

- [x] 清單分群：依到期急迫度／存放位置／食物類型切換，選擇會記住
- [x] 同名批次自動合併成一張卡（「雞蛋 18 個 · 3 批」），展開看各批次期限，食用時預設從最早到期的批次扣（FEFO）
- [x] 統計圖表六區塊：類型分布（筆數）、月趨勢、浪費率趨勢、最常浪費 Top 5、浪費原因分佈、金額損益

### 用掉或丟掉

- [x] 過期食物處理流程（啟動時逐項決定已食用或已浪費）
- [x] 全部使用／部分使用／直接浪費，一次操作可同時記「吃了 3 個、丟了 2 個」
- [x] 記錄浪費原因（忘記吃／買太多／壞掉／不好吃／放到過期太久）與處理方式（吃掉／冒風險吃掉／送人／堆肥／丟棄）
- [x] 食物點數依時效加權：即期救援 +3、正常食用 +2、過期才吃或冒風險吃 +1、堆肥 −1〜−2、丟棄 −2〜−3；每日加分上限 10（以當日加分總和計算）
- [x] 等級與里程碑：五個等級（見習生 → 零浪費大師）、六個一次性里程碑、距上次浪費天數

### 其他

- [x] Email／Google 登入、修改顯示名稱、重設密碼、刪除帳號
- [x] 雲端手動備份與還原（Firestore）
- [x] 多語系（繁體中文、English）與深色模式
- [x] Material 3 設計系統：token 化主題（seed `#3E8E5A`）、狀態語意色、共用元件庫、loading／empty／error 三態

### 規劃中

- [ ] 生鮮食物過期提醒（本機通知）
- [ ] 電子發票載具綁定，自動記錄
- [ ] Hive ↔ Firestore 雙向同步
- [ ] 提醒時透過 AI 推薦料理

## 技術棧

Flutter 3.47 / Dart 3.13、flutter_bloc 9、Hive CE 2.20（本機儲存）、Firebase（firebase_core 4、firebase_auth 6、cloud_firestore 6）、google_sign_in 7、intl（l10n）、fl_chart、flutter_slidable、Lottie、Font Awesome 11、mobile_scanner 7（電子發票 QR）。Android：Gradle 9.3、AGP 9.1、Kotlin 2.4、Java 21 目標。

## 開發

```bash
flutter pub get
flutter run
flutter test
```

- 專案規格以 [OpenSpec](https://github.com/Fission-AI/OpenSpec) 維護：`openspec/specs/` 是系統現況，任何行為變更先在 `openspec/changes/` 提出。
- AI agent（Claude Code、Codex）的工作規範在 [AGENTS.md](AGENTS.md)；領域知識在 `.claude/skills/`。
- 品質關卡：`node .claude/hooks/stop-verify.cjs --manual`（format、analyze、test）。
- 產生程式碼：Hive adapter `dart run build_runner build --delete-conflicting-outputs`；多語系 `dart run intl_utils:generate`。

## 授權

見 [license](license)。
