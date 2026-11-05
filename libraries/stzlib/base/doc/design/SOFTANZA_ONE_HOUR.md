# The One Hour
### What the language must make impossible, and what the tools must make fast -- a security design for Softanza, Ring++, Haro and Harobanda

**Status: DESIGNED, 2026-11-05, by stzlib-security -- for the author's rulings (section 7).**
Every claim is **[M] measured** (a number, a file, a date), **[R] recorded** (a ruling or
finding in the estate's record) or **[D] designed** (a proposal, reversible by name). A
number without a source is a defect in this document.

**The one sentence.** A model wrote a working root exploit for a 9.8 Linux bug in 48 minutes
[M, Anthropic's publication of 2026-10-27, read through the security press 2026-11-05]; the
time from an advisory to our machines being safe has never been measured; this document makes
the language close whole classes of the bug by construction, and makes the tools turn that
hour into a number the ledger reports.

---

## 0. What this stands on

- The reading of five autumn bugs against the estate, memo 2026-11-05 14:27 (`softanza/memos/
  2026-11-05.md`): the Linux IPv4 TCP use-after-free (CVE-2026-98432), Copy Fail
  (CVE-2026-31431), PHP2Shell (CVE-2026-109618/9, read 2026-10-22), Node-RED
  (CVE-2026-58115), and October's package-registry compromises.
- Two of them reached the estate directly, not by analogy [M]: Harobanda pins Linux 6.12.109,
  before the TCP fix (`harobanda/vendor/PIN.md`); and `stzPIAgent.Cycle` leaves `$cStzCaller`
  set when a skill raises, so later model calls are filed under that agent
  (`base/agentic/stzPIAgent.ring:200-237`, probed 2026-11-05).
- The threat model (`base/security/SOFTANZA_THREAT_MODEL.md`, G01-G47, R6-R18), the incident
  system (`SOFTANZA_INCIDENT_ANALYSIS.md`), the code rules (`base/meta/stzCodeRules.ring`, 37
  rules), the response plan (`base/security/stzResponsePlan.ring`), the drill
  (`stzSecurityDrill.ring`).
- Ring++'s checker discipline: *"Every rule traces to a measurement. No rule ships without a
  number behind it"* (`ringpp/src/check.zig:3`), and its absence-rule template of set-global
  gates (`ringpp/docs/CHECKER-FRONTIER.md`, R3 shipped 2026-08-28).
- Haro's charter v0.2 RATIFIED and its principles: *No silent global* (1), *Refuse, then
  explain* (4), *No effect without a door* (12), *The error, as a value* (`GRAMMAR-SKETCH.md`
  section 7: "No `cCatchError`; no process-wide last error").
- The author's charge of 2026-11-05: *"add 'finally' and any feature our new language needs to
  be among the best languages for agentic programming"*, and *"automated tools that help
  programmers identify such risks, and quickly patch them in the one-hour spot"*.

## 1. The two clocks

There are two clocks, and only one of them is ours.

**Time-to-exploit** is the attacker's, and it has collapsed. The TCP bug was fixed upstream in
late October; a model produced root on a lab server in 48 minutes plus five [M, as above];
public proof-of-concept code for PHP2Shell appeared within days of the advisory; Node-RED was
exploited against a canary one day after its CVE was assigned (2026-10-30) [M, VulnCheck]. The
number to plan for is **one hour from advisory to exploit**, and it is falling.

**Time-to-safe** is ours: from an advisory being published to every machine of ours that the
bug reaches being safe -- patched, or with the door shut while the patch is built. Today it is
**unmeasured** [M: no event kind in the ledger names an advisory, a pin, or a rebuild; the
kernel pin predates a fix by at least three weeks and nobody was watching]. A number that is
not measured cannot be a target.

Two consequences shape everything below:

1. **Whole classes must be closed by the language,** because a class closed by construction has
   a time-to-safe of zero for every future member. PHP2Shell's class (per-call state surviving
   a non-local exit) exists in stzlib today in a function nobody thought was related to PHP.
2. **For what the language cannot close, the hour is spent shutting the door, not patching.**
   A patch needs a build, a test and a deploy; a door needs one refusal. The tools must make
   the door the first move and the patch the second.

## 2. Where the autumn's bugs live in this stack

| the bug's shape | in Linux / PHP / Node-RED | in this estate today [M/R] | closed by |
|---|---|---|---|
| per-call state survives a non-local exit | PHP2Shell: `longjmp` skipped request cleanup; worker globals pointed into a freed heap | `stzPIAgent.Cycle` restores `$cStzCaller` only on the normal path; 8 save/restore sites in the library, 6 protected by hand-written try/restore/raise, 2 not [M 2026-11-05] | **A1, A2** (language) + **A5** rule |
| a pointer moved to a new owner, freed by the old one | CVE-2026-98432: `ireq_opt` moved into the child socket, `kfree` without an RCU grace period | the engine handle table had it (R16, closed with generations, 2026-10-22); cross-thread engine objects not yet swept | **A3** + **B3** Zig shape rule |
| a rarely used door built for everyone | Copy Fail: `algif_aead`, a 2017 zero-copy path through a crypto socket few use | Harobanda: OUT by construction (tinyconfig) [M `src/image.zig`]; stzlib: every program loads 87 engine domains and every function [M `base/common/stzRingLibs.ring`] | **A6** + **B1** |
| a code-running surface with no credential | Node-RED's HTTP interface | `stzAppServer` binds 127.0.0.1 by default [M `:95`]; other listeners unswept | **A5** rule + **B1** |
| code that runs at install or start, from a taken-over account | LiteLLM on PyPI; npm worms | models digest-gated (status -3 refuses) [M]; 21 vendored C libraries carry VERSION, no digest [M `engine/vendor/*/VERSION*`]; releases unsigned (R12) | **B1** + R12 |
| a pinned version nobody moved | every distribution still on an old kernel | Harobanda's pin, 6.12.109, with no written bump rule [M `vendor/PIN.md`] | **B6** |

## 3. Part A -- the language: what Ring++ ships now, what Haro inherits

Ring is retired (RING-RETIRED-01) and Haro runs on Ring++ in its own repository, so a language
feature has one place to land: Ring++'s compiler and the `rnx` VM. Haro's grammar then
inherits it with its own spelling. Each item names the class it closes and the number behind
it.

### A1. `finally` -- cleanup that runs on every exit [D]

```ring
try
    ...
catch e
    ...
finally
    ...          # runs after the body or the handler, on EVERY exit:
done             # normal, raise, return, exit, loop
```

Semantics, stated so a VM can be checked against them: the `finally` block runs exactly once
per entry of the `try`; a `return` or a raise inside the body or the handler is held, the
block runs, then the held exit resumes; a raise inside `finally` replaces a held one and the
replaced error is attached as its cause; `exit` and `loop` crossing a `try` run its `finally`
first. **The class closed:** PHP2Shell's. **The number:** 6 of 8 restore sites in stzlib are
hand-written `try / catch / restore / raise` [M] -- `finally` is that idiom with the compiler
holding the pen, and the 2 sites that forgot it are the measured cost of not having it.

### A2. `within` -- an ambient value with an end [D]

Haro's first principle is *no silent global*. An ambient value (who is acting, which workbench
is active, which ledger is current) is the one legitimate global: it must exist, and it must
end.

