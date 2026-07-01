# Xcode Local Runbook

Use this on the local Mac after Xcode and Simulator are healthy.

## 1. Confirm Simulator Runtime

Open Xcode:

1. Xcode > Settings
2. Platforms
3. Confirm an iOS runtime is installed
4. Xcode > Open Developer Tool > Simulator

Terminal check:

```sh
xcodebuild -version
xcrun simctl list runtimes
xcrun simctl list devices available
```

Current Codex check on 2026-06-30:

- Xcode is visible as `Xcode 26.6 Build version 17F113`.
- Generic build without asset catalog succeeded before App Icon registration.
- `Assets.xcassets` is now registered in the `GanSoudanSupport` target Resources.
- App Icon Source is configured as `AppIcon`.
- After installing iOS 26.5 Simulator and restarting the Mac, XcodeBuildMCP can see `iPhone 17`.
- Simulator build, install, and launch succeeded on `iPhone 17`.
- First-launch consent screen was confirmed by screenshot.
- PDF share sheet, trusted external link, emergency/self-harm wording, copy alert, edit, single-note delete, and all-history delete were confirmed on Simulator through XcodeBuildMCP.

If shell `simctl` still cannot list runtimes but XcodeBuildMCP can, use XcodeBuildMCP or Xcode GUI for simulator validation.

## 2. Open Project

Open:

`GanSoudanSupport/GanSoudanSupport.xcodeproj`

Select scheme:

`GanSoudanSupport`

## 3. Register App Icon Assets

The draft icon files are already generated:

`GanSoudanSupport/GanSoudanSupport/Assets.xcassets/AppIcon.appiconset`

The project file now registers `Assets.xcassets` in the `GanSoudanSupport` target and uses `AppIcon`.

If `actool` fails with `No available simulator runtimes`, repair the iOS Simulator runtime first. The asset catalog itself is already wired.

## 4. Configure Signing

1. Select project `GanSoudanSupport`
2. Select target `GanSoudanSupport`
3. Signing & Capabilities
4. Set Team
5. Confirm Bundle Identifier: `jp.iimurakenji.GanSoudanSupport`

## 5. Run Manual QA

Use:

- `docs/manual-qa-checklist.md`
- `docs/testflight-checklist.md`
- `docs/screenshot-shotlist.md`

The first simulator launch has passed. Continue with the full manual QA checklist before TestFlight.

## 6. Archive For TestFlight

After manual QA:

1. Product > Archive
2. Validate App
3. Distribute App
4. App Store Connect
5. Upload

Codex note: shell-side archive attempts currently fail during asset-catalog processing because `actool` cannot see available Simulator runtimes from the restricted shell environment, even though XcodeBuildMCP can build and launch the app on Simulator. Use Xcode GUI Organizer for the real Archive/Upload path.
