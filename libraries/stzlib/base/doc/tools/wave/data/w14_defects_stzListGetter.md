# Wave 14 defects: stzListGetter, stzListMerger, stzListRemover, stzListSplits, stzListClassifier, stzListOfSections, stzListComparator, stzListDuplicates, stzListMover, stzListWalker, stzSet, stzListBounder, stzListExtractor, stzListStringify

Found by calling every root method with real data (invented lists, Hebrew, Arabic, emoji); each defect was confirmed with a second call on different data before being written here. Nothing was fixed. Each is recorded as a warning in the doc block of the method. Helper classes of stzList: all take `new stzListX(aList)` or a stzList and work on their own copy; no class emptied the stzList passed to it (checked on Remover, Mover, Duplicates, Bounder, Extractor, Stringify, Classifier, Splits, Getter, Merger).

## stzListGetter (list/stzListGetter.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| OnlyChars | a single non-ASCII character is left out | a character counts as one only when `len(text) = 1`, which is the byte length | ["é","😀","x","ا","xy"] answers just ["x"]; ["ab",1,"c",[1,2],2.5,"שלום","ש"] answers ["c"] |
| Range | a count of 0 answers two items instead of [ ] | Range calls Section(n, n + 0 - 1), whose start is larger than its end and Section swaps them | Range(2, 0) on a b c d e f g answers a b |
| NthItem, FirstItem, LastItem, CentralItem, NFirstItems, NLastItems, Head, Tail, ItemsAtPositions, RandomItem | a position or count outside the list raises R2 (not a defect of logic; a contrast with Bounder.NFirstItems and Getter.Section, which clip) | the list is indexed directly | NthItem(99), NthItem(0), NFirstItems(99), NLastItems(99) on a b c, FirstItem and RandomItem on an empty list |

## stzListRemover (list/stzListRemover.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| RemoveItemAtPosition, RemoveAt, RemoveAtPosition, RemoveNthItem | a negative position kills the whole Ring process: `panic: integer part of floating point value out of bounds` (stz_list.dll) | a negative n passes the guard (only 0 is refused) and reaches StzEngineListRemove | RemoveItemAtPosition(-1) on a b c; RemoveItemAtPosition(-2) on 10 20 |
| RemoveLastItem, LastItemRemoved, RemoveFirstAndLastItems | on an empty list (or, for the last one, a list of one item) they raise `Incorrect param! n must be a number different from zero` | the position asked for is NumberOfItems = 0 | RemoveLastItem on [ ]; RemoveFirstAndLastItems on ["x"] |
| RemoveItemsAtPositions, RemoveAtPositions | a position listed twice deletes two different items | positions are removed one by one from the last to the first and a repeat is not dropped | [2, 2] on a b c leaves a |

## stzListSplits (list/stzListSplits.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Split, SplitAt, SplitBefore, SplitAfter, SplittedAt | a number is always read as a position, so a list of numbers cannot be cut at one of its items | `isNumber(pItem)` routes to the position methods | Split(30) on 10 20 30 40 50 answers one part |
| SplitAfter | cuts only after the LAST occurrence of an item, where SplitBefore cuts at every occurrence | the code splits after the last position found, as its own comment says | a b - c d - e after - gives a b - c d - / e |
| SplitAt, SplitBefore | an absent item gives [[all]] for SplitAt and the flat list for SplitBefore | SplitAt always calls SplitAtPositions, SplitBefore only when a position is found | on x y z with "q" |
| Split | the call mutates and returns an empty text; a second call works on the parts and wraps them | Split is the in-place verb under a name that suggests an answer | Split("-") then Split("-") gives [[[a, b], ...]] |
| SplitAtPacer, SplittedAtPacer | a pace of 0 never ends (not run) | `while i <= len` with `i = i + 0` appends forever | read from the code, not run, because it fills memory |

## stzListClassifier (list/stzListClassifier.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Classify, Classes, NumberOfClasses, Parts (and ClassifyQ) | a list made of numbers answers [ ] / 0 | the engine classifier returns nothing for number items | [1, 2, 2, 3, 3, 3] and [1, 2, 2.5, 2, 3, 3, 3, 1] |
| Classify, Frequencies, Mode, MostFrequent, ItemsAppearing* versus FrequencyOf | case handling disagrees: the first fold ASCII capital and small letters, FrequencyOf compares exactly | Classify and Frequencies call the engine with case flag 0, FrequencyOf calls CountCS with 1 | a B a b c a: Frequencies gives B 2, FrequencyOf("b") gives 1; é and É stay apart |
| Parts | PartsCS takes a case flag and ignores it | PartsCS returns Classify() | PartsCS(1) and Parts() answer the same |
| Partition | n = 0 raises R1 Can't divide by zero | ceil(len / n) | Partition(0) |

## stzListOfSections (list/stzListOfSections.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| ContiguousSectionsMerged, IncludedSectionsMerged, OverLappedSectionsMerged, Merged, SectionsMerged | the "Merged" forms also change the object | `Copy()` returns `This`, not a copy, and the forms are `This.Copy().MergeXQ().Content()` | Content after the call equals the merged result on four datasets |
| MergeContiguous | sections swallowed when the input is not sorted | it never sorts and keeps the first section's start | [10,12] [6,8] [1,5] [4,9] answers [10,12]; [5,6] [1,2] answers [5,6] |

