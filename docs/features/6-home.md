# Feature 6 — Home

Status: in progress (2026-11-17)

## Goal

Answer, on opening the app, the question "what is coming?": the cards of today, late ones first, then those of the next days, and the new cards each group receives.

## Implementation overview

The Home tab is a single timeline, `HomeTimeline`, computed by `TimelinePlanner` from every card, the upcoming [extra reminders](../lexicon.md#extra-reminder), the distillations and the pauses. It is recomputed whenever one of these changes and every minute, through the current moment.

### The timeline

The timeline covers seven [days](../lexicon.md#day): today and the six next ones. Today always shows, outlined in the accent colour, with "Nothing planned today." when it is empty; a later day shows only when something falls on it. Days are titled "Today", "Tomorrow", then "Thu 12 Nov".

Each day lists its reminders card by card:

- an introduced card goes on the day of its [due date](../lexicon.md#due-date), or on today when it is [due](../lexicon.md#due), with "late" in red when its due day is past; today's cards also give their time ("at 12:00");
- a "Review soon" reminder goes on its day, labelled "Review soon";
- each card shows its front and its group, never its step; touching it opens its sheet.

Late cards come first, then the others by moment. A card already answered today has left today, since its due date moved: today only shows what is left to do. Suspended and pending cards are not reminders.

### New cards

New cards are never named. Each group gets one line per day, "Capitales: 2 new cards", which opens the group. It counts:

- the introduced cards never answered, on the day they are due (today when late);
- the cards the group's [distillation](8-distillation.md) should introduce that day, following its rhythm from its current batch, as if every batch went through: the budget of "Avoid collisions" may push an arrival back by a day.

A paused distillation, or a paused group, announces no future arrival. Cards of a paused group stay on the timeline: they remain reviewable in the app.

### Header

The title "Coming up" sits over today's date. A pause button next to it starts the global pause, after a confirmation ([Feature 7](7-notifications.md#pauses)). During the pause, Home starts with "En pause depuis le …" and a "Reprendre" button.

There is no count of due cards and no "Review all" on Home: reviewing happens from the notifications, a group page or a card sheet.

## Acceptance criteria

- [x] Today shows first, outlined, with its late cards first, even when empty; the next six days follow when something falls on them.
- [x] Each reminder shows its card's front and its group, without its step; a "Review soon" reminder shows on its day.
- [x] New cards show as one line per group and day, made of the introduced cards never answered and of the arrivals expected from the distillation.
- [x] A paused distillation or group announces no arrival.
- [x] The pause button starts the global pause; Home then offers to resume it.

## Test strategy

- `TimelinePlanner` is tested as pure logic with a fixed moment: late cards first, empty days left out but today kept, suspended and pending cards left out, new cards counted per group, today's batch owed until the daily pass ran, paused distillation and group, and "Review soon" reminders.
- The arrivals of a distillation are tested on `DistillationRhythm`: batches until the queue is empty, today skipped once its pass ran, a batch in progress finished first.
- The screen is covered by golden tests in light and dark theme, in English and during the global pause, on the sample data partly answered, with a reminder and a distilling group, and by a golden test of a distillation in progress.

## File mapping

- `lib/application/home/` — `TimelinePlanner`, the timeline and its days, cards and arrivals, and its providers.
- `lib/features/home/` — the Home tab and its timeline.

## Technical details

`todayStartProvider` derives the start of the scheduling day (4am) from the current moment but only changes once a day, so the streams built on it (the notifications of the day for the safeguards) are not rebuilt every minute.
