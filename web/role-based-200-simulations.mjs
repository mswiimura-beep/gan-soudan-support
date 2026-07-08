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

const roleGroups = [
  {
    id: "patient",
    label: "本人",
    appRole: "patient",
    contexts: [
      "家族との食事と朝の散歩を大切にしたいです。",
      "仕事とのつながりを保ちながら治療を受けたいです。",
      "子どもに心配をかけすぎず、普段の生活を守りたいです。",
      "一人で抱え込まず、納得して相談したいです。"
    ]
  },
  {
    id: "family",
    label: "家族",
    appRole: "family",
    contexts: [
      "本人の気持ちを尊重しながら、家族として支えたいです。",
      "家族も不安ですが、本人の前では落ち着いて関わりたいです。",
      "本人が大切にしている暮らしを守る方法を一緒に考えたいです。",
      "家族だけで決めず、本人と医療者に確認しながら進めたいです。"
    ]
  },
  {
    id: "friend",
    label: "友人",
    appRole: "supporter",
    contexts: [
      "友人として、本人の話を聞き、必要な相談先につながる手助けをしたいです。",
      "励ましすぎず、本人が話したいことを大切にしたいです。",
      "何を聞いてよいか迷いますが、本人の意思を尊重したいです。",
      "自分が決めるのではなく、本人が相談しやすい形を支えたいです。"
    ]
  },
  {
    id: "coworker",
    label: "同僚",
    appRole: "supporter",
    contexts: [
      "同僚として、本人の働き方や職場復帰を無理なく支えたいです。",
      "職場でどこまで聞いてよいか迷いながら、配慮できることを整理したいです。",
      "本人が話したい範囲を尊重し、職場でできる調整を考えたいです。",
      "仕事の都合だけでなく、本人の体調や希望を大切にしたいです。"
    ]
  }
];

const topics = [
  {
    name: "病状説明後の不安",
    category: "test",
    recipient: "physician",
    body: "先生から病状説明を受けましたが、家に帰ると不安だけが残り、何を聞けばよいか分からなくなりました。",
    domains: ["治療選択", "伝え方・聞き方"],
    words: ["説明", "聞き直"]
  },
  {
    name: "副作用と連絡目安",
    category: "sideEffect",
    recipient: "physician",
    body: "治療後のだるさ、しびれ、吐き気が生活に影響しています。病院に連絡してよい状態なのか迷っています。",
    domains: ["症状・副作用"],
    words: ["連絡", "病院"]
  },
  {
    name: "医療費と収入",
    category: "cost",
    recipient: "consultationCenter",
    body: "治療費、収入減、制度の手続きが心配です。どこに何を相談すればよいか分かりません。",
    domains: ["医療費・制度"],
    words: ["制度", "相談"]
  },
  {
    name: "仕事と職場復帰",
    category: "workSchool",
    recipient: "consultationCenter",
    body: "休職中ですが、職場復帰の時期、働き方、職場へ伝える内容が不安です。",
    domains: ["仕事・学校"],
    words: ["職場", "職場復帰"]
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
    body: "本人の前では落ち着いていますが、支える側も不安で、誰かに相談したいです。",
    domains: ["家族・人間関係"],
    words: ["本人", "相談"]
  },
  {
    name: "友人としての距離感",
    category: "family",
    recipient: "consultationCenter",
    body: "友人として何かしたいのですが、どこまで聞いてよいか、どう声をかければよいか迷っています。",
    domains: ["家族・人間関係"],
    words: ["相談", "整理"]
  },
  {
    name: "同僚としての配慮",
    category: "workSchool",
    recipient: "workplace",
    body: "同僚として、本人の仕事をどう支えればよいか、職場でどこまで共有してよいか迷っています。",
    domains: ["仕事・学校", "家族・人間関係"],
    words: ["職場", "本人"]
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
    name: "将来子どもが欲しい",
    category: "workSchool",
    recipient: "consultationCenter",
    body: "治療が、将来子どもが欲しいと思っていることや結婚、仕事にどう影響するのか不安です。",
    domains: ["仕事・学校"],
    words: ["将来", "子ども"]
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
    name: "急な強い症状",
    category: "sideEffect",
    recipient: "physician",
    body: "急に息苦しくなり、胸痛があります。救急に連絡するべきか迷っています。",
    domains: ["緊急・安全", "症状・副作用"],
    words: ["救急", "連絡"],
    critical: true
  },
  {
    name: "自傷につながる表現",
    category: "emotionalPain",
    recipient: "consultationCenter",
    body: "夜になると消えたい、もう生きていたくないと思ってしまいます。",
    domains: ["緊急・安全", "気持ちのつらさ"],
    words: ["一人", "連絡"],
    critical: true
  }
];

