# Wave 13 (agent w13a) defects: stzStringCrypto, stzStringComparator, stzStringFinder, stzStringInserter, stzStringLines, stzTextStream, stzListFinder, stzTree, stzTimex, stzListex, stzNumBuffer, stzPCA

Found by calling every root method with real data (invented text and keys, Hebrew, Arabic, emoji, small tables); each was confirmed with a second dataset or a second call. Nothing was fixed. Each is recorded as a warning in the doc block of the method. The strings in the evidence column are exactly what the call returned.

## stzStringCrypto (string/stzStringCrypto.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| IsEncrypted | TRUE for almost any text | `Entropy()` returns hundredths of a bit (abc gives 158) and `IsEncrypted` compares it with 4 as if it were bits | ab (100), abab (100), abcdef (258), a plain sentence (387) and a SHA-256 hex text (386) all answer 1; only aaaa (0) and an empty text answer 0 |
| init (stzString argument) | the first in-place edit leaves the stzString passed in reading as an empty text; the helper keeps the right text | not checked (same symptom as stzStringRemover) | ROT13 and Atbash on keep me, both times |
| HmacSha256, XorEncrypt, VigenereEncrypted | an empty key returns an empty text | not checked | `HmacSha256("")`, `XorEncrypt("")`, `VigenereEncrypted("")` on Hello |

Checked and correct against published vectors: Sha256(abc) = ba7816bf..., Md5(abc) = 900150983cd24fb0d6963f7d28e17f72, Blake3(abc) = 6437b3ac..., HmacSha256(abc, key) equal to Python hmac, Hash(abc) = FNV-1a 64 (16654208175385433931 exact, 16654208175385434112 as the double returned), Vigenere ATTACKATDAWN/LEMON = LXFOPVEFRNHR.

## stzStringComparator (string/stzStringComparator.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| IsEqualTo, Compare (and kin) | a number instead of a text ends the Ring process with no message (exit code 1) | not checked | `IsEqualTo(5)`, `Compare(5)` |
| CommonCharsWith, CommonalityWith, DiffCharsWith (case-sensitive form) | work on bytes: cut multibyte characters, lose them or count bytes | the case-sensitive path of the engine call is byte-wise; the CS 0 form is right | עולם against עיר: CommonCharsWith empty, CommonalityWith 2 (CS 0 gives ע and 1), DiffCharsWith three broken characters (CS 0 gives ולם); a😀b😀 against a😀c😀: CommonCharsWith gives a, CS 0 gives a😀; Arabic مرحبا بك against مرحبا: CommonCharsWith empty, CommonalityWith 7 |
| LongestCommonPrefixWith (case-sensitive form) | ends with half a character | byte-wise common prefix | עולם against עיר gives ע plus a lone byte, where CommonPrefixWith gives ע |
| Soundex, Metaphone | non-Latin text gives a broken code (a lone byte followed by 000) or an empty text | only Latin letters are coded | שלום and مرحبا بك |
| JaroSimilarityWith, JaroDistanceWith, JaroWinklerDistanceWith | the Distance names are the same call as the Similarity: 1000 means identical | aliases | MARTHA against MARHTA: 944 for both Jaro names, 960 for both Jaro-Winkler names (the published Jaro-Winkler value is 0.961) |

## stzStringFinder (string/stzStringFinder.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| IndexOf versus FindFirst, FindLast | an absent fragment answers -1 for IndexOf and 0 for the others; FindNth answers -1 for a bad rank and 0 for an absent fragment | three conventions | banana split with zz: IndexOf -1, FindFirst 0, FindLast 0; FindNth(9, an) -1, FindNth(1, zz) 0 |
| FindCharsWCS, FindSubStringsWCS | the case flag is ignored | the flag is never read | aAbAB with `@substring = 'A'`: [ 2, 4 ] for 0 and for 1; `@char = 'a'`: [ 1 ] for both |
| FindBetweenAsSection | with the closing bound before the opening one it returns a meaningless section | the two ends are swapped when out of order | c then a on abc gives [ 0, 4 ]; greedy by design: f(x) g(y) h(z) gives [ 3, 13 ] |
| FindFirstRegex | an invalid pattern answers 0 with no message | the engine returns no match | `(` |

