# Wave 9 defects: stzStringText, stzStringChecker, stzStringRemover, stzStringReplacer, stzStringCharList

Found by calling every root method with real data (invented text, Hebrew, Arabic, emoji); each was confirmed with a second dataset. Nothing was fixed. Each is recorded as a warning in the doc block of the method.

## stzStringChecker (string/stzStringChecker.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| HasLeadingChars, HasTrailingChars, HasLeadingAndTrailingChars | always 0 | compares two values returned by `StzEngineStringCharAtToString` (engine handles, numbers like 1971) instead of the characters; the stzString method of the same name works | aab, abb, xxyy, aabaa all answer 0; `new stzString("aab").HasLeadingChars()` answers 1 |
| ContainsChar (CS form) | the case flag is ignored | `ContainsCharCS` passes only a code point to `StzEngineStringContainsChar` and never reads `pCaseSensitive`; stzString.ContainsCharCS delegates here | ContainsCharCS("e", 0) on HELLO and ContainsCharCS("a", 0) on ABC answer 0 |

## stzStringRemover (string/stzStringRemover.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| RemoveSection, RemoveRange, SectionRemoved, RangeRemoved | the whole Ring process dies: `panic: integer part of floating point value out of bounds` (stz_string.dll) | a negative length (`n2 - n1 + 1`) reaches `StzEngineStringRemoveRange` | RemoveSection(4,2) on banana split, RemoveSection(3,1) and RemoveRange(2,-1) on plain text |
| RemoveAnyBetweenIB, RemoveAnyBetweenCSIB (and their Removed forms) | same process panic when no pair is found | the section found is [0,0] and widening it by the bound lengths gives a negative range, passed to RemoveSection | RemoveAnyBetweenIB("(", ")") and RemoveAnyBetweenCSIB("<B>", "</B>", 1) |
| RemoveAnyBetweenIB | removes one section from the first opening bound to the LAST closing bound | one section found with FindAnyBetweenAsSection, then removed | f(x) g(y) gives f, where RemoveAnyBetween gives f g |
| RemoveManyCS, RemoveAllOfTheseCS, RemoveTheseCS, ManyRemovedCS | R14 `Calling Method without definition: updatewith` | calls `This.UpdateWith(...)`, a method this class does not have | RemoveManyCS(["A","N"],0), RemoveManyCS(["a","n"],1), RemoveAllOfTheseCS(["a"],1) |
| RemoveNth, NthRemoved (and CS forms) | rank counts from 0 (1 removes the second occurrence); stzString.RemoveNth counts from 1 | the engine `StzEngineStringRemoveNth` is 0-based and is called without adjusting | RemoveNth(1,"one") and RemoveNth(2,"one") on one two one two one remove the 2nd and the 3rd one; RemoveNth(3,"a") on banana split removes nothing |
| RemoveNthCS, RemoveFirstCS, RemoveLastCS, RemoveFromLeftCS, RemoveFromRightCS, RemoveAnyBetweenCS (and the Removed forms) | the case flag is ignored | the CS body calls the engine variant that has no case argument | RemoveFirstCS("AN",0) and RemoveLastCS("AN",0) leave banana split alone; RemoveAnyBetweenCS("<B>","</B>",0) leaves the lower-case pair |
| RemoveAtPosition | removes as many characters as pcSubStr has, whatever they are | only `StzLen(pcSubStr)` is used | RemoveAtPosition(2,"zz") on hello gives hlo |
| RemoveSubStringsExcept, RemoveAllBut, RemoveAllExcept | empties the text (or nearly) | removes in turn every substring of the text that is not in the list, including the substrings that contain a listed one | abc with [b], [abc], [x] give an empty text, abc with [ab, c] gives c, banana split with [a] and [ba] give an empty text |
| init (stzString argument) | after the first edit the stzString passed in reads as an empty text; the remover keeps the right text | probable: the held copy of the stzString shares its engine handle and `Update` frees it (the symptom is observed, the mechanism is not checked) | stzString("keep me") then Remove("e"): original reads empty; same with abc xyz and RemoveSpaces |

