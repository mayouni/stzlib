# The Drill
### A detection nobody has ever seen fire is a hypothesis

> Every code block below is real, and every output block is its actual
> output (the run is `base/test/system/security_drill_narrated.ring`,
> 20 assertions, ~3 seconds of real processes). Incident analysis I8,
> the last phase — `doc/design/SOFTANZA_INCIDENT_ANALYSIS.md`.

## Proving it, not asserting it

Seven phases built a system that witnesses, judges, correlates,
contains and attests. Every one of them was guarded — but always with
events the guard itself created. That leaves the honest question
unanswered: *does any of this fire when a real application is really
attacked?*

The drill answers it the way P11's load driver answered the R-vs-X
knee: with real processes.

```ring
oDrill = StzSecurityDrill("nightly")
oDrill.SpawnTarget(0)
oDrill.FireCredentialStuffing("victim", 5)
oDrill.FireForgery()
oDrill.FireReplay()
oDrill.CollectEvidence()
oDrill.Show()
```
```
Drill nightly against 127.0.0.1:38278 -- every expected detection fired.
  evidence : ..._drill_nightly_evidence.stzledger (8 verified event(s), attested by target-process)
  [fired]  credential stuffing (5 bad passwords) -> credential-stuffing
  [fired]  a forged signature -> forged-request
  [fired]  a replayed nonce -> replayed-request
```

Nothing there is simulated. A separate `ring` process runs a real
`stzAppServer` with a real `stzAuth` and a real `stzRequestSigner`. The
bad passwords really fail; the forged MAC really fails to verify; the
replayed nonce really trips the replay cache — in another process,
through a socket.

## The part that makes it forensics

The parent **never touches the target's memory**. It learns what
happened only from evidence the target sealed and the parent verified:

```
acquired 8 verified entr(ies)
```

That single line exercises I1's hash chain, I7's attestation, and the
acquisition path together: the child seals its ledger to a file; the
parent verifies the chain and the seal, and only then rebuilds a
working ledger to analyse. This is exactly the position a real
investigator occupies — and it means the drill's conclusions rest on
the same evidence an auditor would be handed.

The rebuilt ledger recomputes its own chain, and the code says so
plainly: the original chain lives in the file and was just verified;
the copy is a working artifact, never a second original. An
investigator must not mistake a re-derived chain for a sealed one.

Then the acquired evidence goes through the rest of the system
unchanged — the sentinel fires on it, and an incident reconstructs
from it:

```
Incident INC-DRILL (error, open) -- forged-request involving 'drill'
```

## And evidence that was edited is not believed

```ring
# rewrite "victim" to "nobody" in the sealed file, then try to acquire
```
```
the chain breaks at entry 2 -- that record (or one before it) was edited
acquisition REFUSES edited evidence
...and hands back no ledger to analyse
```

Refusing to *analyse* tampered evidence matters more than detecting the
tampering. A tool that verifies, warns, and then analyses anyway
teaches its users to ignore the warning.

## Two defects this phase found in the library

A drill's real value is the bugs it finds, and this one found two
before it found any attacks.

**The route that always said "sealed".** The first seal handler ignored
`WriteTo`'s return value and answered `"sealed"` unconditionally — so a
failure to write looked exactly like success, and the drill sat there
verifying a file that did not exist. The route now reports what it did
(`sealed=1 count=8`). A status that cannot be false is not a status.

**Capability-bearing actors do not survive into a spawned child's
handlers.** An `stzSystemActor` built by `HumanActor(...)` *inside* an
anonymous route handler in a child process came back with **one**
capability instead of three — so the governed-export gate refused a
legitimately entitled actor. Passing one in through a global did not
help either. The drill's target therefore seals its evidence directly
and the governed-export gate is proven where it belongs: in-process, by
the I7 guard, which tests all three actor kinds. Both facts are now
comments at the site and notes in memory.

Neither would have surfaced from another in-process guard. That is the
argument for drills.

## Honest limits

The drill fires the attacks the wired seams can see (I2 left several
seams unwired, and they are listed in the design doc). It is a
**validation** harness, not a fuzzer: it proves that a declared
detection fires on a real instance of the thing it declares — it does
not search for attacks nobody thought of. And the target is an
application the drill generates, so it proves the *library's*
detections, not any particular app's configuration.

---

With I8 the plan is complete: **witness, detect, reconstruct, contain,
attest** — and now, *prove*. Nine guards, three hundred assertions, and
a library that no longer forgets what it detects.
