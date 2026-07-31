# Softanza Incident Analysis

### Security incidents as something the program KNOWS about itself — witnessed, detected, reconstructed, contained under governance, and attested

> **Status: I0-I2 SHIPPED (2026-08-01); I3-I8 planned.** This document is the
> design study for the security incident-analysis system. It is grounded
> in a full read of `base/security/`, `base/governance/`, the actor /
> plan / rule machinery, and the observability substrate the perf system
> (P0-P11) just finished building. Every "today" claim below was verified
> against the live tree; file:line anchors are given where a claim is
> load-bearing.
>
> Sibling of `SOFTANZA_SECURITY.md` (the constitution — this document
> does not restate it, it extends it in time). Written to the house
> pattern set by `SOFTANZA_PERF_SYSTEM.md`; a
> `SOFTANZA_INCIDENT_VS_THE_FIELD.md` will be written when the system
> ships, not before — comparing unbuilt things to shipped ones is how
> design docs lie.
>
> **I0 delivered:** `base/security/stzSecurityEvent.ring` — the typed
> record, the closed 30-kind catalog (each with default severity, an
> ATT&CK technique where one maps honestly, and a meaning in words),
> both clocks stamped at detection, the active trace id captured
> automatically, fluent build (`ByActor/About/Doing/AtRisk/FromOrigin`
> + `Granted/Refused/Failed`), `Record()`, `CanonicalString()` (the I1
> chain's input), `ToOcsfJson()`, `AsLine()/Explain()/Show()`, and the
> one-line seam forms `StzSecurityRefusal/StzSecurityGrant`. **The
> redaction law is structural**: `About()` takes an object's
> `Descriptor()` and this class never calls `Reveal()` — the guard
> proves a literal secret's value is absent from the subject, the
> canonical form, the human line and the exported JSON. Ring finding:
> catalog kinds are STRINGS, not `:symbols` (`:a.b.c` parses as `:a`
> plus member access). Guard: `test/system/security_event_narrated.ring`
> (49 assertions); security suites (secret 53, secretstore 26, posture
> 20, graph 22, authz 31) and the perf trace-scope guards re-run green.
> Narration: `narrations/stz-security-event-narration.md`.
>
> **I1 delivered:** `engine/src/seclog.zig` (`stz_seclog.dll`) — a
> bounded ring of canonical event lines, each digest computed IN THE
> ENGINE as `sha256(prev || "|" || canonical)` so no caller can forge
> history; `seclog_verify` returns the 1-based index of the first
> broken link. The engine gap the study named is closed:
> `crypto_hmac_sha256` is now exported (HMAC existed only inside
> PBKDF2/TOTP), bridged as `StzEngineCryptoHmacSha256`.
> `base/security/stzSecurityLedger.ring`: `Record()`, `Count()/Size()`,
> `At/All/Recent`, the analyst pivots (`OfActor/OfSubject/OfKind/
> OfTrace/OfOutcome/OfSeverity/OfOrigin/Refusals/Since/Between`),
> `Digest()/DigestAt()/Verify()`, and `SealTo(path, key)` +
> `StzVerifySealedLedger(path, key)` — which distinguishes an EDITED
> file ("the chain breaks at entry N") from a WRONG KEY ("the chain is
> intact but the SEAL does not match"), an investigation needing both.
> Correctness note: `CanonicalString()` now folds a field's own pipes
> to "/" at the source, so a reason quoting `a|b|c` cannot shift every
> field after it. Guard: `test/system/security_ledger_narrated.ring`
> (35 assertions, incl. tamper-detection on a real file and a 3-slot
> ring evicting through 5 events); 4 zig tests; security + OIDC/crypto
> suites re-run green. Narration:
> `narrations/stz-security-ledger-narration.md`.
>
> **I2 delivered:** the process ledger (`StzOpenSecurityLedger` /
> `StzSecurityLedgerQ` / `StzCloseSecurityLedger` / `StzNoteRefusal` /
> `StzNoteGrant` / `StzRecordSecurityEvent`), whose current-slot lives
> IN THE ENGINE (`seclog_set_current/has_current/current_append`) — a
> Ring global did not work and the guard caught it: process state
> belongs in the engine, the same law P9's trace scope established.
> Closed by default, and closed returns before the event is built.
> SIX classes wired at points that already knew: `stzRequestSigner`
> (unknown key / stale / **forged** / **replayed nonce**),
> `stzPasskeyServer` (assertion refusals + the anti-phishing clientData
> path that previously bypassed the refusal helper entirely, plus the
> clone-suspected counter), `stzSaml` (**replay** + rejection),
> `stzSecretStore` (grant + refusal, now timestamped and chained),
> `stzAuth` (every failure + the lockout), `stzUpdatePlan`
> (capability + **scope** + **posture** — the last two were never
> audited at all, the study's bug-shaped finding). Guard:
> `test/system/security_seams_narrated.ring` (37 assertions: the
> off-state, all four signer signals, both store outcomes, the
> redaction law across the WHOLE ledger, the two former gaps, 10
> distinct kinds firing, chain intact). Eleven security/auth/governance
> suites re-run green. Still unwired (kinds exist, one line each):
> OIDC token+code, cross-world/federated refusals, HTTP 401/403,
> rate-limit sheds, production-fake refusal, graph escalation paths.
> Narration: `narrations/stz-security-seams-narration.md`.

---

## 1. The finding that shapes everything

The security module is **rich in refusal reasons and poor in refusal
memory**.

Every verifier in `base/security/` produces an excellent explanation of
why it said no — and stores it in a single slot that the next call
overwrites:

| The library detects... | Where | What survives |
|---|---|---|
| a **cloned authenticator** (WebAuthn counter did not advance) | `stzPasskey.ring:127` | a returned string |
| an **assertion replay** (SAML, already consumed) | `stzSaml.ring:253` | a returned string |
| a **forged or tampered request** (HMAC mismatch) | `stzRequestSigner.ring:119` | `@cWhy`, overwritten |
| a **replayed nonce** (same nonce, same key) | `stzRequestSigner.ring:126` | `@cWhy`, overwritten |
| an **id-token forgery** (bad sig / issuer / audience / nonce) | `stzOidc.ring:363-396` | `@cLastWhy`, overwritten |
| an **auth-code replay**, a bad client secret | `stzOidcProvider.ring:299-330` | `@cWhy`, overwritten |
| a **capability refusal** (actor may not commit) | `stzVirtualSystem.ring:419-428` | audited |
| a **scope refusal**, a **posture refusal**, a bridge failure | same file, 385-413 | *not audited at all* |
| a **secret reveal refused** | `stzSecretStore.ring:137` | audited — untimestamped |
| a **sandboxed actor reaching effectful** | `stzSecurityRule.ring:46` | recomputed, never stored |

These are not weak signals. A stalled WebAuthn counter is the textbook
cloned-credential indicator. A replayed nonce against a valid key is an
active attacker, not a bug. In today's library each one is detected
perfectly, reported honestly to its immediate caller, and then
**forgotten** — and because nothing is timestamped, nothing is
correlated, and nothing outlives the call, the second occurrence looks
exactly like the first.

`SOFTANZA_SECURITY.md` already states the cure in one line, about the
secret store: *"A refusal is an event, not a silent failure."* This
document is that sentence applied **everywhere**, plus the four things
it needs to become an investigation: **memory, time, correlation, and a
governed way to act.**

## 2. What exists today (the study)

**Assets — more than expected.**

- **A typed decision vocabulary.** Capability kinds (`effectful ·
  sensing · compute · inference`) and postures (`trusted · external ·
  sandboxed`), risk tiers 1-4, authority levels advisory→emergency
  override. Every refusal in the library is already *typed*; nothing
  needs to be re-derived from text.
- **Refusal reasons everywhere** — a uniform `Why()` / `[ :ok=FALSE,
  ..., :why ]` convention across ten classes.
- **The security graph** (`stzSecurityGraph`): 6 node kinds, 7 labeled
  edges, `ReachesEffectful()`, `ReachesCapability()`, **`BlastRadius(secret)`**
  — multi-hop escalation analysis the field would call attack-path
  modelling, already shipped, already rule-checked.
- **Correlation identity**: W3C trace ids, the engine-global trace
  scope, and `stzLog.OfTrace(id)` (perf P9) — every log line written
  during a scoped request already carries the request's trace id.
- **Bounded engine stores**: the trace ring, the series ring, latency
  histograms, metric families with overflow buckets — the exact storage
  shapes an event ledger needs, already proven copy-proof.
- **Edge-triggered alerting with flight recorder**: `stzPerfSentinel`
  fires on transitions only and photographs state at the moment of
  firing.
- **Governed action**: `stzPerfPlan` — closed action catalog, actor
  preflight, full audit, LLM-proposes / effectful-commits. A response
  plan is the same object with a different verb list.
- **One CI gate**: the unified finding shape → `stzRuleReport`.
- **Attack-relevant primitives**: PCRE2 **with step limits** (ReDoS-safe
  signature matching), token-bucket rate limiters, per-host outlier
  ejection, constant-time compare, sha256, PBKDF2.

**Absences — verified, not assumed.** No security event type. No event
stream. No timeline. No detection over *sequences* (every rule in the
library checks static structure at one instant). No incident object. No
containment plan. No tamper-evidence on any audit surface. Governance
lineage has **no timestamps**, is queryable only by id, grows unbounded,
forks on Ring copy, and is **dropped by `Save()`** — the decision history
does not survive a round trip.

## 3. The field, honestly

### 3.1 The categories

| Category | Examples | What it does |
|---|---|---|
| **SIEM** | Splunk, Elastic Security, Sentinel, Google SecOps, Panther | collect → normalize → correlate → detect → retain, at fleet scale |
| **EDR/XDR** | CrowdStrike, SentinelOne, Defender | kernel/eBPF host telemetry, process trees, host isolation |
| **SOAR** | XSOAR, Splunk SOAR, Tines, Torq | response playbooks with approval gates |
| **DFIR** | Velociraptor, Timesketch, Volatility, KAPE | evidence acquisition, custody, timeline reconstruction |
| **Runtime / cloud-native** | Falco, Tetragon, Tracee, Sysdig | syscall-level rules, Kubernetes-aware |
| **Detection-as-code** | Sigma, Panther detections, Elastic rules | versioned, CI-tested detection content |
| **Schemas & frameworks** | OCSF, ECS, STIX/TAXII, MITRE ATT&CK, NIST SP 800-61 | normalization, taxonomy, lifecycle |
| **Log integrity** | hash chains, Rekor, CloudTrail validation, journald FSS, WORM | making the log admissible |
| **RASP / AppSec runtime** | Contrast, Imperva | in-app attack detection, injected |
| **Supply chain** | SLSA, in-toto, Sigstore, SBOM (SPDX/CycloneDX) | artifact provenance |

### 3.2 The structural critique

Almost the entire field is **external to the application**. The app
emits text; a platform re-derives meaning from that text with parsers,
grok patterns and field mappings; detections are written against the
*reconstruction*, not against the truth. This costs three things:

1. **Fidelity.** The app knew it refused a *sandboxed* actor's attempt
   to reveal a *production* secret. The SIEM sees a string and tries to
   recover that with a regex. Every normalization schema (OCSF, ECS)
   exists to repair damage that only occurred because the semantics were
   thrown away at the door.
2. **Latency of understanding.** Detection happens minutes to hours
   later, elsewhere, by someone who must reconstruct what the program
   meant.
3. **Authority confusion.** SOAR playbooks act with whatever credentials
   the automation holds; "who may contain what" is a platform
   configuration, not a property of the system being defended.

RASP is the closest neighbor — it instruments the app to detect attacks
from inside — but it is *injected* into an app that does not know
itself, so it detects with heuristics (this SQL looks like injection)
rather than with the app's own typed decisions.

### 3.3 What the field does that Softanza will not

Stated now, so the plan does not drift into pretending otherwise:
fleet-scale storage and query (PromQL/SPL-class), months of retention,
UEBA/ML baselining, threat-intel feeds, host and network telemetry,
geo/device enrichment, SOC workflow (ticketing, shift handover,
case management at team scale). **Softanza's answer is to export
natively** (OCSF, OTLP) and let those systems do what they are good at
— the same posture the perf system took toward Prometheus and Grafana.

### 3.4 Where Softanza can be genuinely different

1. **Structured at birth, not parsed after.** The gate that refuses IS
   the event source: actor, posture, capability, risk tier, subject,
   outcome, reason — typed, no parsing, no schema guessing.
2. **Detection in the app's own vocabulary.** "A sandboxed actor
   attempted an effectful action" is a *type-level* statement here, not
   a pattern-match over log text.
3. **Attack paths as graph queries, already shipped.**
   `ReachesEffectful` / `BlastRadius` answer "what could this actor have
   reached" and "what does this leaked secret touch" — questions most
   SIEMs cannot answer at all because they never had the model.
4. **Containment under the same lattice as everything else.** Response
   is a governed plan: an inference-only actor may investigate and
   propose containment and is structurally unable to execute it. That is
   SOAR whose authority model is the application's own — and it is the
   answer to agentic security's hardest question, already half-built.
5. **Detections tested against real driven attacks.** Sigma rules are
   validated against sample logs; a Softanza detection can be proven by
   an adversary-emulation harness firing the real sequence at a real
   spawned app (the P11 load-driver pattern, pointed at security).
6. **Evidence-grade by construction.** A hash-chained, sealed ledger
   makes "the audit log" something a broken chain can expose — precedent
   already exists (`stzPredicateSet` seals rule sets with sha256).

## 4. The thesis

Three commitments, each inherited from doctrine the library already
holds:

1. **A refusal is an event.** Every governed decision — granted or
   refused — becomes a durable, typed, timestamped record carrying the
   reason the gate already produced. Nothing is re-derived; nothing is
   forgotten. *Softanza already detects; this makes it remember.*

2. **Evidence, not logging.** The ledger is bounded, hash-chained and
   verifiable: a retroactive edit breaks the chain and says so. Events
   inherit the library's redaction discipline — a security event about a
   secret carries its **descriptor**, never its value. An incident record
   must never become the leak it describes.

3. **Investigation is free; containment is governed.** Reading events
   and building incidents are `sensing` acts, open to any actor that may
   observe. Every containment act — revoke, lock, rotate, shed,
   quarantine — is `effectful` and crosses only through an audited plan.
   The machine may analyze and propose; an effectful actor commits.

## 5. The vocabulary

The perf system closed its vocabulary at four letters (U/R/X/D). This
system closes its own at **five verbs and one record**.

**The pipeline** (NIST SP 800-61's lifecycle in the library's voice):

```
Witness  ->  Detect  ->  Reconstruct  ->  Contain  ->  Attest
(record)    (judge)     (investigate)    (act,       (seal +
                                          governed)   export)
```

**The record** — one shape, six questions, closed fields:

| Field | Meaning | Source |
|---|---|---|
| `:kind` | what happened, from a closed catalog (§6.1) | the gate |
| `:actor` + `:posture` + `:kinds` | WHO | `stzSystemActor` |
| `:action` + `:risk` | WHAT was attempted, at which risk tier | `stzGovernance` |
| `:subject` | WHICH thing (secret/session/site/route/part) — a **descriptor** | the gate |
| `:origin` | from where (ip / host / endpoint), when the seam knows it | the gate |
| `:outcome` | `granted · refused · failed` | the gate |
| `:reason` | the gate's own `Why()` — never re-derived | the gate |
| `:atWall` / `:atMono` | absolute forensic time / ordering time | clocks-are-scopes |
| `:traceId` | correlation backbone | the active trace scope |
| `:severity` | `info · warning · error` (house set) | the catalog |

## 6. The objects

New classes in **`base/security/`** — not a new folder: the security
doc's own law is that security is *one* vocabulary applied in many
places, and splitting incident analysis out would re-scatter what was
deliberately consolidated.

### 6.1 `stzSecurityEvent` — the typed record (I0)

A value object over the §5 fields, with a **closed kind catalog** whose
names are well-known and stable (the perf lesson: `http.request.ms` is
an API). First draft of the catalog, each mapped to the seam that
already detects it, and (where meaningful) to its MITRE ATT&CK technique
for outbound interoperability:

```
auth.login.failed            auth.lockout.engaged        (T1110 brute force)
auth.twofactor.failed        auth.session.revoked
auth.passkey.clone_suspected                             (T1550 alt. material)
sso.assertion.replayed       sso.token.rejected          (T1550.001)
sig.nonce.replayed           sig.signature.forged        (T1550)
secret.reveal.refused        secret.reveal.granted       (T1552 credentials)
capability.refused           scope.refused               (T1068 escalation)
posture.refused              plan.op.failed
http.request.unauthorized    http.request.forbidden
ratelimit.shed               service.production_fake_refused
graph.escalation_path_found                              (T1078 valid accounts)
```

### 6.2 `stzSecurityLedger` — evidence, not a log (I1)

Engine-backed bounded ring (the `perf_trace_*` shape), each entry
carrying `sha256(prev_digest || this_event)` — a **hash chain**, so a
retroactive edit is detectable and `Verify()` names the first broken
link. Queries are the analyst's pivots: `Since(ms)`, `OfActor(name)`,
`OfSubject(desc)`, `OfKind(kind)`, `OfTrace(id)`, `Refusals()`,
`Between(t1, t2)`. Bounded by design (the house law); `SealTo(path)`
exports a signed, verifiable slice for external retention.

*Engine addition needed:* a standalone HMAC export at the C ABI (today
HMAC exists only inside PBKDF2/TOTP) so the seal can be **keyed** rather
than merely hashed. One Zig function + one bridge row.

### 6.3 `stzDetection` / `stzDetectionSet` — detection-as-code (I3)

The library's rules today judge **structure at one instant**. Detections
judge **sequences over time** — the missing half:

```ring
oD = StzDetection("credential-stuffing")
oD.WhenKind(:auth.login.failed).From(:sameActor).Repeats(5).Within(60000).AsError()

oD2 = StzDetection("stolen-then-used")
oD2.WhenKind(:auth.login.failed).ThenKind(:secret.reveal.refused).Within(300000)

oD3 = StzDetection("novel-signer").WhenKind(:sig.signature.forged).FirstSeen(:key)
```

Verdicts are findings in the unified shape (`:subject = "security"`) →
`stzRuleReport.Ingest()`: a detection that fires can fail CI in a drill
exactly as a capability violation does. The **corroboration law** (perf
law 5, applied): a detection may require two *independent* signals
before it reaches error severity — one signal is a rumor.

### 6.4 `stzSecuritySentinel` — the watcher (I4)

A clone of the perf sentinel's proven shape: edge-triggered (fires on
transition, not on state), `OnDetection(f)` / `OnClear(f)` callbacks,
fan-out on the process-global event bus (`sec.detection`), a bounded
alert log, and the three run modes (pull / tick / hosted via
`Name_()` + `Cycle()` — a served app watches itself while serving).
On firing it **opens an incident** and photographs context.

### 6.5 `stzIncident` — the case file (I5)

Correlation into one investigable object: the triggering detection, the
related events (gathered by trace id, actor, and subject), a **timeline**
in wall time, the **attack path** from `stzSecurityGraph`
(`ReachesEffectful`, the path itself), the **blast radius** of any
secret involved, a status lifecycle (`open → contained → closed`), and
`Explain()` — the narrated account:

```
Incident INC-3 (error) opened 14:02:11.
  14:02:11  actor 'billing-agent' (external) failed login for 'admin'  x5 from 10.0.0.7
  14:03:04  request signed for key 'billing' REPLAYED a nonce         (sig.nonce.replayed)
  14:03:05  reveal of secret 'stripe-live' REFUSED (actor not effectful)
  Attack path: billing-agent -uses-> deploy-tool -grants-> effectful  (2 hops)
  Blast radius of 'stripe-live': 3 sites.
  Detections: credential-stuffing (5-in-60s), stolen-then-used (sequence).
```

Same instructive dimension as the perf profile's `Explain()`: an analyst
gets the story, a student learns what correlation *is*, from their own
system's events.

### 6.6 `stzResponsePlan` — containment, governed (I6)

`stzPerfPlan` with a security verb list — closed catalog
(`:RevokeSession`, `:LockAccount`, `:RotateSecret`, `:RevokeCapability`,
`:ShedSource`, `:QuarantinePart`), rationale carried from the incident's
own findings, `MayCommit(actor)` preflight, `ExecuteOn(target, actor)`
gated on effectful + non-sandboxed, every outcome audited (refusals
never silent). The consequence, by construction: **an LLM actor can run
the whole investigation and propose the containment it cannot perform.**

### 6.7 Export & attestation (I7)

Per the house interop rule (every object gets a native shape *and* an
industry serialization): **OCSF** JSON for events (the modern SIEM
schema), **OTLP logs** reusing the P9 envelope, the unified findings for
the CI gate, and the sealed ledger slice with a custody statement
(chain digest, range, signer) for retention outside the process.

## 7. Seams — where events come from (I2)

The phase that makes the library stop forgetting. Every row already
*detects*; none of them currently *remembers*:

| Event | Seam | Today |
|---|---|---|
| login / 2FA / OTP / passkey failure, lockout | `stzAuth` login paths (`:269, :316, :677, :1018`) | counter only, wiped on success |
| session expired / revoked / rotated | `stzAuth` session paths | row deleted, no trace |
| **cloned authenticator** | `stzPasskey.ring:127` | string returned |
| SAML replay / issuer / audience / window | `stzSaml.ring:229-253` | `@cWhy` |
| OIDC token + code refusals | `stzOidc.ring:363`, `stzOidcProvider.ring:299` | one-slot why |
| **forged signature / replayed nonce** | `stzRequestSigner.ring:100-131` | `@cWhy` |
| secret reveal granted / refused | `stzSecretStore.ring:137/145` | logged, untimestamped |
| bare-secret reveal refusal | `stzSecret.ring:189` | raise only |
| capability / **scope** / **posture** refusals, bridge failure | `stzVirtualSystem.ring:385-435` | only capability audited |
| cross-world + federated call refusals | `stzSuperApp.CallAcross`, `stzComputeFederation` | `Why()` |
| 401 / 403, rate-limit shed | `stzAppServer._Dispatch`, `stzRateLimiter` | status codes / counters |
| production-fake refusal | `stzServiceRegistry` | raise |
| escalation path appears | `stzSecurityGraph` + rules | recomputed, not evented |

Two of these rows are bug-shaped and worth fixing regardless of this
plan: scope and posture refusals are **not audited at all** today, and
the governance lineage is **lost on `Save()`**.

## 8. Governance of the incident system itself

The system must obey the doctrine it enforces:

- **Reading is sensing; containing is effectful.** Building incidents,
  running detections and reading the ledger require `sensing`; every
  containment verb requires `effectful` + non-sandboxed, through the
  plan.
- **The ledger is itself sensitive.** It names actors, subjects, IPs and
  refusals — a complete map of what is worth attacking. Ledger reads are
  governed, and the redaction law is absolute: **descriptors, never
  values**.
- **The LLM's place is fixed.** Inference-only actors investigate,
  narrate, and propose. The library's six existing enforcement
  checkpoints gain a seventh: `stzResponsePlan.ExecuteOn`.
- **Findings join the one gate.** Detections emit the unified shape;
  `stzRuleReport` stays the single CI verdict across code, agents,
  security, workflow, orgcharts — and now incidents.

## 9. Laws (carried and new)

Carried from the perf grind (`CLAUDE.md`, "Perf-system laws"): engine
handles materialized eagerly (copy law); one face drives Ring-side
state; bounded stores everywhere; edge-triggered alerting with snapshot;
clocks are scopes (wall for forensic absolutes, monotonic for ordering);
f64 serialization boundary; findings → one gate; `Name_()`/`Cycle()` for
anything periodic; industry format from day one.

New, security-specific:

1. **Detect ≠ remember.** A detection that is not recorded is a rumor.
   Any code that can say *why* it refused must also be able to say *that*
   it refused, durably.
2. **Redaction is inherited.** No event, incident, export or narration
   carries a secret value — only its descriptor. The incident record must
   never become the breach.
3. **The ledger is evidence.** Append-only, hash-chained, verifiable,
   sealed on export. "Trust me, it's in the log" is not a security
   property.
4. **Corroborate before alarming.** Prefer two independent signals for
   error severity; a single anomalous read is a warning at most.
5. **Judge the newest against the prior window** (leave-one-out, perf
   law 6) — an outlier test that includes the outlier in its own
   baseline cannot fire.
6. **Vocabulary collision is a defect.** "Breach" already means *SLA
   breach* in this tree. Security uses **detection / incident /
   finding**; the perf system keeps `breach`.

## 10. Plan of record (I0-I8)

Each phase ships the house triple — design-doc update, runnable
narration (`narrations/stz-incident-*-narration.md`, every output real),
and a narrated guard (`base/test/security/*_narrated.ring`) — and lands
green before the next begins.

- **I0 — The event. SHIPPED 2026-08-01.** `stzSecurityEvent`, the closed
  30-kind catalog, the redaction law enforced structurally, wall +
  monotonic stamps, trace id from the active scope, OCSF export from
  day one. 49 assertions. *(Smallest phase; it fixes the vocabulary
  everything else uses.)*
- **I1 — The ledger. SHIPPED 2026-08-01.** Engine-backed bounded ring +
  sha256 hash chain computed engine-side + `Verify()` naming the broken
  link; the analyst pivots; `SealTo`/`StzVerifySealedLedger` telling an
  edited file apart from a wrong key; the standalone HMAC engine export
  delivered. 35 assertions.
- **I2 — The seams. SHIPPED 2026-08-01 (six classes; the rest listed
  above as remaining).** The process ledger + `StzNote*` helpers, the
  engine-held current slot, and the wiring of the signer's four
  signals, the passkey refusals, SAML replay, the secret store's two
  outcomes, every auth failure, and the three plan refusals —
  including scope and posture, which no audit had ever recorded. 37
  assertions; eleven suites green.
- **I3 — Detection.** `stzDetection`/`stzDetectionSet`: N-in-window,
  sequence, novelty/first-seen, rate; findings → `stzRuleReport`; the
  corroboration law.
- **I4 — The sentinel.** Edge-triggered watcher, event-bus fan-out,
  hostable on `stzAgentHost`, opens incidents, photographs context.
- **I5 — The incident.** Correlation into a case file: timeline, attack
  path, blast radius, lifecycle, narrated `Explain()`.
- **I6 — Response.** `stzResponsePlan`: closed containment catalog,
  preflight, audited execution, LLM-proposes / effectful-commits.
- **I7 — Attest & export.** OCSF events, OTLP logs, sealed ledger +
  custody statement, CI-gate integration.
- **I8 — The drill.** Adversary-emulation harness (the P11 load-driver
  pattern pointed at security): spawn a real app, fire real bad
  sequences — credential stuffing, nonce replay, escalation attempt —
  and assert the detections fire and the incident reconstructs. *A
  detection nobody has ever seen fire is a hypothesis.*

## 11. Honest caveats

- **An in-process ledger dies with the process.** Hash chaining detects
  retroactive edits; it does not survive an attacker with code execution
  in-process, nor a crash. Evidence-grade means *exported* — I7's seal is
  the boundary, and retention belongs downstream.
- **This is application-layer only.** No host, kernel, or network
  telemetry; no memory forensics. An attacker below the app is out of
  scope by construction.
- **Detections see what the seams emit.** Same caveat the graph-rules
  plan states about extraction: report what can be seen and say so, never
  emit false confidence.
- **No enrichment.** No geo, device fingerprinting, threat intel, or
  behavioural baselining trained on months of data.
- **Bounded means forgetting.** A ring buffer loses the oldest events by
  design; a long, slow campaign outruns the window unless exported.
  I1 will make the window explicit rather than pretend otherwise.

---

*The industry treats a security incident as something reconstructed
afterwards, elsewhere, from text an application threw over the wall.
Softanza already knows — at the moment of refusal — who asked, what they
wanted, which capability was missing, and why the answer was no. The
whole of this plan is to stop discarding that knowledge one call later:
to remember it as evidence, judge it over time, reconstruct it into a
story a person can read, and let only governed hands act on it. A
program that can explain how it runs should also be able to explain who
tried to make it run otherwise.*
