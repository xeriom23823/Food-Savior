#!/usr/bin/env node
// 把實機辨識結果倒成基準測試的 fixture（paper-receipt-ocr design D6）。
//
// Debug 建置的 MlKitTextRecognitionService 會把每個 OCR 元素以
// `[receipt-ocr-fixture] {json}` 逐行印到 logcat。這個腳本從 logcat 撈出最後一次
// 辨識（最後一組 BEGIN…END），寫成 test/fixtures/receipts/<name>.json，
// `expected` 留空等人手標註。
//
// 用法：
//   node tool/dump_receipt_fixture.cjs <name> [--note "備註"]
//   adb logcat -d | node tool/dump_receipt_fixture.cjs <name> --stdin
//
// 建議在拍照前先 `adb logcat -c`，log 才不會混到上一張。

const { execSync } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const TAG = '[receipt-ocr-fixture]';

function parseArgs(argv) {
  const args = { name: null, note: '', stdin: false };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === '--stdin') args.stdin = true;
    else if (arg === '--note') args.note = argv[++i] ?? '';
    else if (!args.name) args.name = arg;
  }
  if (!args.name || !/^[a-z0-9-]+$/.test(args.name)) {
    console.error('用法：node tool/dump_receipt_fixture.cjs <kebab-case-name> [--note "..."] [--stdin]');
    process.exit(2);
  }
  return args;
}

function readLog(useStdin) {
  if (useStdin) return fs.readFileSync(0, 'utf8');
  return execSync('adb logcat -d', { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });
}

/// 取最後一組 BEGIN…END 之間的元素。
function extractElements(log) {
  const payloads = [];
  for (const line of log.split(/\r?\n/)) {
    const at = line.indexOf(TAG);
    if (at < 0) continue;
    payloads.push(line.slice(at + TAG.length).trim());
  }
  const lastBegin = payloads.map((p) => p.startsWith('BEGIN')).lastIndexOf(true);
  if (lastBegin < 0) return null;
  const elements = [];
  for (const payload of payloads.slice(lastBegin + 1)) {
    if (payload === 'END') break;
    try {
      const { text, left, top, right, bottom } = JSON.parse(payload);
      elements.push({ text, left, top, right, bottom });
    } catch {
      console.warn(`略過無法解析的一行：${payload}`);
    }
  }
  return elements;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const elements = extractElements(readLog(args.stdin));
  if (!elements) {
    console.error(`logcat 裡沒有 ${TAG}。確認是 debug 建置、而且辨識真的跑過一次。`);
    process.exit(1);
  }
  if (elements.length === 0) {
    console.error('這次辨識沒有任何元素（照片裡沒有文字？）。');
    process.exit(1);
  }

  const fixture = {
    name: args.name,
    elements,
    // 人手標註：從照片對照，填 rawName／quantity／unitPrice／amount／barcode。
    expected: [],
    note: [
      '實機 ML Kit 輸出（SM-T500），未經修飾；expected 待標註。',
      args.note,
    ].filter(Boolean).join(' '),
  };

  const out = path.join('test', 'fixtures', 'receipts', `${args.name}.json`);
  if (fs.existsSync(out)) {
    console.error(`${out} 已存在，換個名字或先刪掉。`);
    process.exit(1);
  }
  fs.writeFileSync(out, JSON.stringify(fixture, null, 2) + '\n', 'utf8');

  console.log(`已寫入 ${out}（${elements.length} 個元素）`);
  console.log('辨識到的文字（依 top 排序，方便對照標註）：');
  for (const element of [...elements].sort((a, b) => a.top - b.top || a.left - b.left)) {
    console.log(`  ${String(Math.round(element.top)).padStart(5)} ${String(Math.round(element.left)).padStart(5)}  ${element.text}`);
  }
}

main();
