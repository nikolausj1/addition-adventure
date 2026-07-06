# Backlog — Addition Adventure

Ideas and deferred work, roughly ordered by value. Nothing here blocks the first
real play test except the deploy itself.

## Done (the port)
- ~~Engine port~~ DONE 2026-07-05: addition 0+0..12+12 (91 facts), subtraction as
  the inverse form (`15 − 7 = ?`, minuends to 24), distractors, fluency bar
  4.0→2.5s, quest floor/ceiling 8/12 min, crossing-ten review boost, rank &
  milestone counts rescaled to 91. Identity `com.levelup.addsub`, display "Addition".
- ~~UI/copy sweep~~ DONE 2026-07-05: × → +/− everywhere (dashboard, grid,
  certificate, onboarding, wrap).
- ~~Branding art~~ DONE 2026-07-05: splash, map banner (header1, faded), app icon.
- ~~Curriculum tuning~~ DONE 2026-07-05: order 0,1,2,10,5,3,4,6,7,8,9,11,12 —
  11s/12s as the finale (split across the last two worlds), +9 grouped with the
  crossing-ten facts. World sizes 15/13/17/10/11/12/13.
- ~~Engine tests + 10-day sims~~ DONE 2026-07-05: all green; fast & slow learner
  healthy through world 2, no rule-fact grind.

## To first play test (blocking real use)
- **Deploy Ad Hoc IPA to Vinny's iPad** — the under-13 recipe (child account
  sign-out → reboot → Developer Mode → sign back in; `archive` → `exportArchive`
  method `release-testing`, team 6A4J2GTB6F → `devicectl install`). New bundle id
  `com.levelup.addsub` may need the App ID registered (automatic signing usually
  handles it on first archive).
- **Fresh profile before day 1** — no dev/test data on his iPad.
- **Watch the first real boss fight** — CRITICAL: visual lands? ~70% pass bar fair?
  quest length/rollover pacing in real play?

## Verification gaps (worth closing before or right after deploy)
- ~~Full-journey sim~~ DONE 2026-07-06 (`-dumpDays 80 -dumpQuiet`): all 7 worlds
  cleared / 7 bosses defeated by day ~36 (fast learner), 91/91 fluent, no crashes.
  Subtraction served 1322×, minuends 4…24 (21 distinct). See finding below.
- ~~Mastery / certificate unreachable~~ FIXED 2026-07-06: `+0/+1` rule facts were
  excluded from review and stuck at fluency, capping mastery at 66/91 so the
  100%-completion certificate could never trigger. PromotionEngine now masters a
  rule fact on its second correct (both reps land in its intro session; no cross-day
  needed — a rule isn't crammable). Post-fix journey: mastery climbs (0 → 14 by
  adventure-end vs 0 before), all 91 now reachable with continued play. NOTE: this
  same gap exists in the multiplication app — worth porting the fix back to Math Tutor.
- Full 91/91 mastery takes many sessions beyond the ~36-day adventure (review
  bandwidth is ~10 facts/session) — the certificate is a long-haul reward, by design.
- **Subtraction feel** — confirm the `sum − addend = ?` questions surface at a good
  rate and read clearly to a 7-year-old. Option on the table: mix in the
  `5 + ? = 12` form too (currently pure subtraction display).
- **Remaining-screen screenshots** for review — session (addition keypad + a
  subtraction question), onboarding steps, wrap, boss panel, certificate.

## Tune after week 1 (from real use)
- **Session length** — 8-min floor / 12 ceiling right for Vinny, or drop to the
  ~5/8 fallback if he fades?
- **Speed bar** — 4.0s→2.5s fluency threshold: too tight / too loose?
- **Crossing-ten review boost** — confirm the exact hard-fact set (currently
  `sum > 10 && min addend > 2`).
- **Curriculum order** — any further placement tweaks (like the +9 move).
- **World 3 (17 facts, the largest)** — watch pacing there.

## Features (inherited ideas, reusable here)
- **Boss idle videos** — replace boss stills with seamless idle loops
  (image-to-video, chroma → HEVC-alpha → `AVPlayerLooper`). Pilot 2–3 bosses.
- **True/False lightning round** — freshness drop ("7 + 8 = 16, true or false?"),
  big tap targets, fast pace, for attention dips.
- **Progress export/import** — Parent Area button to export/import the profile as
  JSON via share sheet. Cheap insurance against device loss / botched update.
- **Per-world ambience loops / background music** — volume-ducked under SFX,
  parent toggle.

## Audio (inherited — copied over as-is, re-check)
- **sfx_complete replacement** (session wrap) — warm short victory jingle.
- **sfx_world_unlock** — map smoke-reveal + boss verdict.
- **Re-listen to sfx_milestone** — trimmed from a 10s render; may want a re-cut.

## Housekeeping
- **map_header art** still carries the old × logo (never displayed while
  map_banner exists — harmless, but replace for zero stale art).
- **Own git remote** — `origin` was removed (pointed at the multiplication repo).
  Create a fresh GitHub repo for this app if you want it backed up / for
  TestFlight later.
- **App Store path** (only if ever distributing beyond the one iPad): new ASC app
  record, bundle-id registration, TestFlight upload, bump CURRENT_PROJECT_VERSION.
