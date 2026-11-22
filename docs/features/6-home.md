# Feature 6 — Home

Status: implemented (2026-11-20)

## Goal

Answer, on opening the app, the question "what is coming?": the cards of today, late ones first, then those of the next days, the new cards each group receives, and how many cards the coming month and year hold. Pulling the page down uncovers how many cards have been notified so far.

## Implementation overview

The Home tab is a single timeline, `HomeTimeline`, computed by `TimelinePlanner` from every card, the upcoming [extra reminders](../lexicon.md#extra-reminder), the distillations and the global pause. It is recomputed whenever one of these changes and every minute, through the current moment.

### The timeline

The timeline covers seven [days](../lexicon.md#day): today and the six next ones. Today always shows, with "Nothing planned today." when it is empty; a later day shows only when something falls on it. It reads as an agenda, with no panel: a hairline starts each day, whose date sits on the left as a weekday and a number ("TUE 24"), today's on a badge filled in the accent colour. Under the date, a thin trait runs down towards the next day; the last one fades out, towards [what lies further ahead](#further-ahead). Today and tomorrow are named in capitals above their content, "TODAY" and "TOMORROW"; the other days only have their date.

Each day lists its reminders card by card:

- an introduced card goes on the day of its [due date](../lexicon.md#due-date), or on today when it is [due](../lexicon.md#due), with "late" in red after its group when its due day is past; today's cards also give their time ("Capitals · 12:00");
- a "Review soon" reminder goes on its day, with "Review soon" after its group;
- each card shows its front and its group, never its step; touching it opens its sheet;
- on its right, in a pill, the time left before its reminder: in hours today, rounded up ("3H" at 15:00 for 17:30), in days afterwards ("1D" tomorrow, up to "6D"). A late card, or one whose moment has passed, has none.

Late cards come first, then the others by moment. A card already answered today has left today, since its due date moved: today only shows what is left to do. Suspended and pending cards are not reminders.

### New cards

New cards are never named. A day with new cards gets one line under its reminders, marked with a drop: the groups receiving them, each with its count ("Capitals 2  Spanish 1"). Touching a group opens it. The count is made of:

- the introduced cards never answered, on the day they are due (today when late);
- the cards the group's [distillation](8-distillation.md) should introduce that day, one batch a day from its last one; with "Prioritize reviews", the reviews of the group, those of its cards to come included, take the places of new cards ([Estimates](8-distillation.md#estimates)), so an announced arrival may slip.

The distillation arrivals have no delay.

A paused distillation announces no future arrival, and neither does any distillation during the global pause. The reminders of their cards stay on the timeline: a pause does not stop them.

### Further ahead

After the detailed days, under a dashed rule titled "Further ahead", two figures side by side: the cards within a month, from the 8th to the 30th day, and those within a year, from the 31st to the 365th ("8 cards within a month", "28 cards within a year"). The two windows do not overlap: the second does not include the first. Each counts the reminders planned then (one per card, at its due date, and the "Review soon" reminders) and the new cards expected, introduced cards never answered and distillation arrivals alike. They do not react to touch.

### Header

The title "Coming up" sits alone at the top. The global pause is started from Settings ([Feature 8](8-distillation.md#pause)), not from Home. During the pause, Home starts with "Paused since …", a line saying that no new card arrives and that the reminders go on, and a "Resume" button.

There is no count of due cards and no "Review all" on Home: reviewing happens from the notifications, a group page or a card sheet.

### Cards learned

An easter egg: when the page is pulled down past its top, the list gives way and uncovers one more row of the agenda, in the past, with a clock icon: the number of cards notified so far ("1,284 cards learned", "Every card notified so far"). The row fades in with the pull and goes back with the list on release. The page bounces on every platform, so the gap exists on Android too.

A card counts once notified: answered at least once, or introduced with its first moment passed. A card still waiting in a queue, or introduced for a later moment, does not. Learned here is unrelated to the [acquired](../lexicon.md#acquired) cards of a group.

## Acceptance criteria

- [x] Today shows first, its date on an accent badge, with its late cards first, even when empty; the next six days follow when something falls on them.
- [x] A thin trait runs down from each date towards the next day, the last one fading out.
- [x] Each reminder shows its card's front and its group, without its step; a "Review soon" reminder shows on its day.
- [x] New cards show as one line per day listing its groups with their count, made of the introduced cards never answered and of the arrivals expected from the distillation; each group opens.
- [x] A paused distillation, or any during the global pause, announces no arrival.
- [x] Each reminder shows the time left before it, in hours today and in days afterwards, except when late or past.
- [x] The coming month and year give the total of reminders and expected new cards.
- [x] Pulling the page down uncovers the number of cards notified so far, and it goes back on release.
- [x] Home has no pause button; during the global pause, started from Settings, it offers to resume it.

## Test strategy

- `TimelinePlanner` is tested as pure logic with a fixed moment: late cards first, empty days left out but today kept, suspended and pending cards left out, new cards counted per group, today's batch owed until the daily pass ran, batch days taken by the reviews of the group, paused distillation and global pause, "Review soon" reminders, the time left before each reminder, the totals of the coming month and year at their bounds, and the cards notified (answered, or introduced with their first moment passed).
- The arrivals of a distillation are tested on `DistillationRhythm` ([Feature 8](8-distillation.md#test-strategy)).
- The screen is covered by screen tests with a capture in light and dark theme, in French and during the global pause, on the sample data partly answered, with a reminder and a distilling group, by one of a distillation in progress, by one scrolled to the coming month and year, with a group distilling over several months, and by one pulled down on the cards learned.

## File mapping

- `lib/application/home/` — `TimelinePlanner`, the timeline and its days, cards and arrivals, and its providers.
- `lib/features/home/` — the Home tab, its timeline and the counter of cards learned.
- `lib/app/widgets/` — `PullToReveal`, the page that uncovers a widget when pulled down, and `DashedDivider`.

## Technical details

`todayStartProvider` derives the start of the scheduling day (4am) from the current moment but only changes once a day, so the streams built on it (the notifications of the day for the safeguards) are not rebuilt every minute.

`PullToReveal` lays the page out as a `ListView` with bouncing physics, whatever the platform, and reads how far the top is pulled from its scroll notifications. The revealed widget is only built while the page is pulled.
