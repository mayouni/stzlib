# Defects found while documenting the library (generated)

Each row is a method whose doc block says it is broken **today**: it raises, does nothing, or answers wrongly.
They were found by calling every method once with real data before its block was written (DOCREFORM waves 1-4),
and each was checked with a second call on different data. **None is fixed yet.** The register is generated from
`reference.json` by `doc/tools/wave/mk_defects.py`: fix the method, fix its block (or drop the warning), regenerate.

**At least 49 methods in 38 classes** (the register only catches the blocks worded as defects; the per-wave notes with the evidence list more, for instance stzTimeLine.HasMoment): `doc/tools/wave/data/w*_defects*.md`.

| file | class | defects |
|---|---|---|
| math/stzMathFigure.ring | stzMathFigure | 2 |
| network/stzWebSocket.ring | stzWebSocket | 2 |
| neural/stzLLMFunction.ring | stzLLMFunction | 2 |
| number/stzHexNumber.ring | stzHexNumber | 2 |
| number/stzMatrix.ring | stzMatrix | 2 |
| number/stzNumber.ring | stzNumber | 2 |
| number/stzOctalNumber.ring | stzOctalNumber | 2 |
| object/stzListOfNamedObjects.ring | stzListOfNamedObjects | 2 |
| reactive/stzReactor.ring | stzReactor | 2 |
| string/stzStringInserter.ring | stzStringInserter | 2 |
| string/stzStringList.ring | stzStringList | 2 |
| common/stzEngineTimeline.ring | stzEngineTimeline | 1 |
| geo/stzGeoProjection.ring | stzGeoProjection | 1 |
| graph/stzGraphRule.ring | stzGraphRule | 1 |
| graph/stzMathDiagram.ring | stzMathSubstance | 1 |
| graph/stzOrgChart.ring | stzOrgChartSimulation | 1 |
| linguistic/stzText.ring | stzText | 1 |
| list/stzListBounder.ring | stzListBounder | 1 |
| list/stzListDuplicates.ring | stzListDuplicates | 1 |
| list/stzListFinder.ring | stzListFinder | 1 |
| list/stzYielder.ring | stzYielder | 1 |
| math/stzTukey.ring | stzTukeyLine | 1 |
| natural/stzNatural.ring | stzNaturalEngine | 1 |
| network/stzUrl.ring | stzUrl | 1 |
| number/stzBinaryNumber.ring | stzBinaryNumber | 1 |
| optim/stzMultiObjectiveSolver.ring | stzMultiObjectiveSolver | 1 |
| regex/stzListex.ring | stzListex | 1 |
| regex/stzListexUter.ring | stzListexuter | 1 |
| regex/stzRegexUter.ring | stzRegexuter | 1 |
| security/stzOidcProvider.ring | stzOidcProvider | 1 |
| sound/stzSoundGraph.ring | stzSoundGraph | 1 |
| string/stzString.ring | stzString | 1 |
| string/stzStringCounter.ring | stzStringCounter | 1 |
| string/stzStringDuplicates.ring | stzStringDuplicates | 1 |
| string/stzStringIO.ring | stzStringIO | 1 |
| string/stzStringReplacer.ring | stzStringReplacer | 1 |
| string/stzStringSubString.ring | stzStringSubStringCS | 1 |
| table/stzPivotTableShow.ring | TableDisplayConfig | 1 |

## stzEngineTimeline -- common/stzEngineTimeline.ring (1)

- `Duration` (line 161): Returns 0 on every call today, whatever the events are. -- answered 0 for timestamps 100, 200, 300, then 1000 and 5000, then 2.5 and 9, then 1700000000 and 1700000060, sorted or not; the span between the first and the last event is not computed

## stzGeoProjection -- geo/stzGeoProjection.ring (1)

- `Caption` (line 1082): Returns the projection written for a picture: its name, the parallels of a conic and the rotation if any. -- Defect: the parallels of a conic always carry an N, so 22.78 degrees south prints as -22.78N.

## stzGraphRule -- graph/stzGraphRule.ring (1)

- `When` (line 896): Adds a clause that selects the nodes the rule looks at: a node property tested against a value; clauses are combined with AND. -- an empty property name or an unknown operator raises an error; the ordering operators compare numbers only: on a text greaterthan and lessthan never match but greaterequal and lessequal match every node, which is a defect; an unset property reads as 0, so exists fails and missing holds for it

