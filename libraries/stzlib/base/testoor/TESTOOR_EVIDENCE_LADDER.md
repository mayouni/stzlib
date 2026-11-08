# Testoor and proof -- the evidence ladder

*Design note d1, 2026-11-08, desk stzlib-testoor. A direction for protocol 3. It proposes and rules nothing:
section 11 lists the decisions the author owes. It changes nothing in protocol 1.1 or protocol 2.*

*Why it exists. The author wrote, on 2026-11-08, before the next Testoor step: "Testing can only show the
presence of bugs but not their complet absence ... what about formal verification of the correctness of all
the paths in a computer program written in Haro ... And how graph-orientation in Softanza code and Testoor
could make an enabler for it?" After the answer, the author wrote: "So nice! I'm very enthusiastic about this move we will add
to Testoor, Haro and the Softanza world! Yes write the design document and rout your question to Haro". The
sentence the author quoted is Edsger Dijkstra's (1970): "Program testing can be used to show the presence of
bugs, but never to show their absence." Xavier Leroy, OCaml's lead developer, quotes it often, and his
CompCert compiler, which is proved correct by machine, is one answer to it.*

*What was read: stzlib `main` at 4fdffce2c; Haro `origin/main` at c069257 (CHARTER.md, PRINCIPLES.md,
TYPES.md, SG1.md, CODEGRAPH.md). Claims about Haro below cite those files; nothing was run on haro.exe.*

---

## 0. The answer in five sentences

1. Proving that **every** path of **any** program is correct is impossible in general. That is a theorem, and
   no tool escapes it.
2. Proving a **stated property** on every path of a **program written to be provable** is routine engineering.
   It is done every day for types, and for whole programs where failure is very costly: flight control,
   operating-system kernels, compilers, cryptography and cloud storage.
3. What makes a program provable is a **closed world**: every edge known, every effect declared, and every loop
   with a known bound or a stated invariant. A graph is the place where a program says whether its world is
   closed.
4. Testoor already records three grades of evidence per graph node (named, observed, kept). This note proposes
   three more (generalised, exhausted, proved) and lets the evidence floor ask for a grade.
5. Haro already proves some things on every path: it refuses `eval` in its system profile, checks that a
   function with no `uses` reaches no door, follows `unjudged` text, and bounds a `total` function. What
   Testoor needs from Haro is those facts per node, and later a contract form. That is the question routed to
   the Haro desk (section 8).

---

## 1. What "correct on every path" can mean

Formal verification needs three things, and needs all three.

| part | what it is | who writes it |
|---|---|---|
| **a meaning of the language** | a precise statement of what each construct does (its semantics) | the language's designers, once |
| **a specification** | what the program must do, written apart from the code | a person, or an agent whose text a person reads |
| **a proof** | an argument, checked by a machine, that the code under that meaning meets the specification | a person, a solver, or an agent; **checked** by a small trusted program |

So "correct" always means **correct with respect to a specification**. A proof of the wrong specification
proves the wrong thing, perfectly. This is the same law as Testoor's perception gate: a comparison proves
sameness, never rightness (`CENTRAL-PERCEPTGATE-01`). Proof moves the human judgement from *"is every path
right?"*, which no one can check by reading, to *"is this specification what we meant?"*, which is short
enough to read.

**"All paths" is not an enumeration.** A program with one loop that runs up to n times has more paths than
anyone can list. A proof does not walk them. It argues by **induction**: it states an **invariant** that holds
before the loop and is kept by one turn of it, and so holds after any number of turns. It also states a
**measure** that decreases on every turn, which proves the loop ends. Testing samples paths; proof covers them
with one argument.

## 2. What the discipline and practice say about feasibility

**The limit.** Rice's theorem (1953): for any language as powerful as a general computer, no program can decide
every non-trivial property of what other programs do. Every working tool therefore gives up one of three
things.

