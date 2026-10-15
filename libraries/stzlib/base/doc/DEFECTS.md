# Defects found while documenting the library (generated)

Each row is a method whose doc block says it is broken **today**: it raises, does nothing, or answers wrongly.
They were found by calling every method once with real data before its block was written (DOCREFORM waves 1-4),
and each was checked with a second call on different data. **None is fixed yet.** The register is generated from
`reference.json` by `doc/tools/wave/mk_defects.py`: fix the method, fix its block (or drop the warning), regenerate.

**At least 382 methods in 97 classes** (the register only catches the blocks worded as defects; the per-wave notes with the evidence list more, for instance stzTimeLine.HasMoment): `doc/tools/wave/data/w*_defects*.md`.

| file | class | defects |
|---|---|---|
| datetime/stzCalendar.ring | stzCalendar | 25 |
| list/stzItem.ring | stzItemCS | 20 |
| geo/stzGeoMap.ring | stzGeoMap | 18 |
| regex/stzMatrex.ring | stzMatrex | 17 |
| file/stzFile.ring | stzFileManager | 15 |
| datetime/stzListOfTimeLines.ring | stzListOfTimeLines | 14 |
| common/stzCache.ring | stzCache | 13 |
| graph/stzGraph.ring | stzGraph | 12 |
| regex/stzRegexMaker.ring | stzRegexMaker | 12 |
| graph/stzOrgChart.ring | stzOrgChart | 10 |
| regex/stzRegex.ring | stzRegex | 10 |
| string/stzStringChar.ring | stzStringChar | 10 |
| reactive/stzReactive.ring | stzReactiveSystem | 7 |
| common/stzOccurrences.ring | stzOccurrences | 6 |
| extercode/stzImageToAscii.ring | stzImgToAscii | 6 |
| list/stzListProvidedAsString.ring | stzListProvidedAsString | 6 |
| number/stzListOfBytes.ring | stzListOfBytes | 6 |
| string/stzTextStream.ring | stzTextStream | 6 |
| common/stzCache.ring | stzCacheStorage | 5 |
| geo/stzGeoField.ring | stzGeoField | 5 |
| geo/stzGeoSamples.ring | stzGeoSamples | 5 |
| graph/stzDiagram.ring | stzDiagram | 5 |
| graph/stzGridNav.ring | stzGridNav | 5 |
| common/stzConstraint.ring | stzConstraint | 4 |
| list/stzListChecker.ring | stzListChecker | 4 |
| list/stzListOfPairs.ring | stzListOfPairs | 4 |
| list/stzTree.ring | stzTree | 4 |
| string/stzStringSplitter.ring | stzStringSplitter | 4 |
| file/stzHtml.ring | stzHtmlBuilder | 3 |
| graph/stzGraph.ring | stzGraphComparison | 3 |
| graph/stzWorkflow.ring | stzWorkflowSimulation | 3 |
| list/stzListWalker.ring | stzListWalker | 3 |
| list/stzSet.ring | stzSet | 3 |
| natural/stzChainOfTruth.ring | stzChainOfTruth | 3 |
| natural/stzChainOfValue.ring | stzChainOfValue | 3 |
| natural/stzEntity.ring | stzEntity | 3 |
| object/stzListOfObjects.ring | stzListOfObjects | 3 |
| regex/stzRegexMaker.ring | stzRecursiveRegexMaker | 3 |
| regex/stzTimex.ring | stzTimex | 3 |
| sound/stzSoundLive.ring | stzSoundLive | 3 |
| stats/stzCoeffExtractor.ring | stzCoeffExtractor | 3 |
| stats/stzDataSet.ring | stzDataSet | 3 |
| stats/stzLinearSolver.ring | stzLinearSolver | 3 |
| string/stzStringChecker.ring | stzStringChecker | 3 |
| string/stzStringPerformer.ring | stzStringPerformer | 3 |
| string/stzStringText.ring | stzStringText | 3 |
| appserver/stzAppServer.ring | stzAppServer | 2 |
| datetime/stzDate.ring | stzDate | 2 |
| file/stzZipFile.ring | stzZipFile | 2 |
| geo/stzGeoFeatures.ring | stzGeoFeatures | 2 |
| geo/stzGeoProcess.ring | stzGeoProcess | 2 |
| graph/stzGraphQuery.ring | stzGraphQuery | 2 |
| graph/stzKnowledgeGraph.ring | stzKnowledgeGraph | 2 |
| list/stzSetOfSections.ring | stzSetOfSections | 2 |
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
| file/stzFile.ring | stzFileInfo | 1 |
| file/stzFile.ring | stzFileModifier | 1 |
| file/stzFile.ring | stzFileOverwriter | 1 |
| file/stzFile.ring | stzFileXT | 1 |
| geo/stzGeoProjection.ring | stzGeoProjection | 1 |
| graph/stzGraphRule.ring | stzGraphRule | 1 |
| graph/stzMathDiagram.ring | stzMathSubstance | 1 |
| graph/stzOrgChart.ring | stzOrgChartReporter | 1 |
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

## stzAppServer -- appserver/stzAppServer.ring (2)

- `Use` (line 492): Leaves every request unchanged today instead of running the middleware before the routes under a path. -- The middleware is stored in the router but nothing ever reads the list, so it never runs (checked with paths /a, / and *)
- `Static` (line 504): Leaves a folder unserved today instead of serving its files under a path; a request for a file in it answers 404. -- The static routes are stored in the router but nothing ever reads the list (checked with paths /files and /)

## stzCache -- common/stzCache.ring (13)

- `init` (line 127): Raises error R11 today instead of building a cache that stores its entries in a file. -- it builds a stzCacheStorage, which builds a stzStorage; that class sits in the future folder and is not loaded, so the error names class stzstorage not found; with the class loaded the next error is the call to the undefined TextFileCreateIfInexistant; no cache can be built today
- `StorageType` (line 136): Raises error R13 today instead of returning where the cache keeps its entries. -- the storage object it asks is never built, because init raises
- `CacheOpen` (line 172): Raises error R13 today instead of opening the cache's file or database. -- it starts by asking StorageType, which raises; the file and database calls it would make (TextFileOpen, DatabaseConnect) are not defined anywhere
- `CacheFileHandler` (line 186): Raises error R13 today instead of returning the handle of the cache's file. -- the storage object it asks is never built, because init raises
- `CacheFileColse` (line 195): Raises error R3 today instead of closing the cache's file. -- the name is misspelled (Colse for Close) and no such function exists under either spelling
- `CacheFindEntry` (line 206): Raises error R13 today instead of returning the line number of the entry for a function call. -- it reads the cache file through the storage object that init never builds
- `CacheGetCachedResult` (line 229): Raises error R13 today instead of returning the cached result of a function call. -- it starts with CacheFindEntry, which raises
- `CacheGetResultInLineNumber` (line 243): Raises error R13 today instead of returning the result stored on one line of the cache file. -- it reads the cache file through the storage object that init never builds
- `CacheFileLines` (line 254): Raises error R13 today instead of returning the lines of the cache file. -- it needs the file name from the storage object that init never builds
- `CacheFileLineNumber` (line 282): Raises error R13 today instead of returning one line of the cache file. -- it starts with CacheFileLines, which raises
- `CacheFileNumberOfLines` (line 290): Raises error R13 today instead of returning how many lines the cache file holds. -- it starts with CacheFileLines, which raises
- `ComposeLine` (line 299): Raises error R3 today instead of joining the parts of an entry into one line with a bar between them. -- the function it calls is not defined anywhere in the library
- `AddLine` (line 310): Raises error R13 today instead of appending an entry to the cache file. -- it starts by asking StorageType; the file call it would make (TextFileAddLine) is not defined, and the :InMemomry and :InDatabase branches are empty TODOs, the first misspelled

## stzCacheStorage -- common/stzCache.ring (5)

- `init` (line 349): Raises error R11 today instead of building the storage behind a cache. -- it builds a stzStorage, which sits in the future folder and is not loaded, so the error names class stzstorage not found; with that class loaded the next error is the call to the undefined TextFileCreateIfInexistant; a stzCacheStorage cannot be built today
- `FileHandler` (line 357): Raises error R13 today instead of returning the handle of the storage file. -- it forwards to a stzStorage that init never builds
- `FileName` (line 365): Raises error R13 today instead of returning the storage file's name. -- it forwards to a stzStorage that init never builds
- `CompleteFileName` (line 373): Raises error R13 today instead of returning the storage file's name with its folder. -- it forwards to a stzStorage that init never builds
- `StorageType` (line 381): Raises error R13 today instead of returning where the storage keeps its entries. -- it forwards to a stzStorage that init never builds

## stzConstraint -- common/stzConstraint.ring (4)

- `init` (line 96): Raises error R14 today instead of building a constraint from an object and a condition. -- every call with an object and a text raises R14 Calling Method without definition: removefirstboundq, thrown by IsConstraint; any other argument raises Incorrect types of object params, so no stzConstraint can be built today
- `Name` (line 132): Returns the name of the constraint, which nothing sets today. -- always empty: the field it reads is never assigned anywhere in the class
- `Expression` (line 141): Raises error R24 today instead of returning the Ring code that tests the condition. -- reads a variable _cConstraint_ that is never assigned (the field is @cConstraint), so it raises R24 Using uninitialized variable on every call
- `CheckConstraint` (line 158): Returns 0 on every call today, whether or not the guarded object obeys the condition. -- always 0: the evaluation runs inside a try, and Expression raises first, so the failure is swallowed and reported as a broken constraint; checked on an object that obeys the condition and one that does not

## stzEngineTimeline -- common/stzEngineTimeline.ring (1)

- `Duration` (line 161): Returns 0 on every call today, whatever the events are. -- answered 0 for timestamps 100, 200, 300, then 1000 and 5000, then 2.5 and 9, then 1700000000 and 1700000060, sorted or not; the span between the first and the last event is not computed

## stzOccurrences -- common/stzOccurrences.ring (6)

- `SubString` (line 68): Returns an empty text today instead of the substring that was searched. -- the constructor stores the substring in @pcSubStr while this method reads @cSubStr, so the answer is always empty; checked with plain texts and with the :Of form
- `String` (line 80): Returns an empty text today instead of the string that was searched. -- the constructor stores the string in @pcStr while this method reads @cStr, so the answer is always empty; checked with plain texts and with the :In form
- `Removed` (line 103): Raises error R14 today instead of returning the string with the substring cut out at every occurrence. -- calls RemoveSubStringAtPositionsCSQ, a method stzString does not have; the stored string is also empty, see String
- `ReplacedWithCS` (line 113): Does nothing today: the body is empty. -- an unfinished stub with no parameters and no code; it answers an empty value
- `Uppercased` (line 120): Does nothing today: the body is empty. -- an unfinished stub with no code; it answers an empty value
- `Lowercased` (line 127): Does nothing today: the body is empty. -- an unfinished stub with no code; it answers an empty value

