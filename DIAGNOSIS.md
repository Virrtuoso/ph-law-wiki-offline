# Diagnosis — PH Law Wiki Offline (Virrt)

See also: local PDF `ph-law-wiki-offline-fixes.pdf` and patch `patches-diagnose-and-stabilize.patch` in the workspace checkout.

## Headline
**`main` has no app.** The Flutter MVP lives on Copilot branches / open PRs #1, #2, #4. CI was red. Fixes on this branch make `flutter analyze` / `flutter test` (36/36) / `flutter build apk --debug` succeed.

## Ranked causes
1. App never merged to main (CRITICAL)
2. Red Flutter CI on all open PRs (HIGH)
3. ListView lazy-build hid Bookmarks/disclaimer; home header overflow (HIGH)
4. Optional FTS5 missing on some Android SQLite builds — handled in PR #2 lineage (MEDIUM)
5. Shared GoRouter + brittle widget tests (MEDIUM)
6. Android-only platforms checked in (LOW)

## Verify locally
```sh
git checkout fix/diagnose-and-stabilize
flutter pub get && flutter analyze && flutter test
flutter build apk --debug
```
