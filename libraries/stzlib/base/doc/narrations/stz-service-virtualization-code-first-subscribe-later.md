# Code First, Subscribe Later
### How Softanza builds against sandboxes for six kinds of external service — and why the fakes have to be able to lie badly

You have decided to build a small shop. You will need a payment gateway, a
database, somewhere to keep uploaded images, an SMS sender for one-time codes, a
model to summarise reviews, and a currency-rates API. Six vendors. Five accounts,
four keys, two of them requiring a company registration number you do not have
yet, and a monthly bill that starts before your first line of code compiles.

That is the annoyance. The **defect** is quieter and much worse: even once you have
paid, the parts of your code that handle *failure* are the parts you can never
exercise. No gateway will decline a card because you asked nicely. No API will
rate-limit you on demand. So the decline branch, the retry branch, the
partial-refund branch — the branches that run on your worst day — ship untested.

This narration walks the layer Softanza grew to fix both, and the decisions inside
it that are easy to get wrong. Every code block below is real, and every output
block is its actual output.

The one sentence to take away: **an agreeable fake is more dangerous than no fake
at all**, and almost every design choice here follows from that.

---

## A port is one method

Start with the thing being replaced. In Softanza a **port** is not a class to
inherit or an interface to implement. It is a sentence:

> a payments port is *any object with* `Authorize(amount, token)`, `Capture(id)`
> and `Refund(id)`.

That is the whole contract. Duck-typed, exactly like the vault resolver the
library already had. Any object answering those three calls can be bound as the
shop's payment gateway — a fee-free double today, a Stripe client at deploy.

```ring
oPay = new stzPaymentsSandbox()

aAuth = oPay.Authorize(4200, "tok_visa")
? aAuth[:id]                        # --> auth_1
? aAuth[:status]                    # --> authorized

? oPay.Capture(aAuth[:id])[:ok]     # --> 1
? oPay.StatusOf(aAuth[:id])         # --> captured
```

Two small things in that snippet are deliberate.

`4200` is **not** 42.00. Money here is always an integer in minor units, and a
float is refused outright. Floating-point money is a rounding defect waiting for
its boundary, and a sandbox that quietly accepted `42.5` would teach the habit
that produces it.

`auth_1` is not a random id. A double has no business being unpredictable; ids
count up so a test can name one.

Six categories now have ports, each a sentence of the same shape:

| Category | The port is any object with | Doubles that ship |
|---|---|---|
| Database | `Exec` / `Rows` / `Value` | sqlite, in a file or in memory |
| HTTP (the general case) | `Request(method, url, body)` | scripted + replay sandbox, real client |
| Payments | `Authorize` / `Capture` / `Refund` | deterministic gateway with a ledger |
| Generative | `Complete(prompt)` | replay + scripted sandbox, local DLM |
| Object store | `Save` / `Fetch` / `Exists` / `Remove` | a directory, or memory |
| SMS | `Send(number, text)` | a capture sink that counts segments |

The HTTP one earns its place by subsuming the others' *shape*: nearly every
third-party dependency is a request and a response, so the later categories are
mostly configuration of that one idea rather than new machinery.

## The dangerous fake is the agreeable one

Here is the part that decides whether any of this is worth having.

The obvious way to write a payments double is to return "approved" and move on.
That double is worse than nothing, because it makes broken code pass. Most real
payment bugs are not connectivity bugs — they are **state-machine** bugs:
capturing twice, capturing a decline, refunding more than you took. An agreeable
fake hides precisely the class of defect you most need to find.

So this one enforces the state machine a real gateway enforces:

```ring
# ...continuing above: auth_1 has already been captured
aTwice = oPay.Capture(aAuth[:id])
? aTwice[:ok]                        # --> 0
? aTwice[:why]                       # --> this authorization was already captured

aOver = oPay.RefundAmount(aAuth[:id], 99999)
? aOver[:ok]                         # --> 0
? aOver[:why]                        # --> a refund may not exceed what was captured

? oPay.TotalCaptured()               # --> 4200
? oPay.NetCaptured()                 # --> 4200
```

Capture only an authorized charge, and only once. Refund only what was captured,
never more. Every refusal says why. And the ledger is assertable, so a test can
make a claim about **what happened to the money** rather than about a return
value.

## You have to be able to break it on purpose

The other half of the same idea. A double is the only place where you can *cause*
the failure you need to handle:

