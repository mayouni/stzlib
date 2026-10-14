# Wave 15 (group 1) defects: string, list, number and linguistic helper classes

Found by calling every root method with real data (invented lists and texts, Hebrew, Arabic, emoji); each defect was confirmed with a second call on different data before being written here. Nothing was fixed. Each is recorded as a warning in the doc block of the method.

## stzListCounter (list/stzListCounter.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| HowManyItemsW, HowManyUniqueItemsW, InsertAfterWhere (and the non-root InsertAfterWQ) | raise `Error (R24) : Using uninitialized variable: pcondition` and do nothing | the nested alias declares `pcCondition` but forwards `pCondition`, a variable that does not exist | HowManyItemsW('{ isNumber(@item) }') on a 12-item list and HowManyItemsW('{ len(@item) > 1 }') on [ "x", "yy", "zzz" ]; InsertAfterWhere('{ @item = 2 }', 9) on [1,2,3] leaves the list unchanged |

## stzListInString (list/stzListInString.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Items | the brackets stay on the first and last pieces, and a comma or space inside a quoted text splits or shrinks it | `RemoveAllQ([ "[", "]" ])` with a list of two texts removes nothing (StzStringQ('[1,2]').RemoveAllQ(['[',']']) answers `[1,2]`) | '[1,2,3]' answers [ "[1", "2", "3]" ]; '[ "a b", "c,d" ]' answers [ '["ab"', '"c', 'd"]' ] |
| ItemsXT, Values, VarNames, Variables, Types, VariablesAndTheirTypes | raise R42 "Error in eval() function" (list of several items, the eval sees `[1` or `3]`) or R20 "Calling function with extra number of parameters" (list of one item or none, in `ItemsXT` at the `StzListOfStringsQ(...)` line); no list works | they all start from Items, which keeps the brackets, and the one-item path fails at its next call | '[1,2,3]' and '[ "a", 2, "שלום", 5 ]' (R42); '[5]', '[nAge]', '[ ]' (R20) |
| ContainsValues, ContainsVariables, ContainsOnlyValues, ContainsValuesAndVariables | answer an empty text, never TRUE or FALSE | the bodies are empty stubs | called on '[ "a", 2 ]' and '[ nAge, "x" ]' |

## stzListInserter (list/stzListInserter.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Insert, InsertItem, InsertBefore, InsertBeforePosition, InsertBeforePositions | a position two or more past the end kills the process: `Error (R14) : Calling Method without definition: extendton` | the branch for `_n_ > NumberOfItems()+1` calls `@oList.ExtendToN`, which stzList does not define | Insert("X", 9) and InsertBeforePosition(7, "X") on a b c d; one past the end (5) works and appends |
| InsertAfterPosition, InsertAfter | a list of positions kills the process: `Error (R14) : Calling Method without definition: insertafterpositions` | the list branch calls `This.InsertAfterPositions`, which the class does not define | InsertAfterPosition([1,3], "X") and InsertAfter([2,3], "X") on a b c d; InsertBeforePosition([1,3], "X") works |
| InsertAt | a position of 0 or below raises `ERR-` with no message; a position two or more past the end raises R2 (Index out of range); the sibling InsertBefore ignores 0 and appends one past the end | the position goes unchecked to `ring_insert` | InsertAt(0, "X"), InsertAt(-1, "X"), InsertAt(9, "X") on a b c d |
| MoveItem | moving an item towards the end lands it one place before the target, and MoveItem(n, n+1) changes nothing | after removing the item, `n2` is decreased by one and the item is inserted BEFORE that position, so the target is read as "go before the item that stood at n2" | MoveItem(1, 3) on a b c d answers b a c d; MoveItem(1, 2) and MoveItem(2, 3) leave a b c d; MoveItem(1, 4) answers b c a d; towards the start is exact: MoveItem(3, 1) answers c a b d |
| SwapItems, Swap | a position of 0 is read as 1; a position past the end changes nothing and raises nothing | the engine swap clamps or ignores the position | Swap(0, 2) on a b c d answers b a c d; Swap(1, 9) leaves a b c d |
| Insert, InsertBeforePosition, InsertAfterPosition, InsertAfter | a position of 0 (or below, or past the end for the After forms) and a named place that is not one of the known ones are ignored without a message | the guards fall through | Insert("X", 0), Insert("X", [:Foo, 1]), InsertAfterPosition(0, "X"), InsertAfterPosition(9, "X") all leave the list unchanged |

