# 美術與音效需求清單（美術交由 Codex imagegen 產出）

本檔記錄 `storybook-fridge-food-page` 需要的素材、每張的 prompt 要點、入庫規格與紀錄。所有插畫**必須同時在淺色與深色主題上可辨識**，透明背景（真正 RGBA alpha），四周保留安全留白。

## 風格基調（每張都套用）

- 《麵包小偷》式手繪繪本感：蠟筆／色鉛筆質感、粗而柔和的深褐色外框線、暖色調（奶油黃、麵包棕、橘、少量品牌綠 `#3E8E5A` 與暖黃 `#E0A100` 作點綴）。
- 扁平、無 3D、無漸層光暈、無粒子、無文字、無浮水印、不出現人臉。
- 食物角色表情固定為「呆萌半睜眼＋小小的嘴」；吉娃娃依事件換表情。
- **原創性守則**：只借筆觸與表情語彙。不得重製《麵包小偷》原作角色（吐司小偷、法國麵包犬等）或任何既有商標角色的造型；每張入庫前人工核對。
- 品牌吉娃娃長相以 `assets/icons/food_savior_logo.png` 為準：黑色主毛、兩塊獨立棕褐眉斑、金黃披風。

## 試作（先做這 3 張，使用者確認方向後再批次）

| # | 檔名 | 內容 |
|---|---|---|
| P1 | `probe_food_bread.png` | 吐司角色，側面半睜眼小嘴，底下兩隻短短灰色小腳 |
| P2 | `probe_food_egg_milk.png` | 蛋與小牛奶盒並排雙人組，牛奶盒略高 |
| P3 | `probe_chihuahua_peek_happy.png` | 吉娃娃從層架邊探出頭與前爪，開心咧嘴、眼睛笑弧 |

輸出：`AgentAudit/genart/storybook-fridge-food-page-20260917/probe/`，含 `probe.md` 記錄完整 prompt。

## A. 食物角色（11 張，1024×1024 master → 64／128／192 px）

| # | `FoodItemType` | 檔名 | 角色設計 |
|---|---|---|---|
| A1 | vegetable | `food_character_vegetable.png` | 一根胖胖的紅蘿蔔，葉子當頭髮，半睜眼小嘴 |
| A2 | fruit | `food_character_fruit.png` | 一顆蘋果帶一片葉子，臉在果身正面 |
| A3 | meat | `food_character_meat.png` | 一支圓潤的雞腿，骨端當帽子 |
| A4 | eggAndMilk | `food_character_egg_milk.png` | 蛋＋小牛奶盒雙人組（沿用 P2） |
| A5 | seafood | `food_character_seafood.png` | 一條側面的魚，半睜眼、小嘴、簡單魚鰭 |
| A6 | cannedFood | `food_character_canned_food.png` | 一罐有拉環的罐頭，臉在罐身標籤處 |
| A7 | cookedFood | `food_character_cooked_food.png` | 一碗蓋著蓋子的便當／飯碗，兩條蒸氣線，臉在碗身 |
| A8 | drink | `food_character_drink.png` | 一杯有把手的飲料（帶蓋與吸管），臉在杯身 |
| A9 | snack | `food_character_snack.png` | 一片咬了一口的圓餅乾，半睜眼 |
| A10 | bread | `food_character_bread.png` | 吐司角色（沿用 P1） |
| A11 | others | `food_character_others.png` | 一個打結的購物紙袋，臉在袋身 |

要求：主體佔畫布 70%、彼此在 40 px 下可區分（形狀差異優先於顏色差異）、色彩不承載狀態語意（不可有一張看起來「壞掉」）。

## B. 吉娃娃事件反應（5 張，1024×1024 master → 96／192／288 px）

只畫上半身與前爪，從畫面下緣的一條奶油色層架邊探出；構圖一致以便切換時不跳動。

| # | 檔名 | 表情 | 對應事件 |
|---|---|---|---|
| B1 | `chihuahua_peek_happy.png` | 開心咧嘴、眼睛笑弧 | 食用 |
| B2 | `chihuahua_peek_celebrate.png` | 開心＋一隻前爪舉高、旁邊三顆小星 | 即期救援 +3 |
| B3 | `chihuahua_peek_neutral.png` | 平靜、微微側頭；**不哭、不皺眉、不責備** | 丟棄 |
| B4 | `chihuahua_peek_nod.png` | 閉眼點頭、滿意小弧嘴 | 補期限、標記開封 |
| B5 | `chihuahua_peek_sleepy.png` | 眼皮半垂、頭靠在爪子上 | 每日加分達上限 |

