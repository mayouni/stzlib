# Wave 12 (agent w12b) defects: stzStringFormatter, stzStringEncoder, stzStringBounder, stzStringLeadTrail, stzListSorter, stzListFlattener, stzListParser, stzParser, stzItemCS, stzItem, stzBinaryNumber, stzListOfTimeLines

Found by calling every root method with real data (invented text, Hebrew, Arabic, emoji, invented lists and dates); each was confirmed with a second dataset before being written down. Nothing was fixed. Each is recorded as a warning in the doc block of the method. Binary-number results were checked against a hand conversion.

## Common to the five string helpers and the first four classes

| class | method | symptom | cause | evidence |
|---|---|---|---|---|
| stzStringFormatter, stzStringEncoder, stzStringBounder, stzStringLeadTrail | init (stzString argument) | after the first in-place edit the stzString passed in reads as an empty text; the helper keeps the right text; reads and past-tense forms leave it alone | probable, not checked: the held copy of the stzString shares its engine handle and Update frees it (same symptom as stzStringReplacer and stzStringRemover in wave 9) | stzString("Hello") then LeftAlign(8), Trim(), ApplyTitlecase(), ApplyUppercase() each leave the original reading empty; same for UrlEncode, HtmlEncode, NormalizeNFD, ReplaceBetween, RemoveRepeatedLeadingChars, RemoveFromEnd, EnsurePrefix |

## stzStringFormatter (string/stzStringFormatter.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| PaddedLeft, PaddedRight | the padding character is ignored, spaces are used | the body returns `This.RightAligned(nWidth)` / `This.LeftAligned(nWidth)` and never reads cChar; PadLeft / PadRight (the in-place forms) honour it | abc with PaddedLeft(6, "-") answers three spaces then abc, PadLeft(6, "-") gives ---abc; PaddedRight(6, "-") and PaddedRight(6, "*") on the same text answer spaces |

## stzStringEncoder (string/stzStringEncoder.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| ToBinary | a character above code point 255 is cut to its low eight bits; the docs call it "bytes" | `_n_ & pow(2, b)` is read for b = 7 to 0 only, over the code point (not the UTF-8 bytes) | the Hebrew shin (1513) answers 11101001 (233), the Hebrew word shalom answers 11101001 11011100 11010101 11011101, the Arabic word marhaba answers 01000101 00110001 00101101 00101000 00100111, an emoji (128512) answers 00000000 |
| FromHex | the UTF-8 bytes are not joined back into characters, each byte becomes its own character (Latin-1 reading) | `StzChar(dec(byte))` per pair | FromHex("c3a9") answers two characters (A tilde and a copyright sign) instead of e acute, and FromHex("d7a9d795") answers four characters instead of two Hebrew letters; ToHex then FromHex does not round-trip outside ASCII |
| ToOctal (note) | not a defect, an inconsistency: the octal form is of the whole code point (not cut to eight bits) while ToBinary is cut | | the Hebrew shin answers 2751 in ToOctal and 11101001 in ToBinary |

## stzStringBounder (string/stzStringBounder.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| FindSectionBoundsIBZZ, SectionBoundsIB | a side with no characters (marked [0, 0] by FindSectionBoundsZZ) becomes [1, 1] before and [-1, -1] after, so SectionBoundsIB returns a spurious first character | the IB form adds 1 / subtracts 1 to every pair without testing for the empty marker | abcdefgh: FindSectionBoundsIBZZ(1, 8, 2, 2) answers [[1,1],[-1,-1]] and SectionBoundsIB(1, 8, 2, 2) answers ["a"]; SectionBoundsIB(1, 3, 2, 2) answers ["a", "cd"] where "cd" only is expected |