## stzListNamedParams (list/stzListNamedParams.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| IsNamedParamWith | raises `Error (R20) : Calling function with extra number of parameters` for every keyword | not isolated: the global `IsThisNamedParam(aList, cKeyword)` it calls answers 1 outside the class, but inside the method the call does not reach it | o1.IsNamedParamWith('At') on [ :At, 3 ]; o2.IsNamedParamWith('N') and (:CS) on [ :N, 5 ]; IsThisNamedParam([ :N, 5 ], 'N') answers 1 |
| IsRemoveAtOptionsNamedParam | raises `Error (R14) : Calling Method without definition: containsbothcs` for any hash list holding one of its option keys | the check that :CaseSensitive and :CS are not both given calls `ContainsBothCS` on a stzListOfStrings, which exists only in archive/stzList_monolithic.ring | [ :RemoveNCharsBefore = 2, :CS = 0 ], [ :RemoveNCharsBefore = 2 ] and [ :CaseSensitive = 1, :CS = 0 ]; a list with no such key answers 0 |
| IsConstraintsOptionsNamedParam | answers 0 for every list, even for the example in its own comment | `VerifyConstraints([...])` is called with an argument list but takes none (R20), and the surrounding `try ... catch` turns the error into 0 | the comment's example with :OnStzString and :OnStzNumber answers 0; so does [ 1, 2, 3 ] |
| IsOneOfTheseNamedParams | a name with no matching `Is<Name>NamedParam` method raises R14 instead of answering FALSE | the check builds the method name and evaluates it | IsOneOfTheseNamedParams([ 'Zork' ]) |

## stzListOfGrids (list/stzListOfGrids.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init (so Content and Copy too) | `new stzListOfGrids(aList)` and `StzListOfGridsQ(aList)` raise `Error (R14) : Calling Method without definition: islistofgrids` for every list, an empty one included; no object can be built | the check is `Q(paGrids).IsListOfGrids()`, a method stzList does not have; only the global function `IsListOfGrids` exists | [ [ [1,2],[3,4] ], [ [5,6],[7,8] ] ] and [ ]; Q([ [1,2],[3,4] ]).IsListOfGrids() raises the same |
| Content | has no `return`: the body is the bare name `@aContent`, so it would answer an empty text | a missing `return` | read from the code, not run (no object can be built); Copy builds from Content, so it would inherit it |

## stzListOfHashLists (list/stzListOfHashLists.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| ToSetOfHashLists, ToSet, ToSetOfHashListsQ | repeated hash lists are not removed | the repeat test is `_aRes_[j] = _aHl_`, and Ring's `=` between two lists is always FALSE | [ [ :a = 1 ], [ :a = 1 ] ] answers both; three [ :a = "x" ] answer three; [ [ 'a', 1 ] ] = [ [ 'a', 1 ] ] answers 0 |
| Show, Shwo | a value that is a list raises `Error (R21) : Using operator with values of incorrect type` | the line is built with `key + " : " + value` | [ [ :a = [1,2] ] ]; texts and numbers print |

## stzListOfSets (list/stzListOfSets.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init (so Content, Value, Copy and Sets for any non-empty list) | `new stzListOfSets(aList)` raises `Error (R14) : Calling Method without definition: islistofsets` for every non-empty list, valid or not; only [ ] builds; a non-list raises `Error (R3) : Calling Function without definition: stzlistofsetserror` | the check is `Q(paList).IsListOfSets()`, a method stzList does not have (only the global function exists), and the error text function `stzListOfSetsError` is not defined | [ [1,2], [2,3] ], [ ["a","b"], ["שלום","😀"] ] (R14); "x" (R3); [ ] builds |

## stzListPerformer (list/stzListPerformer.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| YieldPairs | does not return [ position, item ] pairs: it returns the same list as Yield | the body is `@oList.Map(pcYielder)` | YieldPairs('2*@item') on 10 20 30 answers 20 40 60; YieldPairs('upper(@item)') on "a" "b" answers "A" "B" |

