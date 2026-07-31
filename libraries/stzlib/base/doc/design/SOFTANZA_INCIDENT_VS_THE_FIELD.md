# The Softanza Incident-Analysis System vs the Field

### An honest comparison with the SIEMs, the EDR/XDR agents, SOAR, the DFIR toolchain, Sigma, RASP, and the adversary-emulation harnesses

> Companion to `SOFTANZA_INCIDENT_ANALYSIS.md` (I0-I8, complete: 9
> narrated guards, 300 assertions). Sibling of
> `SOFTANZA_PERF_VS_THE_FIELD.md`, and written under the same rule —
> **the comparison waits until the system ships**, because comparing an
> unbuilt design against shipped products is how design documents lie.
> Field references are as of early 2026.

---

## 1. First, name the categories

"Security incident tooling" covers six different kinds of thing, and a
fair comparison must not mix them:

1. **SIEM / detection platforms** — collect, normalize, correlate,
   retain, at fleet scale: Splunk, Elastic Security, Microsoft
   Sentinel, Google SecOps, Panther.
2. **EDR / XDR agents** — kernel and eBPF host telemetry, process
   trees, host isolation: CrowdStrike, SentinelOne, Defender.
3. **SOAR** — response playbooks with approval gates: XSOAR, Splunk
   SOAR, Tines, Torq.
4. **DFIR toolchains** — evidence acquisition, chain of custody,
   timeline reconstruction: Velociraptor, Timesketch, KAPE,
   Volatility.
5. **Runtime rule engines** — syscall-level, cluster-aware: Falco,
   Tetragon, Tracee.
6. **Content, schemas, and harnesses** — Sigma, OCSF/ECS, MITRE
   ATT&CK, NIST SP 800-61, Atomic Red Team, Caldera, Stratus Red Team.

The Softanza incident system is **none of these categories and a thin
slice of five of them**, occupying a position the taxonomy does not
have a name for: an *in-application* witness that is structurally
incapable of losing what the application already knew. It witnesses
like RASP, keeps evidence like DFIR, judges like a SIEM's detection
layer, contains like SOAR, and proves itself like an
adversary-emulation harness — all inside the process, in the
application's own vocabulary, over 300 assertions. It is explicitly
NOT a storage, retention, or SOC-workflow platform: it *exports* to
that world (OCSF, OTLP logs) rather than competing with it.

## 2. The structural claim, restated now that it is built

The plan's thesis was that almost the whole field is **external to the
application**: the app emits text, a platform re-derives meaning from
that text, and detections are written against the *reconstruction*.
Having built the alternative, the claim can be stated more precisely
than it could be at design time.

At the moment `stzVirtualSystem` refuses a bridge crossing, the program
holds: the actor's name, its posture (`sandboxed`), the capability it
lacked (`effectful`), the subject descriptor, the reason, both clocks,
and the active trace id. **All of that is already typed.** Every
normalization schema in the field — OCSF, ECS — exists to repair damage
that occurs only because those fields were flattened into a sentence at
the door and parsed back out somewhere else. Softanza's event is
constructed from the decision itself and *serialized to OCSF on the way
out*, which is the same standard arriving by the opposite route.

The measurable consequence is what `CanonicalString()` does: the
canonical form is the chain input, so the exact fields the detector
judges are the exact fields the hash commits to. In the field, the
detection reads a parsed reconstruction while the integrity control (if
any) protects the raw text — two different objects.

## 3. Head-to-head: the SIEM detection layer

| Dimension | Splunk / Elastic / Sentinel / Panther | **Softanza incident** |
|---|---|---|
| Event origin | app writes text; platform parses | the refusing gate constructs the typed event (`stzSecurityEvent`, 34-kind closed catalog) |
| Schema | OCSF/ECS applied by normalization | typed at birth, OCSF emitted as an *export* |
| Detection language | SPL / KQL / EQL / Sigma YAML | Ring: three shapes (burst, sequence, any) in the app's own vocabulary |
| Where detections run | the platform, minutes to hours later | in-process, `Check()` on a bounded ledger, immediately |
| Detection content | thousands of community rules | 8 shipped detections over the catalog + whatever the app declares |
| Scale | petabytes, months of retention | a bounded engine ring; export or forget |
| Correlation | search-time joins across sources | one hop: the actor's whole story + everything sharing a trace id |
| Alert discipline | tuning, dedup, suppression, all configured | one finding per **story**, not per match; corroboration required for `error` severity |
| Verdict shape | platform-specific alert object | the house rule shape `[:rule,:subject,:where,:severity,:message]` → the same CI gate as security and perf |