```ring
oPay = new stzPaymentsSandbox()
oPay.DeclineTokenQ("tok_chargeback")          # a "test card", as gateways publish

aDecl = oPay.Authorize(4200, "tok_chargeback")
? aDecl[:status]                     # --> declined
? aDecl[:why]                        # --> the payment token was declined
```

And now a distinction worth the whole section:

```ring
oPay.FailNextQ()                              # the gateway is down, once

aOut = oPay.Authorize(4200, "tok_visa")
? aOut[:status]                      # --> refused
? aOut[:why]                         # --> the gateway is unreachable

? oPay.NumberOfAuthorizations()      # --> 1
? oPay.Authorize(100, "tok_visa")[:ok]        # --> 1
```

`:refused` is not `:declined`, and conflating them is how real shops lose money in
both directions. **A decline is an answer**: do not retry, tell the customer.
**An outage is not an answer**: retry, and say nothing to the customer about their
card. Code that treats them alike either double-charges people or turns a
five-minute vendor blip into lost sales.

Notice `NumberOfAuthorizations()` is `1`, not `2`. The outage recorded no phantom
authorization — the call never reached the gateway, so nothing exists to
reconcile later. And it is one-shot, so the next call works: you can script the
blip and then the recovery.

## Silence is the worst answer

Every sandbox here is **strict by default**. Ask for something nobody prepared and
it raises:

```ring
oSb = new stzHttpSandbox()
oSb.ScriptQ("GET", "https://api.rates/v1", 200, '{"usd":1.09}')

aRates = oSb.GetFrom("https://api.rates/v1")
? aRates[:status]                    # --> 200
? aRates[:body]                      # --> {"usd":1.09}
? aRates[:from]                      # --> scripted

? oSb.IsStrict()                     # --> 1
```

```ring
try
    oSb.GetFrom("https://api.rates/v2")       # a URL nobody scripted
catch
    ? cCatchError
done
# --> stzHttpSandbox: nothing scripted or recorded for GET https://api.rates/v2.
#     Script it, record it, or SetStrict(FALSE) to let misses through.
```

Compare the alternative. A lenient double answers `""` for the URL you forgot,
your parser reads no rates, your code falls back to a default, and the test goes
green. You have produced **a test that passes for the wrong reason** — the single
worst outcome available in testing, because it actively removes your ability to
find the bug.

Leniency is still available, but you have to ask, and the answer labels itself:

```ring
oSb.SetStrictQ(FALSE)
aMiss = oSb.GetFrom("https://api.rates/v2")
? aMiss[:from]                       # --> miss
? aMiss[:status]                     # --> 501
```

`501`, not `200`. A miss must never be mistakable for success.

## Not every substitute is a fake

This one arrived as a correction. The first design had two kinds of binding —
fake and real — and the database category broke it immediately.

sqlite is not a pretend database. It is a real database in a file you own. Running
it in production is a choice plenty of good systems make forever, not a mistake to
be caught. So "fake vs real" was too coarse, and there are now **three postures**,
each *asked of the object* rather than guessed from its class name:

```ring
oSql = StzSqliteDataSourceQ("shop.db")
oSql.Exec("CREATE TABLE dish (name TEXT, price INTEGER)")
oSql.Exec("INSERT INTO dish VALUES ('Tajine', 120)")

? len(oSql.Rows("SELECT * FROM dish"))    # --> 1
? oSql.IsLocalReal()                      # --> 1
? oSql.IsEphemeral()                      # --> 0

oMem = StzMemoryDataSourceQ()
? oMem.IsLocalReal()                      # --> 1
? oMem.IsEphemeral()                      # --> 1

? (new stzPaymentsSandbox()).IsSandbox()  # --> 1
```

- `:sandbox` — a fake. Must never ship.
- `:local` — a genuine local equivalent. May ship; self-hosting is a decision, not
  an oversight.
- `:live` — the real hosted service.

And the in-memory case earned an invariant of its own. `":memory:"` is *real*
sqlite right up to the restart that empties it — and it is one character away from
the spelling that persists. That is not a naming convention's job to catch:

```ring
oReg = new stzServiceRegistry("shop")
oReg.Bind(:database, oSql)
oReg.Bind(:scratch, oMem)
oReg.Bind(:payments, new stzPaymentsSandbox())

? oReg.PostureOf(:database)          # --> local
? oReg.PostureOf(:scratch)           # --> local
? oReg.PostureOf(:payments)          # --> sandbox

oReg.SetPhaseQ(:production)
? oReg.IsSound()                     # --> 0
```