## stzListProvidedAsString (list/stzListProvidedAsString.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init, Items | Items answers [ ] for every text | init takes the answer of `RemoveTheseBounds("[","]")` and of `RemoveSpaces()`, which change the string in place and answer nothing, so the text it splits is empty | '[ 1, 2, "A" ]', '[ n1, n2 ]', '[ [1,2], 3 ]', '[]'; `StzString('[ 1, 2 ]').RemoveTheseBounds('[',']')` answers "" and leaves " 1, 2 " |
| IsListOfValues, ContainsOnlyValues | raise `Error (R12) : Error in property name, property not found: list` | the body reads `This.List`, a property the class does not define | called on '[ 1, 2, "A" ]' |
| IsListOfVariables, ContainsOnlyVariables, IsListOfValuesAndVariables, ContainsValuesAndVariables | answer an empty text, never TRUE or FALSE | TODO stubs with an empty body | called on '[ 1, 2, "A" ]' and '[ n1, n2 ]' |

## stzListSections (list/stzListSections.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| ManyRanges | raises `Error (R24) : Using uninitialized variable: paranges` | the alias declares `paSections` but forwards `paRanges` | ManyRanges([ [1,2], [4,3] ]); Ranges with the same argument works |
| RangesOtherThan (and RangesOtherThanIB) | raises `Error (R19) : Calling function with less number of parameters` | the alias calls `This.AntiRanges()` without the ranges | RangesOtherThan([ [2,2] ]); AntiRanges([ [2,2] ]) works |
| Range | answers a text "" (not a list) when the start or the length is 0, and wraps the section one list deeper than Section and RangeXT | `Range` returns `""` for 0 and adds the section as one item of a result list | Range(2, 0) and Range(0, 2) answer ""; Range(2, 3) on a to g answers [ [ "b","c","d" ] ] while RangeXT(2, 3) answers [ "b","c","d" ] |

## stzListTrimmer (list/stzListTrimmer.ring)

No defect found. Behaviour worth knowing, recorded as notes in the doc blocks: the number 0 counts as an empty item for Trim, TrimLeft and TrimRight; TrimToSize with 0 or a negative n empties the list without an error; the helper `_TrimItemIsEmpty` is defined inside TrimRightCS (a nested def).

## stzPair (list/stzPair.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Update, UpdateWith, Swap, SwapQ, Swapped | raise `Error (R24) : Using uninitialized variable: panpair` for every argument; the pair is never changed | Update checks `len(panPair)` while its parameter is `paPair`; Swap and Swapped end in UpdateWith; the next line also calls `KeepingHisto()`, which looks like a misspelling of `KeepingHistory()` | Update([1,2]), UpdateWith([3,4]), Update([1,2,3]), Swap(), SwapQ(), Swapped() on [ "שלום", 7 ] |
| init | the list is not checked for two items | the comment says "Control: paList must contain just 2 items" and nothing enforces it | [ 1, 2, 3 ] is kept whole; [ 1 ] builds a pair whose Item2 raises R2 |

## stzPairOfLists (list/stzPairOfLists.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Alternate (and AlternateQ) | raises `Error (R24) : Using uninitialized variable: aresult` for every non-empty pair of lists | the code is built as text and evaluated: it appends to `aResult` while the variable is `_aResult_`, and it names `This.FirstList()` inside the eval | [ "a","b","c" ] with [ 1,2,3 ]; [ "a","b" ] with [ 1,2,3,4 ]; [ "a","b","c" ] with [ 1 ]; two empty lists answer [ ] |

## stzSection (list/stzSection.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init, and IsSection | a start past the size is accepted when the end is inside it | the check is `_n1_ >= 1 and _n2_ <= _nSize_` and does not bound `_n1_` above | new stzSection(12, 3, 10) answers [ 12, 3 ] and IsSection(12, 3, 10) answers 1; new stzSection(30, 1, 5) answers [ 30, 1 ] |