## stzMathSubstance -- graph/stzMathDiagram.ring (1)

- `SetData` (line 3317): Puts a number on an object under a key, which a style can read as name.key to drive a position or a colour. -- an undeclared object raises no error and the number is lost: HasData and DataOf then do not find it, which is a defect, seen with ghost and phantom; setting a key again replaces its value

## stzOrgChartSimulation -- graph/stzOrgChart.ring (1)

- `ApplyChanges` (line 3292): Applies a list of changes to the copy, never to the original, then records the before and after spans and vacancy rates. -- a change_reporting change raises "Cannot add edge: one or both nodes do not exist!", since the copy has no nodes; an unknown :type is skipped without a word

## stzText -- linguistic/stzText.ring (1)

- `SummarizedAbstractively` (line 1316): Raises error R19 today when no generative model is loaded, instead of falling back to the extractive summary. -- Raises error R19 without a generative model (checked on three texts): the fallback calls Summary without its sentence count

## stzListBounder -- list/stzListBounder.ring (1)

- `AreBoundsOf` (line 312): Raises error R14 today instead of telling whether the list's two items are the bounds of a text. -- it raises error R14 Calling Method without definition: isboundedbyin, because the stzString method it calls does not exist; tried on a pair of bounds, on a list of pairs and with the case flag; a list that is neither a pair nor a list of pairs raises Can't check bounds! List must be a pair or a list of pairs instead

## stzListDuplicates -- list/stzListDuplicates.ring (1)

- `RemoveNthDuplicate` (line 487): Leaves the list unchanged today, though it is meant to delete the nth repeat of an item. -- it does nothing: the list is unchanged on a b a c b a d for the first repeat of a, again on a second call, and with an n past the last repeat, because the delete is made on a copy of the list that List returns

## stzListFinder -- list/stzListFinder.ring (1)

- `CountItemsW` (line 728): Raises error R14 today instead of counting the items that satisfy a W condition. -- raises Calling Method without definition: countw for every condition (two conditions tried), because the class it calls has no CountW

## stzYielder -- list/stzYielder.ring (1)

- `MapIndexed` (line 107): Returns the text <list> for every item today, instead of applying an operation together with each item position. -- defect: the result holds the text "<list>" in place of the values, for every operation tried (:Square, :Abs, :Negate, :Increment) and every input; the engine call returns its items in a form the Ring side shows only as that text

## stzMathFigure -- math/stzMathFigure.ring (2)

- `Pin` (line 384): Raises an error today instead of holding a shape where it is during later solves: no shape of any figure kind has a free position to hold. -- the diagram refuses it because the rules fix every shape (checked on 35 sample figures of all ten kinds); an unknown path raises too
- `DragTo` (line 407): Raises an error today instead of moving a shape to a position and re-solving around it: no shape has a free centre to move. -- refused for every shape of 9 figures tried across the kinds; use MoveNoteTo to move a note

## stzTukeyLine -- math/stzTukey.ring (1)

- `Fit` (line 927): Fits Tukey's three-group line, then improves it with passes over the residuals, as R's line does. -- Fit(0) equals R's line with iter 1 and Fit(1) equals iter 2, so the count here is one less than R's; points that all share one x give slope 0 and intercept 0 with no error, which is a defect

## stzNaturalEngine -- natural/stzNatural.ring (1)

- `FindContextPlaceholders` (line 588): Returns the {...} holes of a narration, but today only when the text starts with the hole. -- Returns [ ] today for a hole that is not at the very start: {a} answers {a}, but x{a}, {a} x and Hello {name} from {c} all answer [ ]; the scan tests the character at i with StzMid(text, i, i) where the third argument is a length, so it can match only at the first character

## stzUrl -- network/stzUrl.ring (1)

- `FromLocalFile` (line 702): Raises error R19 today instead of returning a file URL for the given path. -- Raises error R19 today whatever the path, on a drive path with backslashes and on /tmp/y.txt: it calls ReplaceSubstring with two arguments where that method takes a start, an end and a replacement

## stzWebSocket -- network/stzWebSocket.ring (2)

- `Connect` (line 40): Raises error R3 today instead of opening a WebSocket connection. -- raises error R3 because it calls curl_easy_init, a libcurl function that the library no longer loads; the class still wraps libcurl while the rest of the network layer moved to the engine, and even with libcurl the later calls would not see the handle, which Connect keeps in a local variable
- `Close` (line 143): Does nothing today, because no connection can be open.

