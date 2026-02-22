#!/usr/bin/env node

import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const WHITEBOARD_PATH = resolve(process.cwd(), 'PROJECT_WHITEBOARD.md');
const LAST_VERIFIED_DERIVED_LINE =
  'Last verified: Derived from latest timestamp in `Async Run Event Log` (sharded append-only section).';

const ASYNC_START_MARKER = '<!-- ASYNC_RUN_EVENTS_START -->';
const ASYNC_END_MARKER = '<!-- ASYNC_RUN_EVENTS_END -->';

const GENERATED_TASK_BOARD_START = '<!-- GENERATED_TASK_BOARD_START -->';
const GENERATED_TASK_BOARD_END = '<!-- GENERATED_TASK_BOARD_END -->';
const GENERATED_RUN_LEDGER_START = '<!-- GENERATED_RUN_LEDGER_START -->';
const GENERATED_RUN_LEDGER_END = '<!-- GENERATED_RUN_LEDGER_END -->';

const STATUS_VALUES = new Set(['pending', 'in_progress', 'blocked', 'done', 'deferred']);

const decodeCell = (value) => {
  return value.replace(/\\\|/g, '|').replace(/<br\/>/g, '\n').trim();
};

const encodeCell = (value) => {
  return String(value ?? '').replace(/\|/g, '\\|').replace(/\r?\n/g, '<br/>').trim();
};

const normalizeStatus = (value) => {
  const normalized = String(value ?? '').trim().toLowerCase();
  return STATUS_VALUES.has(normalized) ? normalized : 'pending';
};

const parseTableRow = (line) => {
  const trimmed = line.trim();
  if (!trimmed.startsWith('|') || !trimmed.endsWith('|')) {
    return null;
  }

  const cells = [];
  let current = '';

  for (let index = 1; index < trimmed.length - 1; index += 1) {
    const char = trimmed[index];
    const previous = trimmed[index - 1];

    if (char === '|' && previous !== '\\') {
      cells.push(decodeCell(current));
      current = '';
      continue;
    }

    current += char;
  }

  cells.push(decodeCell(current));
  return cells;
};

const isHeaderOrSeparator = (firstCell) => {
  if (!firstCell) {
    return true;
  }

  if (firstCell === 'Task ID' || firstCell === 'Timestamp (UTC)' || firstCell === 'Event ID') {
    return true;
  }

  return /^:?-+:?$/.test(firstCell.replace(/\s+/g, ''));
};

const findBoundsBetween = (source, heading, endAnchor) => {
  const headingIndex = source.indexOf(heading);
  if (headingIndex === -1) {
    throw new Error(`Missing heading: ${heading}`);
  }

  const headingLineEnd = source.indexOf('\n', headingIndex);
  if (headingLineEnd === -1) {
    throw new Error(`Invalid heading line for: ${heading}`);
  }

  const endAnchorIndex = source.indexOf(endAnchor, headingLineEnd + 1);
  if (endAnchorIndex === -1) {
    throw new Error(`Missing section end anchor: ${endAnchor}`);
  }

  return {
    start: headingLineEnd + 1,
    end: endAnchorIndex
  };
};

const parseAsyncEvents = (source) => {
  const start = source.indexOf(ASYNC_START_MARKER);
  const end = source.indexOf(ASYNC_END_MARKER);

  if (start === -1 || end === -1 || end <= start) {
    throw new Error('Async event log markers are missing or invalid.');
  }

  const block = source.slice(start + ASYNC_START_MARKER.length, end);
  const events = [];

  for (const line of block.split('\n')) {
    const cells = parseTableRow(line);
    if (!cells || cells.length < 9 || isHeaderOrSeparator(cells[0])) {
      continue;
    }

    const event = {
      eventId: cells[0],
      timestamp: cells[1],
      role: cells[2],
      taskId: cells[3],
      status: normalizeStatus(cells[4]),
      summary: cells[5],
      validation: cells[6],
      nextStep: cells[7],
      changeNote: cells[8]
    };

    if (!event.taskId) {
      continue;
    }

    events.push(event);
  }

  events.sort((left, right) => right.timestamp.localeCompare(left.timestamp));
  return events;
};

const parseTaskSnapshotMetadata = (source) => {
  const bounds = findBoundsBetween(source, '## Role Task Board', 'Task status vocabulary:');
  const section = source.slice(bounds.start, bounds.end);
  const map = new Map();
  const order = [];

  for (const line of section.split('\n')) {
    const cells = parseTableRow(line);
    if (!cells || cells.length < 7 || isHeaderOrSeparator(cells[0])) {
      continue;
    }

    const taskId = cells[0];
    if (!taskId || map.has(taskId)) {
      continue;
    }

    map.set(taskId, {
      task: cells[1],
      role: cells[2],
      priority: cells[3],
      status: normalizeStatus(cells[4]),
      lastUpdated: cells[5],
      notes: cells[6]
    });
    order.push(taskId);
  }

  return {
    bounds,
    map,
    order
  };
};

