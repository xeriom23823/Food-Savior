# Food-Savior 食物救世主

這是一個紀錄生鮮食物保存期限並給予使用者提醒的手機應用程式，希望使用者使用後可以清楚知道家裡生鮮食物的保存期限狀況，並透過獎勵與懲罰機制希望使用者不要浪費食物。

## 功能

- [x] 現存生鮮食物清單（新增／編輯／刪除、到期日排序、新鮮／快過期／已過期狀態）
- [x] 過期食物處理流程（啟動時逐項標記已食用或已浪費）
- [x] 食用／浪費紀錄與依日期瀏覽
- [x] 食物點數獎懲機制（食用 +1、浪費 -1、每日食用上限 10）
- [x] 統計圖表（依類型圓餅圖、月趨勢折線圖）
- [x] Email／Google 登入
- [x] 雲端手動備份與還原（Firestore）
- [x] 多語系（繁體中文、English）與深色模式
- [ ] UI 設計系統重製
- [ ] 生鮮食物過期提醒（本機通知）
- [ ] 掃描條碡／電子發票 QR 記錄、載具綁定自動記錄
- [ ] Hive ↔ Firestore 雙向同步
- [ ] 提醒時透過 AI 推薦料理

## 技術棧

Flutter 3.47 / Dart 3.13、flutter_bloc 9、Hive CE 2.20（本機儲存）、Firebase（firebase_core 4、firebase_auth 6、cloud_firestore 6）、google_sign_in 7、intl（l10n）、fl_chart、flutter_slidable、Lottie、Font Awesome 11。Android：Gradle 9.3、AGP 9.1、Kotlin 2.4、Java 21 目標。

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
