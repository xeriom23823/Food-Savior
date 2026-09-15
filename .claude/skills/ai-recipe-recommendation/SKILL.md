---
name: ai-recipe-recommendation
description: Food Savior 的 AI 料理推薦架構指引：以 Cloud Functions 代理 Claude API（App 不持有金鑰）、模型選擇、結構化輸出（tool use JSON schema）、提示設計（優先消耗即期食材、繁中家常菜）、快取與每人每日配額、Flutter 端 Repository/Cubit/UI、測試與隱私。開發 AI 推薦 change 時必讀；API 參數與價格以全域 claude-api skill 為準。
---

# AI 料理推薦

## 架構（不可妥協的部分）

```
Flutter App
  RecipeRepository → FirebaseFunctions.instanceFor(region: 'asia-east1').httpsCallable('recommendRecipes')
        │  需已登入（Firebase Auth）+ App Check
        ▼
Cloud Functions for Firebase（2nd gen，Node 22，TypeScript）  functions/src/recommendRecipes.ts
  1. 驗證 auth / App Check
  2. 檢查配額（users/{uid}/quota/{yyyy-MM-dd}.count < 10）
  3. 查快取（users/{uid}/recipeCache/{hash}，24h）
  4. 呼叫 Anthropic API（金鑰在 Secret Manager：ANTHROPIC_API_KEY）
  5. 驗證回傳 JSON 符合 schema → 寫快取 → 回傳
```

- **金鑰絕不進 App**（含 `--dart-define`、`.env`、Remote Config）。
- 全域 `claude-api` skill 是模型 id、參數、價格、prompt caching 用法的權威；本 skill 只定本專案決策。

## 模型與參數

| 用途 | 模型 | 理由 |
|---|---|---|
| 預設 | `claude-haiku-4-5-20251001` | 便宜、快，食譜推薦不需深度推理 |
| 「更講究」選項（未來付費／實驗） | `claude-sonnet-5` | 更好的食材搭配與步驟品質 |

- `max_tokens` 依 3 道食譜估算（約 1500–2500）；`temperature` 0.7。
- 系統提示用 prompt caching（穩定不變的部分放前面）。
- 逾時 30 秒；Functions `timeoutSeconds: 60`、`memory: 512MiB`。

## 結構化輸出

以 tool use 強制 JSON（`tool_choice: {type: 'tool', name: 'return_recipes'}`），schema：

```json
{
  "type": "object",
  "required": ["recipes"],
  "properties": {
    "recipes": {
      "type": "array", "minItems": 1, "maxItems": 3,
      "items": {
        "type": "object",
        "required": ["title", "servings", "timeMinutes", "ingredients", "steps", "usesExpiringItemIds"],
        "properties": {
          "title": {"type": "string"},
          "servings": {"type": "integer"},
          "timeMinutes": {"type": "integer"},
          "ingredients": {"type": "array", "items": {"type": "object", "required": ["name", "amount", "fromInventory"],
            "properties": {"name": {"type": "string"}, "amount": {"type": "string"}, "fromInventory": {"type": "boolean"}}}},
          "steps": {"type": "array", "items": {"type": "string"}},
          "usesExpiringItemIds": {"type": "array", "items": {"type": "string"}},
          "tip": {"type": "string"}
        }
      }
    }
  }
}
```

Functions 端用 zod（或 JSON schema 驗證）再檢查一次；不符就重試一次，再失敗回傳 `unavailable` 錯誤碼。

## 提示設計

- 系統：「你是台灣家庭料理助手。以使用者庫存為主，**優先用完 3 天內到期的食材**，補充常見調味料即可；每道 ≤ 30 分鐘、步驟 ≤ 8 步；語言依 `locale` 參數（zh-TW / en）；不要編造庫存沒有的主食材。」
- 使用者訊息（由 Functions 組裝，不讓 App 直接送任意文字）：
  ```
  locale: zh-TW
  今天: 2026-09-15
  即期食材（id | 名稱 | 數量單位 | 剩餘天數）: ...
  其他庫存: ...
  偏好: 素食=false, 忌口=[], 人數=2
  ```
- 只送食物名稱／數量／到期天數；**不送 email、uid、備註內容**。
- 快取鍵 = sha256(locale + 排序後的 (名稱, 數量, 剩餘天數桶) + 偏好)。

## 配額與費用

- 每人每日 10 次（Functions 內以 transaction 遞增）；超過回 `quotaExceeded`，UI 顯示明日再試。
- 監控：Functions log 記 input/output tokens；Cloud Billing 預算警示。
- 費用估算以 `claude-api` skill 的價格表計算，寫進 change 的 proposal。

## Flutter 端

```
lib/models/recipe.dart                 Recipe / RecipeIngredient（fromJson，Equatable）
lib/repositories/recipe_repository.dart  介面 RecipeApi + FirebaseFunctionsRecipeApi；快取最近一次結果到 Hive Box recipeCache（離線可回看）
lib/cubits/recipe_cubit.dart           RecipeState: initial / loading / loaded(recipes, generatedAt) / error(code)
lib/pages/recipes/                     推薦入口（食物分頁 FAB 或即期提示卡）、食譜卡（標題、時間、人數、使用的即期食材 chip）、詳情
```

- 觸發點：食物分頁頂部「N 項即將到期 → 看看能做什麼」卡片；設定頁可關閉 AI 功能。
- 錯誤碼 → l10n：`recipeErrorQuota`、`recipeErrorUnavailable`、`recipeErrorOffline`。
- 食譜中「fromInventory」食材可一鍵標記為已使用（串 `FoodItemListConsume`）。

## 後端專案配置

- `firebase init functions`（TypeScript、ESLint）；`functions/` 進 repo，`.github/workflows` 加 `npm ci && npm run build && npm test`。
- `firebase functions:secrets:set ANTHROPIC_API_KEY`；程式以 `defineSecret('ANTHROPIC_API_KEY')` 綁定。
- App Check：Android Play Integrity、iOS App Attest；debug provider 供開發。
- 部署：`firebase deploy --only functions:recommendRecipes`（需 firebase CLI、Blaze 方案）。

## 測試

- Functions：以注入的 Anthropic client 介面 + 固定回應測 schema 驗證、快取命中、配額、錯誤映射；`firebase emulators:start --only functions,firestore,auth` 跑整合。
- Flutter：`FakeRecipeApi` 餵成功／配額／離線；Cubit bloc_test；食譜卡 widget test（zh/en 長標題不截斷）。
- 契約 fixture：`test/fixtures/recipes/sample_response.json` 兩端共用。
- 實機：Wi-Fi 關閉、配額用盡、回應超過 20 秒的載入體驗。

## 需要的 spec

`ai-recipe-recommendation`（新能力：觸發條件、輸入資料範圍、輸出結構、配額、離線、隱私聲明）、`app-settings` MODIFIED（AI 功能開關）、`food-inventory` MODIFIED（從食譜標記已使用）。