```ring
within $cStzCaller = "agent-x"
    ...          # the caller is "agent-x" here and in everything called from here
done             # restored on every exit, including a raise
```

It compiles to a save, the body, and a `finally` that restores. **The class closed:** the
ambient leak measured today (`$cStzCaller` left as `agent-x`, a later model call filed as
`agent:agent-x`). An `rnxc` rule (A5) then makes the old shape -- a bare `$x = ...` later
restored by hand -- a finding. In Haro the same construct is the natural home of *who speaks*:
an agent's turn is a `within` block, and its name cannot outlive its turn.

### A3. `using` -- a lifetime for what has no destructor [D]

Ring has no destructor; that is why KERN-07 needed an explicit `Release()` and why R16 was
possible at all (a copy of a destroyed object kept its handle). `using` gives a resource the
one thing a destructor gives: an end that cannot be forgotten.

```ring
using oKey = StzSecretQ("db").FromRandomHexQ(32)
    ...
done             # oKey.Release() -- or Destroy(), or Close() -- on every exit
```

The VM calls the first of `Release`, `Destroy`, `Close` the object answers to; a value with
none is a compile error, not a silent no-op. **The class closed:** a held secret or engine
object outliving its use (KERN-07's residue; R16's shape). Combined with the handle table's
generations, a copy that escapes the block is stale by construction.

