# Answerable Forever

### The second bug-shaped finding, and what "forever" turned out to mean

> Every code block below is real, and every output block is its actual
> output (the run is `base/test/governance/governance_lineage_narrated.ring`,
> 37 assertions, ~0.01 seconds). The finding is recorded in
> `doc/design/SOFTANZA_INCIDENT_ANALYSIS.md` section 1.

## The comment that was making a promise

`stzGovernance.RecordDecision` carried this comment:

> a decision records its rationale AND the actor's authority + the
> action's risk AT THE TIME — 'why does this look the way it does'
> stays answerable forever

Everything before the dash was true. The last four words were not. The
incident study named it as one of two bug-shaped findings worth fixing
regardless of the incident plan — and unlike the other one (scope and
posture refusals that no audit ever recorded, closed in I2), this one
had four separate problems wearing one name.

The lineage had **no timestamps**. It was **queryable only by an id you
already knew**. It **grew without bound**. And `Save()` wrote the
regime — risks, permissions, authorities, postures — and **left the
lineage behind entirely**, so every reason the regime looked the way it
did died with the process holding it.

## When, and about what

```ring
oGov.RecordDecisionAt("d-101", "peak-season pricing adjustment",
    "billing-agent", "send-invoice", $T0)
aD = oGov.LineageOf("d-101")
```
```
  [OK] the rationale survives
  [OK] ...with the authority AT THE TIME
  [OK] ...the risk at the time
  [OK] ...and now the moment it was taken
  [OK] the ACTION is kept beside its tier
```

Without a time, a lineage cannot say whether a decision came before or
after the change it is meant to explain — which is the first question
anyone asks of it. The clock is the **wall** clock deliberately: this is
an absolute "when in the world", not a duration, and epoch milliseconds
stay exact in an f64 where nanoseconds would not.

The action needed keeping too. The original row stored only the risk
*tier*, so two unrelated tier-3 decisions were indistinguishable and
"what was decided about `send-invoice`" could only ever be answered with
confident nonsense.

## An audit trail you can only query by a known key is a lookup table

```
  [OK] what did this actor decide?
  [OK] who decided anything about this action?
  [OK] ...and the other action is not swept in
  [OK] what was decided after this moment?
  [OK] ...and inside this window?
  3 decisions, reachable five ways
```

`LineageOf(id)` answered exactly one question, and it was the question
you ask *last* — after something else has already told you which
decision to look up. The pivots an investigation opens with are by
actor, by action, and by time window.

`LineageOf` also used to return the *first* match. Now the latest wins,
because a re-decision supersedes — and the earlier ones stay reachable:

```
  [OK] the LATEST answer wins
  [OK] ...and the earlier one is still reachable
  [OK] the history is in the order it happened
```

## Bounded, and honest about it

```ring
oGov.SetLineageCapacity(2)
```
```
  [OK] lowering the bound drops the OLDEST
  [OK] ...counts them
  [OK] ...and no longer claims to be complete
  [OK] the survivors are the most recent
  2 decision(s) dropped by a capacity of 2
```

An unbounded list that grows for the life of a long-running process is a
leak wearing an audit trail's clothes. A bounded one that drops
**silently** is worse: the gap reads as a period during which nothing was
decided. `LineageDropped()` and `LineageIsComplete()` are the difference
between the two, and they are the whole reason the bound is acceptable.

## The section `Save()` threw away

```ring
oReg.RecordDecisionAt("d-201", "raised the tier after the audit | see ticket 4471",
    "billing-agent", "send-invoice", $T0)
cFile = oReg.Save("t_gov_lineage")
oBack = new stzGovernance("")
oBack.LoadFrom(cFile)
```
```
  [OK] the regime still judges after the round trip
  [OK] ...and the lineage came with it
  [OK] the moment survived the file
  [OK] the action survived
  [OK] a rationale containing the field separator is INTACT
  raised the tier after the audit | see ticket 4471
```

The regime is what the rules **are**; the lineage is **why**. Persisting
one without the other keeps only the half a reader can already see by
looking at the rules.

That last assertion earned its place. The `.zgov` format is
pipe-separated, the rationale goes last, and the loader rejoins the
tail — but the first attempt trimmed each segment *before* rejoining, so
`audit | ticket` came back as `audit| ticket`. A round trip that alters
the text it claims to preserve is not one. Rejoin raw, trim once.

## The file records what WAS true

```
  [OK] the regime changed
  [OK] ...and the decision still reports the tier it was taken under
```

Authority and risk are read **from the file**, never recomputed on load.
Recomputing them would let a changed regime quietly rewrite its own
history — the single thing a lineage exists to prevent.

## A loader that reads its own format's future

Adding a section exposed something the old loader did by accident. It
recognised its four section names by literal comparison, so a header it
did not know left the **previous** section active — and fed that
section's parser rows meant for another. `DeclarePosture` raises on a
value it does not recognise, so a file written by a newer build took an
older build down.

