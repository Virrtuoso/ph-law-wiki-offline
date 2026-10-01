# Testing checklist

Run the automated checks before each change:

```sh
flutter analyze
flutter test
```

## Data and search

- [ ] A clean install creates and seeds the local database.
- [ ] The home and browse views show the bundled laws.
- [ ] A known title, article number, and body phrase each return relevant
  search results.
- [ ] Opening a search result displays the expected article and hierarchy.

## Reader and local state

- [ ] Bookmarking and unbookmarking an article updates the bookmarks view.
- [ ] Creating, editing, and deleting a note persists during the current app
  session.
- [ ] Citation text and source information display for seeded material.
- [ ] Light/dark theme settings apply across routed screens.

## Offline and update behavior

- [ ] Core browsing and search work with network access disabled.
- [ ] The displayed dataset version is `2024.1-sample` on a new install.
- [ ] Checking for updates reports that this offline MVP has no network
  updates.
- [ ] An attempted manual update does not alter existing content, bookmarks,
  or notes.

## Release review

- [ ] Validate the supported Android, iOS, and/or desktop targets used for the
  release.
- [ ] Confirm the legal disclaimer is visible from the app and README.
- [ ] Verify all dataset changes passed the process in
  [data-ingestion-plan.md](data-ingestion-plan.md).
- [ ] Confirm the GitHub Actions workflow completed `flutter analyze` and
  `flutter test`.
