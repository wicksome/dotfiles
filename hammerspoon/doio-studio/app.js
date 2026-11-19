"use strict";

// ---------------------------------------------------------------------------
// 패드 배치. pos 는 펌웨어 행렬 칸(행, 열)이다. 정의 파일 kb16b-02 V2.json (5행 × 7열) 기준.
// id 는 물리 자리 이름이다(doio.lua 의 PAD_INPUTS 와 같다). 자리가 어떤 키를 보내는지는 펌웨어 키맵이 정한다.
// defaultCode 는 펌웨어 기본 키맵(레이어 0)이 그 자리에 둔 keycode 다. 펌웨어를 아직 읽지 않았을 때 쓴다.
// ---------------------------------------------------------------------------
const PAD_KEYS = [
  [{ id: "1", pos: [0, 1], defaultCode: 0x1e }, { id: "2", pos: [0, 2], defaultCode: 0x1f }, { id: "3", pos: [0, 3], defaultCode: 0x20 }, { id: "4", pos: [0, 4], defaultCode: 0x21 }],
  [{ id: "5", pos: [1, 1], defaultCode: 0x22 }, { id: "6", pos: [1, 2], defaultCode: 0x23 }, { id: "7", pos: [1, 3], defaultCode: 0x24 }, { id: "8", pos: [1, 4], defaultCode: 0x25 }],
  [{ id: "9", pos: [2, 1], defaultCode: 0x26 }, { id: "0", pos: [2, 2], defaultCode: 0x27 }, { id: "up", pos: [2, 3], defaultCode: 0x52 }, { id: "return", pos: [2, 4], defaultCode: 0x28 }],
  [{ id: "bottomLeft", pos: [3, 1], defaultCode: 0x5103 }, { id: "left", pos: [3, 2], defaultCode: 0x50 }, { id: "down", pos: [3, 3], defaultCode: 0x51 }, { id: "right", pos: [3, 4], defaultCode: 0x4f }],
];

const KNOBS = [
  {
    className: "left-small", title: "왼쪽 작은 노브",
    slots: [
      { name: "↺", id: "leftKnobLeft", pos: [4, 6], defaultCode: 0xac },
      { name: "누름", id: "leftKnobPress", pos: [4, 5], defaultCode: 0xae },
      { name: "↻", id: "leftKnobRight", pos: [3, 6], defaultCode: 0xab },
    ],
  },
  {
    className: "big", title: "큰 노브",
    slots: [
      { name: "↺", id: "bigKnobLeft", pos: [1, 6], defaultCode: 0xaa },
      { name: "누름", id: "bigKnobPress", pos: [2, 5], defaultCode: 0xa8 },
      { name: "↻", id: "bigKnobRight", pos: [0, 6], defaultCode: 0xa9 },
    ],
  },
  {
    className: "right-small", title: "오른쪽 작은 노브",
    slots: [
      { name: "↺", id: "knobLeft", pos: [1, 5], defaultCode: 0x4b },
      { name: "누름", id: "rightKnobPress", pos: [3, 5], defaultCode: 0x5011 },
      { name: "↻", id: "knobRight", pos: [0, 5], defaultCode: 0x4e },
    ],
  },
];

const ALL_CELLS = [...PAD_KEYS.flat(), ...KNOBS.flatMap((knob) => knob.slots)];

// 정의 파일 배치에 쓰인 칸. 행렬 표에서 그 밖의 칸을 구분해 보여준다.
const DEFINED_CELLS = new Set(ALL_CELLS.map((cell) => cell.pos.join(",")));

// QMK keycode(= HID usage) → Hammerspoon 키 이름. 맥이 일반 키 이벤트로 받는 것만 있다.
const HS_KEY_NAMES = {};
"abcdefghijklmnopqrstuvwxyz".split("").forEach((ch, i) => { HS_KEY_NAMES[0x04 + i] = ch; });
"1234567890".split("").forEach((ch, i) => { HS_KEY_NAMES[0x1e + i] = ch; });
Object.assign(HS_KEY_NAMES, {
  0x28: "return", 0x29: "escape", 0x2a: "delete", 0x2b: "tab", 0x2c: "space", 0x2d: "-", 0x2e: "=", 0x2f: "[",
  0x30: "]", 0x31: "\\", 0x33: ";", 0x34: "'", 0x35: "`", 0x36: ",", 0x37: ".", 0x38: "/", 0x39: "capslock",
  0x4a: "home", 0x4b: "pageup", 0x4c: "forwarddelete", 0x4d: "end", 0x4e: "pagedown",
  0x4f: "right", 0x50: "left", 0x51: "down", 0x52: "up",
});
for (let i = 0; i < 12; i++) HS_KEY_NAMES[0x3a + i] = `f${i + 1}`;
for (let i = 0; i < 8; i++) HS_KEY_NAMES[0x68 + i] = `f${i + 13}`; // macOS 는 F20 까지만 받는다

// 미디어 keycode → Hammerspoon 미디어 키 이름(doio-mapping.json 의 media).
const MEDIA_NAMES = { 0xa8: "MUTE", 0xa9: "SOUND_UP", 0xaa: "SOUND_DOWN", 0xab: "NEXT", 0xac: "PREVIOUS", 0xae: "PLAY" };

// keycode 가 맥에 무엇으로 오는지. key = 일반 키(Hammerspoon 이 자리로 알아봄), media = 미디어 키, 그 밖 = 맥에 안 옴.
// 수정키가 붙은 keycode(예: ⌘+A)는 Hammerspoon 이 keycode 로만 알아보므로 기본 키 이름을 쓴다.
function classifyCode(code) {
  const base = code > 0xff && code < 0x2000 ? code & 0xff : code;
  if (HS_KEY_NAMES[base]) return { key: HS_KEY_NAMES[base] };
  if (MEDIA_NAMES[code]) return { media: MEDIA_NAMES[code] };
  return {};
}

const hex4 = (code) => `0x${code.toString(16).toUpperCase().padStart(4, "0")}`;

const MOD_SYMBOLS = [["ctrl", "⌃"], ["alt", "⌥"], ["shift", "⇧"], ["cmd", "⌘"]];
const KEY_SYMBOLS = {
  up: "↑", down: "↓", left: "←", right: "→", return: "⏎", delete: "⌫",
  tab: "⇥", space: "␣", escape: "⎋", forwarddelete: "⌦", pageup: "PgUp", pagedown: "PgDn",
};
const SEND_KEY_SUGGESTIONS = [
  "escape", "tab", "space", "return", "delete", "forwarddelete", "up", "down", "left", "right",
  "home", "end", "pageup", "pagedown",
  ..."abcdefghijklmnopqrstuvwxyz".split(""), ..."0123456789".split(""),
  "[", "]", "-", "=", ";", "'", ",", ".", "/", "`", "\\",
  ...Array.from({ length: 20 }, (_, i) => `f${i + 1}`),
];

const $ = (selector) => document.querySelector(selector);
const escapeHtml = (text) => String(text ?? "").replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);

function shortcutLabel(mods, key) {
  const prefix = MOD_SYMBOLS.filter(([mod]) => (mods || []).includes(mod)).map(([, symbol]) => symbol).join("");
  return prefix + (KEY_SYMBOLS[key] || key.toUpperCase());
}

function inputId(input) {
  return input.key !== undefined ? `key:${input.key}` : `media:${input.media}`;
}

const MEDIA_LABELS = { PREVIOUS: "⏮", NEXT: "⏭", PLAY: "⏯", SOUND_DOWN: "🔉", SOUND_UP: "🔊", MUTE: "🔇" };

// 이 자리가 지금 펌웨어에서 보내는 keycode. 펌웨어를 USB 로 읽은 적이 없으면 펌웨어 기본값이다.
function firmwareCode(cell) {
  const saved = mappingState.server?.firmware?.inputs?.[cell.id];
  return saved ? parseInt(saved.code, 16) : cell.defaultCode;
}