A section header is now anything without a field separator:

```
  [OK] a section this build does not know is stepped over
```

## The fifth defect: a record that forks

The four above were fixed first, and the fifth was left standing with a
note — the lineage lived in a Ring attribute, and Ring's `=` and
attribute-stores **copy**. A governance handed to an agent host, a
constellation or a federation became a snapshot there.

The note said this was a caveat rather than an emergency, and that was
true of the *regime*. Risks, permissions, authorities and postures fork
**fail-closed**: a permission the copy never saw is a permission
refused, an authority it never saw is an authority it will not act on.
A stale regime is over-strict, and over-strict is survivable.

A **record** has no such mercy. It does not fail closed or open — it
silently answers a different question than the one asked. Decisions
taken through the host's copy were invisible to the caller's own handle
and vice versa, so `NumberOfDecisions()` returned a count that was true
of one face and of no other. **An audit trail that is true of one face
is not an audit trail.**

So the rows moved into a table keyed by an id:

```ring
oShared = new stzGovernance("release-ops")
oFace = oShared                    # Ring COPIES on assignment
oFace.RecordDecisionAt("d-301", "shipped from the second face",
    "release-bot", "ship", $T0)
```
```
  [OK] a decision taken through the COPY is visible to the original
  [OK] ...and reads identically from either face
  [OK] ...and the traffic flows both ways
  [OK] the capacity is shared too, not re-defaulted per face
  [OK] ...so a bound set on one face binds the other
  two faces, one record
```

## Then the regime followed it

The argument for leaving the regime in attributes was that its forking
fails closed, and that argument was correct. It was also not enough.

The cost was being paid somewhere else — in a rule the whole library had
to know: **"chain config calls, never assign-then-mutate"**. It exists
because

```ring
oGov = oHost.GovernanceQ()
oGov.GrantPermission("release-bot", "deploy")   # reached nothing
```

quietly reached a copy. Fail-closed made that survivable rather than
dangerous, so it became a convention instead of a bug report. **A rule
every caller must remember in order not to be silently wrong is a defect
with good manners.**

With the regime in the table, the convention is simply unnecessary:

```ring
oOwner = new stzGovernance("deploy-ops")
oHeld = oOwner                            # what an agent host stores
oOwner.DeclareRisk("deploy", 3)
oOwner.GrantPermission("release-bot", "deploy")
oOwner.SetAuthority("release-bot", :Autonomous)
```
```
  [OK] a regime declared on one face judges on the other
  [OK] ...and a posture declared on the other is seen by the first
  [OK] a commitment advanced through the copy advances for both
  [OK] an obligation fulfilled through the copy earns retirement for both
  assign-then-mutate now reaches the object that judges
```

All six lists moved — risks, permissions, authorities, commitments,
decommissions, postures — into one ten-field row. Ten positional fields
across sixty-five call sites is exactly how a field gets read as its
neighbour in the one branch nobody runs, so **every index literal appears
once**, in a pair of one-line accessors, and no method reaches into the
row directly.

## What deliberately did not move

`@cName` is identity, not governed state. And `@cWhy` is the answer to
the last question **this face** asked:

```ring
oA.MayProceed("bot", "ship")        # allowed
oB.MayProceed("nobody", "ship")     # refused
```
```
  [OK] Why() is the answer to the question THIS face asked
```

Sharing it would let one face's question overwrite another face's answer
between the call and the read. It is the one place in this object where
forking is the correct behaviour — which is worth stating, because
"move everything into the table" would have been the tidier rule and the
wrong one.

## Two details carry the weight

**The id is materialized eagerly, in `init()`.** A lazily-created handle
is created once *per copy* and forks silently — which is the exact
failure the table exists to remove, reintroduced by the fix. (A
paren-less `new stzGovernance` skips `init()` entirely, so `_Slot()`
raises with a message that says so, rather than quietly sharing slot
zero with every other paren-less instance.)

**`Release()` is the owner's act alone.** Ring has no destructor, so the
slot has to be freed explicitly; and a *copy* calling it would free
state every other face is still reading. Without it, the table keeps one
slot per governance ever constructed: fine for a regime that lives as
long as the process, a leak for one built per request.

## And the ordering was the point

The lineage moved first and the regime followed, and doing it in that
order was not caution for its own sake. The failure *direction* is what
ranks the work:

- a forked **gate** fails **open** — the emergency
  (`stzServiceRegistry`, which is why that table exists);
- a forked **record** fails **neither** — it answers a different
  question, which is the lineage;
- a forked **rule** fails **closed** — survivable, and therefore last.

Moving the record first fixed the thing that had no safe direction to
fail in, with one section changed. Moving the rules afterwards retired a
convention the whole library had been carrying. Doing both at once would
have been one large diff whose green suites proved less.

---

Six defects behind one comment. The comment is now true.
