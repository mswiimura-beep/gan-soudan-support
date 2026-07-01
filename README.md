# がん相談サポートアプリ

がん患者さん、家族、付き添い者が、診察前や相談前に不安や疑問を整理するための相談支援アプリです。

このアプリは診断、治療方針、薬剤、緊急性の判断を行いません。相談メモ、質問リスト、信頼できる情報への導線、PDF・テキスト出力を中心にします。

設計思想は「治療と暮らしのデザイン」です。治療だけでなく、本人が大切にしたい暮らし、避けたいこと、相談のゴールを言葉にしてから、医療者やがん相談支援センターに伝える形へ整えます。

## Web版

テスターを増やすためのブラウザ版を `web/` に追加しています。ログインなしで開ける静的Webアプリで、相談メモはブラウザ内の `localStorage` に保存します。

```sh
cd web
python3 -m http.server 5173
```

ブラウザで `http://localhost:5173` を開きます。

Web版の簡易チェック:

```sh
node --check web/app.js
node web/check-web-app.mjs
```

現在の進捗と次にやることは `docs/current-status.md` に整理しています。

オープンベータ公開の手順は `web/open-beta-guide.md` です。GitHub認証で止まる場合は、Netlify Dropで `web/` の中身を公開する方法も使えます。

## Current Scope

- ローカル相談メモ保存
- 初回同意ゲート
- 相談カテゴリと伝える相手の選択
- 患者本人、家族、付き添い者など、誰のことで相談するかの選択
- よくある相談テンプレート
- 任意の次回診察・相談予定日
- 相談メモ一覧、検索、詳細表示、編集、1件削除
- 相談整理プレビュー
- 主治医・相談支援センター向け質問案
- 診察前チェックリスト
- 相談支援センター、AYA、家族向け情報などの信頼情報リンク
- PDF・テキスト出力
- 相談メモと短く伝える文のコピー
- 同意、端末内保存、履歴削除、プライバシー要点
- プライバシーポリシー案、アプリの位置づけ説明
- 緊急時・自傷表現の安全案内

## Build

```sh
xcodebuild -project GanSoudanSupport/GanSoudanSupport.xcodeproj \
  -scheme GanSoudanSupport \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath DerivedData \
  CODE_SIGNING_ALLOWED=NO build
```

## Scenario Check

```sh
python3 scripts/check_support_reply_scenarios.py
python3 scripts/release_readiness_check.py
```

## Product References

- `docs/product-backbone.md`
- `docs/treatment-life-design.md`
- `docs/communication-guidelines.md`
- `docs/patient-experience-r5-evidence.md`
- `docs/faq-scenarios.md`
- `docs/ai-consultation-guardrails.md`
- `docs/privacy-policy-draft.md`
- `docs/app-store-readiness.md`
- `docs/app-store-listing-draft.md`
- `docs/manual-qa-checklist.md`
- `docs/source-review-register.md`
- `docs/emergency-routing.md`
- `docs/testflight-checklist.md`
- `docs/screenshot-shotlist.md`
- `docs/app-store-screenshots/`
- `docs/app-privacy-label-draft.md`
- `docs/remaining-release-tasks.md`
- `docs/xcode-local-runbook.md`
- `docs/simulator-qa-report.md`
- `docs/current-status.md`

## iOS Source Layout

- `GanSoudanSupport/GanSoudanSupport/App.swift`: app entry, tabs, root consent gate routing
- `GanSoudanSupport/GanSoudanSupport/Models.swift`: notes, categories, roles, templates, store
- `GanSoudanSupport/GanSoudanSupport/Screens.swift`: app screens
- `GanSoudanSupport/GanSoudanSupport/SharedViews.swift`: reusable SwiftUI rows and cards
- `GanSoudanSupport/GanSoudanSupport/ConsultationAnalyzer.swift`: rule-based consultation organization
- `GanSoudanSupport/GanSoudanSupport/PDFExporter.swift`: consultation PDF generation
