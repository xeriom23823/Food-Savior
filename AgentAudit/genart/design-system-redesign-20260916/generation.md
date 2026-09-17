# E 組食物類型圖示生成紀錄

日期：2026-09-16  
用途：`design-system-redesign` E 組，11 個食物類型的線性圖示候選素材。  
工具：built-in `imagegen`（未使用 CLI fallback）。

## 共用 prompt

Use case: `ui-mockup`。Asset type: mobile app food-category icon，transparent PNG master。每張只包含一個居中的食物／分類符號，使用 24×24 app icon 語彙：扁平、單色、圓角線端與線接合、適中的一致線寬、簡化幾何造型、透明背景、約 70% 畫布佔比、24 dp 可辨識。禁止文字、浮水印、陰影、漸層、3D、寫實材質、臉部與裝飾粒子，避免 Font Awesome 式實心剪影。

色彩要求為沉穩綠 `#3E8E5A`；生成後將前景統一重建為此品牌色，並由亮度重新計算 alpha，清除生成預覽裡的近黑背景與肉類／海鮮光暈。輸出保留真正透明 alpha。

## 個別 subject

| 類型 | subject |
|---|---|
| vegetable | 一根帶葉子的紅蘿蔔 |
| fruit | 一顆帶一片葉子的蘋果 |
| meat | 一支雞腿，帶簡單骨端 |
| egg_milk | 一顆蛋與小牛奶紙盒的緊湊組合 |
| seafood | 一條側面的魚，含尾巴、眼睛與簡單魚鰭 |
| canned_food | 一罐有拉環的罐頭 |
| cooked_food | 一碗熟食與兩條蒸氣線 |
| drink | 一杯有把手的飲料與小碟子 |
| snack | 一片帶三個小碎片的圓餅乾 |
| bread | 一個帶兩道切痕的麵包 |
| others | 交叉的叉子與湯匙 |

## 交付物

- `masters/food_type_<name>_master.png`：1024×1024 RGBA，已統一留白與品牌色。
- `assets/icons/food_type_<name>.png`：24×24 runtime variant。
- `assets/icons/2.0x/food_type_<name>.png`：48×48 runtime variant。
- `assets/icons/3.0x/food_type_<name>.png`：72×72 runtime variant。
- `food-types-preview-light.png`、`food-types-preview-dark.png`：亮／暗 surface 預覽。
- `food-types-24px-preview-light.png`、`food-types-24px-preview-dark.png`：24 px 放大檢查預覽。
- `raw/`：imagegen 原始輸出，供追溯；不直接作為 runtime asset。

E 組已由 `FoodItemVisuals.assetOf` + `FoodTypeIcon` 替換原本的 Font Awesome food-type binding；目前仍待實機畫面 A/B 與使用者確認縮小後的視覺比例。`font_awesome_flutter` 保留給 Google 登入等其他用途。
