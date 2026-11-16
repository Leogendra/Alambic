# Lexicon — Alambic

The only place where terms are defined. Specs link here instead of redefining them. The name used in the code is given in parentheses; the French interface word follows when it differs.

## Terms

### Card

A front / back flashcard (`Flashcard`; *carte*). Each face holds plain text and/or an image. A card always belongs to one [group](#group) and has a single progression: its state, [step](#step) or FSRS memory, [due date](#due-date) and history. Its states are [pending](#pending), active and acquired (`CardState`).

### Pending

State of a card never introduced (`CardState.pending`; *en attente*). Every new card starts there, at the end of the [queue](#queue) of its group, with no due date. Only the [distillation](#distillation) of its group introduces it; resetting a card sends it back there.

### Queue

The pending cards of a group, in their queue order (`queuePosition`; *file*). A card created in the group, moved into it while pending, or reset, joins its end.

### Distillation

A permanent setting of a group that introduces its [pending](#pending) cards a few at a time, "N cards every X days" (`Distillation`; *distillation*). A group has at most one; it does not exist until the user activates it, and afterwards is only adjusted, paused or resumed. It never stops nor ends: a card added later joins the [queue](#queue) and arrives at the same rhythm.

### Asked side

The face shown as the question of a display (`CardSide`; *face posée*). It is the front, unless the group has [the back](#back-option) enabled, in which case every display draws front or back at random. It changes nothing to the progression of the card.

### Back option

Option of a group (`CardGroup.reverseEnabled`; *verso*) that makes each display of its cards ask the front or the back, one chance in two.

### Group

A flat list of cards sharing a [preset](#preset) (`CardGroup`; *groupe*), with its [distillation](#distillation) and its [back option](#back-option). Every card is in a group.

### Preset

A complete set of repetition rules (`Preset`): engine, interval sequence, behaviour on failure and at the end of the sequence, schedule, notification mode. A level (card, group, global) picks a whole preset or inherits from the next level.

### Step

Position of a card in its preset's sequence (`step`; *cran*): the index of the interval currently waited. A card never answered has no step, nor does a card followed by the [adaptive engine](#adaptive-engine).

### Reminder label

Short name of the interval a card waits (*étiquette de rappel*): "J1", "J2", "S1", "M3" in French, "D1", "W1", "M3" in English, or the interval itself below a day ("10 min"). It is taken from the interval of the current [step](#step), not from its number. A card followed by the [adaptive engine](#adaptive-engine) has none.

### Adaptive engine

The engine of a preset that computes each interval with FSRS (`SchedulingEngineKind.adaptive`; *adaptatif*), instead of walking a fixed sequence. It keeps a memory per card (`FsrsMemory`): a stability, in days, and a difficulty from 1 to 10. Its interval brings the probability of recalling the card down to the preset's target retention (*rétention visée*).

### Due date

Moment when a card becomes [due](#due) again (`dueAt`; *échéance*). For an interval of a day or more, it is the preset slot on the target day; for a shorter interval, the answer moment plus the interval.

### Day

Scheduling day, which starts at 4am rather than midnight (`SchedulingCalendar`; *journée*). Every "same day" and "today" rule uses it.

### Due

A card is due today (*à réviser*) when its due date has passed, or when it falls today and the card has not already been reviewed today (`DuePolicy`). A suspended card is never due.

### Extra reminder

A one-off reminder added to a card with "Review soon" (`ExtraReminder`; *rappel ponctuel*). Answering it is a [bonus review](#bonus-review).

### Pause

A period during which cards are not notified (`Pauses`; *pause*): the pause of a group, or the global pause (*vacances*) covering every card. The cards stay reviewable in the app; at the end of the pause, their [due dates](#due-date) move by its length.

### Notification moment

Moment at which a scheduled card is notified (`DeliveryPlanner`). It is usually its [due date](#due-date), but a time range spreads the cards of a day over the range.

### Wake-up

A moment at which the app is woken up by an alarm to show what is due (*réveil*). Wake-ups are planned from the [notification moments](#notification-moment); the notifications themselves are built when the wake-up fires.

### Bonus review

An answer to a card that is not due (*révision bonus*), pending cards included. It is written to the history but changes neither the step nor the due date, and a pending card stays pending.