// 자리 → 앱별 매핑의 입력. 일반 키를 보내면 { key: 자리 }, 미디어 키면 { media }, 맥에 안 오면 { fixed }.
function cellInput(cell) {
  const code = firmwareCode(cell);
  const output = classifyCode(code);
  if (output.key) return { key: cell.id, sends: output.key };
  if (output.media) return { media: output.media };
  return { fixed: keycodeName(code) };
}

// ===========================================================================
// 앱별 매핑 탭
// ===========================================================================
const mappingState = {
  server: null, // GET /api/mapping 응답
  saved: "", // 마지막으로 읽은 rules 직렬화. 바뀐 건수를 센다
  rules: [],
  appNames: {},
  apps: [], // 칩에 보일 번들 ID 순서
  selectedApp: null, // null = 모든 앱
  selectedInput: null, // { key } 또는 { media }
};

function findRule(input, app) {
  return mappingState.rules.find((rule) =>
    (input.key !== undefined ? rule.key === input.key : rule.media === input.media) && (rule.app ?? null) === app);
}

// 앞 앱이 app 일 때 이 입력에 적용되는 규칙과 그 출처.
function effectiveRule(input) {
  const app = mappingState.selectedApp;
  if (app) {
    const own = findRule(input, app);
    if (own) return { rule: own, source: "app" };
  }
  const global = findRule(input, null);
  if (global) return { rule: global, source: "global" };
  return { rule: null, source: "none" };
}

function ruleLabels(rule, input) {
  if (!rule) return { main: input.sends ? shortcutLabel([], input.sends) : MEDIA_LABELS[input.media], sub: "" };
  if (rule.block) return { main: "✕", sub: "막음" };
  if (rule.send) return { main: rule.shortcut || shortcutLabel(rule.send.mods, rule.send.key), sub: rule.description || "" };
  const action = mappingState.server.actions[rule.action];
  return { main: rule.shortcut || action?.label || rule.action, sub: rule.description || "" };
}

function cellHtml(cell, extraClass, positionLabel) {
  const input = cellInput(cell);
  if (input.fixed) {
    return `<div class="key fixed ${extraClass}" data-pos="${cell.pos.join(",")}" title="펌웨어에서 ${escapeHtml(input.fixed)} 이라 맥으로 키 이벤트가 오지 않는다. ① 펌웨어 키맵에서 바꾼다">
      <i class="pos">${positionLabel}</i><span class="main">—</span><span class="sub">${escapeHtml(input.fixed)}</span></div>`;
  }
  const { rule, source } = effectiveRule(input);
  const labels = ruleLabels(rule, input);
  const classes = ["key", extraClass, rule?.block ? "blocked" : source];
  if (mappingState.selectedInput && inputId(mappingState.selectedInput) === inputId(input)) classes.push("selected");
  return `<button class="${classes.join(" ")}" data-input="${escapeHtml(inputId(input))}" data-pos="${cell.pos.join(",")}">
    <i class="pos">${positionLabel}</i><span class="main">${escapeHtml(labels.main)}</span><span class="sub">${escapeHtml(labels.sub)}</span></button>`;
}

function renderPad(container, cellRenderer) {
  let html = "";
  PAD_KEYS.forEach((row, r) => row.forEach((cell, c) => {
    html += `<div style="grid-row:${r + 1};grid-column:${c + 1};display:grid">${cellRenderer(cell, "", `${r * 4 + c + 1}`)}</div>`;
  }));
  KNOBS.forEach((knob) => {
    html += `<div class="knob-wrap ${knob.className}"><span class="knob-title">${knob.title}</span><div class="knob-slots">`;
    knob.slots.forEach((slot) => { html += cellRenderer(slot, "", slot.name); });
    html += `</div></div>`;
  });
  container.innerHTML = html;
}

function renderMapping() {
  const chips = [null, ...mappingState.apps].map((app) => {
    const name = app ? (mappingState.appNames[app] || app) : "모든 앱";
    return `<button class="chip ${app === mappingState.selectedApp ? "active" : ""}" data-app="${escapeHtml(app ?? "")}">${escapeHtml(name)}</button>`;
  });
  $("#app-chips").innerHTML = chips.join("");
  renderPad($("#mapping-pad"), cellHtml);
  renderEditor();
  showPressed(tester.pressed);
  const dirty = serializeRules() !== mappingState.saved;
  $("#mapping-save").disabled = !dirty;
  $("#mapping-revert").disabled = !dirty;
  $("#dirty-count").textContent = dirty ? "저장하지 않은 변경이 있다" : "";
  const bySentKey = {};
  ALL_CELLS.map(cellInput).filter((input) => input.key).forEach((input) => {
    (bySentKey[input.sends] = bySentKey[input.sends] || []).push(input.key);
  });
  const duplicates = Object.entries(bySentKey).filter(([, ids]) => ids.length > 1);
  const source = mappingState.server?.firmware ? "USB 로 마지막에 읽은 펌웨어 키맵" : "펌웨어 기본 키맵(아직 USB 로 읽지 않음)";
  $("#mapping-hint").textContent = `칸은 ${source} 기준이다. 키를 눌러 아래에서 할 일을 고른다.` +
    (duplicates.length ? ` 같은 키를 보내는 자리가 있어 맥이 구분하지 못한다: ${duplicates.map(([key, ids]) => `${key}(${ids.join("·")})`).join(", ")}` : "");
}

function renderEditor() {
  const input = mappingState.selectedInput;
  const editor = $("#mapping-editor");
  if (!input) { editor.innerHTML = ""; return; }
  const app = mappingState.selectedApp;
  const own = findRule(input, app);
  const inherited = !own && app ? findRule(input, null) : null;
  const rule = own || {};
  const kind = rule.block ? "block" : rule.send ? "send" : rule.action ? "action" : "none";
  // 미디어 키는 노트북 키와 구분되지 않아 모든 앱 규칙으로는 막기만 허용한다(doio-mapping.lua 검사와 같은 규칙).
  const mediaWithoutApp = input.media !== undefined && !app;
  const appName = app ? (mappingState.appNames[app] || app) : "모든 앱";
  const inputName = input.key !== undefined
    ? `${input.key} 자리 (펌웨어가 보내는 키: ${shortcutLabel([], input.sends)})`
    : `미디어 키 ${input.media}`;
  const actions = mappingState.server.actions;
  const actionName = rule.action || Object.keys(actions)[0];
  const params = rule.params || {};
  const paramFields = Object.entries(actions[actionName]?.params || {}).map(([name, type]) =>
    `<span class="field-label">${escapeHtml(name)}</span><input type="${type === "number" ? "number" : "text"}" data-param="${escapeHtml(name)}" data-type="${type}" value="${escapeHtml(params[name] ?? "")}">`).join("");

  const choice = (value, label, disabled) =>
    `<label class="choice ${disabled ? "disabled" : ""}"><input type="radio" name="kind" value="${value}" ${kind === value ? "checked" : ""} ${disabled ? "disabled" : ""}>${label}</label>`;

  editor.innerHTML = `
    <h2>${escapeHtml(inputName)} · ${escapeHtml(appName)}</h2>
    <p class="note">${inherited ? `지금은 모든 앱 규칙(${escapeHtml(ruleLabels(inherited, input).main)})을 따른다. 여기서 고르면 ${escapeHtml(appName)} 전용 규칙이 생긴다.` : app ? `${escapeHtml(appName)} 이 앞에 있을 때만 적용한다.` : "모든 앱에 적용한다. 앱 전용 규칙이 있으면 그 앱에서는 앱 규칙이 우선한다."}
    ${mediaWithoutApp ? "<br>미디어 키는 노트북 키와 구분되지 않아, 모든 앱에서는 막기만 할 수 있다. 다른 동작은 앱을 골라 건다." : ""}</p>
    <div class="row">
      ${choice("none", app ? "규칙 없음 (모든 앱 규칙을 따름)" : "규칙 없음 (패드 키 그대로)")}
      ${choice("block", "막기")}
      ${choice("send", "다른 키 보내기", mediaWithoutApp)}
      ${choice("action", "동작 실행", mediaWithoutApp)}
    </div>
    <div class="row" data-show="send">
      <span class="field-label">보낼 키</span>
      <input type="text" id="send-key" list="send-keys" value="${escapeHtml(rule.send?.key ?? "")}" placeholder="예: a, escape, f13">
      <datalist id="send-keys">${SEND_KEY_SUGGESTIONS.map((k) => `<option value="${escapeHtml(k)}">`).join("")}</datalist>
      ${MOD_SYMBOLS.map(([mod, symbol]) => `<label class="choice"><input type="checkbox" data-mod="${mod}" ${(rule.send?.mods || []).includes(mod) ? "checked" : ""}>${symbol} ${mod}</label>`).join("")}
    </div>
    <div class="row" data-show="action">
      <span class="field-label">동작</span>
      <select id="action-name">${Object.entries(actions).map(([name, a]) => `<option value="${escapeHtml(name)}" ${name === actionName ? "selected" : ""}>${escapeHtml(a.label)}</option>`).join("")}</select>
      ${paramFields}
    </div>
    <div class="row" data-show="send action">
      <span class="field-label">윗줄</span><input type="text" id="rule-shortcut" value="${escapeHtml(rule.shortcut ?? "")}" placeholder="비우면 자동">
      <span class="field-label">아랫줄</span><input type="text" id="rule-description" value="${escapeHtml(rule.description ?? "")}" placeholder="하는 일 설명">
    </div>`;
  editor.querySelectorAll("[data-show]").forEach((row) => {
    row.style.display = row.dataset.show.split(" ").includes(kind) ? "" : "none";
  });
}

