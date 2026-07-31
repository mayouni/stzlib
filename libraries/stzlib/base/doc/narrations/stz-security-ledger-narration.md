# The Security Ledger
### Evidence, not logging: a hash chain that notices when someone edits the past

> Every code block below is real, and every output block is its actual
> output (the run lives in `base/test/system/_secledger_narration_demo.ring`;
> the guard suite is `base/test/system/security_ledger_narrated.ring`, 35
> assertions). Incident analysis I1 —
> `doc/design/SOFTANZA_INCIDENT_ANALYSIS.md`.

## What "audit log" usually means

It usually means a text file. Anyone who can write to it can rewrite
it, and nothing about the file objects. "Trust me, it's in the log" is
not a security property — which is why the industry built hash chains,
transparency logs and WORM storage around the idea that *the record of
what happened must be harder to change than what happened*.

I0 gave refusals a shape. I1 gives them a memory of that kind.

## Recording

```ring
oLed = StzSecurityLedger(256)
oLed.Record(StzSecurityRefusal("auth.login.failed", HumanActor("admin"), "user:admin", "bad password"))
oLed.Record(StzSecurityRefusal("sig.nonce.replayed", HumanActor("peer-3"), "key:billing", "nonce already used for this key"))
oLed.Record(StzSecurityRefusal("secret.reveal.refused", LLMActor("advisor"), "secret:stripe-live", "actor is not effectful"))
oLed.Show()
```
```
Security ledger -- 3 event(s) recorded, 3 retained of 256, chain intact.
  REFUSED auth.login.failed by admin on user:admin -- bad password
  REFUSED sig.nonce.replayed by peer-3 on key:billing -- nonce already used for this key
  REFUSED secret.reveal.refused by advisor on secret:stripe-live -- actor is not effectful
```

Three refusals that, before this phase, would have existed only as
strings returned to whoever asked — and then not at all.

## The chain

Each entry's digest is computed over **the previous digest plus this
entry**:

```
digest[i] = sha256( digest[i-1] || "|" || canonical[i] )
```

so the head digest is a commitment to the entire history, and any edit
to any entry invalidates everything after it:

```ring
? "head digest : " + oLed.Digest()
? "verify      : " + oLed.Verify()[:message]
```
```
head digest : c2441958fcfb2af96c386c55c153450f117616fc896c8bf659bb4709d45ed7bb
verify      : chain intact over 3 retained entr(ies)
```

The chain is computed **in the engine**, never handed in from Ring —
a caller that could supply its own digest could forge history. The
guard proves the commitment property directly: two ledgers whose last
event is byte-identical but whose earlier history differs by one
character produce different head digests.

## The pivots an investigation actually uses

```ring
? "refusals            : " + len(oLed.Refusals())
? "about that secret   : " + len(oLed.OfSubject("secret:stripe-live"))
? "by the sandboxed llm: " + len(oLed.OfActor("advisor"))
```
```
refusals            : 3
about that secret   : 1
by the sandboxed llm: 1
```

Plus `OfKind`, `OfTrace`, `OfOutcome`, `OfSeverity`, `OfOrigin`,
`Since`, `Between`, `Recent`. And because I0 events capture the active
trace scope, `OfTrace(id)` fetches the security events of a request
while `stzLog.OfTrace(id)` fetches its log lines — one story, two
stores, no coordination needed.

## Someone edits the evidence

`SealTo()` writes the retained window as a verifiable file: one
`digest → canonical` line per entry, plus an HMAC seal over the head
digest and count (this is the phase's one engine addition — HMAC-SHA256
existed inside PBKDF2 and TOTP but was never exported, so nothing could
seal a payload with a key). Then we do what an attacker would do —
edit the file so the refusal reads as routine:

```ring
oLed.SealTo(cPath, "the-evidence-key")
? "fresh export  : " + StzVerifySealedLedger(cPath, "the-evidence-key")[:why]
# ... rewrite "actor is not effectful" to "routine maintenance" ...
? "after an edit : " + StzVerifySealedLedger(cPath, "the-evidence-key")[:why]
```
```
fresh export  : ok=1 -- chain intact over 3 entries
after an edit : ok=0 -- the chain breaks at entry 3 -- that record (or one before it) was edited
```

The edit is not merely detected — the broken **link is named**. The
guard also proves the third case: an auditor holding the *wrong* key
gets "the chain is intact but the SEAL does not match this key", which
is a different accusation from "someone edited the file", and an
investigation needs to tell those apart.

## Honest limits, stated plainly

- **Bounded means forgetting.** Past capacity the oldest entries give
  way; `Count()` keeps counting, `Size()` is what remains, and the head
  digest still commits to everything ever recorded. A long, slow
  campaign outruns the window unless it is sealed out. The guard runs a
  3-slot ledger through 5 events to show exactly this.
- **Verification after eviction is a window property.** The first
  retained entry's predecessor is gone, so `Verify()` checks the
  consistency of what remains.
- **This is not protection against an attacker already running code
  in the process** — such an attacker can append or wipe the ring.
  Hash chaining detects *retroactive edits*; the keyed seal protects an
  *export*. Evidence-grade means exported, and I1's job is to make the
  export worth trusting.

One small correctness note from building it: the canonical line is
pipe-separated, so a field's own pipes are folded to `/` at the source.
Sanitizing where the value is created beats parsing bravely later —
otherwise a reason quoting `a|b|c` would shift every field after it,
and the ledger would confidently report the wrong wall clock.

**I2** is next, and it is the phase that matters most: wiring the
thirteen seams that currently detect and forget, so this ledger fills
itself.
