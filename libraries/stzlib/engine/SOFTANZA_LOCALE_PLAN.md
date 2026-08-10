# Locale data belongs in the engine

**Status:** scoped, not started. Written 2026-08-10.

Unicode already made this move: `utf8proc` is vendored under `engine/vendor/`,
and `stzStringChar.ring` carries **no Ring-side Unicode tables at all** — it asks
`StzEngineUnicodeCategory`, `StzEngineStringCharIsMarkAt`, `StzEngineUnicodeBidiClass`.
Locale has not made it. This is the scope.

## What exists today

**Ring side — 4,911 lines, ~1,375 data rows across five files:**

| file | lines | table | rows |
|---|---|---|---|
| `base/data/stzLocaleData.ring` | 1,483 | `_aLocaleAbbreviationsXT` | 495 |
| `base/i18n/stzLocale.ring` | 1,623 | `_aCurrencyISOData` | 143 |
| | | `_aDayNamesPerLang` | 10 |
| | | `_aMonthNamesPerLang` | 10 |
| | | `aDaysOfWeek` | 7 |
| `base/i18n/stzCountry.ring` | 685 | `_aLocaleCountriesXT` | ~261 |
| `base/i18n/stzLanguage.ring` | 617 | `$aLocaleLanguagesXT` | ~323 |
| `base/i18n/stzScript.ring` | 505 | `_aLocaleScriptsXT` | ~143 |

**Engine side — `src/locale.zig`, 236 lines, 10 functions, all C-locale stubs:**

```
stz_locale_am_text      stz_locale_pm_text
stz_locale_to_upper     stz_locale_to_lower     stz_locale_to_titlecase
stz_locale_format_number
stz_locale_month_name   stz_locale_month_abbr
stz_locale_day_name     stz_locale_day_abbr
```

`stz_locale_day_name(dow)` takes a day NUMBER and no locale, reading one
hardcoded English array. There is no locale-aware engine API to delegate to yet
— which is why the Ring tables are still load-bearing, and why two fixes landed
in them this week rather than in their eventual home.

## What that costs today

Both defects fixed this week were data-shape problems that a single owned table
would make structurally impossible:

- `LanguageName()` derived the language from the COUNTRY (`b4226cf38`), because
  language and country live in separate Ring tables with no join.
- 36 of 143 currency rows carried the ISO code in the symbol column
  (`451501ebc`) — a column contract nothing enforced.

And the ten-language day-name table is the visible edge: a "native" day name for
Persian is the English word, because the table stops at ten.

## Phases

**L0 — decide the data source.** CLDR is the obvious answer and the only one
that covers ~500 locales; the question is whether to vendor a subset the way
`utf8proc` was vendored, or generate compact Zig tables from CLDR at build time.
This decision sets everything after it. **Nothing else starts until L0 is
answered.**

**L1 — one table, end to end.** Move `_aCurrencyISOData` (143 rows, the smallest
and the one with a proven column-contract defect) into the engine with a real
API: `stz_locale_currency_symbol(code)`, `_iso_code(locale)`, `_name(code)`.
Ring keeps `stzLocale` as the face and delegates. This proves the seam — bridge,
build, guard shape — on the cheapest table.

**L2 — countries, languages, scripts.** ~727 rows, and the join that
`LanguageName()` needed. One engine-side registry keyed by locale, so
language/country/script stop being three lists a Ring method has to reconcile.

**L3 — day/month names per locale.** The 495-row abbreviation table plus real
per-locale day and month names, retiring `_aDayNamesPerLang` and its
ten-language ceiling. `stz_locale_day_name` grows a locale argument here.

**L4 — retire the Ring tables** and delete `stzLocaleData.ring`.

## Guard rails

- The promises harness (`#-->` expected-outputs) covers `locale/` at 213
  expectations; run it before and after each phase. It moved 66 → 58 → 57 on the
  two fixes so far, and it is a **signal, not a target** — some divergences are
  stale test spellings, not defects.
- Every phase keeps the existing narrated guards green:
  `test/locale/00_locale_narrated.ring`, `01_languagename_narrated.ring`,
  `02_currencysymbol_narrated.ring`.
- Property assertions travel with the data, not the row: "no currency answers
  its own ISO code" caught 36 rows at once and will catch the 37th.
