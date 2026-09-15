# App 圖示 v2 生成紀錄

- 日期：2026-09-15。
- 工具：內建 image_gen，依 imagegen skill 執行；未使用 CLI fallback。
- 成果：food-savior-app-icon-v2.png，1254 × 1254。候選圖，尚未套用到 launcher 或登入頁。
- 概念：象牙白食物與承托曲線、金黃葉片、沉穩綠底，表達珍惜與保存食物。
- 目視檢查：單一置中圖案、無文字、無外框圓角，第二次生成已修正第一版背景及破碎邊緣。仍有輕微色調變化，並非可編輯向量或精確色票母檔；尚未驗證各平台遮罩、小尺寸實機顯示。

## 初始 prompt

```text
Use case: logo-brand
Asset type: Food Savior mobile app launcher icon, new design, one finished square raster master.
Primary request: Create a distinctive, friendly, highly legible app icon for a household food expiry tracking and food waste reduction app. Design one bold emblem of a fresh rounded apple cradled protectively by a simple bowl-like cupped form, with a single confident leaf. The protective curve and fruit should form one cohesive memorable silhouette, with clever clean negative space. Everyday warmth, freshness, care, calm reliability.
Style: exceptionally polished flat vector-like brand illustration, restrained geometric curves, minimal large shapes, crisp smooth edges, no fine detail. Not a rendered 3D object.
Palette: full-bleed solid muted deep brand green #3E8E5A background; warm ivory main emblem; a small warm golden yellow #E0A100 accent, with restrained dark green only if necessary. Strong small-size contrast.
Composition: exactly one centered icon, emblem entirely within central 66 percent of square, balanced optical weight, enough safe area for circle and squircle crops. Background reaches all four square edges; do not bake rounded corners into image. Aim for instant recognition at 48 pixels.
Text: none.
Avoid: letters, words, numbers, watermark, mockup, phone, presentation board, multiple options, gradients, shadows, glossy lighting, tiny texture, pet mascot, recycling arrows, elaborate vegetables, checkmark badges, heart overload. Output a single 1024x1024 image.
```

## 最終修整 prompt

```text
Edit this app icon into a clean finished opaque square icon. Preserve the central idea and arrangement: ivory apple cradled by a protective ivory bowl curve, one golden leaf. CRITICAL: entire canvas must have a SOLID OPAQUE muted green #3E8E5A background, including ALL negative spaces between shapes. No transparency anywhere. Rebuild the silhouette edges cleanly, remove all white flecks, ragged edges, pale green highlights and gradients. Use only three flat solid colors: green background, warm ivory apple and cradle, golden yellow leaf. Smooth bold geometric vector-like edges, clear green gaps separating the apple and cradle, centered safe margins. No text, no border, no rounded outer corners, no shadow, no presentation mockup. One square finished raster image.
```