### A4. Retire `cCatchError` -- the error is the handler's value [R, Haro; D, Ring++]

Ring's last error is a process-wide global: `cCatchError` is PHP's worker-global shape in one
name, readable by any code after any raise, and overwritten by the next. Haro already rules it
out (*"No `cCatchError`; no process-wide last error; `e` is the handler's own"*). Ring++
should ship `catch e` now, with `e.Message()`, `e.Code()`, `e.Span()` and `e.Cause()` (for
A1's replaced errors), and `rnxc check` should mark a read of `cCatchError` as a finding, so
stzlib migrates once rather than twice. **The number:** 14 references in Ring++'s own sources
[M `grep` 2026-11-05]; stzlib's count is the first task of the migration.

### A5. Five checker rules, each with its number [D]

`rnxc check` is the tool programmers already run; a security rule there costs nothing to
adopt. Each rule below respects the checker's own law (a measurement behind it; set-global
gates for any absence rule) and names its measured false-positive risk.

| rule | fires on | number today [M] | tier |
|---|---|---|---|
| `global-restored-by-hand` | a body that assigns a `$global` from a local and later assigns the local back, with no `finally` (or no `try`) on the path | 8 sites in stzlib, 2 unprotected | warn |
| `listener-binds-all` | a literal `0.0.0.0`, `::` or `""` as a bind address | 0 in stzlib library code; the sweep of every listener is B1's | warn |
| `text-run-as-code` | `eval(` / `call` on a value that is not a literal and did not pass `StzIsQueryCondition` | R17 closed 7 sites on 2026-10-22; the rule keeps them closed | err |
| `last-error-read` | a read of `cCatchError` | 14 in Ring++, stzlib uncounted | note until A4 ships, then err |
| `handle-held-across-raise` | an engine handle (a number from a `StzEngine*Create` / `Hold`) assigned in a body with no `using` and no `Release`/`Destroy` on every path | KERN-07's residue; count owed by the first sweep | warn |

### A6. Haro: the attack surface is declared, like the machine [D]

Harobanda's lesson from Copy Fail is the strongest in this document: the bug was out of every
Harobanda machine because nothing had declared it in. Haro should carry the same principle one
floor up. A declared language names what its worlds may reach, with the machine file's words:

```
LANGUAGE tontine NEEDS [filesystem, inference]
```

A world written in `tontine` cannot express a listener, a process spawn or a network call: the
grammar has no production for it, so the agent cannot be talked into one, and the checker has
nothing to find. This is COMPASS-KERN-02's filter (Harobanda's enforcement generated from the
machine file) applied to the language, and it is how *no effect without a door* becomes *no
door that was not declared*. The stzlib corollary is B1's: load an engine domain when a
declaration needs it, not all 87 at every start.

## 4. Part B -- the tools: the One-Hour Watch, in Softanza

