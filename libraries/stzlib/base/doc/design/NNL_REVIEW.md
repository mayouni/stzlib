# NNL Reviewed: Near-Natural Language as Softanza's First Paradigm
## The thesis, the devices, the decay, and the rebuild plan

*Written 2026-07-10 after re-reading stz-near-natural-language-programming.md
and stz-near-natural-language-tutorial.md, RUNNING their examples against the
current library, and reading the implementations (stzObject descriptor
machinery, stzTrueObject/stzFalseObject, the QM family, stzChainOfTruth,
stzChainOfValue, stzNaturalCode). This corrects NATURAL_VISION.md's Era-1
framing, which treated NNL as residue to absorb. It is not residue. It is a
paradigm with its own thesis, and it deserves its own floor.*

---

## 1. The Thesis, Stated Properly

NNL's claim is NOT "make APIs read nicely" (fluent interfaces do that) and
NOT "make the machine understand text" (that is Naturally's direction). The
claim is:

> **Any natural-language expression, however complex, can be modeled as
> computational code -- by forcing the CODE to adhere to human language
> dynamics rather than the inverse -- with zero NLP, zero ML, native speed,
> full determinism, and the programmer in control.**

The consequence that matters: in NNL, **the human is the parser**. The
programmer reads the natural sentence, disambiguates it in their head, and
writes its meaning down as a chain whose every link is a real method call.
The machine never guesses because there is nothing left to guess -- the
sentence arrives already compiled. This is the exact mirror image of
Naturally(), where the MACHINE parses and must refuse what it cannot prove.

Two directions, one gap:

| | Naturally() (Era 2/3) | NNL chains (Era 1) |
|---|---|---|
| Who parses | the machine (lexicon) | the human (programmer) |
| Ambiguity | refused, loudly | impossible by construction |
| Vocabulary | bounded by packs | unbounded (any method) |
| Understanding | machine-verified (Understood) | human-verified (reading) |
| Audience | domain experts, agents | programmers |

Both end at the same place: a deterministic sequence of semantic operations.
That shared destination is the convergence point (section 6).

## 2. The Device Catalog -- Grammar as API

The deep contribution of the two documents is a catalog of LINGUISTIC
PHENOMENA each realized as a small computational device. This is what makes
NNL a paradigm and not a style. Reconstructed from the docs and the code:

| Linguistic phenomenon | NNL device | Example |
|---|---|---|
| Reference (pronoun "it") | `Q(v)` wraps the referent; the chain IS the pronoun | `Q("ring").` |
| **Definite reference** ("THE word... that word") | `QM()` memorizes the MAIN object; `...QMM()` / `OnlyQM()` recall it mid-chain | `TheWordQM("ring")...OnlyQM(1).VowelNB()` |
| Articles (a / an / the) | `IsAQ / IsAnQ / IsTheQ / HasAQ / ALengthQ` | `HasAQ().LengthQ()` |
| Prepositions (of / with / in) | `OfQ() / WithQ() / InQ()` particles | `ALengthQ().OfQ(4)` |
| Relative clauses (which / that / having) | `WhichQ() / ThatQ() / HavingQ()` -- pass-through particles that keep the narrative going | `.WhichQ().HasAQ()` |
| Conjunction (and) | `AndQ()` | `.AndQ().DividableBy(10)` |
| Possessive plural anaphora ("their") | `TheirQ()` | `AreBothQ(:strings).HavingQ().TheirQ().FirstCharQ()` |
| **Number agreement** (is/are) | `IsAQ` vs `AreQ / AreBothQ` -- subject-verb agreement as API | `Q([...]).AreQ(:numbers)` |
| **Anaphoric ellipsis** ("...and only ONE vowel") | `_LastValue` context + `B/NB` suffixes: a determiner stores the expected count, the noun checks agreement | `OnlyQM(1).VowelNB()` -> counts vowels, compares to the remembered 1 |
| Quantifiers / determiners (only, both, all) | `Only(n)`, `AreBoth`, `All...` | `OnlyQM(1)` |
| **Tense & aspect** (before / after / then / future) | the `_aFuture` queue: `FQ` marks deferred, `FFQ` triggers, `BeforeQ/AfterQ` set order | `BeforeQ("ringo").IsUppercasedFQ().RemoveFFQ("o")` |
| **Temporal & modal subordination** (until / since / whenever / sometimes) | stzChainOfValue: `Until(v).Becomes(x).DoThis(...)`, `Since()`, `Whatever()`, `SometimesWhen()` (probabilistic modality!) | reactive clauses as code |
| Predication & truth (is / is not / neither...nor) | stzChainOfTruth: `Is/IsA/IsNot/IsNeighther/Nor`, closed by the `._` magic attribute | `_("G").IsA('LetterOf("HUSSEIN")')._` |
| **Discourse short-circuit** (a false premise voids the rest) | stzTrueObject / stzFalseObject: truth-carrying objects that absorb the rest of the chain -- a hand-built Maybe monad | `IsAQ(:String)` returns the typed object OR `AFalseObject()` |
| Descriptor compilation (adjectives) | `IsAXT([:Lowercase, :Latin, :Word])` -> each SYMBOL dispatches to a real `@is<X>()` predicate | adjectives as data, resolved dynamically |
| Semantic subtlety | `IsA('LetterOf(...)')` verifies the ARTICLE's meaning: "a letter of" implies OTHERS exist -- the code checks there are >= 2 | grammar semantics enforced computationally |

Read as a whole, this is a small **computational grammar of English**
realized as method conventions. The flagship sentence proves the range:

    "The word 'ring' is a lowercase Latin word with a length of 4 letters
     and only 1 vowel."

    TheWordQM("ring").IsAQ([:Lowercase, :Latin, :Word]).WithQ().ALengthQ().
        OfQ(4).Q(:Letters).AndQ().OnlyQM(1).VowelNB()

Definite reference, adjectives, preposition, ellipsis, conjunction,
quantifier, number agreement -- every one deterministic, every one a real
call. No fluent-interface literature I know of goes this far; the closest
relatives (RSpec matchers, AssertJ) stop at conjunction and articles.

## 3. Empirical State (run 2026-07-10, ring127)

The 15 canonical examples from the two documents, executed as written:

| Example | Status |
|---|---|
| `Q("ring").IsAXT([:Lowercase,:Latin,:String])` | RUNS but answers **0** (article says TRUE) |
| `IsAXTQ(...).WhichQ().HasAQ().LengthQ().EqualTo(4)` | FAILS |
| `IsAQ(:String).InLowercase()` | FAILS |
| `IsAQ(:String).Which().IsLowercase()` | OK (1) |
| `TheWordQ("ring").HasNQ(4).LettersNB()` | FAILS |
| `SetLastValue(3); Q("AnnIE").VowelNB()` | RUNS but returns **3** (count, not the B-comparison) |
| `SetLastValue([...]); Q("AnnIE").VowelsB()` | OK (1) |
| `AreBothQ(:strings).HavingQ().TheirQ().FirstCharQ().EqualTo("R")` | FAILS |
| `AreQ(:numbers).ThatQ().AreNegativeQ().AndQ().DividableBy(10)` | FAILS |
| flagship `TheWordQM(...)...OnlyQM(1).VowelNB()` | FAILS |
| `IsTheQ(...).WhichIsQ().TheQ().ReverseOfB("gnir")` | FAILS |
| typo tolerance `InLowarcase()` | FAILS |
| `ContainingQ("@").AndQ().ContainingQ(".")` | FAILS |
| `AreQ(:numbers).ThatQ().ArePositive()` | FAILS |
| `BeforeQ(...).IsUppercasedFQ().RemoveFFQ("o")` | FAILS (wrappers dropped pre-2026; globals retired step 1) |

Root causes found so far:
- **`@isLowercase("ring")` returns 0** -- a live broken predicate global that
  silently poisons every descriptor chain containing `:Lowercase`.
- The **B/NB suffix family is gone**: zero `*NB(` methods remain in
  stzObject/stzString (dropped during string modularization). The ellipsis
  device -- arguably NNL's most original -- has no surviving implementation.
- Grammar particles survive partially (`WhichQ/ThatQ/AndQ/HavingQ/TheirQ/
  HasNQ` exist in stzObject; `OnlyQM`, `ALengthQ`, `OfQ` do not).
- The QM family survives (19 constructors in stzFuncs + `SetMainObject`
  context kept in step-1's trimmed stzNaturalCode).
- The FalseObject monad exists but covers only equality methods -- arbitrary
  continuation after a false premise (and the documented typo tolerance)
  has no catch-all, so chains die with R14 instead of absorbing.

**Verdict: the paradigm is intact on paper and one-third alive in code.**
The decay was invisible because no narrated suite ever locked the NNL
surface -- the naturalcode tests were retired instead of preserved.

## 4. Design Assessment

**What is genuinely strong -- keep as principles:**
1. *Human-as-parser determinism.* Nothing to misunderstand at runtime; the
   accountability story is "read the chain".
2. *The monad short-circuit.* True/FalseObject absorbing the rest of a
   chain is exactly right for narrative logic (a false premise voids the
   sentence, it does not crash it).
3. *Grammar particles as pass-throughs.* `WhichQ()/ThatQ()/AndQ()` cost
   nothing, change nothing, and buy readability -- pure linguistic sugar
   with zero semantic risk.
4. *Context devices model real discourse.* Definite reference (QM) and
   anaphoric ellipsis (LastValue + NB) are real, hard linguistic phenomena
   given honest computational form.
5. *Descriptor compilation.* `[:Lowercase, :Latin, :Word]` as data mapped to
   predicates is the same move the semantic lexicon later made -- Era 1
   invented Era 3's atom without naming it.

**What must change -- the honest critique:**
1. *Process-global context.* `_LastValue`/`_oMainObject` are shared by every
   chain in the process: two interleaved chains contaminate each other; no
   reentrancy; hostile to threads and to agents running many narrations.
   The context belongs ON THE CHAIN (carried by the returned object).
2. *Hand-written combinatorial surface.* `VowelNB`, `LettersNB`,
   `ReverseOfB`... every noun x every device suffix was hand-authored --
   thousands of aliases nobody can maintain; this is precisely why the
   layer decayed silently. The devices are REGULAR; the surface should be
   DERIVED (from the semantic lexicon + form grammar), not typed.
3. *Silent typo tolerance vs accountability.* `InLowarcase()` "still works"
   -- but so would `InLowercaze()` meaning nothing. Era 3 answered this
   properly: resolve morphologically, VERIFIED, and refuse or suggest
   otherwise. The rebuilt NNL should route unknown names through the same
   resolver (deterministic exact/variant hit -> run; miss -> lint error
   with a suggestion), replacing absorb-anything with explain-everything.
4. *No test spec.* A paradigm that lives as conventions dies without an
   executable specification. The articles ARE the spec; they must become a
   narrated suite (which literate blocks now make trivial).

## 5. Generalization: Derive the Surface from the Substrate

The single most important design decision for NNL 2.0: **stop hand-writing
the surface; generate it from the lexicon.** The semantic lexicon already
knows every operation, its kind (action/query), its arity, its forms, and
its aka words. The NNL devices are a FINITE grammar:

- ~15 grammar particles (`WhichQ ThatQ AndQ HavingQ TheirQ WithQ OfQ TheQ
  AnQ AQ AlsoQ ...`) -- pass-throughs, written once on stzObject, done.
- ~6 device suffixes per operation (`Q` chain, `N` number, `B` boolean vs
  chain context, `NB`, `M` memorize, `MM/QM-recall`) -- MECHANICAL
  transforms of any semantic ID.

So the NNL surface for the ~2280 grown operations is derivable:
`METHOD_NUMBEROFVOWELS` + device `NB` = "count, then compare to the chain's
expected value". One dispatcher -- resolve name morphologically (the step-2
machinery!), split the device suffix, execute ID + device -- replaces
thousands of hand aliases and can never rot again, because it reads the
same lexicon everything else reads. Era 3 does not replace Era 1; **Era 3
is the factory that finally makes Era 1 buildable at scale.**

## 6. The Convergence, Restated

One semantic program, THREE representations, all round-trippable through
the plan (the ordered list of semantic IDs + arguments + context bindings):

    free narration  <--Naturally-->  PLAN  <--linearize-->  NNL chain
    (human/agent text)               (IDs)                  (executable Ring)
                       Understood():  plan -> narration
                       NNL 2.0:       chain -> plan is the IDENTITY
                                      (each call IS an ID + device)

- Naturally: machine parses text -> plan -> executes. Bounded, refusing.
- NNL: human writes the plan DIRECTLY, wearing grammar. Unbounded, total.
- Understood: plan -> canonical narration (already shipped, multilingual).
- Missing piece: **plan -> NNL chain** (generate readable, executable Ring
  from any narration -- Naturally's codegen becoming NNL chains means the
  generated code itself reads like the sentence that produced it), and
  **NNL -> plan** (trivial in NNL 2.0), which gives NNL chains
  Understood()/Answers()/strict-mode FOR FREE.

## 7. Prospect: Governing Intelligent Systems

Why this matters beyond ergonomics. An agent -- programmatic (Softanza-
native) or LLM-driven -- needs an action language that is (a) expressive
enough to say real things, (b) bounded enough to be provable, (c) auditable
by humans, (d) deterministic in execution. The stack built this year is
exactly that contract:

- **Vocabulary bound**: packs + allow-lists define what CAN be said
  (StzExportPackTemplate already emits the contract; give it to the LLM as
  its tool grammar).
- **Total understanding**: strict mode refuses any narration containing an
  unresolved word; Unresolved() + suggest are the repair loop; the LLM
  regenerates until the machine can PROVE the reading.
- **Audit**: Understood() paraphrases back (multilingual); plan->NNL
  renders the executable artifact a human reviews; Answers()/AllYes() are
  the policy verdicts.
- **Grounding**: entities ($oWorldEntities, WhatIs) name the things acted
  on; stzKnowledgeGraph datasets can govern which relations are sayable --
  the bridging-minds Semantic Model (`Person Eats Fruit`) becomes the
  agent's ontology; a narration mentioning an entity the world cannot type
  is refusable, exactly like an unknown verb.
- **Policy as interrogative narration**: "Is the requester an admin ? Does
  the amount exceed 1000 ?" -- AllYes() as the gate. ChainOfValue's
  temporal gems (Until/Since/Whenever) are the natural-word guards for
  agent LOOPS -- the right rebuild target for that class when the agent
  thread opens.

This is the "algorithmically bound and totally understood" intelligence
the NNL documents were reaching for: not the machine pretending to
understand language, but language constrained until understanding is a
theorem.

## 8. The Plan -- Updated After the Renovation (2026-07-10)

The user directed: dig the archives, renovate cleanly with full coverage,
and invent new devices. That work LANDED, absorbing the original P1 and
the core of P3. The phases, restated against what now exists:

### DONE -- the renovation itself

- **The archive dig** established the original patterns: B/NB compare to
  LastValue and return This|AFalseObject (the monad); typo tolerance was
  literally hand-written `@Misspelled` alias sections; ALength was an
  article alias family; QM/MM memorize/recall the main referent.
- **P1 (spec-lock): DONE.** `@isLowercase`/`@isUpperCase` repaired (they
  were char-only predicates -- every word answered 0). The two decayed
  stzString remnants (VowelNb returning a bare count, VowelsB returning
  HasVowels) restored to true B semantics. `nnl_narrated.ring` (24
  assertions) is the executable specification: the article's opening
  example and the FLAGSHIP sentence now run and are locked:

      TheWordQM("ring").IsAQ([:Lowercase,:Latin,:Word]).WithQ().
          ALengthQ().OfQ(4).UnitQ(:Letters).AndQ().OnlyQM(1).VowelNB()
      #--> TRUE

  (UnitQ replaces the article's `.Q(:Letters)`: a method named Q() would
  shadow the global Q() for every child class -- the documented len()
  trap.)
- **P3 (derived surface): CORE DONE.** The hand-written engine on
  stzObject: `_NNLCall` (the accountable mini-dispatcher: exact method ->
  call; else resolve the stem through the ONE lexicon, morphology
  included; else REFUSE with a did-you-mean), `_NNLNounCount`,
  `_NNLExpectCompare`, `_NNLValueIs`, `_NNLDo`. Above it, the GENERATED
  noun surface: 41 countable nouns x N/NQ/NB/NBQ (+ Nouns B/BQ where the
  plural op exists) = 234 methods emitted from the semantic lexicon into
  a marked region of stzObject.ring (regenerate: scratchpad
  gen_nnl_surface.py). Child classes overriding a name win automatically
  on live objects, while stzFalseObject inherits the parent surface --
  which is exactly how the monad absorbs the WHOLE surface through three
  tiny overrides (_NNLCountIs/_NNLValueIs/_NNLExpectCompare return 0 with
  "the premise before was already false").
- **NEW DEVICES delivered** (aspects beyond the original catalog):
  1. **Comparative determiners** -- degree modification for the ellipsis
     device: `AtLeast(n) AtMost(n) MoreThan(n) LessThan(n) Exactly(n)
     About(n)/AboutXT(n,tol) BetweenN(n1,n2)` (+Q/QM forms; global
     Expect* twins). "About" models linguistic VAGUENESS (+/-10% default).
     BetweenN carries the N because stzString owns Between() for text.
  2. **The accountability surface** -- two scopes, per the archived
     WhyChainStopped precedent (explanations live ON the chain):
     chain-local `o.WhyCheckFailed()` (the last failing check on THIS object;
     interleaved chains never lie to each other) and
     `oFalse.WhyStopped()` (why the chain stopped -- a live object
     answers "the chain is not stopped", the archive's politeness);
     detached `Why()` remains as console/test convenience over the
     process register. Never WhyB -- the B suffix is reserved for
     boolean devices. Explain-everything replaced absorb-anything.
  3. **Conditional mood** -- the chain branches on its own truth:
     `Q("ring").IsAQ(:String).IfSo(:Uppercase).Otherwise(:Trim)`. The
     false premise now CARRIES its origin (AFalseObjectXT wired into all
     9 monadic sites), so Otherwise recovers the judged object and acts
     on it. Actions are natural: `:Uppercase`, "remove duplicates"
     (lexicon-resolved), or `[ :Replace, "a", "b" ]`.
  4. **Ordinal reference** -- `TheNth(2, :Words)`, `TheFirst/TheLast
     (:Vowels)`: definite reference into plural nouns, stzOrdinal wired
     into the refusal message ("there is no 4th word here").
  5. Grammar particles completed: `AnQ AlsoQ UnitQ` join the surviving
     WhichQ/ThatQ/AndQ/HavingQ/TheirQ/WithQ/OfQ/TheQ/OnlyQM family; the
     generic `ALengthN/ALength/ALengthQ/ALengthNB` article device works
     on ANY object (chars/items/digits by type).

### REMAINING -- the re-scoped phases

- **P2 -- Chain-scoped context.** Unchanged: MainObject/LastValue/the
  expectation register are still process globals; move them onto the
  chain (carried by returned objects) with the globals as compatibility
  shims. Required before NNL is agent-safe under concurrency.
- **P3b -- Widen the derived surface.** Today: countable nouns. Next:
  predicate B-forms for query ops (EqualsB, StartsWithB...), M/QM
  variants generated, and pack-language aka stems accepted by _NNLCall
  (the dispatcher already reads the lexicon; let it read the packs too,
  making the NNL surface MULTILINGUAL like Naturally already is).
- **P4 -- The pivot round-trip.** Unchanged: plan->NNL linearizer
  (Naturally emitting NNL chains as its generated code) and NNL->plan;
  NNL chains then gain Understood()/Answers()/strict for free.
- **P5 -- The governance kit.** Unchanged: entity-grounded strict mode,
  graph-governed relations, interrogative policies as gates,
  ChainOfValue's temporal guards rebuilt on W, the LLM contract bundle.
- **P6 (new) -- Device candidates observed but deferred:** distributive
  quantification (`EachQ()` mapping the next predicate over items --
  needs W integration), chain-level negation particle (`NotQ()` flipping
  the next predicate -- needs the P3b dispatcher), evidentiality
  ("apparently/certainly" -- confidence-carrying answers pairing with
  the neural tier's scores), and discourse tense over QH history
  ("was it ever uppercase?" -- SoFarQ/EverB over the object's kept
  history).