## stzCalendar -- datetime/stzCalendar.ring (25)

- `AvailableHours` (line 1086): Raises Not yet implemented! today instead of returning the list of available hour slots of the calendar. -- the body is a stub that raises Not yet implemented!; the form that works is AvailableHoursN
- `AvailableHoursBetween` (line 1139): Raises Not yet implemented! today instead of returning the available hour slots between two dates. -- the body is a stub that raises Not yet implemented!; the form that works is AvailableHoursBetweenN
- `HasAvailableHoursBetween` (line 1222): Raises Not yet implemented! today instead of telling whether the range holds available hours. -- calls AvailableHoursBetween, which is a stub
- `AvailableHoursOn` (line 1232): Raises Not yet implemented! today instead of returning the available hour slots of one day. -- the body is a stub that raises Not yet implemented!; the form that works is AvailableHoursOnN
- `ContainsAvailableHoursOn` (line 1320): Raises Not yet implemented! today instead of telling whether a day has available hours. -- calls AvailableHoursOn, which is a stub
- `HasAvailableHoursOn` (line 1330): Raises Not yet implemented! today instead of telling whether a day has available hours. -- calls AvailableHoursOn, which is a stub
- `AvailableDaysBetween` (line 1414): Raises Not yet implemented! today instead of returning the available days between two dates. -- the body is a stub that raises through raise()
- `AvailableDaysBetweenN` (line 1434): Raises error R14 today instead of counting the available days between two dates. -- calls AvailabelDaysBetween, a misspelling of a method that is itself a stub
- `ContainsAvailableDaysBetween` (line 1450): Raises error R14 today instead of telling whether the range holds available days. -- calls AvailableDaysBetweenN, which raises R14
- `HasAvailableDaysBetween` (line 1460): Raises error R14 today instead of telling whether the range holds available days. -- calls AvailableDaysBetweenN, which raises R14
- `AvailableWeeks` (line 1469): Raises Not yet implemented! today instead of returning the available weeks as pairs of dates. -- the body is a stub that raises Not yet implemented!
- `NextDay` (line 1803): Raises Not yet implemented! today instead of answering the day after the calendar's current day. -- the body is a stub that raises Not yet implemented!; the calendar keeps no current day
- `GoToNextDay` (line 1813): Raises Not yet implemented! today instead of moving the calendar to the next day. -- the body is a stub that raises Not yet implemented!
- `PreviousDay` (line 1827): Raises Not yet implemented! today instead of answering the day before the calendar's current day. -- the body is a stub that raises Not yet implemented!; the calendar keeps no current day
- `GoToPreviousDay` (line 1835): Raises Not yet implemented! today instead of moving the calendar to the previous day. -- the body is a stub that raises Not yet implemented!
- `GoToNext` (line 1894): Raises error R14 today instead of moving the calendar to the next month. -- calls GoNextMonth, which exists nowhere
- `GoTo` (line 2011): Raises Not yet implemented! today instead of moving the calendar to a given date. -- the body is a stub that raises Not yet implemented!
- `CurrentDay` (line 2052): Returns the day of the month of today, read from the clock and not from the calendar.
- `CurrentMonth` (line 2061): Returns the English name of today's month, read from the clock and not from the calendar.
- `CurrentMonthN` (line 2075): Returns the number of today's month, read from the clock and not from the calendar.
- `CurrentYear` (line 2084): Returns today's year, read from the clock and not from the calendar.
- `HasWeekends` (line 2207): Answers nothing today instead of telling whether the calendar has weekend days. -- the method has no body
- `WeekendsBetween` (line 2217): Raises Not yet implemented! today instead of returning the weekend days between two dates. -- the body is a stub that raises Not yet implemented!
- `WeekendsBetweenN` (line 2237): Raises Not yet implemented! today instead of counting the weekend days between two dates. -- calls WeekendsBetween, which is a stub
- `ConflictsWithSpan` (line 2684): Raises error R24 today instead of listing the days where a named span meets a holiday or a day off. -- tests an undefined variable oTimeLine instead of the attached timeline, so it raises Using uninitialized variable: otimeline for any label

## stzDate -- datetime/stzDate.ring (2)

- `ToHuman` (line 1867): Returns today, tomorrow or yesterday for those days, a count of days for the next or last 7, else a long date. -- the future form starts with a capital (In 3 days) and the past form does not (3 days ago)
- `ToRelative` (line 1901): Returns today, tomorrow or yesterday, a count of days or weeks within a month of today, else the date as dd/MM/yyyy.

## stzListOfTimeLines -- datetime/stzListOfTimeLines.ring (14)

- `AddPointsToLane` (line 379): Does nothing today instead of adding several points to a lane at once. -- it edits the copy that Lane returns, so the lane stays empty and no error is raised: after AddPointsToLane("b", [ ["Alpha", "2026-07-01"] ]) the lane holds no point, where the same call on the copy gives it
- `AddSpanToLane` (line 395): Does nothing today instead of adding a labelled span of time to a lane. -- it edits the copy that Lane returns, so the lane stays empty and no error is raised: AddSpanToLane("team a", "Build", "2026-04-01", "2026-05-01") leaves Spans of the lane empty, though the same call on the copy returns the span
- `AddPeriodToLane` (line 412): Does nothing today instead of adding a labelled period to a lane. -- it is AddSpanToLane, which edits a copy and keeps nothing
- `AddSpansToLane` (line 423): Does nothing today instead of adding several spans to a lane at once. -- it edits the copy that Lane returns, so the lane stays empty and no error is raised
- `AddBlockedSpanToLane` (line 439): Does nothing today instead of blocking a labelled span of a lane. -- it edits the copy that Lane returns: afterwards IsBlockedInLane for a moment inside the span answers FALSE
- `AddBlockedPointToLane` (line 451): Does nothing today instead of blocking a moment of a lane. -- it edits the copy that Lane returns: afterwards IsBlockedInLane for that moment answers FALSE
- `BlockSpanInLane` (line 463): Raises error R14 today instead of blocking an existing span of a lane by its label. -- it calls BlockSpan on the lane's timeline, a method stzTimeLine does not have, so every call raises R14
- `BlockPointInLane` (line 475): Raises error R14 today instead of blocking an existing point of a lane by its label. -- it calls BlockPoint on the lane's timeline, a method stzTimeLine does not have, so every call raises R14
- `Show` (line 588): Raises error R19 today instead of returning a drawing of all the lanes. -- it calls an internal drawing routine without the arguments it needs; the drawing routines behind it are also unfinished stubs, so no picture exists to return
- `ShowShort` (line 597): Raises error R19 today instead of returning a short drawing of all the lanes. -- it fails as Show does, through the same internal drawing routine
- `ShowUncovered` (line 611): Raises error R19 today instead of returning a drawing that marks the uncovered periods. -- it fails as Show does, through the same internal drawing routine
- `VizFind` (line 621): Raises error R19 today instead of drawing the lanes with one label highlighted. -- it ends by calling Show, which fails: Show raises error R19
- `RemovePointFromLane` (line 758): Does nothing today instead of removing a point from a lane by label or moment. -- it edits the copy that Lane returns, so the point stays in the lane and no error is raised: removing KICKOFF2 or the moment 2026-02-01 leaves the lane unchanged
- `RenameLabelInLane` (line 771): Does nothing today instead of renaming a point label in a lane. -- it edits the copy that Lane returns, so the label stays as it was and no error is raised

## stzImgToAscii -- extercode/stzImageToAscii.ring (6)

- `init` (line 63): Raises error C27 today, when the file loads, instead of building an image-to-text converter. -- the file extercode/stzImageToAscii.ring does not parse in Ring 1.27 (C27 Syntax Error at lines 41, 55, 56, 58, 79 and more) because it writes blocks in braces after if and in method bodies; no other file of the library loads it, so the class does not exist in a normal session
- `EnsureDirs` (line 74): Raises error C27 today, when the file loads, instead of creating the temp and output folders. -- same cause as init; the body also calls dir_create and reads a field @cOutputDir that is never defined (the field is @cOutDir)
- `Execute` (line 97): Raises error C27 today, when the file loads, instead of running the im2ansi tool on the image and keeping the text or file it produces. -- same cause as init; the tool path defaults to ../tools/im2ansi/im2ansi.exe, which is not in the library, and the body starts a real program
- `Content` (line 157): Raises error C27 today, when the file loads, instead of returning the converted image as text, running Execute first when needed. -- same cause as init
- `Show` (line 171): Raises error C27 today, when the file loads, instead of printing the converted image or opening the output file in the system viewer. -- same cause as init; for the svg and html formats the body would start the operating system's viewer
- `BuildArgs` (line 202): Raises error C27 today, when the file loads, instead of building the command-line options for the im2ansi tool from the settings. -- same cause as init

## stzFileInfo -- file/stzFile.ring (1)

- `IsExecutable` (line 1133): Returns 0 for every file today, because the extension it compares carries a leading dot. -- defect: the extension is read as .exe or .BAT and compared with exe, bat, cmd and com, so a file named prog.exe and one named run.BAT both answer 0; the sibling stzFileManager.IsExecutable fails differently (see there)

## stzFileManager -- file/stzFile.ring (15)

- `CopyTo` (line 2967): Raises error R3 today instead of copying the file into a folder under its own name. -- defect: the body calls the helper _FileName, which is not a global function (a function placed between two classes belongs to the class before it), so every call raises Calling Function without definition: _filename; same cause as MoveTo, MoveAs, RenameAs, CopyAs, CreateBackup, CreateBackupAs, SafeDelete, SafeRemove, ZipBackup and IsExecutable
- `CopyAs` (line 2988): Raises error R3 today instead of copying the file under a new name in the same folder. -- defect: the body calls the helper _FileDirPath, which is not a global function, so every call raises Calling Function without definition: _filedirpath
- `MoveTo` (line 3023): Raises error R3 today instead of moving the file into a folder under its own name. -- defect: calls the missing helper _FileName (see CopyTo)
- `MoveAs` (line 3044): Raises error R3 today instead of renaming the file inside its own folder. -- defect: calls the missing helper _FileDirPath (see CopyTo)
- `RenameAs` (line 3084): Raises error R3 today instead of renaming the file inside its own folder. -- defect: calls the missing helper _FileDirPath (see CopyTo)
- `Backup` (line 3107): Returns 1 but writes no backup today, because the name it builds contains the characters / and :. -- defect: the copy is named file.backup. followed by StzTimeStamp(), which has the form 09/10/2026 11:37:52, so the target path holds folders that do not exist and the copy fails without notice; checked twice, no file appears and the 1 is returned anyway
- `SplitByLines` (line 3122): Raises error R13 today instead of splitting the file into parts of a fixed number of lines. -- defect: the body treats the text returned by StzFileRead as a reader object and calls Lines() on it, so every call raises Object is required; the helper names it uses (_FileCompleteBaseName and others) are missing too
- `SplitBySize` (line 3166): Raises error R13 today instead of splitting the file into parts of a fixed number of bytes. -- defect: same cause as SplitByLines, calling a method on the text returned by StzFileRead
- `SplitByPattern` (line 3209): Raises error R13 today instead of splitting the file at every line that contains a pattern. -- defect: same cause as SplitByLines
- `ZipBackup` (line 3356): Raises error R3 today instead of zipping the file into a backup archive in its own folder. -- defect: calls the missing helpers _FileDirPath, or _FileCompleteBaseName for the empty text (see CopyTo)
- `CreateBackup` (line 3380): Raises error R3 today instead of copying the file to a timestamped backup name and giving its path. -- defect: calls the missing helper _FileCompleteBaseName (see CopyTo)
- `CreateBackupAs` (line 3407): Raises error R3 today instead of copying the file to a named backup in its folder and giving its path. -- defect: calls the missing helper _FileDirPath (see CopyTo)
- `SafeDelete` (line 3459): Raises error R3 today instead of backing the file up and then deleting it. -- defect: it calls CreateBackup, which calls the missing helper _FileCompleteBaseName (see CopyTo); the file is left in place
- `SafeRemove` (line 3477): Raises error R3 today instead of backing the file up and then deleting it. -- defect: same cause as SafeDelete
- `IsExecutable` (line 3576): Raises error R3 today instead of telling whether the extension marks an executable. -- defect: calls the missing helper _FileExtension (see CopyTo)

