# Softanza Structured Output — the normative specification

**Contract**: C9 · **Version**: `1.0.0` · **Status**: normative · **Owner**: StzLib
**Home**: `libraries/stzlib/base/neural/SOFTANZA_STRUCTURED_OUTPUT.md`
**Pointer**: `softanza/contracts/C9-structured-output.md` (Central owns the pointer; this file is the contract)
**First published**: 2026-08-22, extracted from working code, not designed ahead of it.

---

## 0. How to read this file, and how to cite it

**A consumer claims conformance against a VERSION OF THIS FILE, never against a
paragraph.** Write `C9 v1.0.0` in your own documentation. That sentence exists because
C2 failed in exactly the other shape: its specification existed, nothing pointed at it,
and a sibling repository truthfully reported conformance against a one-sentence summary
it had found instead. A contract whose normative home is a paragraph invites conformance
claims against a paragraph.

**Everything below was extracted from code that runs**, and every claim names the file it
was read from:

| Layer | File | Lines |
|---|---|---|
| the court (declare, parse, validate, refuse) | `base/neural/stzOutputSchema.ring` | 1,676 |
| the typed call that uses it | `base/neural/stzLLMFunction.ring` | 616 |
| the grammar compiler | `engine/src/schema_gbnf.zig` | 567 |
| the sampler-side stack machine | `engine/src/gbnf_machine.zig` | 1,070 |
| the executable proof | `base/test/neural/structuredoutput_narrated.ring` | 73 assertions |
| the grammar proof | `base/test/neural/schema_grammar_narrated.ring` | 28 assertions |
| the decoding proof | `base/test/neural/constrained_decoding_narrated.ring` | 50 assertions |
| the measurement harness | `base/test/neural/_measure_structured.ring` | — |

**Where this file and the code disagree, the code is right and this file is a defect.**
Report it; do not reconcile by editing the code to match the prose.

---

## 1. What C9 promises, and what it refuses to promise

> **Structure kills malformedness, not falsehood.**

C9 guarantees **integrity**: an answer has the shape it was asked for, **whole**, or there
is no answer at all. It guarantees nothing about truth. `age: 900000` is refused because
900000 is outside a declared band; `age: 41` for a person who is 62 passes every rule in
this specification and is simply false.

A schema-valid lie validates. `structuredoutput_narrated.ring` **Scene 10** lets one
through on purpose, so that this limit is executable rather than implied. Truth needs
reversibility, an auditor and a Principal — which is Bangalo's law 18 read from the other
side, and is not C9's business.

The three things a grammar additionally cannot do, each stated by name in
`gbnf_machine.zig` rather than discovered by a caller:

- **VALUE.** No context-free rule says "between 0 and 130".
- **TRUTH.** `city: Paris` and `city: Tokyo` are equally grammatical.
- **BYTES ABOVE ASCII INSIDE A CHARACTER CLASS.** Masking is over token *bytes*, so
  `[a-z]` is a byte range; a multi-byte character inside `[...]` is **refused by name**
  rather than silently matching one of its bytes. Multi-byte characters inside a
  `"quoted literal"` are fine — they compile to their UTF-8 byte sequence.

---

## 2. The two halves, and why neither retires the other

C9 is **one promise in two halves**. A consumer may implement either, must not claim the
other, and must be able to say which one an answer came through.

| | **The grammar half** | **The court half** |
|---|---|---|
| Where | `schema_gbnf.zig` + `gbnf_machine.zig` | `stzOutputSchema.ring` |
| When | at the sampler, per candidate token | after the model has spoken |
| Effect | a violating token is **never drawn** | a violating answer is **refused whole** |
| Constrains | SHAPE | SHAPE **and** VALUE |
| Answers | `IsDecodingConstrained()` → 1 | always |

**The court does not retire when constrained decoding lands.** It is the half that checks
what a grammar structurally cannot. `UnenforcedByGrammar()` lists, one line per field and
operator, every constraint the emitted grammar does not carry — and dropping one silently
would be the worst outcome available, because the surface above would report
"constrained" while the band went unenforced.

### 2.1 What the second half was worth, measured

Against the model this repository ships (`smollm2-135m-instruct-q8_0`), ten structured
prompts, harness `base/test/neural/_measure_structured.ring`:

| | checked afterwards | constrained at the sampler |
|---|---|---|
| first attempt valid | 2 / 10 | **10 / 10** |
| valid within four attempts | 6 / 10 | **10 / 10** |
| attempts per valid answer | 5.0 | **1.0** |
| never valid at all | 4 / 10 | **0 / 10** |

This is a measurement, not a belief. **The line that must travel with that number**: it
is a shape result. Retries still earn their keep, because a value outside its declared
band is still refused by the court, and a schema-valid lie is still a lie.

---

## 3. The declaration

```ring
oS = StzOutputSchemaQ([
    [ :field = "name", :type = :string ],
    [ :field = "age",  :type = :number, :must = [ [ ">=", 0 ], [ "<=", 130 ] ] ],
    [ :field = "mood", :type = :oneof,  :choices = [ "positive", "negative" ] ],
    [ :field = "tags", :type = :list,   :of = :string, :optional = 1 ]
])
```

### 3.1 The type vocabulary is closed (`StzOutputFieldTypes()`)

`string` · `number` · `boolean` · `oneof` · `list` · `structure`

Aliases normalize (`_StzOutputNormalizeType`), and **only these**:

| canonical | accepted spellings |
|---|---|
| `string` | `string`, `text`, `str` |
| `number` | `number`, `num`, `int`, `integer`, `float`, `decimal` |
| `boolean` | `boolean`, `bool`, `flag` |
| `oneof` | `oneof`, `enum`, `choice` |
| `list` | `list`, `array`, `listof` |
| `structure` | `structure`, `struct`, `object`, `record` |

Anything else **raises at declaration time**. A typed declaration that silently never
matches is the failure this whole layer exists to prevent.

### 3.2 The field keys are closed (`_StzOutputFieldKeys()`)

`field` · `name` · `type` · `required` · `optional` · `choices` · `oneof` · `of` ·
`fields` · `must` · `note` · `description`

Anything else raises. `:requird = 0`, quietly leaving a field required, is precisely the
class of typo a court must not tolerate **in its own law**.

### 3.3 Operators are stzGraphRule's, and are checked per type

The operator vocabulary is **borrowed, not reinvented**: it is `stzGraphRule`'s, normalized
by the same `_StzGraphRuleNormalizeOp()` — `equals`, `not-equals`, `contains`,
`greaterthan`, `lessthan`, `greaterequal`, `lessequal`. A typo raises at **declaration**
time rather than never matching at run time.

Which operators mean anything on which type (`_StzOutputOpsFor`):

| type | permitted operators |
|---|---|
| `number` | equals, not-equals, greaterthan, lessthan, greaterequal, lessequal |
| `string` | equals, not-equals, contains |
| `boolean` | equals, not-equals |
| `oneof` | equals, not-equals |
| `list` | equals, not-equals, contains, greaterthan, lessthan, greaterequal, lessequal |
| `structure` | *(none)* |

**On a `:list`, a comparison operator constrains ELEMENT COUNT** (`[ [ ">=", 1 ] ]` reads
"at least one element") and `contains` is **membership**. Both readings are stated in
every refusal message, so no reader has to remember which it was.

Declaring a constraint that cannot apply is a **declaration defect**, not a runtime miss.

### 3.4 The declaration is judged when it is DECLARED

An unknown type, an unknown key, a `oneof` with no choices, a `must` operator that cannot
apply — each raises **before any model is ever called**
(`structuredoutput_narrated.ring` Scene 1).

---

## 4. Reading what the model actually said

`StzParseModelOutput(cRaw)` → `[ :ok, :value, :shape, :why ]`

**Two shapes are understood, and nothing else is guessed at:**

