'use strict';
// PreToolUse（Bash / shell）：攔截 `openspec archive` 與 `openspec bulk-archive`。
// archive 代表「規格已成為現況」，因此必須先通過：
//   - openspec validate --all --strict --no-interactive
//   - flutter analyze（無 error / warning）
//   - flutter test 全綠
// 其他指令直接放行（exit 0，不影響原本的權限流程）。
const { readStdinJson, projectDir, run, truncate, tail, block } = require('./lib.cjs');

const input = readStdinJson();
const toolInput = input.tool_input || {};
let cmd = toolInput.command ?? toolInput.cmd ?? '';
if (Array.isArray(cmd)) cmd = cmd.join(' ');
if (typeof cmd !== 'string' || !/\bopenspec\b[^\n]*\b(archive|bulk-archive)\b/.test(cmd)) process.exit(0);

const cwd = projectDir(input);
const problems = [];

const validate = run('openspec validate --all --strict --no-interactive', { cwd, timeoutMs: 120000 });
if (validate.code !== 0) problems.push(`openspec validate --all --strict 未通過：\n${truncate(validate.stdout + validate.stderr, 2500)}`);

const analyze = run('flutter analyze --no-pub', { cwd, timeoutMs: 240000 });
const severe = (analyze.stdout + '\n' + analyze.stderr).split(/\r?\n/).filter((l) => /^\s*(error|warning)\s+[-•]/.test(l));
if (severe.length) problems.push(`flutter analyze 有 ${severe.length} 個 error/warning：\n${truncate(severe.join('\n'), 2000)}`);

const test = run('flutter test --no-pub --reporter compact', { cwd, timeoutMs: 420000 });
if (test.code !== 0) problems.push(`flutter test 失敗：\n${truncate(tail(test.stdout + test.stderr, 2500))}`);

if (problems.length) {
  block(
    `【OpenSpec archive 已被攔截】archive 前必須通過所有品質關卡：\n\n` +
      problems.map((p, i) => `${i + 1}. ${p}`).join('\n\n') +
      `\n\n修正後再執行 archive。若確實要略過（不建議），請由使用者明確指示。`,
  );
}
process.exit(0);