## stzFileModifier -- file/stzFile.ring (1)

- `InsertLine` (line 2549): Raises error R24 today instead of inserting a line at a position. -- defect: the body passes nNewLine, a name that does not exist (the parameter is cNewLine), so every call raises Using uninitialized variable: nnewline

## stzFileOverwriter -- file/stzFile.ring (1)

- `PreserveAndModify` (line 2186): Raises error R12 today instead of writing the old text back and adding a change after it. -- defect: the body reads This.cOriginalContent where the attribute is @cOriginalContent, so every call raises Error in property name, property not found: coriginalcontent (checked on two files)

## stzFileXT -- file/stzFile.ring (1)

- `init` (line 856): Returns an empty stzFileXT object today, instead of the file object of the chosen intent. -- defect: the constructor returns the object of the chosen class, and Ring ignores the value a constructor returns, so new stzFileXT(path, "info") has no FileName and "read" answers NULL to Content; the intent erase names a class stzFileEraser that does not exist (it is stzFileEaraser) and raises Error in class name, class not found; an unknown intent raises Can't proceed! The intent you provided is not support in Softanza file API.

## stzHtmlBuilder -- file/stzHtml.ring (3)

- `AppendToCurrent` (line 498): Adds a node as the last child of the current node and returns the builder. -- defect: the current node is a copy of the root made at birth, because Ring copies an object on assignment, so the node lands in the copy and Build, Root and BuildToFile still show nothing; checked with two different nodes and after SetCurrent(Root())
- `Build` (line 545): Returns the HTML text of the document: the children of the root, one after the other. -- defect: it answers the empty text after AppendToCurrent, whatever was appended (see AppendToCurrent)
- `BuildToFile` (line 558): Writes the HTML text of the document to a file and returns the builder. -- defect: the file is created empty after AppendToCurrent, for the same reason as Build

## stzZipFile -- file/stzZipFile.ring (2)

- `CreateFromDirectory` (line 129): Raises error R3 today instead of creating the archive from every file of a folder. -- the call FilesInDir does not exist anywhere in the library, so an existing folder raises R3 Calling Function without definition: filesindir; a missing folder raises Directory does not exist
- `AddString` (line 218): Raises error R3 today instead of storing a text as an entry of the archive. -- the zip_newentry function it calls does not exist (checked by calling it directly), so every call raises R3 Calling Function without definition: zip_newentry

## stzGeoFeatures -- geo/stzGeoFeatures.ring (2)

- `IndicesWithin` (line 776): Returns the positions of the features whose bounding box has its middle inside a box of longitude and latitude. -- Defect: a feature across the antimeridian has a box 360 degrees wide whose middle is longitude 0, so Fiji is taken by a window around Africa.
- `Within` (line 800): Returns a new set of the features whose bounding box has its middle inside a box of longitude and latitude. -- Defect: the same antimeridian trap as IndicesWithin: Fiji is taken by a window around Africa.

## stzGeoField -- geo/stzGeoField.ring (5)

- `ValueAt` (line 270): Returns the field's value at a place: bilinear between four known nodes, the nearest node where some are unknown. -- Defect: a bilinear read of a constant field comes back one rounding step under the node value about 6 per cent of the time, so with SetClassesEvery a pixel at the first class edge draws as no data (white specks).
- `SetClassesEvery` (line 338): Sets pnHowMany equal classes between the field's lowest and highest value. -- Defect: a bilinear read of a constant field comes back one rounding step under the node value about 6 per cent of the time, so with SetClassesEvery a pixel at the first class edge draws as no data (white specks).
- `SetRamp` (line 361): Sets the colours of the classes from a named ramp, in as many steps as there are classes. -- Defect: the error for an unknown name lists nine ramps although thirteen exist.
- `DrawOn` (line 460): Draws the field as one image on a canvas, resampled through a projection into a box, coloured by class. -- Defect: a bilinear read of a constant field comes back one rounding step under the node value about 6 per cent of the time, so with SetClassesEvery a pixel at the first class edge draws as no data (white specks).
- `DrawXT` (line 478): Draws the field as one image like DrawOn, with an opacity so the map underneath can show through. -- Defect: a bilinear read of a constant field comes back one rounding step under the node value about 6 per cent of the time, so with SetClassesEvery a pixel at the first class edge draws as no data (white specks).

## stzGeoMap -- geo/stzGeoMap.ring (18)

- `SetRamp` (line 557): Sets the class colours from a named ramp, in as many steps as there are classes. -- Defect: the error for an unknown name lists nine ramps although thirteen exist (Viridis, Magma, Cividis and Flow are missing from the message).
- `SetPalette` (line 576): Sets the colour of each class by hand. -- Defect: before SetClasses it raises with the message -1 classes need -1 colours, because an empty edge list counts as -1 classes.
- `SetPaper` (line 599): Tells the map the box it is drawn in, so no label is written off the sheet and the scale bar is measured over that box. -- Defect: when it is not called, the scale-bar and stream-density methods guess the sheet from the projection's scale and misjudge a country map.
- `SetOpenTop` (line 649): Declares that the top class has no upper edge, so a value above the last edge belongs to it and the legend draws an arrow. -- Defect: an inset made by DrawInsetsOn does not copy it, so a region above the last edge shows as no data in the inset (Niamey on the Niger sheet).
- `ClassOf` (line 794): Returns the class that feature pnI's value falls in. -- Defect: raises error R2 when values are set and the classes are not, because the class edges are an empty list read at index 0.
- `ColourOf` (line 819): Returns the fill colour of feature pnI: its group's colour, its class's colour, or the no-data colour. -- Defect: raises error R2 when values are set and the classes are not, because the class edges are an empty list read at index 0.
- `DrawOn` (line 841): Draws the old-style layers on a canvas: sphere, graticule every 30 degrees, regions with white edges, the world's edge. -- Defect: raises error R2 when values are set and the classes are not, because the class edges are an empty list read at index 0.
- `DrawRegionsOn` (line 885): Draws every feature in the colour its value earns, with one edge colour. -- Defect: raises error R2 when values are set and the classes are not, because the class edges are an empty list read at index 0.
- `DensityPointsIn` (line 1104): Returns the places per feature divided by the feature's area, ready for SetValues. -- Defect in the comment: the source says per square kilometre but the code multiplies by 10000, so the figure is per 10000 km2.
- `LabelPointOf` (line 1152): Returns where a name goes: the area centroid of the largest part, or the roomiest inner point when the centroid is outside it. -- Defect: no range check, so a position of 0 or past the last raises error R2.
- `DrawInsetsOn` (line 2189): Draws every inset on a canvas: its locator rectangle on the parent, its enlarged map, its frame, its title and its scale. -- Defect: the inset copies values, edges and palette but not SetOpenTop, so a value above the last edge draws as no data inside the inset while the parent paints it in the top colour (Niamey on the Niger sheet).
- `DrawSheetOn` (line 2448): Draws the regions as a statistical map does: dark hairline borders, the no-data hatch, then the heavy outline of the selection. -- Defect: raises error R2 when values are set and the classes are not, because the class edges are an empty list read at index 0.
- `DrawScaleBarOn` (line 2746): Draws a scale bar at a stated latitude and prints that latitude; draws nothing when the scale varies too much over the sheet. -- Defect: without SetPaper the sheet is guessed from the projection's scale as plus and minus pi times it, so a country map measures a scale variation of 57.85 instead of 1.009 and the bar is refused.
- `ScaleVariation` (line 2793): Returns the ratio of the largest local scale to the smallest over the sheet: 1 means a scale bar is true everywhere. -- Defect: without SetPaper the sheet is guessed from the projection's scale as plus and minus pi times it, so a country map measures a scale variation of 57.85 instead of 1.009 and the bar is refused.
- `ScaleBarAt` (line 2809): Returns the scale bar that would be drawn, without drawing it. -- Defect: without SetPaper the sheet is guessed from the projection's scale as plus and minus pi times it, so a country map measures a scale variation of 57.85 instead of 1.009 and the bar is refused.
- `DrawStreamDensityOn` (line 3415): Draws a field's speed as a shaded raster with evenly spaced streamlines on top, the speed on the ground and the shape on the lines. -- Defect: without SetPaper the sheet is guessed from the projection's scale, so the raster covers a box thousands of pixels wide.
- `DrawLegendOn` (line 3466): Draws the older legend: one row per class with its range, "(no region)" for a class nothing falls in, and a no-data row. -- Defect: raises error R2 when values are set and the classes are not, because the class edges are an empty list read at index 0.
- `IsOnPaper` (line 3899): TRUE if any part of feature pnI reaches the paper at all. -- Defect: no range check, so a position of 0 or past the last raises error R2.

## stzGeoProcess -- geo/stzGeoProcess.ring (2)

- `ExpectedCount` (line 397): Returns how many points the process puts down on average in a window of the given area. -- Defect: for Inhomogeneous it is the mean of all the grid values times the window area, not the integral over the window: 191.9 against 149.4 drawn on average and 144.3 integrated.
- `PatternIn` (line 429): Raises error today instead of returning the pattern of GenerateIn as a stzGeoPoints ready to measure. -- Defect: it passes the window's list of rings to StzGeoPoints, which takes the stzGeoFeatures. Seen with SSI and MaternCluster on the fixtures and Poisson on Niger

## stzGeoProjection -- geo/stzGeoProjection.ring (1)

- `Caption` (line 1082): Returns the projection written for a picture: its name, the parallels of a conic and the rotation if any. -- Defect: the parallels of a conic always carry an N, so 22.78 degrees south prints as -22.78N.