// 편집기 값으로 선택한 입력·앱의 규칙을 만들거나 지운다.
function applyEditor() {
  const input = mappingState.selectedInput;
  const app = mappingState.selectedApp;
  const editor = $("#mapping-editor");
  const kind = editor.querySelector("input[name=kind]:checked")?.value || "none";
  const existingIndex = mappingState.rules.indexOf(findRule(input, app));
  if (kind === "none") {
    if (existingIndex >= 0) mappingState.rules.splice(existingIndex, 1);
    return;
  }
  const rule = {};
  if (app) rule.app = app;
  if (input.key !== undefined) rule.key = input.key; else rule.media = input.media;
  if (kind === "block") rule.block = true;
  if (kind === "send") {
    const mods = [...editor.querySelectorAll("[data-mod]:checked")].map((box) => box.dataset.mod);
    rule.send = { key: editor.querySelector("#send-key")?.value.trim() || "" };
    if (mods.length) rule.send.mods = MOD_SYMBOLS.map(([mod]) => mod).filter((mod) => mods.includes(mod)).reverse();
  }
  if (kind === "action") {
    const name = editor.querySelector("#action-name").value;
    rule.action = name;
    const params = {};
    editor.querySelectorAll("[data-param]").forEach((field) => {
      params[field.dataset.param] = field.dataset.type === "number" ? Number(field.value) : field.value;
    });
    if (Object.keys(params).length) rule.params = params;
  }
  if (kind === "send" || kind === "action") {
    const shortcut = editor.querySelector("#rule-shortcut")?.value.trim();
    const description = editor.querySelector("#rule-description")?.value.trim();
    if (shortcut) rule.shortcut = shortcut;
    if (description) rule.description = description;
  }
  if (existingIndex >= 0) mappingState.rules[existingIndex] = rule;
  else mappingState.rules.push(rule);
}

// doio-mapping.json 과 같은 모양으로 쓴다. 규칙 밖 필드(params 안 등)는 이름순이다. Hammerspoon 이 JSON 을 읽으면 필드 순서가 섞이기 때문이다. 모든 앱 규칙 먼저, 앱 규칙은 앱별로 묶고 묶음 사이에 빈 줄을 둔다.
const FIELD_ORDER = ["app", "key", "media", "block", "send", "action", "params", "shortcut", "description"];

function formatValue(value) {
  if (Array.isArray(value)) return `[${value.map(formatValue).join(", ")}]`;
  if (value && typeof value === "object") {
    const keys = [...FIELD_ORDER.filter((k) => k in value), ...Object.keys(value).filter((k) => !FIELD_ORDER.includes(k)).sort()];
    return `{ ${keys.map((k) => `${JSON.stringify(k)}: ${formatValue(value[k])}`).join(", ")} }`;
  }
  return JSON.stringify(value);
}

function serializeRules() {
  const groups = new Map([[null, []]]);
  mappingState.rules.forEach((rule) => {
    const app = rule.app ?? null;
    if (!groups.has(app)) groups.set(app, []);
    groups.get(app).push(rule);
  });
  const blocks = [...groups.values()].filter((rules) => rules.length).map((rules) => rules.map((rule) => `    ${formatValue(rule)}`).join(",\n"));
  return `{\n  "rules": [\n${blocks.join(",\n\n")}\n  ]\n}\n`;
}

async function loadMapping() {
  try {
    const response = await fetch("/api/mapping", { cache: "no-store" });
    const server = await response.json();
    mappingState.server = server;
    mappingState.rules = structuredClone(server.mapping.rules || []);
    mappingState.appNames = { ...mappingState.appNames, ...server.appNames };
    const ruleApps = [...new Set(mappingState.rules.map((rule) => rule.app).filter(Boolean))];
    mappingState.apps = [...new Set([...ruleApps, ...mappingState.apps])];
    mappingState.saved = serializeRules();
    setStatus("hs", true, "연결됨");
    renderMapping();
  } catch (error) {
    setStatus("hs", false, "응답 없음");
  }
}

async function loadRunningApps() {
  try {
    const apps = await (await fetch("/api/apps")).json();
    $("#app-add").innerHTML = `<option value="">+ 앱 추가</option>` +
      apps.map((app) => `<option value="${escapeHtml(app.bundleID)}">${escapeHtml(app.name)}</option>`).join("");
  } catch (error) { /* 서버 응답이 없으면 목록을 비워 둔다 */ }
}

async function saveMapping() {
  const body = serializeRules();
  const problems = $("#mapping-problems");
  problems.className = "problems";
  const response = await fetch("/api/mapping", {
    method: "PUT", headers: { "Content-Type": "application/json", "X-DOIO-Studio": "1" }, body,
  });
  const result = await response.json();
  if (!response.ok) {
    problems.textContent = "저장하지 않았다:\n" + (result.problems || []).join("\n");
    return;
  }
  problems.className = "problems ok";
  problems.textContent = `저장했다 (규칙 ${result.saved}개). Hammerspoon 이 다시 읽는 중…`;
  // 리로드하는 동안 서버가 잠깐 내려간다. 다시 응답하면 새로 읽는다.
  setStatus("hs", false, "다시 읽는 중");
  await waitForHammerspoon();
  await loadMapping();
  problems.textContent = `저장했고 Hammerspoon 이 새 매핑을 읽었다 (규칙 ${result.saved}개).`;
}

