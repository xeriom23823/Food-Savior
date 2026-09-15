'use strict';
// 把 .claude/skills/* 同步到 .agents/skills/*（Codex 讀取的位置）。
// 來源目錄是 .claude/skills；請勿直接編輯 .agents/skills。
// 用法：node tool/sync_skills.cjs [--check]   （--check 只比對，不一致時 exit 1）
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const src = path.join(root, '.claude', 'skills');
const dst = path.join(root, '.agents', 'skills');
const check = process.argv.includes('--check');

function walk(dir) {
  const out = [];
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) out.push(...walk(p));
    else out.push(p);
  }
  return out;
}

if (!fs.existsSync(src)) {
  console.error(`找不到 ${src}`);
  process.exit(1);
}
fs.mkdirSync(dst, { recursive: true });

let copied = 0;
let differing = [];
for (const file of walk(src)) {
  const rel = path.relative(src, file);
  const target = path.join(dst, rel);
  const same = fs.existsSync(target) && fs.readFileSync(file).equals(fs.readFileSync(target));
  if (same) continue;
  differing.push(rel);
  if (!check) {
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.copyFileSync(file, target);
    copied++;
  }
}

if (check) {
  if (differing.length) {
    console.error(`.agents/skills 與 .claude/skills 不一致（${differing.length} 個檔案）：\n- ${differing.join('\n- ')}\n請執行 node tool/sync_skills.cjs`);
    process.exit(1);
  }
  console.log('✅ .agents/skills 與 .claude/skills 一致');
} else {
  console.log(`已同步 ${copied} 個檔案到 .agents/skills`);
}
