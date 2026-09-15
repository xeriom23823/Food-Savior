@AGENTS.md

# Claude Code 專用補充

- OpenSpec 指令：`/opsx:new`、`/opsx:continue`、`/opsx:ff`、`/opsx:apply`、`/opsx:verify`、`/opsx:sync`、`/opsx:archive`、`/opsx:explore`。依 `openspec status --change <name>` 的狀態選擇；不確定就先 `/opsx:explore`。
- Hooks 由 `.claude/settings.json` 掛載（PostToolUse 格式化、Stop 驗證、PreToolUse archive 關卡）。Stop hook 阻擋時，訊息就是待修清單：修完再結束，不要繞過。
- Dart MCP（`.mcp.json` 的 `dart`）已啟用：用 `mcp__dart__analyze_files`、`run_tests`、`list_devices`、`launch_app`、`hot_reload`、`get_runtime_errors`、`widget_inspector` 做 L1、L2、L5 驗證，取代長時間阻塞的 `flutter run`。
- 需要程式碼審查時用 `/code-review`；只做品質整理用 `/simplify`。兩者都不取代 Stop hook 的測試關卡。
- 專案 skills 在 `.claude/skills/`，改完執行 `node tool/sync_skills.cjs` 同步給 Codex。
- 全域可用的 `claude-api` skill 是 Claude API 參數與價格的權威來源；`ai-recipe-recommendation` skill 只描述本專案的架構決策。