## stzLLMFunction -- neural/stzLLMFunction.ring (2)

- `ReturnsNumber` (line 166): Declares that the answer must be a number. -- the answer is read as the first word that parses as a number; a reply whose first word is not numeric (such as about 42 or none) raises a Ring error R41 inside the call instead of being refused or retried (w13 defect file)
- `ReturnsBoolean` (line 177): Declares that the answer must be yes or no, kept as 1 or 0. -- the reply is searched for the letters yes or true, then no or false, as substrings, so a reply such as unknown reads as 0 (w13 defect file)

## stzBinaryNumber -- number/stzBinaryNumber.ring (1)

- `ToScientificNotationForm` (line 494): Raises error R14 today instead of returning the number in scientific notation. -- it forwards to a stzNumber method of that name, which does not exist, so every call raises R14

## stzHexNumber -- number/stzHexNumber.ring (2)

- `FractionalPart` (line 264): Raises error R14 today instead of returning the digits after the point. -- it calls HexNumberWithoutPrefix, a method that does not exist, so FractionalPart and FractPart raise for every input; init also refuses a text with a point, so there is never a fraction to return
- `ToScientificForm` (line 388): Raises error R14 today instead of returning the value in scientific notation. -- it forwards to stzNumber.ToScientificForm, a method that does not exist, and passes an undefined variable; stzNumber itself raises the same R14; confirmed with 0xFF and 0x41

## stzMatrix -- number/stzMatrix.ring (2)

- `Diagonal1` (line 2961): Returns nothing today instead of the main diagonal, because its body is empty. -- the method exists but has no body, so it answers an empty value for every matrix; Diagonal gives the main diagonal
- `EigenVectors` (line 4433): Returns the unit eigenvectors as the columns of a matrix, in the same order as the eigenvalues. -- raises an error unless the matrix is square, for a defective matrix, and when an eigenvector is complex

## stzNumber -- number/stzNumber.ring (2)

- `SetDefaultFormat` (line 8937): Raises an unsupported-feature error today instead of setting the default number format. -- the call raises an unsupported-feature error today
- `ApplyLocale` (line 8946): Raises an unsupported-feature error today instead of applying a locale to the number. -- the call raises an unsupported-feature error today

## stzOctalNumber -- number/stzOctalNumber.ring (2)

- `ToBaseNForm` (line 228): Raises error R14 today instead of writing the value in another base. -- it forwards to ToBaseNForm on stzNumber, a method that does not exist there (stzNumber has IntegerPartToBaseNForm), so every base raises R14; confirmed with 0o377 and 17
- `ToScientificNotationForm` (line 242): Raises error R14 today instead of writing the value in scientific notation. -- it forwards to ToScientificNotationForm on stzNumber, a method that does not exist there; stzNumber raises the same R14 on its own

## stzListOfNamedObjects -- object/stzListOfNamedObjects.ring (2)

- `init` (line 68): Raises error R14 today instead of building a list of named objects from the given list. -- the check calls IsListOfNamedObjects on a stzList, a method that does not exist, so every list raises R14 Calling Method without definition: islistofnamedobjects (tried with an empty list and with one object); a value that is not a list raises Incorrect param type
- `Copy` (line 97): Raises error R14 today instead of returning a copy of the list: it builds a new one through init, which raises.

## stzMultiObjectiveSolver -- optim/stzMultiObjectiveSolver.ring (1)

- `exportParetoFrontCSV` (line 1154): Raises error R41 today instead of writing the front to a file, one row per solution. -- a variable value, a number, is joined to a comma with + and Ring cannot add a number to a text; it raises for the front of every problem tried (two problems, epsilon-constraint method)

## stzReactor -- reactive/stzReactor.ring (2)

- `SubmitSpawn` (line 211): Starts a program on the loop and returns at once with the job id; the program runs off the Ring thread and its output is fetched later. -- a plain text instead of a list raises error R21, because the wrap into a list is skipped inside the method
- `Spawn` (line 289): Runs a program and waits for it to end, returning what it printed; the exit code is then in SpawnLastStatus. -- a plain text instead of a list raises error R21, because the wrap into a list is skipped inside SubmitSpawn

## stzListex -- regex/stzListex.ring (1)

- `NormalizeListString` (line 1120): Raises error R3 today instead of removing the spaces from the text of a list. -- raises Calling Function without definition: @stzreplace (R3), because it calls a function that does not exist