## stzSetOfSections (list/stzSetOfSections.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init (so every other method is unreachable) | `new stzSetOfSections(aList)` raises "Can't create the stzSetOfSections object. You must provide a list of sections." for every argument, valid ones included | init tests `@IsSetOfSections(paSections)`, declared as `func @IsSetOfSections(paSections)` with an empty body (answers ""); the full `IsSetOfSections` calls `StzListQ(...).IsListOfSections()`, a method stzList does not have, and raises R14 | [ [1,3], [5,7] ], [ [1,3] ], and 'x'; IsSetOfSections([ [1,3], [5,7] ]) raises `Error (R14) : Calling Method without definition: islistofsections` while the global IsListOfSections([ [1,3], [5,7] ]) answers 1 |
| Update, UpdateWith | would fail on first use (read from the code, not run) | `CheckingParam()` is a misspelling of `CheckingParams()`, the check reads `paSections`, a variable that does not exist (the parameter is paNewSections), and the history line calls `KeepingHisto()` | not run: no object can be built |
| Copy | returns the same object (`return This`) | no copy is made | read from the code, not run |
| IntersectionWith, Intersection | always raise "Feature not implemented yet!" | the body is a single StzRaise | read from the code, not run on an object |

## stzSortedList (list/stzSortedList.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| AddQ, AppendQ (the Q forms of Add and Append) | the item is not inserted | the Q form's body is `return this` with no call to Add or Append | AddQ("c") and AppendQ("a") on [ "b", "d" ] leave [ "b", "d" ]; AddQ(3) on a six-number list leaves it unchanged; Add and Append work |

## stzTile (list/stzTile.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| SetObstacleCell, SetObstacleChar | one character is refused when it takes 4 bytes: "Incorrect param value! cChar must be a string of maximum 3 chars." | the limit is `len(cChar) < 4`, which counts bytes | SetObstacleCell("😀") raises; "X", "#" and "███" are accepted |
| ToString, Show (then Legend) | the stored obstacle text is changed by drawing: a one-character obstacle is padded to " X " the first time the tile is drawn | ToString assigns `@cObstacleChar = " " + @cObstacleChar + " "` when `IsChar(@cObstacleChar)` | Legend shows `Obstacles: X` before and `Obstacles:  X ` after ToString |
| ShowCustomGrid | a custom grid with fewer rows or columns than the tile raises R2 | the loops run over the tile's size, not the grid's | ShowCustomGrid([ [1] ]) on a 3x2 tile |

## stzComplex (number/stzComplex.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init | the pair form is unreachable: new stzComplex([2, -3]) raises `Error (R19) : Calling function with less number of parameters` | init declares two required parameters, so the one-argument pair branch cannot be used | new stzComplex([2, -3], 0) builds 2-3i |
| init | a text for a part is silently read as 0 | `if NOT isNumber(...)` resets the part | new stzComplex("x", "y") builds 0+0i |
| StzComplexQ | the factory function is not callable: `Error (R3) : Calling Function without definition: stzcomplexq` | the `func StzComplexQ` is written after the class body with no `package` or class end, so Ring reads it as a method of stzComplex | StzComplexQ(1,2) |

## stzFourier (number/stzFourier.ring)

No defect of behaviour found. One trap, recorded as a note in the doc blocks: `InverseTransform()` inverts the sequence the object holds, so `o.InverseTransform()` on [1,2,3,4] answers the inverse of that list read as a spectrum; the comment "InverseTransform(Transform()) is the identity" holds only as `new stzFourier(o.Transform()).InverseTransform()`. `Content()` returns only the real parts of complex samples.

## stzDecimalToBinary (number/stzDecimalToBinary.ring)

No defect found. Notes: a number (not a text) raises at creation; the fraction is cut at 19 binary digits.

## stzMathFunction, stzObjective (number/)

No defect found. Notes recorded in the doc blocks: after Free, ValueAt answers 0 instead of raising; SetMaxIterations and SetGradientTolerance ignore a value of 0 or less silently; the :status words come back lowercase (converged, settled, maxiterations, linesearchfailed, notfinite) because Ring folds the case of symbols.

## stzPairOfNumbers (number/stzPairOfNumbers.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| BothAreBetween (and AreBothBetween) | a first number larger than the upper bound is accepted | the test is `(c[1] >= n1 and c[2] <= n2) and (c[2] >= n1 and c[2] <= n2)`: the second number is checked twice and the first never against n2 | [ 20, 12 ] between 10 and 15 answers 1; [ 99, 5 ] between 0 and 10 answers 1; [ 12, 18 ] between 10 and 15 answers 0 correctly |
| LeastCommonMuliple alias CommonLeastMultiplier | raises `Error (R14) : Calling Method without definition: leastcommonmuliplier` | the alias calls a method of another spelling (Muliplier) | o.CommonLeastMultiplier() |