- **`json`** — the first *balanced* `{ … }` span found anywhere in the reply, so a model
  that wraps its answer in prose or a ` ```json ` fence is still readable. Quotes and
  backslash escapes are respected while balancing. Parsed by the **house** parser
  (`JsonToList`), never a second one written for this layer.
- **`memo`** — the yaml-like shape this project writes its own memos in: `key: value`
  lines, a bare `key:` opening an indented block, `- ` opening a list item. **Values stay
  STRINGS**; the field's declared type decides how to read them, which is why `"true"` for
  a `:string` field stays `"true"` instead of becoming `1`.

**Fences**: when the reply contains a fence pair, only what is inside the FIRST one
survives; a language tag after the opening fence is skipped.

Anything else is a **parse refusal carrying a reason** — never a partial list of whatever
could be scavenged.

*Implementation note, normative for any re-implementation*: the balanced-span scan walks
BYTES on purpose and is safe to, because the delimiters are ASCII and no byte of a UTF-8
multibyte sequence can be mistaken for one. The span is rebuilt by appending the bytes it
spans, so no byte-oriented `substr()` is ever taken across it.

---

## 5. Validation — the five rules a consumer must implement

**R1 — PARTIAL CREDIT IS FORBIDDEN.** One missing required field refuses the whole
structure. There is no "mostly valid" return. (Scene 4.)

**R2 — A REPRESENTABLE SCALAR IS COERCED; NOTHING IS GUESSED.** The string `"36"`
satisfies a `:number` field and comes back as the number `36`. The string `"old"` does
not, and is refused. **A closed enumeration is CLOSED**: unlike the scalar
`ReturnsOneOf()` path — which accepts a unique containment — a `:oneof` field must match a
choice **exactly**, after trim and case folding.

**R3 — A REQUIRED FIELD THAT IS PRESENT BUT EMPTY IS MISSING.** The model did not answer
it. Optional fields may be empty.

**R4 — THE VALIDATED VALUE IS THE DECLARED SHAPE.** Declared fields, in **declared
order**, whatever order the model wrote them in.

**R5 — UNDECLARED FIELDS ARE REPORTED AND DROPPED.** As *warnings*, so they do not refuse.
`RefuseUnknownFields()` promotes them to errors — which is what "a closed language" means
when you want it strictly. `AllowUnknownFields()` restores the default.

**Nesting is supported by the court**: structures inside structures, and lists of
structures, compile recursively and validate with dotted paths (Scene 5). *The grammar
half does not support it* — see §6.2.

---

## 6. The grammar half

### 6.1 Emission (`stz_gbnf_compile`)

The compiler emits a **line-oriented** GBNF: one rule per field, in declared order,
optional fields marked `?` in `root`. This is the real output of `ToGBNF()` on the §3
declaration, run on Ring 1.27 — not a sketch of it:

```
root ::= name-line age-line mood-line tags-line?
name-line ::= "name: " text "\n"
age-line ::= "age: " number "\n"
mood-line ::= "mood: " ("positive" | "negative") "\n"
tags-line ::= "tags:\n" ("  - " text "\n")*
text ::= [^\n]+
number ::= "-"? [0-9]+ ("." [0-9]+)?
boolean ::= ("yes" | "no" | "true" | "false")
```

A required `:list` emits `(…)+`; an optional one emits `(…)*`.

### 6.2 What the compiler REFUSES, by name

Every capacity and every inexpressible construct refuses with a named code rather than
truncating or approximating:

| code | meaning |
|---|---|
| `RC_OK` (0) | compiled |
| `RC_FULL` (−1) | more than 64 fields |
| `RC_NO_FIELDS` (−2) | nothing was declared; there is no grammar to emit |
| `RC_BAD_TYPE` (−3) | field type outside the vocabulary |
| `RC_NO_CHOICES` (−4) | a `oneof` with no choices |
| `RC_NESTED` (−5) | **a nested structure** |
| `RC_OVERFLOW` (−6) | emitted grammar over 8,192 bytes |
| `RC_BAD_NAME` (−7) | a field name the grammar cannot carry |

**`RC_NESTED` is deliberate and normative.** Nested structures are **refused rather than
flattened**: a grammar that accepted what the schema rejects would put the two halves into
disagreement, and disagreement between the halves is the one failure C9 has no answer for.
`IsExpressibleAsGrammar()` answers this without raising.

Capacities (`schema_gbnf.zig`): 64 fields, 64-byte names, 512-byte choice list, 8,192-byte
grammar, 512-byte diagnostic, 1,024-byte unenforced report.

### 6.3 The unenforced report is MANDATORY

`stz_gbnf_unenforced()` / `UnenforcedByGrammar()` lists, one line per field per operator:

```
age: 'greaterequal' is NOT enforced by the grammar (a grammar constrains shape, never value) -- the Ring court still checks it.
age: 'lessequal' is NOT enforced by the grammar (a grammar constrains shape, never value) -- the Ring court still checks it.
```

Note the operator is named in its **normalized** form (`greaterequal`), not the `>=` the
declaration was written with — the report speaks the same vocabulary the declaration was
compiled into, which is `stzGraphRule`'s.

**Empty means the grammar carries everything the declaration asked for.** A consumer that
reports an answer as "grammar-constrained" without also being able to produce this list is
not conforming.

### 6.4 Honest reporting of which rung you got

`stz_gbnf_decoding_supported()` / `IsDecodingConstrained()` answers whether anything
actually **constrains decoding** with this grammar — as opposed to merely compiling one.
It answered `0` for as long as that was true, and **that was the point of it**. It answers
`1` since `gbnf_machine.zig` landed (2026-08-20), because the rung underneath it exists —
not because a grammar exists, which was never the same claim.

`DecodingStatus()` returns the prose form of the same answer, including its limits.

---

## 7. The sampler-side machine (`gbnf_machine.zig`)

A pushdown machine over the parsed grammar, holding a **set** of stacks rather than one —
an alternation is genuinely several live positions at once, and a candidate is legal if
**any** of them survives it.

**The one question it answers per candidate token**: *if I emitted this token, could the
grammar still be satisfied?*

### 7.1 The case a naive implementation gets wrong — normative

**A token is not a byte.** Given `root ::= "yes" "\n"`, the vocabulary token `yesterday`
starts with three bytes the grammar accepts and dies on the fourth. A check that asked
only whether the FIRST byte is acceptable would emit it and produce `yesterday`, which the
grammar forbids.

**A candidate is accepted only if EVERY ONE of its bytes is consumed**: the machine is
cloned, fed the whole piece, and the clone must still be alive at the end. There is a unit
test named for exactly this case at the bottom of `gbnf_machine.zig`, and any
re-implementation owes the same test.

### 7.2 End of generation

**End-of-generation is legal only where the grammar is satisfied** (`stz_grammar_can_end`).
A model may not stop mid-structure.

### 7.3 Refusals at parse time

| code | meaning |
|---|---|
| `RC_SYNTAX` (−1) | the grammar text does not parse |
| `RC_FULL` (−2) | a capacity was reached |
| `RC_UNDEFINED` (−3) | a rule reference with no rule |
| `RC_NO_ROOT` (−4) | no `root` rule |
| `RC_NONASCII_CLASS` (−5) | a multi-byte character inside `[...]` |
| `RC_LEFT_RECURSION` (−6) | `a ::= a "x"` — refused by name rather than hanging |

Capacities: 8,192 elements, 128 rules, 12 group depth, 192 live stacks, 48 stack depth,
96 advance depth. Every one of them **refuses by name rather than truncating**.

The element encoding and the advance/match algorithm follow llama.cpp's grammar sampler,
which is the reference implementation of GBNF. **Nothing is vendored** — this repository
holds raw ggml, not llama.cpp — so the machine is ours, and so is every bound in it.

### 7.4 Installing a grammar

```ring
StzGenerateXT(cPrompt, [ :Grammar = oSchema.ToGBNF() ])
```

---

## 8. The finding shape — C9 joins the house CI gate

Every verdict is reported in the **family's unified rule shape**, unchanged:

```ring
[ :rule, :subject, :where, :severity, :message ]
```

- `:subject` is always `"structured-output"`.
- `:where` is the field **path** — `"author.name"`, `"tags[2]"`.
- `:severity` is `error` (refuses) or `warning` (does not).

A schema verdict therefore hands straight to `stzRuleReport.Ingest()` and stands in the
**same CI gate** as the code, agent, graph, org and security rules — one gate, six domains.
(Scene 6 proves the handoff.)

`CiteFindings(aFindings)` renders them for a human. **Every refusal names the rule that
produced it** — LAW 3, and the court manner of this whole family.

---

## 9. The typed call (`stzLLMFunction`)

The consumer-facing surface. C9 governs the `ReturnsStructure()` path.

```ring
oF = new stzLLMFunction("read-ticket")
oF.SetPrompt("Read this support ticket: {input}")
oF.ReturnsStructure([
    [ :field = "summary",  :type = :string ],
    [ :field = "severity", :type = :oneof, :choices = [ "low", "high" ] ],
    [ :field = "hours",    :type = :number, :must = [ [ ">=", 0 ] ] ],
    [ :field = "tags",     :type = :list, :of = :string, :optional = 1 ]
])
oF.Budget(3)
aTicket = oF.Call_(cText)      # the DECLARED shape, or a refusal
```

Normative behaviour of the call:

- **BUDGET IS MANDATORY.** `Budget(n)` must be set; exhaustion is a **refusal**, never a
  silent partial answer and never a silent spend. Retries happen **inside the same
  budget**. (Scene 7.)
- **MEMOIZED BY CONTENT HASH** (engine sha256): the second identical call is deterministic
  and free — determinism-by-cache.
- **ZERO CAPABILITIES.** This object maps input text to a typed value. Effects belong to
  pi-gates; never here.
- **A SEED IS JUDGED LIKE A GENERATED ANSWER.** `SeedAnswer()` does not bypass the court.
  (Scene 8.)
- **GOLDEN SETS.** `AddGolden` / `RunGoldens` pin regressions, structures included.
  (Scene 9.)
- **HONEST ABOUT WHICH RUNG IT USED.** `IsConstrainingDecoding()`,
  `WasLastAnswerConstrained()`, `GrammarUsed()`, and `WhyNotConstrained()` — which names
  *which* of the three reasons applies: a declaration a grammar cannot express (a nested
  structure), `ConstrainDecoding(0)`, or a build without the sampler rung.

### 9.1 The prompt clause is a measurement, not taste

`PromptClause()` emits exactly:

```
Answer with ONLY this structure, one field per line, nothing before it and nothing after it:
```

followed by the shape lines. **Do not add instructions here without re-running
`base/test/neural/_measure_structured.ring`.** Prose aimed at the observed failures — "do
not explain the structure", "replace every `<…>` with a real value" — took the score to
**0/10**: a small model told not to explain explained more, and the negation was the thing
it echoed. It was reverted on the measurement. *Taste is not evidence.*

---

## 10. Conformance — what a consumer owes

A consumer claiming **C9 v1.0.0** owes all of the following. Anything less is a partial
claim and must say which clauses it meets.

1. **Declare the structure**, and let the declaration be judged **at declaration time** —
   an unknown type, an unknown key, or a `oneof` with no choices is refused before any
   model is called (§3.4).
2. **Validate the whole.** Partial credit is forbidden. A structure missing one required
   field is refused entire, citing **field, path and rule** (§5 R1, §8).
3. **Refuse, never scavenge.** An unreadable reply is a refusal carrying a reason, not a
   partial list of whatever parsed (§4).
4. **Report which rung the answer came through.** If you claim constrained decoding, you
   must also be able to produce the **unenforced list** (§6.3, §6.4).
5. **Refuse what you cannot express, by name.** Never flatten, never approximate, never
   truncate silently (§6.2, §7.3).
6. **Keep the finding shape.** `[ :rule, :subject, :where, :severity, :message ]`, subject
   `"structured-output"` (§8).
7. **Budget every call**, and refuse on exhaustion (§9).
8. **Carry the limit sentence.** Wherever you publish the improvement number, publish
   *structure kills malformedness, not falsehood* beside it (§1, §2.1).
9. **Cite the version.** Name `C9 v1.0.0` and this file's path in your own documentation
   (§0).

---

## 11. Versioning

| Version | Date | Change |
|---|---|---|
| `1.0.0` | 2026-08-22 | First publication. Extracted from working code at `stzOutputSchema.ring` (1,676 lines), `stzLLMFunction.ring` (616), `schema_gbnf.zig` (567), `gbnf_machine.zig` (1,070), proven by 151 assertions across three narrated guards, all green on Ring 1.27. |

**The version moves when the vocabulary moves.** A new field type, a new operator, a new
accepted wire shape, a change to any refusal's meaning, or a change to what conformance
requires — each is a version bump. Widening what is *accepted* is a minor bump; narrowing
it, or changing a refusal, is a major one.

The `pia: 1`-style discipline applies here too: a consumer that pins a version this build
does not know should **refuse rather than guess**.
