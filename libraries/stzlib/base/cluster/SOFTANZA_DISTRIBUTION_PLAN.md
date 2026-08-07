# The Softanza Distribution Plan

Status: plan, written 2026-08-07. Companion to
`engine/SOFTANZA_COMPUTE_MODEL.md` — that document describes three widths
of the same computation (SIMD lanes, threads, GPU kernels); this plan adds
the fourth: **machines**. Like the GPU plan, every phase below carries its
kill criteria in writing before its first number, and nothing is admitted
without a measurement.

## The vision in one paragraph

Any Softanza app — or a declared part of it — runs as a set of NODES that
may live on one machine or many, and the code does not change when they
move. Nodes are share-nothing OS processes that interact only by message;
sends are location-transparent (the same `Send` reaches a child process or
a machine across the wire); failure is handled by supervisors with declared
restart strategies, not by defensive code at every call site. The whole
thing is declarative in Ring, rides on dependency-free Zig binaries
(the engine + vendored libuv/mbedTLS/libcurl already in the tree), and is
admitted under the same dispatch discipline as lanes, threads, and the
GPU: the wire is a boundary, boundaries have a measured cost, and work
crosses only where the measurement says it pays.

This is the pragmatic 80% of Erlang/Elixir, on Softanza's own primitives,
without the BEAM and without the hard 20% (consensus, netsplit healing,
exactly-once) that serves almost no application.

## What already exists (build on it, do not rewrite it)

The distribution substrate is substantially built and guarded:

- **Reactor (Zig, libuv):** async TCP server (`StzEngineReactorListen` /
  `ServerPoll` / `ServerLastData` / `ServerWrite` / `ServerCloseConn`),
  TLS listen (`ListenTls`), async TCP client (`SubmitTcp` / `TcpAwait`),
  async subprocess with kill (`SubmitSpawn` / `SpawnAwait` / `SpawnKill`),
  async curl, 1 ms timer resolution (`timeBeginPeriod` at create).
- **HTTP plane:** `http.zig` + `http_framing.zig`, fuzzed and
  property-tested (`fuzz_http.zig`, `prop_http.zig`).
- **Cluster floor (Ring):** `stzWorkerPool` (admission + load isolation),
  `stzClusterSupervisor`, `stzComputeFederation` (multi-host facet
  discovery, governed calls, HMAC-signed, optional mTLS),
  `stzComputePipeline`, `stzFacetCatalog`, the appserver.
- **Security:** `stzRequestSigner` (HMAC), mbedTLS mTLS channel,
  `stzSystemActor`'s capability lattice, the delivery plane's keyed
  remote. Distribution REUSES these; it does not grow its own.
- **Calibration:** `engine/src/calib.zig`, OVERRIDE > FILE > DEFAULT.
  The `net.*` namespace is claimed by this plan (as `gpu.*` was reserved
  by the GPU plan).

What does NOT exist — the actual gap this plan closes — is the paradigm:
a mailbox, a location-transparent `Send`, supervision-with-restart
semantics, and a declarative surface that makes "this part runs
elsewhere" a deployment statement instead of a rewrite. Today's
`FederatedCall` is governed RPC; the target is message-passing nodes.

## The model

- **A node is an OS process** running a Ring script over the stz runtime.
  Ring is a single-threaded interpreter, so the process IS the natural
  unit of concurrency — share-nothing by construction, the property
  Erlang built a VM to obtain. In-process parallelism inside a node stays
  what it is today: the threads/SIMD/GPU tiers.
- **Messages are the only interaction.** A message is a Ring value
  (list/string/number, nestable), serialized once at the boundary. No
  shared state, no remote references, no distributed objects.
- **Sends are location-transparent.** A node address is a name
  (`"indexer"`) or `name@host`. `Send(addr, aMsg)` is fire-and-forget;
  `Ask(addr, aMsg, nTimeoutMs)` is request/reply with a mandatory
  timeout. Local child and remote machine take the same call.
- **Mailboxes are bounded.** Every node has one inbox with a declared
  capacity and a declared overflow policy (`:DropOldest`, `:DropNewest`,
  `:Refuse`). A bounded record counts what it drops (the incident-analysis
  law) — overflow is a counted, observable event, never silent.