Six pieces, each a class in `base/security/` with a guard, each reusing a house contract (the
ledger's event shape, `Name_()` + `Cycle()` for anything periodic, the response plan's
responders, the drill).

### B1. `stzExposure` -- what this process runs, as data [D]

An inventory the engine emits, not a document a person maintains: engine domains loaded (and
which were used), vendored libraries with name, version and **digest** (the 21 `VERSION` files
gain a `SHA256SUMS` beside them, like the models' -- the same gate, status -3 refuses a
mismatch), models with digests, listeners open with bind address and whether a credential
guards them, doors passed, and, under Harobanda, the kernel pin and built options. Exported as
CycloneDX JSON for anything outside, the way the ledger exports OCSF and OTel. **Why first:**
B2 cannot match an advisory to a thing we cannot name.

### B2. `stzAdvisoryFeed` -- the advisory meets the inventory [D]

Reads OSV (a free JSON query by package and version) and CISA's KEV list, matches them against
`stzExposure`, and writes one ledger event per match: kind `advisory.matched`, severity from
CVSS, `exploited` when the id is in KEV, subject the component, reason the advisory id. It is
periodic, so it is an agent (`Name_()` + `Cycle()`) hostable on any `stzAgentHost`, and it
reaches the network, so it is a **door**: declared, logged, refusable. Its guard runs on a
seeded fixture feed (a deterministic replay, the way `stzLlmSandbox` seeds answers), never on
the live internet. The honest limit: OSV covers packages and kernels it knows by name; our own
Zig is matched by B3, not here.

### B3. Shape rules -- the autumn's bugs as code rules [D]

The five shapes of section 2 become rules that run on the estate, not only on the bug that
taught them. In Ring, five rules join `stzCodeRules.ring` (the same five as A5, so `rnxc check`
and `StzCheckProject` agree). In Zig, where `rnxc` does not reach, a sweep in
`engine/tools/shape_sweep.py` finds the TCP bug's shape -- a pointer copied into a second owner
and the first owner's `free` or `destroy` on the same object without a generation, a copy, or a
grace -- and Copy Fail's -- a zero-copy path (`@ptrCast` of a read-only slice to a writable
one, `splice`-like reuse) with no comment naming the boundary and no guard that writes through
it. Both start with their number [M, first run], and a rule whose first run finds nothing is
still worth keeping only if its mechanism is explained; that is the checker's own standard.

### B4. The patch ledger -- time-to-safe becomes a number [D]

Five event kinds join the catalog: `advisory.matched` (B2), `exposure.closed` (B5 shut the
door), `pin.moved` (a digest changed in PIN.md or SHA256SUMS), `rebuilt` (the engine or the
image was built against the new pin), `guard.green` (the gate passed on it). They chain by the
advisory id in the trace field, and **time-to-safe = `exposure.closed` or `guard.green` minus
`advisory.matched`**, read from the ledger, never from a person's memory. The drill
(`stzSecurityDrill`) gains a scenario that pushes a seeded advisory through all five and
asserts the number against a budget. The budget is the author's to set; the proposal is
**one hour to `exposure.closed`, one day to `guard.green`**.

### B5. `stzExposureResponder` -- the hour is spent with the door shut [D]

A responder in the response plan whose action is never a patch: it refuses the listener,
unloads the engine domain, denies the socket family (under Harobanda, through the program
filter), or revokes the capability that reaches the exposed component -- and writes
`exposure.closed`. Patching is slower than refusing and must never be the first move. The
responder is governed like every effect: an actor, a door, a record.

### B6. Harobanda: `harb advisories`, and a rule for the pin [D]

Harobanda already has the hard part: the kernel fragment says exactly which subsystems a
machine built. `harb advisories <machine>` reads the fragment and the kernel advisories and
prints only the CVEs that reach **this** machine -- CVE-2026-98432 yes (CONFIG_INET),
Copy Fail no (no CRYPTO_USER_API) -- which is the noise reduction that makes an hour
possible. `PIN.md` gains a bump rule: who watches, how fast, and that a reference image is
rebuilt and its boot guarantees re-run on every bump. And what is excluded becomes a
guarantee a boot proves (HAROBANDA-ALGOUT-01): *out by construction* is only true until
someone edits a fragment.