| what the tool gives up | the family | examples that work in production |
|---|---|---|
| **generality of the property**: one class of facts, on all paths, with no help | type systems, abstract interpretation | OCaml's and Rust's types make whole classes of error impossible; Astree proved the absence of run-time errors in the Airbus A340 and A380 flight-control code |
| **unboundedness**: every state, up to a size | model checking, bounded model checking | hardware floating-point units after Intel's FDIV defect (1994); TLA+ models of DynamoDB and S3 at Amazon found design defects testing had missed (Newcombe et al., CACM 2015); CBMC on C |
| **automation**: a person (now also an agent) writes the proof, a machine checks it | deductive verification, proof assistants | SPARK (Ada) in rail and avionics; Dafny, Why3, Frama-C, F*, Verus; CompCert in Coq (the Csmith study of 2011 found wrong-code defects in every compiler it tried, and none in CompCert's proved part, only in its unproved front end); seL4 in Isabelle, about 8,700 lines of C against about 200,000 lines of proof, about 20 person-years by its authors' count (Klein et al., 2009) |

**What has changed recently is the cost.** A proof is hard to find and cheap to check. Since about 2024,
language models have written loop invariants and proof steps in Lean, Dafny and Verus that a small checker then
accepts or refuses. The checker does not trust the model. The model is a search engine for proofs, and the
checker is the judge. This is the shape the estate already follows in its doctrine: "a model proposes and never
commits" (Haro CHARTER, the Aicha row), and Testoor's ruling 17, "intelligence proposes and a run decides".

**The conditions a language must meet.** A language admits proof to the degree that its meaning is small and
its world is closed. Four features of Ring work against proof:

- a name built at run time (`eval`, `call "name"()`, `addmethod`) is an edge nobody can see before the run;
- a constant that can be reassigned (`TRUE`, `NL`) makes a proof about code that reads it void (this
  repository's CLAUDE.md: "the logic runs backwards and nothing errors");
- names compared without case, and values converted between types without being asked, both have to enter the
  semantics;
- copying a list on assignment makes aliasing part of the meaning.

Haro has already removed or fenced most of these, for reasons other than proof (next section).

## 3. What Softanza and Haro already have that proof needs

Read the left column as "exists today", with its source, and the right column as "what it becomes on the way to
proof".

| exists today | where | what it becomes |
|---|---|---|
| the graph record's `open` flag and `complete` field | TESTOOR_PROTOCOL_2.md section 2 | **the line where proof stops.** An `open` node dispatches by a name built at run time; nothing can be proved through it. A complete graph is the closed world a prover needs |
| Haro's `dynamic` mark on a node whose behaviour is set by a string | Haro CODEGRAPH.md 3.5 | the same line, drawn by the language itself |
| Haro's resolved graph (L2): calls, references, inherits; "over-approximation, extra named" where a call cannot be resolved | Haro CODEGRAPH.md 3.1 | the dependency structure of a **modular proof**: prove each node against its contract, assuming its callees meet theirs |
| `PROFILE system`: refuses `eval`, a run-time `load`, a call through a name the compiler cannot resolve, an undeclared door, a managed allocation outside a region | Haro SG1.md section 3, ruled D56 | **a verifiable subset already exists in spirit.** It refuses what C cannot hold without a runtime; most of the same things defeat a prover |
| `uses [door]` on a function; no `uses` means pure, and the compiler checks the closure of its calls | SG1.md section 7, D56 (f) | **a property proved on every path**, by the checker, today: this function and everything it calls reach no door |
| `total` on a function: no `while`, `for` only over a collection or a range known before the loop, no recursion, calls only to total functions | SG1.md section 7, D56 (h); PRINCIPLES.md section 11 | **termination proved by construction**, the cheapest proof there is. Its loops are bounded, so "exhaust it" and "prove it" become possible |
| `unjudged` (text that came through a door may not run, become a sentence, or direct a door) and its dual `personal` | TYPES.md T7; SG1.md section 7 | **information-flow properties on every path**: integrity and confidentiality, checked by the type system |
| the declared altitude's `CONSTRAINT`, a "closed, total condition language", and `REFINE` with `POINTS` and `FLOOR` | Haro CHARTER, v0.2 to v0.4 | a **specification language that is already total**. It is the natural candidate for contracts (question (b) of section 8) |
| the intent clause, `def Total(...) -> decimal is "the sum of the amounts"` | TYPES.md T2 | a specification in words: the human's half of a contract |
| refinement points with declared bounds, `<R:PARAM ... min="0" max="0.25">`, and a five-stage gate | base/refine/stzRefinableCode.ring | **a declared domain.** "For every value in 0..0.25" can be sampled, enumerated, or proved |
| the seed, the stepped clock and the declared weather (kill, pick, skew) | testoor_clock.zig, P3.2 | **a closed, finite world** of schedules: what a model checker enumerates |
| promises (`#-->`) and claims (`Then`) | TESTOOR_PROTOCOL.md | specifications by example, written apart from the code |
| the impact record: the callers' closure of a changed node | testoor_graph.zig, P3.3 | **what must be proved again** after a change, the same set that selects which tours to walk |
| the evidence floor (posture, tier, floor; exit 1 when not met) | testoor_evidence.zig, protocol 2 section 6 | **the policy hook**: the place where "this change needs a proof" can be said |
| a small judge in Zig, held byte for byte to hand-written goldens | testoor_*.zig, golden/ | **a small trusted checker**, which is what makes a proof system believable (de Bruijn's criterion) |

**Two facts stand out.** First, Haro proves things on every path **today**: purity, totality by construction,
and information flow. Most people do not call this formal verification because it arrives as a type error.
Second, Testoor already knows posture and tier, so the question "who proposed this change and how much
evidence does it need" has a home. What is missing is the higher grades of evidence and a way to record them.

## 4. The ladder

Evidence is recorded **per node of the graph and per property**, never per file, and never as a percentage.

| grade | what it means | who produces it | cost | what it proves | built? |
|---|---|---|---|---|---|
| **0 named** | the node is in the graph | the program's graph reader | free | that the node exists and is owned | yes, P3.3 |
| **1 observed** | a tour reached the node (`[testoor node ID]`) | a tour, or a trace hook | one walk | the node runs without crashing on one input | yes, P3.3 and P3.4 |
| **2 exemplified** | a claim was KEPT on a tour that reached the node | a tour | one walk | the node did the right thing on one input the author chose | yes, through claims and node lines; the per-node join is not yet reported |
| **3 generalised** | a property held over N generated inputs drawn from a declared domain, with a seed; a failure is shrunk to its smallest case and kept as a new tour | a property tour | N walks, or one walk that loops | the property is likely: no counterexample in N tries | no |
| **4 exhausted** | a property held for **every** input of a finite declared domain, or every schedule of the declared weather up to depth k | an enumerating tour, or a bounded model checker | the domain's size | the property holds, **inside the bound** | no |
| **5 proved** | a checker issued a certificate for the property against a specification, under a stated profile, for these exact source bytes | a type checker, a solver, or a proof assistant; Testoor only records it | from free (a checker's fact) to very high (a hand proof) | the property holds on every path, if the specification and the trusted base are right | no |

**The ladder is per property, so it is not one order of strength.** A proof against a specification nobody
read is weaker than a kept claim that a person wrote from the real intent. A floor that asks for grade 5 must
therefore also ask that the specification was read (section 6, `spec_read_by`).

**The first proofs are free.** Grade 5 does not start with a theorem prover. It starts with the facts Haro's
checker already establishes: a function the checker accepted as `total` is proved to terminate; one accepted
with no `uses` is proved pure. Recording those per node costs Testoor one field in the graph record. That is
question (a) to Haro.

**Grades 3 and 4 need nothing from Haro.** The bounds of refinement points, the declared weather and the seed
are enough to generate and to enumerate. They can be built in Ring and Zig today and tried on stzlib.

## 5. How the graph makes this cheap enough to do

- **It says where to stop.** Proof and exhaustion are claimed only for nodes whose closure in the graph contains
  no `open` node. A node that reaches an `open` node can be exemplified, never proved; the report says which
  `open` node blocked it, as `complete`/`why` already do for selection.
- **It makes proof modular.** A node's contract is proved assuming its callees' contracts. When a callee
  changes, only its callers' proofs are reopened, and those are exactly the **impact record** Testoor already
  computes.
- **It keeps the effort small.** The evidence floor asks for a grade over the **impact set of a change**, not
  over the whole program. A one-line change to a critical point asks for grade 4 on perhaps a dozen nodes, not
  on 531,000 lines.
- **It joins intent to code.** A route (a plan item) is joined to the nodes that implement it (`implements`).
  A property is attached to a route, so "TAX-01 is proved" means "every node implementing TAX-01 carries a
  grade-5 certificate for TAX-01's property".

## 6. A sketch of protocol 3

Protocol 2's rule 0 holds: **a key appears only when it has something to say**, so a run with none of the
additions below writes protocol 2's bytes, and the goldens stay the acceptance test.

**(a) Facts on a graph node** (from the language's checker; never computed by Testoor):

```json
{"id":"stzTax.Total","kind":"method","open":false,
 "facts":{"total":true,"uses":[],"profile":"system","checked_by":"haro check 0.46","source_sha":"9c1e..."}}
```

**(b) A property record**, in the run, one per property walked:

```json
{"property":"TAX-RATE-01","route":"TAX-01","nodes":["stzTax.Total"],
 "domain":"rate in 0..0.25 step 0.01","grade":"exhausted","tried":26,"of":26,
 "held":true,"seed":42,"counterexample":null}
```

A property that fails gives `held:false` and its **shrunk counterexample**, which becomes a new tour (a
regression test the run wrote for you).

**(c) A certificate record.** Testoor never checks a proof. It records who checked it and against what, and
refuses a certificate whose `source_sha` is not the subject walked (a stale proof counts as nothing):

```json
{"property":"TAX-RATE-01","node":"stzTax.Total","grade":"proved",
 "checker":"<name>","checker_version":"<v>","spec_sha":"...","source_sha":"...",
 "spec_read_by":"<a person's name>","verdict":"proved"}
```

The list of checkers a library trusts is library data, like the floor policy. It is not the core's.

**(d) A floor that asks for a grade**, in the evidence record:

```json
"floor":{"min_kept":3,"allow_unjudged":false,"min_grade":"exhausted","over":"impact"}
```

`over:"impact"` means every node in the impact set of the change must reach the grade on at least one of its
properties. A node the graph cannot close (`open` in its reach) can never meet a floor above grade 2, and the
reason names that node.

## 7. Why this becomes a requirement in the agentic age

1. **The human proof step disappears.** Code review was the place where a person tried to reason about every
   path. Agents write code faster than anyone can review it. The reasoning moves to a machine or stops.
2. **Tests become targets.** An agent that sees the tests can make them pass without being right (Goodhart's
   law). A specification that a person reads, checked by a checker the agent cannot change, cannot be satisfied
   that way. The agent can still prove the wrong theorem, which is why `spec_read_by` is a field.
3. **The asymmetry fits.** Finding a proof is search, which agents are good at. Checking a proof is mechanical
   and cheap. Trust the small checker, never the agent: proof-carrying code (Necula and Lee, 1996), with the
   agent as the untrusted producer.
4. **The cost flips.** Proof was rare because writing it cost many times the code. If agents write the proofs,
   what remains for people is the specification, which is short, and its reading.
5. **The floor already encodes it.** `posture:"llm"` with `tier:"critical"` is the case where a proof should be
   asked for. Today the floor can only ask for kept claims.

## 8. What Testoor asks of Haro (routed as HARO-PROOF-01)

One row, five parts. Routed to the Haro desk through its mailbox the day this note was written.

- **(a) Checker facts per node.** Can Haro's graph (or `haro check`) export, per function, the facts its checker
  already establishes (`total`, the `uses` set (empty means pure), the profile, `dynamic`, and whether `unjudged`
  or `personal` values reach it), with the checker's version and the source hash? This is the cheapest grade 5
  in existence, and Testoor needs nothing else to start recording it.
- **(b) A contract form.** Does Haro intend preconditions, postconditions and loop invariants on a function? If
  so, could the declared altitude's closed, total condition language (`CONSTRAINT`) be the language contracts
  are written in, beside the intent clause `is "..."`, so that the specification language is itself total?
- **(c) A profile for proof.** `PROFILE system` refuses most of what defeats a prover. Is the system profile, with
  `total` and `uses`, meant to be the provable subset, or would proof need a profile of its own, for example
  one that refuses a function that is neither `total` nor carries a decreasing measure? If it needs its own
  profile, the profile's name is the author's.
- **(d) The discharge path.** Which way would Haro send its proof obligations: to a solver directly (Z3 or cvc5),
  through an existing verifier (Why3, Dafny, Lean), or through SG2's C target to C verifiers (Frama-C, CBMC)?
  Testoor does not need the answer to build grades 3 and 4; it needs it only to know what a certificate from
  Haro will look like.
- **(e) The Ring surface.** Confirm that a `.ring` file run on haro.exe stays outside any proof claim, because of
  case-insensitive names, coercion and `eval`, so that Testoor caps it at grade 4 and says why.

## 9. What Testoor builds, and in what order

Proposed as a phase of its own, after P4 has measured the graph on the real library. Each step starts with a
measurement and with hand-written goldens, as P3 did.

| step | what | needs Haro? |
|---|---|---|
| **V1** | report grade 2 per node: the join of kept claims and node lines, already in the logbook's data | no |
| **V2** | grade 3: property tours over declared domains (refinement bounds first), seeded, with shrinking; TR5's metamorphic relations (`Verb`/`Verbed`/`VerbQ`) are its first properties | no |
| **V3** | grade 4: enumerate finite domains and the schedules of the declared weather up to depth k; report `tried` and `of` | no |
| **V4** | `min_grade` and `over:"impact"` in the floor; goldens first | no |
| **V5** | the certificate record; the first producer is Haro's checker facts (question (a)) | yes, (a) |
| **V6** | contracts and a discharge path, when Haro has them | yes, (b) to (d) |

V1 to V4 can be built in Zig and Ring now. V5 and V6 wait on the Haro desk's answer.

## 10. Limits, said plainly

- **A proof is as good as its specification.** Hence `spec_read_by`, and the perception law: where a person is
  the last consumer of an output (a sound, a picture, a sentence), proof of the code never replaces a person's
  verdict on the output.
- **The trusted base remains**: the checker, the compiler, the VM, the engine, the operating system. A proof
  moves trust; it does not create it. Keeping each of those small is the defence.
- **Proofs go stale.** A certificate is valid only for the source bytes it names; Testoor refuses one whose hash
  does not match the walked subject.
- **Floats, concurrency and the outside world are hard.** Floats need their own rules. Concurrency is what the
  stepped clock and weather approximate, and only up to a bound. What happens after a door opens (a socket, a
  process) is outside any proof of the program, as SG1.md section 7 says of `process`.
- **Most of stzlib is Ring with `eval`.** Grade 5 will cover a small core first: engine-facing functions, the
  judge itself, and `.haro` code under a profile. That is how every verified system started.

## 11. Decisions

| row | question | state |
|---|---|---|
| TESTOOR-LADDER-01 | (a) adopt the ladder as the direction of protocol 3; (b) the six grade names (named, observed, exemplified, generalised, exhausted, proved); (c) the phase V1 to V6 after P4, with V1 to V3 allowed to start before P4 ends; (d) Testoor records certificates and never checks proofs itself | **DECIDED 2026-11-08 by the author, all four as written**: "yes to all four, make a visual diagram of the ladder, display it, and only after that we can go with V1" |

The diagram the author asked for is `TESTOOR_EVIDENCE_LADDER.html` beside this note: the six grades in three groups, and
one worked change whose floor is refused (an illustration with invented names, not a measurement).
