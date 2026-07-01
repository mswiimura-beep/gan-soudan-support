const STORAGE_KEY = "gan-soudan-support.web.notes.v1";
const CONSENT_KEY = "gan-soudan-support.web.consent.v1";
const DRAFT_KEY = "gan-soudan-support.web.draft.v1";
const FEEDBACK_FORM_URL = "";

const categories = [
  ["treatment", "治療について", "🧰"],
  ["test", "検査について", "🔎"],
  ["sideEffect", "副作用・体調について", "💗"],
  ["appearanceChange", "見た目の変化について", "🪞"],
  ["cost", "医療費・制度について", "💴"],
  ["workSchool", "仕事・学校について", "💼"],
  ["family", "家族・人間関係について", "👥"],
  ["secondOpinion", "セカンドオピニオンについて", "🔀"],
  ["palliativeCare", "緩和ケアについて", "🤲"],
  ["emotionalPain", "気持ちのつらさについて", "🫶"],
  ["other", "その他", "…"]
];

const roles = [
  ["patient", "患者本人"],
  ["family", "家族"],
  ["companion", "付き添い者"],
  ["supporter", "支える人"],
  ["undecided", "まだ決めていない"]
];

const recipients = [
  ["physician", "主治医"],
  ["nurse", "看護師"],
  ["consultationCenter", "がん相談支援センター"],
  ["family", "家族"],
  ["workplace", "職場・学校"],
  ["other", "まだ決めていない"]
];

const templates = [
  {
    id: "side-effect",
    title: "副作用・体調を相談したい",
    subtitle: "症状と連絡の目安を整理",
    category: "sideEffect",
    role: "patient",
    recipient: "physician",
    body: "治療後の体調について相談したいです。いつから、どの症状が、生活にどのくらい影響しているかを整理したいです。",
    icon: "💗"
  },
  {
    id: "appearance-change",
    title: "見た目の変化が不安",
    subtitle: "髪、眉、肌、爪、帽子、ウィッグ",
    category: "appearanceChange",
    role: "patient",
    recipient: "consultationCenter",
    body: "治療に伴う髪、眉、肌、爪、体型、服装などの見た目の変化が不安です。実際にどうなるかを決めつけず、準備したいことや相談したいことを整理したいです。",
    icon: "🪞"
  },
  {
    id: "cost-work",
    title: "お金・仕事が心配",
    subtitle: "制度、収入、休職・職場復帰",
    category: "cost",
    role: "patient",
    recipient: "consultationCenter",
    body: "治療費、収入、休職や職場復帰のことが心配です。使える制度、職場への伝え方、復帰する時期や配慮してほしいことを整理したいです。",
    icon: "💴"
  },
  {
    id: "family-supporter",
    title: "家族として相談したい",
    subtitle: "本人への伝え方と家族の不安",
    category: "family",
    role: "family",
    recipient: "consultationCenter",
    body: "家族として、本人をどう支えればよいか、自分の不安をどこへ相談すればよいか整理したいです。",
    icon: "👥"
  },
  {
    id: "explanation-gap",
    title: "説明が分からなくなった",
    subtitle: "聞き直したい点を整理",
    category: "treatment",
    role: "patient",
    recipient: "physician",
    body: "病院で説明を聞いた時は分かったつもりでしたが、家に帰ってから分からない点が出てきました。聞き直したい内容を整理したいです。",
    icon: "💬"
  },
  {
    id: "second-opinion",
    title: "セカンドオピニオン",
    subtitle: "目的、資料、伝え方",
    category: "secondOpinion",
    role: "patient",
    recipient: "consultationCenter",
    body: "セカンドオピニオンを考えています。何を確認したいのか、必要な資料、主治医への伝え方を整理したいです。",
    icon: "🔀"
  },
  {
    id: "aya-life",
    title: "学校・将来・子どものこと",
    subtitle: "若い世代の心配",
    category: "workSchool",
    role: "patient",
    recipient: "consultationCenter",
    body: "治療が学校、仕事、将来子どもが欲しいと思っていること、見た目、将来にどう影響するのか不安です。相談できることを整理したいです。",
    icon: "🌱"
  }
];

