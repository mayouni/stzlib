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

## 4b. The Grammaticality Doctrine (author's correction, 2026-07-10)

Two rules that ARE the paradigm, learned by violating them:

1. **The chain IS the sentence.** Every particle is a syntactic
   constituent, not decoration. A relative pronoun must be followed by a
   verb: `...WhichQ().HasQ().ALengthQ().Of(4)` -- "which HAS a length of
   4". `...WhichQ().ALengthQ()` runs but reads "which a length": that a
   chain executes does NOT make it NNL-correct; an ungrammatical chain
   that runs is a BUG in NNL terms, because the paradigm's claim is that
   the code adheres to language dynamics. Reviewing an NNL chain =
   reading it aloud as English and rejecting what a native speaker would
   reject.
2. **M is a commitment, never a default.** `QM` declares "a later clause
   will refer back to this referent". If nothing recalls it, M is wrong
   -- a topic introduced and never mentioned again:
   - no recall -> no M:
     `TheWordQ("ring").IsAQ(:Word).WhichQ().HasQ().ALengthQ().Of(4)`
   - recall ("...and only 1 vowel" refers back to the WORD) -> M:
     `TheWordQM("ring")...ALengthQ().OfQ(4).AndQ().OnlyQM(1).VowelNB()`
   Grammar decides M -- specifically, whether the discourse contains a
   forward reference -- not habit.

Fix that fell out of the correction: IsAQ(pcType) with a NON-core
descriptor (:Word, :Char...) used to fall through its type switch and
return NOTHING (R13 downstream); it now continues on the typed object,
context carried, so the author's canonical statement runs as written.

## 4c. The M Ruling (author, 2026-07-10): MARKERLESS -- the M zoo is REMOVED

The archive dig reconstructed the original M-algebra (MQ = memorize-and-
chain, final QM = recall, MM = emphatic recall, one IsAQM duplicate) and
the author rejected it on review: the letter-order cipher was inverted by
its own inventor from memory, it duplicated meanings (one thing must do
one thing), and language itself never marks reference this way.

THE MODEL NOW (endorsed and enforced):
1. The subject is the topic BY BEING THE SUBJECT -- Q()/The*Q()
   constructors stamp the chain subject chain-locally at birth; no
   marker, no global.
2. Comebacks resolve by SELECTIONAL ATTACHMENT, deterministically:
   nearest referent first (the current object), the subject second
   ("...a length of 4 and only 1 vowel" -- lengths have no vowels),
   refusal third, with explanation.
3. The pronouns ItQ()/ItsQ()/TheirQ() are the ONLY explicit recall --
   they return the chain subject (which on an uninterrupted chain is
   This itself: one semantic, two situations).

REMOVED (not frozen -- removed): 260+ M-suffixed methods across
stzObject (x{M, MQ, QM, MM, QMM} families), the three QM constructor
funcs (StzTheString/Number/ListQM + aliases like TheWordQM), the QM()
global, and the Main-register globals (_oMainObject, MainObject,
SetMainObject) -- ChainOfTruth/Value never used them. The flagship reads
exactly like its English sentence now, marker-free:

    TheWordQ("ring").IsAQ([:Lowercase,:Latin,:Word]).WithQ().ALengthQ().
        OfQ(4).UnitQ(:Letters).AndQ().OnlyQ(1).VowelNB()   #--> TRUE

Casualty note for honesty: the first removal sweep matched suffixes
case-insensitively and briefly took FromQ/FromThemQ/ThemQ/HimQ ("from"+Q,
"them"+Q are particles, not zoo) -- restored from git in the same
session; the executable spec caught nothing because those particles were
untested: they now deserve assertions when the particle inventory is
locked (P3b).

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

## 7. (Withdrawn)

This section proposed using the stack to govern AI agents and LLMs.
The author ruled that scope OUT of the library (2026-07-12); the
section is withdrawn and the corresponding code was removed.

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

- **P2 -- Chain-scoped context.** [DONE 2026-07-10] The expectation
  register (@pNNLExpect/@cNNLExpectMode/@nNNLExpectTol) and the main
  referent (@oNNLMain) are now ATTRIBUTES of the chain: determiners set
  the expectation on the object they RETURN (QM determiners set it on
  the recalled main), devices that build new objects carry the context
  over (_NNLCarry through IsAXTQ/IsAQ/ALengthQ/ordinals/generated NQ),
  all 116 *QM recall sites read the chain-local main first
  (This._NNLMain()), SetMainObject stamps the chain-local main, and the
  false branch carries it too. The globals survive as fallback shims and
  the detached console surface. Suite-proven: two interleaved discourses
  each keep their own referent AND their own expectation
  (nnl_narrated 37/37). Remaining niche: legacy Q-methods outside the
  NNL layer that build new objects do not carry (fall back to globals).
