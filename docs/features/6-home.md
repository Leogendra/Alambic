# Feature 6 — Home

Status: implemented (2026-11-20)

## Goal

Answer, on opening the app, the question "what is coming?": the cards of today, late ones first, then those of the next days, the new cards each group receives, and how many cards the coming month and year hold.

## Implementation overview

The Home tab is a single timeline, `HomeTimeline`, computed by `TimelinePlanner` from every card, the upcoming [extra reminders](../lexicon.md#extra-reminder), the distillations and the global pause. It is recomputed whenever one of these changes and every minute, through the current moment.

### The timeline

The timeline covers seven [days](../lexicon.md#day): today and the six next ones. Today always shows, outlined in the accent colour, with "Nothing planned today." when it is empty; a later day shows only when something falls on it. Days are titled "Today", "Tomorrow", then "Thu 12 Nov".

Each day lists its reminders card by card:

- an introduced card goes on the day of its [due date](../lexicon.md#due-date), or on today when it is [due](../lexicon.md#due), with "late" in red when its due day is past; today's cards also give their time ("at 12:00");
- a "Review soon" reminder goes on its day, labelled "Review soon";
- each card shows its front and its group, never its step; touching it opens its sheet;
- on its right, the time left before its reminder: in hours today, rounded up ("3H" at 15:00 for 17:30), in days afterwards ("1J" tomorrow, up to "6J"). A late card, or one whose moment has passed, has none; a "Review soon" reminder shows its label before it.

Late cards come first, then the others by moment. A card already answered today has left today, since its due date moved: today only shows what is left to do. Suspended and pending cards are not reminders.

### New cards

New cards are never named. Each group gets one line per day, "Capitals: 2 new cards", which opens the group. It counts:

- the introduced cards never answered, on the day they are due (today when late);
- the cards the group's [distillation](8-distillation.md) should introduce that day, following its rhythm from its last batch; with "Prioritize reviews", the reviews already planned on a batch day take the places of new cards ([Estimates](8-distillation.md#estimates)), so an announced arrival may slip.

The distillation lines have no delay.

A paused distillation announces no future arrival, and neither does any distillation during the global pause. The reminders of their cards stay on the timeline: a pause does not stop them.

### Coming month and year

After the detailed days, two blocks side by side: "Next month", from the 8th to the 30th day, and "Next year", from the 31st to the 365th. Each gives its total ("12 cards"): the reminders planned then (one per card, at its due date, and the "Review soon" reminders) and the new cards expected, introduced cards never answered and distillation arrivals alike. A pile of card slices under it grows with the total: one slice, then one more each time the total doubles (2, 4, 8…), up to seven. The blocks do not react to touch.

### Header

The title "Coming up" sits over today's date. The global pause is started from Settings ([Feature 8](8-distillation.md#pause)), not from Home. During the pause, Home starts with "Paused since …", a line saying that no new card arrives and that the reminders go on, and a "Resume" button.

There is no count of due cards and no "Review all" on Home: reviewing happens from the notifications, a group page or a card sheet.

## Acceptance criteria

- [x] Today shows first, outlined, with its late cards first, even when empty; the next six days follow when something falls on them.
- [x] Each reminder shows its card's front and its group, without its step; a "Review soon" reminder shows on its day.
- [x] New cards show as one line per group and day, made of the introduced cards never answered and of the arrivals expected from the distillation.
- [x] A paused distillation, or any during the global pause, announces no arrival.
- [x] Each reminder shows the time left before it, in hours today and in days afterwards, except when late or past.
- [x] The coming month and year give the total of reminders and expected new cards, with a pile that grows with it.
- [x] Home has no pause button; during the global pause, started from Settings, it offers to resume it.

## Test strategy

- `TimelinePlanner` is tested as pure logic with a fixed moment: late cards first, empty days left out but today kept, suspended and pending cards left out, new cards counted per group, today's batch owed until the daily pass ran, batch days taken by planned reviews, paused distillation and global pause, "Review soon" reminders, the time left before each reminder, and the totals of the coming month and year at their bounds.
- The arrivals of a distillation are tested on `DistillationRhythm` ([Feature 8](8-distillation.md#test-strategy)).
- The screen is covered by screen tests with a capture in light and dark theme, in French and during the global pause, on the sample data partly answered, with a reminder and a distilling group, by one of a distillation in progress, and by one scrolled to the coming month and year, with a group distilling over several months.

## File mapping

- `lib/application/home/` — `TimelinePlanner`, the timeline and its days, cards and arrivals, and its providers.
- `lib/features/home/` — the Home tab and its timeline.

## Technical details

`todayStartProvider` derives the start of the scheduling day (4am) from the current moment but only changes once a day, so the streams built on it (the notifications of the day for the safeguards) are not rebuilt every minute.