## stzGeoSamples -- geo/stzGeoSamples.ring (5)

- `ValueOf` (line 182): Returns the value of measurement pnI. -- Defect: no range check, so a position of 0 or past the last raises error R2.
- `PlaceOf` (line 191): Returns where measurement pnI was made. -- Defect: no range check, so a position of 0 or past the last raises error R2.
- `FitAndUse` (line 315): Fits a variogram model and adopts it in one move. -- Defect: on gauges with a trend the Gaussian fit reaches a range longer than the window and the estimate leaves the measured range by tens of thousands (-30825 to 29761 for gauges of 180 to 799) while Findings only warns.
- `KrigeFields` (line 351): Returns the ordinary-kriging estimate and its variance as two fields, from one factorisation. -- Defect: on gauges with a trend the Gaussian fit reaches a range longer than the window and the estimate leaves the measured range by tens of thousands (-30825 to 29761 for gauges of 180 to 799) while Findings only warns.
- `Findings` (line 402): Returns what is wrong with the set: gauges outside the window, too few gauges, a range beyond the data, a nugget that is most of the sill. -- Defect: a kriging that leaves the measured range by tens of thousands is only a warning (range over half the diagonal), so IsSound stays TRUE.

## stzDiagram -- graph/stzDiagram.ring (5)

- `PenWidth` (line 2004): Raises error R24 today instead of returning the pen width. -- it reads the attribute @nPenWidth, which nothing declares or sets, so every call raises R24 (uninitialized variable)
- `NodesWith` (line 2939): Raises error R20 today instead of returning the nodes whose property satisfies a comparison. -- it builds a stzGraphQuery with two arguments where its constructor takes a different number, so every call raises R20
- `propertiesLegend` (line 3020): Raises error R13 today when a visual rule is registered, instead of returning a text legend of the rules. -- it reads fields of the rules as if they were objects (.@cConditionType) while RegisterVisualRule stores hash lists, so any rule raises R13 (object is required)
- `SaveToStzDiagInFolder` (line 18160): Raises error R14 today instead of writing the .stzdiag file in a folder. -- it takes no folder argument and calls WriteToDiagFileXT with a global that is never set, and that method exists nowhere, so every call raises R14
- `Explain` (line 18425): Returns a short account of the diagram: its size, its visual rules and what they affected; raises error R13 as soon as a rule is registered. -- with a registered rule it reads the rule's id as a field of an object (.@cRuleId) while rules are stored as hash lists, so it raises R13; without rules it answers "No visual rules defined."

## stzGraph -- graph/stzGraph.ring (12)

- `InsertNodesBefore` (line 715): Raises error R20 today instead of inserting a chain of nodes in front of an existing node. -- it calls InsertNodeBefore with three arguments, but that method takes two, so even a valid list of pairs raises R20
- `InsertNodesAfter` (line 731): Raises error R20 today instead of inserting a chain of nodes behind an existing node. -- it calls InsertNodeAfter with three arguments, but that method takes two, so even a valid list of pairs raises R20
- `ConnectEdgesXTT` (line 1484): Raises error R19 today instead of adding edges to several nodes, each with its own label and properties. -- it calls AddEdgeXTT with two arguments where four are needed, so any non-empty list raises R19, and an empty list does nothing
- `LongestPath` (line 3296): Returns the largest number of nodes reachable from any one node, which is not the hop count of the longest path. -- the name promises a path length, but the body counts reachable nodes, so a node that reaches two branches of two nodes each answers 4, though no path is longer than 2 hops
- `CyclicNodes` (line 3321): Returns an empty list today instead of the ids of the nodes that lie on a cycle. -- it looks for the node among the nodes it reaches, but ReachableFrom never lists the start node, so the test is never true; use HasCyclicDependencies for the graph
- `LoadFromGraphML` (line 4951): Raises error "Incorrect Id" today instead of reading a GraphML file into the graph, and leaves odd nodes behind. -- the parser cuts the text at fixed positions instead of the positions it finds, so even a file written by SaveToGraphML yields garbled ids such as "sion=" and raises; the graph is left with those nodes
- `LoadGraphML` (line 4965): Raises error "Incorrect Id" today instead of reading a GraphML file into the graph. -- it only calls LoadFromGraphML, whose parser fails on every file written by SaveToGraphML and leaves garbled nodes behind
- `ImportFromGraphML` (line 4974): Raises error "Incorrect Id" today instead of importing a GraphML file into the graph. -- it only calls LoadFromGraphML, whose parser fails on every file written by SaveToGraphML and leaves garbled nodes behind
- `ImportGraphML` (line 4983): Raises error "Incorrect Id" today instead of importing a GraphML file into the graph. -- it only calls LoadFromGraphML, whose parser fails on every file written by SaveToGraphML and leaves garbled nodes behind
- `HasRule` (line 5940): TRUE if a constraint rule has that name; the name is folded to upper case first. -- derivation and validation rules are never found, because their names are lowered before the comparison with an upper-case name, so a rule that is loaded can still answer FALSE
- `ValidationSummary` (line 6225): Returns the record of the last validation that passed; before any pass it answers that none has run. -- a failed validation is never recorded, so after a failure the summary still shows the older pass, or none has run, and its violations list is always empty
- `Anomalies` (line 6260): Returns the violations of the last recorded validation, which is always an empty list today. -- only passing validations are recorded, so this can never list a violation; read the issues of Validate instead

## stzGraphComparison -- graph/stzGraph.ring (3)

- `Content` (line 8704): Returns nothing today instead of the comparison data. -- the body is empty, so the call answers empty text; Data returns the comparison
- `WithCycles` (line 8787): Returns an empty list today instead of the names of the variations that contain a cycle. -- the rows hold the text TRUE or FALSE in the cycle field, and the body tests it against the number 1
- `WithoutCycles` (line 8807): Returns an empty list today instead of the names of the variations that stay acyclic. -- the rows hold the text TRUE or FALSE in the cycle field, and the body tests it against the number 0

## stzGraphQuery -- graph/stzGraphQuery.ring (2)

- `ValidateWith` (line 233): Queues a validation of the matched subgraph against rule groups; a single text raises error R21 when the query runs today. -- a single text is wrapped with paValidators = [ paValidators ], which stores [ [ [ ] ] ] and the run then raises R21; a list of names works, and a failing group raises Validation failed
- `OrderBy` (line 650): Leaves the rows in match order for ascending and reverses them for descending today, instead of sorting by a field. -- the sort call @SortOn returns the sorted list and the method drops it, so nothing is sorted; asc keeps the match order and desc reverses it; only the first OrderBy is read; both arguments are required, with one Ring raises R19

## stzGraphRule -- graph/stzGraphRule.ring (1)

- `When` (line 896): Adds a clause that selects the nodes the rule looks at: a node property tested against a value; clauses are combined with AND. -- an empty property name or an unknown operator raises an error; the ordering operators compare numbers only: on a text greaterthan and lessthan never match but greaterequal and lessequal match every node, which is a defect; an unset property reads as 0, so exists fails and missing holds for it

## stzGridNav -- graph/stzGridNav.ring (5)

- `init` (line 83): Raises error Can't create stzGridNav! Engine returned error today instead of building a named grid. -- new stzGridNav("g", 3, 4) and new stzGridNav("g5", 5, 5) both raise, because the engine function StzEngineGridCreate takes (rows, cols) and is handed (name, rows, cols): the text is read as 0 rows and the call returns -1; StzEngineGridCreate(3, 4) called directly succeeds
- `CurrentRow` (line 141): Returns the row of the current position, once a grid exists; none can be built today. -- unreachable today because init raises
- `CurrentCol` (line 153): Returns the column of the current position, once a grid exists; none can be built today. -- unreachable today because init raises
- `NeighborCount` (line 251): Returns how many cells touch the current one, up, down, left and right, inside the grid; none can be built today. -- unreachable today because init raises
- `DistanceTo` (line 284): Returns the Manhattan distance between the current cell and another, once a grid exists; none can be built today. -- unreachable today because init raises; it also sends 3 arguments to an engine function that takes 4 (both cells), so the answer would not be the distance from the current cell

## stzKnowledgeGraph -- graph/stzKnowledgeGraph.ring (2)

- `ValidateOntology` (line 865): Returns 1 whatever the ontology holds; the check is not written yet. -- the body only returns 1, so no inconsistency is ever reported
- `Explain` (line 1000): Raises error R14 today instead of describing the knowledge graph in sections: structure, facts, entities, predicates, ontology and insights. -- it calls ApplyInference, which is defined nowhere, so the call always raises R14; stzGraph.Explain is shadowed by this version seen in the gallery: drawn through GraphCanvas a knowledge graph shows no predicate on its edges and no arrowheads; Dot() with graphviz draws each fact as an edge labelled with its predicate

## stzMathSubstance -- graph/stzMathDiagram.ring (1)

- `SetData` (line 3317): Puts a number on an object under a key, which a style can read as name.key to drive a position or a colour. -- an undeclared object raises no error and the number is lost: HasData and DataOf then do not find it, which is a defect, seen with ghost and phantom; setting a key again replaces its value

## stzOrgChart -- graph/stzOrgChart.ring (10)

- `ValidateSuccession` (line 937): Fails for every filled position without a successor, one issue each; the positions are the affected nodes. -- a successor is looked for under a key that is never written, so every filled position fails
- `SuccessionRisk` (line 1093): Returns the ids of the filled positions that have no successor; today that is every filled position. -- the successor is looked for under an attributes key that is never written, so a successor set with SetNodeProperty is not seen
- `GenerateVacancyReport` (line 1181): Returns the vacancy report: how many positions are vacant, the rate, and the title and department of each. -- the level of each detail is always staff, since it is read from a key that is never written
- `ResetAllNodeColors` (line 1451): Paints every position node white, which is meant to restore the level colours. -- the level colour is read from a key that is never written, so every node ends white
- `ViewNonCompliant` (line 1759): Raises error R20 today instead of highlighting the positions named in a failing norm's issues and displaying the chart. -- it calls Validate with an argument that Validate does not take, so every call raises R20
- `ViewNotAtRisk` (line 1852): Raises error R24 today instead of highlighting the positions that have a successor and displaying the chart. -- it reads an attribute @bShowTitle that no class defines, so every call raises R24
- `ViewDepartment` (line 1881): Highlights the positions of one department and displays the chart; raises error R24 when the chart has a title. -- the subtitle line, written when a title is set, reads an undefined variable ppcdepartmentid; without a title it works
- `ViewPath` (line 1918): Highlights the positions on the path between two positions and displays the chart; with a title set it also adds a stray node. -- with a title set, the subtitle line indexes the node list by id and adds a node with an empty id; without a title it works
- `ViewNodeWithProperties` (line 1992): Does nothing today instead of highlighting the nodes that hold several properties: the body is a TODO. -- the method is an empty stub
- `ViewNodesWithTags` (line 2029): Does nothing today instead of highlighting the nodes that hold several tags: the body is a TODO. -- the method is an empty stub

