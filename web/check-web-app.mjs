import fs from "node:fs";
import vm from "node:vm";

const source = fs.readFileSync(new URL("./app.js", import.meta.url), "utf8");

const sandbox = {
  console,
  localStorage: {
    getItem() { return null; },
    setItem() {}
  },
  crypto: {
    randomUUID() { return "test-id"; }
  },
  Intl,
  Date,
  Blob: class {},
  URL,
  confirm() { return true; },
  alert() {},
  navigator: {
    clipboard: {
      async writeText() {}
    }
  },
  document: {
    querySelector() {
      return { innerHTML: "", addEventListener() {} };
    },
    querySelectorAll() {
      return [];
    },
    createElement() {
      return { click() {}, addEventListener() {} };
    }
  }
};

vm.createContext(sandbox);
vm.runInContext(source, sandbox, { filename: "app.js" });

const sampleNote = {
  id: "sample",
  title: "お金と職場復帰が心配",
  body: "治療費、収入、休職や職場復帰のことが心配です。",
  personContext: "仕事を続けたいです。",
  category: "cost",
  role: "patient",
  recipient: "consultationCenter",
  diagnosis: "",
  nextDate: "",
  createdAt: new Date("2026-07-01T00:00:00+09:00").toISOString()
};

const result = vm.runInContext(`
  state.notes = [${JSON.stringify(sampleNote)}];
  ({
    reply: supportReply(state.notes[0]),
    summary: summarizeMoyamoya(state.notes[0]),
    doctorQuestions: doctorQuestions(state.notes[0]),
    centerQuestions: supportCenterQuestions(state.notes[0]),
    shortBrief: briefMessageShort(state.notes[0]),
    detailedBrief: briefMessage(state.notes[0]),
    exported: textExport(),
    trustedResourceCount: trustedResources.length,
    templateCount: templates.length
  })
`, sandbox);

const checks = [
  ["医療費・制度 domain", result.reply.domains.includes("医療費・制度")],
  ["仕事・学校 domain", result.reply.domains.includes("仕事・学校")],
  ["職場復帰 prompt", result.reply.next.includes("職場復帰")],
  ["moyamoya summary", result.summary.length === 4 && result.summary.join("").includes("モヤモヤ")],
  ["export has moyamoya summary", result.exported.includes("モヤモヤの要約")],
  ["doctor questions", result.doctorQuestions.length >= 2],
  ["support center questions", result.centerQuestions.some((item) => item.includes("職場復帰"))],
  ["short brief exists", result.shortBrief.length > 20 && result.shortBrief.length < result.detailedBrief.length],
  ["short and detailed brief UI", source.includes("診察で読む一文") && source.includes("詳しく見る") && source.includes("短い版") && source.includes("詳しい版")],
  ["trusted resources", result.trustedResourceCount >= 9],
  ["templates", result.templateCount >= 7],
  ["feedback UI", source.includes("data-open-feedback") && source.includes("feedbackDialog")],
  ["draft autosave", source.includes("DRAFT_KEY") && source.includes("saveDraft")],
  ["life design prompts", source.includes("治療と暮らしをデザインする") && source.includes("保ちたい暮らし") && source.includes("こうはなりたくない")],
  ["usage timing guide", source.includes("どんな時に使う？") && source.includes("診察や相談の前") && source.includes("人に話す前")],
  ["writing guide", source.includes("迷った時の目安") && source.includes("診察や相談で聞くことを見る")],
  ["selectable writing prompts", source.includes("選んで書けるきっかけ") && source.includes("順番は気にせず")],
  ["soft consultation wording", source.includes("相談員・相談窓口")],
  ["test privacy warning", source.includes("個人名、病院名、主治医名") && source.includes("相談メモ本文は書かないでください")],
  ["delete all local data", source.includes("deleteAllLocalData") && source.includes("下書き、同意状態")],
  ["safety boundary phrase", source.includes("診断、治療方針、薬剤、緊急性の判断は行いません")],
  ["no old abbreviation wording", !source.includes(["M", "V", "P"].join(""))],
  ["no specialist fertility wording", !source.includes("妊" + "孕") && !source.includes("妊" + "よう")],
  ["export has app title", result.exported.includes("がん相談サポート Web")]
];

const failed = checks.filter(([, ok]) => !ok);
if (failed.length) {
  for (const [name] of failed) {
    console.error(`failed: ${name}`);
  }
  process.exit(1);
}

console.log(`${checks.length} web app checks passed`);
