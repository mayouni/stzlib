# The Rest of the Seams
### A detection can only ever see what a seam emits

> Every code block below is real, and every output block is its actual
> output (the run is `base/test/system/security_seams2_narrated.ring`,
> 41 assertions, ~0.3 seconds). Incident analysis I2, second pass —
> `doc/design/SOFTANZA_INCIDENT_ANALYSIS.md`.

## The gap that was listed, not hidden

I2's first pass wired six classes and stopped. The design doc's section 7
table kept the rest of the rows in plain sight, and the completion
document said so as the system's largest honest gap: *a detection sees
only what a seam emits*. The kinds were in the catalog; the calls were
not written.

This pass writes them. Ten more places where the library already knew
something and forgot it one call later.

## An id-token, and the one slot that held it

```ring
oCli = new stzOidcClient("https://id.acme.com", "shop-app")
aTok = oCli.VerifyIdTokenAt("not-a-jwt", "", $NOW)
```
```
  [OK] the client refuses it
  [OK] ...and the refusal is now REMEMBERED, not just returned
  [OK] ...naming the issuer that claimed to have signed it
  the token is not a well-formed JWT
```

`@cLastWhy` holds exactly one of these. Ten in a row — a botched key
rotation, or a forged-token campaign — read identically from any single
call to `Why()`.

## The distinction the provider could not make

The catalog has always had an `oauth.code.replayed` kind: *an
authorization code was redeemed twice*. The provider could not honestly
emit it. Its refusal read **"unknown or already-used authorization
code"**, because a spent code is deleted, so a stolen code replayed and a
code nobody ever issued arrive as exactly the same miss.

So the provider now remembers the codes it has spent — bounded, and
they are single-use and short-lived, so an old entry has nothing left to
protect:

```ring
aAuth = oOp.AuthorizeAt([ :clientId = "shop-app", ... ], "dana", $NOW)
oOp.ExchangeCodeAt("shop-app", "s3cret", aAuth[:code], ...)   # succeeds
oOp.ExchangeCodeAt("shop-app", "s3cret", aAuth[:code], ...)   # the replay
oOp.ExchangeCodeAt("shop-app", "s3cret", "a-code-nobody-issued", ...)
```
```
  [OK] the second is refused
  [OK] ...and recorded as a REPLAY, the error it is
  [OK] a code that was never issued is NOT called a replay
  [OK] ...it is a rejected client, the warning it is
  the answer to both is identical -- only the ledger tells them apart
```

The refusal returned to the caller stays byte-identical, so an attacker
learns nothing from the difference. The distinction exists only in
evidence — which is exactly where it belongs.

## One place, not nine

There are nine `Status(401, ...)` sites inside `stzAppServer.ring` alone,
and every application adds more. Wiring each one would have produced a
seam that saw the library's own refusals and missed the ones an
application wrote — the more interesting half.

The verdict is read once, where the response is final:

```ring
oSrv.Get_("/vault", func oReq, oResp {
    oResp.Status(403, "Forbidden").Json([ "error", "not yours" ]) })
```
```
  [OK] a real 403 came back over a real socket
  [OK] ...and the refusal reached the ledger from a USER's route
  [OK] ...naming the method and path, and nothing from the headers
  GET /vault
  [OK] a 200 writes nothing -- a 404 is a typo and a 500 is a bug
```

Only 401 and 403 carry a security meaning. And nothing from the request
body or its headers is written, so a credential in an `Authorization`
header cannot reach the ledger through this door.

## What a counter cannot say

```ring
oRl.SetLimit("scraper", 1, 1)
oRl.Allow("scraper")   # x3
```
```
  [OK] the counter says how many were shed
  [OK] ...the ledger says when each one was
  [OK] a shed is INFO -- the limiter working, not a failure
```

A steady trickle and a sudden flood read the same from `RejectedCount()`.
The times are what turns a burst of sheds into a detection — and a shed
is deliberately `info`, because shedding is the limiter doing its job.

## The refusals that were only ever a return value