## stzOrgChartReporter -- graph/stzOrgChart.ring (1)

- `VacancyReport` (line 3000): Returns the vacancy report: how many positions are vacant, the rate, and the title and department of each. -- the level of each detail is always staff, since it is read from a key that is never written

## stzOrgChartSimulation -- graph/stzOrgChart.ring (1)

- `ApplyChanges` (line 3246): Applies a list of changes to the copy, never to the original, then records the before and after spans and vacancy rates. -- a change_reporting change raises "Cannot add edge: one or both nodes do not exist!", since the copy has no nodes; an unknown :type is skipped without a word

## stzWorkflowSimulation -- graph/stzWorkflow.ring (3)

- `OptimizeStep` (line 1678): Raises error R24 Using uninitialized variable: @achanges today instead of recording a new duration for a step. -- no object of this class can record a change: the class has no @aChanges list and no init, so the first line of the method raises; building the object with a workflow, new stzWorkflowSimulation(oWf), raises the same error on the call
- `ReassignStep` (line 1694): Raises error R24 Using uninitialized variable: @achanges today instead of recording a move of a step to another actor. -- raises the same error as OptimizeStep, because the class has no @aChanges list
- `ParallelizeSteps` (line 1709): Raises error R24 Using uninitialized variable: @achanges today instead of recording that steps run side by side. -- raises the same error as OptimizeStep, because the class has no @aChanges list

## stzText -- linguistic/stzText.ring (1)

- `SummarizedAbstractively` (line 1316): Raises error R19 today when no generative model is loaded, instead of falling back to the extractive summary. -- Raises error R19 without a generative model (checked on three texts): the fallback calls Summary without its sentence count

## stzItemCS -- list/stzItem.ring (20)

- `Sections` (line 354): Raises error R14 today instead of answering the positions of the item as runs of consecutive positions. -- it calls FindAsSectionsCS on the list, a method stzList does not have, so every call raises R14, whatever the list
- `IsBoundedBy` (line 441): Raises error R14 today instead of telling whether the item stands between two bounding items. -- it calls ContainsItemBoundedByCS on the list, a method stzList does not have, so every call raises R14
- `IsBetween` (line 458): Raises error R14 today instead of telling whether the item stands between two given items. -- it calls ContainsItemBetweenCSQ on the list, a method stzList does not have, so every call raises R14
- `BoundedBy` (line 474): Raises error R14 today instead of putting two bounding items around the item in the list. -- it calls BoundItemByCSQ on the list, a method stzList does not have, so every call raises R14; its body also reads a name pacBounds that is not its parameter
- `ReplacedWith` (line 497): Raises error R14 today instead of returning the list with the item replaced by another. -- it calls ReplaceCSQ on the list, a method stzList does not have, so every call raises R14; Replaced and ReplacedBy are the same call
- `Removed` (line 518): Raises error R14 today instead of returning the list without the item. -- it calls RemoveCSQ on the list, a method stzList does not have, so every call raises R14
- `Uppercased` (line 570): Raises error R14 today instead of returning the list with the item in upper case. -- it calls UppercaseItemCSQ on the list, a method stzList does not have, so every call raises R14
- `Lowercased` (line 585): Raises error R14 today instead of returning the list with the item in lower case. -- it calls LowercaseItemCSQ on the list, a method stzList does not have, so every call raises R14
- `InstertedBeforeCS` (line 598): Raises error R14 today instead of returning the list with a new item put before the item. -- it calls InsertBeforeCSQ on the list, a method stzList does not have, so every call raises R14; the method name is also misspelled: Instertedbefore
- `InsertedBefore` (line 612): Raises error R14 today instead of returning the list with a new item put before the item. -- it calls InsertedBeforeCS, a name that does not exist because the real method is spelled InstertedBeforeCS, so every call raises R14; InsertedBAt is the same call
- `InsertedBeforePosition` (line 626): Raises error R14 today instead of returning the list with the item put before a position. -- it calls InsertBeofrePositionQ, a misspelled name that does not exist, so every call raises R14; InsertedAtPosition is the same call
- `InsertedBeforePositions` (line 640): Raises error R14 today instead of returning the list with the item put before several positions. -- it calls InsertBeofrePositionsQ, a misspelled name that does not exist, so every call raises R14
- `InsertedBeforeItem` (line 666): Raises error R14 today instead of returning the list with another item put before the item. -- it calls InsertBeforeItemCSQ on the list, a method stzList does not have, so every call raises R14
- `InsertedBeforeItems` (line 685): Raises error R14 today instead of returning the list with several items put before the item. -- it calls InsertBeforeItemsCSQ on the list, a method stzList does not have, so every call raises R14
- `InstertedAfterCS` (line 707): Raises error R14 today instead of returning the list with a new item put after the item. -- it calls InsertAfterCSQ on the list, a method stzList does not have, so every call raises R14; the method name is also misspelled: Instertedafter
- `InsertedAfter` (line 718): Raises error R14 today instead of returning the list with a new item put after the item. -- it calls InsertedAfterCS, a name that does not exist because the real method is spelled InstertedAfterCS, so every call raises R14
- `InsertedAfterPosition` (line 730): Raises error R14 today instead of returning the list with the item put after a position. -- it calls the misspelled InsertBeofrePositionQ, which does not exist, so every call raises R14; its body is the one of the Before form, so it would insert before
- `InsertedAfterPositions` (line 742): Raises error R14 today instead of returning the list with the item put after several positions. -- it calls the misspelled InsertBeofrePositionsQ, which does not exist, so every call raises R14; its body is the one of the Before form, so it would insert before
- `InsertedAfterItem` (line 762): Raises error R14 today instead of returning the list with another item put after the item. -- it calls InsertAfterItemCSQ on the list, a method stzList does not have, so every call raises R14
- `InsertedAfterItems` (line 781): Raises error R14 today instead of returning the list with several items put after the item. -- it calls InsertAfterItemsCSQ on the list, a method stzList does not have, so every call raises R14

## stzListBounder -- list/stzListBounder.ring (1)

- `AreBoundsOf` (line 312): Raises error R14 today instead of telling whether the list's two items are the bounds of a text. -- it raises error R14 Calling Method without definition: isboundedbyin, because the stzString method it calls does not exist; tried on a pair of bounds, on a list of pairs and with the case flag; a list that is neither a pair nor a list of pairs raises Can't check bounds! List must be a pair or a list of pairs instead

## stzListChecker -- list/stzListChecker.ring (4)

- `ContainsItem` (line 574): Returns 0 whatever the list holds today, because the item is handed to the engine in a form it does not match. -- defect: ContainsItem(2) on [1,2,3], ContainsItem("a") on ["a","b"] and ContainsItem([3]) on [[1,2],[3]] all answer 0, and so does ContainsItemCS with either case flag; the call StzEngineListContainsCS(list, item, cs) answers 0 on its own for present items; the engine function stz_list_contains_cs expects the needle as a value handle and the class passes the raw item
- `ContainsAllOfThese` (line 595): Returns 1 only for an empty list of items today, because every ContainsItem answers 0. -- defect: ContainsAllOfThese([1,2]) on [1,2,3] answers 0 and ContainsAllOfThese([]) answers 1; the cause is ContainsItem, which never finds an item
- `ContainsOneOfThese` (line 614): Returns 0 today, whatever the items are, because every ContainsItem answers 0. -- defect: ContainsOneOfThese([9,2]) on [1,2,3] and ContainsOneOfThese(["z","b"]) on ["a","b"] answer 0; the cause is ContainsItem, which never finds an item
- `ContainsW` (line 703): Raises error R3 today instead of telling whether an item satisfies the condition. -- defect: the method calls StzCCodeToRingCode, which no file of the library defines, so every call raises Calling Function without definition: stzccodetoringcode

## stzListDuplicates -- list/stzListDuplicates.ring (1)

- `RemoveNthDuplicate` (line 487): Leaves the list unchanged today, though it is meant to delete the nth repeat of an item. -- it does nothing: the list is unchanged on a b a c b a d for the first repeat of a, again on a second call, and with an n past the last repeat, because the delete is made on a copy of the list that List returns

## stzListFinder -- list/stzListFinder.ring (1)

- `CountItemsW` (line 728): Raises error R14 today instead of counting the items that satisfy a W condition. -- raises Calling Method without definition: countw for every condition (two conditions tried), because the class it calls has no CountW

## stzListOfPairs -- list/stzListOfPairs.ring (4)

- `ExpandedIfPairsOfNumbers` (line 1223): Raises error R14 today instead of returning the number lists that the pairs of numbers expand to. -- Raises R14 today on every call: it calls ExpandedIfPairOfNumbers, a method that exists nowhere in the loaded library
- `IsListOfSections` (line 1427): Answers TRUE for any list of pairs today, instead of TRUE only when every pair is made of two numbers. -- Answers TRUE whatever the pairs hold, text included: the loop records a failing pair in a variable that is never read, so the result stays at its start value
- `AreAnagrams` (line 1564): Raises error R14 today instead of telling whether the two items are anagrams of each other. -- Raises R14 today on every call: it reads FirstValue and SecondValue, which this class does not define
- `ToStzSetOfSections` (line 2317): Raises an error today instead of returning the pairs as a stzSetOfSections. -- Raises "You must provide a list of sections" today for valid sections such as [ [ 1, 3 ], [ 5, 8 ] ]: the stzSetOfSections constructor refuses what stzListOfSections accepts

## stzListProvidedAsString -- list/stzListProvidedAsString.ring (6)

- `IsListOfValues` (line 85): Raises error R12 today instead of telling whether the list text holds only values and no variable names. -- Raises error R12 (property not found: list) today instead of TRUE or FALSE, because ContainsOnlyValues reads a property that does not exist
- `IsListOfVariables` (line 94): Returns an empty text today instead of telling whether the list text holds only variable names and no values. -- Not implemented: ContainsOnlyVariables is an empty TODO stub, so the answer is "" whatever the text, and a test on it is always false
- `IsListOfValuesAndVariables` (line 103): Returns an empty text today instead of telling whether the list text mixes values and variable names. -- Not implemented: ContainsValuesAndVariables is an empty TODO stub, so the answer is "" whatever the text
- `ContainsOnlyValues` (line 112): Raises error R12 today instead of telling whether the list text holds only values, such as numbers, texts and lists. -- Raises error R12 (property not found: list) today, because its first line reads This.List, a property the class does not have
- `ContainsOnlyVariables` (line 122): Returns an empty text today instead of telling whether the list text holds only variable names. -- Not implemented: the body is a TODO comment, so the answer is "" whatever the text
- `ContainsValuesAndVariables` (line 131): Returns an empty text today instead of telling whether the list text holds both values and variable names. -- Not implemented: the body is a TODO comment, so the answer is "" whatever the text

