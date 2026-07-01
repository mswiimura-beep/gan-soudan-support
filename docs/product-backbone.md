# がん相談サポート MVP Product Backbone

## Source

- Primary reference: `/Users/iimurakenji/Desktop/青森県立中央病院/認定がん専門相談員/基礎3/がん専門相談員のための学習の手引き第４版.pdf`
- Communication reference: `/Users/iimurakenji/Desktop/青森県立中央病院/がん相談支援センター/良好な関係を築くためのコミュニケーション.pdf`
- Patient experience evidence: `docs/patient-experience-r5-evidence.md`
- Confirmed locally: 344 pages, image-based PDF, table of contents visible on pages 6-11.

This file is not a content extraction of the guide. It is the product interpretation layer for the iOS MVP. Do not copy long passages from the guide into the app. Use it to decide structure, safety boundaries, and consultation flow.

## Product Position

The app is a consultation-preparation tool, not a diagnosis or treatment app.

It should help patients, family members, and accompanying supporters:

- put worries into words
- identify what they want to ask
- separate medical, social, financial, work, family, and emotional concerns
- prepare for conversations with clinicians and cancer consultation support centers
- find reliable public or specialist information sources

It must not:

- infer a diagnosis
- recommend a treatment choice
- judge urgency inside the app
- adjust medication
- predict recurrence, prognosis, or survival
- replace cancer consultation support center staff or clinicians

The R5 patient experience survey evidence reinforces that the MVP should prioritize consultation access, symptom/distress communication, money/work concerns, family burden, and awareness of cancer consultation support centers.

## Backbone From The Guide

The guide's table of contents suggests the app should be organized around these pillars:

1. Cancer care and cancer policy context
2. Role and posture of cancer consultation support centers
3. Consultation support process
4. Communication in consultation scenes
5. Understanding the person, assessing needs, and supporting next steps
6. Health literacy and information support
7. Collaboration with other departments and community resources
8. Situation-specific support such as treatment selection, social resources, employment, life stage, prevention/screening, genomics, appearance care, rare cancers, hereditary tumors, sexuality/fertility, and communication accommodations
9. Quality management and service design

## MVP Translation

The first iOS version should reflect the guide as workflow, not as a medical encyclopedia.

### Current MVP Screens

- Home
- Write consultation note
- Question list
- Trusted information
- Settings, consent, deletion, emergency guide

### Next Product Shape

The consultation note should evolve from a plain text memo into a structured assessment:

- What happened or what is worrying?
- Who is affected: patient, family, supporter, child, AYA, older adult, worker, caregiver?
- Which domain is involved: treatment, symptoms, money, work, family, emotions, life, information, access, communication?
- What has already been explained by clinicians?
- What does the user want to decide, ask, or prepare?
- Who is the right next contact: attending physician, nurse, pharmacist, social worker, consultation support center, workplace, school, municipality, emergency care?

## Consultation Flow Rule

Use this order when building AI or rule-based assistance:

1. Acknowledge the user's concern without diagnosing.
2. Classify the concern into a support domain.
3. Ask for missing context only when it changes the next question list.
4. Generate questions for clinicians and consultation support center staff.
5. Show reliable information sources when appropriate.
6. State the safety boundary if the user asks for diagnosis, treatment judgment, medication, emergency judgment, prognosis, or non-evidence-based therapy.
7. Route emergency or self-harm content outside the app.

For the detailed reply style, use `docs/communication-guidelines.md`. In particular, when more information is needed, the app should first receive the concern, reflect the feeling, rephrase in plain language, confirm understanding, and then ask one minimum next question.

## Question Generation Principle

Questions should be framed as confirmation questions, not advice.

Good:

- "この症状は治療の副作用として相談すべき内容ですか？"
- "どの程度の症状が出たら病院へ連絡すべきですか？"
- "利用できる制度や相談窓口はありますか？"
- "職場や家族に伝える内容を一緒に整理できますか？"

Avoid:

- "この症状は再発です"
- "この治療を選ぶべきです"
- "薬を減らしましょう"
- "救急に行かなくて大丈夫です"

## Domain Model To Add Next

Add a lightweight `ConsultationDomain` model before adding AI:

- treatmentSelection
- symptomsAndSideEffects
- medicalCostAndBenefits
- employmentAndSchool
- familyAndRelationships
- emotionalDistress
- secondOpinion
- palliativeCare
- socialResources
- healthLiteracy
- lifeStage
- communicationSupport
- emergencyOrSafety

Each domain should define:

- safe summary patterns
- doctor question templates
- consultation center question templates
- trusted resource links
- prohibited response patterns
- escalation wording

## Design Guardrails

- Store diagnosis, cancer type, stage, hospital name, and treatment history as optional fields.
- Keep the first version local-only unless there is a complete consent, deletion, logging, and security design.
- Do not add ranking, advertising, hospital comparison, treatment outcome claims, or free-clinic promotion.
- Do not present guide-derived content as independent medical advice.
- Add source and review metadata before publishing original medical information.

## Next Implementation Step

Improve the current fixed question templates into domain-specific templates based on the guide's consultation support structure.

Smallest useful code change:

1. Split `ConsultationCategory` from support-domain logic.
2. Add domain-specific question template data.
3. Add a simple classifier that maps note category and user wording to one or more domains.
4. Keep all generated output in the form of "questions to ask" and "points to organize".
