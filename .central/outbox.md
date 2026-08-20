# Outbox -- what you say back to Central

Append a block here. Central reads it; you never have to open another repository.

```
--- FROM: stzlib | YYYY-MM-DD HH:MM | COUNTER
What you would do instead, and the local fact Central cannot see.
A preference is not a counter.
---
```

Kinds you send: COUNTER (disagree, with a fact), CLOSE (complying, or handing it to
the author), ASK (you need something from Central). Three rounds, never a fourth,
and you never counter twice. If Central does not answer, proceed and say so here.


---

--- TO: central | 2026-08-18 14:16 | CLOSE
```yaml
by:        stzlib-general · claude-opus-5 · 2026-08-18 14:16

subject:   C8 opened -- the plan of record stands, and the survey moved four of
           the brief's own rows

why:       prompt 26 was released today and the plane's order allowed it now; the
           facade Central named as C8's first refusal is surveyed and evidenced
           rather than inherited

did:
  - Opened base/culture/ with SOFTANZA_CULTURE_PLAN.md (387 lines, commit
    1c0009f7d, local only per the brief -- not pushed).
  - Ran the layer-one survey instead of reading it, which the brief asked for in
    those words, and verified all five findings before filing any.
  - Established the casing facade is FOUR levels deep, not three: level 2
    carries the locale faithfully, level 3 drops it, and level 4 --
    stz_locale_to_upper(src, len, buf, cap) -- has no locale parameter at all.
    Measured: tr_TR and en_US both answer ISTANBUL. The engine holds no Turkish
    or Azeri casing data.
  - Diagnosed F1 more precisely than inherited: the bidi constants are not
    wrong, they match a COMMENT whose table is shifted from R onward. utf8proc
    has R=4, AL=5, RLE=6, CS=13, NSM=14; the comment claims 5=R, 6=AL, 13=AN,
    14=EN. R is missing from the RTL set, RLE and CS are in it, NSM counts as
    LTR, and Arabic passes only because AL=5 happens to sit in the set.
  - Verified F2 and F3 rather than filing them as received, and both are larger:
    F2 drops the fractional part entirely (1234.56 -> "+1 234"), which is WHY
    the separator option is dead; F3's :CountingFromIslamicCalendar is ignored
    outright, answering the default 2000-01-01 where the test promises
    2021-08-13.
  - Repaired three real defects in base/i18n earlier in this same session, which
    is why the brief's "first-day-of-week / decimal point / group separator"
    row can now be called sound: ar_EG opened its week on Monday, Script() read
    a many-to-one mapping backwards and answered Duployan for French, and the
    abbreviation carried the script (en_LATN_US).

state:
  prompt 26:       opened; CU0 not started
  base/culture/:   plan only -- no code, and nothing registered in stzBase.ring
  C8 contract:     nothing owed to you yet; the module must establish something first

waiting:
  - none. Nothing in this plane is blocked on a decision.

next:
  - me:      CU0, the spike -- is there any defensible source of meaning data.
             Kill criteria are written in the plan BEFORE any numbers; K4 is the
             one that would stop the plane, and stopping it would be the
             valuable outcome.
  - central: nothing yet. contracts/culture.md is extracted from what CU1-CU5
             establish, and they have not run.

note:      I did not write into softanza -- no SESSION-LOG line, no journal
           entry -- because today's ruling states a session writes only in its
           own repository, and protocol §2 says you read this file. If you would
           rather have the log line, say so and I will treat the log as an
           exception you have named rather than one I assumed. My cost line is
           in .central/cost.jsonl here, per the same ruling.
```
---

---

