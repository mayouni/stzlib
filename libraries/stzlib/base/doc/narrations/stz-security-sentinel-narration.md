# The Sentinel
### Alarms on transitions, not on states — and a case photographed the moment one fires

> Every code block below is real, and every output block is its actual
> output (the run lives in `base/test/system/_secsentinel_narration_demo.ring`;
> the guard suite is `base/test/system/security_sentinel_narrated.ring`,
> 33 assertions). Incident analysis I4 —
> `doc/design/SOFTANZA_INCIDENT_ANALYSIS.md`.

## From asking to watching

I3's detections judge when asked. Somebody still has to ask, and an
investigation that begins with "did anyone look at the ledger today?"
has already lost. The sentinel asks on a cadence — and, crucially,
speaks only when something **changes**.

```ring
StzOpenSecurityLedger(512)
oSent = StzSecuritySentinel(StzDefaultDetectionSet())
oSent.OnDetection(func aFinding { ... })
oSent.OnClear(func cWhere { ... })
```
```
quiet system      : 0 alert(s)
after five guesses:
  >> ALERT [error] credential-stuffing/victim
     5 x auth.login.failed within 60000ms by 'victim' -- repeated authentication failures against one account
still under attack:
  0 new alert(s) -- the story did not restart
```

Read the last line twice: the attack is *still happening* — another
failed login just arrived — and the sentinel says nothing new. The
alarm fired when the story began, and it will speak again only when the
story genuinely ends and returns. This is the same edge-triggering the
perf system settled on, and it is the difference between an alert an
operator reads and an alert an operator filters.

## What counts as "a story"

The identity of a firing is the finding's `:where` —
`credential-stuffing/victim`, not merely `credential-stuffing`. So:

- one account under sustained attack is **one** story, no matter how
  long it lasts;
- a **second** account under attack is a **second** story, fired
  separately (the guard proves both);
- and when the evidence ages out of the ledger's window, the story
  **clears** — with its own callback and its own channel — so a
  returning attack is honestly a new alarm rather than a duplicate.

That last property is why the sentinel keeps an alert log of both
kinds: the guard asserts the sequence `fire, fire, clear, clear, fire`
end to end.

## The case, photographed at the moment of firing

An investigation that starts hours later inherits a window that has
moved on. So when something fires, the sentinel takes a picture:

```ring
aCase = oSent.LastCase()
```
```
the case, photographed when it fired:
  story        : credential-stuffing/victim
  severity     : error
  ledger held  : 6 event(s)
  head digest  : 462edef3afcc78cdc713472d...
  nearest events:
    auth.login.failed by victim   (x5)
    auth.lockout.engaged by victim
```

The head digest matters more than it looks: it is I1's chain head, a
commitment to *the entire history as it stood at that instant*. If the
ledger is later edited, the case's digest and the ledger's no longer
agree — the snapshot is evidence about evidence. And the nearest
events are the seed of the timeline I5 will build, so the
investigation will not have to re-derive the moment of detection.

Notice something the demo did not have to arrange: the sixth event in
that picture is `auth.lockout.engaged`. The library's own defence
fired during the attack, and the case records both the attack and the
response — because both went through seams in I2.

## Three ways to run it, one of them hands-free

`Check()` when you like; `Every(ms)` + `Tick()` from a loop you
already run; or — the one that matters — `Name_()` + `Cycle()`, the
house agent contract, so **any `stzAgentHost` supervises it**:

```ring
oHost.Supervise(oSentinel, 50)
oHost.RunFor(260)
```
```
the host ticked the sentinel 6 time(s)
```

The guard runs exactly that, with a replayed-nonce event planted in
the watched ledger, and asserts the hosted copy fired on it. Since
`stzAppServer` hosts agents on this same contract, a served
application can watch its own security while it serves — no separate
process, no cron, no forgetting.

Every transition also fans out on the process-global event bus
(`sec.detection` / `sec.clear`), so an agent supervised *on that
channel* wakes exactly when something fires.

## One thing deliberately not done

The sentinel does **not** write its own firings into the ledger as
events. Detections over detection-events invite feedback loops, and
the ledger is a record of what the *system* did, not of what the
watcher thought about it. The alert log is the watcher's own memory,
kept separately and bounded — 256 alerts, 16 cases, the house
bounded-store law.

## Honest limits

A detection stays "active" as long as its evidence remains in the
ledger's retained window, so window size and eviction determine when a
story clears — bounded means forgetting, and here forgetting is also
what makes a re-alarm possible. The cadence is monotonic-clocked, but
the detections it runs judge wall-time windows. And the sentinel's
transition state is Ring-side: one face drives `Check()`, every face
reads the same ledger.

**I5** turns a case into an **incident**: the timeline, the actors, the
attack path from the security graph, the blast radius of whatever
secret is implicated — the file a person actually reads at 3 a.m.
