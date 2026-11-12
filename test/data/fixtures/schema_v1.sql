-- Schema version 1 as created by the first release, with one Standard
-- preset, one group, one started card and one review.
CREATE TABLE "presets" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" TEXT NOT NULL, "built_in_key" TEXT NULL, "engine" TEXT NOT NULL, "intervals" TEXT NOT NULL, "failure_behavior" TEXT NOT NULL, "end_behavior" TEXT NOT NULL, "typed_answer" INTEGER NOT NULL CHECK ("typed_answer" IN (0, 1)), "schedule_kind" TEXT NOT NULL, "fixed_time" INTEGER NOT NULL, "range_start" INTEGER NOT NULL, "range_end" INTEGER NOT NULL, "notification_mode" TEXT NOT NULL, "grouped_action" TEXT NOT NULL, "target_retention" REAL NOT NULL);
CREATE TABLE "app_settings" ("id" INTEGER NOT NULL DEFAULT 1, "global_preset_id" INTEGER NOT NULL REFERENCES presets (id), PRIMARY KEY ("id"));
CREATE TABLE "card_groups" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "name" TEXT NOT NULL, "preset_id" INTEGER NULL REFERENCES presets (id), "created_at" INTEGER NOT NULL);
CREATE TABLE "flashcards" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "group_id" INTEGER NULL REFERENCES card_groups (id) ON DELETE CASCADE, "front_text" TEXT NULL, "front_image_path" TEXT NULL, "back_text" TEXT NULL, "back_image_path" TEXT NULL, "preset_id" INTEGER NULL REFERENCES presets (id), "suspended" INTEGER NOT NULL DEFAULT 0 CHECK ("suspended" IN (0, 1)), "created_at" INTEGER NOT NULL);
CREATE TABLE "card_directions" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "card_id" INTEGER NOT NULL REFERENCES flashcards (id) ON DELETE CASCADE, "sense" TEXT NOT NULL, "state" TEXT NOT NULL, "step" INTEGER NULL, "due_at" INTEGER NULL, "last_reviewed_at" INTEGER NULL, "notified_at" INTEGER NULL, UNIQUE ("card_id", "sense"));
CREATE TABLE "review_records" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "direction_id" INTEGER NOT NULL REFERENCES card_directions (id) ON DELETE CASCADE, "reviewed_at" INTEGER NOT NULL, "outcome" TEXT NOT NULL, "is_bonus" INTEGER NOT NULL CHECK ("is_bonus" IN (0, 1)), "step_before" INTEGER NULL, "step_after" INTEGER NULL, "source" TEXT NOT NULL);
CREATE TABLE "extra_reminders" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "direction_id" INTEGER NOT NULL REFERENCES card_directions (id) ON DELETE CASCADE, "remind_at" INTEGER NOT NULL, "notified_at" INTEGER NULL);
CREATE INDEX card_directions_due_at ON card_directions (due_at);
CREATE INDEX review_records_reviewed_at ON review_records (reviewed_at);
INSERT INTO presets VALUES (1, 'Standard', 'standard', 'sequence', '[{"amount":1,"unit":"day"},{"amount":2,"unit":"day"},{"amount":1,"unit":"week"},{"amount":1,"unit":"month"},{"amount":3,"unit":"month"},{"amount":6,"unit":"month"}]', 'stepBack', 'repeatLast', 0, 'fixedTime', 720, 540, 1080, 'perCard', 'openApp', 0.9);
INSERT INTO app_settings VALUES (1, 1);
INSERT INTO card_groups VALUES (1, 'Capitales', NULL, 1794300000);
INSERT INTO flashcards VALUES (1, 1, 'Mongolie', NULL, 'Oulan-Bator', NULL, NULL, 0, 1794300000);
INSERT INTO card_directions VALUES (1, 1, 'frontToBack', 'active', 0, 1794400000, 1794310000, NULL);
INSERT INTO card_directions VALUES (2, 1, 'backToFront', 'inactive', NULL, NULL, NULL, NULL);
INSERT INTO review_records VALUES (1, 1, 1794310000, 'correct', 0, NULL, 0, 'session');
PRAGMA user_version = 1;
