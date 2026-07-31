# The Incident
### The file a person reads at 3 a.m. — timeline, attack path, blast radius, and a status that only moves forward

> Every code block below is real, and every output block is its actual
> output (the run is `base/test/system/security_incident_narrated.ring`,
> 32 assertions, whose Scene 6 prints the file below verbatim).
> Incident analysis I5 — `doc/design/SOFTANZA_INCIDENT_ANALYSIS.md`.

## From "something fired" to "here is what happened"

I4's case says *what* fired and photographs the moment. That is the
right thing to keep, and the wrong thing to hand a human. An
investigator needs the story: who, in what order, how far they could
have gone, what is exposed, and what has been done about it.

Here is the whole file, printed by the guard, for an attack the guard
itself staged through real detections:

```
Incident INC-1 (error, closed) -- guess-then-reach involving 'billing-agent'
  auth.login.failed then secret.reveal.refused within 26000ms by 'billing-agent' -- a failed sign-in followed by a reach for a secret -- the classic shape of a stolen-credential attempt
  6 correlated event(s):
    1785700004000  auth.login.failed by billing-agent on user:admin
    1785700008000  auth.login.failed by billing-agent on user:admin
    1785700012000  auth.login.failed by billing-agent on user:admin
    1785700016000  auth.login.failed by billing-agent on user:admin
    1785700020000  auth.login.failed by billing-agent on user:admin
    1785700030000  secret.reveal.refused by billing-agent on secret:stripe-live
  Attack path: billing-agent -> deploy-tool -> effectful  (2 hop(s))
  Blast radius of 'stripe-live': 1 node(s) -- checkout-site
  [contained] revoked the agent's session and rotated the key
  [closed] credentials rotated; the reach was refused, nothing left the process
```

Everything above is derived, nothing is narrated by hand.

## Correlation: one honest hop

The incident starts from the firing's actor, takes **every** event that
actor produced — so the file holds all five failed logins, not just the
pair the detection matched — and then pulls in anything sharing a
**trace id** with those.

That second step is where P9's backbone pays off in a domain it was not
built for. The guard proves it with a case where an event by a
*different* actor (`someone-else`, replaying a nonce) joins the story
because it happened inside the same request scope:

```ring
chk("a DIFFERENT actor's event joined the story via the shared trace", ...)
chk("...and the trace id is reported for the log query", ...)
```

And because the trace ids are reported, `stzLog.OfTrace(id)` returns
the handler's own log lines for that request — the 3 a.m. circle
closes: alert → incident → the words the code wrote while it happened.

## The path, not just the verdict

`stzSecurityGraph` has been able to answer *whether* a sandboxed actor
reaches an effectful capability since the graph-rules plan. An
investigation needs *how*, so I5 added `PathToEffectful()` — the path
itself:

```
Attack path: billing-agent -> deploy-tool -> effectful  (2 hop(s))
```

"This external agent could have reached an effectful capability through
the deploy tool" is a sentence a security review can act on; a boolean
is not. The guard also checks the negative case: an actor with no route
reports **no path**, because a false alarm about reachability is worse
than silence.

The same graph answers what a leaked secret exposes —
`Blast radius of 'stripe-live': checkout-site` — which is rotation
planning, computed rather than remembered.

## Status moves forward, and only forward

`open → contained → closed`, and each transition carries a note. Trying
to contain twice, or to reopen a closed incident, refuses:

> already closed. Reopening is a NEW incident referencing this one —
> regressions are new commitments, deliberately.

That sentence is borrowed on purpose: `stzGovernance` applies exactly
this discipline to commitments. An incident record that can be
rewritten backwards is not a record.

## The incident notices a rewritten history

The case kept the ledger's chain head from the moment it fired. Later
events move the ledger's head — that is normal — but the incident's
copy does not change:

```ring
chk("the ledger moved on, so its head differs from the incident's", ...)
chk("...but the incident still holds the head it fired on", ...)
```

So an incident is evidence *about* evidence: if the ledger is ever
edited rather than appended, the two heads disagree in a way that can
be shown, not merely asserted.

## Honest limits

Correlation is **one hop** — actor, then shared traces. It will not
find an attacker who changes identity between steps without ever
sharing a request; that is the kind of link a human or a later phase
adds. The timeline is wall-clock ordered because that is how humans
reason, which means it is only as good as the clocks across processes
(within one process the ordering is monotonic and exact). Stories are
bounded at 64 events — an incident is a story, not an archive. And the
graph answers only what the graph was told: `stzSecurityGraph` is a
declared model, so an undeclared edge is an unseen path, exactly as the
graph-rules plan warned ("report what it can see and say so").

**I6** is the last verb: containment as a governed act — the plan an
LLM may compose and only an effectful actor may commit.