## stzStringLeadTrail (string/stzStringLeadTrail.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| RepeatedLeadingCharsCS, RepeatedTrailingCharsCS (and HasRepeated...CS, NumberOfRepeated..., RemoveRepeated...Chars built on them) | the case flag is ignored, the comparison is always case-sensitive | pCaseSensitive is never read in the loop (`_acChars_[i] = _cFirst_`) | xXxy with RepeatedLeadingCharsCS(0) answers an empty text; yxXx with RepeatedTrailingCharsCS(0) answers an empty text; AaAbBb likewise |
| RemoveFromStartCS, RemoveFromEndCS (and RemovedFromStartCS, RemovedFromEndCS) | with the flag 0 and a different case, nothing is removed | StartsWithCS(..., 0) answers TRUE, then `StzEngineStringRemovePrefix` / `...RemoveSuffix` compare with case | Hello World: RemovedFromStartCS("HELLO ", 0), RemovedFromStartCS("hello ", 0), RemovedFromEndCS(" world", 0) and RemovedFromEndCS("WORLD", 0) all answer the text whole |
| RemoveRepeatedLeadingCharsCS, RemoveRepeatedTrailingCharsCS vs RemoveRepeatedLeadingChars, RemoveRepeatedTrailingChars | the CS forms remove the whole run, the plain forms keep one character | the CS forms call `@oString.RemoveLeadingChars()` / `RemoveTrailingChars()`, the plain forms remove run length minus one | aaabccc: the CS form answers bccc, the plain form abccc; xxyzz: CS leading yzz then trailing y, plain xyzz |

## stzListSorter (list/stzListSorter.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| SortBy, SortByInAscending, SortByInDescending, SortedBy, SortedByInDescending (and stzList.SortBy, same engine call) | an expression using lower() or upper() as the key does not order alphabetically: the list comes out in length order and equal lengths keep their place | not isolated; observed in the engine function `StzEngineListSortByExpr` (engine/src/list.zig, stz_list_sort_by_expr) with a key from expr.zig fn_lower / fn_upper; `@item` and `len(@item)` as keys work | zebra, Ox, cat with lower(@item) answers Ox, cat, zebra (expected cat, Ox, zebra); pear, Apple, fig, banana with lower(@item) answers fig, pear, Apple, banana (expected Apple, banana, fig, pear); b, A, c, D with lower(@item) answers b, A, c, D; stzList.SortBy("lower(@item)") on zebra, Ox, cat answers Ox, cat, zebra |
| NthSmallest, NthLargest (note) | n = 0 is treated as 1 and n above the length answers 0, a value that can be a real item | not a rank slip: both are 1-based (NthSmallest(1) is the smallest) | [5,2,9,1,7]: NthSmallest(0) 1, NthSmallest(6) 0, NthLargest(0) 9 |

## stzListFlattener (list/stzListFlattener.ring)

No defect. Notes recorded in the entries: Flatten opens every level, like DeepFlatten (its name suggests one level); HasLeadingItems asks whether the FIRST item is repeated, as HasRepeatedLeadingItemsCS(1) does; ToStzGrid raises unless the content is a pair [columns, rows].

## stzListParser, stzParser (list/stzListParser.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| NextPosition, NextNthPosition, PreviousPosition, PreviousNthPosition, NextItem, NextNthItem, PreviousItem, PreviousNthItem | moving past the last or before the first visited position raises error R2 (array access out of range) instead of answering 0 as the code intends; the cursor stays in place | `ParsedPositions()[ _nPos_ + n ]` is read before any bound test | five positions: NextPosition on the last, NextNthPosition(9), PreviousPosition on the first and PreviousNthPosition(9) all raise R2 |
| Parse (positions beyond the list) | no check against the list: Parse(1, 20, 1) on five items gives 20 positions and ParsedItems then raises R2 | | list of five items |
| stzParser.Source on a stzListParser | answers an empty text | stzListParser has its own init, does not call the parent's init, and stores its list in @aList | Source() of a parser over x, y, z answers an empty text, List() the list |