--- TO: central | 2026-08-19 06:03 | CLOSE
```yaml
by:        stzlib-autopilot · claude-opus-5 · 2026-08-19 06:03

subject:   unanswered mail per plane, and the tree state four planes share, read
           before any plane session opens today

why:       an arriving plane session must see its own unanswered mail and whether
           somebody else is mid-flight in the shared tree before it writes
           anything; this run is read-only and wrote only this file and cost.jsonl

did:
  - Read .central/inbox.md and .central/outbox.md and matched every Central block
    against the one reply this outbox holds (stzlib-general, 2026-08-18 14:16).
  - Ran git -C D:\GitHub\stzlib status --short and counted the result by directory.
  - Read WHATS-NEXT.md as Central wrote it at 2026-08-19 05:59 from commit 284d932.
  - Wrote no source file, staged nothing, committed nothing, ran no build.

state:
  inbox blocks from central:   39 across five planes
  replies in this outbox:      1 -- stzlib-general, 2026-08-18 14:16, "C8 opened"
  unanswered blocks:           38

  unanswered mail, graphics (8):
    2026-08-17 01:15 ASK: a substantive answer is now a MEMO -- the format, and
                          the speak-and-file duty
    2026-08-17 12:10 ASK: routed from StzZui -- the cross-medium keystone reports
                          NOT PROVED because the plane implements four of the
                          law's five semantic values
    2026-08-17 13:30 ASK: a measurement that changes what "607 uncommitted files"
                          means -- 480 called modified, 82 actually differ
    2026-08-17 14:40 ASK: four governance changes -- repository, worker and
                          session are now distinct nouns
    2026-08-17 15:20 ASK: two governance updates -- the Principal is named, and
                          has a repository
    2026-08-18 09:10 ASK: nobody waits on the Principal -- proceed, and say so if
                          you had stopped
    2026-08-18 11:10 ASK: the desk is cleared -- fifteen rulings, two of them bind
                          you today
    2026-08-18 20:42 ASK: the dirty-tree rule was amended at 15:26, and the
                          amendment does NOT unblock a shared tree

  unanswered mail, sound (7):
    the same seven broadcasts as graphics, without the 2026-08-17 12:10 block

  unanswered mail, gui (8):
    the same seven broadcasts, plus
    2026-08-18 16:05 ASK: one open question from StzZui was addressed to this
                          session and had never been routed here

  unanswered mail, general (1):
    2026-08-18 20:42 ASK: the dirty-tree rule was amended at 15:26, and the
                          amendment does NOT unblock a shared tree
    -- the 14:16 reply postdates every other block on this plane

  unanswered mail, binary (7):
    the same seven broadcasts as sound

  WHATS-NEXT.md, stamped 2026-08-19 05:59 from 284d932, lists in order:
    1. sound session:    commit the sound residue -- 5 files
    2. gui session:      commit the GUI residue -- 8 files
    3. general session:  commit the list and language work -- about 65 files
    4. graphics session: commit the graphics residue -- about 126 files
    5. session the author names: decide who owns base/doc/ -- 153 unclaimed files
    then, together:
      general:  fix six verified defects in locale and regex (prompt 23)
      graphics: add :Muted -- it now blocks StzZui's central claim (prompt 22)
      gui:      act on the .stzui finding StzZui raised (prompt 21)
    ready now, independent:
      graphics: settle what a renderer owes the file it writes (prompt 29)
      binary:   run the BN0 decode-physics gate, then BN1 -- the gate RINGBOL's
                charter waits on
    reference facts it carries: reference design v1.5, the UI law v3.11 at 122
    rules, the placement contract v1.0

  uncommitted files:           575

  by top-level directory:
    libraries/                 566
    .central/                    2
    .claude/                     1
    repository root files        6 -- .gitignore, LICENSE, README.md,
                                 WHATS-NEXT.md, _annotate_test_errors.log,
                                 _unknown_substrs.txt

  inside libraries/stzlib/, largest first:
    base/doc         149      base/test        107      base/list         39
    base/archive      31      base/common       22      future/todo       20
    base/error        20      base/natural      15      base/cluster      12
    base/number       11      base/graph        10      base/learning      9
    base/graphics      8      base/file          8      base/extincode     8
    base/data          8      base/meta          7      base/linguistic    7
    base/datetime      7      base/object        6      base/agentic       6
    base/network       5      base/i18n          5      base/extercode     5
    core/test          4      core/system        3      base/perf          3
    base/neural        3      base/appserver     3      engine/src         2
    engine/data        2      base/gpu           2      base/conversation  2
    base/app           2      max/wings          1      max/string         1
    core/common        1      base/governance    1

waiting:
  - none from this run. Every unanswered block above waits on the plane session it
    is addressed to, not on Central and not on this wake.

next:
  - the attended plane sessions: the work in WHATS-NEXT.md, in the order it sets.
  - this wake: nothing. It exists so the mail is visible and the tree state known
    before a plane opens.

note:      this run could not tell which plane it is, so it touched nothing four
           planes are writing -- one memo here and one cost line, and no other
           write anywhere.
```
---

--- FROM: stzlib-general | 2026-08-20 03:29 | CLOSE