- **P3b -- Widen the derived surface.** Today: countable nouns. Next:
  predicate B-forms for query ops (EqualsB, StartsWithB...), M/QM
  variants generated, and pack-language aka stems accepted by _NNLCall
  (the dispatcher already reads the lexicon; let it read the packs too,
  making the NNL surface MULTILINGUAL like Naturally already is).
- **P4 -- The pivot round-trip.** Unchanged: plan->NNL linearizer
  (Naturally emitting NNL chains as its generated code) and NNL->plan;
  NNL chains then gain Understood()/Answers()/strict for free.
- **P5 -- REMOVED by the author (2026-07-12).** The governance kit
  (StzPolicy, StzAgentContract, grounded strict) and every LLM-facing
  relation were ruled OUT of the library and deleted the same day they
  landed. The natural stack's own guarantees (strict mode, refusal,
  Why, Understood, the ask records, Suppose) remain -- as library
  features, not as an agent-governance product.

- **P6 (new) -- Device candidates observed but deferred** (status as of
  2026-07-12): distributive quantification DONE (EachQ/AnyQ/NoneQ +
  item forms); chain-level `NotQ()` RULED OUT by the negation doctrine
  (negative forms / antonym comparators / OrNot instead); discourse
  tense DONE (WasEver/WasNever/UsedToBe/IsStill over the QH stream).
  Only EVIDENTIALITY remains ("apparently/certainly" --
  confidence-carrying answers pairing with the neural tier's scores).

## 9. The Coverage Map -- Toward Any Natural-Language Expression

The author's question (2026-07-10): what constructs cover, theoretically,
ANY natural-language expression? Typology's answer: a finite inventory --
a predicate-argument core wrapped in operator layers (negation, modality,
aspect, tense), given an ILLOCUTIONARY FORCE, combined by coordination /
subordination / comparison / quantification, over a discourse layer
(reference, ellipsis, information structure). Cover the systems and every
idiom is a composition.

| Linguistic system | Status |
|---|---|
| Predicate + arguments | DONE (methods + params) |
| Reference & anaphora | DONE (markerless subject, attachment, pronouns) |
| Determiners & degree (+vagueness) | DONE |
| Agreement / relatives / flow-and | DONE |
| Ellipsis | DONE (expectation register + NB) |
| Conditional mood | DONE (IfSo/Otherwise) |
| Voice | DONE (forms grammar) |
| Illocutionary force (questions) | DONE Q1 -- stzQuestion (below) |
| Comparison of computed constituents | DONE Q1 (same/different/more/less) |
| Noun phrases as values | DONE Q1 (aspect + genitive slots) |
| Truth-functional or/nor, both...and | DONE Q3-corrected: fused copulas IsEitherQ/IsNeitherQ coordinate TYPE NOUNS (ANumberQ/AStringQ...); Or-recovery via origin; skip short-circuit; pronouns carry the figure |
| Negation | DONE Q3-corrected: NO NotQ (un-English) -- negative FORMS (IsNot*/DoesNot*), ANTONYM comparators (DifferentFromQ), and the TAG closer OrNot() |
| Distributive quantification | DONE Q3b: EachQ/AnyQ/NoneQ figures distribute the next predicate (types AND the NB ellipsis device) with per-item explanations; strings quantify over chars; the collective ALL stays in AreQ (agreement) |
| Tense/aspect over history | DONE Q4: WasEver/WasNever/UsedToBe/IsStill peek the QH stream (owned, never another chain's leftovers), explain with the state |
| Modality (can/must) | DONE (2026-07-12): kind constraints (ConstrainQ...ToBeQ) + CanQ/MustQ modal questions + the QualifiesAsQ gate; AND the archived per-object design GENERALIZED onto stzObject per the author (AddConstraint named rules -- descriptors or placeholder conditions -- VerifyConstraint(s) with Why, ApplyConstraints = the structured cancel, chainable when clean); enforcement-on-update DONE (2026-07-12): EnforceConstraint() arms a guard at the single update point (stzString/stzNumber Update, stzList _SetContent -- the very site the author's archived '# Checking object constraints (#TODO)' reserved in stzNumber.Update); violating updates are refused BEFORE they land (mutators compute-then-Update, so the object stands untouched); RelaxConstraints() disarms while on-demand verification stays |
| Evidentiality | DONE (2026-07-13): the evidential register -- every verdict carries its confidence ($nStzLastCertainty; Certainty()/Evidentially()/HowCertain()); deterministic checks answer CERTAINLY (1), the semantic verdicts (similarity, zero-shot, sentiment) carry their graded score (neural when a model is loaded, honest lexical evidence otherwise); bands >= 0.85 certainly / >= 0.60 probably / else apparently; Why() narrates the evidential verdict ("probably yes: semantically similar to ..."). THE COVERAGE MAP IS COMPLETE. |
| Hypothetical contexts | DONE (2026-07-12): SupposeQ(name).IsAQ(type) overlays the world; WhatIs answers while supposed; ForgetSuppositions discards (world untouched), CommitSuppositions concludes via StzKnow -- the agent reasoning primitive |

### 9.1 Q1 -- stzQuestion, DONE 2026-07-10

The author's design, two LAWS enforced:
- **Decomposition: one word = one method.** TheQ() stands alone; nouns
  are GENERATED from the lexicon (1063 on the frame: every arity-0 query
  + every NumberOf* counter). Particles compose with nouns -- never fused
  (TheLengthQ-style fusion is the alias explosion reborn).
- **The plain form closes.** Q chains, no-Q answers -- the house
  Q-convention applied to interrogation. Two grammatical orderings, two
  closers:

      WhatIsQ().TheQ().FirstCharQ().Of("Ring")          --> "R"
      WhatQ().TheQ().FirstCharQ().OfQ("Ring").Is()      --> "R"
      IsQ().TheQ().LengthQ().OfQ("Ring").IsQ().
          TheSameAsQ().TheQ().LengthQ().Of("Ruby")      --> 1
      HowManyQ().VowelsQ().Of("Ring")                   --> 1

The frame (natural/stzQuestion.ring) is a slot-filling machine, NOT an
stzObject descendant (it records, it must not execute); aspects compute
through the accountable dispatcher (morphology + refusal-with-suggestion
for free); every answer records Why() ("yes: 4 is the same as 4"); WH
answers are DATA (values, lists); HowMany prefers the NumberOf twin.
Suite: question_narrated 13/13.


### 9.2 Q3 corrected by the author (grammar over mechanics)

My first Q3 shapes ran but were un-English and were rejected:
"IsQ()...IsQ().NotQ().TheSameAsQ()" doubles the fronted copula and
misplaces negation; "EitherQ().IsAQ().OrQ().IsAQ()" is not how English
coordinates predicates. The corrected inventory:

- TAG QUESTION: IsQ().TheQ().LengthQ().OfQ("Ring").TheSameAsQ().TheQ().
  LengthQ().OfQ("Ruby").OrNot() -- OrNot() is a plain-form CLOSER (it
  answers); the tag does not negate.
- Negation-proper: antonym comparators (DifferentFromQ) and the
  negative forms family. NotQ was removed everywhere.
- Disjunction: Q("Ring").IsEitherQ().ANumberQ().OrQ().AStringQ() --
  the fused copula + TYPE NOUNS; the first disjunct may fail without
  falsifying; a satisfied disjunction skips the rest (proven by type
  passthrough).
- Neither: IsNeitherQ().ANumberQ().NorQ().AListQ(), and the author's
  inverted variant NeitherQ().IsAQ(:Number).NorQ().ItQ().IsAQ(:List).

CORRECTED BY THE AUTHOR -- THE ALIASING DOCTRINE (mutation-probed;
objectid() is volatile and proves nothing):

- Ring semantics: numbers/strings COPY; lists and objects pass BY
  REFERENCE into functions, but the `=` ASSIGNMENT (including
  attribute store) COPIES.
- The engine corollary: a copied stz object SHARES its engine handle;
  after the younger copy mutates, the ELDER's content view DANGLES
  (reads empty). Therefore: NEVER alias stz objects with `=` -- clone
  through content with QC()/Copy().
- The chain is built of objects RETURNED BY SOFTANZA CODE (This or a
  deliberate new object): its semantics belong to the library, never
  to raw Ring aliasing.
- Consequences implemented: the global QC() now exists (the missing
  member of the MACROPLAN trio "Q() chaining, QC() clone, QH()
  history") -- chain on a clone, original untouched, for values AND
  stz objects; the reflect layer already tags the ...QC method suffix
  as the immutable form, to be emitted by the generator in P3b.
  Subject stamping became LAZY (at interruption, from the live
  object) -- a birth-time snapshot would dangle after the original
  mutates; pronouns fall back to This on uninterrupted chains and
  re-stamp the live logical figure on what they hand back.

Q4 DONE (2026-07-12): discourse tense over QH + the session
ask-record (AnswersSoFar/AllYesSoFar/AnyYesSoFar/ClearAnswers -- every
question frame records its verdict, so a run of questions folds like a
narration: the agent-gate primitive). WhatQ<->WhatIs converge BY NAME:
frames ask about VALUES, WhatIs() asks the WORLD -- one interrogative
family, two knowledge sources; no new syntax invented without the
author. And since 2026-07-12, one DOOR: Ask() consults the entity world
on world-shaped questions ("(world)" entries), and WhatIs() falls back
to the library through Ask's own retrieval pipeline. plan->NNL emission deferred (the generated code is already
readable method calls; revisit on demand).

Q2 DONE (2026-07-10): the generator emits 2512 devices -- countable-noun
families, value-agreement B/BQ over every arity-0 query, immutable QC
over every arity-0/1 action (seeds parsed from stzNatural.ring: the
cache holds grown ops only), and _NNLCall resolves PACK-language stems
(IfSo("majuscule") uppercases). Remaining: Q4
(convergence: frame answers into Answers()/AllYes, WhatQ meets WhatIs,
history tense, plan<->NNL).