- **Failure is supervised, not handled inline.** A supervisor owns child
  nodes, detects death (process exit or missed heartbeats), and restarts
  under a declared strategy: `:OneForOne`, `:AllForOne`, with a max-restart
  budget per time window. Beyond budget, the supervisor escalates (dies
  and reports), it does not loop.
- **A partitioned node is down.** From the other side's view, unreachable
  and dead are the same observable, handled the same way: timeout →
  monitor fires → supervisor policy. No split-brain arbitration.

## Taken from Erlang/Elixir — and refused, in writing

**Taken:** share-nothing processes · message-only interaction ·
location transparency · let-it-crash + supervision trees · monitors,
links, timeouts as the only failure detection · named registry.

**Refused (the kill list — any phase that starts needing one of these is
out of scope by definition):**
- **Exactly-once delivery.** The plane offers at-most-once by default;
  at-least-once is opt-in per send via an idempotency key the RECEIVER
  checks. Nothing stronger exists honestly.
- **Consensus, global state, netsplit healing.** No quorum, no leader
  election, no CRDTs. Softanza apps that need a consistent shared store
  use a database, which is good at it.
- **Hot code loading.** Redeployment belongs to the delivery plane,
  which exists.
- **A vendored broker** (ZeroMQ/NNG/RabbitMQ/etc.). A broker imports a
  second event loop and a second threading model to replace ~300 lines
  of framing over the reactor we already fuzz. The only vendoring
  question this plan leaves open is the serialization format, decided by
  measurement in D0.

## The wire (sketch, finalized in D0)

One frame format, `STZM`, over reactor TCP (or its TLS listener):

```
magic "STZM" | u8 version | u8 flags | u32 payload_len
| u64 correlation_id | 32B hmac (0 if unsigned) | payload
```

- Length-prefixed, so partial reads are trivially reassembled on the
  reactor's stream callbacks; the HTTP framing module is the house
  precedent for doing this correctly under fuzzing.
- Payload = one serialized Ring value. D0 measures an in-house
  binary encoding (type tag + length, recursive) against vendored
  msgpack on real message shapes; the loser is not built. The
  f64 boundary law from the perf grind applies: epoch nanos cross as
  ms-exact strings, never as raw f64.
- `flags` carries: signed, reply-expected, idempotency-key-present,
  compressed (reserved).
- Signing reuses `stzRequestSigner`'s HMAC discipline; encrypted
  transport reuses the mbedTLS channel. No new crypto.

## The declarative surface (target shape, built in D4)

```ring
oApp = new stzNodeApp("shop")

oApp.Node("indexer").On(:embed, func (aMsg) {
    return StzNeuralEmbeddingOf(aMsg[2])
})
oApp.Node("search").Requires([ :neural ])

oApp.Supervise([ "indexer", "search" ], :OneForOne)
oApp.InboxOf("indexer", 1000, :Refuse)

oApp.RunLocal()                       # every node = a child process, one machine
# oApp.Deploy("indexer", "10.0.0.7") # one line moves a node; no other change

? Ask("indexer", [ :embed, "how do I bake bread?" ], 2000)
Send("search", [ :warm ])             # fire-and-forget
```

`RunLocal()` IS the pseudo-distributed mode: the full topology on one
machine, à la Erlang's single-host clusters — same mailboxes, same
supervision, same wire format over loopback, so moving a node later
changes latency, not semantics. All of it programmable in plain Ring —
this surface is a first-class citizen of the library, not a
stzKernelMaker-style specialist tool.

## Phases

Each phase lands with a narrated guard; kill criteria are written here,
before any number.

**D0 — the message plane spike (the G0 of this plan).**
Framed STZM echo between two OS processes over reactor TCP on loopback:
measure round-trip latency, messages/sec sustained, and serialization
cost per KB for both encoding candidates on three real shapes (a small
command list, a 384-f64 embedding vector, a 100-row table slice).
Numbers seed `net.*` in the calibration store.
*Kill criteria:* loopback round-trip > 5 ms at the default timer
resolution (would drown every mailbox interaction — revisit the reactor
before building on it); serialization > 50% of end-to-end cost for the
embedding shape (fix the encoding before framing anything else).
Windows law to respect: sleeps quantize at ~15.6 ms outside a reactor
process — all waiting happens ON reactor polls, never sleep loops.

