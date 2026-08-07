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

## The wire (finalized by D0's measurement)

One frame format, `STZM`, over reactor TCP (or its TLS listener):

```
magic "STZM" | u8 version | u8 flags | u32 payload_len
| u64 correlation_id | 32B hmac (0 if unsigned) | payload
```

- Length-prefixed, so partial reads are trivially reassembled on the
  reactor's stream callbacks; the HTTP framing module is the house
  precedent for doing this correctly under fuzzing.
- Payload = one serialized Ring value. **Decided by D0's measurement:
  the payload encoding is STZB, the in-house tag+length format**
  (see the D0 result below). The msgpack subset survives ONLY as the
  D0 guard's measurement instrument; D1+ speaks stzb exclusively, and
  the FLAG_MSGPACK bit stays reserved to that instrument. The
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

**D0 RESULT (2026-08-07, DONE).** Guard: `base/test/cluster/
d0_message_plane_narrated.ring` (27 assertions, two real OS processes,
echo peer `_d0_echo_server.ring`). Both kill criteria passed with wide
margin on the reference machine (loopback, release build):
- Round trip (small command frame): **1.98 ms median busy-poll, 2.01 ms
  median engine-await** (p95 4.0 ms) — kill line was 5 ms.
- Sustained throughput: **~13,000 msg/s** with 64 frames pipelined on
  one link.
- Serialization share of end-to-end on the 384-f64 embedding: **2%**
  for both candidates — kill line was 50%.
- **Encoding verdict: STZB wins** by the rule written before the
  numbers (codec cost primary, frame bytes tiebreaker): 125 us vs
  126-131 us total pack+unpack on the heavy shapes — a near-tie in
  cost — while msgpack packs ~40% smaller (4,932 B vs 7,958 B). On
  loopback, bytes are noise; unpack (rebuilding the Ring value)
  dominates codec cost for both, so the byte advantage buys nothing
  measurable. If a future REMOTE phase shows wire bytes dominating,
  this verdict names its own revisit condition; until then D1+ builds
  on stzb only.
- Seeds written as compiled defaults in `engine/src/stzm.zig`:
  `net.stzm.rtt_loopback_us = 2000`, `net.stzm.msgs_per_sec_loopback =
  12000`, `net.stzm.ser_ns_per_kb = 13000`.
- Substrate grown (not rewritten): `stzm.zig` — pure, fuzz-shaped
  frame + codec module in the http_framing mold (7 unit tests, hostile
  headers/payloads fail closed); a persistent CLIENT CHANNEL in the
  reactor (`reactor_connect` — a Server citizen with no listener: one
  outbound conn, the same events/write/framing paths as a listener, so
  `ServerPoll/Write/Stop` work identically on both ends of a link);
  STZM framing mode on the listener (mode 2); Ring-value pack/unpack
  bridges (`StzEngineStzmPack/Unpack`).
- Defect found by the spike and pinned in the guard: `stopServer` had a
  use-after-free — reaping a no-listener server frees it synchronously
  and the old code kept touching it; the redial storm panicked the loop
  thread. Fixed (conns close first, reap is the last touch), with a
  deterministic 15-cycle dead-port regression scenario.

**D1 — node + mailbox, one machine.**
`stzNode`: spawn (reactor `SubmitSpawn`), bounded inbox with the three
overflow policies (counted drops), `On(:tag, f)` dispatch loop, clean
shutdown. Guard proves: delivery order per sender is FIFO; overflow
counts exactly; a node that raises inside a handler dies loudly (its
exit is observable) rather than wedging.
*Kill criteria:* if per-message dispatch overhead exceeds the D0
round-trip itself, the mailbox layer is too heavy — thin it before D2.