## stzItemCS, stzItem (list/stzItem.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Sections, SectionsCS | R14 | calls `FindAsSectionsCS` on the list; stzList has no such method | any receiver (text item, number item, list item) |
| IsBoundedBy, IsBetween, BoundedBy | R14 | call `ContainsItemBoundedByCS`, `ContainsItemBetweenCSQ`, `BoundItemByCSQ`, absent from stzList; BoundedByCS also reads `pacBounds`, not its parameter | text and number receivers |
| ReplacedWith (Replaced, ReplacedBy, ReplacedWithCS) | R14 | calls `ReplaceCSQ` on the list, absent from stzList; the body reads `pcOtherItem` where the CS signature names `pOtherItem`; the plain form calls `ReplacedWithCs` | text and number receivers |
| Removed, RemovedCS | R14 | calls `RemoveCSQ`, absent from stzList | text and number receivers |
| Uppercased, Lowercased (and CS forms) | R14 | call `UppercaseItemCSQ`, `LowercaseItemCSQ`, absent from stzList | text and number receivers |
| InstertedBeforeCS, InstertedAfterCS | R14; the names are misspelled (Insterted) | call `InsertBeforeCSQ`, `InsertAfterCSQ`, absent from stzList | text and number receivers |
| InsertedBefore, InsertedAfter | R14 | call `InsertedBeforeCS` / `InsertedAfterCS`, which do not exist (the methods are spelled Insterted...) | text and number receivers |
| InsertedBeforePosition(s), InsertedAfterPosition(s) | R14 | call the misspelled `InsertBeofrePositionQ` and `InsertBeofrePositionsQ`; the After forms call the Before names | text and number receivers |
| InsertedBeforeItem(s), InsertedAfterItem(s) | R14 | call `InsertBeforeItemCSQ`, `InsertBeforeItemsCSQ`, `InsertAfterItemCSQ`, `InsertAfterItemsCSQ`, absent from stzList | text and number receivers |
| InsertedBeforeW, InsertedAfterW | R14; the After form calls the Before name | call `InsertBeforeWQ`, absent from stzList | text and number receivers |
| NumberOfItems (Size, CountItems) | R14 for a text or number item, works for a list item | `Q(item).NumberOfItems()` and stzString / stzNumber have no such method | "a" and 5 raise, [1, 2] answers 2 |
| IsLowercased, IsUppercased | R14 for a number or a list item | `Q(item).IsLowercased()` exists for text only | 5 and [1, 2] raise |
| OccurrencesXT (OccurrencesCSXT) | answers only the position of the LAST requested occurrence | `_anResult_ = ...` is assigned in the loop instead of appended | [1, 2] answers 5, [2, 1] answers 1, [1] answers 1 on a, b, A, c, a, b, b with item a |
| init (case flag) | the flag is stored and returned by CaseSensitive but never read by the plain methods | Positions, NumberOfOccurrence, FirstPosition... call their CS twin with a literal 1 | stzItemCS("b", [a, B, b], 0): Positions answers [3], PositionsCS(0) answers [2, 3] |
| init (named :In) | `[ :In = list ]` is not unpacked: List() answers `[ ["in", list] ]` and Positions is empty | the test `Q(paList).IsInOrInListNamedParam()` does not match | stzItemCS("b", [:In = [a, b, b]], 1) and TheItemInQ("b", [:In = [...]]) |
| TheItemInQ / TheItemIn | CaseSensitive() answers the text casesensitive, not 1 | the shorthand passes the word `:CaseSensitive` as the flag | TheItemInQ("b", [a, b, b]).CaseSensitive() |
| stzItem (all list methods) | "paList must be a list" raised by every method that needs the list | init insists on two texts, so the list is a text and ListQ() builds a stzList from it | stzItem("an", "banana"): Positions, NumberOfOccurrence, FirstPosition, IsLowercased, Uppercased all raise; only Item, List, CaseSensitive answer |
| ItemQ / Item / TheItem functions (note, outside the roots) | R11 class not found: stzsitem | `ItemCSQ` builds `new stzSItem(...)`, a class that does not exist | ItemQ("a") |