const trustedResources = [
  resource("life-design", "まず整理する", "治療と暮らしをデザインする", "大切にしたい生活、避けたいこと、相談のゴールを分ける", "🧭", "治療を受ける時も、病気だけでなく暮らし全体を一緒に考えることが大切です。何を大切にしたいか、何を避けたいか、誰に何を相談したいかを分けると、医療者や相談支援センターに伝えやすくなります。", ["治療の話だけで生活が置き去りになっている", "自分が何を大切にしたいのか言葉にできない", "こうはなりたくないという不安がある"], ["治療を受けながら、保ちたい生活について相談できますか？", "避けたいことや譲れないことを、どのように医療者へ伝えればよいですか？", "相談支援センターで、暮らしや仕事、家族のことも一緒に整理できますか？"], ["大切にしたいことを1つ書く", "避けたいことを1つ書く", "相談のゴールを1つ選ぶ"], "https://ganjoho.jp/public/support/index.html", "がん情報サービス 療養生活の支援"),
  resource("first", "まず整理する", "まず何を調べるか整理する", "病名や治療の一般情報を見る前に、知りたいことを分ける", "📘", "がんの情報は量が多く、いきなり外部サイトを読むだけでは不安が増えることがあります。まず、病気の説明、検査、治療、副作用、生活、お金、家族への伝え方のどれを知りたいのかを分けます。", ["説明を聞いたが、どこから確認すればよいか分からない", "検索結果が多すぎて、信頼できる情報を選べない"], ["私がまず理解しておくべき病気や治療の言葉は何ですか？", "自分の場合に当てはまる情報と、一般情報の違いはどこですか？"], ["知りたいことを1つだけ相談メモに書く", "一般情報を読んだ後、自己判断せず主治医に確認する"], "https://ganjoho.jp/public/index.html", "国立がん研究センター がん情報サービス"),
  resource("center", "まず整理する", "がん相談支援センターに相談する", "治療以外の不安も相談できる窓口として使う", "👥", "がん相談支援センターは、患者さん本人だけでなく家族も相談できる窓口です。治療方針を決めてもらう場所ではなく、困りごとを整理し、必要な情報や相談先につなげてもらうために使います。", ["医師に聞くほどではないと思って我慢している", "お金、仕事、家族、制度の話を誰に聞けばよいか分からない"], ["この内容は相談支援センターで相談できますか？", "主治医に確認した方がよいことは何ですか？"], ["相談メモをテキストで出す", "相談時に、今一番困っていることを1つ目に伝える"], "https://hospdb.ganjoho.jp/kyotendb.nsf/xpConsultantSearchTop.xsp", "がん相談支援センター検索"),
  resource("money", "暮らし・制度", "医療費・制度の不安を整理する", "高額療養費、休職、収入減などを相談しやすくする", "💴", "医療費の不安は、制度名を読むだけでは自分に使えるか分かりにくい領域です。加入している保険、収入、治療予定、仕事の状況を分けて確認します。", ["治療費がどのくらいになるか不安", "休職や収入減で生活が心配"], ["高額療養費制度や限度額適用認定証の対象になりますか？", "相談先は病院、保険者、職場のどこがよいですか？"], ["保険証の種類、勤務先、治療予定をメモする", "病院の相談支援センターで制度相談を予約する"], "https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/kenkou_iryou/iryouhoken/juuyou/kougakuiryou/index.html", "厚生労働省 高額療養費制度"),
  resource("work", "暮らし・制度", "仕事・学校との両立を相談する", "休み方、伝え方、治療予定の調整を整理する", "💼", "治療と仕事・学校の両立は、病状だけでなく、勤務形態、通院頻度、副作用、職場や学校にどこまで伝えるかが関わります。", ["仕事や学校を続けられるか不安", "職場や学校にどう伝えるか迷っている"], ["治療中に避けた方がよい作業や予定はありますか？", "職場や学校に伝えるための診断書や説明書は必要ですか？"], ["勤務・授業・通院予定をメモに並べる", "職場や学校へ出す前に、相談支援センターで言い方を確認する"], "https://chiryoutoshigoto.mhlw.go.jp/", "厚生労働省 治療と仕事の両立支援"),
  resource("family", "暮らし・制度", "家族・付き添い者として相談する", "本人への伝え方、自分の不安、支える限界を整理する", "👥", "家族は、本人を支えたい気持ちと、自分自身の不安を同時に抱えやすくなります。本人の意思を尊重しながら、家族自身が相談できることも整理します。", ["本人にどう声をかければよいか分からない", "付き添いや介護の負担が大きくなっている"], ["家族として診察時に確認してよいことは何ですか？", "家族自身の不安や負担を相談できる窓口はありますか？"], ["本人に確認したいことと、家族自身の不安を分けて書く", "相談支援センターへ家族として相談する"], "https://ganjoho.jp/public/support/family/index.html", "がん情報サービス 家族向け情報"),
  resource("young", "からだ・生活の変化", "若い世代の心配", "学校、仕事、将来子どもが欲しい気持ちを分ける", "🌱", "若い世代では、治療だけでなく、学校、仕事、恋愛、結婚、将来子どもが欲しいと思っていること、見た目、将来設計などが同時に問題になります。", ["将来子どもが欲しいと思っていることや、見た目の変化が不安", "学校や仕事への説明に迷っている"], ["将来子どもが欲しいと思っていることへの影響について、どこで相談できますか？", "学校や職場へ伝える時、どの範囲まで説明すればよいですか？"], ["聞きにくいこともメモに書き出す", "主治医に聞くことと、相談支援センターに聞くことを分ける"], "https://ganjoho.jp/public/life_stage/aya/index.html", "がん情報サービス 若い世代のがん情報"),
  resource("appearance", "からだ・生活の変化", "見た目の変化に備える", "髪、眉、肌、爪、帽子、ウィッグの不安を整理する", "🪞", "治療に伴う見た目の変化は、体の変化だけでなく、人に会うこと、仕事や学校、家族との過ごし方、自分らしさにも関わります。", ["髪、眉、まつ毛、肌、爪、体型、服装の変化が不安", "帽子、タオル帽子、ウィッグ、眉メイクなどを試すか迷っている"], ["治療に伴う見た目の変化について、どの時期に何を確認すればよいですか？", "帽子、ウィッグ、眉メイク、スキンケアについて相談できる窓口はありますか？"], ["いちばん不安な変化を1つ選んで相談メモに書く", "助成制度や購入先は、相談支援センターや自治体に確認する"], "https://ganjoho.jp/public/support/condition/appearance/index.html", "がん情報サービス アピアランスケア"),
  resource("urgent", "急ぐ時", "強い症状・危険を感じる時", "アプリで判断せず、医療機関・救急へつなぐ", "⚠️", "息苦しさ、胸痛、意識がもうろうとする、強い痛み、出血、高熱などがある時は、情報を読むより先に連絡が必要です。このアプリは緊急性を判定しません。", ["急な強い症状がある", "危険かもしれないと感じている", "死にたい、消えたい気持ちがある"], ["今すぐ病院や救急へ連絡する状態ですか？", "一人でいないために、今連絡できる人は誰ですか？"], ["119番、救急、医療機関、身近な人へ連絡する", "落ち着いた後で、症状の始まり、体温、薬、連絡先をメモする"], "https://www.fdma.go.jp/mission/enrichment/appropriate/appropriate001.html", "総務省消防庁 救急車利用案内")
];

const state = {
  tab: "home",
  notes: loadNotes(),
  accepted: localStorage.getItem(CONSENT_KEY) === "yes",
  selectedResource: null,
  feedbackOpen: false,
  shouldFocusMain: false
};

function resource(id, group, title, subtitle, icon, overview, useWhen, questions, actions, url, sourceName) {
  return { id, group, title, subtitle, icon, overview, useWhen, questions, actions, url, sourceName };
}

function labelFor(list, key) {
  return list.find(([id]) => id === key)?.[1] ?? key;
}

function categoryIcon(key) {
  return categories.find(([id]) => id === key)?.[2] ?? "📝";
}

function loadNotes() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY) || "[]");
  } catch {
    return [];
  }
}

function saveNotes() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state.notes));
}

function loadDraft() {
  try {
    return JSON.parse(localStorage.getItem(DRAFT_KEY) || "{}");
  } catch {
    return {};
  }
}

function saveDraft(form) {
  const data = new FormData(form);
  const draft = {
    title: String(data.get("title") || ""),
    body: String(data.get("body") || ""),
    personContext: String(data.get("personContext") || ""),
    category: String(data.get("category") || "treatment"),
    role: String(data.get("role") || "patient"),
    recipient: String(data.get("recipient") || "physician"),
    diagnosis: String(data.get("diagnosis") || ""),
    nextDate: String(data.get("nextDate") || "")
  };
  localStorage.setItem(DRAFT_KEY, JSON.stringify(draft));
}

function clearDraft() {
  localStorage.removeItem(DRAFT_KEY);
}

function deleteAllLocalData() {
  localStorage.removeItem(STORAGE_KEY);
  localStorage.removeItem(DRAFT_KEY);
  localStorage.removeItem(CONSENT_KEY);
  state.notes = [];
  state.accepted = false;
  state.selectedResource = null;
  state.feedbackOpen = false;
}

