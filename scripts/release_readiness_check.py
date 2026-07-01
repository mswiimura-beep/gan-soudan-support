#!/usr/bin/env python3
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "GanSoudanSupport" / "GanSoudanSupport.xcodeproj" / "project.pbxproj"
APPICON = ROOT / "GanSoudanSupport" / "GanSoudanSupport" / "Assets.xcassets" / "AppIcon.appiconset"
SCREENSHOTS = ROOT / "docs" / "app-store-screenshots"


def main() -> None:
    failures: list[str] = []
    warnings: list[str] = []

    required_paths = [
        ROOT / ".gitignore",
        ROOT / "README.md",
        ROOT / "GanSoudanSupport" / "GanSoudanSupport" / "App.swift",
        ROOT / "GanSoudanSupport" / "GanSoudanSupport" / "Models.swift",
        ROOT / "GanSoudanSupport" / "GanSoudanSupport" / "Screens.swift",
        ROOT / "docs" / "privacy-policy-draft.md",
        ROOT / "docs" / "app-store-listing-draft.md",
        ROOT / "docs" / "app-privacy-label-draft.md",
        ROOT / "docs" / "testflight-checklist.md",
        ROOT / "docs" / "manual-qa-checklist.md",
    ]

    for path in required_paths:
        if not path.exists():
            failures.append(f"missing: {path.relative_to(ROOT)}")

    icon_count = len(list(APPICON.glob("*.png"))) if APPICON.exists() else 0
    if icon_count < 18:
        failures.append(f"expected 18 app icon PNGs, found {icon_count}")

    screenshot_count = len(list(SCREENSHOTS.glob("*.jpg"))) if SCREENSHOTS.exists() else 0
    if screenshot_count < 5:
        failures.append(f"expected at least 5 App Store screenshot drafts, found {screenshot_count}")

    project_text = PROJECT.read_text() if PROJECT.exists() else ""
    if "DEVELOPMENT_TEAM = \"\";" in project_text:
        warnings.append("DEVELOPMENT_TEAM is empty; signing must be configured before TestFlight.")

    if "Assets.xcassets in Resources" not in project_text:
        warnings.append("Assets.xcassets is not registered in Resources because local actool fails with broken Simulator runtimes.")

    if "PRODUCT_BUNDLE_IDENTIFIER = jp.iimurakenji.GanSoudanSupport;" not in project_text:
        failures.append("unexpected bundle identifier")

    if failures:
        print("FAIL")
        print("\n".join(failures))
        raise SystemExit(1)

    print("release readiness file check passed")
    print(f"app icon PNGs: {icon_count}")
    print(f"app store screenshot drafts: {screenshot_count}")
    for warning in warnings:
        print(f"warning: {warning}")


if __name__ == "__main__":
    main()
