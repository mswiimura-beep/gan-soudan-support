# Simulator QA Report

Date: 2026-06-30

Environment:

- Xcode: 26.6
- Runtime: iOS 26.5
- Simulator: iPhone 17
- Bundle ID: `jp.iimurakenji.GanSoudanSupport`
- Development Team: `9M837R3Y7K`

## Result

Simulator build, install, and launch succeeded.
After Xcode signing configuration, normal Simulator build and launch also succeeded without disabling code signing.

## Checked Flows

- First launch consent screen appears.
- Two consent switches can be enabled.
- Consent button moves to the home screen.
- Home screen displays the app positioning and main actions.
- Consultation template selection changes the category to `副作用・体調について`.
- Template fills the title and consultation body.
- Consultation memo can be saved.
- Save completion alert appears.
- Saved consultation memo appears on the home screen.
- Question list is generated from the saved memo.
- Tapping the saved memo from home opens the organized question list for that memo.
- Trusted information screen shows public and support links.
- Settings screen shows consent, privacy, app-position, review-state, TestFlight, and support entries.
- PDF export opens the iOS share sheet.
- External trusted-information link opens Safari.
- Emergency symptom wording appears for `胸痛`, `呼吸困難`, and `強い痛み` sample input.
- Self-harm wording appears for `死にたい` and `消えたい` sample input.
- Short-message copy action shows the copy-complete alert.
- Note edit screen opens from note detail.
- Single-note delete confirmation appears and deletion removes the note.
- All-history delete confirmation appears and deletion empties the home list.
- Toolbar save button works from the consultation editor.

## Evidence

- First launch screenshot was captured.
- Post-consent home screen was observed through runtime UI snapshot.
- Saved note appeared in home runtime UI snapshot.
- Static safety check passed.
- Release readiness check passed.
- Share sheet screenshot captured for generated PDF.
- Safari screenshot captured for `ganjoho.jp`.
- Five App Store screenshot drafts saved in `docs/app-store-screenshots/`.

## Implementation Fixes From QA

- Export now uses an explicit `UIActivityViewController` wrapper for PDF/text files.
- The consultation editor now has a top-right save/update toolbar button, because the bottom save row can sit too close to the tab bar on the tested Simulator.
- DEBUG-only safety QA seed notes can be launched with `--seed-safety-qa`; this is not included in Release/TestFlight behavior.

## Remaining QA

- Verify text export share sheet on Simulator or real device.
- Paste from clipboard into another app or field to verify exact copied content.
- Spot-check the remaining external links, not only the first `ganjoho.jp` link.
- Capture final App Store Connect screenshots at required device sizes after final visual review.
- Archive and upload from Xcode GUI after Apple Developer/App Store Connect setup.
