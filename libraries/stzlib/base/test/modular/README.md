# Modular thematic tests

Originated from the narrative `*Test.ring` files in `base/test/`.
Each `/*---` narrative block of the originals is extracted into its
own independently-runnable thematic file under `modular/<topic>/`.
Narratives and `#-->` expected-output markers are preserved verbatim;
any drift between the narrative and current runtime is recorded with
a `# RUNTIME <date>:` line directly below the affected expectation.

## Coverage status

| Topic | Source narrative file | Modular dir | Status |
|---|---|---|---|
| counter | `stzCounterTest.ring` | `counter/` | 5 blocks extracted, blocks 1-4 pass, block 5 hangs (task #4) |
| chardata | `stzCharDataTest.ring` | `chardata/` | 4 blocks extracted, 2 pass + 2 drift |
| ... | ~120 more files | -- | pending (task #2) |

## How to run

From each topic dir:

```
D:\Ring126\bin\ring.exe <file>.ring
```

The `pf()` profiler at the end of each block raises a "STOPPED!"
banner on purpose -- that is the Softanza idiom for closing a profiled
run, not a test failure. The actual output to verify is everything
before "STOPPED!".

## Findings surfaced by modularization

1. **`InvisibleUnicodes()` table drift** -- count changed 26->27;
   members shifted (added U+2000..U+200F space variants and
   U+2028/U+2029 separators; dropped U+0020 and U+00AD). Decide
   whether the new set is canonical.
2. **`NumberOfGeneralPunctuationChars()` corrected** -- the narrative
   recorded 111, library now reports 112. The new value reconciles
   with the documented 250 total (= 112 + 138).
3. **`stzCounter.CountTo(N)` perf regression (TASK #4)** -- documented
   timing for N=1M was 0.91s in Ring 1.23; current Ring 1.26 build
   hangs for minutes even at smaller N like 1000. The earlier
   `:AfterYouSkip = 9, :RestartAt = 0` configuration with N=13 runs
   instantly, so the regression is in the `:WhenYouReach / :RestartAt`
   path for large N.

## Unicode restoration

Done alongside this modularization:

- `stzDate.ring` Day/Month tables restored from pristine commit
  271afae9 (French + Arabic display correctly).
- `stzLocale.ring` `$_aDayNamesPerLang` restored from 3d776007.
- 6 files (`stzFuncs`, `stzFile`, `stzFolder`, `stzDiagram`, `stzGraph`,
  `stzStringTest`) keep their long-standing shipping-state mangling.
  No clean git history exists for them and the regression suites pass
  with the mangled bytes as opaque string literals. Tracked as a known
  cosmetic-only debt.

Helper scripts at repo root:
- `_unicode_restore.py` -- safe block-from-git restorer (used here)
- `_fix_unicode_safe.py` -- narrow byte-level reverser for 3-byte
  smart-quote-range mangling
- `_fix_unicode.py` -- comprehensive reverser (works only on
  purely-mangled files)
