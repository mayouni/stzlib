# The Service-Virtualization Plane
### Plan: code the whole solution fee-free against sandboxes, flip to the real services at deploy

> Status: **phases 1–5 BUILT — the spine, the database exemplar, the generic HTTP port, the payments gateway, the generative port, and three doubles ship.** `base/service/`
> now exists with **`stzMailPort`/`stzMailSandbox`** (built for auth phase 4 — a
> capture sink you assert on), **`stzOidcSandbox`** (a real signing identity
> provider) and **`stzPasskeySandbox`** (a real virtual authenticator). Those
> validate the pattern: each holds genuine keys, produces genuine artefacts, and
> can produce deliberately BAD ones so the negative path is testable.
> **`stzServiceRegistry` (phase 1) is now built**: `Declare` the dependency
> surface, `Bind`/`BindSandbox`/`BindLive`, `Service(name)` resolution that RAISES
> rather than no-ops, a `:development`/`:emulated`/`:production` phase, and four
> governed invariants — `sandbox-in-production` and `unbound-service` and
> `live-without-secret` (ERROR), `inline-credential` (WARN) — reported in the same
> `[:invariant, :severity, :where, :message]` shape as `stzSecurityPosture`, plus
> `MayGoLive(actor, store)` so going live is an actor-gated crossing like every
> other commit. **So "flip it to real before shipping" is now ENFORCED, not
> remembered.** Guard `service_registry_narrated` (45).
> **Phase 2 (the database exemplar) is built too**: `base/service/stzDataPort.ring`
> names the contract (`Exec`/`Rows`/`Value` — the surface `stzDatabase` already
> had) and ships `stzSqliteDataSource` in **local-real** mode. Building it forced a
> real refinement of phase 1: fake-vs-real was too coarse, because sqlite is not a
> pretend database. There are now **three postures** — `:sandbox` (must not ship),
> `:local` (a genuine local equivalent; self-hosting is a choice, not a mistake)
> and `:live` — plus a fifth invariant, **`ephemeral-in-production`**, for the one
> case that IS dangerous: `":memory:"` is real sqlite right up to the restart that
> empties it, and it is one character from the safe spelling. Guard
> `data_port_narrated` (41).
> **Phase 3 (the generic HTTP port) is built too**: `base/service/stzHttpPort.ring`
> names the contract (`Request(method, url, body)` → `[:status, :body]`) and ships
> BOTH sides — `stzHttpSandbox` in **scripted** mode (rules you write, so you can
> make a gateway decline or an API rate-limit you, which no real vendor will do on
> request) and **replay** mode (a response recorded once and replayed forever,
> keyed by a hash of method+url+body — generalising what `stzLLMFunction`'s answer
> cache does for prompts), plus `stzReactorHttpClient` as the live adapter over the
> reactor's own curl-backed client. **Strict by default**: an unscripted request
> raises, because a double that silently answers `""` produces a test that passes
> for the wrong reason. Every request is journalled, so a test can assert on what
> the code *tried* to do. Guard `http_port_narrated` (37).
> **Phase 4 (payments) is built too**: `base/service/stzPaymentsPort.ring` names the
> contract (`Authorize(amount, token)` / `Capture(id)` / `Refund(id)`) and ships
> `stzPaymentsSandbox` — a deterministic gateway with an assertable ledger
> (`TotalCaptured`/`TotalRefunded`/`NetCaptured`/`Movements`). What lifts it above a
> stub is that it **enforces the state machine a real gateway enforces**: capture
> only an authorized charge and only ONCE, refund only what was captured and never
> more. So double-captures, capturing a decline and over-refunds fail in a test
> rather than in production — and most payment bugs are state-machine bugs, not
> connectivity bugs. Money is an **integer in minor units** (a float is refused).
> Rules (`ApproveUnder`, `DeclineOver`, `DeclineToken`, `FailNext`) make the FAILURE
> paths testable at all, and an **outage is `:refused`, distinct from a
> `:declined`** — conflating them is how code double-charges or loses sales. The
> live Stripe/PayPal/Adyen adapter is deliberately not shipped (account + key +
> network = infra-gated); the contract is defined and the registry refuses to let
> the fake ship in its place. Guard `payments_port_narrated` (49).
> **Phase 5 (the generative port) is built too**, and it is mostly *promotion* as
> planned: `base/service/stzLlmPort.ring` names the contract
> (`Complete(prompt)` → `[:ok, :text, :from]`) and ships `stzLlmSandbox`
> (**replay** — a seeded or recorded answer keyed by a hash of the prompt;
> **scripted** — `WhenPromptContains` for a whole family of prompts, with a seeded
> answer winning over a rule because a recording is what a model actually said) and
> `stzDlmSource`, which puts `stzDLM` behind the same method in **local-real**
> posture. The honest limit is stated first in the file, because it governs
> everything else: **frontier-model QUALITY cannot be virtualized.** The other ports
> here substitute faithfully — a mail sink really is mail-shaped, sqlite really is a
> database — and nothing local is GPT-class. What a generative sandbox buys is three
> other things, each real: **determinism** (a model-dependent test stops being
> flaky), **cost** — zero *and measurable*, since the sandbox counts calls and
> approximate tokens so "this feature must not cost more than two calls" becomes an
> assertion — and **offline** CI. So: use it for the SHAPE of a pipeline (prompts
> assembled right, answers parsed right, cost bounded) and judge model quality
> against the real thing, deliberately, as its own activity. `stzDlmSource` is the
> interesting one: ask it outside its domain and it *says so rather than inventing*,
> the opposite failure mode from a language model, which is why shipping it is a
> legitimate choice for a bounded factual assistant rather than a fake awaiting
> replacement. The frontier-API adapter is infra-gated (key + network); the registry
> refuses to let the sandbox ship in its place. Guard `llm_port_narrated` (37).
> Still unbuilt: the blob store and surfacing the registry inside
> `stzDelivery`/`stzDeployment` (phases 6–7).
> Written 2026-07-23 in answer to
> the user's question: *"does our emulation system cover emulating databases,
> business APIs, frontier LLMs, cloud providers, etc., so a programmer can code
> his program completely without complex subscriptions or API fees and yet get a
> working solution ready to deploy on real platforms?"* Every "today" claim below
> was verified against the live tree.

