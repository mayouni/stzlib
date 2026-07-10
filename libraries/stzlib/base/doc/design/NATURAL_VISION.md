# The Softanza Natural Programming Vision
## One Gap, Three Attacks -- and the Common Architecture That Unifies Them

*Synthesis of the full natural/ folder, its published articles, the deleted
design documents recovered from git history, and the legacy test corpus
(chainoftruth/, naturalcode/, test-copy monoliths). Written 2026-07-10,
after the lexical + neural substrate landed.*

---

## 1. The Single Problem

Everything in `base/natural/` -- across five years of layers -- attacks a
single wall: **the semantic gap between a human intention and its
execution**. What makes the folder look heterogeneous is that the gap was
attacked from three directions, in three eras.

### Era 1 -- Near-Natural Coding (raise the code toward language)

The host is *Ring syntax*; naturalness lives inside it. Artifacts:

- **The function-forms grammar** (active / passive / fluent / immutable /
  partial / plural forms) -- documented in
  `stz-functions-as-linguistic-expressions.md`. The **"Chain of Actions"**
  is precisely the Q()-fluent chain as that article defines it.
- **stzChainOfTruth** -- boolean narratives:
  `_("ring").IsA(:String).Which(:IsLowercase).Containing("g")._`
- **stzChainOfValue** -- temporal / conditional execution in natural words:
  `Until(v).Becomes(10).DoThis(...)`, with self-explaining
  `WhyChainStopped()`.
- **stzNaturalCode** -- the `_aFuture` deferred-action queue (FQ/FFQ
  suffixes, `BeforeQ`/`AfterQ`), `_LastValue`/`_MainValue` context memory,
  and the `_ActionsXT` glossary.
- **The morphology helpers** -- stzAdverb, stzPlural, stzSingular,
  stzOrdinal.
- **stzNaturalMarkup** -- annotation-governed structure (see section 5).

### Era 2 -- Natural Programming (lower the language toward code)

The host is *free text*. The recovered design document
(`stz-natural-programming-design.md`, deleted from the tree but present in
history) states the architecture explicitly: **selective attention** --
ignore filler words, react only to semantic triggers, stay data-driven.
`stzNatural` implements it ("molecular design": one object per block, full
plan built in memory *before* execution -- see
`stznatural-vs-ring-naturallib.md`).

### Era 3 -- the Meaning Substrate (2026)

- **stzText / stzListOfTexts** -- the linguistic tier: lemmatization, POS,
  NER, sentiment, key phrases, summarization, sentence embeddings. A
  *string* is characters; a *text* is a string elevated to meaning.
- **The semantic unification** -- ONE semantic-ID lexicon
  (stzSemanticResolver) merging the packs, the `_ActionsXT` descendant, and
  the `#@ aka` tags; shared by execution (Naturally) and documentation
  (Ask/Explain). Multilingual morphology packs (en/ha/fr/ar/tr), verified
  affix stripping, one IDF ranker with neural rescue, runtime teaching,
  predictive suggest, naming lint, `Understood()` paraphrase-back in the
  program's own language, pack template exporter.

### The Transversal Insight

**The semantic ID is the atom of the whole system.** Era 3 built what Eras
1 and 2 were each groping for separately:

- the *forms grammar* says how an ID surfaces as a **method name**;
- the *packs* say how it surfaces in a **human language**;
- *morphology* bends inflected words back to it;
- the *neural tier* rescues what the lexicon misses;
- `Understood()` linearizes IDs back out;
- *plans* order IDs in time (the Future idea, absorbed);
- *entities* name the things IDs act on.

A coherent Softanza natural system is simply: **every layer reads and
writes the same IDs**. Nothing else needs to be shared.

---

## 2. The Target Architecture

```
                +----------------------------------------------+
  Floor 4       |  KNOWLEDGE: one $oWorldEntities world        |
  (emerging)    |  Naturally names - NER feeds - Ask queries   |
                +----------------------------------------------+
  Floor 3       |  TWO SYMMETRIC SURFACES                      |
                |  Natural->Code: Naturally/In (+ suggest,     |
                |    strict mode, teach, Understood)           |
                |  Code->Natural: Ask/Explain/PlanForIntent    |
                +----------------------------------------------+
  Floor 2       |  NEAR-NATURAL RING: forms grammar            |
                |  (active/passive/Q/W), chain of actions;     |
                |  ChainOfTruth as resolver-backed sugar       |
                +----------------------------------------------+
  Floor 1       |  MEANING SUBSTRATE: semantic-ID lexicon,     |
                |  packs + morphology (Plural/Singular/...),   |
                |  stzText linguistics, neural embeddings      |
                +----------------------------------------------+
                    one atom everywhere: the semantic ID
```

