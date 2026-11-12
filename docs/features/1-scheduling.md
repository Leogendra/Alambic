# Feature 1 — Review scheduling

Status: implemented (2026-11-12)

## Goal

Decide, after each answer, when a [direction](../lexicon.md#direction) must come back. This is the heart of spaced repetition: a successful card comes back later and later, a failed card comes back sooner. Two engines decide the interval: a fixed sequence of intervals, or FSRS, which computes each interval from the answers.

## Implementation overview

Scheduling lives entirely in the domain and works in three stages.

1. The engine of the [preset](../lexicon.md#preset) computes the interval to wait. The sequence engine (`SequenceEngine`) moves the [step](../lexicon.md#step) from the current step and the answer, and may report that the direction is acquired. The adaptive engine (`FsrsEngine`) updates the [memory](../lexicon.md#adaptive-engine) of the direction and derives the interval from it.
2. The scheduler (`ReviewScheduler`) turns that interval into a [due date](../lexicon.md#due-date), depending on whether the interval counts in days or in minutes.
3. It finally applies the two-directions rule: if the other direction of the card is due the same day, the one being scheduled moves to the next day.

The [day](../lexicon.md#day) starts at 4am, through `SchedulingCalendar`. An answer given at 1am counts for the previous day, and every "same day" comparison goes through this calendar. Days are added as calendar days rather than 24-hour slices, so that a daylight saving change does not shift the slot by an hour.

The engines never read the time: the answer moment is given to them. They do not read the database either; the caller gives the scheduler the direction, the resolved preset and the due date of the other direction.

### The step

The step is the index, in the preset sequence, of the interval currently waited. A direction never reviewed has no step: its first correct answer waits the first interval. In the Standard sequence (1 d, 2 d, 1 wk, 1 mo, 3 mo, 6 mo), a card answered correctly three times in a row therefore waits 1 week, at step 3 of 6.

If the sequence was shortened, or the card moved to a shorter preset, the engine clamps the step to the last existing step before computing. The stored step is only corrected at the next answer.

### The adaptive engine

The adaptive engine is a port of FSRS-5 with its default parameters. It keeps two numbers per direction: the stability (days until the probability of recalling the card falls to 90 %) and the difficulty (1 to 10). "Correct" counts as *Good* and "Again" as *Again*. Each answer updates both numbers from the days elapsed since the previous answer: the longer the card held, the more its stability grows; a failure drops it.

The next interval is the number of days until the probability of recalling falls to the preset's target retention (90 % by default, 70 % to 97 %): a higher retention brings the reviews closer. It always lasts a day or more, even after a failure, and lands on the preset slot like any day-based interval, with the two-directions rule. A new direction answered "Correct" comes back in 3 days, then about 11 days, 35 days, 3 months; answered "Again", the next day.

A direction followed by FSRS has no step. Where a step is shown elsewhere, an adaptive direction shows its current interval instead ("interval 11 d"). `DirectionProgress` gives, for any direction and its preset, the step, the FSRS memory and interval, or "new": screens, notifications and the priority of the daily cap all read it.

### Starting a direction

A new direction is never scheduled by itself: it stays unstarted until the user starts it ([Feature 3](3-cards.md#starting-new-cards)). Starting it, or resetting its progress, makes it due today at the preset slot, even when that slot has already passed: the direction is due at once. The two-directions rule applies too: a card started in both directions has its back → front direction due the day after the front → back one.

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

- [x] A started direction is due today at the preset slot, its reverse the next day.
- [x] Correct moves one step forward; the first correct answer waits the first interval.
- [x] Again applies the preset behaviour: one step back without going below the first, back to the start, or same step. A never-reviewed direction answered Again waits the first interval.
- [x] After the last step, Correct applies the preset end-of-sequence behaviour: repeat the last interval, mark acquired (no more due date), or loop to the start.
- [x] An interval of a day or more counts from the answer day and lands on the preset slot.
- [x] An interval shorter than a day counts from the answer moment.
- [x] After a failure, the due date is the interval of the step reached: never the same day for a day-based sequence.
- [x] The day starts at 4am.
- [x] The two directions of a card are never due the same day: the direction being scheduled moves to the next day.
- [x] A step beyond a shortened sequence is clamped to the last step.
- [x] With the adaptive engine, each answer updates the stability and the difficulty from the days elapsed since the previous answer; the interval is the time until the recall probability falls to the target retention, at least a day, at the preset slot.

## Test strategy

- Each engine rule is proven by a domain unit test, without a database: moving forward, each failure behaviour, each end of sequence, clamped step.
- Dates are fixed in the tests (November 2026): no test reads the clock or waits.
- The day boundaries (3:59am and 4am, end of month, slot before 4am) are tested explicitly on the calendar.
- The reverse-direction shift is tested at start and after an answer.
- The FSRS port is checked against values computed by hand from the FSRS-5 formulas (first answers, recall on time, failure, target retention), then end to end through the review service on a stored adaptive card.

## File mapping

- `lib/domain/scheduling/` — 4am calendar, sequence engine, scheduler, "due" rule and `DirectionProgress`.
- `lib/domain/scheduling/fsrs/` — the FSRS port: memory, ratings and formulas.
- `lib/domain/presets/preset_interval.dart` — an interval and its unit; a unit of a day or more counts in days.

## Technical details

Months count 30 days (`IntervalUnit.month`). A "1 month" always has the same length, and the "in 30 d" preview shown on the buttons stays true whatever the current month.

A preset slot earlier than 4am (for example 2am) belongs to the end of the scheduling day: `momentAt` places it on the next calendar date. Without this, a due date "day D at 2am" would fall on the previous evening in the user's calendar.

The two-directions rule only looks at the current due date of the other direction. It only applies to day-based intervals: a 10-minute interval is never pushed to the next day.

FSRS keeps its stability and difficulty in `card_directions` (`stability`, `difficulty`), empty for a sequence direction. The elapsed days count scheduling days between the previous answer and this one; a bonus review does not count as an answer. Intervals are not fuzzed: two cards answered the same way the same day come back together, which the notification safeguards then spread. The parameters are the published defaults: they are not fitted to the user's history.

## Constraints

- The scheduling domain stays pure Dart: no Flutter, drift or plugin import.
