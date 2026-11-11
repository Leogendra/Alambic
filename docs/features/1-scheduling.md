# Feature 1 — Review scheduling

Status: implemented (2026-11-11)

## Goal

Decide, after each answer, when a [direction](../lexicon.md#direction) must come back. This is the heart of spaced repetition: a successful card comes back later and later, a failed card comes back sooner. This feature covers the sequence engine; the adaptive engine (FSRS) will be added alongside it.

## Implementation overview

Scheduling lives entirely in the domain and works in three stages.

1. The sequence engine (`SequenceEngine`) computes the new [step](../lexicon.md#step) from the current step, the answer and the [preset](../lexicon.md#preset). It returns the interval to wait, or reports that the direction is acquired.
2. The scheduler (`ReviewScheduler`) turns that interval into a [due date](../lexicon.md#due-date), depending on whether the interval counts in days or in minutes.
3. It finally applies the two-directions rule: if the other direction of the card is due the same day, the one being scheduled moves to the next day.

The [day](../lexicon.md#day) starts at 4am, through `SchedulingCalendar`. An answer given at 1am counts for the previous day, and every "same day" comparison goes through this calendar. Days are added as calendar days rather than 24-hour slices, so that a daylight saving change does not shift the slot by an hour.

The engine never reads the time: the answer moment is given to it. It does not read the database either; the caller gives it the current step, the resolved preset and the due date of the other direction.

### The step

The step is the index, in the preset sequence, of the interval currently waited. A direction never reviewed has no step: its first correct answer waits the first interval. In the Standard sequence (1 d, 2 d, 1 wk, 1 mo, 3 mo, 6 mo), a card answered correctly three times in a row therefore waits 1 week, at step 3 of 6.

If the sequence was shortened, or the card moved to a shorter preset, the engine clamps the step to the last existing step before computing. The stored step is only corrected at the next answer.

### Due date of a new direction

A direction entering review (card creation, activation of the reverse direction) is due at the next preset slot: today if the slot has not passed yet, tomorrow otherwise. The two-directions rule applies too: a card created with both directions has its back → front direction scheduled the day after the front → back one.

### Due

A direction counts as [due](../lexicon.md#due) when it is active, its card is not suspended, and:

- its due date has passed;
- or its due date falls today (or earlier) and it has not already been reviewed today.

The second condition lets the user review in the app, in the morning, a card planned for 12:00 without waiting for the notification. It does not apply to a card just answered correctly with a 10-minute interval: reviewed today, it waits for its exact due date.

## Examples

Standard preset, 12:00 slot:

| Situation | Answer | Result |
|---|---|---|
| Never reviewed, Tuesday 9:30pm | Correct | step 1 (1 d), Wednesday 12:00 |
| Step 1, Tuesday 9:30pm | Correct | step 2 (2 d), Thursday 12:00 |
| Step 4 (1 mo), Tuesday 12:05 | Again | step 3 (1 wk), next Tuesday 12:00 |
| Never reviewed, Wednesday 1am | Correct | Wednesday 12:00 (the answer counts for Tuesday) |
| Never reviewed, other direction due Wednesday | Correct on Tuesday | Thursday 12:00 instead of Wednesday |

Intensive preset (10 min, 1 h, …): a first correct answer at 15:07 gives a due date at 15:17, whatever the preset slot.

## Acceptance criteria

- [x] Correct moves one step forward; the first correct answer waits the first interval.
- [x] Again applies the preset behaviour: one step back without going below the first, back to the start, or same step. A never-reviewed direction answered Again waits the first interval.
- [x] After the last step, Correct applies the preset end-of-sequence behaviour: repeat the last interval, mark acquired (no more due date), or loop to the start.
- [x] An interval of a day or more counts from the answer day and lands on the preset slot.
- [x] An interval shorter than a day counts from the answer moment.
- [x] After a failure, the due date is the interval of the step reached: never the same day for a day-based sequence.
- [x] The day starts at 4am.
- [x] The two directions of a card are never due the same day: the direction being scheduled moves to the next day.
- [x] A step beyond a shortened sequence is clamped to the last step.

## Test strategy

- Each engine rule is proven by a domain unit test, without a database: moving forward, each failure behaviour, each end of sequence, clamped step.
- Dates are fixed in the tests (November 2026): no test reads the clock or waits.
- The day boundaries (3:59am and 4am, end of month, slot before 4am) are tested explicitly on the calendar.
- The reverse-direction shift is tested at creation and after an answer.

## File mapping

- `lib/domain/scheduling/` — 4am calendar, sequence engine, scheduler and "due" rule.
- `lib/domain/presets/preset_interval.dart` — an interval and its unit; a unit of a day or more counts in days.

## Technical details

Months count 30 days (`IntervalUnit.month`). A "1 month" always has the same length, and the "in 30 d" preview shown on the buttons stays true whatever the current month.

A preset slot earlier than 4am (for example 2am) belongs to the end of the scheduling day: `momentAt` places it on the next calendar date. Without this, a due date "day D at 2am" would fall on the previous evening in the user's calendar.

The two-directions rule only looks at the current due date of the other direction. It only applies to day-based intervals: a 10-minute interval is never pushed to the next day.

## Constraints

- The scheduling domain stays pure Dart: no Flutter, drift or plugin import.
