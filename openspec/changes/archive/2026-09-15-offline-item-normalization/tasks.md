## 1. 命中率基準（先做，design D1）

- [x] 1.1 `test/fixtures/product_names/benchmark.json`：真實風格 POS 品名 + 人工標註的期望 `type`；寫法要含品牌、促銷、規格、全形，不是乾淨的食物名
- [x] 1.2 基準樣本必須包含 design D3 表列的每一組消歧案例
- [x] 1.3 `test/domain/name_suggestion_benchmark_test.dart`：走**完整管線**（`ProductNameCleaner` → `FoodSuggestionEngine`）計算命中率
- [x] 1.4 門檻寫成測試檔常數，註解記下當時實測值；低於門檻即失敗，並印出推導錯誤的樣本
- [x] 1.5 先跑一次記下**擴充前**的基準值，作為改善幅度的對照

## 2. 比對規則（design D4、D5）

- [x] 2.1 ~~建索引~~ **取消**：`FoodSuggestionEngine`／`FoodPreset` 有 `const` 用法，且 bloc 每次存取都重建 engine，索引會變成每次重算。實測成本本來就在毫秒以下（design D5 已改寫記錄原因）
- [x] 2.2 `presetFor` 平手時以關鍵字字典序較小者勝，與資料排列順序無關
- [x] 2.3 平手規則測試：兩筆同長度關鍵字命中時結果確定，且**重新排列資料檔順序後結果相同**
- [x] 2.4 既有的 `food_suggestion` 相關測試維持全綠（行為契約不變）

## 3. 擴充對照表（資料，design D2、D3）

- [x] 3.1 `assets/data/food_presets.json` 擴充到約 200 筆，涵蓋台灣零售常見生鮮與加工食品
- [x] 3.2 補齊 design D3 表列的消歧條目
- [x] 3.3 每筆都有：非空關鍵字、合法 `FoodItemType`、正整數常溫天數；保存天數取保守（偏短）值
- [x] 3.4 `test/repositories/food_preset_repository_test.dart` 補上「實際 asset 檔的每一筆都符合必要欄位」的資料健檢

## 4. 擴充雜訊詞表（資料，design D6）

- [x] 4.1 `assets/data/product_noise_terms.json` 補齊更多品牌、通路、促銷、溫層用語
- [x] 4.2 交叉比對測試：任何雜訊詞都不得包含任何對照表關鍵字；衝突時印出是哪一對
- [x] 4.3 確認清洗後仍能命中（「特價 統一 牛奶」→ 蛋奶類）

## 5. 驗證

- [x] 5.1 `dart format .`
- [x] 5.2 `flutter analyze --no-pub`（0 error／0 warning，info 如實回報）
- [x] 5.3 `flutter test` 全綠
- [x] 5.4 命中率歷程：**63.9%**（擴充前，61 筆）→ 98.4%（擴充字典後）→ 100%（改用最靠近字尾優先）→ **79.7%**（補進 18 筆未為其調整過的難樣本，79 筆）→ **98.7%**（依基準指出的缺口補上台式熟食小吃）。完整記錄在 `name_suggestion_benchmark_test.dart` 的門檻註解
- [~] 5.5 實機（SM-T500，Android 12）：以快速新增輸入含 `milk` 的名稱，推導出蛋奶類圖示、單位「瓶」、冷藏 7 天到期——與對照表該筆完全一致，證明 asset 在裝置上正確載入並生效。**未驗**：中文品名（`adb input text` 無法輸入中文，需實體鍵盤或手動操作；中文路徑由 79 筆基準樣本覆蓋）
- [x] 5.6 `openspec validate --all --strict --no-interactive`

> 不需要 `flutter build apk --debug`：本 change 不動套件、原生權限或 Gradle。