## stzSequence (number/stzSequence.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init | a fraction in the start or the step is cut to a whole number without a message | the engine sequence is integer | start 2.5 step 1 answers 2 3 4; start 0 step 0.5 answers 0 0 0; start 1 step 1.5 answers 1 2 3 |

Notes (not defects): SetBounds has no effect in mode 0 (step); after Destroy, Current and NextValue answer 0 and SetBounds is silent.

Another note for stzSequence.init: building a second sequence with a name already in use does not replace or reset it; the new object shares the existing counter and its start, step and mode are ignored (a counter standing at 20, rebuilt with start 100, still answers 20).

## stzSimilarity, stzVectorIndex (number/)

No defect found. Notes in the doc blocks: the 3-component methods read a component that is not a number as 0 without a message; CosineFromLists returns 0 when a vector is all zeros; the stzVectorIndex setters drop the built index so it is rebuilt at the next search.

## stzStringAligner (string/stzStringAligner.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init, then AlignLeft / AlignRight / AlignCenter / PadLeft / PadRight / PadBoth | the stzString object passed in is left EMPTY by the first in-place edit, while the aligner holds the result | not isolated: the aligner takes the object as given (`@oString = pStrOrStzStrObj`) and the in-place edit, which replaces the text through the engine string, empties the original; the copy-based passive forms do not | os = new stzString("hello"); oa = new stzStringAligner(os); oa.AlignRight(8, "."): oa.Content() answers "...hello", os.Content() answers ""; AlignedLeft (a copy) leaves os alone, and IsAlignedLeft does too |
| IsAlignedLeft, IsAlignedRight | TRUE whichever side the padding is on once the text is as wide as the width | `if _nLen_ >= n return 1` | "abc..." at width 6 is aligned left AND right; "abc.." at width 5 both TRUE; at width 7 left TRUE, right FALSE |
| AlignLeft, AlignRight, AlignCenter (pcChar of more than one character) | the padding text is repeated per missing character, so the result is longer than the width | the padding is not cut to one character | AlignedLeft(6, "..") on "abc" answers "abc......" (9 characters) |

## stzStringBoxed (string/stzStringBoxed.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| BoxedChars | the top and bottom borders are longer than the row of cells, and the dividers do not line up | each border cell is `"────"` (4 dashes) while each text cell is `" c │"` (3 characters before the divider) | "hello" gives a top line of 26 characters over a middle line of 21; "a😀ب" the same shape |

## stzStringCaseChanger (string/stzStringCaseChanger.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init, then Uppercase / Lowercase / Capitalize / CapitalizeEachWord / ToggleCase / DecapitalizeFirst / SetCase | the stzString object passed in is left EMPTY by the first in-place edit, while the changer holds the result | same behaviour as stzStringAligner; the passive forms (Uppercased ...) leave the object alone | os = new stzString("keep me"); oc = new stzStringCaseChanger(os); oc.Uppercase(): oc.Content() answers "KEEP ME", os.Content() answers "" |
| IsCapitalized | answers TRUE when nothing is capitalised | it only tests that the first character equals its own uppercase form | TRUE for "ABC", "123", "שלום עולם" and "😀 abc"; FALSE for "abc" and "" |
| SetCase | any case word other than :Upper, :Uppercase, :Lower, :Lowercase, :Capitalized, :Capital is ignored without a message | no else branch | SetCase(:Weird) leaves the text unchanged |

## stzStringCode (string/stzStringCode.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| IsRingCode | TRUE for ordinary words that contain a Ring keyword | the test is a substring search for func, class, def, if, but, else, ok, for, next, while, end, switch, off, return, load, see, give, new, try, catch, done | "a gift" (if), "Brendan" (end), "Seeing it" (see) answer 1; "Joyful", "good morning" and "שלום עולם" answer 0 |
| Execute | a variable the code assigns is not visible to the caller | the `eval` runs inside the method, so `x = 1 + 2` makes a local | after Execute on "x = 1 + 2", reading x raises R24 in the caller (a note rather than a defect) |