## stzStringInserter (string/stzStringInserter.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| InsertAfterFirst, InsertAfterLast, InsertAfterNth (and Inserted forms) | when the fragment or the rank is absent the new fragment lands in a wrong place | the position found is 0 (or -1) and `pos + len(fragment) - 1` is used as a position | banana: InsertedAfterFirst(z, -) gives -banana, (zz, -) gives b-anana, InsertedAfterNth(9, an, -) gives -banana, InsertedAfterLast(zz, -) gives b-anana |
| InsertAfterManyPositions, InsertBeforeManyPositions | raise R13 Object is required for every valid list | probably `new stzList(panPos).SortedInDescending()` chained on `new` (the same call in two statements works) | [1,3,5] on banana, [2] on abc, both verbs |
| InsertSubStringBetweenPositions (InsertBetween, InsertBetweenPositions) | the second position is never used to place the fragment | the fragment goes after the smaller position | banana with - and (2,5) gives ba-nana, (5,2) gives the same, (1,6) gives b-anana |
| InsertSubStringBetweenSubStrings (InsertBetweenSubStrings) | replaces the text between the bounds instead of inserting | `ReplaceSections` is used on the found sections | f(x) g(y) with - between ( and ) gives f(-) g(-); [a] [b] gives [-] [-] |

## stzStringLines (string/stzStringLines.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| NumberOfEmptyLines | not a count of blank lines | `NumberOfLines() - len(EmptyLinesRemoved())` subtracts the length in characters of a text from a line count | a and b on two lines give -1; a, empty, b, empty, empty give 2 (3 are empty); xx then a final line feed gives 0 (1 is empty) |
| init (stzString argument) | the first in-place edit leaves the stzString passed in empty | not checked | ReverseLinesOrder on x then y |
| Lines | a CRLF text keeps the CR at the end of each line; an empty text answers [ "" ] while NumberOfLines answers 0 | split at the line feed only | a CR LF bb gives a first line of length 2 |

## stzTextStream (string/stzTextStream.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init | raises R11 class not found: qtextstream unless `load "guilib.ring"` came first | the class wraps RingQt and stzlib does not load it | plain `new stzTextStream()` |
| SetFromFile | raises R20 extra number of parameters | calls `new stzFile(pcFile, :WriteToEnd)` and stzFile.init takes one parameter | a scratch file, twice |
| SetEncoding | raises Bad parameter type! for a name | the QTextStream call wants a QTextCodec object | UTF-8, utf8, ISO-8859-1 |
| SetLocale | ends the Ring process with exit code 1 and no message | the QTextStream call wants a QLocale object | "C" and 1 |
| SetStatus | answers 1 and changes nothing; an unknown name raises R3 stztextstreamerror | the computed `n` is never applied; the error function does not exist | SetStatus(:ReadPastEnd) then Status gives ok |
| IsSetFromFile, IsSetFromSocket | never TRUE | the setter writes `_bSetFromFile_` and `_bSetFromSocket_`, the getters read `_bIsSetFromFile_` and `_bIsSetFromSocket_` | after SetFromScocket: IsSetFromSocket 0 while SourceOfStream gives socket |
| IsSetFromProcess | raises R24 Using uninitialized variable: reurn | misspelled `return` | before and after SetFromProcess |
| Flush | raises R14 Calling Method without definition: flash | misspelled `flush` | |
| ReadAll, Lines, ReadLine | non-ASCII text comes back garbled (double-encoded) | probably a Latin-1 codec that SetEncoding cannot change | a Hebrew line, an Arabic line and an emoji line through a QBuffer |
| SetFromScocket | name misspelled | | |

## stzListFinder (list/stzListFinder.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| CountItemsW | raises R14 Calling Method without definition: countw | calls `This.CountW`, which the class does not have | two conditions |
| AntiFind, AntiFindAsSections | wrong answer for an empty list | the range 1 to 0 is built and read as [1, 0] | AntiFind(b) gives [ 1, 0 ] and AntiFindAsSections(a) gives [ [ 1, 2 ] ] on an empty list |
| FindPreviousNthOccurrence versus FindPreviousNthOccurrences | ranks count backward in one and forward in the other | two conventions | a b a c a d A before 7: (2, a) gives 3, ([1,2], a) gives [ 1, 3 ] |

## stzTree (list/stzTree.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| FindTheseItems | repeats the last path of an item as many times as it occurs | indexes `_aBranchesWithPos_[_nLen2_]` (the count) instead of `[j]` | X (three places) gives [:root][:node3][1] three times; X and 5 give that path three times then [:root][:node3][3] |
| FindThisItem | answers an empty text | nested alias calls `This.FindItem` without `return` | |
| FindItemCS, FindItem | the case flag does not widen the search | not checked | FindItemCS(x, 0) and FindItem(x) both [ ] while X is present |
| NodeAt | a well formed path that names no node answers an empty text | `eval` of a missing key | [:root][:nope] |
| RemoveThisItemCS | does nothing (no error) while RemoveItem, RemoveTheseItems, RemoveItems, RemoveAllItems raise Not yet implemented! | the body is empty / TODO | |
| AddNodeAt, AddItemAt | a path that does not exist changes nothing, silently | | [:root][:nope] |

