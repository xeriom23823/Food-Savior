'use strict';
// PostToolUse（Edit/Write/MultiEdit/apply_patch）：對剛編輯的 .dart 檔執行 dart format。
// 只做格式化（<1s）；flutter analyze 與 flutter test 放在 Stop hook（stop-verify.cjs），
// 因為每次編輯都跑 analyzer 需 10–30 秒，且單檔 analyze 在 Windows 上不穩定。
// 若 dart format 失敗代表有語法錯誤 → exit 2 讓模型立刻修正。
const fs = require('fs');
const path = require('path');
const { readStdinJson, projectDir, run, quote, isGenerated, changedDartFiles, block, truncate } = require('./lib.cjs');

const input = readStdinJson();
const cwd = projectDir(input);
const toolInput = input.tool_input || {};

let files = [];
if (typeof toolInput.file_path === 'string') files.push(toolInput.file_path);
if (Array.isArray(toolInput.edits)) {
  for (const e of toolInput.edits) if (e && typeof e.file_path === 'string') files.push(e.file_path);
}
// Codex 的 apply_patch 不帶 file_path → 退回以 git 判斷有異動的 .dart 檔
if (files.length === 0) files = changedDartFiles(cwd);

files = Array.from(
  new Set(
    files
      .filter((f) => f.endsWith('.dart'))
      .map((f) => (path.isAbsolute(f) ? path.relative(cwd, f) : f))
      .map((f) => f.replace(/\\/g, '/'))
      .filter((f) => !isGenerated(f) && fs.existsSync(path.join(cwd, f))),
  ),
);
if (files.length === 0) process.exit(0);

const r = run(`dart format ${files.map(quote).join(' ')}`, { cwd, timeoutMs: 60000 });
if (r.code !== 0) {
  block(
    `【dart format 失敗】通常代表 Dart 語法錯誤，請先修正：\n${truncate(r.stdout + r.stderr, 2500)}`,
  );
}

const m = /\((\d+) changed\)/.exec(r.stdout);
if (m && Number(m[1]) > 0) {
  // 非阻擋提示：告知模型檔案已被重新格式化，避免後續 Edit 的 old_string 對不上。
  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'PostToolUse',
        additionalContext: `dart format 已重新格式化 ${m[1]} 個檔案（${files.join(', ')}）。後續 Edit 前請重新讀取該檔。`,
      },
    }),
  );
}
process.exit(0);
