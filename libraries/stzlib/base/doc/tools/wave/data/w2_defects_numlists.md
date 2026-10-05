# Defects found while documenting stzListOfNumbers and stzListOfLists (code, not comments; none fixed)

## stzListOfNumbers (file number/stzListOfNumbers.ring)
- Absolute, Absoluted: raise R24 (_nlen_ uninitialised): `This.Content()*` has a stray `*` that joins the next line.
- Negate: does nothing (edits a local copy); Negated: returns the numbers unchanged.
- Cumulate: loop starts at 3, second number never added to the first ([1,2,3,4,5] -> [1,2,5,9,14]); Cumulated: raises R24 (CumulateQRT reads unset pcReturnType).
- MeanByCoefficient: R11, builds class steListOfNumbers (does not exist).
- OnlyUnicodes: R3, IsUnicodeNumber undefined.
- Walker: R11, class stzWalker undefined.
- MinZ / MaxZ (derived forms, not roots): both return TopNZ(1)[1], so MinZ answers the MAXIMUM with its position.
- Bottom/Top N AndTheirPositions (16 roots): numbers and positions are two separately ordered lists paired by index; right only for an ascending list without repeats.
- Neighbors and 6 misspelled aliases: absent n greater than the COUNT of numbers answers only the largest ([4,7,10,3,6,9], 8 -> [10]); `_n_ > _nLen_` compares with the count.
- Closest: R19, calls Nearest() without n.
- ContainsADividableNumberBy: tests the product, raises for a negative product; DividableNumbersBy: ignores n, keeps evens (`% 2`).
- EachMultipliedWithW, EachDividedWithW: R19 (call the WQ chaining form with one argument); MultiplyEachWithW, DivideEachWithW: drop the numbers that fail the condition and require @i.
- ARandomNumber, ANumber, AnyRandomNumber, AnyNumber, ANumberLessThan, NRandomNumbers: `ARandomNumberBetween(1, size)` resolves to the class's own method (alias of AnyNumberBetween, exclusive), so a list number is used as a position; raises "No valid numbers found in the list!" when none lies strictly between 1 and the size.
- ANumberGreaterThan, NNumbersGreaterThan: R14 (NumbersGreaterThanQRT / ...Q undefined); NNumbersLessThan: R14 (NRandomNumbers missing on the Q object); NNumbersOtherThan: R19 and looks up the count instead of the number.
- AnyNumberBeforeOrAfter: treats the returned number as a position. AnyNumberAfter: looks n up in the REVERSED list and uses that position forward (200 in [100..500] always 500). AnyNumberAfterPosition: position computed between n-1 and 2n-3, not after n.
- AnyNumberNotBetweenPositions: R3 (AnyNumberNotIn undefined); AnyNumberOutsidePosition: R24 (_anPos_ never set); NItemsOutsidePositionZ: R4 infinite recursion.
- SomeNumbersLessThan, SomeNumbersGreaterThan, SomeNumbersBetween, SomeNumbersNotBetween: R3, call StzListOfNumbers() (function is StzListOfNumbersQ).
- SomeNumbersOtherThan: second parameter ignored.
- SortByInDescending, SortByDown, SortedByInDescending: R13, `new stzList(...).Reversed()` chain.
- AreGreaterThen / AreSmallerThen: test >= / <= (not strict).
- Nearest family fine; NearestXT(5, :After) / FarthestXT answer "" or raise (not roots, not documented).
- NumbersW('@number > 3') answered [ ] on the probe list (not a root, not investigated).

## stzListOfLists (file list/stzListOfLists.ring)
- ListAt: R19 (NthList() without n).
- FindInLists (+ aliases): raises for a number item or lists holding numbers (StzFindAll accepts text only); FindItemsInLists: R24 (pItem unset); FindSubListInListsCS: raises "non implemented yet"; FindSubListInList: R14 (FindSubListInListCS undefined).
- PositionsW (and ListsW, FindListsW...): R24, collects into `_aResult_` while the evaluated code writes `aResult`.
- JustifyEachListWith: declared without a parameter but reads pItem (R24 / R20).
- ExtendToByRepeatingItems, ExtendToWithItemsRepeated, ExtendedToByRepeatingItems, ExtendedToWithItemsRepeated, ExtendByRepeatingItems, ExtendWithItemsRepeated, ExtendByItemsRepeated, ExtendedByRepeatingItems: R14 (stzList has no ExtendedToByRepeatingItems).
- ExtendToWithItemsIn, ExtendToUsingItemsIn, ExtendedToWithItemsIn, ExtendWithItemsIn, ExtendUsingItemsIn, ExtendedWithItemsIn: R14 (ExtendedToWithItemsIn missing on stzList).
- AdjustedToSmallest, AdjustedToSmallestSize, AdjustedToSmallestList, AdjustedToMin, AdjustedToMinSize, AdjustedToMinList: no `return`, answer lost.
- ShrinkToWith, ShrinkToUsing (and the Shrinked passive forms): the item is never used; n greater than the longest list drops every list (content becomes []).
- Pairify with other than exactly two same-size lists: R21/R24 (documented as raising).
- Entry family (EntryByPosition, EntryByNumberOfOccurrence, Entry, NumberOfOccurrenceOfEntry, HowManyEntry, HowManyEntries, NthOccurrenceOfEntry, FirstOccurrenceOfEntry, LastOccurrenceOfEntry): R14, IndexOn undefined.
- Merge, Flatten: always raise by design ("use Merged()/Flattened()").
- SortDownNthList, SortNthListInDescending, NthListSortedDown: R13 (`new stzList(...).Reversed()` chain).
- Classify, ClassifyOn, ClassifyBy, ClassifyOnBy: R14, StringifyNamedObjectsQ undefined on the first column object.
- RemoveCol, RemoveNthCol, RemoveColumn, RemoveNthColumn, RemoveNthItems, ColRemoved: early check `_n_ > number of LISTS` (should be columns); 2 lists x 3 items: RemoveCol(3) does nothing.
- RemoveCols, RemoveTheseCols, RemoveTheseColqQ, RemoveManyCols, RemoveManyColqQ, RemoveColumns, RemoveTheseColumns, RemoveManyColumns, ColsRemoved: R14, IsAtOrAtPositionsNamedParams undefined.
- InsertCol / InsertItems: cannot append after the last column (n must be an existing column).
- ToListInStringInShortForm: R21; ToStzListOfpairsOfNumbers: R11 (class missing); SpeedUp, GainFactor: R21 (divide lists).
- AreContiguous / @AreContiguous: a list mixing text and numbers raises "Bad parameter type!"; @AreContiguous ignores its argument.
- Updated returns its argument unchecked (documented as a note, not a defect).
- Copy uses `new stzListOflists` (case-insensitive, works).
