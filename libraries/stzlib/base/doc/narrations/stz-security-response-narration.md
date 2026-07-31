# The Governed Response
### The machine proposes the containment it is structurally unable to perform

> Every code block below is real, and every output block is its actual
> output (the run is `base/test/system/security_response_narrated.ring`,
> 27 assertions). Incident analysis I6 —
> `doc/design/SOFTANZA_INCIDENT_ANALYSIS.md`.

## The only verb that touches reality

Witness, detect, reconstruct — none of those change anything. Contain
does: it revokes a session, locks an account, rotates a secret. This is
where a security system is most useful and most dangerous, and it is
exactly where the library already has a doctrine:

> Expression is free; admission is governed.

So containment is a **plan**. Anyone may compose it. Only an effectful,
non-sandboxed actor may commit it.

## An incident proposes its own containment

The plan is not invented by a human staring at a dashboard — it is
derived from what the incident already knows: the actor it names, the
capability the graph says that actor could reach, the secret it reached
for.

```ring
oResp = StzResponsePlan("contain-INC-9")
oResp.ProposeForIncident(oInc)
oResp.Show()
```
```
Response plan contain-INC-9 -- 4 proposed action(s).
  1. lockaccount 'billing-agent'
  2. revokesession 'billing-agent'
  3. revokecapability 'billing-agent'
     because ... -- and this actor can reach an effectful capability
  4. rotatesecret 'stripe-live'
     because ... -- the secret was reached for
```

Every action carries the incident's own sentence as its rationale.
Nothing was guessed: action 3 exists *because* I5's attack path found a
route to an effectful capability, and action 4 exists *because* the
incident implicated that secret. The catalog is closed — six verbs —
and anything outside it refuses with the list.

## The line that the whole design was built for

```ring
? oResp.MayCommit(oLlm)                 # the agent that did the analysis
? oResp.ExecuteOn(oFake, oLlm)          # ...tries anyway
```
```
preflight refuses the inference-only actor
...and says why: actor 'advisor' is not effectful -- it may propose, not commit
the LLM's execution commits NOTHING
...the responder was never touched
...and all four actions were audited REFUSED
```

The LLM actor holds `inference` only, so `MayCommit` is false —
**structurally, not by policy**. An agent can run the entire
investigation, read the timeline, follow the attack path, write the
containment plan, explain it in words a banker's auditor could read —
and be unable to execute a single action of it. Then:

```
all four actions committed
the responder received them in the proposed order
the audit holds both verdicts (4 refused + 4 committed)
```

Same plan, same target, different actor. Both judgments are in one
audit trail, which is what makes it an account rather than a log.

## The response is *in* the story, not beside it

Every committed action is also a ledger event
(`response.action.committed`), and every refusal is one
(`response.action.refused`). So the hash chain covers the attack, the
refusals, and the containment together:

```
the ledger now holds 14 event(s): the attack, the refusals, the containment
```

That matters for the question an auditor actually asks six months
later — not "was there an incident?" but "what did you do about it, and
who decided?" And no detection watches response kinds, so recording the
response cannot feed the detector that produced it (the guard asserts
that explicitly — a feedback loop between watcher and responder would
be a defect, not a feature).

## The circle, in five lines

The guard's last scene prints the whole system:

```
1. the seams witnessed  : 10 refusal(s) recorded
2. a detection judged   : guess-then-reach
3. the incident said HOW: billing-agent -> ... -> effectful
4. the machine proposed : 4 containment action(s)
5. a human committed    : 4, audited and ledgered
```

Six phases, one story: refusals the library already detected and used
to forget, judged as a sequence, correlated into a file with an attack
path, answered by a plan a machine wrote and a person authorised.

## Honest limits

The responder is **duck-typed and not auto-wired**. `stzAuth` knows how
to revoke sessions and lock accounts; `stzSecretStore` knows how to
rotate; the rate limiter knows how to shed — but which object owns
which action is an application's decision, and a containment plan that
guesses is worse than one that asks. The guard executes against a
double, which is the service-virtualization pattern doing what it was
built for: proving a crossing without performing one.

There is no rollback verb. Undoing a containment is a new decision by a
new actor, not an "undo" — the same reasoning that makes an incident's
status forward-only.

**I7** is what remains: attestation and export — the sealed evidence
and the OCSF/OTLP handshake that lets the rest of the world read what
this system now knows.