## stzListWalker -- list/stzListWalker.ring (3)

- `AddWalker` (line 123): Raises error R24 today instead of registering a named walker for the list. -- it raises error R24 Using uninitialized variable: @awalkers on any list (tried on two lists), because the class reads the attribute @aWalkers without ever declaring or filling it
- `Walkers` (line 161): Raises error R24 today instead of answering the registered walkers. -- it raises error R24 Using uninitialized variable: @awalkers, because the class reads the attribute @aWalkers without ever declaring or filling it (tried on two lists)
- `Walker` (line 172): Raises error R24 today instead of answering the walker registered under a name. -- it raises error R24 Using uninitialized variable: @awalkers, as Walkers does (tried on two lists)

## stzSet -- list/stzSet.ring (3)

- `Subsets` (line 505): Returns an empty text today, because the method is only a TODO in the code. -- it computes no subsets: the body is the comment TODO
- `SubSetsOfNElements` (line 514): Returns an empty text today, because the method is only a TODO in the code. -- it computes no subsets: the body is the comment TODO
- `NumberOfSubsets` (line 522): Returns 0 today, because it counts the subsets that Subsets does not compute. -- it is the length of what Subsets answers, an empty text

## stzSetOfSections -- list/stzSetOfSections.ring (2)

- `init` (line 46): Raises error "Can't create the stzSetOfSections object" today for every argument instead of building a set of sections. -- Refuses [ [1,3], [5,7] ] and every other list: the check calls @IsSetOfSections, a function whose body is empty, so it answers an empty text and the creation is always refused; the working global IsSetOfSections itself fails with R14 (stzList has no IsListOfSections method)
- `IntersectionWith` (line 117): Raises the error "Feature not implemented yet!" today instead of the sections shared with another set. -- Not run on an object, since none can be built; read from the code, the body is only a StzRaise call, and Intersection forwards to it

## stzTree -- list/stzTree.ring (4)

- `RemoveItem` (line 980): Raises error Not yet implemented! today instead of removing an item from the tree. -- the removal of items is a TODO in the class
- `RemoveTheseItems` (line 995): Raises error Not yet implemented! today instead of removing several items from the tree. -- the removal of items is a TODO in the class
- `RemoveItems` (line 1005): Raises error Not yet implemented! today instead of removing every item from the tree. -- the removal of items is a TODO in the class
- `RemoveAllItems` (line 1014): Raises error Not yet implemented! today instead of removing every item from the tree. -- it calls RemoveItems, which is a TODO in the class

## stzYielder -- list/stzYielder.ring (1)

- `MapIndexed` (line 107): Returns the text <list> for every item today, instead of applying an operation together with each item position. -- defect: the result holds the text "<list>" in place of the values, for every operation tried (:Square, :Abs, :Negate, :Increment) and every input; the engine call returns its items in a form the Ring side shows only as that text

## stzMathFigure -- math/stzMathFigure.ring (2)

- `Pin` (line 384): Raises an error today instead of holding a shape where it is during later solves: no shape of any figure kind has a free position to hold. -- the diagram refuses it because the rules fix every shape (checked on 35 sample figures of all ten kinds); an unknown path raises too
- `DragTo` (line 407): Raises an error today instead of moving a shape to a position and re-solving around it: no shape has a free centre to move. -- refused for every shape of 9 figures tried across the kinds; use MoveNoteTo to move a note

## stzTukeyLine -- math/stzTukey.ring (1)

- `Fit` (line 927): Fits Tukey's three-group line, then improves it with passes over the residuals, as R's line does. -- Fit(0) equals R's line with iter 1 and Fit(1) equals iter 2, so the count here is one less than R's; points that all share one x give slope 0 and intercept 0 with no error, which is a defect

## stzChainOfTruth -- natural/stzChainOfTruth.ring (3)

- `Containing` (line 772): Raises error Syntax error today for any text or list, instead of tagging the chain with whether the value holds p. -- tested with a text and with a list, and both raised Syntax error! Check the condition you provided, because it builds the condition between braces and Where refuses braces
- `ContainingNo` (line 827): Raises error Syntax error today for any text or list, instead of tagging the chain with whether the value lacks p. -- tested with a text and with a list, and both raised Syntax error! Check the condition you provided, for the same reason as Containing
- `Nth` (line 969): Raises error R13 Object is required today for a number, instead of returning the nth item such as the 7th letter of HUSSEIN. -- the call NthLetterOf(7, "HUSSEIN") on its own works and answers N; the failure is in the last line of the method, which builds the result with the name _, an attribute inside the class

## stzChainOfValue -- natural/stzChainOfValue.ring (3)

- `IsANumber` (line 761): Returns the chain itself whatever the value holds, so it does not answer today whether the value is a number. -- tested with a number, a text and a list: the answer is always the chain, never 1 or 0
- `IsAList` (line 925): Returns nothing today: the method has an empty body and does not test the value. -- tested with a number, a text and a list: the answer is always an empty text
- `IsAnObject` (line 933): Returns nothing today: the method has an empty body and does not test the value. -- tested with a number and a text: the answer is always an empty text

## stzEntity -- natural/stzEntity.ring (3)

- `IsOfType` (line 424): TRUE if the entity type equals the given type. -- the comparison lower-cases only the argument, so a stored type such as Person never matches (w13 defect file)
- `HasName` (line 434): TRUE if the entity name equals the given name. -- the comparison lower-cases only the argument, so a stored name such as Ana never matches (w13 defect file)
- `IsEmpty` (line 461): TRUE if the entity holds nothing beyond name and type. -- the test is that the size equals 2, but created is always a third property, so it can never be TRUE (w13 defect file)

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

## stzListOfBytes -- number/stzListOfBytes.ring (6)

- `BytesOfThisChar` (line 458): Does nothing today and answers an empty text instead of the bytes of a character. -- the definition has no body, so the argument is never read; BytesOfChar answers the bytes (tried on abc with b, and on héllo with é)
- `FillWithAsciiCharUpToNChars` (line 585): Raises error R21 today instead of filling the content with one ASCII character repeated for a number of characters. -- raises the error R21 Using operator with values of incorrect type, because nChars is multiplied by NumberOfBytesPerChar, which answers a list of pairs and not a number (tried on abc with 2, and on abcd with 3)
- `ToUTF8` (line 788): Raises error R14 today instead of answering the bytes as UTF-8. -- raises the error R14 Calling Method without definition: toutf8, because it forwards to a stzString method that does not exist (tried on abc and on aé€)
- `Bits` (line 1148): Does nothing today and answers an empty text: its body is a TODO that waits for a list of bits class.
- `ToStzListOfBits` (line 1156): Does nothing today and answers an empty text: its body is a TODO that waits for a list of bits class.
- `Stripped` (line 1237): Does nothing today and answers an empty text instead of the bytes without the spaces at both ends. -- the definition has no body; Trimmed answers the trimmed bytes (tried on '  ab c  ' and on 'x ')

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

## stzListOfObjects -- object/stzListOfObjects.ring (3)

- `init` (line 36): Raises error R14 today instead of building a list of objects from the given list. -- the type check calls IsListOfObjects on a stzList, a method that does not exist, so every list raises R14 Calling Method without definition: islistofobjects (tried with one object and with two); a value that is not a list raises Incorrect param type
- `Content` (line 50): Returns an empty text today instead of the list of objects, because the method names the list and does not return it. -- the body is the bare name @aContent with no return, so the list is never handed back, even for a holder built without init
- `Copy` (line 58): Raises error today instead of returning a copy of the list: it calls Content, which returns nothing, and init then refuses it. -- raises Incorrect param type! paoObjects must be a list of objects

## stzMultiObjectiveSolver -- optim/stzMultiObjectiveSolver.ring (1)

- `exportParetoFrontCSV` (line 1154): Raises error R41 today instead of writing the front to a file, one row per solution. -- a variable value, a number, is joined to a comma with + and Ring cannot add a number to a text; it raises for the front of every problem tried (two problems, epsilon-constraint method)

## stzReactiveSystem -- reactive/stzReactive.ring (7)

- `StopSafe` (line 258): Raises the STOPPED banner error today instead of stopping the system on the next tick, from inside the loop. -- the timer callback it schedules calls Stop without the object, so Ring reaches the global Stop of the profiler, which raises the STOPPED banner and the loop never ends cleanly
- `SafeStopLoop` (line 271): Raises the STOPPED banner error today instead of stopping the system on the next tick; another spelling of the safe stop. -- it forwards to StopSafe, whose scheduled callback reaches the profiler's global Stop and raises
- `SafeStopExecution` (line 280): Raises the STOPPED banner error today instead of stopping the system on the next tick; another spelling of the safe stop. -- it forwards to StopSafe, whose scheduled callback reaches the profiler's global Stop and raises
- `SafeStopLoopExecution` (line 289): Raises the STOPPED banner error today instead of stopping the system on the next tick; another spelling of the safe stop. -- it forwards to StopSafe, whose scheduled callback reaches the profiler's global Stop and raises
- `StopNext` (line 298): Raises the STOPPED banner error today instead of stopping the system on the next tick; another spelling of the safe stop. -- it forwards to StopSafe, whose scheduled callback reaches the profiler's global Stop and raises
- `StopNextLoop` (line 307): Raises the STOPPED banner error today instead of stopping the system on the next tick; another spelling of the safe stop. -- it forwards to StopSafe, whose scheduled callback reaches the profiler's global Stop and raises
- `BindObjects` (line 422): Leaves both objects unchanged today instead of keeping an attribute of the target in step with one of the source. -- it wraps copies of both objects, because Ring copies an object it is handed, so the binding links two throwaway wrappers and neither the source nor the target you passed ever changes

## stzReactor -- reactive/stzReactor.ring (2)

- `SubmitSpawn` (line 211): Starts a program on the loop and returns at once with the job id; the program runs off the Ring thread and its output is fetched later. -- a plain text instead of a list raises error R21, because the wrap into a list is skipped inside the method
- `Spawn` (line 289): Runs a program and waits for it to end, returning what it printed; the exit code is then in SpawnLastStatus. -- a plain text instead of a list raises error R21, because the wrap into a list is skipped inside SubmitSpawn

## stzListex -- regex/stzListex.ring (1)

- `NormalizeListString` (line 1120): Raises error R3 today instead of removing the spaces from the text of a list. -- raises Calling Function without definition: @stzreplace (R3), because it calls a function that does not exist

## stzListexuter -- regex/stzListexUter.ring (1)

- `GetDependencyChain` (line 461): Raises a stack overflow today instead of returning the triggers a trigger depends on. -- every log entry lists its own trigger in dependson, so the method calls itself on that same trigger without end; confirmed with the triggers pair and t1

## stzMatrex -- regex/stzMatrex.ring (17)