---

## 3. Verdicts, File by File

### 3.1 The spine -- necessary, already converged

| File | Role |
|---|---|
| stzNatural.ring | The Era-2 engine, unified with the resolver, suite-guarded (semantic_resolver 79, multilingual 45, hostile-globals 27) |
| stzSemanticResolver.ring | The one lexicon -- absorbed `_ActionsXT`, the packs, the aka tags; ranker + morphology + teach/suggest/lint/linearize |
| stzNaturalLangData.ring | Pure-data language packs (en/ha/fr/ar/tr) |
| stzText.ring | The meaning tier over strings (Tier-1 linguistics + neural) |
| stzListOfTexts.ring | Meaning ops on collections (semantic rank, sentiment filter; neural upgrade / lexical degrade) |

### 3.2 Necessary but currently islands -- wire them in

- **stzPlural / stzSingular / stzAdverb / stzOrdinal** -- keep. They serve
  *both* directions: understanding ("strings" -> OBJECT_STRING; the old
  `11_pluraltostztype` idea) and surface realization (Understood/Explain).
  Today nothing in the resolver calls them -- the English canon path should
  use Singular() the way the Arabic path uses suffix stripping.

- **stzEntity / stzListOfEntities** -- keep; this is the seed of the
  **Semantic Model** from `stz-bridging-minds-and-code.md`
  (`IsA(:Fruit)`, `WhatIs`, relations like `:Eats`). Three proto-entity
  systems exist today: the engine's named objects (`call it basket`),
  stzText's `NamedEntities()`, and `$oWorldEntities` (only fed by
  ChainOfTruth's `_@`). There should be ONE world that Naturally() writes
  into, NER feeds, and Ask can query. This is the next unification of the
  same kind as the lexicon one.

### 3.3 Reconsider -- the ideas survive, the implementations don't

- **stzNaturalCode.ring** -- all three contributions have modern heirs:
  `_ActionsXT` -> the lexicon (absorbed); `_LastValue`/`_MainValue`
  context -> `@result` + `keep it as` variable bindings; `_aFuture`
  deferred actions -> **the plan**. The FQ/FFQ suffix wrappers it depended
  on were already dropped during string modularization (why the
  naturalcode tests are retired stubs). The deferred-execution *insight*
  was profound -- natural language demands building the full computational
  model before executing -- and it is exactly what the engine's token plan
  and the SOV params-before-verb machinery do now. Retire the globals; the
  idea is already home.

