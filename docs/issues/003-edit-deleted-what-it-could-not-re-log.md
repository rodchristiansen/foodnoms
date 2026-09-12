# 003 — `edit` deleted the entry and re-logged nothing

**Status:** fixed · **Opened:** 2026-09-12 · **Fixed:** 2026-09-12 · **Affects:** `foodnoms edit`

`foodnoms edit <entry> --scale 0.5` deleted the entry, reported success, and left the day
short. Splitting a lunch across two meals ran it seven times: seven entries deleted, three
reported "reduced", four queued a re-log that the drain then marked done, and 732 kcal left the
day with every command exiting zero.

## What is actually wrong

Three failures stacked, each hiding the one under it.

1. **The re-log called a command that does not exist.** `edit` dispatched `log-food` through
   the bridge. `intents.yaml` defines `log`, `log-meal`, `create-food`, `delete`, `entries` and
   `goal` — never `log-food`. The bridge's dispatcher matched no branch and did nothing.

2. **The confirmation matched by name.** After the delete, `edit` polled for an entry with the
   same name and quantity. A split logs the moved share first, so a same-named entry was
   already on the day; three of the seven matched it and reported success. `dispatch` and the
   queue drain had the same flaw, which is why the queued re-logs were marked done without
   being written (fixed separately — see the 0.6.0 notes).

3. **The delete addressed the first entry of that name.** `matches[0]` is the same entry as the
   one being edited only when the day holds one of them.

## What cannot be fixed here

Nothing dispatched at run time can re-log a library food. `LogIntent.food` is an entity, and an
entity binds only from a literal written into the action when it is generated, or from another
action's output; `SearchFoodLibraryIntent` and `SearchFoodnomsDatabaseIntent` both open FoodNoms'
picker and block. A real-food entry can only be written by a Shortcut built with that food in it.

So `edit` now says so instead of pretending. It refuses unless `--quick-entry` says the caller
accepts a name-and-macros replacement, it logs the replacement *before* deleting the original,
and it deletes the occurrence it actually edited. A double-counted day is visible and one delete
from correct; a deleted entry whose replacement never landed is silent and unrecoverable.