function setupMappingEvents() {
  $("#app-chips").addEventListener("click", (event) => {
    const chip = event.target.closest(".chip");
    if (!chip) return;
    mappingState.selectedApp = chip.dataset.app || null;
    renderMapping();
  });
  $("#app-add").addEventListener("change", (event) => {
    const bundleID = event.target.value;
    if (!bundleID) return;
    mappingState.appNames[bundleID] = event.target.selectedOptions[0].textContent;
    if (!mappingState.apps.includes(bundleID)) mappingState.apps.push(bundleID);
    mappingState.selectedApp = bundleID;
    event.target.value = "";
    renderMapping();
  });
  $("#mapping-pad").addEventListener("click", (event) => {
    const cell = event.target.closest("[data-input]");
    if (!cell) return;
    const [type, name] = cell.dataset.input.split(/:(.*)/s);
    mappingState.selectedInput = type === "key"
      ? cellInput(ALL_CELLS.find((c) => c.id === name))
      : { media: name };
    renderMapping();
  });
  $("#mapping-editor").addEventListener("change", (event) => {
    if (event.target.id === "action-name") {
      // 동작을 바꾸면 파라미터 칸이 달라지므로, 새 동작으로 규칙을 만든 뒤 다시 그린다.
      applyEditor();
      const rule = findRule(mappingState.selectedInput, mappingState.selectedApp);
      if (rule) delete rule.params;
    } else {
      applyEditor();
    }
    renderMapping();
  });
  $("#mapping-save").addEventListener("click", saveMapping);
  $("#mapping-revert").addEventListener("click", () => {
    mappingState.rules = structuredClone(mappingState.server.mapping.rules || []);
    $("#mapping-problems").textContent = "";
    renderMapping();
  });
}

// ===========================================================================
// 펌웨어 키맵 탭 (VIA 프로토콜 9, WebHID)
// ===========================================================================
const VIA = { GET_PROTOCOL: 0x01, SET_KEYCODE: 0x05, GET_LAYER_COUNT: 0x11, GET_BUFFER: 0x12 };
const ROWS = 5;
const COLS = 7;

const firmwareState = {
  usbAttached: null, // Hammerspoon 이 본 USB 연결 여부. null = 아직 모름
  device: null,
  protocol: null,
  layers: 0,
  layer: 0,
  keymap: [], // [layer][row*COLS+col] = keycode, 패드에서 읽은 값
  pending: new Map(), // "layer,row,col" → 바꿀 keycode
  selectedPos: null,
  pickerGroup: "기본",
};

// --- keycode 이름 (VIA 프로토콜 9 = QMK 옛 keycode 체계) ---
const BASIC_NAMES = {};
"ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("").forEach((ch, i) => { BASIC_NAMES[0x04 + i] = ch; });
"1234567890".split("").forEach((ch, i) => { BASIC_NAMES[0x1e + i] = ch; });
Object.assign(BASIC_NAMES, {
  0x28: "Enter", 0x29: "Esc", 0x2a: "Bksp", 0x2b: "Tab", 0x2c: "Space", 0x2d: "-", 0x2e: "=", 0x2f: "[", 0x30: "]",
  0x31: "\\", 0x33: ";", 0x34: "'", 0x35: "`", 0x36: ",", 0x37: ".", 0x38: "/", 0x39: "Caps",
  0x46: "PrtSc", 0x47: "ScrLk", 0x48: "Pause", 0x49: "Ins", 0x4a: "Home", 0x4b: "PgUp", 0x4c: "Del", 0x4d: "End",
  0x4e: "PgDn", 0x4f: "→", 0x50: "←", 0x51: "↓", 0x52: "↑",
  0xa8: "Mute", 0xa9: "Vol+", 0xaa: "Vol-", 0xab: "Next", 0xac: "Prev", 0xad: "Stop", 0xae: "Play",
  0xe0: "LCtl", 0xe1: "LSft", 0xe2: "LAlt", 0xe3: "LCmd", 0xe4: "RCtl", 0xe5: "RSft", 0xe6: "RAlt", 0xe7: "RCmd",
});
for (let i = 0; i < 12; i++) BASIC_NAMES[0x3a + i] = `F${i + 1}`;
for (let i = 0; i < 12; i++) BASIC_NAMES[0x68 + i] = `F${i + 13}`;

const RGB_NAMES = { 0x5cc2: "RGB 켜기/끄기", 0x5cc3: "RGB 모드+", 0x5cc4: "RGB 모드-", 0x5cc5: "색상+", 0x5cc6: "색상-", 0x5cc7: "채도+", 0x5cc8: "채도-", 0x5cc9: "밝기+", 0x5cca: "밝기-", 0x5ccb: "속도+", 0x5ccc: "속도-" };
const MOD_BITS = [[0x0100, "⌃"], [0x0400, "⌥"], [0x0200, "⇧"], [0x0800, "⌘"]];

function keycodeName(code) {
  if (code === 0x0000) return "없음";
  if (code === 0x0001) return "▽";
  if (BASIC_NAMES[code]) return BASIC_NAMES[code];
  if (code >= 0x5100 && code <= 0x51ff) return `MO${code & 0xff}`;
  if (code >= 0x5010 && code <= 0x501f) return `TO${code & 0x0f}`;
  if (RGB_NAMES[code]) return RGB_NAMES[code];
  if (code >= 0x5f12 && code <= 0x5f21) return `M${code - 0x5f12}`;
  if (code > 0x00ff && code < 0x2000 && BASIC_NAMES[code & 0xff]) {
    const mods = MOD_BITS.filter(([bit]) => code & bit).map(([, symbol]) => symbol).join("");
    return mods + BASIC_NAMES[code & 0xff];
  }
  return `0x${code.toString(16).toUpperCase().padStart(4, "0")}`;
}

const PICKER_GROUPS = {
  기본: [...Array.from({ length: 26 }, (_, i) => 0x04 + i), ...Array.from({ length: 10 }, (_, i) => 0x1e + i),
    0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38],
  "F 키": [...Array.from({ length: 12 }, (_, i) => 0x3a + i), ...Array.from({ length: 12 }, (_, i) => 0x68 + i)],
  "이동·편집": [0x4f, 0x50, 0x51, 0x52, 0x4a, 0x4d, 0x4b, 0x4e, 0x49, 0x4c, 0x46, 0x47, 0x48, 0x39],
  미디어: [0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae],
  수정키: [0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7],
  레이어: [0x0001, 0x0000, ...Array.from({ length: 9 }, (_, i) => 0x5100 + i), ...Array.from({ length: 9 }, (_, i) => 0x5010 + i)],
  조명: Object.keys(RGB_NAMES).map(Number),
  매크로: Array.from({ length: 16 }, (_, i) => 0x5f12 + i),
};

// --- HID 통신 ---
let pendingResponse = null;

function onInputReport(event) {
  if (pendingResponse) {
    const resolve = pendingResponse;
    pendingResponse = null;
    resolve(new Uint8Array(event.data.buffer));
  }
}

// 명령은 한 번에 하나씩 보낸다. 응답에 명령 번호 말고 짝을 맞출 값이 없어서다(키 눌림 확인이 주기적으로 끼어든다).
let commandQueue = Promise.resolve();

function viaCommand(...bytes) {
  const run = commandQueue.then(() => sendViaCommand(bytes));
  commandQueue = run.catch(() => {});
  return run;
}

async function sendViaCommand(bytes) {
  const report = new Uint8Array(32);
  report.set(bytes);
  const response = new Promise((resolve, reject) => {
    pendingResponse = resolve;
    setTimeout(() => { if (pendingResponse === resolve) { pendingResponse = null; reject(new Error("패드 응답 없음")); } }, 1000);
  });
  await firmwareState.device.sendReport(0, report);
  return response;
}

async function readKeymap() {
  const total = firmwareState.layers * ROWS * COLS * 2;
  const bytes = [];
  for (let offset = 0; offset < total; offset += 28) {
    const size = Math.min(28, total - offset);
    const response = await viaCommand(VIA.GET_BUFFER, offset >> 8, offset & 0xff, size);
    bytes.push(...response.slice(4, 4 + size));
  }
  const keymap = [];
  for (let layer = 0; layer < firmwareState.layers; layer++) {
    const cells = [];
    for (let i = 0; i < ROWS * COLS; i++) {
      const at = (layer * ROWS * COLS + i) * 2;
      cells.push((bytes[at] << 8) | bytes[at + 1]);
    }
    keymap.push(cells);
  }
  return keymap;
}