## C. 紋理（3 張，256×256 無縫小圖，RGBA，低對比）

| # | 檔名 | 內容 | 用途 |
|---|---|---|---|
| C1 | `texture_paper.png` | 米白紙張纖維紋，灰階、對比極低 | 內牆與 sheet 背景，token 不透明度淺 ≤ 0.08／深 ≤ 0.05 |
| C2 | `texture_frost.png` | 稀疏的白色霜點與細冰紋 | 冷凍層架架板 |
| C3 | `texture_wood.png` | 淺色直向木紋 | 常溫層架（木質櫥架） |

要求：四邊無縫可重複；只有透明與淡色，不含深色像素（避免壓低對比）。

## D. 過期處理頁插圖（1 張，1024×1024 master → 192／384／576 px）

| # | 檔名 | 內容 |
|---|---|---|
| D1 | `expired_processing_hero.png` | 吉娃娃站在打開的冰箱前，一手拿小掃把、一手指向層架，表情專注不責備；冰箱與 A1 空狀態插畫同一台（綠色外殼、奶油色內牆） |

## E. 音效（6 段，WAV 44.1 kHz 16-bit mono，各 ≤ 1.5 秒、≤ 150 KB）

Codex 不能產音效。來源二擇一：(a) kenney.nl「Interface Sounds」／「UI Audio」CC0 包（**下載前需使用者同意**），(b) 使用者自備。放 `assets/audio/`。

| # | 檔名 | 聲音 | 事件 |
|---|---|---|---|
| E1 | `sfx_fridge_open.wav` | 輕輕的門封條剝開＋一聲低沉「咚」 | 每次啟動第一次進食物頁 |
| E2 | `sfx_pop.wav` | 短促的「啵」 | 新增、匯入完成（一次） |
| E3 | `sfx_munch.wav` | 一口咀嚼 | 全部使用、部分使用含食用 |
| E4 | `sfx_drop.wav` | 柔軟的輕放聲（不是垃圾桶砸落） | 丟棄、刪除 |
| E5 | `sfx_sticker.wav` | 貼紙撕下＋按上 | 補期限、標記開封 |
| E6 | `sfx_glow.wav` | 極輕的「叮」（可省略，若太吵就不用） | 層架冷光（新增時，與 E2 合成一聲亦可） |

## 如何請 Codex 產圖

用 Claude Code 的 `codex:codex-rescue` 子代理轉交，一次一批（試作 3 張、A 組 11 張、B＋D 6 張、C 組 3 張），prompt 需包含：輸出目錄、檔名、尺寸、透明背景、共用風格基調、原創性守則、逐張的角色設計，以及「不要改動 lib／assets／openspec／pubspec」。產出後由 Codex 檢查 RGBA 與 alpha 極值，並寫 `generation.md` 記錄完整 prompt。

## 入庫步驟

1. master 放 `AgentAudit/genart/storybook-fridge-food-page-20260917/masters/`；縮成 1x／2x／3x 放 `assets/images/`、`assets/images/2.0x/`、`assets/images/3.0x/`（紋理只需 1x，256×256）。
2. `AppAssets` 與 `FoodItemVisuals.characterAssetOf` 加對照；`pubspec.yaml` 的 `assets:` 已涵蓋 `assets/images/` 各層，新增 `assets/audio/`。
3. 每張在淺色與深色 surface 各截一張預覽（`preview-light.png`／`preview-dark.png`），24／40／56 dp 可辨識度另截一張。
4. 回填下方入庫紀錄與 `docs/art-asset-inventory.md`，勾 `tasks.md` 對應任務。

## 入庫紀錄

### 2026-09-17 試作（P1–P3）已產出，待使用者確認方向

Codex（codex-cli 0.145.0，built-in `image_gen` + chroma-key 去背）產出於 `AgentAudit/genart/storybook-fridge-food-page-20260917/probe/`：`probe_food_bread.png`、`probe_food_egg_milk.png`、`probe_chihuahua_peek_happy.png`（各 1024×1024 RGBA，alpha 含 0 與 255），完整 prompt 見同目錄 `probe.md`。三張都符合風格基調（蠟筆質感、深褐柔框、半睜眼小嘴），吉娃娃保有黑毛、兩塊眉斑、金黃披風。尚未入庫 `assets/`。