### B7. The attacker's instrument, pointed at our own engine first [D]

The model that wrote the TCP exploit is the model to point at `engine/src/*.zig` and
`engine/vendor/*` before anyone else does. stzlib-intelligence's registry and court exist for
exactly this discipline: a model's finding is a **claim**, judged against a fixture (a known
bug re-found; a clean file left alone) before it is a finding. A periodic audit agent (B2's
shape) runs it over files changed since the last run, and files its claims as
`audit.claim` events with the court's verdict. The honest frame: this finds what a model can
find; it does not prove absence.

## 5. Sequence and owners

| rung | what | owner | days | gate |
|---|---|---|---|---|
| W0 | B1 `stzExposure` + digests for the 21 vendored libraries + the listener sweep | stzlib-security | 1 | `exposure_narrated`: the inventory names every domain, library and listener; a changed vendored file is refused |
| W1 | B2 feed on a fixture, B4 event kinds, the drill scenario | stzlib-security | 2 | `advisory_watch_narrated`: a seeded advisory reaches `exposure.closed` in the drill, number printed |
| W2a | B3 Ring rules in `stzCodeRules.ring`, Zig sweep in `engine/tools` | stzlib-security | 1 | both print their numbers on the tree; AMBIENT-01 is found by the rule |
| W2b | A5 the same five rules in `rnxc check` | ringpp | 2 | the rules fire on stzlib's measured sites and nowhere else |
| W3 | A1 `finally`, A2 `within`, A3 `using`, A4 `catch e` | ringpp | 5 | a VM guard per semantics line of A1; stzlib's 8 restore sites rewritten and the rule reads 0 |
| W4 | A6 `NEEDS` on a language declaration | haro-charter (design) then haro | charter 1, build after ZC4 | a world in a language without `network` cannot parse a listener |
| W5 | B6 `harb advisories`, the pin rule, ALGOUT-01, and the pin moved past the TCP fix | harobanda | 1 + the bump | the reference boot proves the fix and the exclusion |
| W6 | B5 responder; B7 audit agent under the court | stzlib-security + stzlib-intelligence | 2 | the drill shuts a door in under its budget; the audit re-finds a planted bug and leaves a clean file alone |

W0-W2a start now in this plane. W3 is the largest and the most valuable: every future member
of two bug classes costs zero after it.

## 6. What this does not do

- It does not make Zig memory-safe; A3 and B3 narrow the TCP bug's shape, they do not forbid
  it. The engine remains the place where a reviewer, and B7's model, must read.
- It does not patch anything by itself. B5 shuts doors; a person moves a pin, and B4 measures
  how long that took.
- It does not reach the live internet from a guard. Every feed guard runs on a fixture; the
  live feed is a door with a record.
- It does not claim the one-hour number until B4 has measured it on a real advisory. Until
  then the number is **unmeasured**, and this document says so.

## 7. The rulings owed by the author

1. **A1-A4 in Ring++, with these spellings** (`finally`, `within`, `using`, `catch e`), or
   with others -- the semantics are the ruling, the words are reversible.
2. **Retire `cCatchError`** once `catch e` ships: stzlib migrates once, by a sweep.
3. **Engine domains load on need, not all 87 at start** (A6's corollary): a behaviour change
   every program sees, so it is the author's, not this plane's.
4. **The feed is a door**: B2 may reach OSV and KEV from a program that declares it; the
   budget for time-to-safe (proposed one hour / one day).
5. **B7 runs**: a model reads our engine on a schedule, under the court.

Every other line is this plane's to build or another plane's to answer in its mailbox, and
each is named there with the measurement it must report.
