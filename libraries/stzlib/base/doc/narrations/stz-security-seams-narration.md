# The Seams
### The phase where the library stops forgetting

> Every code block below is real, and every output block is its actual
> output (the run lives in `base/test/system/_secseams_narration_demo.ring`;
> the guard suite is `base/test/system/security_seams_narrated.ring`, 37
> assertions). Incident analysis I2 —
> `doc/design/SOFTANZA_INCIDENT_ANALYSIS.md`.

## One page of output that did not exist before

Three unrelated things happen to a running application: someone probes
a signed-request gateway, someone guesses at the login door, and a
sandboxed agent reaches for a production secret. Every one of those was
already *detected* by Softanza. Not one of them was *remembered*.

```ring
StzOpenSecurityLedger(512)
# ... the gateway probing, the password guessing, the secret reach ...
StzSecurityLedgerQ().Show()
```
```
Security ledger -- 7 event(s) recorded, 7 retained of 512, chain intact.
  REFUSED sig.key.unknown by ghost on path:/pay -- unknown key 'ghost'
  REFUSED sig.signature.forged by billing on path:/pay -- signature mismatch (forged, tampered, or wrong key)
  REFUSED sig.nonce.replayed by billing on path:/pay -- replay detected (nonce already used for this key)
  REFUSED auth.login.failed by admin on user:admin -- authentication failed (attempt 1)
  REFUSED auth.login.failed by admin on user:admin -- authentication failed (attempt 2)
  REFUSED auth.login.failed by admin on user:admin -- authentication failed (attempt 3)
  REFUSED secret.reveal.refused by advisor on secret:stripe-live -- the actor is not effectful (or is sandboxed)
```

Seven events, three classes, one chain — and every reason is the gate's
own sentence, not a reconstruction. Before I2 each of those lines lived
for exactly one call, in a `Why()` slot that the next call overwrote.

## What got wired

Six classes, at the exact points where they already knew something:

| Class | What it detects | Kind noted |
|---|---|---|
| `stzRequestSigner` | unknown key, stale envelope, **forged MAC**, **replayed nonce** | four kinds |
| `stzPasskeyServer` | assertion refusals incl. the anti-phishing check; the cloned-authenticator counter | `auth.passkey.failed`, `auth.passkey.clone_suspected` |
| `stzSaml` | **assertion replay**, issuer/audience/window rejection | two kinds |
| `stzSecretStore` | reveals granted and refused | two kinds |
| `stzAuth` | every failed attempt, and the lockout it triggers | two kinds |
| `stzUpdatePlan` | capability refusal, **scope refusal**, **posture refusal** | three kinds |

The bolded ones are the compromise indicators the study found being
thrown away. The last two rows include the phase's bug-shaped finding:
scope and posture refusals were **never audited at all** — they
produced a log line in the returned result and then vanished. They are
events now.

One more was found while wiring: the passkey server's clientData check
— the *anti-phishing* check, origin and challenge — returned before the
refusal helper, so it recorded nothing. It goes through the helper now.

## Closed by default, and closed is free

The ledger is a process resource, and an application that never opens
one is unchanged:

```ring
chk("no ledger is open by default", NOT StzSecurityLedgerIsOpen())
# a refusal still refuses, still explains, and records nothing
```

Every seam calls `StzNoteRefusal(...)` unconditionally, and that helper
returns **before building anything** when no ledger is open — an event
costs two clock reads and a trace-scope lookup, so not building it is
the point. This is the perf-P3 discipline (an unobserved server pays
one NULL check) applied to security.

## Where the current ledger lives — a lesson repaid

The first implementation kept the process ledger in a Ring global.
It did not work: a function cannot reliably write one, and the guard
caught it immediately (`the process ledger is open` — FAIL). The fix
was to put the current-ledger slot **in the engine**, exactly where P9
had already put the trace scope, for exactly the same reason. Ring
faces then reach it through the engine and cannot fork it; destroying
the current ledger clears the slot so nothing dangles.

That is the second time this session the same law has paid: *process
state belongs in the engine, not in a Ring global.*

## The redaction law, now across a whole ledger

The secret store's refusal names the secret. The guard checks the whole
ledger — every subject and every reason of every event — for the
literal value:

```
secret value leaked anywhere? 0
```

The event carries `secret:stripe-live`, never `sk_live_…`, because
`About()` takes a descriptor and no seam calls `Reveal()`. An incident
record must never become the breach it describes, and I2 is where that
law gets tested at scale rather than in a single object.

## What is still unwired, honestly

OIDC token/code refusals, cross-world and federated call refusals, HTTP
401/403 at the appserver, rate-limit sheds, the service registry's
production-fake refusal, and escalation paths appearing in the security
graph. Each is a one-line note at a site that already computes the
reason; they are held back only because this phase already touches six
live, well-guarded classes, and eleven suites had to stay green (they
did). The catalog already carries their kinds.

And the honest one about the clone indicator: it is wired at the
signature-counter check, which is reachable only with a valid assertion
whose counter stalled — real authenticator fixtures. The guard
exercises the refusal path it can reach and says so rather than
claiming a test it does not run.

**I3** is next: detection over *sequences* — three failed logins then a
secret reach is a story, and the library's rules today can only judge
one moment at a time.