- `Match` (line 557): TRUE if the matrix satisfies every term of the pattern; a success also records its size, properties and matrix as the matched parts. -- known defects: the terms row, col, pattern, determinant and sum accept every matrix, diagonal accepts every square one, quantifiers are never applied, and size(<n), size(>n) or a size with m or n for a number accept every matrix
- `CheckSize` (line 713): TRUE if the matrix has the size a token states, such as 3x3. -- a size with m or n in place of a number, such as 3xn, accepts every matrix, and the > and < forms never apply
- `CheckRows` (line 879): Returns TRUE for every matrix today instead of testing a condition on the rows. -- the body is a stub that returns 1, so a row term never rejects a matrix
- `CheckCols` (line 891): Returns TRUE for every matrix today instead of testing a condition on the columns. -- the body is a stub that returns 1, so a col term never rejects a matrix
- `CheckDiagonal` (line 903): TRUE if the matrix is square; the diagonal terms of the token are not tested. -- it only tests squareness, so any square matrix passes whatever the term asks
- `CheckPattern` (line 1021): Returns TRUE for every matrix today instead of testing a visual or structural pattern. -- the body is a stub that returns 1
- `CheckDeterminant` (line 1033): TRUE if the matrix is square; the determinant value that the token states is not tested. -- the body only tests squareness, so determinant(5) accepts a matrix whose determinant is -3
- `CheckSum` (line 1051): Returns TRUE for every matrix today instead of testing the sum of its elements. -- the body adds the elements up and ignores the result
- `MatchesNone` (line 1421): Returns TRUE when at least one matrix of the list matches, which is the reverse of what its name promises. -- the loop returns 1 at the first match and 0 when there is none, the opposite of none matching
- `RemoveConstraint` (line 1500): Removes the token at a position from the parsed tokens, so that Match stops testing it. -- the pattern text is not changed, so Pattern and Explain still show the removed term
- `SimilarityScore` (line 1520): Returns the share of cells that are equal in two matrices of the same size, from 0 to 1; matrices of different sizes score 0. -- the wrapped forms [ "between", m ] and [ "and", m ] that the body tries to accept raise an error, because it stores the inner matrix in a misspelled variable
- `CommonProperties` (line 1703): Returns the names among square, symmetric, diagonal, identity, zero, upper and lower that every matching matrix of the list has. -- known defects: square is never reported, because the property test has no such branch, and when no matrix matches every name is returned
- `Andd` (line 1817): Raises error R24 today instead of returning a pattern that holds both patterns joined by &. -- it forwards the misspelled variable oOtherMatriex, which is uninitialized
- `Not_` (line 1847): Returns a new matrex whose pattern has @! in front of the whole pattern; this object does not change. -- the negation lands on the first term only, so for a pattern with several terms the result is not the opposite of the original
- `ToJSON` (line 1864): Raises error R21 today instead of returning the pattern and its tokens as JSON text; only the empty pattern works. -- it joins pair lists into a text, which is an operator on the wrong type, so every token raises R21
- `TokensToJSON` (line 1878): Raises error R21 today instead of returning the tokens as a JSON array; an empty token list gives []. -- each token is a list of pairs and the body adds a pair to a text, which raises R21
- `TokenToJSON` (line 1898): Raises error R21 today instead of returning one token as a JSON object. -- it adds a pair list to a text, which raises R21, because tokens are lists of pairs and not flat key and value lists

## stzRegex -- regex/stzRegex.ring (10)

- `FindMatches` (line 749): Returns the start position of each match of the pattern in the last text given to a match call. -- it continues from one character past the end of each match, so a match that starts right after the previous one is skipped: \d on 1234 answers [ 1, 3 ] while Matches finds four
- `HasGroups` (line 954): TRUE if the last match call left captures; the whole match counts as capture 0, so it is TRUE after any successful match. -- a pattern without any parentheses also answers TRUE after a match, and a pattern with groups answers FALSE until a match succeeded
- `FindCapture` (line 1199): Returns the start position of each match of the pattern in the last text given to a match call. -- it walks the matches like FindMatches, so a match that starts right after the previous one is skipped
- `LastError` (line 1378): Returns an empty text today instead of the compile error of the pattern. -- the body is a stub that returns "", so an invalid pattern gives no message
- `PatternErrorOffset` (line 1387): Returns -1 today instead of the position of the compile error in the pattern. -- the body is a stub that returns -1, even for a pattern that does not compile
- `FindPartialMatch` (line 1509): Returns the position where a partial or complete match starts in the text; raises an error when there is no match at all. -- for a text that does not match it reads the first element of an empty section and raises error R2
- `PartialMatchLength` (line 1535): Returns the length of the partial or complete match today minus one: the partial match 123- gives 3. -- it subtracts an inclusive start from an inclusive end without adding one, so 12 matched by \d{3} gives 1 and a complete 123 gives 2
- `RecursiveDepth` (line 1889): Returns the number of distinct nested matches found by the last recursive match, which is the nesting depth only for a single chain. -- it counts matches, so ((x)(y)(z)) answers 4 although the nesting is 2 deep, while (((x))) answers 3
- `NestedDepth` (line 1898): Returns the number of distinct nested matches found by the last recursive match; the same count as the recursive depth. -- it counts matches, so ((x)(y)(z)) answers 4 although the nesting is 2 deep
- `Explain` (line 1938): Returns a one-line explanation of the pattern when the library knows it by name; any other pattern raises an error. -- for a pattern outside the library's named list it builds stzRegexAnalyzer, a class that does not exist, and raises error R11

## stzRecursiveRegexMaker -- regex/stzRegexMaker.ring (3)

- `Pattern` (line 1642): Raises error R19 today when a level exists, instead of returning the pattern joined from the root levels. -- tested with one level, with three levels and with a quantifier, and each raised error R19 Calling function with less number of parameters, because the helper calls HasKey with one argument
- `SubPattern` (line 1667): Raises error R19 today for an existing level, instead of returning the pattern built from that level; an unknown level gives an empty text. -- tested with a top level and with a child level, and both raised error R19, for the same cause as Pattern
- `pvtBuildPattern` (line 1807): Raises error R19 today for any existing level, instead of returning its pattern with its children and its quantifier. -- the call HasKey(_level_[:quant]) lacks its second argument, which makes Pattern and SubPattern raise

## stzRegexMaker -- regex/stzRegexMaker.ring (12)

- `Quantifiers` (line 435): Returns an empty text today, because the method is an unwritten placeholder. -- placeholder: the body is a TODO and nothing is computed
- `QuantifiersCommands` (line 443): Returns an empty text today, because the method is an unwritten placeholder. -- placeholder: the body is a TODO and nothing is computed
- `NumberOfSequences` (line 477): Raises error R24 today instead of returning how many sequences were recorded. -- Raises error R24 today: the body reads len(acSequences), a variable that is never set, where @aSequences is meant; HowManySequences, CountSequences, NumberOfSeqs, HowManySeqs, CountSeqs, NumberOfCommands, HowManyCommands and CountCommands forward to it and raise the same error
- `CommandAndFragment` (line 565): Raises error R24 today instead of returning a sequence together with its fragment. -- Raises error R24 today: the alias passes n to SequenceXT but declares no parameter, so n is an unset variable; SequenceXT(1) itself works and answers [ sequence, piece ]
- `CommandAndFrag` (line 574): Raises error R24 today instead of returning a sequence together with its fragment. -- Raises error R24 today: the alias passes an unset n to SequenceXT
- `CommandAndItsFragment` (line 583): Raises error R24 today instead of returning a sequence together with its fragment. -- Raises error R24 today: the alias passes an unset n to SequenceXT
- `CommandAndItsFrag` (line 592): Raises error R24 today instead of returning a sequence together with its fragment. -- Raises error R24 today: the alias passes an unset n to SequenceXT
- `CanContainAChar` (line 645): Raises error R14 today instead of adding a character class given as a named parameter such as :Between = [ A, Z ]. -- Raises error R14 today: it calls IsBetweenOrFromNamedParam on a stzList, a method that does not exist; seen with the Between, Among and From forms, and a text instead of a list raises Incorrect param type!
- `CanContaingChar` (line 688): Raises error R14 today instead of adding a character class given as a named parameter. -- Raises error R14 today: it calls CanContainAChar, which calls the missing IsBetweenOrFromNamedParam
- `CanContainADigit` (line 812): Raises error R14 today instead of adding a digit class given as a named parameter such as :Between = [ 0, 9 ]. -- Raises error R14 today: it calls IsBetweenOrFromNamedParam on a stzList, a method that does not exist; seen with the Between, Among and From forms
- `CanContaingdigit` (line 847): Raises error R14 today instead of adding a digit class given as a named parameter. -- Raises error R14 today: it calls CanContainADigit, which calls the missing IsBetweenOrFromNamedParam
- `MatchSameContentAs` (line 1371): Raises error R24 today instead of appending a closing tag that repeats a defined group. -- Raises error R24 today: after finding the group it uses the variable pcTagGroupName, which is not a parameter of this method; seen with two different group names

## stzRegexuter -- regex/stzRegexUter.ring (1)

- `GetDependencyChain` (line 410): Raises a stack overflow today instead of returning the triggers a trigger depends on. -- every log entry lists its own trigger in dependson, so the method calls itself on that same trigger without end; confirmed with the trigger num and the trigger d

## stzTimex -- regex/stzTimex.ring (3)

- `SplitByOperator` (line 177): Returns the whole text as one piece today instead of cutting it at an operator outside brackets. -- the brackets are tracked correctly, only the comparison fails
- `MatchExact` (line 506): TRUE if the pattern matches the whole target, with nothing left over. -- because of the parser defect, only single-token patterns are meaningful; Match is the same call
- `MatchPartial` (line 527): TRUE if the pattern matches somewhere inside the target, starting at any item. -- because of the parser defect, only single-token patterns are meaningful; any text in a list counts as an instant, so @Instant matches a list holding the text x

## stzOidcProvider -- security/stzOidcProvider.ring (1)

- `IssueIdTokenAt` (line 526): Signs an ID token as IssueIdToken does, with the issue time you give, so that exp is pnNow plus the token lifetime. -- same escaping defect as IssueIdToken

## stzSoundGraph -- sound/stzSoundGraph.ring (1)

- `OutputNode` (line 183): Returns the index of the node the graph hands to the world. -- a node added after the graph was prepared can reset this to 0, see the defects file

## stzSoundLive -- sound/stzSoundLive.ring (3)

- `CaptureInsteadOfDevice` (line 191): Chooses to drain the sound into a buffer instead of a sound card, for at most a number of seconds. -- refused once the loops have started; the buffer is silent beyond what was heard; WaitCycles for longer than pnSeconds never returns, see the defects file
- `WaitCycles` (line 410): Lets the session run for a number of heard cycles, starting it first when needed, and then returns. -- in capture mode it never returns when the wait is longer than the capture buffer, see the defects file; without capture it plays on a device, which was not run in this reference
- `Landings` (line 580): Returns where each definition of a loop took effect. -- before the loops start every landing is cycle 0 and the heard cycle is -1; a loop redefined twice before the start and once while running is numbered v3 and then v2, so version numbers can go back, see the defects file