The honest reading: **on everything that is a function of scale, the
SIEMs win outright and it is not close** — retention, search, fleet
correlation, UEBA baselining, threat-intel enrichment, thousands of
maintained detections, and a UI an entire SOC shares. Softanza has none
of that and has said so since the design doc.

What inverts is fidelity and immediacy. A Softanza detection asks *"did
a sandboxed actor attempt an effectful action"* as a type-level
statement. A SIEM asks the same question as a pattern-match over text
that was already lossy when it was written. And the corroboration law
(`Corroborated()` downgrades any finding whose evidence spans fewer
than two kinds, and *says so in the message*) is a discipline the field
implements as tuning culture rather than as a property of the rule.

## 4. Head-to-head: log integrity and the DFIR toolchain

This is the comparison the system most deserves, because the ledger is
its foundation.

| | CloudTrail digest / journald FSS / Rekor / QLDB | Velociraptor + Timesketch | **stzSecurityLedger** |
|---|---|---|---|
| Integrity | hash chain / signed digest / transparency log | acquisition hashes, custody forms | `sha256(prev \| canonical)` computed **engine-side** — Ring cannot forge history |
| Tamper report | "verification failed" | analyst compares hashes | `Verify()` returns the **1-based index where the chain breaks** |
| Wrong key vs edited file | usually indistinguishable | n/a | **distinguished, deliberately** — they are different incidents |
| Custody | external documentation, forms | first-class in the tool | `stzSecurityAttestation`: attestor, time, count, head digest, and the verify instruction *in words*, inside the seal |
| On tampered evidence | warns; analysis continues | analyst's judgment | **refuses to hand back a ledger at all** |
| Acquisition | agent collects from the host | agent collects from the host | the subject seals; the analyst verifies before believing |

Two of those rows are genuinely unusual.

**The refusal to analyse.** `StzLedgerFromSealedFile` on an edited file
returns no ledger — not a ledger plus a warning. The field's norm is
verify, warn, proceed, which trains its users to click past the
warning. A tool that analyses evidence it has just declared untrustworthy
is teaching a habit that ends in court.

**The distinction between a wrong key and an edited file.** Most
integrity checks collapse both into "invalid". They are different
incidents: one is a key-management failure, the other is an attacker.
Saying which one is a small feature and a large difference in what the
responder does next.

Where the DFIR toolchain wins, decisively: memory forensics, disk
images, host artifacts, filesystem timelines, and the entire
below-the-application universe. Softanza is application-layer by
construction and holds one kind of evidence — but it holds it at a
fidelity a disk image cannot recover, because the semantics were never
written down anywhere else.

## 5. Head-to-head: SOAR and the agentic question

| Dimension | XSOAR / Tines / Torq | **stzResponsePlan** |
|---|---|---|
| Action set | arbitrary integrations, open-ended | **closed 6-verb catalog** |
| Where the plan comes from | an author writes a playbook ahead of time | `ProposeForIncident` **derives** it from the incident's own facts (RevokeCapability only when the graph says the actor reaches effectful) |
| Authority | the automation's credentials — a platform configuration | the **application's own capability lattice**: `effectful` + non-sandboxed |
| Preflight | "will this integration work" | `MayCommit()` / `WhyNot()` on the actor, before anything moves |
| Audit | platform activity log | both verdicts become **ledger events** — the chain covers attack *and* response |
| An LLM in the loop | prompt-and-permissions, enforced by policy text | `LLMActor` is inference-only + sandboxed: it composes the entire plan and **is structurally unable to commit** |