```
[error] sandbox-in-production @ shop/payments
        still bound to a SANDBOX in a production phase -- a fake must never ship
[error] ephemeral-in-production @ shop/scratch
        a LOCAL source that vanishes on restart (in-memory) is bound in a production phase
```

Two different objections to two different mistakes. Both `:local`; only one of
them dangerous.

That `IsEphemeral()` question turned out to be the reusable part. Four phases
later an in-memory *blob* store was added, and it was caught in production by the
same rule with no new code written — because the registry asks the object a
question rather than knowing anything about databases.

## When you cannot fake it, say so

The generative category is where honesty matters most, so the file states its
limit before its features: **frontier-model quality cannot be virtualized.**

Every other double here substitutes faithfully. A mail sink really is mail-shaped.
sqlite really is a database. A directory really does store bytes. Nothing you can
run locally is GPT-class, and pretending otherwise would be the one genuinely
dishonest thing in this layer.

So a generative sandbox sells three other things, each real. First, **determinism**
— a recorded answer, replayed, turns a flaky test into a test:

```ring
oLlm = new stzLlmSandbox()
oLlm.SeedAnswerQ("Summarise the Q3 report in one line.", "Revenue rose 4%; costs flat.")

aSum = oLlm.Complete("Summarise the Q3 report in one line.")
? aSum[:text]                        # --> Revenue rose 4%; costs flat.
? aSum[:from]                        # --> replay

oLlm.WhenPromptContainsQ("translate", "(a translation)")
? oLlm.Complete("please translate this")[:from]    # --> scripted
```

Answers are keyed by a hash of the prompt; a rule can cover a whole *family* of
prompts. When a prompt matches both, the seeded answer wins — a recording is what
a model actually said, and that beats a rule someone wrote.

Second, and this is the piece that surprised me into building it, **cost — zero,
and measurable**:

```ring
oC = new stzLlmSandbox()
oC.SetFallbackQ("ok")
oC.Complete("Summarise: " + StzRepeatStr("word ", 40))
oC.Complete("Now translate it")

? oC.NumberOfCalls()                 # --> 2
? oC.ApproximateTokensSent()         # --> 57
? oC.WasAskedAbout("translate")      # --> 1
? oC.WasAskedAbout("delete")         # --> 0
```

A fee-free layer ought to let you **assert the fee**. "This feature must not cost
more than two calls" becomes a test instead of a hope, and `WasAskedAbout` asserts
on what your pipeline actually *sent* — which is where prompt-assembly bugs
genuinely live. The token count is approximate on purpose: it is a budget, not a
bill.

Third, **offline**: no key, no network, no rate limit in CI.

And then there is a local option that is not a fake at all:

```ring
oKb = new stzKnowledgeGraph("cuisine")
oKb.Know("tajine", "dish").KnowRelation("tajine", "origin-is", "morocco")

oDlm = new stzDlmSource( StzDlmQ(oKb) )
? oDlm.IsLocalReal()                          # --> 1
? oDlm.Complete("what is tajine")[:text]      # --> Tajine is a dish.
```

Ask it something outside what it knows:

```ring
? oDlm.Complete("who won the 1998 world cup")[:text]
# --> That is outside the 'cuisine' domain (I know 1 entities and 1 relations).
```

Which is the **opposite failure mode from a language model**, and the reason
shipping this is a legitimate choice rather than a fake awaiting replacement. It
reasons over facts you gave it and declines everything else. For a bounded,
factual assistant that is often what you actually wanted.

## Building the double taught us the service

An unplanned benefit, twice over: writing a faithful fake forces you to learn what
the real service actually promises. Both of the following were *measured* before
the code was written, and both are traps I would otherwise have shipped.

**An object key is not a file path.** The obvious blob store maps key to filename.
Watch what that costs:

```ring
oB = StzFileBlobStoreQ("uploads")
oB.Save("Photo.JPG", "the original")
oB.Save("photo.jpg", "a different picture")

? oB.NumberOfBlobs()                 # --> 2
? oB.Fetch("Photo.JPG")              # --> the original
? oB.Fetch("photo.jpg")              # --> a different picture
```

Two objects, as S3 would hold them. Mapped naively onto this machine's
case-insensitive filesystem, the second write would have **silently destroyed the
first** — data loss with no error, the worst kind. And:

```ring
oB.Save("../escaped.txt", "did I get out?")
? oB.Exists("../escaped.txt")                          # --> 1
? StzFileExists("escaped.txt")                         # --> 0

oB.Save("photos/2026/tajine.jpg", "nested key")
? oB.Fetch("photos/2026/tajine.jpg")                   # --> nested key
```

