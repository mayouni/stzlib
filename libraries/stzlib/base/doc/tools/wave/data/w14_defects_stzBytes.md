# Wave 14 (agent w14b) defects: stzBytes, stzStringUnicodeList, stzStringCounter, stzStringSplitter, stzStringSubStringCS, stzStringSubString, stzStringNumbers, stzHexNumber, stzPolynomial, stzOctalNumber, stzRegexuter, stzListexuter

Found by calling every root method with real data (invented text and numbers, Hebrew, Arabic, emoji); each was confirmed with a second dataset or a second call, and the numbers of hex, octal and polynomial results were checked by hand (0xFF = 255, 0x1A3 = 419, 0xDEADBEEF = 3735928559, 0o755 = 493, (x-1)(x-2)(x-3) = x^3 - 6x^2 + 11x - 6). Nothing was fixed. Each is recorded as a warning in the doc block of the method. The strings in the evidence column are exactly what the call returned. stzStringUnicodeList and stzPolynomial: no defect found (the repeated-root behaviour of stzPolynomial is documented by its author in the file header and surfaced by the tolerance of RealRoots).

## stzBytes (string/stzBytes.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| the whole class | `new stzBytes(...)` never builds this class: it builds the alias of stzListOfBytes, which has no ByteAt (R14); loading the file beside the library raises C26 for the class and C22 for six functions | string/stzBytes.ring is not loaded by stzBase.ring, and number/stzListOfBytes.ring line 49 defines `class stzBytes from stzListOfBytes` under the same name | after `load stzlib.ring`: `classname(new stzBytes("Hello"))` gives stzbytes, `NumberOfBytes()` 5, `ByteAt(2)` raises R14; `load "string/stzBytes.ring"` raises "Class redefinition". The doc examples were run on a copy renamed stzBytesX. |
| Left, Right, Mid, Fill, Resize, Replace | a negative count, length or size stops the Ring process with `panic: integer does not fit in destination type` in stz_bytes.dll; Fill with a byte above 255 panics with `integer part of floating point value out of bounds` | the DLL converts the Ring number to an unsigned integer without a check | Left(-1), Right(-2), Mid(2,-1), Fill(65,-2), Resize(-1), Replace(1,-1,"x") and Fill(300,2) each ended the process; Mid(-1,2), Remove(-1,1), Insert(-1,"x") and ByteAt(-3) are harmless |
| Append | a number as argument ends the Ring process with exit code 1 and no message | the DLL expects text | `Append(66)` on keep |
| FromHex | a bad text EMPTIES the buffer silently (odd digit count, `0x` prefix, a space, `zz`), while FromBase64 with a bad or unpadded text leaves the buffer as it was | not checked | FromHex("486"), FromHex("0x4849"), FromHex("48 49") each gave an empty buffer; FromBase64("!!!notbase64") and FromBase64("SGk") changed nothing |

## stzStringCounter (string/stzStringCounter.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| CountBetween, CountBetweenCS | raise R3 for every input | the body calls `StringNumberOfOccurrenceCS`, a function that does not exist (only StringNumberOfOccurrence is defined, in stzStringFunc.ring) | Banana banana with an, 1, 6 and xyzxyz with x, 1, 3 |
| CountOverlappingCS | the case flag is ignored | the flag is read into `_bCase_` and never passed to the engine | aa in AAaa gives 1 with 0 and with 1; ignoring case would give 3 |
| NumberOfCharsCS | with 0 it counts the distinct letters without regard to case, not the characters | the case-insensitive branch returns `len(UniqueCharsCS(0))` | aAa gives 3 with 1 and 1 with 0 |
| NumberOfSubStringsCS | the flag changes nothing | both branches give n*(n+1)/2 | Banana banana gives 91 with 0 and with 1 |
| CountLeadingChar, CountTrailingChar | an empty text stops the Ring process with `integer part of floating point value out of bounds` in stz_string.dll | the first code point of an empty text is passed on as an invalid value | CountLeadingChar("") and CountTrailingChar("") on a😀ab |
| init (stzString argument) | after the stzString is edited the counter reads an empty text (Append, Replace) or the old text (Insert) | the counter shares the engine handle of the stzString, and the edit replaces or frees it | s = stzString("hello"), counter over s: Count("l") 2; after s.Append("lll") the counter's Content is empty while a fresh counter gives 5 |
| CountRegex | an invalid pattern gives 0 with no error | the engine count returns 0 | CountRegex("[") on a😀ab |