Cross-world crossings, federated calls, the production door, and the bare
secret's reveal gate all knew and all forgot. The federation's four
refusal points — an SSRF-shaped path, a facet nobody offers, a missing
bond, the capability lattice — each wrote `@cWhy` and returned `""`; they
now share one door, which also removed four copies of the timing
bookkeeping.

```
  [OK] an unbonded caller is refused
  [OK] ...and so is an SSRF-shaped path -- the same door
  unsafe path rejected (must start with '/', no CRLF): http://evil.example/x
```

The production door records **one event per unsound service**, not one
per refused deploy, so an incident's `Subjects()` names which services
were still fake:

```
  [OK] one event per UNSOUND SERVICE, not one per refused deploy
  service:shop/payments -- sandbox-in-production: still bound to a SANDBOX
  in a production phase -- a fake must never ship
```

...and it is recorded at the **refusal**, never inside `MayGoLive()`.
That one is a preflight anyone may ask speculatively, and a predicate
that writes evidence fills the ledger with questions instead of events.

The bare secret's gate refuses by raising, which reaches whoever wrote
the `try/catch` and nobody else:

```ring
try
    oSec.Reveal(oBot)      # an LLM actor: inference-only, sandboxed
catch
done
```
```
  [OK] the raise still fires
  [OK] ...and the attempt survives it
  [OK] the secret's NAME is written -- never its value
  [OK] ...and the value appears nowhere in the exported chain
```

The guard's own empty `catch` is exactly the caller that used to erase
the attempt.

## A verb, not a side effect

`ReachesEffectful()` was the obvious place to record an escalation, and
it is the wrong one. An investigation asks the reachability questions
dozens of times while reconstructing an incident; a question that writes
evidence chains the investigator's own curiosity.

So the recording is a deliberate act:

```ring
oGr.AddActor("billing-agent", "sandboxed")
oGr.Uses("billing-agent", "deploy-tool")
oGr.Grants("deploy-tool", "effectful")
aEsc = oGr.AuditEscalations()
```
```
  [OK] the query alone writes NOTHING -- an investigator may ask freely
  [OK] the audit finds the sandboxed actor that reaches effectful
  [OK] ...and records it
  [OK] the PATH is named, not merely the risk
  a sandboxed actor reaches effectful via billing-agent -> deploy-tool -> effectful
```

"billing-agent can reach effectful" names a risk. "billing-agent →
deploy-tool → effectful" names the edge to cut.

## The seam that changed the vocabulary

Sessions end, and the row that proved they existed is deleted. So the
event is written first:

```
  [OK] revoking it is remembered
  [OK] the TOKEN is never written -- it is a bearer credential
  [OK] ...the user is, because that is what an investigation asks
```

Writing the token into evidence would turn the evidence file into a way
in. The user and the address are descriptors; the token is not.

But an expiring session is **neither granted nor refused**. No gate ran;
nobody was told no. The outcome vocabulary had three verdicts and no way
to say "this simply happened", so a fourth arrived — `Observed` — and
finding a home for it exposed a live defect in two places:

```ring
def IsRefusal()
    return @cOutcome != "granted"      # both here and in Refusals()
```

Read that with a fourth outcome in the world and an expired session is a
refusal. In a system whose entire argument is that a warning should mean
something, routine housekeeping would have been counted as attacks in
every pivot. Both are now positive lists:

```
  [OK] its outcome is OBSERVED -- no gate ran, nobody was told no
  [OK] ...so the ledger's own refusal pivot skips it
  [OK] an observed event reports itself as no refusal
  [OK] ...while a failure still is
```

The negative form is the bug. `!= granted` was correct for exactly as
long as there were three outcomes, and it failed silently the moment
there were four.

## The honest limit that does not close

```
  [OK] every event this guard wrote is chained
  15 events across ten newly-wired seams
```

Every row of the design doc's seam table now emits. What remains is not
a phase — it is the permanent shape of the caveat: **all of this
witnesses what the library's gates decide.** Application code that
refuses on its own terms, without passing a Softanza gate and without
answering 401 or 403, is still invisible. No amount of wiring inside the
library reaches it; only an application choosing to record its own
refusals does.

---

Ten seams, 41 assertions, one new outcome, and two defects that had been
sitting in a negative comparison since I0.
