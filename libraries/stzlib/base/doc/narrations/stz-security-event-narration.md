# The Security Event
### A refusal is an event — typed at birth by the gate that refused, redacted by construction, correlated for free

> Every code block below is real, and every output block is its actual
> output (the run lives in `base/test/system/_secevent_narration_demo.ring`;
> the guard suite is `base/test/system/security_event_narrated.ring`, 49
> assertions). Incident analysis I0 —
> `doc/design/SOFTANZA_INCIDENT_ANALYSIS.md`.

## What the library was throwing away

Softanza detects a great deal. A WebAuthn signature counter that fails
to advance — the textbook cloned-credential signal. A SAML assertion
presented twice. An HMAC that does not match. A nonce reused for the
same key. A sandboxed actor reaching for an effectful capability.

Each of those is detected today, explained honestly to whoever called,
and then **forgotten**: the explanation goes into a `Why()` slot that
the next call overwrites. Nothing is timestamped, so nothing correlates;
the second attempt looks exactly like the first. The security doc
already names the cure in one line — *"A refusal is an event, not a
silent failure"* — and I0 is that sentence given a shape.

## Six questions, closed fields

An event answers what happened, who tried, which thing, how it ended,
why, and when — and it gets those facts **from the gate that produced
them**, never from parsing text afterwards:

```ring
oE = StzSecurityEvent("secret.reveal.refused")
oE.ByActor(oLlm).About(oSecret).Doing("reveal").AtRisk(4)
oE.Refused("actor is not effectful")
oE.Show()
```
```
Security event secret.reveal.refused [error]
  a secret reveal was refused
  REFUSED secret.reveal.refused by advisor (sandboxed) on <secret 'stripe-live' (secret) from literal> -- actor is not effectful
  at 1785492119737 (wall), 43.51 (mono)
  ATT&CK T1552
```

Read what arrived without being told: the severity (`error`) and the
ATT&CK technique (`T1552`, credentials from password stores) came from
the **closed kind catalog**; the actor's name, its `sandboxed` posture
and its capability set came from the `stzSystemActor` itself; the
reason is the gate's own words. Nothing was inferred, and a SIEM will
not have to guess any of it back.

Both clocks are stamped at the moment of *detection*: wall time for the
forensic "when", monotonic for ordering that survives an NTP
correction (the perf grind's clocks-are-scopes law, inherited).

## The redaction law, enforced by construction

An incident record must never become the breach it describes. The
secret above was created with a real-looking literal value — and the
event carries its **descriptor**:

```ring
? "the value 'sk_live...' appears in the event: " + (StzFindFirst("sk_live", oE.ToOcsfJson()) > 0)
? "what the subject says instead   : " + oE.Subject()
```
```
the value 'sk_live...' appears in the event: 0
what the subject says instead   : <secret 'stripe-live' (secret) from literal>
```

This is structural, not a convention: `About()` asks an object for its
`Descriptor()`, and the only way to get a value out of an `stzSecret` is
`Reveal(effectfulActor)` — which this class never calls. The guard
proves the value is absent from the subject, the canonical form, the
human line, *and* the JSON that leaves the process.

## Correlation, free

Inside a trace scope — and an observed appserver opens one per request
— the event stamps the active trace id, exactly as `stzLog` does:

```ring
StzOpenTraceScope("")
# ... an event and a log line, written by unrelated code ...
StzCloseTraceScope()
```
```
event trace : 881702bc4503da9ab5191f4b91fb5750
log   trace : 881702bc4503da9ab5191f4b91fb5750
same story  : 1
```

Two objects that know nothing about each other, one identity. That is
the backbone the I5 incident timeline will pull on, and it cost nothing
to acquire because P9 already built it.

## Speaking OCSF from day one

The house interop rule (a native shape *and* an industry
serialization, from the first phase) applies here as it did to spans
and metrics. OCSF is the schema modern SIEMs ingest:

```ring
? oEvt.ToOcsfJson()
```
```
{"category_uid":6,"class_uid":6003,"time":1785492119740,"severity_id":4,"status_id":2,"message":"REFUSED sig.nonce.replayed by peer-3 (external) on key:billing from 10.0.0.7 -- nonce already used for this key","actor":{"user":{"name":"peer-3"}},"metadata":{"product":{"name":"Softanza","vendor_name":"Softanza"},"version":"1.0.0"},"metadata_trace_id":"881702bc4503da9ab5191f4b91fb5750","unmapped":{"kind":"sig.nonce.replayed","outcome":"refused","reason":"nonce already used for this key","subject":"key:billing","posture":"external","action":"","risk":0,"origin":"10.0.0.7","attack_technique":"T1550"}}
```

`auth.*` maps to Authentication (category 3 / class 3002), `http.*` to
HTTP Activity (4 / 4002), everything else to API Activity (6 / 6003);
severity and status map to OCSF's own ids. The mapping is deliberately
conservative, and everything that does not map cleanly rides in
`unmapped` — which is precisely what that OCSF field is for. Better an
honest `unmapped` than a confidently wrong class id.

## Honest limits

The catalog is closed: an unknown kind refuses at construction, with
the known kinds listed. That is deliberate for I0 (the names are an
API, like `http.request.ms`), and app-defined kinds are an open
question for I3, when detections start referring to kinds by name.
Kinds are **strings**, not `:symbols` — Ring parses `:a.b.c` as `:a`
followed by member access, so a dotted catalog name must be quoted.

And the honest scope note: an event that is built and dropped is no
better than a `Why()` slot. I0 only makes remembering *possible*;
**I1** gives it a hash-chained ledger to live in, and **I2** wires the
thirteen seams that currently detect and forget.