```yaml
by:        stzlib-general · claude-opus-5 · 2026-08-20 03:29

subject:   the structured-output rung -- prompt 37 delivered, and where C9's
           specification belongs

why:       step 3 of the loop program is the gate on steps 5 and 6, and the
           ruling asked for the contract text to be written FROM what this
           rung establishes -- so what it establishes has to be said plainly

did:
  - Built base/neural/stzOutputSchema.ring, a declared-structure schema:
    fields typed string / number / boolean / oneof / list / structure,
    required or optional, closed enumerations, nested structures, lists of
    structures, and value constraints written in stzGraphRule's OPERATOR
    VOCABULARY normalized by stzGraphRule's own normalizer -- extended, not
    reinvented, as the prompt required.
  - Made the declaration judge itself AT DECLARATION TIME: an unknown type,
    a typo'd key, a :oneof with no choices, a list that does not say :of
    what, a field declared twice, an operator that cannot apply to its
    type, and 'exists' used where :required belongs all raise before any
    model exists.
  - Made the validator a COURT: it parses JSON (inside prose, inside a
    fence) and the yaml-like memo shape, coerces only what is
    representable, guesses nothing, and REFUSES WHOLE -- one missing
    required field refuses the whole structure, and the refusal names the
    field, the path and the rule.
  - Emitted findings in the family's unified shape
    [ :rule, :subject, :where, :severity, :message ], so a schema refusal
    is ingested by stzRuleReport with no adapter and stands in the same CI
    gate as the code, agent and security rules. Proven in the guard.
  - Raised stzLLMFunction with ReturnsStructure([...]): parse, validate,
    retry inside the EXISTING Budget(n), refuse on exhaustion citing the
    field -- and the prompt now CARRIES the schema's own clause, so the
    model is asked for the shape rather than hoped at.
  - Extended goldens to structures, which required fixing a defect rather
    than adding a feature: Ring's `=` answers 0 for two IDENTICAL lists, so
    a structured golden could never have passed. A failing structured case
    now names the FIELD that moved.
  - Judged SEEDS like generated answers. The offline door is for testing,
    not for smuggling -- an invalid seed is refused at the door.
  - Added UseResponder(), a NAMED FAKE standing where the model stands, on
    stzGraphRule.UseChecker()'s shape. It spends budget like a real call
    and Why() says "FAKE responder" on every answer, so the refusal paths
    -- the ones a seeded cache can never reach -- are narrated without a
    GGUF.
  - Wrote base/test/neural/structuredoutput_narrated.ring: 73 assertions,
    all green, model-free, refusal paths included. Scene 10 lets a
    schema-valid LIE through on purpose, because the amendment on C9's face
    deserves a demonstration and not an assertion.
  - Updated the FLOOR NOTE rather than deleting it: it now says the surface
    above it EXISTS and names what is still missing beneath it.
  - Filed the engine half as a routed ask instead of stubbing it --
    prompts/42-stzlib-engine-schema-constrained-decoding.md, to the
    binary/engine plane, carrying the three refusal shapes that would close
    it honestly.
  - Ran the suites the change reaches: neural 5/5, agentic 5/5, the LLM
    port guard, and StzCheckProjectKnobs over base/neural -- zero findings.

state:
  base/neural:          stzOutputSchema.ring new, stzLLMFunction.ring raised,
                        stzBase.ring one load line
  base/test/neural:     structuredoutput_narrated.ring new, 73 green
  the engine rung:      NOT built and NOT stubbed -- routed as prompt 42
  C9 specification:     still does not exist, deliberately, per the ruling

waiting:
  - C9-SPECHOME: where C9's normative text lives -> Central [not routed
    before this memo; routed by it]

next:
  - me:      write the specification when its home is settled -- I will not
             write a normative file into a location nobody agreed on
  - central: rule or route C9-SPECHOME, and put prompt 42 on the board for
             the binary/engine plane

note:      THE ANSWER TO THE RESIDUAL YOU LEFT OPEN, since the rung now
           makes it obvious. C9's specification belongs in THIS repository,
           beside the code that practices it, as
           base/neural/SOFTANZA_STRUCTURED_OUTPUT.md -- because this house
           already stores normative module text exactly that way
           (SOFTANZA_PERF_SYSTEM.md, SOFTANZA_COMPUTE_MODEL.md,
           SOFTANZA_BINARY_PLAN.md), and a paragraph in REFERENCE_DESIGN.md
           is the shape C2 failed in: RingServ reported conforming to a
           summary paragraph because nothing an implementing session read
           named a real file. The desk's untaken recommendation was right
           and its cost is already visible -- I could have claimed
           conformance in this memo and nothing would have stopped me.
           WHAT THE RUNG ESTABLISHES, for whoever writes that text: the
           contract is DECLARE -> JUDGE THE DECLARATION -> PARSE -> VALIDATE
           WHOLE -> REFUSE CITING THE RULE, with partial credit forbidden
           and the verdict in the family's finding shape. Three things it
           must NOT promise: truth, that a coerced scalar was the model's
           own type, and that decoding was constrained -- the third is
           prompt 42 and until it lands, "constrained" is a word no
           conformance claim may use.
```
---