---

## 1. The question, and the honest starting point

Two different things are both called "emulation," and the delivery plane does one
but not the other:

1. **Emulating *your own solution* on its target platforms** — `Deploy(:Emulated)`
   runs each part *for real* (its differential engine compiled to wasm) in an
   offline mission-control. It emulates browser / mobile / firmware / server as
   **targets for your code**. This exists and works.
2. **Emulating the *third-party services your code depends on*** — a payment
   gateway, a frontier LLM API, an object store, a hosted database, a CRM. This is
   **service virtualization**, and there is **no general layer for it today**.

So the answer to the user's question is *"partly, and by two mechanisms."* This
plan builds the missing second mechanism — and, crucially, it is **not
greenfield**: the library already contains the exact pattern to generalize, a
working exemplar for one whole category, and a record-replay primitive for
another. The plan is mostly *generalization + new category sandboxes + governance
wiring*, not invention.

## 2. What already exists (the credit, and the pattern)

| Piece | What it is today | What it gives this plane |
|---|---|---|
| **`stzVaultResolver`** (`security/`) | a duck-typed seam — *"any object with `Resolve(locator)`"* — with an in-memory dev impl swapped for a real vault client at deploy, passed by reference at use time, actor-gated | **THE pattern to generalize.** A service double is this shape, one abstraction level up. |
| **`stzAppBackend` + sqlite** (`appserver/`) | real embedded sqlite (`:memory:`/file) behind the MBaaS REST floor — a self-hosted backend you own | **The database category is essentially already done right** (local-real → hosted at deploy). It becomes the reference sandbox, not a rebuild. |
| **`stzLLMFunction`** (`neural/`) | a memo cache (`@aCache`: request-hash → validated value) + `SeedAnswer(input, value)`; *"memoized: deterministic, free"*; refuses when no model is loaded rather than faking | **The record-replay primitive already exists** for the hardest category (generative). Generalize it. |
| **`stzDLM`** + local GGUF (`learning/`, `neural/`) | deterministic answers from a domain knowledge graph; a small local model via vendored ggml | Two real fee-free stand-ins for an LLM that are not "fakes" — a local-real option for the LLM port. |
| **`stzSecretStore`** (`security/`) | the *one central place* to register, enumerate and govern secrets, with an audit trail | **The structural parallel** for the registry this plane needs — and where live-service credentials will resolve from. |
| **`Deploy(:Emulated)` / `Deploy(:Production)`** (`system/stzDelivery`) | a dual-phase deploy with an actor gate on the production commit | **The phase switch is already there.** Emulated binds sandboxes; production binds live adapters. No new machinery. |

So roughly 40% of the shape is proven. The work is to name the seam once, put a
central registry in front of it, and fill in the category sandboxes.