## stzListexuter -- regex/stzListexUter.ring (1)

- `GetDependencyChain` (line 461): Raises a stack overflow today instead of returning the triggers a trigger depends on. -- every log entry lists its own trigger in dependson, so the method calls itself on that same trigger without end; confirmed with the triggers pair and t1

## stzRegexuter -- regex/stzRegexUter.ring (1)

- `GetDependencyChain` (line 410): Raises a stack overflow today instead of returning the triggers a trigger depends on. -- every log entry lists its own trigger in dependson, so the method calls itself on that same trigger without end; confirmed with the trigger num and the trigger d

## stzOidcProvider -- security/stzOidcProvider.ring (1)

- `IssueIdTokenAt` (line 526): Signs an ID token as IssueIdToken does, with the issue time you give, so that exp is pnNow plus the token lifetime. -- same escaping defect as IssueIdToken

## stzSoundGraph -- sound/stzSoundGraph.ring (1)

- `OutputNode` (line 183): Returns the index of the node the graph hands to the world. -- a node added after the graph was prepared can reset this to 0, see the defects file

## stzString -- string/stzString.ring (1)

- `IsCurrencySymbol` (line 9370): Answers FALSE today: the currency symbol check is a stub that waits for the locale data.

## stzStringCounter -- string/stzStringCounter.ring (1)

- `CountBetween` (line 214): Raises an error today instead of counting a fragment inside a section of the text. -- it calls the function StringNumberOfOccurrenceCS, which does not exist, so CountBetween and CountBetweenCS raise R3 for every input; confirmed with Banana banana and with xyzxyz

## stzStringDuplicates -- string/stzStringDuplicates.ring (1)

- `DuplicateSubStringRemoved` (line 281): Returns the text with the later occurrences of a substring removed, leaving the helper unchanged. -- the same overlap defect

## stzStringIO -- string/stzStringIO.ring (1)

- `FromClipboard` (line 328): Raises the error "Clipboard access is not supported in this environment!" today. -- Always raises, it is a placeholder

## stzStringInserter -- string/stzStringInserter.ring (2)

- `InsertAfterManyPositions` (line 606): Raises error R13 today instead of inserting a fragment after each of several positions. -- raises Object is required (R13) for every valid list of numbers: [1,3,5] on banana and [2] on abc; probable cause the line that sorts the positions with new stzList(panPos).SortedInDescending(), since the same call made in two statements works; an empty or non-numeric list raises Incorrect param type instead
- `InsertBeforeManyPositions` (line 638): Raises error R13 today instead of inserting a fragment in front of each of several positions. -- raises Object is required (R13) for every valid list of numbers: [1,3,5] on banana; probable cause the line that sorts the positions with new stzList(panPos).SortedInDescending(); an empty or non-numeric list raises Incorrect param type instead

## stzStringList -- string/stzStringList.ring (2)

- `SortBy` (line 1311): Sorts the strings in place by a numeric key computed from each one, such as its length; a text key raises. -- @item is not defined here and raises R24, and a key that is text raises R41 because keys are compared with a greater-than, so only numeric keys such as len(@string) work
- `Matches` (line 1756): TRUE if every string matches the pattern as a whole, so "a." matches ab and "a" does not; an empty list is TRUE. -- the old comment says it returns the strings that match, but it answers one verdict for the whole list

## stzStringReplacer -- string/stzStringReplacer.ring (1)

- `RemoveLast` (line 530): Leaves the text unchanged today, because the occurrence it aims at is one past the last, in place. -- it asks the nth removal for a rank equal to the number of occurrences, and that rank counts from 0 in the default case-sensitive call, so nothing is removed: one two one two one, aaa bbb and its b stay as they are; RemoveLastCS(..., 0) does remove the last occurrence

## stzStringSubStringCS -- string/stzStringSubString.ring (1)

- `Positions` (line 182): Raises error R14 today instead of returning the position of every occurrence. -- it calls FindAllCS on the finder, a method that does not exist, so Positions and Occurrences raise for every input; confirmed with Banana bandana and with banana

## TableDisplayConfig -- table/stzPivotTableShow.ring (1)

- `GetDimensionGroupWidth` (line 464): Raises error R5 today instead of returning the width of one group of columns. -- it reads a variable that belongs to CalculateLayout and is empty here; the same error for 1 and for 2