const PAD_FILTER = { vendorId: 0xfeed, productId: 0x6060, usagePage: 0xff60, usage: 0x61 };

function isPadInterface(device) {
  return device.vendorId === PAD_FILTER.vendorId && device.productId === PAD_FILTER.productId &&
    device.collections.some((c) => c.usagePage === PAD_FILTER.usagePage && c.usage === PAD_FILTER.usage);
}

// 레이어 0 의 자리별 출력을 Hammerspoon 에 넘긴다(doio-firmware.json). 바뀌었으면 Hammerspoon 이 다시 읽는다.
// 앱별 매핑은 레이어 0 기준이다. 다른 레이어는 대부분 비어 있어(▽) 레이어 0 의 키가 나간다.
async function syncFirmwareSnapshot() {
  const lines = ALL_CELLS.map((cell) => {
    const code = firmwareState.keymap[0][cell.pos[0] * COLS + cell.pos[1]];
    return `    ${JSON.stringify(cell.id)}: ${formatValue({ code: hex4(code), ...classifyCode(code) })}`;
  });
  const body = `{\n  "inputs": {\n${lines.join(",\n")}\n  }\n}\n`;
  const response = await fetch("/api/firmware", {
    method: "PUT", headers: { "Content-Type": "application/json", "X-DOIO-Studio": "1" }, body,
  });
  const result = await response.json();
  if (result.changed) {
    setStatus("hs", false, "펌웨어 반영 중");
    await waitForHammerspoon();
    await loadMapping();
  }
}

// Hammerspoon 이 리로드하는 동안 서버가 잠깐 내려간다. 다시 응답할 때까지 기다린다.
async function waitForHammerspoon() {
  for (let attempt = 0; attempt < 20; attempt++) {
    await new Promise((resolve) => setTimeout(resolve, 500));
    try {
      if ((await fetch("/api/mapping", { cache: "no-store" })).ok) return;
    } catch (error) { /* 아직 리로드 중 */ }
  }
}

// 장치를 열고 프로토콜·레이어 수·키맵을 읽는다. 버튼(권한 요청)과 자동 연결이 함께 쓴다.
async function openPad(device) {
  if (!device.opened) await device.open();
  device.addEventListener("inputreport", onInputReport);
  firmwareState.device = device;
  setStatus("hid", true, "읽는 중");
  const protocol = await viaCommand(VIA.GET_PROTOCOL);
  firmwareState.protocol = (protocol[1] << 8) | protocol[2];
  firmwareState.layers = (await viaCommand(VIA.GET_LAYER_COUNT))[1];
  firmwareState.keymap = await readKeymap();
  firmwareState.pending.clear();
  setStatus("hid", true, `VIA ${firmwareState.protocol} · 레이어 ${firmwareState.layers}`);
  $("#hid-connect").textContent = "다시 읽기";
  $("#fw-hint").textContent = "칸을 눌러 아래에서 키코드를 고른다. 「펌웨어에 쓰기」를 누르기 전에는 패드에 쓰지 않는다.";
  renderFirmware();
  await readMacros();
  await syncFirmwareSnapshot();
}

async function connectPad() {
  if (firmwareState.usbAttached === false) return;
  if (!("hid" in navigator)) {
    setStatus("hid", false, "WebHID 없음");
    $("#fw-hint").textContent = "이 브라우저에는 WebHID 가 없다. Chrome 이나 Edge 로 연다.";
    return;
  }
  if (firmwareState.device) {
    await openPad(firmwareState.device);
    return;
  }
  const [device] = await navigator.hid.requestDevice({ filters: [PAD_FILTER] });
  if (device) await openPad(device);
}

// Hammerspoon 에 USB 연결 여부를 묻는다. 꽂거나 뽑으면 화면을 바꾼다.
async function pollUsb() {
  try {
    const { usb } = await (await fetch("/api/pad", { cache: "no-store" })).json();
    if (usb === firmwareState.usbAttached) return;
    const wasAttached = firmwareState.usbAttached;
    firmwareState.usbAttached = usb;
    if (usb && !firmwareState.device) {
      setStatus("hid", false, "연결 안 됨");
      $("#fw-hint").textContent = "패드가 USB 로 꽂혀 있다. 왼쪽 「패드 연결」을 누른다. 한 번 허용하면 다음부터는 자동으로 연결한다.";
      if (wasAttached === false) await autoConnectPad();
    }
    renderFirmware();
  } catch (error) { /* Hammerspoon 리로드 중 */ }
}

// 이미 허용한 패드가 꽂혀 있으면 권한 창 없이 연결한다.
async function autoConnectPad() {
  if (!("hid" in navigator) || firmwareState.device) return;
  const device = (await navigator.hid.getDevices()).find(isPadInterface);
  if (device) await openPad(device);
}

function showConnectError(error) {
  setStatus("hid", false, "연결 실패");
  $("#fw-hint").textContent = `연결 실패: ${error.message}`;
}

function currentCode(layer, row, col) {
  const pendingKey = `${layer},${row},${col}`;
  if (firmwareState.pending.has(pendingKey)) return firmwareState.pending.get(pendingKey);
  return firmwareState.keymap[layer]?.[row * COLS + col];
}

function firmwareCellHtml(input, extraClass, positionLabel) {
  const [row, col] = input.pos;
  const code = currentCode(firmwareState.layer, row, col);
  const classes = ["key", extraClass];
  if (firmwareState.pending.has(`${firmwareState.layer},${row},${col}`)) classes.push("dirty");
  if (firmwareState.selectedPos?.join(",") === input.pos.join(",")) classes.push("selected");
  const label = code === undefined ? "?" : keycodeName(code);
  return `<button class="${classes.join(" ")}" data-pos="${row},${col}">
    <i class="pos">${positionLabel}</i><span class="main">${escapeHtml(label)}</span><span class="sub">${row},${col}</span></button>`;
}

function renderFirmware() {
  const connected = Boolean(firmwareState.device);
  const noUsb = firmwareState.usbAttached === false;
  $("#tab-firmware").classList.toggle("disabled", noUsb && !connected);
  $("#hid-connect").disabled = noUsb;
  if (noUsb && !connected) {
    setStatus("hid", false, "USB 아님");
    $("#fw-hint").textContent = "패드가 USB 로 연결돼 있지 않다. Bluetooth 연결에서는 펌웨어 키맵을 읽고 쓸 수 없다. ② 앱별 매핑은 그대로 쓸 수 있다.";
  }
  $("#layer-buttons").innerHTML = Array.from({ length: firmwareState.layers }, (_, i) =>
    `<button class="chip ${i === firmwareState.layer ? "active" : ""}" data-layer="${i}">${i}</button>`).join("");
  renderPad($("#firmware-pad"), firmwareCellHtml);
  renderPicker();
  renderMatrix();
  const count = firmwareState.pending.size;
  $("#fw-dirty").textContent = count ? `쓰지 않은 변경 ${count}칸` : "";
  $("#fw-write").disabled = !count;
  $("#fw-revert").disabled = !count;
  $("#fw-backup").disabled = !connected;
  $("#fw-tester").disabled = !connected;
  showPressed(tester.pressed);
}

