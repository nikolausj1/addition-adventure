# App Store Connect — copy-paste metadata

Everything below is ready to paste into App Store Connect. Character limits are
Apple's; drafts here respect them. Anything in **[brackets]** is a decision or a
value only you can supply. Adapted from the sibling Multiplication Adventure's
already-live submission (`../Math Tutor/docs/appstore/METADATA.md`) — that
app's exact settings were confirmed live in App Store Connect on 2026-07-17.

---

## App name (max 30 chars) — PICK ONE

Apple requires the public name to be unique across the store, so have backups.

1. **Addition Adventure** (18) — first choice, matches the home-screen brand and
   the sibling's naming convention
2. **Addition Quest** (14)
3. **Addition & Subtraction Quest** (28)
4. **Math Facts Adventure** (20)
5. **Add & Subtract Adventure** (24)

> The home-screen label (`Addition`) is independent of this and can stay as is.
> If your first choice is taken, App Store Connect tells you instantly when you
> type it into the app record.

## Subtitle (max 30 chars)

> Addition & subtraction facts

Alternates: `Master addition, the fun way` (28); `Sums, worlds, and boss fights` (28).

## Promotional text (max 170 chars) — editable anytime without a new build

> Learn addition and subtraction the fun way. Explore seven worlds, battle
> guardians, earn stars, and master every fact. No ads, no tracking, made for kids.

## Keywords (max 100 chars, comma-separated, no spaces after commas)

> addition,subtraction,math,maths,kids,1st grade,2nd grade,facts,fluency,arithmetic,learning,game

(97 chars. Don't repeat the app-name words here — Apple already indexes those.)

## Description (max 4000 chars)

```
Addition Adventure turns learning addition and subtraction into a real adventure.

Your child journeys across seven hand-painted worlds — from the Wandering Isles
to the aurora-lit peak of Aurora Summit — mastering one addition fact at a time.
Every world ends in a boss battle against its guardian, and every correct answer
lands a hit.

The app adapts to your child. Facts they know fly by; facts they're still
learning come back more often, first as multiple choice, then fill-in-the-blank,
then from memory — so they build real fluency, not just lucky guesses. Subtraction
emerges naturally too: once a child knows 5 + 7 = 12, the app asks 12 − 5 = ? as
the same fact viewed the other way. Fast, confident answers earn speed bonuses
and streaks; a wrong answer just means a little more practice, never a penalty.

WHAT'S INSIDE
• All addition facts from 0+0 to 12+12 — 91 facts in total, with subtraction
  woven in as the inverse of each one your child has learned
• Seven worlds with a boss guardian in each
• A star quest system that paces practice into short, winnable sessions
• Speed bonuses, answer streaks, and celebration moments that make progress feel great
• An Addition Table reference chart to look up any answer
• A Certificate of Mastery to earn — and print — once every fact is mastered
• Multiple player profiles, so siblings and friends each keep their own progress

BUILT FOR KIDS AND PARENTS
• No ads. No in-app purchases. No sign-in.
• No tracking and no data collection — the app is completely offline and every
  bit of progress stays on the device.
• A simple parent area (behind a gate) shows exactly which facts your child has
  mastered and which ones need work.

Made by a dad for his own kids, and now for yours. Perfect for kindergarten
through 2nd graders building addition and subtraction fluency — or anyone who
wants the facts to finally stick.
```

## What's New (release notes for v1.0)

```
The very first release. Seven worlds, 91 facts, and a certificate waiting at the end. Have fun!
```

---

## TestFlight (Beta) fields

### Beta App Description (shown to testers)

```
Addition Adventure — an addition & subtraction game for kids. Explore seven
worlds, battle the guardian in each, and master every fact from 0+0 to 12+12.
Fully offline, no ads, no accounts. Thanks for testing!
```

### What to Test (per build)

```
Please try:
• Create a player, pick an avatar, and play a session in the first world.
• Answer some questions right and some wrong — the number pad should always appear.
• Check the Addition Table button (top of the map) and the parent area (gear icon).
• Let a second child create their own profile and confirm progress stays separate.

Tell me anything confusing, anything that looks broken, and whether the difficulty
feels right for your kid's grade.
```

### Test information (contact)

- Feedback email: **claude@justinnikolaus.com**
- Marketing URL: (optional) your GitHub repo or leave blank
- Privacy Policy URL: **[hosted privacy-policy.html URL — see SUBMISSION.md]**

---

## App information (set once)

| Field | Value |
|---|---|
| Bundle ID | `com.levelup.addsub` |
| Primary category | **Education** |
| Secondary category | **Games** (subcategory: **Family**) — matches the sibling's live setting |
| Age rating | **4+** (answer "None/No" to every questionnaire item, same as the sibling) |
| Price | **Free** |
| Made for Kids category | **Recommend NO for v1**, same call as the sibling — Education + 4+ is fully appropriate and skips the stricter Kids-category review. Can opt in later. |
| Support URL | **[required — can be the GitHub repo URL or a simple page]** |
| Marketing URL | Optional |
| Privacy Policy URL | **[hosted privacy-policy.html URL]** |
| Copyright | `2026 Justin Nikolaus` |
| Availability | **[all countries, or just your own to start]** |
| Content rights | Contains no third-party content (art is your own/AI-generated, audio is Kenney CC0) |
| Device support | **Universal (iPhone + iPad)** — unlike the sibling (iPad-only), this app also runs on iPhone in landscape, so it needs BOTH the iPad 13" and iPhone 6.9" screenshot sets. |

## Data collection (App Privacy section) — the easy part

Answer Apple's App Privacy questionnaire with:

> **"Data Not Collected"** — check the single box that says the app collects no data.

Nothing else to fill in. This matches the `PrivacyInfo.xcprivacy` now shipped in
the app (`Sources/App/Resources/PrivacyInfo.xcprivacy`).
