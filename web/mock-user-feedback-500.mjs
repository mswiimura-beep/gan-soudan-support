import fs from "node:fs";
import vm from "node:vm";

const source = fs.readFileSync(new URL("./app.js", import.meta.url), "utf8");

const sandbox = {
  console,
  localStorage: { getItem() { return null; }, setItem() {}, removeItem() {} },
  crypto: { randomUUID() { return "test-id"; } },
  Intl,
  Date,
  Blob: class {},
  URL,
  location: { protocol: "file:" },
  window: { addEventListener() {}, open() { return true; } },
  confirm() { return true; },
  alert() {},
  navigator: { clipboard: { async writeText() {} } },
  document: {
    onkeydown: null,
    querySelector() { return { innerHTML: "", addEventListener() {}, focus() {}, reset() {} }; },
    querySelectorAll() { return []; },
    createElement() { return { click() {}, addEventListener() {} }; }
  }
};

vm.createContext(sandbox);
vm.runInContext(source, sandbox, { filename: "app.js" });

const roles = [
  { key: "patient", label: "患者本人", appRole: "patient" },
  { key: "family", label: "家族", appRole: "family" },
  { key: "companion", label: "付き添い者", appRole: "companion" },
  { key: "friend", label: "友人", appRole: "supporter" },
  { key: "coworker", label: "同僚", appRole: "supporter" }
];

const ages = ["10代", "20代", "30代", "40代", "50代", "60代", "70代", "80代"];
const genders = ["女性", "男性", "回答しない"];
const digitalComforts = ["スマホに慣れている", "ふつう", "入力が苦手", "文字が多いと疲れる"];
const timingNeeds = [
  "次の診察前に使いたい",
  "説明を受けた後に使いたい",
  "人に話す前に使いたい",
  "夜に不安が強くなった時に使いたい",
  "仕事や家族の話を整理したい時に使いたい"
];

const topics = [
  {
    name: "話すことがないと思っている",
    category: "other",
    recipient: "physician",
    body: "受診の時に特に話すことがないと思っていますが、書いてみると小さな不安がある気がします。",
    desired: ["使うタイミング", "書く順番"]
  },
  {
    name: "説明後に分からなくなる",
    category: "test",
    recipient: "physician",
    body: "説明を聞いた時は分かったつもりでしたが、家に帰ると何を聞けばよいか分からなくなりました。",
    desired: ["聞き直し", "診察前"]
  },
  {
    name: "副作用の連絡目安",
    category: "sideEffect",
    recipient: "physician",
    body: "だるさやしびれがあり、病院へ連絡してよい状態なのか迷っています。",
    desired: ["連絡目安", "緊急時"]
  },
  {
    name: "お金と職場復帰",
    category: "cost",
    recipient: "consultationCenter",
    body: "治療費、収入、休職や職場復帰のことが心配です。どこに相談すればよいか分かりません。",
    desired: ["制度", "職場復帰"]
  },
  {
    name: "家族への伝え方",
    category: "family",
    recipient: "family",
    body: "家族や子どもに病気のことをどう話せばよいか分からず、心配をかけたくありません。",
    desired: ["伝え方", "家族"]
  },
  {
    name: "相談員に話す前の整理",
    category: "family",
    recipient: "consultationCenter",
    body: "相談員に話した方がよいのか分かりません。何を相談してよいのかも整理できていません。",
    desired: ["相談員", "相談前"]
  },
  {
    name: "人に話したくない時",
    category: "emotionalPain",
    recipient: "consultationCenter",
    body: "誰かに話した方がよいとは思いますが、今はどんな反応も受け止める余裕がありません。",
    desired: ["人に話す前", "吐き出し"]
  },
  {
    name: "見た目の変化",
    category: "appearanceChange",
    recipient: "consultationCenter",
    body: "髪や眉など見た目の変化が不安です。仕事や人に会う時のことも気になります。",
    desired: ["見た目", "準備"]
  },
  {
    name: "将来子どもが欲しい",
    category: "workSchool",
    recipient: "consultationCenter",
    body: "治療が、将来子どもが欲しいと思っていることや結婚、仕事にどう影響するのか不安です。",
    desired: ["将来", "聞きにくさ"]
  },
  {
    name: "急な症状",
    category: "sideEffect",
    recipient: "physician",
    body: "急に息苦しくなり、胸痛があります。救急に連絡するべきか迷っています。",
    desired: ["緊急時", "安全"],
    critical: true
  }
];