## stzCoeffExtractor -- stats/stzCoeffExtractor.ring (3)

- `numericalDerivative` (line 268): Raises error R42 today instead of returning the slope of the expression along one variable at the test point 10. -- every call raises R42 Error in eval() function (checked on x/8 + y/4 and pow(x, 2)), because evaluateExpression builds an empty formula
- `evaluateExpression` (line 309): Raises error R42 today instead of returning the value of an expression at a point. -- the variables are replaced by calling ManyReplaced with a list of new texts, which takes ONE new text and returns an empty text, so the evaluated formula is empty and eval fails with a syntax error (checked on x + y and x + 1)
- `validateExpression` (line 396): Returns 0 for every expression today instead of telling whether it can be evaluated. -- it calls createTestValues with an argument that method does not take, which raises inside its try, so the answer is always 0 (checked on x + 1 and x + y)

## stzDataSet -- stats/stzDataSet.ring (3)

- `NonParametricCorrelation` (line 2924): Raises error R24 today instead of returning a rank correlation. -- the body reads a variable named _oOtherStats_ that this method does not receive
- `MutualInformation` (line 3144): Returns the mutual information, in bits, between this data and another data set of the same length. -- the pairs are joined with an underscore and split again, so a value containing an underscore gives a wrong result: "a_b" and "c_d" against x and y give 0 where ab and cd give 1
- `PlanSummary` (line 3983): Raises error R5 today instead of returning a text preview of a plan's steps without running it. -- the body reads the title from a variable named oPlan, which does not exist, instead of from the plan it built

## stzLinearSolver -- stats/stzLinearSolver.ring (3)

- `solveWithBranchAndBound` (line 624): Raises error today instead of solving by branch and bound, which is not implemented yet. -- an honesty guard stops the method on its first line, so the branching code after it never runs; use "greedy" or "simplex"
- `CalculateFitness` (line 1274): Raises error R5 today instead of returning the objective value less the constraint penalty, negated when minimizing. -- it raises whenever the problem has a constraint, because CalculatePenalty fails (two problems); with no constraint it returns the objective value, negated when minimizing
- `CalculatePenalty` (line 1293): Raises error R5 today instead of returning 1000 times the total constraint violation of a candidate. -- line 995 reads a variable oConst that is never defined, ahead of the correct line; it raises with one constraint and with two, and returns 0 when the problem has none

## stzString -- string/stzString.ring (1)

- `IsCurrencySymbol` (line 9373): Answers FALSE today: the currency symbol check is a stub that waits for the locale data.

## stzStringChar -- string/stzStringChar.ring (10)

- `CanRetrieveName` (line 967): Answers TRUE when the Unicode database holds a name for the char, and raises when it does not. -- for an unnamed code such as U+0378 it raises "Can't proceed!" instead of answering FALSE, because it asks for the name and the name request raises
- `AsciiCode` (line 1018): Returns the ASCII code of the char, 0 to 127; for a char above 127 it raises R3 instead of a clear message. -- the failure branch calls stzCharError, which is defined nowhere, so a non-ASCII char raises R3 "Calling Function without definition"
- `IsLeftToRightIsolate` (line 1222): Returns an empty string today instead of TRUE for the left-to-right isolate mark, U+2066. -- the body is only a comment ("Reserved for future implementation"), so the answer is always empty
- `IsRightToLeftIsolate` (line 1230): Returns an empty string today instead of TRUE for the right-to-left isolate mark, U+2067. -- the body is only a comment ("Reserved for future implementation"), so the answer is always empty
- `IsEuropean` (line 1443): Raises error R14 today instead of TRUE for a European number, separator or terminator. -- the body calls IsEuropeanNumber, which is defined nowhere
- `Mirrored` (line 1735): Raises error R3 today instead of returning the mirror partner of the char. -- the body calls CharFromUnicode, which is defined nowhere
- `IsOtherCircledChar` (line 1997): Raises error R3 today instead of testing for a circled char outside the digits and Latin letters. -- the body calls OtherCircledCharUnicodes, which is defined nowhere
- `IntroducedInUnicodeVersion` (line 2067): Returns a rough Unicode version taken from the char's block, "0.9" for nearly every char and "3.2" for emoji. -- the version list is an approximation, marked #TODO in the data file ("Put correct values"); emoji were added in Unicode 6
- `DefaultLanguage` (line 2155): Returns the main language of the char's script, such as english, arabic or hebrew, and undefined for chars shared by scripts. -- raises "Can not create char object!" for a char of the Inherited or Unknown script, such as a combining accent, an unassigned code or a private-use char
- `TaiThamScript` (line 2857): Raises error R14 today instead of testing for the Tai Tham script. -- the body calls ScriptCode, which was retired; ScriptIs("taitham") is the working test

## stzStringChecker -- string/stzStringChecker.ring (3)

- `HasLeadingChars` (line 607): Returns 0 today whatever the text is, instead of telling whether the text starts with a repeated character. -- answers FALSE for aab and for xxyy alike: it compares two engine handles, which are never equal, instead of the two characters; the stzString method of the same name answers 1 for aab
- `HasTrailingChars` (line 624): Returns 0 today whatever the text is, instead of telling whether the text ends with a repeated character. -- answers FALSE for abb and for xxyy alike: it compares two engine handles, which are never equal, instead of the two characters
- `HasLeadingAndTrailingChars` (line 642): Returns 0 today whatever the text is, because both of the questions it combines answer 0. -- answers FALSE for aabaa: it is the AND of HasLeadingChars and HasTrailingChars, which are always 0

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
- `Matches` (line 1760): TRUE if every string matches the pattern as a whole, so "a." matches ab and "a" does not; an empty list is TRUE. -- the old comment says it returns the strings that match, but it answers one verdict for the whole list

## stzStringPerformer -- string/stzStringPerformer.ring (3)

- `Content` (line 62): Returns the text the performer holds, which no method of this class changes today.
- `Perform` (line 92): Leaves the text unchanged today instead of replacing every character by the result of an expression. -- Has no effect today: Perform("upper(@char)") on "abc" leaves "abc", because the result of the engine call is dropped and never written back; use Yield to get the results as a list
- `PerformOn` (line 112): Leaves the text unchanged today instead of replacing the characters at some positions by the result of an expression. -- Has no effect today: PerformOn([1], "upper(@char)") on "abc" leaves "abc"; the positions are not even read; use YieldOn

## stzStringReplacer -- string/stzStringReplacer.ring (1)

- `RemoveLast` (line 530): Leaves the text unchanged today, because the occurrence it aims at is one past the last, in place. -- it asks the nth removal for a rank equal to the number of occurrences, and that rank counts from 0 in the default case-sensitive call, so nothing is removed: one two one two one, aaa bbb and its b stay as they are; RemoveLastCS(..., 0) does remove the last occurrence

## stzStringSplitter -- string/stzStringSplitter.ring (4)

- `Partition` (line 564): Returns only the text before the first separator, in a one-item list, today instead of the cut into before, separator and after. -- the engine hands back the three pieces in a buffer separated by NUL bytes and Ring reads only up to the first one, so key=value=more with = gives only key; confirmed with a-b, x=y=z, one two and a Hebrew text; stzString.Partition gives the real three-part cut
- `PartitionAfter` (line 583): Returns only the text behind the first separator, in a one-item list, today instead of the cut that keeps the separator on the first part. -- the NUL-separated engine buffer is read up to its first NUL, so key=value=more with = gives only value=more; confirmed with a-b, x=y=z and a Hebrew text
- `RPartition` (line 602): Returns only the text before the last separator, in a one-item list, today instead of the cut into before, separator and after. -- the NUL-separated engine buffer is read up to its first NUL, so key=value=more with = gives key=value; confirmed with x=y=z
- `RPartitionAfter` (line 621): Returns only the text behind the last separator, in a one-item list, today instead of the cut that keeps the separator on the first part. -- the NUL-separated engine buffer is read up to its first NUL, so key=value=more with = gives only more; confirmed with x=y=z and a Hebrew text

## stzStringSubStringCS -- string/stzStringSubString.ring (1)

- `Positions` (line 182): Raises error R14 today instead of returning the position of every occurrence. -- it calls FindAllCS on the finder, a method that does not exist, so Positions and Occurrences raise for every input; confirmed with Banana bandana and with banana

## stzStringText -- string/stzStringText.ring (3)

- `OnlyScript` (line 386): Raises error R24 today instead of returning the part of the text written in a given script. -- raises Using uninitialized variable pcscript for :Latin, :Hebrew and :Arabic alike: the anonymous function it builds does not see its own parameter
- `OnlyArabic` (line 402): Raises error R14 today instead of returning the Arabic-script part of the text. -- raises Calling Method without definition: concatenateq on a Latin text and on an Arabic text alike
- `OnlyLatin` (line 416): Raises error R14 today instead of returning the Latin-script part of the text. -- raises Calling Method without definition: concatenateq on a Latin text and on a mixed text alike

## stzTextStream -- string/stzTextStream.ring (6)

- `SetFromFile` (line 64): Raises error R20 today instead of attaching a file as the source of the stream. -- raises Calling function with extra number of parameters (R20): it builds new stzFile(pcFile, :WriteToEnd) and stzFile takes one parameter; nothing is attached and SourceOfStream stays NULL (checked on a scratch file, twice)
- `SetEncoding` (line 133): Raises error Bad parameter type! today instead of selecting the stream's text encoding by name. -- raises for UTF-8, utf8 and ISO-8859-1; only an empty text passes, and it selects nothing; the underlying call wants a QTextCodec object, which this class cannot build
- `IsSetFromFile` (line 194): Returns a flag meant to tell that the stream reads a file, which stays NULL or 0 whatever is attached today. -- never TRUE: the setter writes _bSetFromFile_ while the getter reads _bIsSetFromFile_, two different attributes
- `IsSetFromSocket` (line 205): Returns a flag meant to tell that the stream reads a socket, which stays NULL or 0 whatever is attached today. -- never TRUE: after SetFromScocket it answers 0 while SourceOfStream answers socket; the setter writes _bSetFromSocket_ and the getter reads _bIsSetFromSocket_
- `IsSetFromProcess` (line 215): Raises error R24 today instead of telling that the stream reads a process. -- raises Using uninitialized variable: reurn, a misspelled return, before and after SetFromProcess
- `Flush` (line 342): Raises error R14 today instead of flushing the stream. -- raises Calling Method without definition: flash, a misspelled call to flush on the QTextStream

## TableDisplayConfig -- table/stzPivotTableShow.ring (1)

- `GetDimensionGroupWidth` (line 464): Raises error R5 today instead of returning the width of one group of columns. -- it reads a variable that belongs to CalculateLayout and is empty here; the same error for 1 and for 2