## stzBinaryNumber (number/stzBinaryNumber.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| WithPrefix | the prefix is doubled | Content already starts with b or 0b and BinaryPrefix() is put in front | 0b1011 answers 0b0b1011, b1111 answers 0bb1111, the empty number b0 answers 0bb0 |
| IntegerPart (no dot) | returns the prefix with the digits | the part before the dot is taken from the full text | 0b1011 answers 0b1011 |
| IntegerPartReversed, Reversed | the prefix is reversed with the digits: 0b1011 answers 1101b0, not a binary number | the whole text, prefix included, is reversed | 0b1011 and b1111 (answers 1111b) |
| IntegerPart, Reversed, IntegerPartReversed with a fractional part | R24 uninitialized variable _oTempStr_ | the dot branch reads `_oTempStr_`, which this method never creates | 0b101.11 and b10.1 |
| ToHexForm | the fractional digits are lost | stzNumber.ToHexForm answers a dot with nothing after it | 0b101.11 (5.75) answers 0x5. (0x5.C expected), 0b10.1 (2.5) answers 0x2. (0x2.8), 0b11.01 (3.25) answers 0x3. (0x3.4); ToOctalForm is right (0o5.6, 0o2.4, 0o3.2) |
| ToScientificNotationForm, ToScientificNotation | R14 | forwards to `stzNumber.ToScientificNotationForm`, which does not exist | 0b1011, 0b11111111 |
| FractionalPartToDecimalFormWithoutZeroDot | raises "Indexes out of range" when there is no fractional part | takes `Section(3, ...)` of the text 0 | 0b1011, 0b0 |
| init (uppercase prefix) | 0B101 is accepted, but ToDecimalForm answers 0 (5 expected) | the prefix is stripped in lower case only | 0B101 and 0B11 both answer 0 |
| FromDecimalForm (negative) | answers 0b-101, which the constructor refuses (it accepts -0b101) | the sign is put after the prefix | FromDecimalForm(-5) |
| BitwiseOnesComplement, operator("~") | the operand is ignored | the signature takes nOtherNumber and never uses it | answers -12 for 0b1011 and -7 for 0b110 whatever the argument |
| operator (unknown) | an operator that is not listed answers an empty text without an error | `switch` without a default | operator("+", 1) |
| class description (note) | the class comment says FromHexForm("x0E22") and FromOctalForm("o2077"), which raise; the text must start with 0x and 0o | comment out of date | FromHexForm("x0E22"), FromOctalForm("o2077") raise; "0x0E22" and "0o2077" work |

## stzListOfTimeLines (datetime/stzListOfTimeLines.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| AddSpanToLane (AddPeriodToLane), AddSpansToLane, AddPointsToLane, AddBlockedSpanToLane, AddBlockedPointToLane, RenameLabelInLane, RemovePointFromLane | nothing is stored and no error is raised | each does `_oLaneTL_ = This.Lane(pcLane)` and edits it; Lane returns a COPY of the stzTimeLine, so the stored timeline is untouched (AddPointToLane was already repaired by indexing @aTimeLines directly, with a comment saying so) | AddSpanToLane("team a", "Build", "2026-04-01", "2026-05-01") leaves Spans of the lane empty, while the same AddSpan on the object Lane returns shows the span; AddPointsToLane, AddSpansToLane, RenameLabelInLane("Kickoff" to "Start") and RemovePointFromLane (by label and by moment) leave the lane as it was; AddBlockedPointToLane("2026-06-01") then IsBlockedInLane answers 0 |
| (consequence) HasOverlapsInLane, CrossLaneOverlaps, UncoveredPeriodsPerLane, and the span part of WhatsAt and ToTimeLine | not exercised with real spans: no span can reach a lane | see above | |
| BlockSpanInLane, BlockPointInLane | R14 | call `BlockSpan` / `BlockPoint` on stzTimeLine, which has neither | any lane and label |
| Show, ShowShort, ShowUncovered, VizFind | R19 calling function with less number of parameters | `This._buildVizCanvas()` is called with no argument while it is declared (pcMode, paOptions); the drawing routines `_addLaneLabelToCanvas`, `_drawAxisForLane`, `_vizCanvasToString`, `_buildTable` are empty stubs | all four raise R19 |
| ShowXT | R26 calling private method from outside the class: _calculaterequiredvizheight | `_calculateGlobalLayout` calls the private method of stzTimeLine | ShowXT([]) |
| Copy | the copy has the lanes and bounds but none of the points | `new stzTimeLines(This.Content())` reads only :Start, :End and :Lanes of the content | after AddPointToLane, Copy().Lane(name).Points() answers an empty list |
| (note) Lane names | stored in upper case, so Lanes() answers TEAM A for Team A | init and AddLane apply StzUpper | |
