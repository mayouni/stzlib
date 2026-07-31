# The Softanza Performance System vs the Field

### An honest comparison with Micrometer, OpenTelemetry, Prometheus, the APM agents, JFR, and the platforms that scale

> Companion to `SOFTANZA_PERF_SYSTEM.md` (P0-P7, complete). This
> document places the system among the tools an industry practitioner
> already knows: what is genuinely different, what is deliberately
> absent, and what is simply missing. Comparisons reference the field
> as of early 2026.

---

## 1. First, name the categories

"Performance framework" covers four different kinds of thing, and a
fair comparison must not mix them:

1. **Instrumentation libraries** -- in-process APIs an app calls:
   Micrometer (JVM), Prometheus client libraries, the OpenTelemetry
   SDKs, .NET `System.Diagnostics.Metrics`, Go `expvar`/`runtime
   metrics`, Node `prom-client`.
2. **Agents** -- attach from outside, instrument via bytecode/probe
   magic, ship to a vendor backend: Datadog, New Relic, Dynatrace,
   Elastic APM, AppDynamics.
3. **Runtime flight recorders / profilers** -- JVM Flight Recorder
   (JFR), Go pprof, async-profiler, Linux perf/eBPF tooling.
4. **Platforms that store, visualize, and act** -- Prometheus server +
   Alertmanager + Grafana, Jaeger/Tempo, Kubernetes HPA, the vendor
   SaaS backends.

The Softanza performance system is **category 1 with pieces of 3
(black box, senses) and a governed sliver of 4 (SLA judgment, the
scaling loop)** -- plus one thing none of the categories contain (the
governed act). It is explicitly NOT a storage/visualization platform:
it *exports* to those (Prometheus exposition, OTLP) rather than
competing with them.

## 2. Head-to-head: the instrumentation layer

| Dimension | Micrometer / Actuator | OpenTelemetry SDK | Prometheus client | **Softanza perf** |
|---|---|---|---|---|
| Metric kinds | counter, gauge, timer, distribution summary | counter, gauge, histogram (+ exemplars) | counter, gauge, histogram, summary | counter, gauge, timer (bucket + exact window percentiles) |
| Labels / dimensions | yes, first-class | yes (attributes) | yes, first-class | **yes (P8): families with engine-shared child registries, cardinality BOUNDED at birth with a visible overflow child** |
| Storage of samples | in-memory registry | in-memory + export pipeline | in-memory registry | **engine-side (Zig): O(1) rings + histograms, copy-proof handles** |
| Percentile honesty | client-side percentiles are documented-approximate | histogram buckets, exemplars | summary quantiles (streaming, approximate) | **both answers labeled: O(1) bucket bounds AND sort-exact window** |
| Process senses (RSS/CPU) | via binders (JVM-specific) | via runtime instrumentation packages | via collectors (process exporter) | **native engine syscalls (P1), no extra package** |
| Request timing | via framework integration (Spring, etc.) | via per-framework instrumentation libs | manual or via middlewares | **one verb: `oSrv.Observe(oMon)` -- the server is in the same library** |
| Exposition | `/actuator/prometheus` | OTLP push (+ Prom bridge) | `/metrics` | **`/metrics` (Prometheus text) + OTLP JSON, built in** |
| Self-cost stated | no | no | no | **`SelfCost()` -- ~0.03 ms per sampling pass, guarded** |
| Trace propagation | via Sleuth/OTel bridge | W3C traceparent, the reference impl | out of scope | **W3C traceparent at the server seam (join-as-child, echo)** |

The honest reading: on breadth (labels, framework integrations,
language coverage) the incumbents win decisively -- Micrometer alone
has dozens of binders, OTel has SDKs in every major language. On
*depth of honesty per feature* -- percentiles that say which kind they
are, a monitor that prices itself, engine-side storage that survives
value-semantics copying -- Softanza does things the incumbents do not
attempt, because their host languages do not force the discipline
(and JVM/Go references make handle-forking a non-problem; Ring's
copy-on-assign made Softanza solve it *structurally*, which then paid
off as cross-face sharing).

## 3. Head-to-head: the agents (Datadog, New Relic, Dynatrace...)

The agent model's pitch is "no code changes": attach, auto-instrument,
ship everything to our backend. The comparison is philosophical:

| Dimension | APM agents | Softanza perf |
|---|---|---|
| Integration | bytecode injection / probes, config outside the app | a library verb inside the app -- observation is something the app DOES |
| Data destination | vendor backend (SaaS), billed by volume/host | in-process engine stores; export is YOUR choice (Prometheus scrape, OTLP push) |
| Overhead | historically 1-10%+, opaque, occasionally pathological | measured and self-reported; O(1) hot paths; ~0.8 ms CPU per request round trip measured |
| Judgment (SLOs) | in the vendor UI, post-hoc | in the CODE, next to what it judges; CI-gateable through the same gate as security rules |
| Auto-remediation | vendor workflows / webhooks | a governed plan: closed catalog, actor lattice, audit -- the LLM proposes, an effectful actor commits |
| Unreproducible incidents | depends on retention you pay for | the black box: senses + metrics + trip trace-ids photographed AT breach, always on |
| Cost model | per-host / per-GB, recurring | none (it is the library) |

What the agents genuinely have that Softanza does not: fleet-wide
correlation across thousands of services, anomaly detection trained
on months of data, and a UI a whole organization shares. Those are
category-4 platform features -- Softanza's answer is to speak OTLP
and Prometheus *natively* so those platforms (or open-source
equivalents) sit downstream, without the agent or the per-host bill.

## 4. Head-to-head: the distinctive five

Five properties where the comparison inverts -- the field does not
have these, and each traces to a Softanza doctrine rather than a
feature race:

1. **The SLA is code, judged by the CI gate.** Micrometer has no SLA
   concept; Prometheus alerts live in Alertmanager YAML, evaluated by
   a server, far from the code; vendor SLOs live in a web console.
   Softanza's `stzSla` is declared next to the code in the
   operational vocabulary (`Expect(:ResponseTimeP95).Under(200)`),
   judged against measured actuals, and its breaches are findings in
   the SAME unified shape as security and governance rules --
   `stzRuleReport.Ingest()` fails the build on a p95 regression
   exactly as it fails on a capability escalation. Nothing in the
   field couples perf budgets to the codebase's own rule system.

2. **The governed act.** Kubernetes HPA scales on metrics with no
   notion of WHO may scale; vendor auto-remediation is a webhook.
   `stzPerfPlan` makes optimization a governed crossing: closed
   action catalog, `MayCommit()` preflight on the actor's capability
   lattice, full audit, and -- the consequence that matters in 2026 --
   **an inference-only LLM actor can watch, analyze, and PROPOSE with
   full fluency, and is structurally unable to commit**. Agentic
   performance tuning safe by construction is, to our knowledge,
   unique.

3. **Operational analysis as a first-class object.** The field gives
   dashboards; the methodology (USE method, queueing theory, the *Pro
   Java EE Performance Management* tradition this system's notebook
   pedigree cites) lives in books and consultants. `stzPerfProfile`
   computes U/R/X/D, service demand, the bottleneck split, and --
   uniquely -- **self-checks its own measurements** (Little's law N
   vs counted in-flight; anchor-computed U vs the sampled gauge; an
   identity is not a check). `Explain()` then narrates the analysis
   over the user's own numbers. No mainstream tool teaches while it
   measures.

4. **The engine substrate.** Micrometer is JVM-only; prom-client is
   Node-only. Softanza's measuring core (clocks, rings, histograms,
   trace ring, senses) is a flat-C-ABI Zig engine -- the Ring surface
   is ONE face; any language hosting the engine inherits the same
   instruments with the same semantics. That is closer to OTel's
   ambition (one standard, many SDKs) achieved by the opposite means
   (one implementation, many faces).

5. **Everything narrated, everything guarded.** 8 narrated guard
   suites / 283 assertions where every claimed behavior is asserted
   and every documentation output is real. The field's equivalents
   are reference docs and blog posts. This is the Softanza signature
   rather than a perf feature, but it is part of what "the system"
   is.

## 5. Head-to-head: the flight recorder

JFR is the closest prior art to the P6/P7 black box and deserves the
comparison:

| | JFR | Softanza black box |
|---|---|---|
| Granularity | JVM events (allocations, locks, GC, method samples), very deep | process senses + metric values + recent request traces |
| Trigger | continuous ring buffer, dump on demand/exit | photographed automatically AT each breach transition |
| Cost | ~1% target, sophisticated | negligible until a breach fires |
| Analysis | Mission Control UI | the record IS legible data (hashlists), plus trace-ids that open in Jaeger/Tempo |