function renderPicker() {
  const picker = $("#firmware-picker");
  const pos = firmwareState.selectedPos;
  if (!pos) { picker.innerHTML = ""; return; }
  const code = currentCode(firmwareState.layer, pos[0], pos[1]);
  const original = firmwareState.keymap[firmwareState.layer][pos[0] * COLS + pos[1]];
  const codes = PICKER_GROUPS[firmwareState.pickerGroup];
  picker.innerHTML = `
    <h2>레이어 ${firmwareState.layer} · 칸 ${pos.join(",")} — ${escapeHtml(keycodeName(code))}</h2>
    <p class="note">패드에 지금 쓰여 있는 값: ${escapeHtml(keycodeName(original))} (0x${original.toString(16).toUpperCase().padStart(4, "0")}). ▽ 는 아래 레이어 값을 그대로 쓴다는 뜻이다. macOS 는 F20 까지만 받는다.</p>
    <div class="keycode-groups">${Object.keys(PICKER_GROUPS).map((group) =>
      `<button class="chip ${group === firmwareState.pickerGroup ? "active" : ""}" data-group="${group}">${group}</button>`).join("")}</div>
    <div class="keycode-grid">${codes.map((c) =>
      `<button class="${c === code ? "current" : ""}" data-code="${c}">${escapeHtml(keycodeName(c))}</button>`).join("")}</div>
    <div class="row">
      <span class="field-label">직접 입력</span><input type="text" id="raw-code" placeholder="0x0068">
      <button class="btn" id="raw-apply">지정</button>
    </div>`;
}

function renderMatrix() {
  if (!firmwareState.keymap.length) { $("#matrix-table").innerHTML = ""; return; }
  let html = "<table><tr><th></th>" + Array.from({ length: COLS }, (_, c) => `<th>${c}</th>`).join("") + "</tr>";
  for (let r = 0; r < ROWS; r++) {
    html += `<tr><th>${r}</th>`;
    for (let c = 0; c < COLS; c++) {
      const defined = DEFINED_CELLS.has(`${r},${c}`);
      html += `<td class="${defined ? "mapped" : "unknown"}" title="${defined ? "패드에 있는 칸" : "정의 파일에 없는 칸"}">${escapeHtml(keycodeName(currentCode(firmwareState.layer, r, c)))}</td>`;
    }
    html += "</tr>";
  }
  $("#matrix-table").innerHTML = html + "</table>";
}

function setPending(code) {
  const [row, col] = firmwareState.selectedPos;
  const key = `${firmwareState.layer},${row},${col}`;
  if (firmwareState.keymap[firmwareState.layer][row * COLS + col] === code) firmwareState.pending.delete(key);
  else firmwareState.pending.set(key, code);
  renderFirmware();
}

async function writeFirmware() {
  const changes = [...firmwareState.pending.entries()];
  const lines = changes.map(([key, code]) => {
    const [layer, row, col] = key.split(",").map(Number);
    return `레이어 ${layer} 칸 ${row},${col}: ${keycodeName(firmwareState.keymap[layer][row * COLS + col])} → ${keycodeName(code)}`;
  });
  if (!confirm(`패드 펌웨어에 ${changes.length}칸을 쓴다. 쓰면 바로 저장된다.\n되돌리려면 「백업에서 복원」을 쓴다.\n\n${lines.join("\n")}`)) return;
  for (const [key, code] of changes) {
    const [layer, row, col] = key.split(",").map(Number);
    await viaCommand(VIA.SET_KEYCODE, layer, row, col, code >> 8, code & 0xff);
  }
  // 쓴 값을 다시 읽어 맞는지 확인한다.
  firmwareState.keymap = await readKeymap();
  const mismatches = changes.filter(([key, code]) => {
    const [layer, row, col] = key.split(",").map(Number);
    return firmwareState.keymap[layer][row * COLS + col] !== code;
  });
  firmwareState.pending.clear();
  await syncFirmwareSnapshot();
  $("#fw-hint").textContent = mismatches.length
    ? `다시 읽었더니 ${mismatches.length}칸이 쓴 값과 다르다: ${mismatches.map(([key]) => key).join(" / ")}`
    : `${changes.length}칸을 쓰고 다시 읽어 확인했다.`;
  renderFirmware();
}

function downloadBackup() {
  const backup = {
    vendorId: "0xFEED", productId: "0x6060", viaProtocol: firmwareState.protocol, layers: firmwareState.layers,
    keysPerLayer: ROWS * COLS,
    keymap: firmwareState.keymap.map((cells) => cells.map((code) => `0x${code.toString(16).toUpperCase().padStart(4, "0")}`)),
  };
  const link = document.createElement("a");
  link.href = URL.createObjectURL(new Blob([JSON.stringify(backup, null, 1)], { type: "application/json" }));
  link.download = `doio-keymap-backup-${new Date().toISOString().slice(0, 10)}.json`;
  link.click();
}

// 백업 파일과 다른 칸만 쓰기 대기 목록에 올린다. 실제로 쓰는 것은 「펌웨어에 쓰기」다.
async function restoreFromFile(file) {
  const backup = JSON.parse(await file.text());
  if (backup.layers !== firmwareState.layers || backup.keysPerLayer !== ROWS * COLS) {
    $("#fw-hint").textContent = `백업의 레이어 ${backup.layers} × ${backup.keysPerLayer}칸이 패드(${firmwareState.layers} × ${ROWS * COLS})와 다르다.`;
    return;
  }
  firmwareState.pending.clear();
  backup.keymap.forEach((cells, layer) => cells.forEach((hex, i) => {
    const code = parseInt(hex, 16);
    if (firmwareState.keymap[layer][i] !== code) firmwareState.pending.set(`${layer},${Math.floor(i / COLS)},${i % COLS}`, code);
  }));
  $("#fw-hint").textContent = `백업과 다른 칸 ${firmwareState.pending.size}개를 쓰기 대기 목록에 올렸다. 「펌웨어에 쓰기」로 쓴다.`;
  renderFirmware();
}

// --- 키 눌림 보기: VIA 행렬 상태(0x02 0x03)를 주기적으로 읽는다. 행마다 1바이트, 비트 = 열 ---
const MATRIX_STATE = [0x02, 0x03];
const tester = { timer: null, pressed: new Set() };

function showPressed(pressed) {
  document.querySelectorAll(".key.pressed").forEach((key) => {
    if (!pressed.has(key.dataset.pos)) key.classList.remove("pressed");
  });
  pressed.forEach((pos) => document.querySelectorAll(`[data-pos="${pos}"]`).forEach((key) => key.classList.add("pressed")));
}

async function pollMatrix() {
  const response = await viaCommand(...MATRIX_STATE);
  const pressed = new Set();
  for (let row = 0; row < ROWS; row++) {
    for (let col = 0; col < COLS; col++) {
      // 정의 파일에 없는 칸(0열 등)은 회로상 늘 눌림으로 읽혀 뺀다.
      if (response[2 + row] & (1 << col) && DEFINED_CELLS.has(`${row},${col}`)) pressed.add(`${row},${col}`);
    }
  }
  tester.pressed = pressed;
  showPressed(pressed);
}

function setTester(on) {
  clearInterval(tester.timer);
  tester.timer = null;
  if (on && firmwareState.device) {
    tester.timer = setInterval(() => pollMatrix().catch(() => setTester(false)), 60);
  } else {
    showPressed(new Set());
  }
  $("#fw-tester").classList.toggle("on", Boolean(tester.timer));
  $("#fw-tester").textContent = tester.timer ? "키 눌림 보는 중" : "키 눌림 보기";
}