## stzListComparator (list/stzListComparator.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| IsReverseOf (and CS form) | raises R3 Calling Function without definition: listreversed | the function does not exist | [1,2,3,4] against [4,3,2,1], against itself, and a b c texts |
| IsSortedLike | TRUE for any two lists of the same size | `StzFindFirst(...) >= 0` is true even when the find answers 0 | [1,2,3,4] against [10,30,20,40] and [40,30,20,10]; [b,a,c] against [x,y,z] |
| IsEqualTo, IsNotEqualTo, IsPermutationOf | repeats are ignored: [1,1,2] equals [1,2,2] and is "a permutation" of it | mutual subset check of the sets plus the same size | [1,1,2] against [1,2,2]; IsEqualTo is documented set-based, IsPermutationOf is not a permutation test |

## stzListDuplicates (list/stzListDuplicates.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| RemoveNthDuplicate (and CS form) | does nothing | `ring_remove(This.List(), pos)` removes from the copy that List returns | a b a c b a d: first repeat of a, again, an n past the last, and a CS 0 call on a A b B a leave the list as it was |

## stzListMover (list/stzListMover.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| RotateLeft, RotateRight, RotatedLeft, RotatedRight | a negative n kills the whole Ring process: `panic: integer part of floating point value out of bounds` (stz_list.dll) | the negative count reaches StzEngineListRotateLeft/Right unchecked (the panic is in the engine call) | RotatedLeft(-1) on 1 to 5; RotateRight(-1) on x y z |
| Move, Swap | a position outside the list moves nothing and says nothing | the guard returns silently | Move(9, 1), Move(0, 1), Swap(1, 9) |

## stzListWalker (list/stzListWalker.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| AddWalker, Walkers, Walker | raise R24 Using uninitialized variable: @awalkers | the attribute @aWalkers is never declared in the class | on two different lists |
| WalkNForward, WalkNBackward, WalkForthAndBack, WalkZigZag | a step of 0 never ends (not run) | the loop adds 0 | read from the code, not run, because it fills memory |
| WalkZigZag, WalkForthAndBack | the last position appears twice when the step lands exactly on it | the turning point is added again | 7 items, step 2: 1 3 5 7 7 5 3 1 |
| WalkBetween, WalkFromTo | positions are not clipped to the list | no check against NumberOfItems | WalkBetween(1, 99, 3) on 7 items goes to 97 |
| WalkAccumulating | a plain map, not an accumulation | it calls `@oList.Map(pcExpr)` | "@item * 2" gives each item doubled, not a running total |

## stzSet (list/stzSet.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init, Update (and UpdateWith, UpdateBy, UpdateUsing), UnionWith | the intended error is replaced by R3 Calling Function without definition: stzseterror | `stzSetError()` does not exist | new stzSet("abc"), Update([1,1,2]), UnionWith(["x","x"]) |
| AddElement | a text or a number raises `Incorrect param type! paList must be a list`; a list element already present raises R3 | AddElement calls Contains, which this class overrides to take a set | 7, 8 and "z" on three sets; AddElement([1]) when [1] is present |
| Contains, Includes, IsIncludedIn | a single item instead of a list raises the same error, so they cannot test whether one item is in the set | Contains is redefined as Includes of a set | Contains("x") on x y |
| Updated | returns its argument and computes nothing | the body is `return paOtherSet` | Updated([1,2]) answers [1,2] whatever the set holds |
| Subsets, SubSetsOfNElements, NumberOfSubsets | answer an empty text / 0 | the bodies are `// TODO` | any set |
| UnionWithMany, IntersectionWithMany | not roots, read from the code, not run: UnionWithMany reads an undefined `paListOfLists`, IntersectionWithMany is a TODO | | |

## stzListBounder (list/stzListBounder.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| AreBoundsOf (and CS form) | raises R14 Calling Method without definition: isboundedbyin | stzString has no IsBoundedByIn | on a pair, a list of pairs, with the case flag |
| IsBoundedBy | on an empty list raises `Index outside the list!` instead of answering FALSE | FirstItemQ on an empty list | IsBoundedBy(["a","b"]) on [ ] |
| Section | raises when a position is outside the list, where stzListGetter.Section clips (contrast) | explicit range check | Section(1, 5) and Section(0, 9) on four or five items |

## stzListExtractor (list/stzListExtractor.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Extract | removes every occurrence of the item, and returns the item once | it calls RemoveCS, which removes all | a b c b d e: Extract("b") leaves a c d e |
| ExtractRange | a run past the end raises `Indexes out of range!` | the section is checked, not cut | ExtractRange(2, 9) on three items |
| ExtractNthOccurrence, ExtractFirstOccurrence, ExtractLastOccurrence | a missing occurrence answers an empty text, which cannot be told from an empty-text item | | ExtractNthOccurrence(9, "a") |

## stzListStringify (list/stzListStringify.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| StringsToNumbers | a text that is not numeric raises R41 Invalid numeric string; an empty text becomes 0 | `isNumber(0 + text)` evaluates `0 + "abc"` | "abc"; "x"; "7x"; "" gives 0 |
| Join | a sublist item becomes an empty text | the engine join writes nothing for a list | 1, [2,3], 4 with "+" gives 1++4; a, [1,2], c gives a--c |
| StringifyObjects, ObjectsStringified, Stringify | an object is written as `@noname` | @ObjectVarName finds no variable name for an object held in a plain variable | a stzString("hi") in the list |
