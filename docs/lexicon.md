# Lexicon — Remanence

The only place where terms are defined. Specs link here instead of redefining them. The name used in the code is given in parentheses; the French interface word follows when it differs.

## Terms

### Card

A front / back flashcard (`Flashcard`; *carte*). Each face holds plain text and/or an image. A card belongs to one [group](#group) or to none.

### Direction

One of the two ways to review a card (`CardDirection`; *sens*): front → back (`frontToBack`) or back → front (`backToFront`). Each direction has its own state, [step](#step), [due date](#due-date) and history. Its states are inactive (not studied), [unstarted](#unstarted), pending (in a distillation queue), active and acquired.

### Unstarted

State of a studied direction that has not entered review yet (`DirectionState.unstarted`; *pas commencée*). Every new card starts there; it has no due date until the user starts it, all at once or through a distillation.

### Group

A flat list of cards sharing a [preset](#preset) (`CardGroup`; *groupe*). Cards without a group form the virtual list "No group" (*Sans groupe*).

### Preset

A complete set of repetition rules (`Preset`): engine, interval sequence, behaviour on failure and at the end of the sequence, schedule, notification mode. A level (card, group, global) picks a whole preset or inherits from the next level.

### Step

Position of a direction in its preset's sequence (`step`; *cran*): the index of the interval currently waited, displayed from 1 ("step 2 of 6"). A direction never reviewed has no step.

### Due date

Moment when a direction becomes [due](#due) again (`dueAt`; *échéance*). For an interval of a day or more, it is the preset slot on the target day; for a shorter interval, the answer moment plus the interval.

### Day

Scheduling day, which starts at 4am rather than midnight (`SchedulingCalendar`; *journée*). Every "same day" and "today" rule uses it.

### Due

A direction is due today (*à réviser*) when its due date has passed, or when it falls today and the direction has not already been reviewed today (`DuePolicy`).

### Bonus review

An answer to a card that is not due (*révision bonus*). It is written to the history but changes neither the step nor the due date.
