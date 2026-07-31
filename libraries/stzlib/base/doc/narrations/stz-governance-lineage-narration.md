# Answerable Forever

### The second bug-shaped finding, and what "forever" turned out to mean

> Every code block below is real, and every output block is its actual
> output (the run is `base/test/governance/governance_lineage_narrated.ring`,
> 27 assertions, ~0.04 seconds). The finding is recorded in
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

## What is still open, and why it is a caveat rather than a defect

The lineage lives in a Ring attribute, so it forks on copy. Every writer
inside the library already delegates through the owning object — the
house pattern, and the reason this has never bitten. But the standing
rule is sharper than that: *an object that governs others should keep
its state in a handle table, so that every copy IS the object*. Moving
`stzGovernance` there is a refactor with a wide blast radius, not a fix,
and pretending otherwise in a one-line change would be how the previous
promise got made.

---

Four defects behind one comment. The comment is now true.