function setupFirmwareEvents() {
  $("#fw-tester").addEventListener("click", () => setTester(!tester.timer));
  $("#hid-connect").addEventListener("click", () => connectPad().catch(showConnectError));
  navigator.hid?.addEventListener("connect", (event) => {
    if (isPadInterface(event.device)) openPad(event.device).catch(showConnectError);
  });
  $("#layer-buttons").addEventListener("click", (event) => {
    const button = event.target.closest("[data-layer]");
    if (!button) return;
    firmwareState.layer = Number(button.dataset.layer);
    renderFirmware();
  });
  $("#firmware-pad").addEventListener("click", (event) => {
    const cell = event.target.closest("[data-pos]");
    if (!cell || !firmwareState.keymap.length) return;
    firmwareState.selectedPos = cell.dataset.pos.split(",").map(Number);
    renderFirmware();
  });
  $("#firmware-picker").addEventListener("click", (event) => {
    const group = event.target.closest("[data-group]");
    if (group) { firmwareState.pickerGroup = group.dataset.group; renderPicker(); return; }
    const code = event.target.closest("[data-code]");
    if (code) { setPending(Number(code.dataset.code)); return; }
    if (event.target.id === "raw-apply") {
      const value = parseInt($("#raw-code").value, 16);
      if (Number.isInteger(value) && value >= 0 && value <= 0xffff) setPending(value);
    }
  });
  $("#fw-write").addEventListener("click", () => writeFirmware().catch((error) => { $("#fw-hint").textContent = `쓰기 실패: ${error.message}`; }));
  $("#fw-revert").addEventListener("click", () => { firmwareState.pending.clear(); renderFirmware(); });
  $("#fw-backup").addEventListener("click", downloadBackup);
  $("#fw-restore").addEventListener("change", (event) => {
    if (!firmwareState.device) { $("#fw-hint").textContent = "먼저 패드를 연결한다."; return; }
    if (event.target.files[0]) restoreFromFile(event.target.files[0]);
    event.target.value = "";
  });
  navigator.hid?.addEventListener("disconnect", (event) => {
    if (event.device === firmwareState.device) {
      firmwareState.device = null;
      setTester(false);
      macroState.count = 0;
      renderMacros();
      setStatus("hid", false, "연결 끊김");
      $("#hid-connect").textContent = "패드 연결";
      renderFirmware();
    }
  });
}


// ===========================================================================
// 매크로 탭 (VIA 매크로 버퍼: 0x0C 개수, 0x0D 크기, 0x0E 읽기, 0x0F 쓰기)
// 버퍼 = 매크로마다 바이트열 + 0x00. 글자는 ASCII 그대로, 특수 동작은 0x01 뒤에 종류 바이트가 온다.
// 0x01 0x01 kc = 누르고 떼기, 0x01 0x02 kc = 누른 채로, 0x01 0x03 kc = 떼기, 0x01 0x04 숫자들 '|' = 쉬기(ms)
// ===========================================================================
const MACRO = { COUNT: 0x0c, SIZE: 0x0d, GET: 0x0e, SET: 0x0f };
const MACRO_ACTIONS = { 1: "tap", 2: "down", 3: "up" };
const MACRO_ACTION_CODES = { tap: 1, down: 2, up: 3 };

const macroState = { count: 0, size: 0, macros: [], saved: [], selected: 0 };

// 매크로마다 고정 색. 목록·버퍼 막대·범례에 같은 색을 쓴다.
const MACRO_COLORS = ["#5e6ad2", "#4ea7fc", "#4cb782", "#f2c94c", "#f2994a", "#eb5757", "#bb87fc", "#26b5ce",
  "#95a2b3", "#e57ead", "#8bd17c", "#f7c873", "#6dd3c4", "#a78bfa", "#fb923c", "#94a3b8"];

// 매크로별 바이트 수. 해석할 수 없는 매크로는 null.
function macroSizes() {
  return macroState.macros.map((text) => { try { return encodeMacro(text).length; } catch (error) { return null; } });
}

function renderBuffer() {
  const sizes = macroSizes();
  const total = macroState.size || 1;
  // 버퍼 = 매크로 바이트 + 끝 표시(0x00) 1바이트씩
  const used = sizes.reduce((sum, n) => sum + (n ?? 0) + 1, 0);
  const over = used > macroState.size;
  let bar = "";
  sizes.forEach((n, i) => {
    if (n) bar += `<span title="M${i}: ${n} 바이트" style="width:${(n / total) * 100}%;background:${MACRO_COLORS[i]}"></span>`;
    bar += `<span class="terminator" title="M${i} 끝 표시 1바이트" style="width:${(1 / total) * 100}%"></span>`;
  });
  $("#buffer-bar").innerHTML = bar;
  $("#buffer-total").innerHTML = `<b style="color:${over ? "var(--danger)" : ""}">${used}</b> / ${macroState.size} 바이트 · 남은 공간 ${Math.max(0, macroState.size - used)}`;
  $("#buffer-legend").innerHTML = sizes.map((n, i) => n ? `<span><i style="background:${MACRO_COLORS[i]}"></i>M${i} ${n}B</span>` : "").join("") +
    `<span><i style="background:var(--line-strong)"></i>끝 표시 ${sizes.length}B</span>`;
}

const codeByName = () => Object.fromEntries(Object.entries(BASIC_NAMES).map(([code, name]) => [name, Number(code)]));

function macroKeyName(code) {
  return BASIC_NAMES[code] && !/[{}:]/.test(BASIC_NAMES[code]) ? BASIC_NAMES[code] : `0x${code.toString(16).padStart(2, "0")}`;
}

function decodeMacro(bytes) {
  let text = "";
  for (let i = 0; i < bytes.length; i++) {
    const b = bytes[i];
    if (b === 0x01) {
      const kind = bytes[i + 1];
      if (MACRO_ACTIONS[kind]) {
        text += `{${MACRO_ACTIONS[kind]}:${macroKeyName(bytes[i + 2])}}`;
        i += 2;
      } else if (kind === 0x04) {
        let digits = "";
        i += 2;
        while (i < bytes.length && bytes[i] !== 0x7c) digits += String.fromCharCode(bytes[i++]);
        text += `{delay:${digits}}`;
      } else {
        text += `{raw:0x${b.toString(16)}}`;
      }
    } else if (b === 0x7b) {
      text += "{{";
    } else {
      text += String.fromCharCode(b);
    }
  }
  return text;
}

// 편집기 글을 바이트열로 바꾼다. 해석할 수 없는 부분이 있으면 오류를 던진다.
function encodeMacro(text) {
  const names = codeByName();
  const bytes = [];
  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (ch === "{" && text[i + 1] === "{") { bytes.push(0x7b); i++; continue; }
    if (ch === "{") {
      const end = text.indexOf("}", i);
      if (end < 0) throw new Error(`닫는 중괄호가 없다: ${text.slice(i, i + 12)}`);
      const [kind, value = ""] = text.slice(i + 1, end).split(":");
      if (kind === "delay") {
        if (!/^\d+$/.test(value)) throw new Error(`쉬는 시간은 숫자(ms)다: {${kind}:${value}}`);
        bytes.push(0x01, 0x04, ...[...value].map((d) => d.charCodeAt(0)), 0x7c);
      } else if (MACRO_ACTION_CODES[kind]) {
        const code = /^0x[0-9a-f]+$/i.test(value) ? parseInt(value, 16) : names[value];
        if (code === undefined || code > 0xff) throw new Error(`모르는 키: {${kind}:${value}}`);
        bytes.push(0x01, MACRO_ACTION_CODES[kind], code);
      } else {
        throw new Error(`모르는 동작: {${kind}}`);
      }
      i = end;
      continue;
    }
    const code = ch.charCodeAt(0);
    if (ch === "\n") { bytes.push(0x0a); continue; }
    if (code < 0x20 || code > 0x7e) throw new Error(`영문 자판 글자만 넣을 수 있다: "${ch}"`);
    bytes.push(code);
  }
  return bytes;
}

async function readMacros() {
  macroState.count = (await viaCommand(MACRO.COUNT))[1];
  const size = await viaCommand(MACRO.SIZE);
  macroState.size = (size[1] << 8) | size[2];
  const bytes = [];
  for (let offset = 0; offset < macroState.size; offset += 28) {
    const n = Math.min(28, macroState.size - offset);
    const response = await viaCommand(MACRO.GET, offset >> 8, offset & 0xff, n);
    bytes.push(...response.slice(4, 4 + n));
  }
  const macros = [];
  let start = 0;
  for (let index = 0; index < macroState.count; index++) {
    let end = bytes.indexOf(0, start);
    if (end < 0) end = bytes.length;
    macros.push(decodeMacro(bytes.slice(start, end)));
    start = end + 1;
  }
  macroState.macros = macros;
  macroState.saved = [...macros];
  renderMacros();
}

