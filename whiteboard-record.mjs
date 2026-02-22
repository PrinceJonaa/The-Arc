#!/usr/bin/env node

import { createHash, randomUUID } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { materializeWhiteboard } from './whiteboard-materialize.mjs';

const WHITEBOARD_PATH = resolve(process.cwd(), 'PROJECT_WHITEBOARD.md');
const START_MARKER = '<!-- ASYNC_RUN_EVENTS_START -->';
const END_MARKER = '<!-- ASYNC_RUN_EVENTS_END -->';
const SLOT_COUNT = 32;
const STATUS_VALUES = new Set(['pending', 'in_progress', 'blocked', 'done', 'deferred']);

const parseArgs = (argv) => {
  const values = {};

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (!arg.startsWith('--')) {
      continue;
    }

    const key = arg.slice(2);
    const next = argv[index + 1];
    if (!next || next.startsWith('--')) {
      values[key] = 'true';
      continue;
    }

    values[key] = next;
    index += 1;
  }

  return values;
};

const formatNowUtc = () => {
  const now = new Date();
  return now.toISOString().replace(/\.\d{3}Z$/, 'Z');
};

const toSlotLabel = (slotNumber) => slotNumber.toString(16).toUpperCase().padStart(2, '0');

const sanitizeCell = (value) => {
  return String(value ?? '')
    .replace(/\|/g, '\\|')
    .replace(/\r?\n/g, '<br/>')
    .trim();
};

const createAsyncEventSection = () => {
  const slotBlocks = Array.from({ length: SLOT_COUNT }, (_, index) => {
    const label = toSlotLabel(index);
    return [
      `### Slot ${label}`,
      '| Event ID | Timestamp (UTC) | Role | Task ID | Task Status | Summary | Validation | Next Step | Change Note |',
      '|---|---|---|---|---|---|---|---|---|'
    ].join('\n');
  });

  return [
    '## Async Run Event Log (Sharded, Merge-Safe, Append-Only)',
    '',
    'This is the concurrency-safe whiteboard write target for multi-agent/PR workflows.',
    '',
    '- Do not edit existing rows.',
    '- Add one row per run using `npm run whiteboard:record -- ...`.',
    '- `Last verified` is derived from the latest timestamp in this section.',
    '',
    START_MARKER,
    slotBlocks.join('\n\n'),
    END_MARKER,
    ''
  ].join('\n');
};

const ensureAsyncEventSection = (source) => {
  if (source.includes(START_MARKER) && source.includes(END_MARKER)) {
    return source;
  }

  const section = createAsyncEventSection();
  const trailing = source.endsWith('\n') ? '' : '\n';
  return `${source}${trailing}\n${section}`;
};

const appendEventRow = ({ source, slotLabel, row }) => {
  const startIndex = source.indexOf(START_MARKER);
  const endIndex = source.indexOf(END_MARKER);
  if (startIndex === -1 || endIndex === -1 || endIndex <= startIndex) {
    throw new Error('Async event markers are missing or invalid.');
  }

  const slotHeader = `### Slot ${slotLabel}`;
  const slotStart = source.indexOf(slotHeader, startIndex);
  if (slotStart === -1 || slotStart >= endIndex) {
    throw new Error(`Could not find shard ${slotLabel} in async event log.`);
  }

  const nextSlotIndex = source.indexOf('\n### Slot ', slotStart + slotHeader.length);
  const insertionPoint = nextSlotIndex !== -1 && nextSlotIndex < endIndex ? nextSlotIndex + 1 : endIndex;

  const prefix = source.slice(0, insertionPoint);
  const suffix = source.slice(insertionPoint);
  const needsLeadingNewline = !prefix.endsWith('\n');
  const rowWithBreak = `${needsLeadingNewline ? '\n' : ''}${row}\n\n`;
  return `${prefix}${rowWithBreak}${suffix}`;
};

const args = parseArgs(process.argv.slice(2));

const requiredKeys = ['role', 'task', 'status', 'summary', 'validation', 'next', 'change'];
const missing = requiredKeys.filter((key) => !args[key]);

if (missing.length > 0) {
  console.error(
    `Missing required args: ${missing.map((key) => `--${key}`).join(', ')}\n\n` +
      'Example:\n' +
      '  npm run whiteboard:record -- --role sprinter --task CAL-004 --status done --summary "..." --validation "npm run lint" --next "..." --change "..."\n'
  );
  process.exit(1);
}

if (!STATUS_VALUES.has(args.status)) {
  console.error(`Invalid --status "${args.status}". Allowed: ${Array.from(STATUS_VALUES).join(', ')}`);
  process.exit(1);
}

const timestamp = args.timestamp || formatNowUtc();
const eventId = args.eventId || `${timestamp}-${args.role}-${args.task}-${randomUUID().slice(0, 8)}`;
const slot = Number.parseInt(createHash('sha1').update(eventId).digest('hex').slice(0, 2), 16) % SLOT_COUNT;
const slotLabel = toSlotLabel(slot);

const row = `| ${sanitizeCell(eventId)} | ${sanitizeCell(timestamp)} | ${sanitizeCell(args.role)} | ${sanitizeCell(args.task)} | ${sanitizeCell(args.status)} | ${sanitizeCell(args.summary)} | ${sanitizeCell(args.validation)} | ${sanitizeCell(args.next)} | ${sanitizeCell(args.change)} |`;

const source = readFileSync(WHITEBOARD_PATH, 'utf8');
const ensured = ensureAsyncEventSection(source);
const updated = appendEventRow({ source: ensured, slotLabel, row });
const materialized = materializeWhiteboard(updated);

writeFileSync(WHITEBOARD_PATH, materialized, 'utf8');

console.log(`Recorded whiteboard event ${eventId} in shard ${slotLabel}.`);
