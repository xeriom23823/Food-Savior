# 驗證與交接紀錄

日期：2026-09-15。

- 已套用使用者接受的 v4 黑褐吉娃娃；正式來源與 v4 SHA256 一致：05EDA933FE0406474575CD5E6DF7359152B82583F0853E7A6BB72A2EC6A29816。
- `dart run flutter_launcher_icons` 成功，Android 5 個密度與 iOS AppIcon 重新產生；已查看 Android 192 像素輸出。
- 登入頁 diff 僅修改 Image.asset 路徑。
- L0／L1／L2：stop-verify 通過，analyze 無 error、warning，flutter test 通過。
- L3：未額外新增／獨立執行 widget test，本次僅替換現有 Image.asset 圖片路徑。
- L4：flutter build apk --debug 通過。Java native-access 與既有 Kotlin plugin 未來相容性警告仍存在；本次不調整工具鏈。iOS 無 macOS 建置環境，未建置。
- L5 部分：Samsung SM T500、Android 12；adb install -r 成功，App 成功啟動至既有登入帳號的食物頁，截圖見 docs/art/android-icon-check.png。未登出既有帳號，因此未完成登入頁明暗／zh／en 以及系統 launcher 外觀驗收，2.3 當時保持未勾選。

- L6：openspec validate --all --strict --no-interactive：18 passed、0 failed；skip_specs 資訊為本次無行為規格變更的預期結果。
- change 保留，未 archive。工作樹同時出現其他既有 change 的 tasks 修改，本次未修改或回退那些內容。
- 美術計畫保留於 docs/art-asset-inventory.md，待使用者以 Claude 完成功能開發後，再以最新畫面盤點與產出其他素材。

## 2026-09-16 補完 L5（任務 2.3）

使用者當日授權登出既有帳號（並表明會自行登回），於 Samsung SM T500 / Android 12 完成：

- **系統 launcher 外觀**：App 抽屜中 `food_savior` 圖示正確顯示黑褐吉娃娃抱麵包、綠底，與鄰近的 `doll_project` 吉娃娃圖示可明確區分；深色 launcher 背景下對比足夠。證據 `docs/art/launcher-drawer-sm-t500.png`。
- **登入頁 明暗 × zh／en 四種組合**：全部通過，品牌圖與版面在四種組合下都正確繪製，英文字串（Welcome back／Sign in with Google／No account yet? Create account）無截斷或溢出。證據 `docs/art/login-zh-light-sm-t500.png`、`login-zh-dark-sm-t500.png`、`login-en-light-sm-t500.png`、`login-en-dark-sm-t500.png`。

方法：為了在登出狀態下切換主題與語系（設定頁在登入後才進得去），以 `adb run-as` 直接改 debug build 的 `FlutterSharedPreferences.xml`（`flutter.isDark`、`flutter.localeLanguageCode`），每次改完 force-stop 再啟動。驗收結束後已將該檔還原為原始內容（`isDark=false`、無 locale key，其餘鍵值未動），使用者的偏好設定沒有被改變。

### 觀察（不阻擋本 change，供後續美術決定）

品牌圖在登入頁是**直角的實心綠底方塊**，沒有圓角也沒有去背。淺色主題下還算協調，**深色主題下那塊飽和綠特別突兀**，看起來像貼上去的貼紙而不是版面的一部分。App 啟動的 splash 畫面同樣因為不是 adaptive icon，被 Samsung 包成白色圓角底。proposal 明確把 adaptive icon 與啟動畫面重製列為非目標，所以這不算本 change 的缺陷，但值得記進美術盤點。

- L6（2026-09-16 重跑）：openspec validate --all --strict --no-interactive：20 passed、0 failed。
