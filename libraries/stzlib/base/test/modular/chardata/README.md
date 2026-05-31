# Modular character-data tests

Originated from `base/test/stzCharDataTest.ring`. Each `/*---` block
became a runnable thematic file with the narrative preserved.

## Block index

| File | Topic | Pass status |
|---|---|---|
| `01_invisible_unicodes.ring` | InvisibleUnicodes / UnicodesNames | DRIFT (see file) |
| `02_circled_chars_merge.ring` | CircledDigit + CircledLatinLetter merge | PASS |
| `03_punctuation_breakdown.ring` | General / Supplemental punctuation counts | DRIFT (General: 111→112, fixes 111+138 mismatch) |
| `04_unicode_directions.ring` | UnicodeDirectionsXT()[5][3] | PASS |

## Known drift (block 01)

The `_anInvisibleUnicodes` table in
`libraries/stzlib/base/data/stzCharData.ring` (line 969) is now 27
entries instead of the original 26 documented in the narrative. It now
includes U+2000..U+200F space variants and U+2028/U+2029 line/paragraph
separators, but no longer includes U+0020 (regular space) or U+00AD
(soft hyphen). Investigate whether the canonical Unicode invisibility
list should include U+0020 and U+00AD before deciding which side is
authoritative.