**D1 RESULT (2026-08-07, DONE).** Guard: `base/test/cluster/
d1_node_mailbox_narrated.ring` (23 assertions, SIX real child
processes). Kill criterion passed wide: node-echo round trip 1.06 ms
median vs 0.97 ms raw echo measured side by side in the same run —
**dispatch overhead 0.09 ms**, an order of magnitude under one D0
round-trip. FIFO proven by CONTENT (1..50 drained in exact order, deep
equality through the encoder). Overflow counted EXACTLY — 20/20/1
across the three policies — and each policy keeps the messages it
promises: :DropNewest the FIRST cap (survivors 1..10), :DropOldest the
LAST cap (survivors 21..30), :Refuse hangs up so the SENDER observes
the refusal (:closed), and a fresh link finds the node alive with
survivors 1..5 and exactly one counted refusal. A raising handler dies
LOUDLY: link closed + OS process exit observed, no wedge. `stz.stop`
is the built-in clean shutdown, asserted via the exit marker.
Placement note: the bounded inbox lives in the ENGINE (a cap on queued
data events at the framing point, shared by raw/http/stzm modes) —
bounding in Ring would have left the engine queue unbounded, a bound
that lies. `stzNode` (base/cluster/stzNode.ring) carries On/Run
dispatch, replies only when FLAG_REPLY_EXPECTED is set (the D2 Ask
contract, honored early), counts unhandled tags, and does NOT catch
handler errors, by design.

**D2 — registry + location-transparent Send/Ask.**
Name → transport resolution: same-app child (loopback TCP), or
`name@host` (remote TCP/TLS). One code path from the caller's side;
`Ask` timeout mandatory, no infinite waits anywhere. The guard runs the
SAME test body twice — once against a local child, once against a
second host process simulated on another port — and asserts identical
results and identical caller code.
*Kill criteria:* any API where the caller must know locality to write
correct code = the phase failed its one job.

**D2 RESULT (2026-08-07, DONE).** Guard: `base/test/cluster/
d2_location_transparency_narrated.ring` (16 assertions). The kill
criterion is proven BY CONSTRUCTION: one test body `D2Body(cAddr)` --
ping/reply, 10 sends + FIFO drain, nested echo -- runs against a local
child ("worker") and a remote-simulated child ("far@127.0.0.1"), and
the two result sets are byte-identical through the encoder. The
surface: `stzNodeRegistry` (base/cluster/stzNodePlane.ring) with bare
`NodeRegister` / `Send` / `Ask` globals over one default plane.
Honesty proven alongside: Ask refuses a non-positive timeout
(:BadTimeout -- infinite waits do not exist); a timed-out Ask's LATE
reply is discarded by correlation id, never mis-delivered (at-most-once
residue); :Down (registered, unreachable OR died mid-conversation --
same observable, including after re-dial to a dead port) is distinct
from :Unknown (never registered); Send reports failure, not silence.
Links are cached per name and re-dialed transparently after :closed;
re-registering a name MOVES it (the cached link drops) -- the mechanism
`Deploy()` will ride in D4.

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

**D3 RESULT (2026-08-07, DONE).** Guard: `base/test/cluster/
d3_supervision_narrated.ring` (25 assertions, real kills of real
processes). As predicted, ZERO new I/O primitives were needed --
`stzNodeSupervisor` (base/cluster/stzNodeSupervisor.ring) is pure
policy over the existing observations (spawn JobState for exits, plane
Asks for heartbeats), keeping the house contracts: Name_() + Cycle(),
hostable on any stzAgentHost. Proven, by STATE rather than counters
alone: the mid-conversation kill fails the in-flight Ask plainly (no
ghost reply) and the child answers again ~3.0 s after death, restart
counted exactly once; :OneForOne leaves the sibling's accumulated
state INTACT while :AllForOne wipes it (a fresh process has no
memory -- the strongest possible restart witness); the budget (2 per
window) escalates on the third kill with the child named in the
reason, exactly 2 restarts ever counted, post-escalation cycles
restart NOTHING and the child stays observably down; heartbeats (300
ms interval, tolerance 2) catch the WEDGED node -- alive, dispatch
loop spinning forever, invisible to process-exit detection -- kill it,
and have it answering again ~3.1 s after the wedge; monitors receive
[ node.down, child, restarts ] through the plane itself (asserted by
content on a subscribing watcher node).

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