## stzStringSplitter (string/stzStringSplitter.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Partition, PartitionAfter, RPartition, RPartitionAfter | each returns a ONE-item list: the text before the first separator (Partition), behind it (PartitionAfter), before the last (RPartition), behind it (RPartitionAfter); the real cut is three parts | the engine returns the parts in a NUL-separated buffer and the Ring string read from it stops at the first NUL, so `_SplitNullDelimited` sees one part | engine data for a-b with - has length 1, the text a; key=value=more with = gives [ "key" ], [ "value=more" ], [ "key=value" ], [ "more" ]; same for x=y=z, one two and שלום-עולם; stzString.Partition (a different, pure-Ring body) gives the three parts |
| SplitAtSubStrings | a text that already contains `<<<SEP>>>` is split there | each separator is replaced by that literal marker and the text is split on it | x<<<SEP>>>y,z at [ "," ] gives x, y, z |
| Split with the pair [ :around, value ] | raises R14 | calls SplitAroundCS, which this class does not define | Split([ :around, "," ]) |
| init (stzString argument) | the splitter reads an empty text after the stzString is appended to | shared engine handle, same as stzStringCounter | s = stzString("a-b-c"); s.Append("-d"); the splitter's Content is empty |

## stzStringSubStringCS (string/stzStringSubString.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Positions (and Occurrences) | raise R14 for every input | the body calls `FindAllCS` on stzStringFinder, which does not exist | Banana bandana with an; banana with nan |
| NumberOfOccurrence, ReplacedWith | do not count overlapping occurrences, whereas Sections and NthPosition do, so LastPosition (NthPosition of the non-overlapping count) is one short | the finder methods have different overlap rules | ana in banana: NumberOfOccurrence 1, Replaced("-") gives b-na, Sections [2,4],[4,6], NthPosition(2) 4, LastPosition 2 |
| IsBoundedBy | the flag 0 does not reach the last comparison, which is exact | the enclosed stretch is compared with the fragment with `=` after the case-aware search | ab with flag 0 in x(AB)y gives 0, AB with flag 0 gives 1; the finder finds [3,4] for both flags |
| init | a named-parameter list for the flag raises Incorrect param type | the flag goes through @CaseSensitive, which wants 1 or 0 | [ :CaseSensitive = 0 ] |

## stzStringNumbers (string/stzStringNumbers.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Numbers and every method built on it (NumberOfNumbers, ContainsNumbers, SumOfNumbers, MaxNumber, MinNumber, AverageOfNumbers, NthNumber, FirstNumber, LastNumber, NumbersAsStrings) | raise R41 Invalid numeric string for a run with two decimal points | the scanner appends a point whenever a digit follows, then converts 1.2.3 with `0 + text` | v 1.2.3; ip 192.168.0.1; 1.25.5 |
| ScanInteger | stops the Ring process with `integer overflow` in stz_string.dll above 2147483647 and at -2147483648 | 32-bit parse in the engine | 2147483647 gives 2147483647; 2147483648, 3000000000, 99999999999, 12345678901234567890 and -2147483648 each ended the process |
| RemoveNumbers, ReplaceNumbers (stzString argument) | the first in-place edit leaves the stzString passed in EMPTY; the helper keeps the right text | not checked (same symptom as stzStringRemover and stzStringCrypto) | s = stzString("x 5 y 10"); ReplaceNumbers(7) gives helper x 7 y 7 and s reads an empty text; again on the second edit |
| NumbersAsStrings | writes numbers with two decimals, losing digits | Ring's number-to-text conversion | 3.14159 gives 3.14 while Numbers holds 3.14159 (times 100000 gives 314159) |
| RemoveNumbers, ReplaceNumbers, PositionsOfNumbers | work digit by digit and do not agree with Numbers: signs and points stay, and 5.5 is two runs | the loops test isDigit only | x 5 y 10 z 5.5 with 9 gives x 9 y 9 z 9.9; Invoice 12 costs -3.5 with 0 gives -0.0 |

