# Feature 6 — Home

Status: in progress (2026-11-11)

## Goal

Answer, on opening the app, the question "what do I have to do today?": how many cards are [due](../lexicon.md#due) and how long they will take, which reminders the day still holds, and which groups need attention, either to review or to start.

## Implementation overview

The Home tab is built from a single view of the day, `TodayOverview`, computed by `TodayPlanner` from every card, the upcoming [extra reminders](../lexicon.md#extra-reminder), the answers of the day and the preset catalog. It is recomputed whenever one of these changes and every minute, through the current moment.

### Due panel

The panel shows the number of due directions and an estimate of about thirty seconds per card ("About 3 min"). A progress bar compares the directions answered today with the total of the day, that is answered plus still due ("2 of 7 done today"). Bonus reviews are not counted: they move nothing in the schedule. "Review all now" opens a session on every due card, oldest due date first ([Feature 5](5-session.md)); when nothing is due, the panel says so instead.

### Today's reminders

The timeline lists the moments of the day at which something is planned:

- for each group (and "No group"), the directions due today at a given moment, described by the group's preset: "4 reminders, one notification per card", or a grouped reminder;
- the new cards a [distillation](8-distillation.md) introduces today, apart from the reminders of their group: "New knowledge", "Capitales · distillation, card 23 of 35";
- the "Review soon" reminders falling today.

Past moments are greyed and give what is still left ("2 left"); the first moment ahead is highlighted as "Next". A direction answered ahead of its slot leaves the timeline, since its due date moved. Directions overdue from previous days are not in the timeline: they are counted in the due panel.

### Groups

Two grids follow, each opening the group page:

- "Groups to review": the groups with due cards, with their count;
- "Cards to start": the groups holding [unstarted](../lexicon.md#unstarted) cards, so that new cards never go unnoticed ([Feature 3](3-cards.md#starting-new-cards)).

The pause button of the mockup is not there yet: pauses come with the notification safeguards.

## Acceptance criteria

- [x] Home shows the number of due cards, an estimated duration and the progress of the day; "Review all now" starts a session on every due card.
- [x] The timeline lists today's reminders per group and moment, the new cards of the distillations, and the "Review soon" reminders, past ones greyed with what is left, the next one highlighted.
- [x] Home lists the groups with due cards and the groups with cards to start, each opening its group page.

## Test strategy

- `TodayPlanner` is tested on an in-memory database filled through the services: grouping per group and moment, new cards of a distillation apart, extra reminders, next entry, and the count of answers of the day without bonus reviews.
- The screen is covered by golden tests in light and dark theme on the sample data, partly answered, with a reminder and a group of new cards, and by a golden test with a distillation in progress.

## File mapping

- `lib/application/home/` — `TodayPlanner`, the day view and its providers.
- `lib/features/home/` — the Home tab and its timeline.

## Technical details

The answers of the day are read from the start of the scheduling day (4am). `todayStartProvider` derives that moment from the current moment but only changes once a day, so the history stream built on it is not rebuilt every minute.