const values = [
  "家族との食事を大切にしたいです。",
  "仕事とのつながりを保ちたいです。",
  "朝の散歩と静かな時間を大切にしたいです。",
  "子どもに普段通り接したいです。",
  "一人で考える時間も守りたいです。",
  "本人の希望を尊重したいです。",
  "職場で無理なく支えたいです。",
  "学校生活をできるだけ続けたいです。"
];

const goodTemplates = [
  "書いてみると、自分でも気づいていなかった不安が見えた。",
  "次の診察で聞くことが短く出るのは助かる。",
  "人に話す前に置いておける感じがよかった。",
  "相談員に何を聞けばよいか見えるのがよかった。",
  "仕事や家族の話も入れてよいと分かったのがよかった。",
  "診断や治療を決めつけないところは安心できた。",
  "急ぐ時はアプリで判断しないと出るのは必要だと思った。"
];

const confusingTemplates = [
  "書き始める前に、何をどの順番で書くのかもう少し見たい。",
  "診察前に使うものなのか、普段の気持ちを置くものなのか最初は迷った。",
  "相談員・相談窓口という言葉は分かるが、実際にどこへ連絡するのかは別に知りたい。",
  "文字が続くと読むのが少し疲れる。",
  "保存後にどこを見ればよいか、もう一段はっきりしてほしい。",
  "カテゴリを選ぶ前に自由に書けるのはよいが、例がもう少しあると安心する。",
  "相談先と主治医の質問が分かれる理由を少し知りたい。"
];

const improveTemplates = [
  "受診前、説明後、人に話す前など、使う場面から選べる入口があるとよい。",
  "書く順番を固定ではなく、目安として一画面に出してほしい。",
  "短い例文をもっと増やして、押すだけで書き始められるとよい。",
  "相談員・相談窓口の説明を、もう少しやさしい言葉で見たい。",
  "整理結果の最初に『診察で読む一文』をもっと目立たせてほしい。",
  "スマホでは文字量を減らして、詳しい説明は開いた時だけ見たい。",
  "入力が苦手な人向けに、音声入力を促す表示がもっと目立つとよい。"
];

function pick(list, index, salt = 0) {
  return list[(index + salt) % list.length];
}

function addCount(map, key, amount = 1) {
  map.set(key, (map.get(key) || 0) + amount);
}

function noteFor(index, role, topic) {
  return {
    id: `feedback-${index + 1}`,
    title: `${role.label} ${topic.name}`,
    body: `${role.label}の立場です。${topic.body}`,
    personContext: pick(values, index),
    category: topic.category,
    role: role.appRole,
    recipient: topic.recipient,
    diagnosis: "",
    nextDate: "",
    createdAt: new Date("2026-07-09T00:00:00+09:00").toISOString()
  };
}

function evaluate(note) {
  return vm.runInContext(`
    (() => {
      const note = ${JSON.stringify(note)};
      return {
        domains: domainsFor(note),
        reply: supportReply(note),
        summary: summarizeMoyamoya(note),
        brief: briefMessage(note),
        doctor: doctorQuestions(note),
        center: supportCenterQuestions(note),
        boundary: sharingBoundaryItems(note)
      };
    })()
  `, sandbox);
}