## stzStringReplacer (string/stzStringReplacer.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| RemoveFirst (default call) | removes the SECOND occurrence | `RemoveFirstCS` calls `RemoveNthCS(1, ...)`, and the engine nth is 0-based | one two one two one gives one two  two one; Hebrew שלום עולם שלום loses its second שלום; a single occurrence is not removed |
| RemoveLast (default call) | removes nothing | `RemoveLastCS` asks `RemoveNthCS` for rank = number of occurrences, one past the last for a 0-based engine | one two one two one, aaa bbb with a and with b |
| RemoveNth, RemoveNthOccurrence | rank 0-based in the default call, 1-based with the case flag at 0 | `RemoveNthCS(n, s, 1)` uses the engine, `RemoveNthCS(n, s, 0)` falls back to ReplaceNthCS (1-based) | RemoveNth(1,"one") removes the second one, RemoveNthCS(1,"ONE",0) the first |
| ReplaceByMany | wrong result on any text that is not plain ASCII | positions found with Ring `substr`/`lower`/`len` (bytes) are used to slice with the codepoint helpers `StzMid` | שלום עולם שלום gives `אם שלוםב`; a😀b😀c with 1,2 gives a12 (b and c lost); éa éb with é gives `1 é2` |
| init (stzString argument) | Replace edits the stzString passed in place, but ReplaceFirst, Surround and the other Update-based edits leave it reading as an empty text | observed: Replace changes the shared engine string, the others call `Update`; probable: Update frees the shared handle | abc abc with Replace(b,B), ReplaceFirst, Surround |
| ReplaceAt | a count of 0 changes nothing | observed only | hello world, ReplaceAt(7,0,"big ") |

## stzStringCharList (string/stzStringCharList.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Unique | returns a list holding ONE text instead of single characters | probable: `_SplitNullDelimited` finds no NUL separator in the engine answer, as the answer is one text | hello gives [ "helo" ]; Hebrew, emoji and a list given as input behave the same |
| SortAsc, SortDesc, Sort, SortedAsc, SortedDesc (Sorted) | the list is left holding ONE item, the whole sorted text; NumberOfChars answers 1 afterwards | probable: same cause as Unique | hello gives [ "ehllo" ]; ["c","a","b"] gives [ "abc" ] |

## stzStringText (string/stzStringText.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| OnlyScript | R24 `Using uninitialized variable: pcscript` | the anonymous function `func c { ... pcScript ... }` does not see the method parameter | :Latin on English text, :Hebrew on Hebrew, :Arabic on Arabic |
| OnlyArabic, OnlyLatin | R14 `Calling Method without definition: concatenateq` | calls `ConcatenateQ()` on a stzListOfStrings, which has no such method | English, Arabic, mixed text |
| ReverseEachWord | the text ends up empty for any word with non-ASCII characters | probable: the engine reverses bytes, producing invalid UTF-8 (EachWordReversed shows the garbled bytes; the empty text after ReverseEachWord is observed, its mechanism is not checked) | שלום עולם, a😀 b, été vert |
| EachWordReversed | unreadable bytes for any word with non-ASCII characters | same byte reversal | Hebrew, Arabic, emoji, accented words |
| UniqueWords, NumberOfUniqueWords, ContainsWord, ContainsEachWord, WordsU | words keep the punctuation stuck to them, so a word followed by a full stop or a comma is not found | probable: the engine unique-words call splits on blanks, where Words and WordsAndTheirCounts use the Unicode word rules (not checked in the engine) | Hello world. Bye world, ok: ContainsWord("world") answers 0; Arabic مرحبا بالعالم. كيف حالك؟: ContainsWord("بالعالم") answers 0 |
| ToSentenceCase, SentenceCased | only the first letter of the text is capitalized | probable: the engine capitalizes after Unicode sentence breaks, which are not cut before a lower-case letter (not checked in the engine) | one. two. three. gives One. two. three.; it works! really? yes. gives It works! really? yes. |
| CountWordsMatching | counts only words equal to the pattern (punctuation included); a regular expression or wildcard counts 0 | pattern compared as a literal with the blank-separated pieces | [a-z]+, H*, ^again$, o all count 0 |
| Abbreviate | its description said it changes the text in place, but it only returns the shortened copy | the body returns the engine result and never calls Update | the text is unchanged after Abbreviate(10) |
| init (stzString argument) | after the first edit the stzString passed in reads as an empty text | probable: same shared engine handle as the remover | stzString("keep me") then Update, and a b c then ReverseWords |

Not defects, but worth knowing: `Language()` answers NULL until `SetLanguage` is called and nothing in the class reads the language; `IsCapitalcase` answers TRUE for a script without letter case (שלום); `ToSlug` drops every non-ASCII letter instead of transliterating it.
