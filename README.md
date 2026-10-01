# PH Law Wiki Offline

An offline-first Flutter reference app for a small sample of Philippine legal
texts. It is intended for browsing, searching, bookmarking, and annotating
reference material without a network connection.

## Architecture

The app follows a layered structure:

- `lib/presentation` contains Flutter screens, widgets, routing, and Riverpod
  providers.
- `lib/domain` defines entities, repository contracts, and use cases.
- `lib/data` implements repository contracts with local data sources and
  models.
- `lib/infrastructure` provides SQLite setup and migrations, seed data, update
  scaffolding, and shared utilities.

On first launch, the app creates a local SQLite database, creates its schema
and full-text-search index, then seeds the bundled dataset. The app does not
need a server or user account. Bookmarks and notes stay on the local device.

## Run locally

Install a Flutter SDK compatible with the Dart constraint in `pubspec.yaml`,
then run:

```sh
flutter pub get
flutter run
```

Select a connected device, emulator, or desktop target when prompted.

## Analyze and test

```sh
flutter analyze
flutter test
```

Tests use an in-memory SQLite backend through `sqflite_common_ffi`; no device
database or network access is required.

## Seeded data

This MVP ships with the `2024.1-sample` dataset. It contains a small,
representative sample from:

- the 1987 Constitution of the Republic of the Philippines;
- Republic Act No. 386 (Civil Code of the Philippines); and
- Republic Act No. 8491 (Flag and Heraldic Code of the Philippines).

The sample is intentionally incomplete and is not independently verified for
this build. Source links are stored with each seeded law where available.
Read [the data-ingestion plan](docs/data-ingestion-plan.md) before treating a
future expanded dataset as release-ready.

## Manual updates

This build has no automatic or network dataset updates. The in-app update
service currently reports the bundled version only and will not download or
apply an update. A production update process must use versioned artifacts,
verify a SHA-256 checksum before import, and replace or merge data
transactionally. The intended process is documented in
[docs/data-ingestion-plan.md](docs/data-ingestion-plan.md).

## Legal disclaimer

This app provides general legal-reference information only. It is not legal
advice and does not create a lawyer-client relationship. Laws, regulations,
and their interpretations may change; verify material against the Official
Gazette and other authoritative sources, and consult a qualified Philippine
lawyer for advice about a specific situation.

## Roadmap

- Expand the dataset using the reviewed ingestion process.
- Publish signed, versioned dataset releases and implement manual update
  downloads.
- Add source provenance, amendment history, and richer cross-references.
- Improve accessibility, localization, and offline backup/export options.

The roadmap deliberately defers highlights and other advanced reader features
until the core legal dataset and update process are verified.

## Contributing

Use the checks above before submitting changes. See the
[testing checklist](docs/testing-checklist.md) for focused manual and
automated verification guidance.