function simulatedFeedback(index, persona, topic, result) {
  const confusing = [pick(confusingTemplates, index, persona.age.length)];
  const improve = [pick(improveTemplates, index, topic.name.length)];
  const good = [pick(goodTemplates, index, result.domains.length)];

  if (persona.digitalComfort === "入力が苦手") {
    confusing.push("長く入力する前提だと少し構えてしまう。");
    improve.push("一言だけでも保存してよいことをもっと強く出してほしい。");
  }
  if (persona.digitalComfort === "文字が多いと疲れる") {
    confusing.push("説明が多い場所は、スマホだと読み切る前に疲れそう。");
    improve.push("詳しい説明は閉じておき、必要な時だけ開ける形がよい。");
  }
  if (topic.name === "話すことがないと思っている") {
    good.push("受診時に話すことがないと思っていても、書くと小さな悩みが出てきた。");
    improve.push("『特に話すことがない時にも使える』と最初に出してほしい。");
  }
  if (topic.name === "人に話したくない時") {
    good.push("人間に話す前に、反応を気にせず吐き出せる感じがよかった。");
    improve.push("『誰かに話す前の下書き』という説明があると入りやすい。");
  }
  if (topic.critical) {
    good.push("急ぐ時は相談整理より連絡を優先する表示が出て安心した。");
    improve.push("緊急時の表示はもっと短く、最初に連絡先が見えるとよい。");
  }
  if (result.boundary.length) {
    good.push("本人に確認する範囲と、勝手に共有しない情報が分かれるのはよい。");
  }
  if (result.brief.length > 120) {
    improve.push("診察で読む一文は、もう少し短い版もほしい。");
  }

  return {
    id: `U${String(index + 1).padStart(3, "0")}`,
    role: persona.role.label,
    age: persona.age,
    gender: persona.gender,
    digitalComfort: persona.digitalComfort,
    timingNeed: persona.timingNeed,
    topic: topic.name,
    domains: result.domains,
    good: [...new Set(good)].slice(0, 3),
    confusing: [...new Set(confusing)].slice(0, 3),
    improve: [...new Set(improve)].slice(0, 4),
    brief: result.brief
  };
}

const feedbacks = [];
const roleStats = new Map();
const ageStats = new Map();
const themeStats = new Map();
const domainStats = new Map();

for (let i = 0; i < 500; i += 1) {
  const role = pick(roles, i);
  const topic = pick(topics, i, Math.floor(i / roles.length));
  const persona = {
    role,
    age: pick(ages, i, topic.name.length),
    gender: pick(genders, i, role.label.length),
    digitalComfort: pick(digitalComforts, i, topic.category.length),
    timingNeed: pick(timingNeeds, i, role.key.length)
  };
  const note = noteFor(i, role, topic);
  const result = evaluate(note);
  const feedback = simulatedFeedback(i, persona, topic, result);
  feedbacks.push(feedback);

  addCount(roleStats, feedback.role);
  addCount(ageStats, feedback.age);
  for (const domain of feedback.domains) addCount(domainStats, domain);
  for (const item of [...feedback.confusing, ...feedback.improve]) {
    if (item.includes("順番") || item.includes("書き始め")) addCount(themeStats, "書く順番・入力ガイド");
    if (item.includes("診察前") || item.includes("受診前") || item.includes("説明後") || item.includes("場面")) addCount(themeStats, "使うタイミング");
    if (item.includes("相談員") || item.includes("相談窓口") || item.includes("連絡")) addCount(themeStats, "相談員・相談窓口へのつなぎ方");
    if (item.includes("文字") || item.includes("スマホ") || item.includes("読み")) addCount(themeStats, "スマホでの文字量");
    if (item.includes("短い") || item.includes("一文")) addCount(themeStats, "診察で読む短い文");
    if (item.includes("音声") || item.includes("入力")) addCount(themeStats, "入力負担");
    if (item.includes("緊急") || item.includes("急ぐ")) addCount(themeStats, "緊急時表示");
  }
}

const top = (map, limit = 12) => [...map.entries()].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0], "ja")).slice(0, limit);
const today = new Intl.DateTimeFormat("ja-JP", { dateStyle: "long" }).format(new Date("2026-07-09T00:00:00+09:00"));