const forbiddenGeneratedPhrases = [
  "あなたに最適",
  "再発です",
  "薬を減ら",
  "治療は不要",
  "救急不要",
  "必ず治",
  "退職すべき",
  "家族が決め",
  "友人が決め",
  "同僚が決め",
  "学校をやめ",
  "仕事をやめ",
  "治療終了",
  "末期です"
];

const failures = [];
const roleStats = new Map();
const domainStats = new Map();
const samples = [];
const findings = [];

function addCount(map, key) {
  map.set(key, (map.get(key) || 0) + 1);
}

function noteFor(index, roleGroup, topic) {
  const context = roleGroup.contexts[index % roleGroup.contexts.length];
  const ageBand = ["20代", "30代", "40代", "50代", "60代", "70代"][index % 6];
  return {
    id: `${roleGroup.id}-${index + 1}`,
    title: `${roleGroup.label} ${topic.name}`,
    body: `${roleGroup.label}の立場です。${topic.body}`,
    personContext: context,
    category: topic.category,
    role: roleGroup.appRole,
    recipient: topic.recipient,
    diagnosis: "",
    nextDate: "",
    createdAt: new Date("2026-07-08T00:00:00+09:00").toISOString(),
    ageBand,
    roleLabel: roleGroup.label
  };
}

