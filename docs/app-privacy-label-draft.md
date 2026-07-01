# App Privacy Label Draft

This draft is for App Store Connect privacy answers. Confirm against the final implementation before submission.

## Current MVP Data Flow

- Data is stored locally on device.
- No account creation.
- No server sync.
- No external AI service calls.
- No advertising SDK.
- No analytics SDK.
- PDF/text export only happens after user action.

## Data Types Potentially Entered By User

The user may voluntarily enter:

- Health-related consultation text
- Optional diagnosis or cancer type
- Optional treatment status
- Consultation category
- User role such as patient, family, or companion
- Next consultation date

## App Store Privacy Draft Answer

### Data Collection

For the current local-only MVP, the app does not collect data from the user or transmit user data off device.

### Data Linked To User

None in the current MVP, because there is no account and no off-device collection.

### Data Used To Track User

No.

### Third-Party Advertising Or Analytics

No.

### Health Data

Users may type health-related information into local notes. This data remains on device unless the user explicitly exports or shares PDF/text output.

## Changes That Require Reanswering

Revisit App Store privacy answers before adding:

- Sign in with Apple
- Server sync
- LLM or AI processing
- Crash or analytics SDK that receives user identifiers
- Cloud backup or external storage
- Consultation sharing with staff or facilities
- Push notifications with health-related content
