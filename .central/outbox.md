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
