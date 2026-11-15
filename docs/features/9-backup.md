# Feature 9 — Export and import

Status: implemented (2026-11-16)

## Goal

Let the user keep a copy of everything they have built, and move it to another phone, without an account or a cloud. The data stays local; the user saves a zip file wherever they want and imports it back by hand. There is no automatic backup.

Out of scope: merging a backup into the current data. An import always replaces everything.

## Implementation overview

Settings has a "Data" section with two rows, "Export data" and "Import data".

### Export

Export writes a zip file named after the day (`alambic-2026-11-16.zip`) and opens the system save dialog, so the user chooses its folder or a cloud drive. The file holds:

- `alambic.json`: every row of every table of the database, as SQLite stores them, with the version of the file layout and the version of the database schema;
- `images/`: every card image, under the file name the cards refer to.

The rows are copied as they are stored rather than through the domain classes, because a backup is a copy of the data, not an interpretation of it: a new column or table needs no code in the export, only in the list of tables (see Constraints). Everything in the database travels with the file, including the presets, the global preset, the notification safeguards and the pauses, since these settings belong to the data. Interface preferences (language, theme) stay on the phone.

### Import

Import is done in two steps, so that the user confirms knowing what they replace:

1. The user picks a zip file. It is read and checked completely before anything is touched: it must be an Alambic backup, of a layout this version can read, written with the same database schema, with every table and no unknown column. A file refused at this step says why ("not an Alambic backup", "from a version this one cannot read", "damaged or incomplete") and the data stays as it was.
2. A dialog tells how many cards and groups the file holds and that all the current data will be replaced, with no way back. On confirmation, the database is emptied and filled from the file in a single transaction, then the image folder is replaced, then the notifications are planned again from the new data.

The database goes first and in one transaction because it is the part that can fail on content (a constraint the checks did not see): a failure rolls it back and the current data, images included, is untouched.

## Acceptance criteria

- [x] "Export data" saves a zip file holding the whole database as JSON and every card image.
- [x] "Import data" replaces all the current data, images included, by the content of a backup, after a confirmation telling how many cards and groups it holds.
- [x] A file that is not an Alambic backup, comes from an incompatible version or is damaged is refused with a message, without changing the current data.
- [x] After an import, the notifications follow the imported due dates.

## Constraints

- A backup is only imported into the same schema version it was written with. Once the schema has upgrade steps, an older backup will have to go through them; until then, a backup of another version is refused rather than guessed at.
- The list of tables is written once, in insertion order (a table after the tables its foreign keys point at). A table added to the database must be added to it; a test fails otherwise.
- An image name inside the file never contains a path, so that a crafted file cannot write outside the image folder.

## Test strategy

- The zip layout is tested on its own, without a database: round trip of rows and images, and each kind of refused file.
- Export and import are tested between two real in-memory databases with their own image folders, filled through the services: the imported tables and images equal the exported ones, the previous content is gone, the notifications are planned again, and a refused file or a failed insertion leaves the data unchanged.
- The Settings panel is tested with an in-memory replacement of the system file dialogs: refusal message and confirmation dialog.

## File mapping

- `lib/data/backup/` — zip layout, copy of the database tables, and the system file dialogs behind an interface.
- `lib/data/images/image_store.dart` — reading and replacing the whole image folder.
- `lib/application/backup/` — `BackupService`, the preview of a picked file and the providers.
- `lib/features/settings/backup_panel.dart` — the "Data" section of Settings.
