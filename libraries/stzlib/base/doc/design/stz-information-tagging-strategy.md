# Softanza Information-Tagging Strategy

*How every unit of the library becomes retrievable, explainable, and
conversational -- for both lexical (zero-setup) and neural (model-loaded)
natural-language queries.*

Status: **active build** (2026-07-08). Owner: reflection/self-doc layer
(`base/reflect/`), built on the neural tier (`base/neural/`).

---

## 1. Why

Softanza's differentiator is *near-natural programming*: you describe an
intent in plain language and the library tells you the operation (`Ask`),
explains it (`Explain`), or hands you a runnable snippet. That only works if
every unit of the library carries enough **machine-readable meaning** to be
retrieved and ranked against a question.

Today the retrieval text of a method = `camel-split(name) + doc-comment +
section-title`. That already lifted effective coverage to 91-100% on the
sectioned mains. But three gaps remain:

1. **Vocabulary gap.** A user asks for "mood"; the method is `Sentiment`.
   Lexical bag-of-words misses it; even neural embeddings do better with the
   synonym present. We need **user-language aliases** per unit.
2. **Example gap.** "How do I X?" is best answered with a *runnable snippet*,
   not a method name. We have 2986 files of `#-->` examples and hundreds of
   `Scenario(...)` tests -- currently invisible to retrieval.
3. **Intent gap.** There is no atomic "one intent -> one solution" unit that a
   conversation can surface directly. The prose `quickers/` are close but
   long-form.

The strategy closes all three by defining a **single knowledge record** that
methods, examples, and intent-recipes all normalize into, and a small set of
**cheap, backward-compatible conventions** to author them.

## 2. The unifying idea: one knowledge record

Every retrievable unit -- a method, a harvested test example, or an intent
recipe -- normalizes to the same record:

```
{ id         : "stzText.Sentiment"          # stable handle
  kind       : method | recipe | example    # what it is
  name       : "Sentiment"
  intent     : "the overall tone/mood ..."  # one-line, user words
  category   : "sentiment (vader)"          # section / domain tag
  aka        : [mood, feeling, tone, ...]   # user-language synonyms
  signature  : "Sentiment()"                # params
  returns    : "string: positive|neg|neut"  # out shape
  example    : "Q(s).Text().Sentiment() #--> \"negative\""
  see        : [SentimentScore, IsPositive]
  owner      : "stzText"                    # defining class
  source     : "base/natural/stzText.ring" }
```

- **Retrieval text** (what lexical cosine + neural embedding score against) =
  `name-as-words + intent + aka + category (+ example words for recipes)`.
- **Explanation** (what `Explain` renders) = the structured fields.
- **Conversation** follows `see`/`owner`/`kind` links across turns.

The four authoring layers below all feed this one record. Nothing else in the
retrieval/conversation engine needs to know which layer a record came from.

## 3. The four authoring layers

### Layer 0 -- Section headers  *(done)*

Boxed `#==#` headers already act as coarse category tags; the harvester
(`_StzHarvestRange`) attributes each undocumented method to its enclosing
section. Keep every class organized under section boxes. This is the free
floor that guarantees no method is meaningless.

**Convention:** one boxed header per capability group; put the richest keyword
form in the title, keep parentheticals -- `SENTIMENT (VADER)`,
`NAMED-ENTITY RECOGNITION`, `KEY-PHRASE EXTRACTION (RAKE)`.

### Layer 1 -- Intent line  *(convention formalized)*

The first plain `# ...` line(s) immediately above a `def` = the method's
one-line **intent**, written in the *user's* words (what/why), not the
implementation. This is the single highest-value hand-edit.

```ring
# The overall tone/mood of the text as "positive", "negative", or "neutral".
def Sentiment()
```

**Rule:** lead with the noun/verb a user would search ("tone", "mood"),
name the return shape, avoid engine jargon. One line is enough.

### Layer 2 -- Structured InfoTags  *(new: the `#@` convention)*

Optional machine-readable tags in the docblock, above `def`, one per line.
Backward compatible (anything not `#@` is untouched). Parsed into the record.

```ring
# The overall tone/mood of the text as "positive", "negative", or "neutral".
#@ aka  mood, feeling, tone, emotion, polarity, how positive or negative
#@ out  string: "positive" | "negative" | "neutral"
#@ eg   Q("The service was terrible.").Text().Sentiment()   #--> "negative"
#@ see  SentimentScore, IsPositive, IsNegative
def Sentiment()
```

Tag vocabulary (all optional):

| tag    | meaning                                   | feeds            |
|--------|-------------------------------------------|------------------|
| `aka`  | user-language synonyms / phrasings        | retrieval (huge) |
| `out`  | return shape/type                         | explain + retr.  |
| `eg`   | one-line example, uses `#-->`             | explain + recipe |
| `see`  | related method names                      | retrieval + nav  |
| `tags` | extra domain tags                         | retrieval        |

**`aka` is the highest-ROI field**: a handful of synonyms per flagship method
widens both lexical recall and neural match dramatically. Author `aka` on the
top ~20% of methods (by expected query traffic); the long tail rides on
name + section.

**Sigil choice:** `#@` -- visually distinct, greppable, never collides with
`# prose`, `#--> output`, or `#==# boxes`. Centralized parser, so the sigil is
cheap to change if ever needed.

