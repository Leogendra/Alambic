# Lexicon — Alambic

The only place where terms are defined. Specs link here instead of redefining them. The name used in the code is given in parentheses; the French interface word follows when it differs.

## Terms

### Card

A front / back flashcard (`Flashcard`; *carte*). Each face holds plain text and/or an image. A card always belongs to one [group](#group) and has a single progression: its state, [step](#step), [due date](#due-date) and history. Its states are [pending](#pending), active (walking its sequence), in [remanence](#remanence) and [acquired](#acquired) (`CardState`).

### Pending

State of a card never introduced (`CardState.pending`; *en attente*). Every new card starts there, at the end of the [queue](#queue) of its group, with no due date. Only the [distillation](#distillation) of its group introduces it; resetting a card sends it back there.

### Queue

The pending cards of a group, in a fixed order that is the only one (`queuePosition`; *file*): the [distillation](#distillation) takes its head. A card created in the group, moved into it while pending, or reset, joins its end, and so does a bulk add, as a whole batch. A pending card missed in "Review all" goes to its head.

### Distillation

A permanent setting of a group that introduces its [pending](#pending) cards a few at a time, "N cards every X days" (`Distillation`; *distillation*). A group has at most one; it does not exist until the user activates it, and afterwards is only adjusted, paused or resumed. It never stops nor ends: a card added later joins the [queue](#queue) and arrives at the same rhythm.

### Asked side

The face shown as the question of a display (`CardSide`; *face posée*). It is the front, unless the group has [the back](#back-option) enabled, in which case every display draws front or back at random. It changes nothing to the progression of the card.

### Back option

Option of a group (`CardGroup.reverseEnabled`; *verso*) that makes each display of its cards ask the front or the back, one chance in two.

### Group

A flat list of cards sharing a [preset](#preset) (`CardGroup`; *groupe*), with its [distillation](#distillation), its [back option](#back-option), its end of sequence ([remanence](#remanence) or [acquired](#acquired)) and its [typed answer](#typed-answer) option. Every card is in a group.

### Preset

The rhythm of the reviews (`Preset`): interval sequence and behaviour on failure. It says nothing of when in the day nor how a card is notified: that is the [schedule](#schedule) of the app. A group picks a whole preset or inherits the global one; a card follows its group.

### Step

Position of a card in its preset's sequence (`step`; *cran*): the index of the interval currently waited. A card never answered has no step.

### Remanence

End of sequence of a group (`AfterLastStep.remanence`, `CardState.remanent`; *rémanence*): past the last [step](#step) of its preset, a card comes back forever at a fixed interval of the group (`RemanenceInterval`: 3 months, 6 months or 1 year), or at its last step when that is longer. It counts as one more step after the last one.

### Acquired

The other end of sequence of a group (`AfterLastStep.acquired`, `CardState.acquired`; *acquise*): past the last [step](#step), the card has no due date any more.

### Typed answer

Option of a group (`CardGroup.typedAnswer`; *réponse tapée*): its cards whose answer face has text are answered by typing that text, compared leniently, instead of saying "Correct".

### Due date

Moment when a card becomes [due](#due) again (`dueAt`; *échéance*). For an interval of a day or more, it is the [daily slot](#daily-slot) on the target day; for a shorter interval, the answer moment plus the interval.

### Schedule

When the reviews are notified (`ReminderSettings`; *horaire*): a fixed time (12:00 by default) or a time range. One for the whole app, set in Settings with the notification mode (one notification per card, or one grouped reminder per group).

### Daily slot

Time of day at which the due dates of a day or more fall (`ReminderSettings.dailySlot`): the fixed time of the [schedule](#schedule), or the start of its time range.

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

An answer to a card that is not due (*révision bonus*), pending cards included. It is written to the history but changes neither the step nor the due date, and a pending card stays pending (missed in "Review all", it still goes to the head of its [queue](#queue)).
