'use strict';
// Stop hook（Claude Code / Codex 共用）：回合結束前的品質關卡。
//   1. dart format 檢查（不合格者自動格式化並要求確認 diff）
//   2. flutter analyze：任何 error / warning 都阻擋（info 只回報）
//   3. 變更到 *_bloc / *_cubit / *_repository 卻沒有對應 test/**/<name>_test.dart → 阻擋
//   4. flutter test 全部通過
// 只有工作樹存在 .dart 或 pubspec.yaml 異動時才執行；stop_hook_active 時不再重複阻擋。
// 手動執行：node .claude/hooks/stop-verify.cjs --manual   （Codex / CI / 人工皆可用）
const path = require('path');
const {
  readStdinJson,
  projectDir,
  run,
  quote,
  changedDartFiles,
  isGenerated,
  findFileByName,
  truncate,
  tail,
  block,
} = require('./lib.cjs');

const manual = process.argv.includes('--manual');
const input = manual ? {} : readStdinJson();
if (!manual && input.stop_hook_active) process.exit(0);

const cwd = projectDir(input);
const dartFiles = changedDartFiles(cwd).filter((f) => !isGenerated(f));
const pubChanged = run('git status --porcelain -- pubspec.yaml', { cwd }).stdout.trim().length > 0;
if (!manual && dartFiles.length === 0 && !pubChanged) process.exit(0);

const problems = [];
const notes = [];

// 1. 格式
if (dartFiles.length) {
  const chk = run(`dart format --output=none --set-exit-if-changed ${dartFiles.map(quote).join(' ')}`, {
    cwd,
    timeoutMs: 60000,
  });
  if (chk.code !== 0) {
    run(`dart format ${dartFiles.map(quote).join(' ')}`, { cwd, timeoutMs: 60000 });
    problems.push('有 .dart 檔未符合 dart format，已自動重新格式化；請重新讀取檔案並確認 diff 無誤。');
  }
}

// 2. 靜態分析
const analyze = run('flutter analyze --no-pub', { cwd, timeoutMs: 240000 });
const analyzeLines = (analyze.stdout + '\n' + analyze.stderr).split(/\r?\n/);
const severe = analyzeLines.filter((l) => /^\s*(error|warning)\s+[-•]/.test(l));
const infos = analyzeLines.filter((l) => /^\s*info\s+[-•]/.test(l));
if (analyze.timedOut) problems.push('flutter analyze 超時（240s）。');
else if (severe.length) problems.push(`flutter analyze 有 ${severe.length} 個 error/warning：\n${truncate(severe.join('\n'), 2500)}`);
else if (analyze.code !== 0 && infos.length === 0) problems.push(`flutter analyze 非零結束：\n${truncate(tail(analyze.stdout + analyze.stderr, 1500))}`);
if (infos.length) notes.push(`flutter analyze 另有 ${infos.length} 個 info（不阻擋，建議順手處理）。`);

// 3. Bloc / Cubit / Repository 必須有測試
const needTest = dartFiles.filter(
  (f) => /^lib\/.*_(bloc|cubit|repository)\.dart$/.test(f) && !/_(event|state)\.dart$/.test(f),
);
const missing = needTest.filter((f) => !findFileByName(path.join(cwd, 'test'), path.basename(f, '.dart') + '_test.dart'));
if (missing.length) {
  problems.push(
    `以下 Bloc/Cubit/Repository 有變更，但 test/ 下找不到對應的 <name>_test.dart（bloc_test 或單元測試）：\n${missing.join('\n')}`,
  );
}

// 4. 測試
const test = run('flutter test --no-pub --reporter compact', { cwd, timeoutMs: 420000 });
if (test.timedOut) problems.push('flutter test 超時（420s）。');
else if (test.code !== 0) problems.push(`flutter test 失敗：\n${truncate(tail(test.stdout + test.stderr, 3000))}`);

if (problems.length) {
  const msg =
    `【Stop 驗證未通過，請修正後再結束回合】\n\n` +
    problems.map((p, i) => `${i + 1}. ${p}`).join('\n\n') +
    (notes.length ? `\n\n備註：\n- ${notes.join('\n- ')}` : '');
  if (manual) {
    console.error(msg);
    process.exit(1);
  }
  block(msg);
}

if (manual) {
  console.log('✅ 驗證通過：dart format / flutter analyze（無 error、warning）/ 測試對應 / flutter test');
  if (notes.length) console.log('- ' + notes.join('\n- '));
}
process.exit(0);