## stzTimex (regex/stzTimex.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| SplitByOperator, ParsePattern, init | a pattern with steps joined by -> is read as ONE step; labels keep the closing bracket | the calls to `@StzMid(text, from, to)` run against the current `@StzMid(text, start, length)` (changed with commit 5976bb3de) | `{@Event(A) -> @Duration(30m) -> @Event(B)}` gives one token labelled `A)`; `a -> b -> c`, `a->b->c` come back whole |
| ParseSingleToken | negation returns [ ]; numeric range 2-3 gives min 3 max 3; label keeps the closing bracket; `@Event(Session:1h)` raises R2 | same cause | `@!Event(X)`, `@Event(X)2-3`, `@Event(X)` |
| ParseConstraints | a set `{Mon;Wed;Fri}` raises R2 | the text is first read as a duration | |
| init | a pattern holding `@Duration(1h)` raises R2 at once | same cause | |
| ParseAlternation | finds a single alternative | SplitByOperator does not split | `(@Event(A)\|@Event(B))` |
| MatchAsYouBuild | raises R14 Calling Method without definition: couldmatchwithmore whenever MatchPartial is FALSE | the method it falls back on does not exist | `[]` and `[5]` against @Instant |
| Explain | TargetSet is TRUE on a fresh object | `@oTarget != ""` is true for an unset attribute | |

## stzListex (regex/stzListex.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Match (ListSignature) | a reordering of a list already tested returns the cached answer | the cache key is the length and the sum of the characters of the text, equal for any permutation | `[@N+, @S]`: [1,2,a] gives 1 then [a,2,1] gives 1, a fresh matcher gives 0; `[@N, @S]` with [3,x] first then [x,3]: 1 and 1; ListSignature([1,2,3]) = ListSignature([3,2,1]) = 3:550 |
| ParseAlternationToken | the first alternative loses its keyword, type and pattern | probably the opening bracket is left on the first piece | `[(@N\|@S)]` matches a but not 1; `[(@S\|@L)]` matches [[1]] but not a |
| ParseToken, ParseSetValues, RemoveQuotes | single-quoted values keep the closing quote, so such sets never match | `@StzMid(text, 2, len-1)` read as start and length | RemoveQuotes('abc') gives abc'; `[@S{'hello'; 'world'}]` against world, hello: 0 and 0, with double quotes 1 and 1 |
| NormalizeListString, CompareValues (list, any with lists) | raise R3 Calling Function without definition: @stzreplace | calls a function that does not exist | `NormalizeListString("[1, 2,  3]")` |
| TokensInfo (MatchInfo) | raises R41 Invalid numeric string for every token whose minimum differs from its maximum | adds a number to a text | @N+, @N2-3, @S? |
| Match | the unique flag U does not enforce uniqueness | | `[@N2{1; 2}U]` accepts [2, 2], `[@N2-3{1; 2; 3}U]` accepts [1, 1] |
| Match | a quantified nested list fails for two sublists | | `[[@N]+]` FALSE for [[1],[2]], TRUE for [[1]]; `[[@N]*]` FALSE for [[1],[2]] |
| OptimizeTokens | merging `@N+, @N*` gives a minimum of 0 | the merged minimum is the smaller of the two | min 0 max 1999999998 |

## stzNumBuffer (number/stzNumBuffer.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Item, SetItem, Resize | a negative number ends the Ring process (panic: integer part of floating point value out of bounds, stz_stats.dll, exit code 3) | the engine call converts a negative f64 to an unsigned index | Item(-1), SetItem(-1, 5), Resize(-1) |
| Item | a position of 0 or past the end answers 0, like a stored zero | | Item(0), Item(9) on four items |
| Dot | two buffers of different length answer 0, where AddBuffer, SubtractBuffer and MultiplyBuffer raise | | lengths 3 and 2 |
| Min, Max, Mean, Sum, variances | an empty buffer answers 0 | | `new stzNumBuffer([])` |

## stzPCA (number/stzPCA.ring)

No defect found. A tiny matrix was checked against a hand computation: [[2,0],[-2,0],[0,1],[0,-1]] under Center gives singular values 2.83 and 1.41 (the square roots of 8 and 2), variances 8/3 and 2/3 with the sample convention (2 and 0.5 with the population one), ratios 0.8 and 0.2, loadings the identity; standardized, the same data divides by 1.633 (sqrt(8/3)); two perfectly correlated features give a first ratio of 1 and loadings 0.71, 0.71.
