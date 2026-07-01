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

const personas = [
  { age: "10代", gender: "女性", role: "patient", context: "学校生活と友人関係を大切にしたいです。" },
  { age: "20代", gender: "男性", role: "patient", context: "仕事を始めたばかりで、将来の生活設計も大切にしたいです。" },
  { age: "30代", gender: "女性", role: "patient", context: "子育てと仕事を続けながら治療と向き合いたいです。" },
  { age: "40代", gender: "男性", role: "patient", context: "家計を支える立場で、職場復帰の見通しを大切にしたいです。" },
  { age: "50代", gender: "女性", role: "family", context: "本人の意思を尊重しながら、家族として支えたいです。" },
  { age: "60代", gender: "男性", role: "companion", context: "診察に付き添い、本人が聞きたいことを支えたいです。" },
  { age: "70代", gender: "女性", role: "patient", context: "家で穏やかに過ごす時間を大切にしたいです。" },
  { age: "80代", gender: "回答しない", role: "supporter", context: "本人の生活のペースと尊厳を守りたいです。" }
];

const topics = [
  {
    name: "副作用と生活負担",
    category: "sideEffect",
    recipient: "physician",
    body: "治療後のだるさとしびれが続き、家事や通学、仕事に影響しています。病院へ連絡してよいのか迷っています。",
    domains: ["症状・副作用"],
    words: ["連絡", "病院"]
  },
  {
    name: "治療選択の迷い",
    category: "treatment",
    recipient: "physician",
    body: "手術、薬、放射線の説明を聞きましたが、どの選択肢をどう考えればよいか整理できません。",
    domains: ["治療選択"],
    words: ["選択肢", "確認"]
  },
  {
    name: "検査説明が分からない",
    category: "test",
    recipient: "physician",
    body: "検査結果の説明を聞いた時は分かったつもりでしたが、家に帰ると何を意味するのか分からなくなりました。",
    domains: ["治療選択", "伝え方・聞き方"],
    words: ["説明", "聞き直"]
  },
  {
    name: "お金と制度",
    category: "cost",
    recipient: "consultationCenter",
    body: "治療費、収入、制度の手続きが心配です。誰に何を相談すればよいか分かりません。",
    domains: ["医療費・制度"],
    words: ["制度", "相談"]
  },
  {
    name: "仕事と職場復帰",
    category: "workSchool",
    recipient: "consultationCenter",
    body: "休職中ですが、職場復帰の時期や働き方、職場へ伝える内容が不安です。",
    domains: ["仕事・学校"],
    words: ["職場", "職場復帰"]
  },
  {
    name: "学校と友人",
    category: "workSchool",
    recipient: "consultationCenter",
    body: "学校へいつ戻れるか、友人にどこまで話すか、授業や行事をどうするか迷っています。",
    domains: ["仕事・学校"],
    words: ["学校", "伝える"]
  },
  {
    name: "家族への伝え方",
    category: "family",
    recipient: "family",
    body: "家族や子どもに病気のことをどう話せばよいか分からず、心配をかけたくありません。",
    domains: ["家族・人間関係"],
    words: ["家族", "伝え"]
  },
  {
    name: "家族自身の不安",
    category: "family",
    recipient: "consultationCenter",
    body: "本人の前では明るくしていますが、家族の私も不安で、誰かに相談したいです。",
    domains: ["家族・人間関係"],
    words: ["家族", "相談"]
  },
  {
    name: "セカンドオピニオン",
    category: "secondOpinion",
    recipient: "consultationCenter",
    body: "セカンドオピニオンを考えていますが、主治医に悪い気がして資料をお願いしにくいです。",
    domains: ["セカンドオピニオン"],
    words: ["資料", "伝え方"]
  },
  {
    name: "緩和ケアへの不安",
    category: "palliativeCare",
    recipient: "consultationCenter",
    body: "緩和ケアを勧められて怖くなりました。治療とどう関係するのか説明してほしいです。",
    domains: ["緩和ケア"],
    words: ["緩和ケア", "説明"]
  },
  {
    name: "気持ちのつらさ",
    category: "emotionalPain",
    recipient: "consultationCenter",
    body: "夜になると不安が強くなり、眠れません。弱いだけなのかと思ってしまいます。",
    domains: ["気持ちのつらさ"],
    words: ["不安", "相談"]
  },
  {
    name: "見た目の変化",
    category: "appearanceChange",
    recipient: "consultationCenter",
    body: "髪、眉、肌、爪など見た目の変化が不安です。帽子やウィッグをいつ準備すればよいか知りたいです。",
    domains: ["見た目の変化"],
    words: ["見た目", "ウィッグ"]
  },
  {
    name: "将来子どもが欲しい気持ち",
    category: "workSchool",
    recipient: "consultationCenter",
    body: "治療が、将来子どもが欲しいと思っていることや結婚、仕事にどう影響するのか不安です。",
    domains: ["仕事・学校"],
    words: ["将来", "子ども"]
  },
  {
    name: "急な強い症状",
    category: "sideEffect",
    recipient: "physician",
    body: "急に息苦しくなり、胸痛があります。救急に連絡するべきか迷っています。",
    domains: ["症状・副作用", "緊急・安全"],
    words: ["救急", "連絡"],
    critical: true
  },
  {
    name: "自傷につながる表現",
    category: "emotionalPain",
    recipient: "consultationCenter",
    body: "夜になると消えたい、もう生きていたくないと思ってしまいます。",
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
  ["家族が", "決め"].join(""),
  ["学校を", "やめ"].join(""),
  ["仕事を", "やめ"].join(""),
  ["治療", "終了"].join(""),
  ["末期", "です"].join("")
];

const failures = [];
const stats = new Map();

for (let i = 0; i < 120; i += 1) {
  const persona = personas[i % personas.length];
  const topic = topics[i % topics.length];
  const cycle = Math.floor(i / topics.length) + 1;
  const note = {
    id: `pdca-${i + 1}`,
    title: `${persona.age}${persona.gender} ${topic.name}`,
    body: `${persona.age} ${persona.gender} ${topic.body}`,
    personContext: persona.context,
    category: topic.category,
    role: persona.role,
    recipient: topic.recipient,
    diagnosis: "",
    nextDate: "",
    createdAt: new Date("2026-07-01T00:00:00+09:00").toISOString()
  };

  const result = vm.runInContext(`
    (() => {
      const note = ${JSON.stringify(note)};
      const reply = supportReply(note);
      return {
        reply,
        summary: summarizeMoyamoya(note),
        brief: briefMessage(note),
        doctor: doctorQuestions(note),
        center: supportCenterQuestions(note),
        checklist: preVisitChecklist(note)
      };
    })()
  `, sandbox);

  for (const domain of result.reply.domains) {
    stats.set(domain, (stats.get(domain) || 0) + 1);
  }

  const allText = [
    result.reply.heard,
    result.reply.feeling,
    result.reply.rephrase,
    result.reply.next,
    result.reply.reason,
    result.reply.safety,
    result.summary.join("\n"),
    result.brief,
    result.doctor.join("\n"),
    result.center.join("\n"),
    result.checklist.join("\n")
  ].join("\n");

  const generatedOnly = [
    result.reply.heard,
    result.reply.feeling,
    result.reply.rephrase,
    result.reply.next,
    result.reply.reason,
    result.reply.safety,
    result.summary.slice(1).join("\n"),
    result.doctor.join("\n"),
    result.center.join("\n"),
    result.checklist.join("\n")
  ].join("\n");

  for (const domain of topic.domains) {
    if (!result.reply.domains.includes(domain)) {
      failures.push(`${i + 1} ${topic.name}: missing domain ${domain}. got ${result.reply.domains.join(", ")}`);
    }
  }
  for (const word of topic.words) {
    if (!allText.includes(word)) failures.push(`${i + 1} ${topic.name}: missing word ${word}`);
  }
  for (const phrase of forbiddenGeneratedPhrases) {
    if (generatedOnly.includes(phrase)) failures.push(`${i + 1} ${topic.name}: unsafe generated phrase ${phrase}`);
  }
  if (topic.critical && !result.reply.critical) failures.push(`${i + 1} ${topic.name}: expected critical flag`);
  if (!topic.critical && result.reply.critical) failures.push(`${i + 1} ${topic.name}: unexpected critical flag`);
  if (result.summary.length !== 4) failures.push(`${i + 1} ${topic.name}: summary count should be 4`);
  if (!result.summary.join("").includes("治療と暮らしのデザイン")) failures.push(`${i + 1} ${topic.name}: summary does not include treatment-life design context`);
  if (result.doctor.length < 2 || result.center.length < 2) failures.push(`${i + 1} ${topic.name}: not enough questions`);
  if (!result.brief || result.brief.length < 30) failures.push(`${i + 1} ${topic.name}: brief message too short`);

  if ((i + 1) % 15 === 0) {
    console.log(`PDCA cycle ${cycle}: ${i + 1} simulations checked`);
  }
}

if (failures.length) {
  console.error(failures.slice(0, 60).join("\n"));
  if (failures.length > 60) console.error(`...and ${failures.length - 60} more failures`);
  process.exit(1);
}

console.log("120 PDCA simulations passed");
console.log("domain coverage:");
for (const [domain, count] of [...stats.entries()].sort((a, b) => a[0].localeCompare(b[0], "ja"))) {
  console.log(`- ${domain}: ${count}`);
}