## 3. The architecture

### 3a. The port — a duck-typed contract per category

Exactly as a vault resolver is *"any object with `Resolve`,"* a **service port** is
*"any object with the category's methods."* A payments port answers
`Authorize(amount, token)` / `Capture(id)` / `Refund(id)`; a mail port answers
`Send(to, subject, body)`; a blob port answers `Put(key, bytes)` / `Get(key)`.
The port is a **contract, not a class** — Softanza binds to no vendor, just as the
vault seam binds to no secret manager.

For each port Softanza ships **a sandbox** (the fee-free stand-in) and, where
feasible, **a thin live adapter** (or just the adapter contract, for the user to
supply their vendor client).

### 3b. Three modes a sandbox can run in

Not every dependency virtualizes the same way. A sandbox offers whichever fit:

- **Scripted** — deterministic rules you write (*"approve if amount < 100, else
  decline"*). Best for behaviour you want to *drive* in tests.
- **Replay** — canned/recorded responses keyed by a request hash. This is exactly
  what `stzLLMFunction.@aCache` already does; generalize it to any HTTP-shaped
  service (the VCR/nock idea, Softanza-native).
- **Local-real** — a genuine local equivalent: sqlite for the database, the
  filesystem for a blob store, a local GGUF model for the LLM. Not a fake at all —
  the same reason you don't need a hosted DB subscription today.

### 3c. The registry — one place for every external dependency

A `stzServiceRegistry` is to services what `stzSecretStore` is to secrets: the
single place a solution declares *"I depend on payments, mail, an LLM, and blob
storage,"* binds each to a sandbox for the programming phase and a live adapter
for production, and makes the whole external surface **enumerable and governable**.
App code asks the registry for a service by name; the *phase* decides which
implementation it gets back. That indirection is the entire trick — the
application code is byte-identical in emulation and production.

```ring
oReg = new stzServiceRegistry("restolean")
oReg.Bind(:payments, new stzPaymentsSandbox().ApproveUnder(100))   # programming phase
oReg.Bind(:mail,     new stzMailSandbox())                          # captures, never sends

oPay = oReg.Service(:payments)          # the app asks by NAME
oPay.Authorize(4200, cToken)            # runs against the sandbox -- free, deterministic

# at deploy, the SAME registry binds live adapters (credentials from the store):
oReg.BindLive(:payments, new stzStripeAdapter(), oSecretStore, "stripe-key")
```

### 3d. The phase switch is the existing one

`Deploy(:Emulated)` resolves services to sandboxes; `Deploy(:Production)`
resolves them to live adapters, and — reusing the existing actor gate — a
production deploy **requires** each live service's credential to be present in the
secret store and an effectful actor to commit. No new deploy machinery.

## 4. The categories (the taxonomy, honest about what's done)

| Category | Sandbox | Live | Status |
|---|---|---|---|
| **Database** | sqlite (local-real) | a hosted-DB adapter | **≈ done** via `stzAppBackend`; adopt behind the port |
| **Generative / LLM** | replay cache + `stzDLM` + local GGUF | a frontier-API adapter | **BUILT** — `stzLlmPort` (`stzLlmSandbox` replay+scripted with cost accounting; `stzDlmSource` local-real) |
| **HTTP third-party API** (the general case) | scripted + replay | pass-through to the real URL | new — subsumes many SaaS APIs at once |
| **Payments** | deterministic gateway + an assertable ledger | Stripe/PayPal adapter | new — the canonical "sandbox," high-value demo |
| **Blob / object store** | local filesystem | S3/GCS adapter | new — small |
| **Mail / SMS / notifications** | a capture *sink* (inspect what would have been sent) | SendGrid/Twilio adapter | new — small |
| **Message queue / pub-sub** | the engine's own `stzEventBus` / reactive loop | SQS/Kafka adapter | new — the local primitive already exists |
| **Cloud control-plane** (provision a VM/queue) | rehearsed commands | real `ssh`/cloud CLI | **partly** — `stzDeployment.SetProvider` already rehearses |

## 5. Governance & agentic safety — the part that is *more* than convenience

This plane is not only a cost saver; it lands squarely on the library's security
doctrine, and that is its strongest justification.

1. **No sandbox may ship to production.** A `:Production` deploy that resolves any
   service to a sandbox is a violation — a **constraint rule** in the very engine
   the [graph-rules plan](SOFTANZA_GRAPH_RULES_PLAN.md) is about, and a finding in
   `stzSecurityPosture`. The "flip to real" is *enforced*, not remembered.
2. **Live credentials resolve through `stzSecretStore`** — audited, actor-gated,
   never inline. Binding a live adapter names a store secret; it never holds a key.
3. **An agent set loose against sandboxes has an empty *real-world* effect set.**
   This is the load-bearing safety property. During the programming phase an
   autonomous agent (an `LLMActor`) can exercise the whole solution — authorize
   payments, send mail, call the LLM — and **cause no real effect, because a
   sandbox payment moves no money and a mail sink sends no mail.** It is the same
   *expression-is-free, admission-is-governed* rule, extended to the outside
   world: real external effects are admitted only at production, only by an
   effectful actor, only with real credentials present. You can let an agent build
   and rehearse the entire integration safely, by construction.

## 6. Phases

Each ships something runnable and leaves the suite green.

1. **The port + `stzServiceRegistry`** — the duck-typed contract shape, the central
   registry, phase-bound resolution (sandbox vs live), and the two governance
   guards: an unbound service raises rather than silently no-ops; a sandbox bound
   in a production deploy is refused. Generalizes the vault-resolver pattern.
2. **Database exemplar** — wire `stzAppBackend`/sqlite in as the reference DB
   sandbox behind the port, with a hosted-adapter contract. Proves the pattern
   end-to-end from day one with code that already works.
3. **The generic HTTP sandbox** — scripted + replay (generalizing
   `stzLLMFunction.@aCache`) behind an HTTP port; the single highest-leverage
   category because it subsumes most SaaS APIs.
4. **Payments** — the canonical sandbox: a deterministic gateway with an assertable
   ledger, plus the adapter contract. The demo that makes the whole idea legible.
5. **Generative / LLM** — promote the existing replay + local model + `stzDLM`
   behind the port; the frontier adapter contract at deploy. *(BUILT — and it
   forced the plane's honest limit into the open: quality cannot be virtualized,
   so the sandbox sells determinism, measurable cost and offline instead. Cost
   accounting turned out to be the load-bearing feature: a fee-free plane should
   let you ASSERT the fee.)*
6. **Blob store + mail/SMS sink** — two small, high-value local-real / capture
   sandboxes.
7. **Delivery & governance integration** — the registry surfaces in the
   `stzDelivery` plan (every external dependency, its dev/prod binding, and the
   production credentials it will require, rehearsed *before* anything runs); the
   constraint rules land; `stzSecurityPosture` gains "no-sandbox-in-production."

## 7. The differential connection

The delivery plane already assigns each *capability* a vector — Regex →
`construct` (the platform's `RegExp`), BigInt → `native`, PivotTable → `engine`.
External dependencies are simply a **new axis on the same idea**: a dependency
gets vector `:sandbox` in the programming phase and `:live` at deploy. The plan
that already rehearses *"where each capability runs and why"* extends to *"where
each external service comes from, and what production will need to make it real."*
Same doctrine, one more dimension.

## 8. Honest caveats

- **A double is not the real service.** Replayed responses are not the live API's
  behaviour, and a scripted gateway is not Stripe's edge cases. The value is
  *building and testing the shape of your integration fee-free* — **you still need
  at least one real run before production.** The plan must say this in the tool's
  own voice, not bury it.
- **Frontier-LLM quality cannot be emulated.** Record-replay gives determinism for
  tests; a local model gives a real (smaller) answer; `stzDLM` gives deterministic
  domain answers. None of these *is* a frontier model. The sandbox is honest about
  which mode it is in — the same honesty `stzLLMFunction` already shows by refusing
  rather than guessing.
- **Recorded responses drift.** A replay cache goes stale when the real API
  changes. The plane needs a *re-record against the real API* step and, ideally,
  contract tests that flag drift — otherwise "green in the sandbox" quietly stops
  meaning "green against production."
- **Scope.** This is a *plane*, comparable to the delivery plane — bigger than
  graph-rules phase 1. Each category is real work. The first three phases (port +
  registry, DB exemplar, generic HTTP sandbox) are the spine; the rest are
  additive and can be paced.

---

*Softanza already lets you self-host the database, the backend, the secrets store
and a local model — real local equivalents, not fakes. This plane adds the missing
half: a named seam per external dependency, a central registry that binds a
fee-free sandbox during programming and the real service at deploy, and the
governance that makes "flip to real" an enforced boundary rather than a hope — so
an agent can build the whole integration without a subscription, an API fee, or
the ability to cause a single real-world effect until production admits it.*
