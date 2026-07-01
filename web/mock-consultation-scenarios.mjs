import fs from "node:fs";
import vm from "node:vm";

const source = fs.readFileSync(new URL("./app.js", import.meta.url), "utf8");

const sandbox = {
  console,
  localStorage: {
    getItem() { return null; },
    setItem() {},
    removeItem() {}
  },
  crypto: {
    randomUUID() { return "test-id"; }
  },
  Intl,
  Date,
  Blob: class {},
  URL,
  location: { protocol: "file:" },
  window: { addEventListener() {} },
  confirm() { return true; },
  alert() {},
  navigator: {
    clipboard: {
      async writeText() {}
    }
  },
  document: {
    onkeydown: null,
    querySelector() {
      return { innerHTML: "", addEventListener() {}, focus() {}, reset() {} };
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

const scenarios = [
  {
    name: "副作用と生活負担",
    category: "sideEffect",
    body: "抗がん剤のあと、だるさとしびれが強くて家事ができません。病院に言っていいのか迷います。",
    domains: ["症状・副作用"],
    words: ["病院", "連絡"]
  },
  {
    name: "治療選択の迷い",
    category: "treatment",
    body: "手術と薬の治療、どちらがいいのか説明を聞いても決められません。",
    domains: ["治療選択"],
    words: ["確認", "選択肢"]
  },
  {
    name: "お金と職場復帰",
    category: "cost",
    body: "治療費、収入、休職や職場復帰のことが心配です。職場に何を伝えればいいかわかりません。",
    domains: ["医療費・制度", "仕事・学校"],
    words: ["職場復帰", "制度"]
  },
  {
    name: "家族への伝え方",
    category: "family",
    body: "子どもにがんのことをどう話せばいいか迷っています。心配をかけたくありません。",
    domains: ["家族・人間関係"],
    words: ["伝え"]
  },
  {
    name: "気持ちのつらさ",
    category: "emotionalPain",
    body: "夜になると不安で眠れません。弱いだけなのかと思ってしまいます。",
    domains: ["気持ちのつらさ"],
    words: ["不安", "相談"]
  },
  {
    name: "セカンドオピニオン",
    category: "secondOpinion",
    body: "セカンドオピニオンを考えていますが、主治医に悪い気がして言い出せません。",
    domains: ["セカンドオピニオン"],
    words: ["確認", "資料"]
  },
  {
    name: "緩和ケアの誤解",
    category: "palliativeCare",
    body: "緩和ケアを勧められて怖いです。もう治療をあきらめる話なのかと思いました。",
    domains: ["緩和ケア"],
    words: ["緩和ケア", "説明"]
  },
  {
    name: "説明が分からない",
    category: "treatment",
    body: "病院では分かったつもりでしたが、家に帰ると説明がよく分からなくなりました。",
    domains: ["治療選択", "伝え方・聞き方"],
    words: ["聞き直", "説明"]
  },
  {
    name: "相談先が分からない",
    category: "other",
    body: "がん相談支援センターを聞いたことはありますが、何を相談していい場所なのかわかりません。",
    domains: ["情報の整理"],
    words: ["相談", "整理"]
  },
  {
    name: "若い世代の将来",
    category: "workSchool",
    body: "まだ若いので、学校や仕事、将来子どもが欲しいと思っていることがどうなるのか不安です。",
    domains: ["仕事・学校"],
    words: ["将来", "学校"]
  },
  {
    name: "家族自身の不安",
    category: "family",
    role: "family",
    body: "本人には言えませんが、家族の私も不安で相談したいです。",
    domains: ["家族・人間関係"],
    words: ["家族", "相談"]
  },
  {
    name: "連絡先の確認",
    category: "sideEffect",
    body: "体調が悪い時に病院へ連絡していいのか、どこへ電話すればいいのかわかりません。",
    domains: ["症状・副作用"],
    words: ["連絡", "病院"]
  },
  {
    name: "見た目の変化",
    category: "appearanceChange",
    body: "髪や眉が抜けるかもしれないことが不安です。ウィッグや帽子をいつ準備すればいいか知りたいです。",
    domains: ["見た目の変化"],
    words: ["見た目", "ウィッグ"]
  },
  {
    name: "急な強い症状",
    category: "sideEffect",
    body: "急に息苦しくて胸痛があります。救急に行くべきか迷っています。",
    domains: ["症状・副作用", "緊急・安全"],
    words: ["救急", "連絡"],
    critical: true
  },
  {
    name: "自傷表現",
    category: "emotionalPain",
    body: "夜になると消えたい、もう生きたくないと思ってしまいます。",
    domains: ["気持ちのつらさ", "緊急・安全"],
    words: ["一人", "連絡"],
    critical: true
  }
];

const forbiddenGeneratedPhrases = [
  ["あなたに", "最適"].join(""),
  ["再発", "です"].join(""),
  ["薬を", "減ら"].join(""),
  ["治療は", "不要"].join(""),
  ["救急", "不要"].join(""),
  ["必ず", "治"].join(""),
  ["退職", "すべき"].join(""),
  ["治療", "終了"].join(""),
  ["末期", "です"].join("")
];

function noteFor(scenario) {
  return {
    id: scenario.name,
    title: scenario.name,
    body: scenario.body,
    personContext: "自分らしい生活を大切にしたいです。",
    category: scenario.category,
    role: scenario.role || "patient",
    recipient: scenario.recipient || "consultationCenter",
    diagnosis: "",
    nextDate: "",
    createdAt: new Date("2026-07-01T00:00:00+09:00").toISOString()
  };
}

const failures = [];
const summaries = [];

for (const scenario of scenarios) {
  const note = noteFor(scenario);
  const result = vm.runInContext(`
    (() => {
      const note = ${JSON.stringify(note)};
      const reply = supportReply(note);
      const doctor = doctorQuestions(note);
      const center = supportCenterQuestions(note);
      const checklist = preVisitChecklist(note);
      const brief = briefMessage(note);
      const summary = summarizeMoyamoya(note);
      return { reply, doctor, center, checklist, brief, summary };
    })()
  `, sandbox);

  const allText = [
    result.reply.heard,
    result.reply.feeling,
    result.reply.rephrase,
    result.reply.next,
    result.reply.reason,
    result.reply.safety,
    result.summary.join("\n"),
    result.doctor.join("\n"),
    result.center.join("\n"),
    result.checklist.join("\n"),
    result.brief
  ].join("\n");

  const generatedOnly = [
    result.reply.heard,
    result.reply.feeling,
    result.reply.rephrase,
    result.reply.next,
    result.reply.reason,
    result.reply.safety,
    result.summary.join("\n"),
    result.doctor.join("\n"),
    result.center.join("\n"),
    result.checklist.join("\n")
  ].join("\n");

  for (const domain of scenario.domains) {
    if (!result.reply.domains.includes(domain)) {
      failures.push(`${scenario.name}: missing domain ${domain}. got ${result.reply.domains.join(", ")}`);
    }
  }

  for (const word of scenario.words) {
    if (!allText.includes(word)) failures.push(`${scenario.name}: missing word ${word}`);
  }

  for (const phrase of forbiddenGeneratedPhrases) {
    if (generatedOnly.includes(phrase)) failures.push(`${scenario.name}: unsafe generated phrase ${phrase}`);
  }

  if (scenario.critical && !result.reply.critical) failures.push(`${scenario.name}: expected critical safety flag`);
  if (result.summary.length !== 4) failures.push(`${scenario.name}: expected 4 summary lines`);
  if (!result.reply.next || result.reply.next.length < 18) failures.push(`${scenario.name}: next question is too short`);
  if (result.doctor.length < 2 || result.center.length < 2) failures.push(`${scenario.name}: too few generated questions`);

  summaries.push(`${scenario.name}: ${result.reply.domains.join(" / ")}`);
}

if (failures.length) {
  console.error(failures.join("\n"));
  process.exit(1);
}

console.log(`${scenarios.length} mock consultation scenarios passed`);
for (const summary of summaries) console.log(`- ${summary}`);
