# Attestation and Export
### Evidence that proves itself, a statement that explains it, and a door only a sensing actor may open

> Every code block below is real, and every output block is its actual
> output (the run is `base/test/system/security_attest_narrated.ring`,
> 34 assertions). Incident analysis I7 —
> `doc/design/SOFTANZA_INCIDENT_ANALYSIS.md`.

## What I1 left unfinished

I1 made the ledger hash-chained and sealable, which makes a file
**tamper-evident**. That is necessary and not sufficient. An auditor
holding the file still has to ask: who exported this, when, over what
range, under which key, and how do I check it? Those questions are
answered by a *custody statement*, not by a hash.

## The statement

```ring
oAtt = StzSecurityAttestation("nightly-evidence")
oAtt.Of(oLedger).SealedWith("the-evidence-key")
oAtt.WriteTo("evidence.stzledger", oHumanActor)
oAtt.Show()
```
```
Attestation nightly-evidence
  file      : _tmp_attested.stzledger
  attestor  : mansour
  at        : 1785510016221 (epoch ms, wall)
  entries   : 7
  chain head: 8898eb4291676c01e1ab43b2360efe596d8ca55aac4a6a53bad23199840b990e
  seal      : keyed HMAC-SHA256 over (head digest | count)
  verify    : StzVerifyAttestation(path, key) -- recomputes
              sha256(prev|record) down the file and names the
              first broken link, then checks the seal.
  note      : entries are DESCRIPTORS -- no secret value is
              present in this evidence by construction.
```

The file now carries the attestor and the timestamp in its own header,
so verification reports them back:

```
chain intact over 7 entries      (attestor: mansour)
```

And the two failure modes stay distinguishable, which is the whole
point of separating a chain from a seal: a **wrong key** says *"the
chain is intact but the SEAL does not match this key"*, while an
**edited file** says *"the chain breaks at entry 2 — that record (or
one before it) was edited"*. The guard performs both.

## Exporting the evidence is itself governed

Here is a rule that only becomes obvious once the ledger is good: **the
ledger is a map of what is worth attacking.** It names actors,
subjects, origins, and every refusal — precisely the reconnaissance an
attacker would want. So reading it *out of the process* is a
capability-gated act:

```ring
? oAtt.MayAttest(LLMActor("advisor"))        # inference only
? oAtt.MayAttest(GuardianActor("auditor"))   # compute + sensing
? oAtt.MayAttest(HumanActor("mansour"))      # effectful + sensing
```

The inference-only actor is refused — *"lacks the sensing capability"*
— and the refusal is recorded as an event. Note what this is **not**:
it is not the effectful gate. Exporting does not change the system, so
demanding `effectful` would have been the wrong lattice line; reading
is `sensing`, and a guardian may do it. The library already had the
right vocabulary for a distinction this system had not needed until
now.

The export itself is also an event (`evidence.exported`), so the ledger
carries its own custody history: who read it out, and who was refused.

## Speaking the industry's formats, in batch

Per-event OCSF has existed since I0. I7 ships the collector-shaped
forms:

- `ToOcsfNdJson()` — one OCSF event per line, what a collector ingests
  as a stream (the guard checks six events, six lines);
- `ToOcsfJson()` — the same as one JSON array;
- `ToOtelLogsJson()` — the OTLP logs envelope, the *same shape*
  `stzLog` ships since perf P9, so security events and log lines arrive
  at one collector looking like what they are: records of the same run,
  sharing trace ids.

And the incident exports as an **OCSF Security Finding** (class 2001) —
the class a SIEM expects for "something was concluded", as distinct
from the raw events:

```
{"category_uid":2,"class_uid":2001,...,"unmapped":{"actor":"billing-agent",
 "attackPath":["billing-agent","deploy-tool","effectful"],
 "secrets":["stripe-live"],"headDigest":"..."}}
```

The attack path, the implicated secrets and the chain head ride in
`unmapped`, which is exactly what that OCSF field exists for — honest
placement beats a confidently wrong mapping.

## The redaction law, at the door

Every export is checked: no secret value appears in the OCSF batch, the
OTLP envelope, the finding, or the sealed file. That is not a promise
made by the exporter — it is inherited, because everything exported was
built from events, and an event has carried descriptors only since I0.
Seven phases later, the law still holds without a single special case.

## Honest limits

The seal proves *this file was produced by someone holding the key over
this chain*; it does not prove the key stayed secret, and anyone
holding it can re-seal an edited file. That is what key custody means
and no format fixes it. There is no signature over a public key
(Sigstore-style transparency is a different, larger commitment), no
automatic retention or rotation of evidence files, and no push
transport — writing the file is the boundary; shipping it to a
collector is the collector's job.

**I8** is the last phase: the drill — firing real bad sequences at a
real spawned app to prove the detections fire and the incident
reconstructs, because a detection nobody has ever seen fire is a
hypothesis.