`../escaped.txt` is an ordinary S3 key. As a path it escapes the directory —
verified, the bytes landed in the parent — which is a path-traversal write driven
by whatever your users can name. And `photos/2026/a.jpg`, the commonest key shape
there is, *fails outright* as a path unless those directories exist. S3 has no
directories at all; the slashes are characters a console draws as folders.

Guarding each of those in turn is a losing game, so the key never becomes a path:
**the filename is `sha256(key)`**, with the real key in a sidecar so listing still
works. Traversal stops being blocked and becomes *unsayable*. Distinct keys stay
distinct on any filesystem. Slashes are just characters again.

**A character is not a segment.** SMS is billed per segment, and the segment count
depends on the *alphabet*:

```ring
? StzSmsSegments(StzRepeatStr("a", 100))[:segments]                # --> 1

cEmoji = StzUnicodeToChar(128512)
aWith = StzSmsSegments(StzRepeatStr("a", 100) + cEmoji)
? aWith[:segments]                   # --> 2
? aWith[:encoding]                   # --> ucs2
? aWith[:units]                      # --> 102
```

One emoji doubled the bill. The GSM 7-bit alphabet packs 160 characters into a
message; a single character outside it re-encodes **the whole message** to UCS-2,
where the ceiling is 70. Nothing in the source looks different — somebody edited a
template.

```ring
? StzSmsSegments(StzRepeatStr(StzUnicodeToChar(1605), 71))[:segments]   # --> 2
? StzSmsSegments(StzRepeatStr("{", 100))[:units]                        # --> 200
```

Seventy-one Arabic letters already cost two segments, so a cost model that assumes
160 is wrong for most of the world. And the nine GSM *extension* characters
(`^ { } \ [ ~ ] |` and `€`) cost two septets each — a JSON snippet in an SMS bills
at roughly twice what it looks like.

Neither of these is about fakes. They are facts about the real services that
building the fakes forced into the open.

## One place, two worlds

Now the piece that makes the whole layer usable rather than merely present. All of
those doubles are bound in one place, and the application asks by **name**:

```ring
oPay = new stzPaymentsSandbox()
oPay.ApproveUnderQ(10000)

oReg = new stzServiceRegistry("shop")
oReg.DeclareMany([ :payments, :mail ])
oReg.Bind(:payments, oPay)
oReg.Bind(:mail, new stzMailSandbox())

# ---- the application code. It never names an implementation. ----
aRes = oReg.Service(:payments).Authorize(4200, "tok_visa")
oReg.Service(:mail).Send("dana@example.com", "Receipt", "Thank you.")
# -----------------------------------------------------------------

? aRes[:status]                      # --> authorized
? oPay.NumberOfAuthorizations()      # --> 1
```

Those two middle lines are the trick, and they are the same two lines in
production. Nothing switches on a flag, because the application never learns which
implementation it got. The **phase** decides that, somewhere else entirely.

Declaring the surface up front buys the second guarantee:

```ring
? oReg.NumberOfDeclared()            # --> 2
? oReg.NumberOfBound()               # --> 2
? @@(oReg.UnboundServices())         # --> [ ]

try
    oReg.Service(:shipping)          # never declared, never bound
catch
    ? "raised"                       # --> raised
done
```

It raises rather than handing back a `NULL` that fails later somewhere less
informative.

That `NumberOfAuthorizations()` reading `1` is quietly load-bearing. Ring copies
objects on assignment *and* on list insertion, so the registry handed the
application a **copy** of the sandbox — and the original still saw the charge.
Every stateful double here keeps its state in a table keyed by an id precisely so
that a copy is not a snapshot. It is a requirement of the port contract, not a
detail.

## The agent that can touch nothing

This is where the layer stops being a cost saver and becomes a safety property.

An autonomous agent turned loose on a codebase is frightening in proportion to
what it can *reach*. Give it the shop above and it can exercise everything —
authorize payments, send mail, call the model, write objects — and cause **no
effect in the world**, because a sandbox payment moves no money and a mail sink
sends nothing. Its real-world effect set is empty by construction, not by promise.

Then the crossing into production is governed like every other commit in the
library:

```ring
oStore = new stzSecretStore("shop")

? oReg.MayGoLive(LLMActor("assistant"), oStore)       # --> 0
? oReg.WhyNotLive(LLMActor("assistant"), oStore)
# --> actor 'assistant' is not effectful -- it may propose, not commit

? oReg.MayGoLive(HumanActor("dana"), oStore)          # --> 0
? oReg.WhyNotLive(HumanActor("dana"), oStore)
# --> sandbox-in-production: still bound to a SANDBOX in a production phase -- a fake must never ship
```

Read the two refusals: they are refusals of different kinds. The agent is refused
for **who it is**; the human is refused for **what the surface is**. Two
independent questions, and both must pass.

That second answer is also a bug I found while writing this narration. `MayGoLive`
used to ask about soundness *in the current phase* — so with the phase still
`:development` it answered **yes** with a fake bound, because the
production-specific invariants had not fired yet. The guard had only ever asked
after setting production, so the honest answer and the convenient one agreed and
the gap stayed hidden. "May I go live?" *is* the production question, so it is now
asked in that frame whatever the phase, and the phase is put back afterwards.

## The door

Everything so far can be circumvented by forgetting. The last piece removes that
option.

A delivery plan already rehearsed which capabilities each part of a solution
needs. It now rehearses the outside world alongside them:

```ring
oShop = new stzServiceRegistry("shop")
oShop.DeclareMany([ :payments, :cache ])
oShop.BindSandbox(:payments, new stzPaymentsSandbox())
oShop.BindLive(:cache, new stzHttpSandbox(), "redis_url")

oDel = new stzDelivery("shop")
oDel.AddBackend("api", "linux")
oDel.NeedsIn("api", [ :PivotTable ])
oDel.UseServicesQ(oShop)
oDel.NeedsServiceInQ("api", [ :payments, :cache ])

oPlan = oDel.Plan()
oPlan.Show()          # the excerpt below is its external-dependency section
```

```
  External dependencies (2):
     payments      sandbox   a FAKE -- must be flipped before production   <- [ "api" ]
     cache         live      needs secret 'redis_url'   <- [ "api" ]
     => 1 still a fake: [ "payments" ] -- Deploy(:Production) will REFUSE until these are real.
     => production will require these credentials: [ "redis_url" ]
```

Credentials **by name, never by value** — the plan is a document you can read
aloud. And you can ask the production question without claiming to be shipping:

```ring
? oDel.ServicesAreProductionReady()          # --> 0
? oDel.WhyServicesNotReady()
# --> sandbox-in-production: still bound to a SANDBOX in a production phase -- a fake must never ship
? oShop.Phase()                              # --> development
```

Asking is not declaring: the phase went to production, the surface was judged, the
phase came back. Rehearse, then commit.

Then the door itself:

```ring
oDel.DeployTo(StzDeploymentSiteQ("host1"), "api")
oDel.SetActor( HumanActor("dana") )           # fully entitled to commit
oDep = oDel.Deploy(:Production)

? oDep.WasRun()                      # --> 0
? oDep.WasCommitted()                # --> 0
```

```
[error] REFUSED -- the external surface is not production-ready
[error] sandbox-in-production @ shop/payments
```

Refused for an entitled human, and that is the point: deploying a fake payment
gateway is not an authority question. Every reason is logged, not just the first,
so you fix the set rather than discovering them one deploy at a time.

```ring
oDel.ServicesQ().BindLiveQ(:payments, new stzHttpSandbox(), "stripe_key")
? oDel.ServicesAreProductionReady()               # --> 1
? "'" + oDel.WhyServicesNotReady() + "'"          # --> ''
```

"Flip it to real before shipping" used to be a thing to remember. It is now a
door.

### A gate that fails open

Building that door exposed the worst defect in the whole layer, and it is worth
your attention because the shape recurs.

The registry kept its state in ordinary attributes. Ring copies on attribute
store — so attaching a registry to a delivery took a **snapshot**. Bind a fake
afterwards on your own handle and the delivery could not see it, which means the
production gate would have **passed a surface that had since gone fake**.

Note the direction of that failure. Not "the gate is annoying"; the gate was
*decorative*. And it echoes the opening theme exactly: an agreeable fake is worse
than no fake, and **a gate that fails open is worse than no gate**, because both
buy you confidence you have not earned.

The cure was already in the building. Every sandbox in this layer keeps its state
in a table keyed by an id, precisely so a copy is not a snapshot. The registry —
the one object whose job is to *judge* the others — was the only one that had not
been given the same treatment. Now every copy is the registry. The general rule,
recorded: **anything that governs others must survive being copied, or attaching
it silently disarms it.**