### Layer 3 -- Test-sample harvest  *(new: examples for free)*

The `*_narrated.ring` scenario suites already encode `Scenario("intent
phrase")` + runnable code + `#-->` outputs. Harvest them:

- `Scenario(title)` -> an **intent phrase** (a `kind: example` record).
- The code block until `EndScenario()` -> the example body.
- Regex `.\w+(` over the block -> the stz methods it demonstrates -> link the
  example to those method records (auto, zero manual tagging).

This turns the existing test corpus into a runnable-example index at no
authoring cost, and doubles as a *documentation-is-tested* guarantee: every
harvested example provably runs and passes.

**Convention (optional sharpening):** a scenario may name its focus with an
inline `#@ demonstrates stzText.Sentiment` for precise linkage when the code
touches many methods.

### Layer 4 -- Intent recipes  *(new atomic "quicker": `quickers/recipes/`)*

The atomic quick-doc the retrieval layer loves and humans skim: **one intent,
one minimal solution.** Lives under `doc/quickers/recipes/<domain>/<slug>.md`.
A strict, machine-parseable shape (superset is still valid markdown):

```markdown
# Intent: Detect the emotional tone of a paragraph

​```ring
Q("The service was terrible, but the food was great.").Text().Sentiment()
#--> "positive"
​```

- **Methods:** stzText.Sentiment, stzText.SentimentScore
- **Tags:** sentiment, mood, tone, emotion, feeling, positive, negative
- **See also:** stz-text-entities-quicker
```

Harvested: `# Intent:` -> intent phrase; fenced `ring` block -> example;
`Methods:` -> links; `Tags:` -> aka. Indexed as `kind: recipe`. Conversational
"how do I ..." queries surface recipes first (intent-shaped, runnable),
methods second. Recipes are the bridge between the prose `quickers/` (great for
reading) and the retrieval engine (needs atomic units).

## 4. Retrieval + conversation engine (already built, now fed richer)

`stzSelfDoc` (one class) and `stzLibDoc` (many classes) already:

- harvest inheritance-aware (own + ancestors, child overrides),
- rank newest-model-first: **reranker** (lexical-narrow -> cross-encode) >
  **embeddings** (bi-encoder cosine) > **lexical** (bag-of-words, zero setup),
- apply an own-method prior so an object's specialized methods beat inherited
  generics on ties.

This strategy changes only the **records** they index -- the engine is
untouched. The union index becomes:

```
methods (all curated classes, inheritance-aware)
  + recipes  (doc/quickers/recipes/**)
  + examples (test/**/*_narrated.ring scenarios)
```

Conversation templates over the record set:

- `Explain(x)`  -> intent + signature + out + example + see-also.
- `Ask("how do I X")` -> top recipes/examples, then methods.
- `Suggest`/`Compare` -> rank + contrast records; follow `see`/`owner` links
  for multi-turn drill-down.

## 5. Rollout -- priority + definition-of-done

Tier the classes by expected query traffic; finish Tier 1 before widening.

- **Tier 1** (touch first): `stzString`, `stzList`, `stzNumber`, `stzText`,
  `stzListOfTexts`, `stzChar`, `stzTable`.
- **Tier 2**: `stzListOfNumbers`, `stzListOfStrings`, `stzDate`, `stzTime`,
  `stzMatrix`, `stzHashList`, `stzTree`, `stzSet`.
- **Tier 3**: everything else, by demand.

**Definition of done, per class:**

1. Organized under section boxes (Layer 0). *[measurable: 100% effective cov.]*
2. Flagship methods (top ~20% by traffic) have an **intent line + `#@ aka`**
   + at least one `#@ eg`.
3. >= ~8-12 **intent recipes** cover the class's common tasks.
4. An **Ask-probe** test (fixed intent->expected-method pairs) passes top-1
   under lexical, guarding the quality as a regression test.

## 6. Metrics + guardrails (quality is measured, not asserted)

- **Coverage %** per class -- harvester-computed (methods with an effective
  description). Already reported by the coverage script.
- **Ask-probe accuracy** -- a narrated suite of `intent -> expected method`
  pairs, asserting top-k under lexical (and, when a model is loaded, neural).
  This makes NL quality a *regression-guarded* number for both paths.
- **Example liveness** -- every harvested test-example provably runs (it is a
  passing test). Recipe examples are periodically executed in CI.
- **No silent truncation** -- when the index caps a class or pool, it is
  logged, never hidden.

## 7. Build order (this initiative)

1. **Foundation** -- `#@` InfoTag parser in the harvester; fold `aka/tags/see`
   into the retrieval text. *(record shape unchanged -> zero engine churn)*
2. **Pilot** -- `#@ aka` on `stzText` flagships; measure lexical Ask lift.
3. **Recipes** -- create `quickers/recipes/`, seed the `stzText` set, add a
   recipe harvester; union them into `stzLibDoc`.
4. **Examples** -- scenario harvester (`Scenario` title + method linkage);
   union into the index.
5. **Ask-probe suite** -- fixed intent->method pairs as a regression test.
6. **Widen** -- repeat 2-5 across Tier 1, then Tier 2/3.

Each step ships independently, is test-gated, and pushes to both remotes.