const buildTaskSnapshotTable = ({ metadataById, metadataOrder, events }) => {
  const latestByTask = new Map();
  for (const event of events) {
    if (!latestByTask.has(event.taskId)) {
      latestByTask.set(event.taskId, event);
    }
  }

  const discoveredTaskIds = Array.from(latestByTask.keys()).filter((taskId) => !metadataById.has(taskId)).sort();
  const orderedTaskIds = [...metadataOrder, ...discoveredTaskIds];

  const rows = orderedTaskIds.map((taskId) => {
    const metadata = metadataById.get(taskId);
    const latest = latestByTask.get(taskId);

    const taskLabel = metadata?.task || `Auto-tracked task (${taskId})`;
    const role = latest?.role || metadata?.role || 'unassigned';
    const priority = metadata?.priority || 'medium';
    const status = latest?.status || metadata?.status || 'pending';
    const lastUpdated = latest?.timestamp?.slice(0, 10) || metadata?.lastUpdated || '-';
    const notes =
      latest?.changeNote ||
      latest?.summary ||
      metadata?.notes ||
      'Auto-generated from async run events.';

    return `| ${encodeCell(taskId)} | ${encodeCell(taskLabel)} | ${encodeCell(role)} | ${encodeCell(priority)} | ${encodeCell(status)} | ${encodeCell(lastUpdated)} | ${encodeCell(notes)} |`;
  });

  return [
    '| Task ID | Task | Suggested Role | Priority | Status | Last Updated | Notes |',
    '|---|---|---|---|---|---|---|',
    ...rows
  ].join('\n');
};

const buildRunLedgerTable = (events) => {
  const rows = events.map((event) => {
    return `| ${encodeCell(event.timestamp)} | ${encodeCell(event.role)} | ${encodeCell(event.taskId)} | ${encodeCell(event.summary)} | ${encodeCell(event.validation)} | ${encodeCell(event.nextStep)} |`;
  });

  return [
    '| Timestamp (UTC) | Role | Task ID | Summary | Validation | Next Step |',
    '|---|---|---|---|---|---|',
    ...rows
  ].join('\n');
};

const renderTaskSnapshotSection = (table) => {
  return [
    'Auto-generated from `Async Run Event Log`. Do not edit rows manually.',
    '',
    GENERATED_TASK_BOARD_START,
    table,
    GENERATED_TASK_BOARD_END,
    ''
  ].join('\n');
};

const renderRunLedgerSection = (table) => {
  return [
    'Auto-generated from `Async Run Event Log` (latest first). Do not edit rows manually.',
    '',
    GENERATED_RUN_LEDGER_START,
    table,
    GENERATED_RUN_LEDGER_END,
    ''
  ].join('\n');
};

const replaceSlice = (source, start, end, replacement) => {
  return `${source.slice(0, start)}${replacement}${source.slice(end)}`;
};

export const materializeWhiteboard = (source) => {
  const events = parseAsyncEvents(source);
  const taskMetadata = parseTaskSnapshotMetadata(source);

  const taskTable = buildTaskSnapshotTable({
    metadataById: taskMetadata.map,
    metadataOrder: taskMetadata.order,
    events
  });
  let updated = replaceSlice(source, taskMetadata.bounds.start, taskMetadata.bounds.end, `\n${renderTaskSnapshotSection(taskTable)}`);

  const ledgerBounds = findBoundsBetween(updated, '## Role Run Ledger', 'Entry template:');
  const ledgerTable = buildRunLedgerTable(events);
  updated = replaceSlice(updated, ledgerBounds.start, ledgerBounds.end, `\n${renderRunLedgerSection(ledgerTable)}`);

  updated = updated.replace(/^Last verified:.*$/m, LAST_VERIFIED_DERIVED_LINE);
  return updated;
};

const THIS_FILE = fileURLToPath(import.meta.url);
const isDirectRun = process.argv[1] && resolve(process.argv[1]) === resolve(THIS_FILE);

if (isDirectRun) {
  const source = readFileSync(WHITEBOARD_PATH, 'utf8');
  const materialized = materializeWhiteboard(source);
  writeFileSync(WHITEBOARD_PATH, materialized, 'utf8');
  console.log('Materialized task board and run ledger snapshots from async run events.');
}