### Which part of my solution depends on a fake?

One question remains that none of the checks above can answer, because it spans
two models that have never heard of each other. The registry knows services and
postures but nothing about the parts of your solution. The delivery knows parts
and sites but passes no judgement on postures. Join them into one graph and the
answer is one hop away:

```ring
oShop2 = new stzServiceRegistry("shop")
oShop2.DeclareMany([ :payments, :cache ])
oShop2.BindSandbox(:payments, new stzPaymentsSandbox())
oShop2.BindLocal(:cache, StzMemoryBlobStoreQ())

oDel2 = new stzDelivery("shop")
oDel2.AddBackend("api", "linux")
oDel2.AddApp("web", "browser")
oDel2.UseServicesQ(oShop2)
oDel2.NeedsServiceInQ("api", [ :payments, :cache ])
oDel2.NeedsServiceInQ("web", [ :reporting ])
oDel2.DeployTo(StzDeploymentSiteQ("host1"), "api")   # 'api' is going to a real host

? oShop2.Phase()                     # --> development
? len(oShop2.Findings())             # --> 0

aFindings = StzCheckServiceDelivery(oDel2)
```

```
[error] production-part-uses-sandbox @ api
    part 'api' is destined for production but depends on 'payments', which is still a DOUBLE -- flip it to a real binding first
[error] production-part-uses-ephemeral @ api
    part 'api' is destined for production but depends on 'cache', which is real only until the next restart
[warning] part-uses-undeclared-service @ web
    part 'web' depends on 'reporting', which the registry does not declare -- nothing will resolve it at run time
```

Three things to notice.

These findings name **the part**, not the service — you learn which piece of your
solution cannot ship, which is what you actually needed.

The phase is still `:development` and the registry itself reports nothing, quite
correctly. These rules read a part's **destination** instead, so they answer while
there is still time: *if I shipped this today, would it be fake?*

And the third finding is invisible to the registry by construction — `reporting`
exists only in the delivery model, so nothing would ever have resolved it at run
time. It is a warning rather than an error because `web` is not bound to a host
yet.

The rules deliberately do **not** restate the registry's own five invariants.
Those already carry the shared report's shape, so joining them to the project-wide
CI gate is one line:

```ring
oShop2.SetPhaseQ(:production)

oPosture = new stzSecurityPosture("shop")
oPosture.SetServices(oShop2)

oRep = new stzRuleReport("ci")
oRep.Ingest(aFindings)                              # the graph rules
oRep.IngestLegacy(oShop2.Findings(), "services")    # the registry
oRep.IngestLegacy(oPosture.Findings(), "security")  # the security posture

? oRep.NumberOfFindings()            # --> 7
? @@(oRep.Subjects())                # --> [ "services", "security" ]
? len(oRep.Errors())                 # --> 6
? len(oRep.Warnings())               # --> 1
? oRep.IsSound()                     # --> 0
```

One gate, one vocabulary, six domains — code, agents, security, workflow, org
charts, and now the outside world. Restating a rule in a second place is how the
two copies drift apart; the registry owns these, and delivery, the security
posture and CI all *ask* it.

## What this does not do

The limits, plainly, because a layer like this is exactly where overclaiming hurts:

- **A double is not the service.** One real run against the real thing is still
  required before you trust production. Everything here shortens the loop; nothing
  removes that step.
- **Recorded answers drift.** A replay suite needs re-recording, and contract tests
  against the real API, or it slowly becomes a museum of what a vendor used to say.
- **Frontier quality cannot be virtualized.** Judge model output against the real
  model, deliberately, as its own activity. The sandbox is for the *shape* of the
  pipeline.
- **A directory is not a CDN.** No presigned URLs, no public endpoint, no
  replication, no versioning. If your app hands a browser a URL to upload to, that
  path still needs the real service.
- **A capture sink proves what you would have sent**, not that a carrier would
  accept it. Carrier filtering, per-country sender-ID rules and asynchronous
  delivery receipts are not modelled.
- **The live adapters are mostly not shipped**, and that is deliberate rather than
  unfinished: Stripe/PayPal/Adyen, a frontier API client, S3/GCS, Twilio, SMTP each
  need an account, a key and a network. The contracts are defined and the registry
  refuses to let a sandbox ship in their place — but the last mile is yours, and it
  is a mile, not a marathon.

Six ports, three doubles, and a door that refuses to open on a fake. 374
assertions across eight suites, all green, all running for real.

The bill still arrives eventually. It just no longer arrives first.