JFR is far deeper (it sees inside the runtime); the Softanza box is
far more *pointed* (it fires exactly when a promise broke and names
the requests nearest the failure). The deferred counting-allocator
work is the path toward JFR-like depth, ruled a project of its own.

## 6. What the field has that Softanza lacks -- honestly

- ~~Labels/dimensions on metrics~~ **CLOSED by P8** (`stzMetricFamily`
  + `ObserveRoutes()`): per-route/per-anything percentiles, with two
  properties the field's label systems lack -- an engine-shared child
  registry (children created through any Ring face are visible to
  all) and cardinality bounded at birth with a counted, visible
  overflow child instead of the classic label explosion. Still
  downstream-only: PromQL-style aggregation ACROSS children (sum by
  route) -- by design, the scraper's job.
- **Storage, query, visualization.** No TSDB, no PromQL, no Grafana.
  By design: export instead. But teams without a Prometheus stack get
  Show()/Explain(), not dashboards.
- ~~Continuous profiling~~ **CLOSED (cooperatively) by P10**
  (`stzProfiler`): an engine-side call tree with honest self-time, a
  REAL sampler thread over the engine-held frame stack (constant
  cost, statistically validated live: a 40:10 workload sampled
  41:10), and folded-stacks export straight into flamegraph.pl /
  speedscope. The honest boundary vs pprof: frames are cooperative
  -- it profiles the code you bracket, because a native stack walker
  under an interpreter would only ever see the VM's C internals.
- **Distributed context beyond HTTP.** Traceparent propagates at the
  HTTP seam; there is no baggage, no async-context propagation
  through reactor jobs, no cross-process span reassembly inside
  Softanza itself (a collector does that downstream).
- **Sampling strategies.** OTel's head/tail sampling manages volume
  at scale; Softanza's answer today is bounded rings (drop-oldest),
  which is honest but cruder.
- ~~Log correlation~~ **CLOSED by P9** (the trace scope): the observed
  server opens an engine-global trace scope per request, every stzLog
  record inside it stamps the trace id, `OfTrace()` fetches a trip's
  log lines from the alert's own black box, and `stzLog.OtelJson()`
  ships OTLP logs with first-class traceId -- the OTel triad
  (spans/metrics/logs) exported natively.
- **Ecosystem breadth.** Decades of integrations, exporters,
  auto-instrumentation for every framework. Softanza instruments
  Softanza -- which is the point, but is also the boundary.

## 7. The one-table summary

| Question | The field's answer | Softanza's answer |
|---|---|---|
| How do I instrument? | add a library + framework glue, or attach an agent | `Observe(oMon)` -- the server and the instruments are one library |
| Where do numbers live? | client memory -> backend | engine handles (copy-proof, bounded, always-on) |
| Who judges them? | an external alert system, post-hoc | the SLA in the code, via the same CI gate as security |
| Who may act on them? | whoever holds the dashboard/kubectl | an EFFECTFUL actor through an audited plan; the LLM may only propose |
| What does it cost? | usually unstated (agents: per-host bills) | measured and self-reported (`SelfCost()`) |
| What happens at 3 a.m.? | hope retention covers it | the black box was written at breach time, trace-ids included |
| Who explains the numbers? | a consultant with a queueing book | `Explain()` -- the analysis narrated over your own numbers |
| Can others read the data? | vendor formats or OTel | Prometheus + OTLP + W3C natively, in and out |

## 8. Positioning, in one paragraph

The Softanza performance system does not compete with Grafana,
Datadog, or OTel's ecosystem breadth, and should not pretend to: it
exports to that world natively and lets it do what it is good at.
What it offers that the field does not is *integration of judgment
and action into the program itself*: budgets that fail the build,
optimization that passes governance, monitoring that prices itself,
a black box that writes itself, and an analysis layer that teaches
the operator the theory their own numbers are demonstrating. The
field treats performance as something done TO an application from
outside; Softanza treats it as something an application KNOWS about
itself -- which is the same doctrine the rest of the library applies
to security, governance, and delivery.

---

*Written at system completion (P0-P7, 2026-07-29), against the field
as of early 2026. When the field moves -- OTel adds a governed-action
story, or an APM vendor ships CI-gateable SLOs -- revisit section 4.*
