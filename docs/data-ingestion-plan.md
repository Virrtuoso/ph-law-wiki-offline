# Data ingestion plan

## Purpose

The bundled database is a small demonstration dataset, not a complete legal
publication. This document defines the process required before expanded data is
included in a release or made available as a manual update.

## Sources and provenance

1. Obtain each primary text from an authoritative Philippine government source,
   preferably the Official Gazette.
2. Record the source URL, retrieval date, instrument title and number,
   publication or effectivity date, and any amendment or repeal status.
3. Keep the original retrieved artifact and its SHA-256 digest in the
   ingestion review records.
4. Do not infer missing text, consolidation history, or legal status from
   secondary sources. Flag uncertainty for legal-editor review.

## Transform and review

1. Convert source text into laws, hierarchy nodes, articles, and
   cross-references while preserving numbering and order.
2. Validate required fields, unique identifiers, hierarchy references, article
   ordering, source URLs, and text encoding.
3. Compare the transformed content with the source artifact, including a
   review of headings, section boundaries, and amendments.
4. Have a second reviewer approve the source, transformation, and legal-status
   metadata before publication.
5. Build a fresh SQLite database and verify full-text search, citation display,
   navigation, and cross-references against representative entries.

## Release artifacts

Each approved dataset release must include:

- a monotonic dataset version;
- a generated SQLite or JSON update bundle;
- a manifest containing the version, download URL, publication date, source
  summary, and SHA-256 checksum;
- the checksum of the distributed bundle; and
- release notes identifying added, changed, removed, and unresolved material.

Publish artifacts as immutable, versioned files. Never replace an artifact at
an existing version.

## Manual update flow

The current app does not download updates. When implemented, a user-triggered
update must:

1. fetch a versioned manifest over HTTPS;
2. compare its version with the local `app_metadata` dataset version;
3. download the referenced bundle;
4. verify the SHA-256 digest before opening or importing the bundle;
5. validate the bundle schema and required metadata;
6. apply the replacement or merge transactionally, preserving user bookmarks
   and notes where identifiers remain valid; and
7. update the local version and update timestamp only after a successful
   commit.

On any failure, retain the current database and clearly report that no update
was applied.

## Ongoing maintenance

Review source availability and legal-status metadata for every dataset release.
Track corrections as versioned changes, add regression tests for corrected
records, and retain release records so users can identify exactly which
dataset version they consulted.