That last row is the strongest claim in the document, and it is the one
the industry is currently arguing about. The field's answer to "can an
AI agent respond to incidents" is approval workflows, prompt hardening,
and scoped credentials — all of which are policy asserted *around* a
capable actor. Softanza's answer is that the actor is not capable: the
LLM composes a complete, correct containment plan, and `ExecuteOn`
refuses it on the capability lattice, recording `response.action.refused`
in the same chain as the attack. **Proven, not asserted** — that is what
the I6 guard tests.

The narrow reading matters too: this is authority modelling, not
alignment. It says who *may* act, not whether the plan was wise.

## 6. Head-to-head: RASP, and why the resemblance is superficial

RASP (Contrast, Imperva) is the nearest structural neighbour — it too
detects from inside the application. The difference is what it detects
*with*.

RASP is **injected into an application that does not know itself**, so
it must guess: *this SQL string looks like injection; this path looks
like traversal*. It is heuristics applied to an app's data flow from the
outside-in.

Softanza's events come from decisions the application already made, in
the application's own terms. There is no heuristic in
`capability.refused` — a gate refused a named actor a named capability,
and that is not an inference about intent, it is a record of an
outcome. The corollary is the honest limit: **Softanza detects what the
seams emit**. RASP sees attacks against code that never consented to be
observed; Softanza sees only what its own gates decided. Against an app
built on Softanza's gates, that is more; against arbitrary code, it is
nothing at all.

## 7. Head-to-head: detection content and the drill

Sigma and the detection-as-code movement had exactly the right idea:
detections are code, they belong in version control, and they should be
tested. The field tests them **against sample logs**.

I8 tests them against a **real running application**. `stzSecurityDrill`
spawns a target with its own ledger, its own `stzAuth` and its own
`stzRequestSigner`, then attacks it over real HTTP — five bad passwords,
a forged MAC, a replayed nonce. The passwords really fail; the MAC
really fails to verify; the nonce really trips the replay cache, in
another process, through a socket.

| | Atomic Red Team / Caldera / Stratus | Sigma unit tests | **stzSecurityDrill** |
|---|---|---|---|
| What is attacked | a real host / cloud account | nothing (log fixtures) | a real spawned application |
| Scope of techniques | broad ATT&CK coverage | whatever the rule matches | the wired seams only |
| How the result is observed | the analyst checks the SIEM | assertion on a fixture | evidence **sealed by the target and verified by the parent** |
| Verdict | manual | pass/fail on text | `Passed()` / `MissedDetections()`, 20 assertions |

The distinctive property is not the attacking; it is the **evidence
boundary**. The drill's parent never reads the target's memory. It
learns what happened only from a file the target sealed and the parent
verified — which means the drill's conclusions rest on exactly the
evidence an auditor would be handed, and one call exercises the hash
chain, the attestation and the acquisition path together. The
adversary-emulation platforms attack far more broadly; none of them
subject their own verdict to the custody chain.

And the argument for drills in general is what this one found before it
found any attacks: **two library defects, neither reachable from an
in-process guard** — a seal route that answered `"sealed"`
unconditionally (a status that cannot be false is not a status), and
capability-bearing actors silently degrading inside a spawned child's
handlers. A detection nobody has ever seen fire is a hypothesis; so is a
control nobody has ever seen refuse.

## 8. The distinctive five

Where the comparison inverts. Each traces to a Softanza doctrine rather
than a feature race:

1. **The event is the decision, not a description of it.** No parser
   stands between what the program knew and what the detector judges,
   and the canonical form the detector reads is the form the hash
   commits to.
2. **Redaction is structural, not configured.** `About()` takes a
   `Descriptor()`; the event class **never calls `Reveal()`**. A secret
   value cannot reach the ledger, so it cannot reach the OCSF export,
   the incident file, or the sealed evidence. The field's answer is
   scrubbing pipelines — filters applied after the value was already
   written down.
3. **Attack paths are graph queries the library already had.**
   `AttackPath` / `BlastRadius` / `PathToEffectful` answer *"what could
   this actor have reached"* and *"what does this leaked secret touch"* —
   questions most SIEMs cannot answer at all, because they never had the
   model. I5 needed one addition: the graph could say *whether*; an
   investigation needs *how*.
