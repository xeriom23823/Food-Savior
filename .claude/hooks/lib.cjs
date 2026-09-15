'use strict';
// 共用工具：Claude Code 與 Codex 的 hooks 都透過 node 執行這些腳本（跨平台，不依賴 bash/PowerShell）。
const { spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');

function readStdinJson() {
  try {
    const raw = fs.readFileSync(0, 'utf8');
    return raw.trim() ? JSON.parse(raw) : {};
  } catch (_) {
    return {};
  }
}

function projectDir(input) {
  return process.env.CLAUDE_PROJECT_DIR || (input && input.cwd) || process.cwd();
}

function run(cmd, opts = {}) {
  const res = spawnSync(cmd, {
    shell: true,
    cwd: opts.cwd,
    encoding: 'utf8',
    timeout: opts.timeoutMs || 0,
    maxBuffer: 64 * 1024 * 1024,
    env: { ...process.env, ...(opts.env || {}) },
  });
  const timedOut = !!(res.error && res.error.code === 'ETIMEDOUT');
  return {
    code: res.status === null ? (timedOut ? 124 : 1) : res.status,
    stdout: res.stdout || '',
    stderr: res.stderr || '',
    timedOut,
  };
}

function quote(p) {
  return '"' + String(p).replace(/"/g, '\\"') + '"';
}

// 工作樹中所有已修改 / 新增（含未追蹤）的 .dart 檔（相對路徑，正斜線）
function changedDartFiles(cwd) {
  const r = run('git -c core.quotepath=off status --porcelain --untracked-files=all', { cwd });
  if (r.code !== 0) return [];
  return r.stdout
    .split(/\r?\n/)
    .filter(Boolean)
    .map((l) => l.slice(3).trim())
    .map((p) => (p.includes(' -> ') ? p.split(' -> ')[1] : p))
    .map((p) => p.replace(/^"|"$/g, ''))
    .filter((p) => p.endsWith('.dart'))
    .filter((p) => fs.existsSync(path.join(cwd, p)));
}

const GENERATED = [
  /\.g\.dart$/,
  /\.freezed\.dart$/,
  /\.mocks\.dart$/,
  /(^|[\\/])lib[\\/]generated[\\/]/,
  /firebase_options\.dart$/,
  /(^|[\\/])build[\\/]/,
  /(^|[\\/])\.dart_tool[\\/]/,
];
function isGenerated(rel) {
  return GENERATED.some((re) => re.test(rel));
}

function findFileByName(root, fileName) {
  if (!fs.existsSync(root)) return null;
  const stack = [root];
  while (stack.length) {
    const dir = stack.pop();
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) stack.push(full);
      else if (entry.name === fileName) return full;
    }
  }
  return null;
}

function truncate(s, n = 3000) {
  s = String(s || '');
  return s.length > n ? s.slice(0, n) + '\n…（輸出已截斷）' : s;
}

function tail(s, n = 3000) {
  s = String(s || '');
  return s.length > n ? '…（前段省略）\n' + s.slice(-n) : s;
}

// exit 2 + stderr：Claude Code / Codex 都會把訊息回饋給模型並阻擋該動作。
function block(message) {
  process.stderr.write(String(message).slice(0, 8000) + '\n');
  process.exit(2);
}

module.exports = {
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
};