## stzStringConcat (string/stzStringConcat.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init, then Concat / Prepend / Append / ConcatMany / RepeatNTimes / JoinWith | the stzString object passed in is left EMPTY by the first in-place edit | same behaviour as stzStringAligner; the passive forms leave it alone | os = new stzString("keep"); oc = new stzStringConcat(os); oc.Concat("2"): oc.Content() answers "keep2", os.Content() answers "" |
| RepeatNTimes | a negative n silently empties the text | no check on n | RepeatNTimes(-1) on "ab" leaves "" |

## stzStringDuplicates (string/stzStringDuplicates.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init, then RemoveConsecutiveDuplicateChars / RemoveAllDuplicateChars / RemoveDuplicateSubString | the stzString object passed in is left EMPTY by the first in-place edit | same behaviour as stzStringAligner; the passive forms leave it alone | os = new stzString("aabb"); od = new stzStringDuplicates(os); od.RemoveConsecutiveDuplicateChars(): od.Content() answers "ab", os.Content() answers "" |
| RemoveDuplicateSubString, DuplicateSubStringRemoved (and the CS forms) | overlapping occurrences are all counted, so the removal eats more than the repeats, even a non-matching character | the positions come from a finder that reports overlapping matches, and each one after the first is cut out from the end | "aaa" with "aa" answers "a"; "xaaaax" with "aa" answers "xa", losing the last x; "aaaa" with "aa" answers "a"; "abab" with "ab" answers "ab" correctly |

## stzStringExtractor (string/stzStringExtractor.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| ExtractSection (so ExtractRange with a length of 0) | a start after the end KILLS the process: `thread panic: integer part of floating point value out of bounds` in stz_string.dll (exit code 3); with a gap of one the swapped section is returned and nothing is removed | the section is read with swapped bounds but RemoveSection gets the reversed pair | ExtractSection(5, 2) and ExtractSection(6, 1) on "abcdef" (panic); ExtractSection(3, 1) on "abc" (panic); ExtractSection(2, 1) answers "ab" and leaves "abcdef"; ExtractRange(2, 0) answers "ab" and removes nothing |
| Extract, ExtractCS | the answer is the whole text as it was before the removal, not the substring | `_cResult_ = @oString.Content()` is taken before the replacement | Extract("one") on "one two one three one" answers "one two one three one" and leaves " two  three " |
| ExtractCharsW (and ExtractCharsWCS) | raises `Error (R3) : Calling Function without definition: listreversed` after removing the characters | the final `ListReversed(_acResult_)` is not a defined function (ReverseList is not either) | "a1b2" with isDigit(@char) leaves "ab" and raises; "KALIDIA" with a condition that matches leaves the text unchanged and raises; no-match condition raises as well |
| ExtractNthOccurrence | an n larger than the occurrences raises "Indexes out of range!" where the code looks meant to return "" | not isolated: the code returns "" when the finder answers 0, so the finder must answer something else for n beyond the count | "a-b-c-b-d", n = 9, "b" |
| init, then every Extract verb | the stzString object passed in is left EMPTY by the first extraction | same behaviour as stzStringAligner | os = new stzString("hello world"); oe = new stzStringExtractor(os); oe.ExtractSection(1, 5): oe.Content() answers " world", os.Content() answers "" |

## stzStringGetter (string/stzStringGetter.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| NLeftChars, NRightChars (and their Q and AsString forms) | never take the right-to-left branch, so they equal NFirstChars and NLastChars for Hebrew and Arabic | `@oString.IsLeftToRight()` answers TRUE for right-to-left text (it answers TRUE to both IsLeftToRight and IsRightToLeft for Hebrew) | NLeftChars(3) of "מרחבא"-style Arabic "مرحبا بالعالم" answers "مرح", the same as NFirstChars(3); StzStringQ('שלום עולם').IsLeftToRight() and .IsRightToLeft() both answer 1; (the cause sits in stzString.IsLeftToRight, another class) |
| CharNgrams | a text containing the pipe character is cut wrongly | the engine answer is pipe-delimited and is split on every pipe | "a|b" with n = 1 answers [ "a", "", "", "b" ] |
| NthChar | position 0 answers the first character and a position past the end answers "", with no error, where NFirstChars and NLastChars raise | the stzString method clamps | NthChar(0) on "abc" answers "a"; NthChar(9) answers "" |