- **stzChainOfTruth.ring** -- the readable boolean narrative is
  distinctive and worth keeping *as a surface*. But the guts are per-step
  `eval()` of user strings (the pattern already retired elsewhere in favor
  of the W engine), and its predicate resolution duplicates what the
  lexicon does better (predicates are form-classified with their own query
  IDs). Options: **(a)** rebuild thin -- each chain word resolves through
  the lexicon, the whole chain compiles once to a W-expression; **(b)**
  absorb into Naturally as interrogative narrations ("is it a lowercase
  string containing 'g'?" -> ask-chain). Leaning (b), with (a) as sugar
  later. NOTE: the chainoftruth tests RUN today under ring127 -- their
  `#ERR` annotations are stale and must be refreshed either way.

- **stzChainOfValue.ring** -- `Whatever/Until/Since/Becomes` is reactive
  programming in natural words, half-finished and global-state heavy. Its
  lasting gem is not the loop mechanics -- it is
  **`WhyChainStopped()` / `WhyCodeNotExecuted()`: computation that
  explains its own refusals**. That principle is now the signature of the
  whole natural layer (`Unresolved()`, strict-mode refusals, the
  ambiguity-refuses ranker). Extract the explainability doctrine (done, in
  effect); park the temporal DSL until there is a real reactive thread --
  it belongs beside W, not in natural/.

- **stzChainOfCode** -- never implemented; only a dangling
  `IsStzChainOfCode()` in stzObject. Remove, or keep as the named slot for
  the plan builder -- which is what it would have been.

- **stzConstraints.ring** -- a stub referencing a `_aConstraints` global
  that does not exist anywhere. The living heirs of the constraints idea
  are strict mode + allow-lists + the probe/lint layer. Fold into a future
  "contracts" thread; as a file it is dead.

- **stznatural-copy.ring** -- pre-unification drift copy; archive it.

---

## 4. The Articles -- What Each Contributes to the Vision

| Document | Durable contribution |
|---|---|
| stz-bridging-minds-and-code.md | The THREE MODELS: Semantic (knowledge/entities), Mental (CREATE > FIND > APPLY), Expression (forms). The multi-stakeholder audience (analysts, educators, linguists). |
| stz-functions-as-linguistic-expressions.md | The grammar of the API: forms as linguistic categories; "Chain of Actions" = the Q-chain. |
| stz-near-natural-language-programming.md | The NNC-era manifesto: suffix system (Q/B/N/FQ/FFQ), context memory, deferred actions, `Naturally(){}` as the stated destination. |
| stz-natural-programming-design.md (recovered) | Selective attention / intent-driven architecture -- the design stzNatural implements. |
| stznatural-vs-ring-naturallib.md | Molecular design (one object per block); string-based input over braces; plan-before-execute. |
| stznatural-narration.md | The current engine's three pillars (language defs / semantic ops / engine). |
| stzfolder-natural-navigation.md | Natural orientation applied beyond language: state follows action. A design principle, not a natural/ artifact. |

---

## 5. The Focused Question: stzNaturalMarkup

Its purpose was to **govern structure by annotation**: `#< #>` blocks,
`{+list:fruits}` typed creation, `{#1 ...}` parameter slots, `{?how-many}`
query markers, `{Verb}` action markers, `^heart` globals, `2~` arity
hints. Every annotation existed to hand the machine what it could not
infer.

The lexical + neural system has since made each annotation redundant:

| Markup annotation | Modern equivalent, from raw text |
|---|---|
| `{+list:fruits}` typed creation | creation verbs + type words + `called` naming |
| `{#1 [...]}` parameter slots | literal extraction + token provenance |
| `{?how-many}` query marker | query kinds + `@result =` ask semantics |
| `{Verb}` action marker | the resolver (exact -> IDF -> neural rescue) |
| `^heart` globals | `keep it as` / recall bindings |
| arity hints `2~` | grown-op arity from the harvest |
| the governance role itself | strict mode + allow-lists + Understood() + predictive suggest |

The class itself is an unfinished skeleton -- `_ResolveParams()` and
`_GenCode()` are empty; it never generated code.

**Verdict: as an interpretation aid, retire it.** The deepest argument:
markup governs by making the human annotate; the current system governs by
*dialogue* -- suggest guides while typing, strict mode fences, Understood
verifies after. Strictly better ergonomics for the same guarantee.

**Two seeds worth preserving, in modern form, when wanted:**

1. **The block fence (`#< ... #>`) = literate natural programming** --
   executable natural blocks embedded in documents. Modern implementation:
   a ~20-line extractor feeding Naturally(), not a markup language.
   Attractive for the educator/researcher audience.
2. **Parameter slots = natural templates** -- reusable natural procedures
   with holes ("Create a list with {#1} and remove duplicates"). Modern
   heir: a fill-in-the-blanks `NaturallyWith(template, args)` built on the
   existing variable-binding machinery.

---

## 6. Sequencing

1. **Housekeeping** -- archive stznatural-copy.ring; retire
   stzNaturalMarkup, stzNaturalCode's future/context globals, and
   stzConstraints; remove or repurpose the `IsStzChainOfCode` dangler;
   refresh the stale `#ERR` annotations in test/chainoftruth/ and
   test/naturalcode/ (several pass today under ring127).
2. **Morphology wiring** -- Plural/Singular into the en canon path and the
   linearization path (Adverb/Ordinal on standby for surface realization).
3. **Entity convergence** -- one `$oWorldEntities` world: engine named
   objects become stzEntity instances; stzText.NamedEntities() emits into
   the same registry; Ask gains world queries (WhatIs). This realizes the
   Semantic Model pillar of the oldest vision and is the biggest
   structural win remaining.
4. **ChainOfTruth decision** -- absorb into interrogative narrations, or
   rebuild resolver-backed; either way refresh its tests.
5. **Markup seeds (optional)** -- literate blocks + natural templates as
   small stzNatural features.

---

## 7. Closing Observation

The Era-2 design document promised "unlimited expressiveness, intent
preservation, data-driven scope." What was actually built since -- refusal
on ambiguity, teachability, self-paraphrase in the program's own language,
multilingual morphology -- quietly delivered a fourth promise the old
documents never dared to make: **accountability**. The system can always
say what it understood, what it refused, and why. That, more than any
single class, is what distinguishes Softanza's natural programming from
both LLM code generation and toy DSLs -- and it is the thread to keep
pulling.
