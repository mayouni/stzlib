# Detection over Sequences
### Every other rule in the library judges one moment — an incident is a story

> Every code block below is real, and every output block is its actual
> output (the run lives in `base/test/system/_secdetect_narration_demo.ring`;
> the guard suite is `base/test/system/security_detection_narrated.ring`,
> 33 assertions). Incident analysis I3 —
> `doc/design/SOFTANZA_INCIDENT_ANALYSIS.md`.

## The shape the library never had

Softanza is full of rules. A graph rule asks whether a sandboxed actor
can reach an effectful capability. A posture invariant asks what is
true of the system right now. An org rule asks whether one position
both approves and executes. Every one of them judges **structure at a
single instant**.

But "five failed logins inside a minute" is not a structure — it is a
*sequence*. "A failed sign-in, then a reach for a production secret" is
a story with an order and a clock. No rule shape in the library could
express that, which is why I2's ledger, useful as it is, still needed a
reader.

## Three shapes, deliberately few

```ring
oD = StzDetection("credential-stuffing")
oD.WhenKind("auth.login.failed").PerActor().Repeats(5).Within(60000)

oD2 = StzDetection("guess-then-reach")
oD2.WhenKind("auth.login.failed").ThenKind("secret.reveal.refused")
   .BySameActor().Within(300000)

oD3 = StzDetection("cloned-authenticator")
oD3.WhenKind("auth.passkey.clone_suspected").OnAnyOccurrence()
```

**BURST** (n of a kind inside a sliding window), **SEQUENCE** (b within
a window after a), **ANY** (one occurrence is already the story — a
cloned authenticator needs no second opinion). Three, not thirty: each
is computable over a bounded ledger without inventing a query language,
and together they cover the shapes the library's own catalog can
produce.

`PerActor()` matters more than it looks: credential stuffing is per
*account*, not per installation. The guard proves the difference —
nine failures spread across two accounts fire the grouped detection
once (for the account that actually burst) and the ungrouped one once
(for the installation).

## What the library ships knowing

Detection content is usually something you buy or write. Softanza ships
eight detections over its own catalog, because it *knows its own event
names*:

```ring
StzDefaultDetectionSet().Show()
```
```
Detection set softanza-default -- 8 detection(s).
  Detection credential-stuffing [error] -- 5x auth.login.failed within 60000ms, per actor
    repeated authentication failures against one account
  Detection secret-probing [error] -- 3x secret.reveal.refused within 300000ms, per actor
    an actor repeatedly reaching for secrets it may not have
  Detection escalation-attempts [error] -- 3x capability.refused within 60000ms, per actor
    an actor repeatedly attempting acts beyond its capabilities
  Detection guess-then-reach [error] -- auth.login.failed then secret.reveal.refused within 300000ms, same actor
    a failed sign-in followed by a reach for a secret -- the classic shape of a stolen-credential attempt
  Detection cloned-authenticator [error] -- any auth.passkey.clone_suspected
    a signature counter that did not advance
  Detection replayed-request [error] -- any sig.nonce.replayed
    a nonce reused for the same key -- an active replay
  Detection forged-request [error] -- any sig.signature.forged
    a signature that did not verify -- forged, tampered, or wrong key
  Detection replayed-assertion [error] -- any sso.assertion.replayed
    a SAML assertion presented twice
```

## The whole arc, on a real run

Nothing scripted below: a real `stzAuth` refuses five real bad
passwords, a real `stzSecretStore` refuses a real sandboxed actor, the
I2 seams fill the ledger, and the detections read it.

```ring
StzOpenSecurityLedger(512)
# ... five failed logins for 'victim', then an LLM actor reaches for stripe-live ...
aFindings = StzDefaultDetectionSet().CheckAgainst(StzSecurityLedgerQ())
```
```
the ledger holds 7 event(s)
  [error] credential-stuffing/victim -- 5 x auth.login.failed within 60000ms by 'victim' -- repeated authentication failures against one account
  [error] guess-then-reach/victim -- auth.login.failed then secret.reveal.refused within 68ms by 'victim' -- a failed sign-in followed by a reach for a secret -- the classic shape of a stolen-credential attempt
```

Two findings for two real stories, from events nobody wrote by hand.

## A defect the demo caught: one story, one finding

The first implementation reported that second story **five times** —
each of the five failed logins pairs with the same secret reach, so
five pairs matched. Technically correct, operationally useless: a
detection that repeats itself per matching pair is how alert fatigue
starts, and alert fatigue is how real alerts get ignored.

The fix is one finding per actor per detection, and the guard now pins
it so it cannot come back. Worth stating as a rule: **a detection's
job is not to report every match, it is to report every story.**

## The corroboration law

> One anomalous read is a rumor.

`Corroborated()` marks a detection that must not raise an
error-severity alarm on a single signal. If the matched evidence spans
fewer than two distinct event kinds, the finding is emitted as a
**warning that says so**:

```
lonely-signal -- auth.passkey.clone_suspected occurred (single signal: reported as a warning until a second, independent signal corroborates it)
```

The sequence shape satisfies corroboration by construction — it spans
two kinds by definition — so the same flag leaves it at error. This is
the perf system's fifth law (a self-check compares two *independent*
measurements) wearing security clothes.

## It fails the same build

Verdicts are findings in the unified rule shape, so no adapter is
needed anywhere:

```ring
oRep = new stzRuleReport("nightly-ci")
oRep.Ingest(aFindings)
? "IsSound() = " + oRep.IsSound()
```
```
IsSound() = 0
Rule report 'nightly-ci': 2 finding(s), 2 error(s), 0 warning(s) -> UNSOUND (errors present)
```

A tripped detection now fails CI exactly as a capability escalation or
a code-rule violation does — one gate over code, agents, security,
workflow, orgcharts, and now incidents. And a quiet ledger keeps the
gate sound, which the guard also checks: a detector that cannot stay
silent is not a detector.

## Honest limits

Detections read the **retained window** — bounded means forgetting, and
a campaign slower than the ledger's capacity outruns it unless sealed
out (I1's export). Windows use wall time, so a clock adjustment moves
them; ordering within the process is monotonic, but cross-process
correlation is wall-based by necessity. There is no baseline learning,
no frequency modelling, no threat intel: these are *declared* patterns,
which is exactly what makes them reviewable and version-controllable.

**I4** gives them a heartbeat — the sentinel that runs detections on a
cadence, fires on transitions only, and opens an incident from what
fired.