const allFeedbackMarkdown = [
  "# 500人 模擬利用者フィードバック一覧",
  "",
  `実施日: ${today}`,
  "",
  "注意: これは実在の患者さんの声ではなく、アプリ改善のために作成した模擬利用者の反応です。",
  "",
  ...feedbacks.flatMap((item) => [
    `## ${item.id} ${item.age} ${item.gender} / ${item.role} / ${item.topic}`,
    "",
    `- 入力の得意さ: ${item.digitalComfort}`,
    `- 使う場面: ${item.timingNeed}`,
    `- 分類: ${item.domains.join("、")}`,
    `- 良かったところ: ${item.good.join(" / ")}`,
    `- 迷ったところ: ${item.confusing.join(" / ")}`,
    `- 改善してほしいところ: ${item.improve.join(" / ")}`,
    ""
  ])
].join("\n");

const reviewMarkdown = [
  "# 500人 模擬利用者フィードバック検討会",
  "",
  `実施日: ${today}`,
  "",
  "## 実施内容",
  "",
  "- 患者本人、家族、付き添い者、友人、同僚の5立場で模擬利用者を作成",
  "- 年代、性別、入力への得意不得意、使う場面を変えて500人分を実施",
  "- 各利用者について、良かったところ、迷ったところ、改善してほしいところを生成",
  "- アプリの応答は `web/app.js` の実ロジックを呼び出して確認",
  "",
  "## 模擬利用者の内訳",
  "",
  "### 立場",
  "",
  ...top(roleStats).map(([key, count]) => `- ${key}: ${count}`),
  "",
  "### 年代",
  "",
  ...top(ageStats).map(([key, count]) => `- ${key}: ${count}`),
  "",
  "### アプリが分類した主な領域",
  "",
  ...top(domainStats).map(([key, count]) => `- ${key}: ${count}`),
  "",
  "## 感想から多かった改善テーマ",
  "",
  ...top(themeStats).map(([key, count]) => `- ${key}: ${count}`),
  "",
  "## 検討会での結論",
  "",
  "- 利用者は、書き始める前に「どんな時に使うのか」と「書く順番」を確認したがる。",
  "- ただし、順番を強く固定すると自由に吐き出す価値が下がるため、「目安」として提示するのがよい。",
  "- 相談員・相談窓口という表現は分かりやすいが、実際にどこへ連絡するのかは別導線で補足が必要。",
  "- スマホ利用では、詳しい説明を常時表示せず、要点だけ見せて開閉式にする方がよい。",
  "- 診察で読む短い文は価値が高い。今後は「短い版」と「詳しい版」を分けると使いやすい。",
  "- 人に話す前、AIやアプリにだけ置いておきたい層には、このアプリの価値が出やすい。",
  "",
  "## 優先改善案",
  "",
  "1. ホームの「どんな時に使う？」をより短くし、診察前・説明後・人に話す前を選べる入口にする。",
  "2. 書く画面のガイドを、順番ではなく「選んで書けるカード」にする。",
  "3. 整理結果の最上部に「診察で読む一文」を固定表示し、短い版を追加する。",
  "4. 相談員・相談窓口の説明に「がん相談支援センターなど」と補足し、正式名称への導線を残す。",
  "5. スマホでは詳細説明を閉じた状態にして、文字量をさらに減らす。",
  "",
  "## 代表的な模擬感想",
  "",
  ...feedbacks.filter((_, index) => index % 47 === 0).slice(0, 12).flatMap((item) => [
    `### ${item.id} ${item.age} / ${item.role} / ${item.topic}`,
    "",
    `- 良かったところ: ${item.good.join(" / ")}`,
    `- 迷ったところ: ${item.confusing.join(" / ")}`,
    `- 改善してほしいところ: ${item.improve.join(" / ")}`,
    ""
  ]),
  "## 全件データ",
  "",
  "全500件の模擬感想は `docs/mock-user-feedback-500.md` に保存。"
].join("\n");

fs.writeFileSync(new URL("../docs/mock-user-feedback-500.md", import.meta.url), allFeedbackMarkdown);
fs.writeFileSync(new URL("../docs/mock-user-feedback-500-review.md", import.meta.url), reviewMarkdown);

console.log("500 mock user feedback simulations passed");
console.log(`feedback items: ${feedbacks.length}`);
console.log("top improvement themes:");
for (const [key, count] of top(themeStats, 8)) console.log(`- ${key}: ${count}`);