Note: BytesPerChar answers a text of numbers separated by spaces ("1 4 2"), not a list.

## stzStringIO (string/stzStringIO.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init, then FromFile / LoadFrom / FromFileQ | the stzString object passed in is left EMPTY while the helper holds the file content | same behaviour as stzStringAligner | os = new stzString("start"); oi = new stzStringIO(os); oi.FromFile(path): oi.Content() answers "from file", os.Content() answers "" |
| IsFilePath, IsEmail, IsBase64 | shape tests that accept what they should not | IsFilePath: a slash or backslash plus a dot anywhere; IsEmail: an @ and a dot anywhere; IsBase64: only letters, digits, + / = | IsFilePath("http://x.org/a.b") and ("1.5/2") answer 1, ("dir/file") answers 0; IsEmail("@.") and ("x.y@z") answer 1, ("a@b") answers 0; IsBase64("abc") and ("====") answer 1 |

Not run: ToFile, SaveTo, ExportTo, AppendToFile and PrependToFile into a folder that does not exist (only files in a scratch folder were written).

## stzStringPerformer (string/stzStringPerformer.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Perform, PerformOn (and PerformQ, PerformOnQ) | do nothing: the text is never changed | `StzEngineStringMapChars` is called and its result is dropped or freed without being written back; PerformOn does not even read `panPos` | Perform("upper(@char)") and PerformOn([1], "upper(@char)") on "abc" leave "abc"; Yield("upper(@char)") on the same object answers A, B, C |
| PerformW, YieldW (and their Q forms) | raise `Error (R14) : Calling Method without definition: findcharsw` for every condition | the class calls `This.FindCharsW`, which it does not have | PerformW and YieldW on "abc" and "a1b2" with W conditions |

Note: len(@char) inside an expression counts bytes (שלום gives 2 for each letter, 😀 gives 4).

## stzStringRandomizer (string/stzStringRandomizer.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| RandomInsert | empties the text in most calls instead of inserting | when the random place is inside the text the insertion is done by `new stzStringInserter(@oString).InsertBefore(...)`, which leaves the object it was given empty (the same family as the stzString-emptying defect of the other string helpers); when the place is the end, the text is appended correctly | 8 calls of RandomInsert("XY") on "hello": 6 left "", 2 gave "helloXY"; RandomInsert("-") on "שלום": 2 of 3 left "" |
| init, then Shuffle / ShuffleWords / RandomCase / RandomRemove | the stzString object passed in is left EMPTY by the first in-place edit | same behaviour as stzStringAligner | os = new stzString("abc def"); orr = new stzStringRandomizer(os); orr.Shuffle(): orr.NumberOfChars() answers 7, os.Content() answers "" |

Notes: ShuffleWords and RandomWord split on single spaces and lose repeated spaces; RandomChars(n) on an empty text answers n empty texts.

## stzStringSections (string/stzStringSections.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Range, RemoveRange, RangeRemoved | a length of 0 reads or removes a wrong stretch: it reads the pair (start, start-1), which is swapped | the range is turned into the section (start, start + range - 1) with no test for 0 | Range(2, 0) on "abcdefghij" answers "ab" (should be ""); RemoveRange(5, 0) on "0123456789" gives "01256789" (two characters removed) |
| SectionBetween | wrong text when the positions are one apart or equal | it asks Section(n1 + 1, n2 - 1), which is a reversed pair swapped by Section | SectionBetween(2, 3) answers "bc" and SectionBetween(2, 2) answers "abc" (both should be ""); (2, 6) gives "cde" correctly |
| RemoveSections, SectionsRemoved | wrong text unless the pairs are in ascending order | pairs are removed from the last to the first without sorting, so an earlier removal shifts a later one | SectionsRemoved([ [7,8], [2,3] ]) on "0123456789" answers "034567" instead of "034589"; ascending [ [2,3], [7,8] ] gives "034589" |
| Section vs RemoveSection | inconsistent treatment of positions outside the text: Section raises, the removal methods clip | different guards | Section(0, 3) raises; SectionRemoved(0, 2) answers "cdefghij" |
| init, then RemoveSection / RemoveSections / RemoveRange | the stzString object passed in is left EMPTY by the first in-place removal | same behaviour as stzStringAligner | os = new stzString("abcdef"); osx = new stzStringSections(os); osx.RemoveSection(1, 2): osx.Content() answers "cdef", os.Content() answers "" |