function h(text) {
  return String(text ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function includesAny(text, words) {
  return words.some((word) => text.includes(word));
}

function noteText(note) {
  return [note.title, note.body, note.personContext, note.category, note.role, note.recipient].filter(Boolean).join(" ").toLowerCase();
}

function domainsFor(note) {
  const domains = [domainForCategory(note.category)];
  const text = noteText(note);
  addDomain(domains, "症状・副作用", includesAny(text, ["だる", "しびれ", "痛", "吐き気", "副作用", "眠れ", "息苦", "発熱"]));
  addDomain(domains, "見た目の変化", includesAny(text, ["見た目", "外見", "髪", "脱毛", "眉", "まゆ", "まつ毛", "肌", "爪", "ウィッグ", "かつら", "帽子", "タオル帽子", "服装", "体型"]));
  addDomain(domains, "治療選択", includesAny(text, ["治療", "手術", "抗がん剤", "放射線", "決め", "選", "方針"]));
  addDomain(domains, "医療費・制度", includesAny(text, ["お金", "費用", "医療費", "支払", "制度", "収入", "傷病手当", "高額", "職場復帰", "復職"]));
  addDomain(domains, "仕事・学校", includesAny(text, ["仕事", "職場", "休職", "学校", "働", "職場復帰", "復職"]));
  addDomain(domains, "家族・人間関係", includesAny(text, ["家族", "子ども", "妻", "夫", "親", "伝え", "付き添"]));
  addDomain(domains, "セカンドオピニオン", includesAny(text, ["セカンドオピニオン", "別の医師", "他の病院", "資料"]));
  addDomain(domains, "緩和ケア", includesAny(text, ["緩和ケア", "痛み", "つらさを和らげ", "あきらめ"]));
  addDomain(domains, "伝え方・聞き方", includesAny(text, ["説明", "分から", "わから", "聞き直", "質問できない", "信用", "忙しそう"]));
  addDomain(domains, "気持ちのつらさ", includesAny(text, ["不安", "怖", "つら", "泣", "眠れ", "弱い", "気持ち"]));
  addDomain(domains, "緊急・安全", containsSelfHarm(text) || containsUrgent(text));
  return prioritizeDomains(domains, text);
}

function addDomain(domains, domain, condition) {
  if (condition && !domains.includes(domain)) domains.push(domain);
}

function prioritizeDomains(domains, text) {
  const protectedDomains = [];
  addDomain(protectedDomains, "緊急・安全", domains.includes("緊急・安全"));
  addDomain(protectedDomains, "伝え方・聞き方", domains.includes("伝え方・聞き方") && includesAny(text, ["説明", "分から", "わから", "聞き直", "質問できない"]));
  const ordered = [domains[0], ...protectedDomains, ...domains].filter(Boolean);
  return [...new Set(ordered)].slice(0, 3);
}

function domainForCategory(category) {
  return {
    treatment: "治療選択",
    test: "治療選択",
    sideEffect: "症状・副作用",
    appearanceChange: "見た目の変化",
    cost: "医療費・制度",
    workSchool: "仕事・学校",
    family: "家族・人間関係",
    secondOpinion: "セカンドオピニオン",
    palliativeCare: "緩和ケア",
    emotionalPain: "気持ちのつらさ",
    other: "情報の整理"
  }[category] ?? "情報の整理";
}

function containsSelfHarm(text) {
  return includesAny(text, ["死にたい", "消えたい", "自殺", "自死", "自分を傷つけ", "もう生きたくない", "生きていたくない"]);
}

function containsUrgent(text) {
  return includesAny(text, ["救急", "今すぐ", "急に", "意識", "危ない", "耐えられない", "息苦", "呼吸困難", "胸痛", "強い痛み", "出血", "高熱", "けいれん"]);
}

function containsDecision(text) {
  return includesAny(text, ["再発", "余命", "治る", "治療をやめ", "薬をやめ", "薬を減ら", "不要", "効かない"]);
}

function primaryDomain(note) {
  return domainsFor(note)[0] ?? "情報の整理";
}

function safetyNotice(note) {
  const text = noteText(note);
  if (containsSelfHarm(text)) return "今すぐ一人で抱えず、身近な人、医療機関、救急、または地域の緊急相談窓口に連絡してください。このアプリでは安全確認や緊急判断はできません。";
  if (containsUrgent(text)) return "強い症状や危険を感じる場合は、アプリで判断せず、医療機関や救急に連絡してください。";
  if (containsDecision(text)) return "診断・治療方針・薬・緊急性はアプリ内で判断せず、医療者に確認する質問として整理します。";
  return "";
}

function supportReply(note) {
  const domain = primaryDomain(note);
  const topic = note.title || labelFor(categories, note.category);
  const maps = {
    "見た目の変化": [
      `${topic}について、見た目が変わるかもしれない不安や、自分らしさをどう保つかが気になっているのですね。`,
      "見た目の変化は、体のことだけでなく、人に会うこと、仕事や学校、家族との過ごし方にもつながりやすい不安です。",
      "今の相談は、実際の変化を予測するのではなく、不安な場面と準備したいことを整理する内容に見えます。",
      "まず整理したいのは、髪、眉、肌、爪、体型、服装、帽子・ウィッグのどれに近いですか？",
      "不安な変化と生活場面を分けると、主治医、看護師、相談支援センターに聞くことを具体化できます。"
    ],
    "症状・副作用": [
      `${topic}について、体のつらさが生活にも影響しているのですね。`,
      "症状が続くと、治療への不安も生活の負担も大きくなりやすいと思います。",
      "今の相談は、症状の程度と病院へ伝える目安を整理したい内容に見えます。",
      "今いちばん困っているのは、痛み・だるさ・しびれ・吐き気・眠れないことのどれに近いですか？",
      "症状の種類を分けると、主治医に伝える内容と連絡の目安を確認しやすくなります。"
    ],
    "医療費・制度": [
      "治療に加えて、お金、制度、仕事や職場復帰のことが気になっているのですね。",
      "お金の心配は言い出しにくく、ひとりで抱えると苦しくなりやすいと思います。",
      "今の相談は、使える制度や窓口を知り、治療を続ける見通しを立てたい内容に見えます。",
      "今いちばん重いのは、治療費、収入、休職、職場復帰、制度の手続きのどれですか？",
      "困りごとの中心が分かると、医療費制度、収入支援、相談窓口を探しやすくなります。"
    ],
    "仕事・学校": [
      "治療と仕事・学校をどう両立するかが引っかかっているのですね。",
      "治療のことをどこまで伝えるか、続けられるかを考えるだけでも負担があります。",
      "今の相談は、治療と生活を両立するために、職場や学校へ何を伝えるか整理する内容に見えます。",
      "まず整理したいのは、休み方、職場・学校への伝え方、使える制度のどれですか？",
      "伝える相手と目的を分けると、職場や学校に話す内容を短くできます。"
    ],
    "家族・人間関係": [
      "ご家族や身近な方への伝え方が気になっているのですね。",
      "大切な相手だからこそ、心配をかけたくない気持ちも出てくると思います。",
      "今の相談は、誰に、何を、どの順番で伝えるかを整理したい内容に見えます。",
      "まず伝えたい相手は、配偶者、親、子ども、きょうだい、その他のどなたですか？",
      "相手によって伝える量や順番が変わるため、最初に相手を確認します。"
    ],
    "気持ちのつらさ": [
      "不安やつらさが強くなっていて、ひとりで抱えにくい状況なのですね。",
      "はっきりしない不安が続く時間は、とても消耗しやすいと思います。",
      "今の相談は、気持ちのつらさを受け止めつつ、医療者や相談先に伝える言葉を探す内容に見えます。",
      "その不安は、症状、検査結果、次の診察、過去の経験のどれと関係していそうですか？",
      "不安のきっかけを分けると、医療者に確認することと相談先につなぐことを整理できます。"
    ],
    "セカンドオピニオン": [
      "セカンドオピニオンを考えながら、主治医へどう伝えるか迷っているのですね。",
      "今の医療者との関係を大切にしたい気持ちがあると、言い出しにくく感じやすいと思います。",
      "今の相談は、治療を決める前に、確認したい目的、必要な資料、伝え方を整理する内容に見えます。",
      "まず確認したいのは、他の治療選択肢、説明の理解、治療方針への納得感のどれですか？",
      "目的を短くすると、主治医に資料の依頼をしやすくなります。"
    ],
    "緩和ケア": [
      "緩和ケアという言葉を聞いて、不安や怖さが強くなっているのですね。",
      "知らない言葉を突然聞くと、治療や今後のことまで悪い方向に結びついてしまうことがあります。",
      "今の相談は、緩和ケアの目的や、どんなつらさを相談できるのかを説明してもらうための内容に見えます。",
      "まず聞きたいのは、緩和ケアの目的、相談できる症状、今の治療との関係のどれですか？",
      "言葉の意味を確認すると、怖さだけで受け止めずに相談しやすくなります。"
    ],
    "伝え方・聞き方": [
      "説明を聞いた後で分からない点が残り、聞き直し方に迷っているのですね。",
      "診察中は分かったつもりでも、家に帰ってから疑問が出ることは珍しくありません。",
      "今の相談は、理解できていない点を責めるのではなく、もう一度説明してもらうための準備に見えます。",
      "まず分けたいのは、病気の説明、検査、治療、薬、副作用、今後の予定のどれですか？",
      "聞き直したい点を1つずつ書くと、短い診察時間でも伝えやすくなります。"
    ]
  };
  const fallback = [`${topic}について、何から整理すればよいか迷っているのですね。`, "まだ言葉にならない部分があっても、少しずつ分けて整理できます。", "今の相談は、次に誰へ何を確認するかを整理する内容に見えます。", "今いちばん整理したいのは、治療、症状、お金、家族、仕事、気持ちのどれに近いですか？", "相談の入口を分けると、主治医に聞くことと相談支援センターに聞くことを分けられます。"];
  const [heard, feeling, rephrase, next, reason] = maps[domain] ?? fallback;
  return { domains: domainsFor(note), heard, feeling, rephrase, next, reason, safety: safetyNotice(note), critical: containsSelfHarm(noteText(note)) || containsUrgent(noteText(note)) };
}

function doctorQuestions(note) {
  const domain = primaryDomain(note);
  const sets = {
    "見た目の変化": ["治療に伴う髪、眉、肌、爪、体型、服装などの変化について相談できますか？", "帽子、ウィッグ、眉メイク、スキンケアなどを準備する時期や注意点はありますか？", "実際にどの変化が起きるかは、治療内容ごとにどのように確認すればよいですか？"],
    "症状・副作用": ["この症状を、副作用の可能性も含めてどのように伝えればよいですか？", "どの程度の症状が出たら病院へ連絡すべきですか？", "日常生活で気をつけることはありますか？"],
    "治療選択": ["治療の目的、期待できる効果、起こり得る副作用をもう一度確認できますか？", "他の選択肢がある場合、それぞれの違いは何ですか？", "説明で分からなくなった点を、次回もう一度聞き直してもよいですか？"],
    "セカンドオピニオン": ["セカンドオピニオンで確認したい目的を、どのように伝えればよいですか？", "紹介状や検査結果など、必要な資料は何ですか？", "セカンドオピニオン後に、結果を主治医へ共有する方法はありますか？"],
    "緩和ケア": ["緩和ケアでは、今のつらさや生活上の困りごとを相談できますか？", "現在の治療と緩和ケアは、どのような関係になりますか？", "痛み、不眠、不安などを相談する時、どの窓口へ連絡すればよいですか？"],
    "伝え方・聞き方": ["前回の説明で分からなくなった点を、もう一度聞き直してもよいですか？", "病気、検査、治療、薬、副作用、今後の予定を順番に確認できますか？", "家に帰ってから疑問が出た時、どこへ連絡すればよいですか？"]
  };
  return sets[domain] ?? ["治療スケジュールや体調面で、生活上配慮した方がよいことはありますか？", "病院内で相談できる窓口はありますか？", "相談支援センターに共有してよい情報はどこまでですか？"];
}

function supportCenterQuestions(note) {
  const domain = primaryDomain(note);
  const sets = {
    "見た目の変化": ["見た目の変化への不安や準備について相談できますか？", "帽子、ウィッグ、眉メイク、職場や家族への伝え方、助成制度を一緒に整理できますか？"],
    "医療費・制度": ["利用できる医療費支援制度はありますか？", "収入、休職、職場復帰について相談できる制度や窓口はありますか？", "申請先や必要書類を確認できますか？"],
    "仕事・学校": ["治療と仕事・学校を両立するために相談できる制度はありますか？", "職場や学校に伝える内容を一緒に整理できますか？"],
    "家族・人間関係": ["家族へどのように伝えるか相談できますか？", "付き添い者が相談できる窓口はありますか？"],
    "気持ちのつらさ": ["気持ちのつらさを相談できる院内外の窓口はありますか？", "緊急時に頼れる連絡先を整理できますか？"],
    "セカンドオピニオン": ["セカンドオピニオンの目的、流れ、必要な資料を一緒に整理できますか？", "主治医への伝え方や、相談後の戻り方について確認できますか？"],
    "緩和ケア": ["緩和ケアについて、言葉の意味や相談できる内容を一緒に整理できますか？", "つらさを和らげるために、院内で相談できる窓口はありますか？"],
    "伝え方・聞き方": ["診察で聞き直したいことを、短い質問に整理できますか？", "説明が分からない時に使える相談先や、次に確認する順番を一緒に考えられますか？"]
  };
  return sets[domain] ?? ["相談内容を整理するために、どの情報を持参するとよいですか？", "公的な情報源や制度を一緒に確認できますか？"];
}

function preVisitChecklist(note) {
  const items = ["いちばん伝えたいことを1つ選ぶ。", "短く伝える文を診察前に見返す。", "診断・治療・薬・緊急性はアプリでは決めず、医療者に確認する。"];
  if (note.nextDate) items.splice(1, 0, `${note.nextDate}の前に、このメモと質問リストを見返す。`);
  return items;
}

function summarizeMoyamoya(note) {
  const reply = supportReply(note);
  const domains = reply.domains.join("、");
  const concern = compactText(note.body || note.title || labelFor(categories, note.category), 86);
  const context = compactText(note.personContext || "保ちたい暮らしや避けたいことは、まだこれから言葉にできます。", 70);
  return [
    `今のモヤモヤは「${concern}」という形で出ています。`,
    `主なテーマは、${domains}に近い内容です。`,
    `治療と暮らしのデザインとして、${context}`,
    `次は「${reply.next}」を確認すると、相談につなげやすくなります。`
  ];
}

function compactText(text, maxLength) {
  const normalized = String(text || "")
    .replace(/\s+/g, " ")
    .trim();
  if (normalized.length <= maxLength) return normalized;
  return `${normalized.slice(0, maxLength)}…`;
}

function rolePrefix(role) {
  if (role === "family") return "家族として、本人の気持ちを尊重しながら、";
  if (role === "companion") return "付き添い者として、本人が確認したいことを支えながら、";
  if (role === "supporter") return "支える人として、本人の意思決定を代わりに行わない形で、";
  return "";
}

function briefMessage(note) {
  const reply = supportReply(note);
  const concern = (note.body || labelFor(categories, note.category)).slice(0, 70);
  const prefix = rolePrefix(note.role);
  if (["physician", "nurse"].includes(note.recipient)) return `${prefix}今日は「${concern}」について相談したいです。特に、${reply.next} また、どの状態なら病院へ連絡すべきか確認したいです。`;
  if (note.recipient === "consultationCenter") return `${prefix}がんの治療や生活のことで「${concern}」が整理できずにいます。医師に聞くこと、使える制度や相談先、家族や職場への伝え方を一緒に整理したいです。`;
  if (note.recipient === "family") return `がんのことで「${concern}」が気になっています。すぐ答えを出したいというより、今困っていることと病院で確認することを一緒に整理したいです。`;
  if (note.recipient === "workplace") return "治療に伴い、勤務や休み方について相談したいです。現時点で確定していることと、まだ主治医に確認が必要なことを分けてお伝えしたいです。";
  return `「${concern}」について、誰に何を相談すればよいか整理したいです。まず確認したいことは、${reply.next}`;
}

function render() {
  document.querySelector("#app").innerHTML = state.accepted ? shell() : consentScreen();
  bindEvents();
  if (state.shouldFocusMain) {
    focusMainContent();
    state.shouldFocusMain = false;
  }
}

function focusMainContent() {
  const main = document.querySelector("#main-content");
  if (!main) return;
  try {
    main.focus({ preventScroll: true });
  } catch {
    main.focus();
  }
}

function shell() {
  return `
    <div class="app-shell">
      <a class="skip-link" href="#main-content">本文へ移動</a>
      <header class="topbar">
        <img class="logo" src="./assets/app-icon-180.png" alt="">
        <div class="brand">
          <h1 class="brand-title">がん相談サポート Web</h1>
          <p class="brand-subtitle">診断・治療判断ではなく、相談内容を整理する支援ツール</p>
        </div>
      </header>
      <nav class="tabs" aria-label="主な画面">
        ${tabButton("home", "🏠", "ホーム")}
        ${tabButton("write", "✍️", "書く")}
        ${tabButton("questions", "✅", "整理")}
        ${tabButton("info", "📘", "情報")}
        ${tabButton("settings", "⚙️", "設定")}
      </nav>
      <main class="main" id="main-content" tabindex="-1">${currentView()}</main>
    </div>
    ${state.selectedResource ? resourceDialog(state.selectedResource) : ""}
    ${state.feedbackOpen ? feedbackDialog() : ""}
  `;
}

function consentScreen() {
  return `
    <main class="main">
      <section class="hero">
        <img class="logo" src="./assets/app-icon-180.png" alt="">
        <h2>はじめる前に</h2>
        <p>このWeb版は、テスターがブラウザで相談メモの流れを確認するための試作です。相談内容はこのブラウザ内に保存され、外部サーバーには送信しません。</p>
      </section>
      <div class="notice danger"><span aria-hidden="true">⚠️</span><span><strong>テスト時の個人情報について</strong><br>個人名、病院名、主治医名、住所、電話番号、患者番号、詳しい診断情報など、個人が分かる情報は入力しないでください。感想フォームにも相談内容を貼り付けないでください。</span></div>
      <div class="notice"><span>🛡️</span><span><strong>このアプリの位置づけ</strong><br>がんに関する不安や疑問を整理し、医療者・がん相談支援センター等に相談しやすくするための支援ツールです。診断、治療方針、薬剤、緊急性の判断は行いません。</span></div>
      <section class="section">
        <h2>利用前の確認</h2>
        <ul class="list">
          <li>相談メモには病歴、治療、症状、家族や仕事の悩みなど要配慮情報が含まれる可能性があります。</li>
          <li>テストでは、実名、病院名、主治医名、患者番号、連絡先、詳しい診断情報を入力しないでください。</li>
          <li>このWeb版では相談メモをブラウザ内に保存し、外部サーバーには送信しません。</li>
          <li>「感想を送る」では、使いやすさへの感想だけを書き、相談メモ本文や個人が分かる情報は送らないでください。</li>
          <li>強い症状や危険を感じる時は、アプリで判断せず医療機関や救急へ連絡してください。</li>
        </ul>
        <div class="button-row">
          <button class="primary" data-accept>同意してはじめる</button>
        </div>
      </section>
    </main>
  `;
}

function tabButton(id, icon, label) {
  const isActive = state.tab === id;
  return `<button class="tab ${isActive ? "active" : ""}" data-tab="${id}" type="button" aria-current="${isActive ? "page" : "false"}"><span aria-hidden="true">${icon}</span><span>${label}</span></button>`;
}

function currentView() {
  if (state.tab === "write") return writeView();
  if (state.tab === "questions") return questionsView();
  if (state.tab === "info") return infoView();
  if (state.tab === "settings") return settingsView();
  return homeView();
}

function homeView() {
  const latest = state.notes[0];
  return `
    <div class="notice"><span>🛡️</span><span>治療法の推奨や症状の判定はせず、治療と暮らしを一緒に考えるための材料を整理します。</span></div>
    <section class="hero">
      <h2>治療と暮らしをデザインする</h2>
      <p>大切にしたい生活、避けたいこと、相談したいことを出し、必要な人へ伝わる形に整えます。</p>
    </section>
    ${state.notes.length === 0 ? `
      <section class="section">
        <h2>はじめて使うなら</h2>
        ${step(1, "暮らしのゴールを出す", "大事にしていること、心地よい場所、好きな行動、そばにあると落ち着くものを書きます。")}
        ${step(2, "避けたいことも出す", "こうはなりたくない、ここは譲りたくない、というアンチパターンも大事な材料です。")}
        ${step(3, "あとで相談用に整える", "保存後に、治療と暮らしの要約、主治医や相談支援センターへの質問へ変えます。")}
      </section>
    ` : ""}
    <section class="section">
      <h2>次にやること</h2>
      ${action("write", "✍️", "治療と暮らしを書き出す", "大事なこと、避けたいこと、心地よい瞬間、モヤモヤを残す")}
      ${action("questions", "✅", "聞くことを確認する", "主治医・相談員向けの質問案を見る")}
      ${action("info", "📘", "困りごと別に情報を見る", "要点を読んでから公式情報へ進む")}
      <button class="action-row" type="button" data-tab="info" data-focus-urgent><span class="icon" aria-hidden="true">⚠️</span><span><span class="row-title">急ぐ時の連絡先を確認</span><span class="row-subtitle">強い症状や危険を感じる時</span></span></button>
      <button class="action-row" type="button" data-open-feedback><span class="icon" aria-hidden="true">💬</span><span><span class="row-title">使ってみた感想を送る</span><span class="row-subtitle">迷ったところ、良かったところ、改善したいところ</span></span></button>
    </section>
    <section class="section">
      <h2>最近の相談メモ</h2>
      ${latest ? noteList(state.notes.slice(0, 3)) : `<div class="empty">まだ相談メモがありません。まずは「治療と暮らしを書き出す」から始めてください。</div>`}
    </section>
  `;
}

function action(tab, icon, title, subtitle) {
  return `<button class="action-row" type="button" data-tab="${tab}"><span class="icon" aria-hidden="true">${icon}</span><span><span class="row-title">${h(title)}</span><span class="row-subtitle">${h(subtitle)}</span></span></button>`;
}

function step(number, title, detail) {
  return `<div class="reply-line"><span class="pill">${number}</span><span><span class="reply-title">${h(title)}</span><span class="reply-text">${h(detail)}</span></span></div>`;
}

function writeView() {
  const draft = loadDraft();
  return `
    <div class="notice"><span>🛡️</span><span>診断・治療判断ではなく、相談先に伝えるためのメモを作ります。</span></div>
    <form class="section form-grid" data-note-form>
      <h2>まず、ここに出す</h2>
      <p class="section-lead" id="body-help">順番も、言葉づかいも、きれいに整えなくて大丈夫です。整理は保存したあとに行います。スマホのキーボードのマイクで、頭に浮かんだ言葉をそのまま音声入力しても構いません。</p>
      <div class="notice status-notice"><span aria-hidden="true">💾</span><span>入力中の内容は、このブラウザ内に下書きとして残ります。保存前に別画面へ移動しても戻れます。</span></div>
      <div class="notice danger"><span aria-hidden="true">⚠️</span><span>テストでは、個人名、病院名、主治医名、患者番号、住所、電話番号などは書かないでください。実際の相談に近い内容は、個人が分からない形に言い換えてください。</span></div>
      <label>頭にあること
        <span class="hint">短くても、途中で止まっても、同じことを何度書いても大丈夫です。</span>
        <textarea class="free-output" name="body" required aria-describedby="body-help" placeholder="例: 何が不安なのか自分でも分からない。治療の話を聞いたけど家に帰ったら怖くなった。仕事のことも家族のことも一緒に考えると苦しい。">${h(draft.body || "")}</textarea>
      </label>
      <div class="prompt-panel" aria-label="書き出しのきっかけ">
        <p>書き出しに迷う時は、近いものを押してください。</p>
        <div class="prompt-grid">
          ${promptChip("治療を受けながら保ちたい暮らしは、")}
          ${promptChip("こうはなりたくないと思うことは、")}
          ${promptChip("ここだけは譲りたくないことは、")}
          ${promptChip("今いちばん怖いのは、")}
          ${promptChip("本当は聞きたいけれど言いにくいのは、")}
          ${promptChip("家族や職場に伝えるのが不安なのは、")}
          ${promptChip("私が大事にしていることは、")}
          ${promptChip("心地よいと感じる場所や瞬間は、")}
          ${promptChip("落ち着く行動やそばにあると安心するものは、")}
          ${promptChip("自分らしく過ごすために大切にしたいのは、")}
          ${promptChip("体や見た目の変化で気になっているのは、")}
          ${promptChip("お金、仕事、学校、職場復帰で心配なのは、")}
        </div>
      </div>
      <label>治療と暮らしのデザイン
        <span class="hint" id="person-context-help">大事にしていること、保ちたい暮らし、心地よい場所や瞬間、避けたいことを書いてください。治療だけでなく、その人らしさが相談の大切な情報になります。</span>
        <textarea name="personContext" aria-describedby="person-context-help" placeholder="例: 朝の散歩が好き。家族と食卓を囲む時間が大事。仕事を続けたい。人前で急に説明を求められるのは避けたい。">${h(draft.personContext || "")}</textarea>
      </label>
      <details class="optional-details">
        <summary>あとで整理しやすくする項目</summary>
        <div class="optional-fields">
          <label>見出し
            <input name="title" autocomplete="off" value="${h(draft.title || "")}" placeholder="例: お金・仕事が心配">
          </label>
      <div class="grid two">
        <label>カテゴリ
          <select name="category">${categories.map(([id, label]) => `<option value="${id}" ${draft.category === id ? "selected" : ""}>${h(label)}</option>`).join("")}</select>
        </label>
        <label>誰のことで相談しますか
          <select name="role">${roles.map(([id, label]) => `<option value="${id}" ${draft.role === id ? "selected" : ""}>${h(label)}</option>`).join("")}</select>
        </label>
        <label>誰に伝えたいですか
          <select name="recipient">${recipients.map(([id, label]) => `<option value="${id}" ${draft.recipient === id ? "selected" : ""}>${h(label)}</option>`).join("")}</select>
        </label>
        <label>次回診察・相談予定日
          <input name="nextDate" type="date" value="${h(draft.nextDate || "")}">
        </label>
      </div>
      <label>任意情報
        <input name="diagnosis" autocomplete="off" value="${h(draft.diagnosis || "")}" placeholder="診断名・がん種など。分からなければ空欄で構いません">
      </label>
        </div>
      </details>
      <div class="button-row">
        <button class="primary" type="submit">保存して整理する</button>
        <button class="secondary" type="button" data-clear-form>入力を消す</button>
      </div>
    </form>
    <section class="section">
      <h2>よくある相談から選ぶ</h2>
      <div class="template-list">
        ${templates.map((template) => `<button class="action-row" type="button" data-template="${template.id}"><span class="icon" aria-hidden="true">${template.icon}</span><span><span class="row-title">${h(template.title)}</span><span class="row-subtitle">${h(template.subtitle)}</span></span></button>`).join("")}
      </div>
    </section>
  `;
}

function promptChip(text) {
  return `<button class="prompt-chip" type="button" data-prompt="${h(text)}">${h(text)}</button>`;
}

function questionsView() {
  if (!state.notes.length) {
    return `
      <div class="notice"><span>🛡️</span><span>相談メモを保存すると、主治医や相談支援センターに聞く質問案を作れます。</span></div>
      <section class="section">
        <h2>まだ相談メモがありません</h2>
        <p class="section-lead">まずは短い一文だけで構いません。スマホなら音声入力でも始められます。</p>
        ${action("write", "✍️", "相談メモを書く", "頭にあることをそのまま残す")}
      </section>
    `;
  }
  const latest = state.notes[0];
  const reply = supportReply(latest);
  return `
    <section class="section">
      <h2>まず見る</h2>
      ${reply.safety ? `<div class="notice ${reply.critical ? "danger" : ""}"><span>⚠️</span><span>${h(reply.safety)}</span></div>` : ""}
      <h3>モヤモヤの要約</h3>
      ${list(summarizeMoyamoya(latest))}
      ${replyLine("💬", "まず伝える文", briefMessage(latest))}
      ${replyLine("🩺", "主治医に聞くこと", doctorQuestions(latest)[0])}
      ${replyLine("👥", "相談支援センターに聞くこと", supportCenterQuestions(latest)[0])}
    </section>
    <section class="section">
      <h2>次の順番</h2>
      ${step(1, "まず伝える文を読む", "診察や相談の最初に、この一文を見せる・読むことを想定します。")}
      ${step(2, "聞くことを1つ選ぶ", "全部聞こうとせず、今日いちばん大事な質問を1つ選びます。")}
      ${step(3, "必要ならコピーする", "家族、相談員、診察メモへ貼り付けられる形にします。")}
      <div class="button-row">
        <button class="primary" type="button" data-copy-all>相談メモと質問をコピー</button>
        <button class="secondary" type="button" data-tab="info">困りごと別の情報を見る</button>
      </div>
    </section>
    <section class="section">
      <h2>メモ別の整理</h2>
      ${state.notes.map((note) => fullQuestionCard(note)).join("")}
    </section>
    <section class="section">
      <h2>共有</h2>
      <p class="section-lead">テキストとしてコピーできます。写真やPDFにする場合は、共有先の機能で保存してください。</p>
      <div class="button-row">
        <button class="secondary" type="button" data-copy-all>もう一度コピーする</button>
      </div>
    </section>
  `;
}

function fullQuestionCard(note) {
  const reply = supportReply(note);
  return `
    <article class="note-card">
      <h3>${h(note.title || labelFor(categories, note.category))}</h3>
      <div class="meta">${reply.domains.map((domain) => `<span class="pill">${h(domain)}</span>`).join("")}</div>
      ${replyLine("👂", "受け止め", reply.heard)}
      ${replyLine("🫶", "気持ち", reply.feeling)}
      ${replyLine("❓", "次に聞きたいこと", reply.next)}
      <h3>モヤモヤの要約</h3>
      ${list(summarizeMoyamoya(note))}
      <h3>診察前チェック</h3>
      ${list(preVisitChecklist(note))}
      <h3>主治医に聞くこと</h3>
      ${list(doctorQuestions(note))}
      <h3>相談支援センターに相談できること</h3>
      ${list(supportCenterQuestions(note))}
    </article>
  `;
}

function infoView() {
  const groups = ["まず整理する", "暮らし・制度", "からだ・生活の変化"];
  return `
    <section class="section">
      <h2>この画面の使い方</h2>
      ${step(1, "困りごとを選ぶ", "病名ではなく、今困っている場面から選べます。")}
      ${step(2, "要点を読む", "短い解説、聞くこと、次の行動だけを確認します。")}
      ${step(3, "必要なら公式情報へ", "同意してから外部サイトを開きます。")}
    </section>
    <section class="section">
      <h2>急ぐ時</h2>
      ${resourceButton(trustedResources.find((resourceItem) => resourceItem.group === "急ぐ時"))}
    </section>
    ${groups.map((group) => `
      <section class="resource-group">
        <h3>${h(group)}</h3>
        <p>${h(groupDescription(group))}</p>
        <div class="grid two">${trustedResources.filter((resourceItem) => resourceItem.group === group).map(resourceButton).join("")}</div>
      </section>
    `).join("")}
  `;
}

function groupDescription(group) {
  if (group === "まず整理する") return "調べる前に、何を相談したいかを分けます。";
  if (group === "暮らし・制度") return "お金、仕事、家族など生活に関わる心配を整理します。";
  return "見た目、若い世代の悩み、将来のことを分けます。";
}

function resourceButton(item) {
  return `<button class="action-row" type="button" data-resource="${item.id}"><span class="icon" aria-hidden="true">${item.icon}</span><span><span class="row-title">${h(item.title)}</span><span class="row-subtitle">${h(item.subtitle)}</span></span></button>`;
}

function resourceDialog(item) {
  return `
    <div class="dialog-backdrop" data-close-dialog>
      <section class="dialog" role="dialog" aria-modal="true" aria-labelledby="resource-title" tabindex="-1">
        <h2 id="resource-title">${h(item.icon)} ${h(item.title)}</h2>
        <p class="section-lead">${h(item.overview)}</p>
        <h3>こういう時に使う</h3>${list(item.useWhen)}
        <h3>相談時に聞くこと</h3>${list(item.questions)}
        <h3>次の行動</h3>${list(item.actions)}
        <div class="notice"><span>🔗</span><span>公式情報は外部サイトで開きます。必要な時だけ確認してください。</span></div>
        <div class="button-row">
          <a class="primary" href="${h(item.url)}" target="_blank" rel="noopener">はい、公式情報を開く</a>
          <button class="secondary" type="button" data-close-dialog>今は開かない</button>
        </div>
      </section>
    </div>
  `;
}

function feedbackDialog() {
  return `
    <div class="dialog-backdrop" data-close-feedback>
      <section class="dialog" role="dialog" aria-modal="true" aria-labelledby="feedback-title" tabindex="-1">
        <h2 id="feedback-title">使ってみた感想</h2>
        <p class="section-lead">テスターの感想は、次の改善に直接使います。個人名、病院名、主治医名、連絡先、詳しい診断情報、相談メモ本文は書かないでください。</p>
        <div class="notice danger"><span aria-hidden="true">⚠️</span><span>感想フォームには「使いにくかった場所」「分かりにくかった言葉」「改善してほしい点」だけを書いてください。病状や実在する人・病院が分かる情報は送らないでください。</span></div>
        <form class="form-grid" data-feedback-form>
          <label>使った人に近いもの
            <select name="testerRole">
              <option>患者本人</option>
              <option>家族・付き添い者</option>
              <option>医療・相談支援に関わる人</option>
              <option>その他</option>
            </select>
          </label>
          <label>迷ったところ
            <textarea name="confusing" placeholder="例: どこから書けばいいか少し迷った"></textarea>
          </label>
          <label>良かったところ
            <textarea name="good" placeholder="例: 相談支援センターに聞くことが見えてよかった"></textarea>
          </label>
          <label>改善してほしいところ
            <textarea name="improve" placeholder="例: 文字をもう少し短くしてほしい"></textarea>
          </label>
          <div class="button-row">
            <button class="primary" type="submit">感想をコピー</button>
            ${FEEDBACK_FORM_URL ? `<a class="secondary" href="${h(FEEDBACK_FORM_URL)}" target="_blank" rel="noopener">送信フォームを開く</a>` : `<button class="secondary" type="button" data-copy-feedback-template>空の感想テンプレートをコピー</button>`}
            <button class="secondary" type="button" data-close-feedback>閉じる</button>
          </div>
          ${FEEDBACK_FORM_URL ? "" : `<p class="hint">公開時にGoogleフォーム等のURLを設定すると、ここから直接送信フォームを開けます。</p>`}
        </form>
      </section>
    </div>
  `;
}

function feedbackTextFromForm(form) {
  const data = new FormData(form);
  return [
    "がん相談サポート Web テスト感想",
    "個人名、病院名、詳しい診断情報、相談メモ本文は含めない前提の感想です。",
    "",
    `使った人に近いもの: ${data.get("testerRole") || ""}`,
    "",
    "迷ったところ:",
    data.get("confusing") || "",
    "",
    "良かったところ:",
    data.get("good") || "",
    "",
    "改善してほしいところ:",
    data.get("improve") || ""
  ].join("\n");
}

function settingsView() {
  return `
    <section class="section">
      <h2>テスト協力</h2>
      <p class="section-lead">使ってみて迷ったところ、分かりにくかった言葉、安心したところを教えてください。</p>
      <div class="button-row">
        <button class="secondary" type="button" data-open-feedback>感想を送る</button>
      </div>
    </section>
    <section class="section">
      <h2>安全・プライバシー</h2>
      <ul class="list">
        <li>相談メモはこのブラウザ内に保存します。</li>
        <li>外部サーバー、AIサービス、広告、分析基盤へ相談内容を送信しません。</li>
        <li>テストでは、個人名、病院名、主治医名、患者番号、住所、電話番号、詳しい診断情報は入力しないでください。</li>
        <li>感想フォームには、相談メモ本文や個人が分かる情報を送らないでください。</li>
      </ul>
    </section>
    <section class="section">
      <h2>データ</h2>
      <p class="section-lead">このWeb版の保存データと下書きは、使っているブラウザの中だけにあります。共用端末で使った場合は、最後に削除してください。</p>
      <div class="button-row">
        <button class="secondary" type="button" data-export-json>テストデータを書き出す</button>
        <button class="danger-button" type="button" data-delete-all>保存データと下書きをすべて削除</button>
      </div>
    </section>
    <section class="section">
      <h2>緊急時</h2>
      <div class="notice danger"><span>⚠️</span><span>急な強い症状、息苦しさ、強い痛み、意識がもうろうとする、危険を感じる場合は、アプリ内で判断せず、医療機関や救急に連絡してください。</span></div>
    </section>
  `;
}

function noteList(notes) {
  return `<div class="note-list">${notes.map((note) => `
    <article class="note-card">
      <h3>${h(note.title || labelFor(categories, note.category))}</h3>
      <div class="meta">
        <span class="pill">${categoryIcon(note.category)} ${h(labelFor(categories, note.category))}</span>
        <span class="pill">保存日: ${h(formatDate(note.createdAt))}</span>
        <span class="pill">${h(labelFor(recipients, note.recipient))}</span>
      </div>
      <p>${h(note.body).slice(0, 140)}</p>
      <div class="button-row">
        <button class="secondary" type="button" data-use-note="${note.id}">整理を見る</button>
        <button class="danger-button" type="button" data-delete-note="${note.id}" aria-label="${h(note.title || labelFor(categories, note.category))}を削除">削除</button>
      </div>
    </article>
  `).join("")}</div>`;
}

function formatDate(value) {
  return new Intl.DateTimeFormat("ja-JP", { dateStyle: "medium", timeStyle: "short" }).format(new Date(value));
}

function replyLine(icon, title, text) {
  return `<div class="reply-line"><span class="icon">${icon}</span><span><span class="reply-title">${h(title)}</span><span class="reply-text">${h(text)}</span></span></div>`;
}

function list(items) {
  return `<ul class="list">${items.map((item) => `<li>${h(item)}</li>`).join("")}</ul>`;
}

function textExport() {
  return state.notes.map((note) => {
    return [
      "がん相談サポート Web 相談メモ",
      "診断、治療方針、薬剤、緊急性の判断を行うものではありません。",
      "",
      `見出し: ${note.title || labelFor(categories, note.category)}`,
      `保存日: ${formatDate(note.createdAt)}`,
      `カテゴリ: ${labelFor(categories, note.category)}`,
      `誰のことで相談: ${labelFor(roles, note.role)}`,
      `伝える相手: ${labelFor(recipients, note.recipient)}`,
      "",
      "相談したいこと:",
      note.body,
      note.personContext ? `\nその人らしさ・大切にしたいこと:\n${note.personContext}` : "",
      "",
      "モヤモヤの要約:",
      ...summarizeMoyamoya(note).map((item) => `- ${item}`),
      "",
      "短く伝える文:",
      briefMessage(note),
      "",
      "主治医に聞くこと:",
      ...doctorQuestions(note).map((question) => `- ${question}`),
      "",
      "相談支援センターで整理できること:",
      ...supportCenterQuestions(note).map((question) => `- ${question}`)
    ].filter(Boolean).join("\n");
  }).join("\n\n---\n\n");
}

function bindEvents() {
  document.querySelector("[data-accept]")?.addEventListener("click", () => {
    localStorage.setItem(CONSENT_KEY, "yes");
    state.accepted = true;
    render();
  });

  document.querySelectorAll("[data-tab]").forEach((button) => {
    button.addEventListener("click", () => {
      state.tab = button.dataset.tab;
      state.selectedResource = null;
      state.shouldFocusMain = true;
      render();
    });
  });

  document.querySelector("[data-note-form]")?.addEventListener("submit", (event) => {
    event.preventDefault();
    const form = event.currentTarget;
    const data = new FormData(form);
    const body = String(data.get("body") || "").trim();
    if (!body) return;
    state.notes.unshift({
      id: crypto.randomUUID(),
      title: String(data.get("title") || "").trim(),
      body,
      personContext: String(data.get("personContext") || "").trim(),
      category: String(data.get("category") || "treatment"),
      role: String(data.get("role") || "patient"),
      recipient: String(data.get("recipient") || "physician"),
      diagnosis: String(data.get("diagnosis") || "").trim(),
      nextDate: String(data.get("nextDate") || ""),
      createdAt: new Date().toISOString()
    });
    saveNotes();
    clearDraft();
    state.tab = "questions";
    state.shouldFocusMain = true;
    render();
  });

  document.querySelector("[data-note-form]")?.addEventListener("input", (event) => {
    saveDraft(event.currentTarget);
  });

  document.querySelector("[data-clear-form]")?.addEventListener("click", () => {
    document.querySelector("[data-note-form]")?.reset();
    clearDraft();
  });

  document.querySelectorAll("[data-template]").forEach((button) => {
    button.addEventListener("click", () => {
      const template = templates.find((item) => item.id === button.dataset.template);
      const form = document.querySelector("[data-note-form]");
      if (!template || !form) return;
      form.title.value = template.title;
      form.body.value = template.body;
      form.category.value = template.category;
      form.role.value = template.role;
      form.recipient.value = template.recipient;
      saveDraft(form);
      form.body.focus();
    });
  });

  document.querySelectorAll("[data-prompt]").forEach((button) => {
    button.addEventListener("click", () => {
      const form = document.querySelector("[data-note-form]");
      if (!form) return;
      const textarea = form.body;
      const prompt = button.dataset.prompt || "";
      const prefix = textarea.value.trim() ? "\n" : "";
      textarea.value = `${textarea.value}${prefix}${prompt}`;
      saveDraft(form);
      textarea.focus();
      textarea.setSelectionRange(textarea.value.length, textarea.value.length);
    });
  });

  document.querySelectorAll("[data-use-note]").forEach((button) => {
    button.addEventListener("click", () => {
      const index = state.notes.findIndex((note) => note.id === button.dataset.useNote);
      if (index > 0) {
        const [note] = state.notes.splice(index, 1);
        state.notes.unshift(note);
        saveNotes();
      }
      state.tab = "questions";
      state.shouldFocusMain = true;
      render();
    });
  });

  document.querySelectorAll("[data-delete-note]").forEach((button) => {
    button.addEventListener("click", () => {
      if (!confirm("この相談メモを削除しますか。")) return;
      state.notes = state.notes.filter((note) => note.id !== button.dataset.deleteNote);
      saveNotes();
      render();
    });
  });

  document.querySelectorAll("[data-copy-all]").forEach((button) => {
    button.addEventListener("click", async () => {
      await navigator.clipboard.writeText(textExport());
      alert("相談メモと質問リストをコピーしました。");
    });
  });

  document.querySelectorAll("[data-resource]").forEach((button) => {
    button.addEventListener("click", () => {
      state.selectedResource = trustedResources.find((item) => item.id === button.dataset.resource);
      render();
      document.querySelector(".dialog")?.focus?.();
    });
  });

  document.querySelectorAll("[data-close-dialog]").forEach((element) => {
    element.addEventListener("click", (event) => {
      if (event.target !== element && !event.target.matches("[data-close-dialog]")) return;
      state.selectedResource = null;
      render();
    });
  });

  document.querySelectorAll("[data-open-feedback]").forEach((button) => {
    button.addEventListener("click", () => {
      state.feedbackOpen = true;
      render();
      document.querySelector(".dialog")?.focus?.();
    });
  });

  document.querySelectorAll("[data-close-feedback]").forEach((element) => {
    element.addEventListener("click", (event) => {
      if (event.target !== element && !event.target.matches("[data-close-feedback]")) return;
      state.feedbackOpen = false;
      render();
    });
  });

  document.querySelector("[data-feedback-form]")?.addEventListener("submit", async (event) => {
    event.preventDefault();
    await navigator.clipboard.writeText(feedbackTextFromForm(event.currentTarget));
    alert("感想をコピーしました。送信フォームやメッセージに貼り付けてください。");
  });

  document.querySelector("[data-copy-feedback-template]")?.addEventListener("click", async () => {
    const text = [
      "がん相談サポート Web テスト感想",
      "個人名、病院名、詳しい診断情報、相談メモ本文は含めない前提の感想です。",
      "",
      "使った人に近いもの:",
      "",
      "迷ったところ:",
      "",
      "良かったところ:",
      "",
      "改善してほしいところ:"
    ].join("\n");
    await navigator.clipboard.writeText(text);
    alert("感想テンプレートをコピーしました。");
  });

  document.onkeydown = handleGlobalKeydown;

  document.querySelector("[data-delete-all]")?.addEventListener("click", () => {
    if (!confirm("このブラウザ内の相談履歴、下書き、同意状態をすべて削除しますか。")) return;
    deleteAllLocalData();
    render();
  });

  document.querySelector("[data-export-json]")?.addEventListener("click", () => {
    const blob = new Blob([JSON.stringify(state.notes, null, 2)], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = "gan-soudan-support-test-data.json";
    link.click();
    URL.revokeObjectURL(url);
  });
}

function handleGlobalKeydown(event) {
  if (event.key === "Escape" && state.selectedResource) {
    state.selectedResource = null;
    render();
  }
  if (event.key === "Escape" && state.feedbackOpen) {
    state.feedbackOpen = false;
    render();
  }
}

if ("serviceWorker" in navigator && location.protocol !== "file:") {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("./sw.js").catch(() => {
      // Service Worker is optional. The app remains usable without offline cache.
    });
  });
}

render();