**D1 — node + mailbox, one machine.**
`stzNode`: spawn (reactor `SubmitSpawn`), bounded inbox with the three
overflow policies (counted drops), `On(:tag, f)` dispatch loop, clean
shutdown. Guard proves: delivery order per sender is FIFO; overflow
counts exactly; a node that raises inside a handler dies loudly (its
exit is observable) rather than wedging.
*Kill criteria:* if per-message dispatch overhead exceeds the D0
round-trip itself, the mailbox layer is too heavy — thin it before D2.

**D2 — registry + location-transparent Send/Ask.**
Name → transport resolution: same-app child (loopback TCP), or
`name@host` (remote TCP/TLS). One code path from the caller's side;
`Ask` timeout mandatory, no infinite waits anywhere. The guard runs the
SAME test body twice — once against a local child, once against a
second host process simulated on another port — and asserts identical
results and identical caller code.
*Kill criteria:* any API where the caller must know locality to write
correct code = the phase failed its one job.

**D3 — supervision.**
`stzNodeSupervisor` (grown from `stzClusterSupervisor`, not beside it):
`:OneForOne` / `:AllForOne`, max-restarts-per-window budget, escalation
beyond budget, monitors (death notification to a subscribing node),
heartbeat-based liveness with declared interval and tolerance. Guard
kills a child mid-conversation and asserts: restart within the declared
window, the in-flight `Ask` times out (at-most-once honored, no ghost
reply), the restart is COUNTED, and the budget escalates when exceeded.
*Kill criteria:* none — this phase is pure semantics; if it needs new
I/O primitives something upstream was wrong.

**D4 — the declarative surface + pseudo-distributed RunLocal.**
`stzNodeApp` as sketched above. `RunLocal()` runs the whole topology on
one machine; `Deploy(node, host)` moves one node with zero caller
changes. The topology declaration is data (inspectable, printable —
the W-string spirit), not only closures.
*Kill criteria:* a topology that cannot round-trip through its own
description (declare → describe → redeclare identically) is not
declarative yet.

**D5 — governance + security integration.**
Signed frames via `stzRequestSigner`, mTLS via the existing mbedTLS
channel, admission via the `stzSystemActor` capability lattice, and
`stzComputeFederation` re-expressed over the node plane (its facet
discovery and bonds become node-registry features; its HTTP transport
remains for heterogeneous peers). One security vocabulary — nothing
minted here.
*Kill criteria:* any new crypto primitive or a second signer = refused
by construction.

**D6 — doctrine.**
`SOFTANZA_COMPUTE_MODEL.md` gains its fourth width, written after the
fact like the rest of it, with the measured numbers. The boundary law
gets its third witness: PCIe ate one-shot GPU elementwise, the memory
wall ate streaming thread elementwise, and the wire eats chatty
fine-grained messaging — same verdict, third instance. Distribution
pays on coarse work units and resident remote state, never on streaming
cheap calls through the boundary.

## The dispatch discipline carries over

- **Gates from measurement:** D0's numbers seed `net.*` defaults; the
  calibrate tool learns to probe them; a future auto-`Distribute()` of
  library workloads is admitted per-site only where measured work beats
  marshal + wire (the same admission the GPU seam and thread gates use).
- **Two correctness classes, unchanged:** a distributed result is either
  bit-identical to the local computation (partitioned work merged
  deterministically — the M4 tie discipline extends to merge-from-nodes)
  or the site documents why not. Delivery semantics are part of class
  two: at-most-once is the honest default and says so.
- **Without ceremony:** no daemons to install, no config files required,
  no broker to run. A node binary is the same Ring + engine DLLs already
  shipped; `RunLocal()` needs nothing but the app itself. The only
  optional artifact remains the one calibration text file.

## Success, stated up front

The plan succeeds when the semantic-search demo from the neural module
runs as `stzNodeApp` with the indexer on a second machine — same guard
assertions, one changed line (`Deploy`) — and when killing the indexer
process mid-run produces a supervised restart and a clean timeout
instead of a hang. That end-to-end scene is the final guard.