## stzStringTrimmer (string/stzStringTrimmer.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| TrimCharFromLeft, TrimCharFromRight (and the CS forms) | never take the right-to-left branch: Left always trims the start and Right the end, for Hebrew and Arabic too | `@oString.IsLeftToRight()` answers TRUE for right-to-left text (the cause sits in stzString.IsLeftToRight, another class) | TrimCharFromLeft("ب") on "ببمرحباب" answers "مرحباب" (the start), TrimCharFromRight("ب") then answers "مرحبا" |
| init, then Trim / TrimLeft / TrimRight / TrimStart / TrimEnd / TrimChar and the TrimChar forms | the stzString object passed in is left EMPTY by the first in-place trim | same behaviour as stzStringAligner | os = new stzString("  keep  "); ot = new stzStringTrimmer(os); ot.Trim(): ot.Content() answers "keep", os.Content() answers "" |

## stzStringVisualizer (string/stzStringVisualizer.ring)

No defect found. Notes in the doc blocks: Boxed does not frame each line of a multi-line text (the line break stays inside one box as wide as the whole character count); the caret line of VizFind assumes the quoted text is on one line; Stringify wraps a text holding a double quote in single quotes without escaping.

## stzStringWalker (string/stzStringWalker.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| WalkAndYield, CharsWithStep | a step of 0 never ends (and for WalkAndYield a negative step never ends either) | `while _i_ <= _nEnd_` / `while _i_ >= 1 and _i_ <= _nLen_` with `_i_ += nStep` and no check on the step | read from the code, NOT run because it fills memory; CharsWithStep with a negative step works: CharsWithStep(10, -3) on "abcdefghij" gives j, g, d, a |
| AddWalker | the parameter named nStep must be a LIST of steps; a number raises "Incorrect param type! the steps must be a non-empty list of numbers." from stzWalker | the value is handed to `new stzWalker(start, end, nStep)`, whose third parameter is a list | AddWalker("w1", 1, 10, 2) raises; AddWalker("w1", 1, 10, [2]) works (a naming trap, recorded as a warning) |

Notes: the walker names are case-sensitive, a name used twice is kept twice, and printing Walkers() with @@ fails because the items are stzWalker objects.

## stzStringWords (string/stzStringWords.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| ReplaceWord, RemoveWord (and the CS and Q forms) | all punctuation is lost and spaces reset to single ones, even when nothing matches | the text is rebuilt by joining `Words()` with single spaces, and Words drops punctuation | ReplaceWord("zzz", "x") on "Hello, world! It is 5.5 o clock." leaves "Hello world It is 5.5 o clock"; ReplaceWord("quick", "slow") on "The quick brown fox, the lazy dog. THE end" gives "The slow brown fox the lazy dog THE end" |
| UniqueWords vs Words | the two tokenise differently: UniqueWords cuts at spaces (keeps "fox," and "dog.", counts an emoji), Words uses Unicode word rules (drops punctuation, drops emoji) | UniqueWords splits the engine answer on " ", Words uses the engine word splitter | "The quick brown fox, the lazy dog. THE end": UniqueWords has "fox,", Words has "fox"; "שלום עולם שלום 😀 ب ب": UniqueWords lists 😀, Words does not |
| WordAtPosition vs NthWord | WordAtPosition answers "fox," with its comma where Words and NthWord give "fox" | WordAtPosition cuts at white space only | WordAtPosition(17) on "The quick brown fox, the lazy dog. THE end" |
| init, then ReplaceWord / RemoveWord | the stzString object passed in is left EMPTY by the first in-place edit | same behaviour as stzStringAligner | os = new stzString("a b a"); ow = new stzStringWords(os); ow.RemoveWord("a"): ow.Content() answers "b", os.Content() answers "" |

Note: NthWord(0) and NthWord(99) answer "" although the code raises "Index out of range!" when the engine gives no word.