function macroBytes() {
  const bytes = [];
  macroState.macros.forEach((text) => bytes.push(...encodeMacro(text), 0));
  return bytes;
}

async function saveMacros() {
  let bytes;
  try { bytes = macroBytes(); } catch (error) { $("#macro-hint").textContent = `저장하지 않았다: ${error.message}`; return; }
  if (bytes.length > macroState.size) { $("#macro-hint").textContent = `버퍼가 넘친다: ${bytes.length} / ${macroState.size} 바이트`; return; }
  const changed = macroState.macros.map((text, i) => text !== macroState.saved[i] ? `M${i}` : null).filter(Boolean);
  if (!confirm(`패드에 매크로를 저장한다 (바뀐 것: ${changed.join(", ")}). 쓰면 바로 저장된다.`)) return;
  const padded = [...bytes, ...new Array(macroState.size - bytes.length).fill(0)];
  for (let offset = 0; offset < padded.length; offset += 28) {
    const chunk = padded.slice(offset, offset + 28);
    await viaCommand(MACRO.SET, offset >> 8, offset & 0xff, chunk.length, ...chunk);
  }
  const written = [...macroState.macros];
  await readMacros();
  const mismatch = written.map((text, i) => text !== macroState.macros[i] ? `M${i}` : null).filter(Boolean);
  $("#macro-hint").textContent = mismatch.length
    ? `다시 읽었더니 다르다: ${mismatch.join(", ")}`
    : `저장하고 다시 읽어 확인했다 (${changed.join(", ")}).`;
}

function renderMacros() {
  const connected = Boolean(firmwareState.device) && macroState.count > 0;
  $("#tab-macro").classList.toggle("disabled", !connected);
  $("#macro-reload").disabled = !firmwareState.device;
  if (!connected) { $("#macro-list").innerHTML = ""; return; }
  const sizes = macroSizes();
  $("#macro-list").innerHTML = macroState.macros.map((text, i) =>
    `<button class="${i === macroState.selected ? "active" : ""} ${text ? "" : "empty"}" data-macro="${i}">
      <i class="swatch" style="background:${text ? MACRO_COLORS[i] : "var(--line-strong)"}"></i><b>M${i}</b>
      <span class="text">${escapeHtml(text || "(비어 있음)")}</span><span class="size">${sizes[i] === null ? "오류" : sizes[i] ? `${sizes[i]}B` : ""}</span></button>`).join("");
  renderBuffer();
  $("#macro-title").textContent = `M${macroState.selected}`;
  const textarea = $("#macro-text");
  if (document.activeElement !== textarea) textarea.value = macroState.macros[macroState.selected];
  let usage;
  try { usage = `${macroBytes().length} / ${macroState.size} 바이트`; $("#macro-bytes").textContent = ""; }
  catch (error) { usage = "해석 오류"; $("#macro-bytes").textContent = error.message; }
  const dirty = macroState.macros.some((text, i) => text !== macroState.saved[i]);
  $("#macro-save").disabled = !dirty;
  $("#macro-dirty").textContent = dirty ? "저장하지 않은 변경이 있다" : "";
}

const MACRO_INSERTS = [["Enter", "{tap:Enter}"], ["Tab", "{tap:Tab}"], ["Esc", "{tap:Esc}"], ["⌘ 누른 채", "{down:LCmd}"], ["⌘ 떼기", "{up:LCmd}"], ["⇧ 누른 채", "{down:LSft}"], ["⇧ 떼기", "{up:LSft}"], ["100ms 쉬기", "{delay:100}"]];

function setupMacroEvents() {
  $("#macro-inserts").innerHTML = MACRO_INSERTS.map(([label, token]) => `<button class="chip" data-token="${escapeHtml(token)}">${escapeHtml(label)}</button>`).join("");
  $("#macro-inserts").addEventListener("click", (event) => {
    const token = event.target.closest("[data-token]")?.dataset.token;
    if (!token) return;
    const textarea = $("#macro-text");
    const at = textarea.selectionStart ?? textarea.value.length;
    textarea.value = textarea.value.slice(0, at) + token + textarea.value.slice(textarea.selectionEnd ?? at);
    textarea.focus();
    textarea.selectionStart = textarea.selectionEnd = at + token.length;
    macroState.macros[macroState.selected] = textarea.value;
    renderMacros();
  });
  $("#macro-list").addEventListener("click", (event) => {
    const button = event.target.closest("[data-macro]");
    if (!button) return;
    macroState.selected = Number(button.dataset.macro);
    $("#macro-text").blur();
    renderMacros();
  });
  $("#macro-text").addEventListener("input", (event) => {
    macroState.macros[macroState.selected] = event.target.value;
    renderMacros();
  });
  $("#macro-reload").addEventListener("click", () => readMacros().catch((error) => { $("#macro-hint").textContent = `읽기 실패: ${error.message}`; }));
  $("#macro-save").addEventListener("click", () => saveMacros().catch((error) => { $("#macro-hint").textContent = `저장 실패: ${error.message}`; }));
}

// ===========================================================================
// 키보드 번호 (macOS keyboard type)
// ===========================================================================
let keyboardTypeCommand = "";

async function loadKeyboardTypes() {
  try {
    const result = await (await fetch("/api/keyboard-type", { cache: "no-store" })).json();
    const show = (which, value) => {
      $(`#kt-${which}`).textContent = value === null ? "등록 안 됨" : String(value);
      $(`#kt-${which}-dot`).className = `dot ${value === result.expected ? "ok" : "bad"}`;
    };
    show("usb", result.usb);
    show("bt", result.bluetooth);
    keyboardTypeCommand = result.fixCommand || "";
    $("#kt-copy").hidden = !keyboardTypeCommand;
  } catch (error) { /* Hammerspoon 리로드 중 */ }
}

// ===========================================================================
// 공통
// ===========================================================================
function setStatus(which, ok, text) {
  $(`#${which}-dot`).className = `dot ${ok ? "ok" : "bad"}`;
  $(`#${which}-status`).textContent = text;
}

document.querySelectorAll(".tab").forEach((tab) => tab.addEventListener("click", () => {
  document.querySelectorAll(".tab").forEach((t) => t.classList.toggle("active", t === tab));
  document.querySelectorAll(".panel").forEach((panel) => panel.classList.toggle("hidden", panel.id !== `tab-${tab.dataset.tab}`));
}));

// 테마 전환. 버튼에는 누르면 바뀔 모양을 쓴다. 고른 값은 이 브라우저에 기억한다.
function renderThemeToggle() {
  const dark = document.documentElement.dataset.theme !== "light";
  $("#theme-toggle").textContent = dark ? "☀ 밝게" : "☾ 어둡게";
}
$("#theme-toggle").addEventListener("click", () => {
  const next = document.documentElement.dataset.theme === "light" ? "dark" : "light";
  document.documentElement.dataset.theme = next;
  localStorage.setItem("doio-theme", next);
  renderThemeToggle();
});
renderThemeToggle();

setupMappingEvents();
setupFirmwareEvents();
setupMacroEvents();
renderMacros();
loadKeyboardTypes();
setInterval(loadKeyboardTypes, 5000);
$("#kt-copy").addEventListener("click", async () => {
  await navigator.clipboard.writeText(keyboardTypeCommand);
  $("#kt-copy").textContent = "복사했다. 터미널에 붙여 넣고 패드를 다시 연결한다";
});
renderFirmware();
pollUsb().then(() => autoConnectPad()).catch(showConnectError);
setInterval(pollUsb, 2000);
loadMapping();
loadRunningApps();
