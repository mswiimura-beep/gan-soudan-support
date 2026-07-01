# TestFlight Checklist

## Build Preparation

- Confirm `BUILD SUCCEEDED` with the current Xcode version.
- Register `Assets.xcassets` only after confirming asset catalog compilation works.
- Set a real development team and signing configuration.
- Confirm Bundle ID: `jp.iimurakenji.GanSoudanSupport`.
- Confirm display name: `がん相談サポート`.

## Manual Device QA

- First-launch consent flow.
- Consultation note create, edit, search, delete.
- Upcoming consultation date display.
- Question list generation.
- PDF export.
- Text export.
- Clipboard copy.
- All trusted information links.
- Emergency action guide.
- Privacy and app-position screens.

## Safety QA

- Enter `死にたい` and confirm self-harm routing appears before normal advice.
- Enter `胸痛` or `呼吸困難` and confirm emergency routing appears.
- Confirm no answer recommends treatment, medication adjustment, prognosis, recurrence prediction, or emergency triage.

## Privacy QA

- Confirm app explains local-only storage.
- Confirm app explains no server, AI service, ad, or analytics sending in this MVP.
- Confirm one-note delete and all-history delete.
- Confirm PDF/text export only happens after user action.

## App Store Connect

- Privacy policy URL.
- Support URL.
- App Store description.
- Review notes.
- Screenshots.
- App icon.
- Age rating.
- Medical category positioning.
