# App Store Readiness Notes

## Product Positioning

The first release should be submitted as a consultation-preparation and information-navigation app, not as a diagnosis, treatment, triage, or medication app.

Safe wording:

- 相談内容を整理する
- 主治医に聞く質問を作る
- がん相談支援センターに相談できることを整理する
- 公的・専門機関の情報への導線を示す

Avoid wording:

- 診断する
- 治療法を提案する
- 再発や余命を予測する
- 薬の量や中止を判断する
- 緊急性を判定する

## Required Before Public Release

- 正式なプライバシーポリシーURL
- 運営者名と問い合わせ先
- App Store説明文
- スクリーンショット
- アプリアイコン
- 実機または正常なSimulatorでの画面操作確認
- 医療安全・相談支援観点の文言レビュー
- データ削除導線の実機確認

## Current Data Handling

- Local-only storage
- No account
- No server sync
- No LLM calls
- No advertising or analytics SDK
- User-triggered PDF/text export only

## Suggested App Store Subtitle

がんの不安と質問を整理

## Suggested Short Description

がんに関する不安や疑問を、診察前や相談前に整理するための支援アプリです。診断や治療判断は行わず、主治医やがん相談支援センターに聞く質問、伝える内容、信頼できる情報への導線をまとめます。

## App Icon Draft

Draft icon PNGs are generated under:

`GanSoudanSupport/GanSoudanSupport/Assets.xcassets/AppIcon.appiconset`

The current local Xcode environment fails asset-catalog compilation because Simulator runtimes are unavailable. Keep the PNG assets, but register `Assets.xcassets` in the Xcode target Resources only after confirming `actool` works in a normal Xcode/Simulator environment.