4. **One rule shape for six domains.** A credential-stuffing detection,
   an SLA breach, a capability escalation and a code-quality violation
   are all `[:rule,:subject,:where,:severity,:message]` into
   `stzRuleReport` — **one CI gate**. When I7 arrived, the CI
   integration needed no work at all, because findings had been in that
   shape since I3. Nothing in the field couples security detections to
   the codebase's own rule system.
5. **Everything narrated, everything guarded.** Nine narrated guards,
   300 assertions, every documented output a real run. The field's
   equivalent is reference documentation and vendor blog posts.

## 9. What the field has that Softanza lacks — honestly

- **Scale, retention, and search.** No TSDB, no SPL, no months of
  history. The ledger is a bounded ring: **bounded means forgetting**,
  and a slow campaign outruns the window unless it is exported. By
  design — the export is the boundary.
- **Host, kernel, and network telemetry.** No eBPF, no process trees,
  no memory forensics, no network flows. An attacker *below* the
  application is out of scope by construction, and an attacker with
  in-process code execution can stop the witnessing entirely. Hash
  chaining detects retroactive edits; it does not survive the attacker
  who owns the process. Sealed export is the only real answer.
- **Enrichment and baselining.** No geo, no device fingerprints, no
  threat-intel feeds, no UEBA. Detections are declared, not learned.
- **Detection content at community scale.** Sigma's rule corpus versus
  eight shipped detections over one catalog.
- **SOC workflow.** No ticketing, no shift handover, no case management
  at team scale. `stzIncident` is a case *file*, not a case management
  system.
- **Unwired seams.** I2 wired six classes; OIDC token/code refusals,
  cross-world and federated refusals, HTTP 401/403 at the dispatcher,
  rate-limit sheds, production-fake refusals and graph escalation paths
  are still one line each and still not written. The kinds exist in the
  catalog; the calls do not. **A detection can only see what a seam
  emits**, so this is the system's largest honest gap and it is listed,
  not hidden.

## 10. The one-table summary

| Question | The field's answer | Softanza's answer |
|---|---|---|
| Where does an event come from? | the app prints text; a platform parses it back | the gate that refused constructs it, already typed |
| What keeps a secret out of the log? | a scrubbing pipeline downstream | the event class cannot read secret values |
| Is the log evidence? | usually a log; sometimes a signed digest | hash-chained engine-side, sealed, attested, and the break index is named |
| What happens to edited evidence? | verify, warn, analyse anyway | refuse to analyse it |
| Who wrote the detections? | a vendor, a community, a detection engineer | the application, in its own vocabulary |
| What could the attacker have reached? | usually unanswerable — no model | a graph query the library already had |
| Who may contain the incident? | whoever holds the automation's credentials | an `effectful`, non-sandboxed actor — audited into the same chain |
| Can an AI agent respond? | policy, prompts, and scoped tokens | it may propose everything and commit nothing, structurally |
| Do the detections actually fire? | tested against sample logs | fired at a real spawned app, verdict taken from sealed evidence |
| Can other tools read it? | vendor formats, or OCSF/ECS after normalization | OCSF and OTLP logs emitted natively, in and out |

## 11. Positioning, in one paragraph

The Softanza incident system does not compete with Splunk, CrowdStrike,
or Velociraptor, and should not pretend to: it holds one narrow layer of
evidence, for one process, for a bounded window, and it exports natively
to the platforms built for scale. What it offers that the field does not
is *the elimination of the lossy boundary at the door*. The industry's
entire normalization apparatus — OCSF, ECS, grok, field mappings — exists
to reconstruct meaning an application already had and threw away one
call later. Softanza keeps it: typed at birth, hash-chained as evidence,
judged in the app's own vocabulary, reconstructed into a story a person
can read, contained only by hands the capability lattice permits, and
proven by firing real attacks at a real app and taking the verdict from
sealed evidence. The field treats a security incident as something
reconstructed afterwards, elsewhere, from text an application threw over
the wall. Softanza treats it as something the application knows about
itself — the same doctrine the library already applies to performance,
governance, and delivery.

---

*Written at system completion (I0-I8, 2026-08-01), against the field as
of early 2026. When the field moves — a SIEM ingests typed events without
a parser, or a SOAR platform adopts the defended application's own
authority model — revisit sections 3 and 5.*