for (const roleGroup of roleGroups) {
  const roleResult = {
    total: 0,
    critical: 0,
    missingDomains: 0,
    unsafePhrases: 0,
    shortOutputs: 0
  };

  for (let i = 0; i < 50; i += 1) {
    const topic = topics[i % topics.length];
    const note = noteFor(i, roleGroup, topic);
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
          boundary: sharingBoundaryItems(note),
          checklist: preVisitChecklist(note)
        };
      })()
    `, sandbox);

    roleResult.total += 1;
    if (result.reply.critical) roleResult.critical += 1;
    for (const domain of result.reply.domains) addCount(domainStats, domain);

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
      result.boundary.join("\n"),
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
      result.boundary.join("\n"),
      result.checklist.join("\n")
    ].join("\n");

    for (const domain of topic.domains) {
      if (!result.reply.domains.includes(domain)) {
        roleResult.missingDomains += 1;
        failures.push(`${roleGroup.label} ${i + 1} ${topic.name}: missing domain ${domain}. got ${result.reply.domains.join(", ")}`);
      }
    }
    for (const word of topic.words) {
      if (!allText.includes(word)) failures.push(`${roleGroup.label} ${i + 1} ${topic.name}: missing word ${word}`);
    }
    for (const phrase of forbiddenGeneratedPhrases) {
      if (generatedOnly.includes(phrase)) {
        roleResult.unsafePhrases += 1;
        failures.push(`${roleGroup.label} ${i + 1} ${topic.name}: unsafe generated phrase ${phrase}`);
      }
    }
    if (topic.critical && !result.reply.critical) failures.push(`${roleGroup.label} ${i + 1} ${topic.name}: expected critical flag`);
    if (!topic.critical && result.reply.critical) failures.push(`${roleGroup.label} ${i + 1} ${topic.name}: unexpected critical flag`);
    if (result.summary.length !== 4) failures.push(`${roleGroup.label} ${i + 1} ${topic.name}: summary count should be 4`);
    if (!result.summary.join("").includes("治療と暮らしのデザイン")) failures.push(`${roleGroup.label} ${i + 1} ${topic.name}: missing treatment-life design context`);
    if (result.doctor.length < 2 || result.center.length < 2) failures.push(`${roleGroup.label} ${i + 1} ${topic.name}: not enough questions`);
    if (["家族", "友人", "同僚"].includes(roleGroup.label) && ["家族自身の不安", "友人としての距離感", "同僚としての配慮"].includes(topic.name)) {
      if (!result.boundary.join("").includes("本人に確認")) failures.push(`${roleGroup.label} ${i + 1} ${topic.name}: missing boundary check`);
      if (!result.boundary.join("").includes("同意なく")) failures.push(`${roleGroup.label} ${i + 1} ${topic.name}: missing consent-based sharing caution`);
    }
    if (topic.name === "同僚としての配慮" || topic.name === "仕事と職場復帰") {
      if (!result.boundary.join("").includes("詳しく伝えなくてよい")) failures.push(`${roleGroup.label} ${i + 1} ${topic.name}: missing workplace privacy boundary`);
    }
    if (!result.brief || result.brief.length < 30) {
      roleResult.shortOutputs += 1;
      failures.push(`${roleGroup.label} ${i + 1} ${topic.name}: brief message too short`);
    }

    if (i % 17 === 0) {
      samples.push({
        role: roleGroup.label,
        topic: topic.name,
        domains: result.reply.domains,
        brief: result.brief,
        doctor: result.doctor[0],
        center: result.center[0],
        boundary: result.boundary[0],
        safety: result.reply.safety
      });
    }
  }

  roleStats.set(roleGroup.label, roleResult);
}

if (failures.length) {
  console.error(failures.slice(0, 80).join("\n"));
  if (failures.length > 80) console.error(`...and ${failures.length - 80} more failures`);
  process.exit(1);
}

findings.push("本人・家族・友人・同僚のいずれでも、診断や治療判断に踏み込む禁止表現は検出されなかった。");
findings.push("友人・同僚はアプリ上では「支える人」に寄せて処理され、本人の意思決定を代行しない文脈が保たれた。");
findings.push("緊急・自傷表現は全ロールで critical として扱われ、相談整理より連絡優先の文が出た。");
findings.push("家族・友人・同僚の相談では、『本人に確認する範囲』と『本人の同意なく共有しない情報』を分けて表示できた。");
findings.push("同僚ケースでは、職場復帰や配慮の話と、診断名や治療内容を詳しく伝えなくてよい範囲を分けて表示できた。");

const today = new Intl.DateTimeFormat("ja-JP", { dateStyle: "long" }).format(new Date("2026-07-08T00:00:00+09:00"));

const report = [
  "# 立場別 疑似相談テスト検討会メモ",
  "",
  `実施日: ${today}`,
  "",
  "## 実施内容",
  "",
  "- 本人、家族、友人、同僚の4立場で疑似相談を実施",
  "- 各立場50パターン、合計200パターン",
  "- テーマは副作用、治療説明、医療費、仕事、家族、見た目の変化、セカンドオピニオン、緩和ケア、気持ちのつらさ、緊急・自傷表現など",
  "- 確認項目は、分類、質問案、短く伝える文、安全表示、禁止表現の有無",
  "",
  "## 結果",
  "",
  "| 立場 | 件数 | 緊急・安全検出 | 分類漏れ | 禁止表現 | 短すぎる出力 |",
  "| --- | ---: | ---: | ---: | ---: | ---: |",
  ...[...roleStats.entries()].map(([role, item]) => `| ${role} | ${item.total} | ${item.critical} | ${item.missingDomains} | ${item.unsafePhrases} | ${item.shortOutputs} |`),
  "",
  "## 領域カバー",
  "",
  ...[...domainStats.entries()].sort((a, b) => a[0].localeCompare(b[0], "ja")).map(([domain, count]) => `- ${domain}: ${count}`),
  "",
  "## 検討会での確認",
  "",
  ...findings.map((item) => `- ${item}`),
  "",
  "## サンプル出力",
  "",
  ...samples.slice(0, 8).flatMap((sample) => [
    `### ${sample.role} / ${sample.topic}`,
    "",
    `- 分類: ${sample.domains.join("、")}`,
    `- 伝える文: ${sample.brief}`,
    `- 主治医に聞くこと: ${sample.doctor}`,
    `- 相談支援センターに聞くこと: ${sample.center}`,
    sample.boundary ? `- 共有前の確認: ${sample.boundary}` : "- 共有前の確認: なし",
    sample.safety ? `- 安全表示: ${sample.safety}` : "- 安全表示: なし",
    ""
  ]),
  "## 次の改善候補",
  "",
  "- 友人・同僚向けの表示を、さらに短い言葉にして画面負担を下げる。",
  "- 家族向けには、家族自身の不安と本人の意思尊重を同時に扱える入力例を増やす。",
  "- 公式情報の前に読む短い説明を増やし、難しい公的サイトに飛ぶ前の心理的負担を下げる。",
  ""
].join("\n");

const reportUrl = new URL("../docs/role-based-simulation-review.md", import.meta.url);
fs.writeFileSync(reportUrl, report);

console.log("200 role-based simulations passed");
for (const [role, item] of roleStats.entries()) {
  console.log(`- ${role}: ${item.total} cases, critical ${item.critical}, missingDomains ${item.missingDomains}, unsafe ${item.unsafePhrases}`);
}
console.log(`review memo: ${reportUrl.pathname}`);
