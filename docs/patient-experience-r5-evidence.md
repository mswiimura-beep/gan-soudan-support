# Patient Experience Survey R5 Evidence

## Source

- Official project page: `https://www.ncc.go.jp/jp/icc/policy-evaluation/project/010/2023/index.html`
- Full report used locally: `/private/tmp/R5_all.pdf`
- C questionnaire result used locally: `/private/tmp/R5_C.pdf`
- Report title: `患者体験調査報告書 令和5年度調査（最終版）`
- Publisher: 国立がん研究センター, 厚生労働省委託事業, May 2025

The user-provided local Desktop paths were not found in this environment, so the PDFs were downloaded from the official National Cancer Center project page for review.

## Why This Matters For The App

This survey is the evidence layer for "what patients and families actually struggle with." The app should prioritize practical consultation preparation over medical explanation.

## Product-Relevant Findings

Use these as product design inputs, not as user-facing claims unless the source and date are shown.

### Consultation Access

- People who could consult someone about illness or療養生活: 60.6%.
- People who knew about cancer consultation support centers: 55.1%.
- Among people who knew the center, people who used it: 21.1%.
- Among users of the center, people who found it helpful: 72.4%.

Product implication:

- The app should repeatedly explain what the cancer consultation support center can handle.
- "相談したいことがない" or "何を相談する場かわからない" should be treated as design problems.

### Treatment Decision And Communication

- People who received information before deciding cancer treatment: 88.5%.
- People who received an explanation about second opinion: 31.7%.
- People who felt there was another medical staff member besides the physician who was easy to consult: 58.4%.
- People who felt medical staff listened and tried to understand: 90.3%.

Product implication:

- The app should help users prepare questions for physicians and non-physician staff separately.
- Second opinion should be visible as a normal consultation topic, not hidden under advanced settings.

### Side Effects, Symptoms, And Distress

- People who could consult medical staff quickly when they had physical distress: 65.1%.
- People who could consult medical staff quickly when they had emotional distress: 47.6%.
- People who felt pain related to cancer or treatment: 22.0%.
- People who felt bodily distress related to cancer or treatment: 34.0%.
- People who felt emotional distress related to cancer or treatment: 26.2%.
- People whose physical or emotional distress interfered with daily life: 24.3%.
- People who felt support to relieve physical or emotional distress was sufficient: 33.8%.

Product implication:

- "Body distress" and "emotional distress" should be separate domains.
- The app should ask whether the user can contact medical staff and help create a short message for them.
- Do not normalize symptoms or judge urgency. Convert symptoms into questions and contact thresholds.

### Money And Work

- People whose financial burden affected life: 24.2%.
- People who were working at diagnosis: 44.1%.
- Among those working at diagnosis, people who took leave: 53.4%.
- Among those working at diagnosis, people who resigned or closed business: 19.4%.
- People who received a conversation from medical staff about continuing work before treatment: 44.0%.

Product implication:

- Money and work cannot be secondary categories.
- The app should ask whether the concern is treatment cost, income loss, workplace explanation, or制度.
- Work continuation should be raised early, before treatment starts, when relevant.

### Family And Social Burden

- People who felt they were burdening family: 57.7%.
- People who felt they were burdening non-family people around them: 30.3%.
- People who felt unnecessary special treatment after diagnosis: 23.2%.
- People who felt prejudice from non-family people: 7.4%.

Product implication:

- Family communication should be a first-class domain.
- The app should avoid telling the user to "just ask family" and instead help decide who to tell, what to tell, and in what order.

### Younger Patients

The report notes that younger patients had higher burdens in several areas:

- Financial burden affecting life was higher among younger patients.
- Working at diagnosis was much more common among younger patients.
- Younger patients were less likely to feel they could quickly consult medical staff for emotional distress.

Product implication:

- AYA/younger adult flows should emphasize money, work/school, fertility, appearance, family explanation, and emotional support.

## App Changes This Evidence Supports

Already aligned:

- Support domains for symptoms, treatment choice, money, work, family, emotional distress, second opinion, palliative care, communication support.
- Reply flow that acknowledges, reflects, rephrases, confirms, and asks one minimum next question.
- Safety boundary against diagnosis, treatment judgment, medication, and urgency judgment.

Recommended next implementation:

1. Add AYA-specific optional prompts for fertility, school/work, appearance, and money.
2. Add a "before visit checklist" that confirms what the user wants to ask, what they want to show, and whether urgent contact is needed.
3. Add local fixture tests for support reply generation using `docs/faq-scenarios.md`.

Implemented in the MVP after reviewing this evidence:

- "伝える相手" selector for physician, nurse, consultation support center, family, workplace/school, or undecided.
- "医療者や周囲に短く伝える文" section.
- "相談先につなぐ" section explaining what can be discussed at a cancer consultation support center.
- PDF export now includes the recipient, short message, clinician questions, and consultation support center guide.
