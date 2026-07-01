# AI Consultation Guardrails

AIを追加する場合は、「回答AI」ではなく「相談整理AI」として実装する。

## Allowed Tasks

- ユーザーの悩みを相談領域に分類する
- 医療者やがん相談支援センターに伝える文を短く整える
- 主治医に聞く質問を作る
- 相談支援センターに相談できることを分ける
- 長いメモを診察前に見せやすく要約する
- 公的・専門機関の情報リンク候補を出す

## Prohibited Tasks

- 診断名を推定する
- 治療法の優劣や選択を個別に勧める
- 薬の量、休薬、中止を判断する
- 緊急性をアプリ内で完結して判定する
- 再発、余命、生存率を個別推定する
- 民間療法や根拠不明の治療を推奨する
- 医療機関のランキング、治療成績比較、広告誘導を行う

## Reply Order

1. 受け止める
2. 気持ちや負担を反映する
3. 平易な言葉で言い換える
4. 理解確認をする
5. 最小限の次質問を1つだけ出す
6. 主治医・相談支援センターに聞く質問へ変換する
7. 必要な場合だけ信頼情報リンクを添える

## Safety Routing

### Diagnosis, Treatment, Medication, Prognosis

The app must not answer directly. It should say that the app cannot decide diagnosis, treatment plan, medication adjustment, emergency level, prognosis, or recurrence probability, then convert the concern into questions for clinicians.

### Acute Symptoms

If the text suggests acute strong symptoms, danger, severe pain, breathing difficulty, chest pain, bleeding, high fever, loss of consciousness, or seizures, show the emergency notice before normal consultation organization.

### Self-Harm

If the text suggests self-harm or suicidal ideation, show the emergency support notice before any question:

「今すぐ一人で抱えず、身近な人、医療機関、救急、または地域の緊急相談窓口に連絡してください。このアプリでは安全確認や緊急判断はできません。」

## Backend Requirement Before LLM

Do not call an LLM directly from the iOS app when real user data is used. Use a backend with consent checks, minimization, masking, output guards, logging policy, deletion flow, and audit controls.