## stzHexNumber (number/stzHexNumber.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| FractionalPart (FractPart) | raises R14 | calls `HexNumberWithoutPrefix`, which does not exist; init also refuses a point, so there is never a fraction | 0xFF; 0x41 |
| ToScientificForm (ToScientific) | raises R14 | forwards to stzNumber.ToScientificForm, which does not exist, and passes an undefined variable n | 0xFF; 0x41; `new stzNumber(255).ToScientificForm()` raises the same R14 |
| IntegerPartWithoutPrefix | keeps a stray 0 | RemoveMany of the prefixes ["x", "0x", "U+"] removes the x first, leaving 0 | 0xFF gives 0FF, 0xabc gives 0abc, 0x0 gives 00, ABC gives 0ABC |
| ToUnicodeHexForm | writes U+0x41 | the 0x prefix is not removed before the U+ is added | 0x41, 0xFF, U+0041 |
| FromDecimalForm, FromDecimal | a negative or fractional value stores text that init would refuse | no check | -1 stores -1; 255.5 stores FF. |
| ToDecimalForm | rounds above 2^53 | goes through a double | 0x7FFFFFFFFFFFFFFF gives 9223372036854775808.00 (exact: ...807); 0xFFFFFFFFFFFF gives 281474976710655, exact |
| function UnicodeHexToDecimalForm (outside the class) | raises R13 Object is required | calls `.ToDecimalForm()` on the text that HexToDecimal returns | UnicodeHexToDecimalForm("U+0041") |

## stzOctalNumber (number/stzOctalNumber.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| WithPrefix | doubles a prefix already stored | init keeps the text as given, the From... methods store the 0o prefix, and WithPrefix always adds 0o | 0o377 gives 0o0o377; after FromDecimalForm(255) too |
| ToBaseNForm (toBaseN) | raises R14 | forwards to stzNumber.ToBaseNForm, which does not exist (stzNumber has IntegerPartToBaseNForm) | 0o377 with 2, 16, 36, 8; 17 with 2 |
| ToScientificNotationForm | raises R14 | forwards to a missing stzNumber method | 0o377; stzNumber(255) raises the same |
| ToDecimalForm | gives 0 from 2^63 up, and rounds 2^63-1 | the engine conversion from base 8 overflows | 0o1000000000000000000000 gives 0, 0o1777777777777777777777 gives 0, 0o777777777777777777777 gives 9223372036854775808; 0o400000000000000000 gives 9007199254740992, correct |
| init, ToDecimalForm | a capital 0O17 is accepted and then converts to 0 | the prefix removal is by small 0o | 0O17 gives 0; WithPrefix 0o0O17 |
| FromDecimalForm | a negative or fractional value stores text that init would refuse | no check | -8 stores 0o-10; 8.5 stores 0o10.4 |

## stzRegexuter (regex/stzRegexUter.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| GetDependencyChain | stack overflow (R4) once the log holds an entry | every entry lists its own trigger in dependson, and the method recurses on each dependency | trigger num after abc 12 de 5; trigger d after 5; an empty log or an unknown trigger gives [ ] |
| Positions | every copy of a repeated match reports the position of the first | the position is `FindFirst(match)` | 7 in a 7 b 7 c 7 gives 3, 3, 3 |
| AddCode | a second code for the same trigger is stored and never used | executeComputation takes the first code and exits | word with upper then +1 gives ABC |
| Process | a blank text clears the state log but leaves the last Matches and Results | `ResetState` only | Process("") after a run |

## stzListexuter (regex/stzListexUter.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| GetDependencyChain | stack overflow (R4) once the log holds an entry | same as stzRegexuter | triggers pair and t1 |
| StateByPosition | adds an empty `position` field and orders nothing | the sort reads `[:position]`, which list-computer entries never store | entries of [1,"a",2,"b"] come back in computation order with position "" |
| AddTrigger (single text) | raises R3 | calls `lpat`, which does not exist | AddTrigger("[@N]") |
| Process, FindAllMatches | a whole list that matches is reported twice, and every contiguous run of a longer list is a match | the whole list is tested, then all its runs including the full one | [3, "c"] with [@N, @S] gives two matches; [7, 8, 9] with [@N+] gives seven |
| AddCode | code that assigns @value never changes the result, and `@list = [ ... @list ... ]` reads the new empty list | the result is taken from @list; Ring builds a list literal in the target variable | `@value = 'X'` and `@value = 5` leave [1,"a"]; `@list = [len(@list)]` gives [0]; `@list[1] = @list[1] * 10` works |
