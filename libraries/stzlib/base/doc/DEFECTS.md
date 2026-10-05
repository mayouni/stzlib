# Defects found while documenting the library (generated)

Each row is a method whose doc block says it is broken **today**: it raises, does nothing, or answers wrongly.
They were found by calling every method once with real data before its block was written (DOCREFORM waves 1-4),
and each was checked with a second call on different data. **None is fixed yet.** The register is generated from
`reference.json` by `doc/tools/wave/mk_defects.py`: fix the method, fix its block (or drop the warning), regenerate.

**At least 706 methods in 41 classes** (the register only catches the blocks worded as defects; the per-wave notes with the evidence list more, for instance stzTimeLine.HasMoment): `doc/tools/wave/data/w*_defects*.md`.

| file | class | defects |
|---|---|---|
| table/stzTable.ring | stzTable | 191 |
| list/stzListOfLists.ring | stzListOfLists | 69 |
| number/stzListOfNumbers.ring | stzListOfNumbers | 65 |
| list/stzHashList.ring | stzHashList | 56 |
| file/stzFolder.ring | stzFolder | 34 |
| list/stzGrid.ring | stzGrid | 26 |
| datetime/stzCalendar.ring | stzCalendar | 25 |
| string/stzStringChar.ring | stzStringChar | 23 |
| list/stzList.ring | stzList | 22 |
| number/stzNumber.ring | stzNumber | 20 |
| geo/stzGeoMap.ring | stzGeoMap | 18 |
| i18n/stzLocale.ring | stzLocale | 17 |
| regex/stzMatrex.ring | stzMatrex | 17 |
| datetime/stzDateTime.ring | stzDateTime | 15 |
| graph/stzGraph.ring | stzGraph | 12 |
| list/stzListOfPairs.ring | stzListOfPairs | 11 |
| graph/stzOrgChart.ring | stzOrgChart | 10 |
| regex/stzRegex.ring | stzRegex | 10 |
| string/stzString.ring | stzString | 9 |
| reactive/stzReactive.ring | stzReactiveSystem | 7 |
| geo/stzGeoField.ring | stzGeoField | 5 |
| geo/stzGeoSamples.ring | stzGeoSamples | 5 |
| graph/stzDiagram.ring | stzDiagram | 5 |
| stats/stzDataSet.ring | stzDataSet | 5 |
| graph/stzGraph.ring | stzGraphComparison | 3 |
| appserver/stzAppServer.ring | stzAppServer | 2 |
| datetime/stzDate.ring | stzDate | 2 |
| geo/stzGeoFeatures.ring | stzGeoFeatures | 2 |
| geo/stzGeoProcess.ring | stzGeoProcess | 2 |
| graph/stzGraphQuery.ring | stzGraphQuery | 2 |
| graph/stzKnowledgeGraph.ring | stzKnowledgeGraph | 2 |
| math/stzMathFigure.ring | stzMathFigure | 2 |
| number/stzMatrix.ring | stzMatrix | 2 |
| reactive/stzReactor.ring | stzReactor | 2 |
| string/stzStringList.ring | stzStringList | 2 |
| common/stzSplitter.ring | stzSplitter | 1 |
| datetime/stzTimeLine.ring | stzTimeLine | 1 |
| geo/stzGeoProjection.ring | stzGeoProjection | 1 |
| graph/stzOrgChart.ring | stzOrgChartReporter | 1 |
| graph/stzOrgChart.ring | stzOrgChartSimulation | 1 |
| linguistic/stzText.ring | stzText | 1 |

## stzAppServer -- appserver/stzAppServer.ring (2)

- `Use` (line 492): Leaves every request unchanged today instead of running the middleware before the routes under a path. -- The middleware is stored in the router but nothing ever reads the list, so it never runs (checked with paths /a, / and *)
- `Static` (line 504): Leaves a folder unserved today instead of serving its files under a path; a request for a file in it answers 404. -- The static routes are stored in the router but nothing ever reads the list (checked with paths /files and /)

## stzSplitter -- common/stzSplitter.ring (1)

- `SplitAroundSection` (line 1923): Raises error R14 today instead of returning the sections left around one section. -- Raises error R14 today because it calls AntiSectionZZ, which exists nowhere

## stzCalendar -- datetime/stzCalendar.ring (25)

- `AvailableHours` (line 1088): Raises Not yet implemented! today instead of returning the list of available hour slots of the calendar. -- the body is a stub that raises Not yet implemented!; the form that works is AvailableHoursN
- `AvailableHoursBetween` (line 1141): Raises Not yet implemented! today instead of returning the available hour slots between two dates. -- the body is a stub that raises Not yet implemented!; the form that works is AvailableHoursBetweenN
- `HasAvailableHoursBetween` (line 1210): Raises Not yet implemented! today instead of telling whether the range holds available hours. -- calls AvailableHoursBetween, which is a stub
- `AvailableHoursOn` (line 1220): Raises Not yet implemented! today instead of returning the available hour slots of one day. -- the body is a stub that raises Not yet implemented!; the form that works is AvailableHoursOnN
- `ContainsAvailableHoursOn` (line 1274): Raises Not yet implemented! today instead of telling whether a day has available hours. -- calls AvailableHoursOn, which is a stub
- `HasAvailableHoursOn` (line 1284): Raises Not yet implemented! today instead of telling whether a day has available hours. -- calls AvailableHoursOn, which is a stub
- `AvailableDaysBetween` (line 1368): Raises Not yet implemented! today instead of returning the available days between two dates. -- the body is a stub that raises through raise()
- `AvailableDaysBetweenN` (line 1378): Raises error R14 today instead of counting the available days between two dates. -- calls AvailabelDaysBetween, a misspelling of a method that is itself a stub
- `ContainsAvailableDaysBetween` (line 1394): Raises error R14 today instead of telling whether the range holds available days. -- calls AvailableDaysBetweenN, which raises R14
- `HasAvailableDaysBetween` (line 1404): Raises error R14 today instead of telling whether the range holds available days. -- calls AvailableDaysBetweenN, which raises R14
- `AvailableWeeks` (line 1413): Raises Not yet implemented! today instead of returning the available weeks as pairs of dates. -- the body is a stub that raises Not yet implemented!
- `NextDay` (line 1719): Raises Not yet implemented! today instead of answering the day after the calendar's current day. -- the body is a stub that raises Not yet implemented!; the calendar keeps no current day
- `GoToNextDay` (line 1729): Raises Not yet implemented! today instead of moving the calendar to the next day. -- the body is a stub that raises Not yet implemented!
- `PreviousDay` (line 1743): Raises Not yet implemented! today instead of answering the day before the calendar's current day. -- the body is a stub that raises Not yet implemented!; the calendar keeps no current day
- `GoToPreviousDay` (line 1751): Raises Not yet implemented! today instead of moving the calendar to the previous day. -- the body is a stub that raises Not yet implemented!
- `GoToNext` (line 1808): Raises error R14 today instead of moving the calendar to the next month. -- calls GoNextMonth, which exists nowhere
- `GoTo` (line 1925): Raises Not yet implemented! today instead of moving the calendar to a given date. -- the body is a stub that raises Not yet implemented!
- `CurrentDay` (line 1957): Returns the day of the month of today, read from the clock and not from the calendar.
- `CurrentMonth` (line 1966): Returns the English name of today's month, read from the clock and not from the calendar.
- `CurrentMonthN` (line 1980): Returns the number of today's month, read from the clock and not from the calendar.
- `CurrentYear` (line 1989): Returns today's year, read from the clock and not from the calendar.
- `HasWeekends` (line 2112): Answers nothing today instead of telling whether the calendar has weekend days. -- the method has no body
- `WeekendsBetween` (line 2121): Raises Not yet implemented! today instead of returning the weekend days between two dates. -- the body is a stub that raises Not yet implemented!
- `WeekendsBetweenN` (line 2131): Raises Not yet implemented! today instead of counting the weekend days between two dates. -- calls WeekendsBetween, which is a stub
- `ConflictsWithSpan` (line 2578): Raises error R24 today instead of listing the days where a named span meets a holiday or a day off. -- tests an undefined variable oTimeLine instead of the attached timeline, so it raises Using uninitialized variable: otimeline for any label

## stzDate -- datetime/stzDate.ring (2)

- `ToHuman` (line 1910): Returns today, tomorrow or yesterday for those days, a count of days for the next or last 7, else a long date. -- the future form starts with a capital (In 3 days) and the past form does not (3 days ago)
- `ToRelative` (line 1944): Returns today, tomorrow or yesterday, a count of days or weeks within a month of today, else the date as dd/MM/yyyy.

## stzDateTime -- datetime/stzDateTime.ring (15)

- `ToVerbose` (line 2471): Returns the weekday, month name, year and a 12-hour time, with the day number printed as the letter d today. -- the day of the month comes out as the letter d (Sunday, March d, 2026 02:30:00 PM) because the single d of the pattern is never replaced; ToLong prints the day correctly
- `ToVerbose12h` (line 2482): Returns the weekday, month name, year and a 12-hour time, with the day number printed as the letter d today. -- the day of the month comes out as the letter d (Sunday, March d, 2026 02:30:00 PM) because the single d of the pattern is never replaced; ToLong prints the day correctly
- `ToVerboseAP` (line 2493): Returns the weekday, month name, year and a 12-hour time, with the day number printed as the letter d today. -- the day of the month comes out as the letter d (Sunday, March d, 2026 02:30:00 PM) because the single d of the pattern is never replaced; ToLong prints the day correctly
- `ToVerboseAmPm` (line 2504): Returns the weekday, month name, year and a 12-hour time, with the day number printed as the letter d today. -- the day of the month comes out as the letter d (Sunday, March d, 2026 02:30:00 PM) because the single d of the pattern is never replaced; ToLong prints the day correctly
- `ToVerboseWithAP` (line 2515): Returns the weekday, month name, year and a 12-hour time, with the day number printed as the letter d today. -- the day of the month comes out as the letter d (Sunday, March d, 2026 02:30:00 PM) because the single d of the pattern is never replaced; ToLong prints the day correctly
- `ToVerboseWithAmPm` (line 2526): Returns the weekday, month name, year and a 12-hour time, with the day number printed as the letter d today. -- the day of the month comes out as the letter d (Sunday, March d, 2026 02:30:00 PM) because the single d of the pattern is never replaced; ToLong prints the day correctly
- `ToVerbose24h` (line 2537): Returns the weekday, month name, year and a 24-hour time, with the day number printed as the letter d today. -- the day of the month comes out as the letter d (Sunday, March d, 2026 02:30:00 PM) because the single d of the pattern is never replaced; ToLong prints the day correctly
- `ToVerboseWithoutAP` (line 2548): Returns the weekday, month name, year and a 24-hour time, with the day number printed as the letter d today. -- the day of the month comes out as the letter d (Sunday, March d, 2026 02:30:00 PM) because the single d of the pattern is never replaced; ToLong prints the day correctly
- `ToVerboseWithoutAmPm` (line 2559): Returns the weekday, month name, year and a 24-hour time, with the day number printed as the letter d today. -- the day of the month comes out as the letter d (Sunday, March d, 2026 02:30:00 PM) because the single d of the pattern is never replaced; ToLong prints the day correctly
- `ToLong24h` (line 2652): Returns the weekday, month name, year and a 24-hour time with seconds, with the day number printed as the letter d today. -- the day of the month comes out as the letter d because the single d of the pattern is never replaced; ToLong prints the day correctly
- `ToLongDate` (line 2662): Returns the weekday, month name and year without a time, with the day number printed as the letter d today. -- the day of the month comes out as the letter d because the single d of the pattern is never replaced
- `DurationInDecadesTo` (line 3530): Raises error R24 today instead of returning the decades from the datetime to a target datetime. -- raises R24 today instead of answering the decades: the parameter is named cTo but the body reads pcUnit, which does not exist there; DecadesTo works
- `MillisecondsFrom` (line 3670): Raises error R24 today instead of returning the milliseconds elapsed from a named origin up to the datetime. -- raises R24 today: the parameter is named cFrom but the body reads pOrigin, which does not exist there; DurationInMillisecondsFrom works
- `DurationInMillisecondsSince` (line 3681): Raises error R24 today instead of returning the milliseconds elapsed from a named origin up to the datetime. -- raises R24 today: the parameter is named cFrom but the body reads pOrigin, which does not exist there; DurationInMillisecondsFrom works
- `MillisecondsSince` (line 3692): Raises error R24 today instead of returning the milliseconds elapsed from a named origin up to the datetime. -- raises R24 today: the parameter is named cFrom but the body reads pOrigin, which does not exist there; DurationInMillisecondsFrom works

## stzTimeLine -- datetime/stzTimeLine.ring (1)

- `HasMoment` (line 607): Raises a stack overflow today instead of telling whether a point carries the label. -- the method calls itself, so it recurses until the interpreter stops; its spelling siblings HasInstant, ContainsMoment and ContainsInstant call it and fail the same way

## stzFolder -- file/stzFolder.ring (34)

- `IsPath` (line 682): Raises error R19 today instead of telling whether a path names a file or a folder here. -- Raises error R19 today because it calls IsFilePath and IsFolderPath without passing the path
- `IsDeepPath` (line 760): Returns nothing today instead of the verdict of the deep-path test. -- The body calls the test without a return, so the answer is lost
- `ExistingPathsAmong` (line 1287): Raises error R24 today instead of returning the paths of a list that are held here. -- Raises error R24 (uninitialized variable _cpath_) because it appends a variable it never sets, instead of the current item
- `MissingPathsAmong` (line 1319): Raises error R24 today instead of returning the paths of a list that are not held here. -- Raises error R24 (uninitialized variable _cpath_) because it appends a variable it never sets, instead of the current item
- `CountFolder` (line 1614): Returns 0 today for any folder name instead of 1 for a folder held here. -- Always answers 0, because the exact-name search compares sub1 with the listing form /sub1/ and never matches; only a pattern with * can match
- `FilesIn` (line 1722): Raises an error today instead of returning the files of a child folder, unless that child is empty. -- Raises "Incorrect param type! cPath must be non-empty a string." for a child folder that holds anything, because it tests each [ name, kind ] pair as a path; "Incorrect path!" for a path that is not a direct child
- `FoldersIn` (line 1758): Raises an error today instead of returning the folders of a child folder, unless that child is empty. -- Raises "Incorrect param type! cPath must be non-empty a string." for a child folder that holds anything, because it tests each [ name, kind ] pair as a path; "Incorrect path!" for a path that is not a direct child
- `DeepCountFileIn` (line 2002): Raises error R14 today instead of counting the files of that name below a given folder. -- Raises error R14 because it calls FindFileIn, which exists nowhere
- `DeepCountTheseFiles` (line 2012): Raises error R24 today instead of counting how many of the named files are in the tree below. -- Raises error R24 because it reads a variable _cPath_ it never sets
- `DeepCountTheseFilesIn` (line 2022): Raises error R14 today instead of counting how many of the named files are in a given folder. -- Raises error R14 because it calls SearchTheseFilesIn, which exists nowhere
- `DeepCountFolderIn` (line 2112): Raises error R14 today instead of counting the folders of that name below a given folder. -- Raises error R14 because it calls FindFolderIn, which exists nowhere
- `DeepCountTheseFoldersIn` (line 2133): Raises error R14 today instead of counting how many of the named folders are in a given folder. -- Raises error R14 because it calls SearchTheseFoldersIn, which exists nowhere
- `RelativePathFromHome` (line 2669): Returns "." at home; away from home it raises error R14 today instead of returning the path from home. -- Raises error R14 away from home because it calls GetRelativePath, which exists nowhere
- `DistanceFromHome` (line 2683): Returns 0 at home; away from home it raises error R14 today instead of counting the folder levels from home. -- Raises error R14 away from home because it calls GetRelativePath, which exists nowhere
- `DeepDeleteFile` (line 3042): Raises an error today instead of deleting the files of that name anywhere below. -- Always raises Can't navigate outside the folder!, because it tests the bare name against the process folder, so nothing is deleted (checked with a present and an absent name)
- `DeepDeleteFolder` (line 3087): Does nothing today and answers 1 instead of deleting the folders of that name anywhere below. -- Deletes nothing: the folders found are relative paths and the existence test on them fails, so the loop skips every one (checked on a deep and on a top folder)
- `FileOverwrite` (line 3390): Raises error R13 today after replacing the content of a file; the text is written first. -- Raises error R13 (Object is required) after writing in batch mode, and error R14 before writing in the default mode, so the call never returns normally
- `FileErase` (line 3462): Raises error R11 today instead of erasing a file; the file stays. -- Raises error R11 (class stzfileeraser not found) and erases nothing, so use FileRemove
- `FileSafeErase` (line 3530): Raises error R11 today instead of erasing a file safely; the file stays. -- Raises error R11 (class not found) and erases nothing, so use FileRemove
- `FileBackup` (line 3649): Raises error R20 today instead of copying a file to a .bak file beside it; no backup is made. -- Raises error R20 because it calls the global backup function with two arguments where it takes one
- `FileSafeOverwrite` (line 3697): Raises error R11 today instead of replacing a file safely; the content is left as it was. -- Raises error R11 (class not found) and writes nothing
- `FindFolders` (line 4094): Returns the folders held directly here that match a pattern with *; a plain folder name matches nothing today. -- A plain name such as sub1, or /sub1/, answers [ ] because it is compared with the listing form /sub1/ after losing its slashes; only a * pattern can match
- `DeepSearchInFolder` (line 4729): Returns [ ] today instead of the lines that hold a text in the files of the folders of that name below. -- Always answers [ ] (checked on sub1 and deep1 with texts the files hold), because it tests whether the folder path is a file and reads the folder instead of each file
- `DeepSearchInFolders` (line 4784): Returns [ ] today instead of the lines that hold a text in the files of the listed folders below. -- Always answers [ ] because DeepSearchInFolder does
- `GetFoldersContainingFileMatches` (line 4854): Raises error R24 today instead of listing the folder names on the way to files that match a pattern. -- Raises error R24 (uninitialized variable _aallpaths_) because it passes a variable it never set
- `DeepModifyInFile` (line 5075): Does nothing today and answers 0 instead of replacing a text in the files of that name below. -- Changes nothing: it hands the relative paths of DeepFindFile to the existence test, which fails for each (checked on f.txt and d.txt, with texts they hold)
- `DeepModifyInFiles` (line 5110): Does nothing today and answers 0 instead of replacing a text in the files of the listed names below. -- Changes nothing because DeepModifyInFile changes nothing
- `DeepModifyInFolder` (line 5135): Does nothing today and answers 0 instead of replacing a text in the files of the folders of that name below. -- Changes nothing: it reads a folder variable it never sets, so no file is found
- `DeepModifyInFolders` (line 5184): Does nothing today and answers 0 instead of replacing a text in the files of the listed folders below. -- Changes nothing because DeepModifyInFolder changes nothing
- `DeepModifyInRoot` (line 5208): Does nothing today and answers 0 instead of replacing a text in every file of the tree below. -- Changes nothing: the folders from DeepFolders are relative entries that the directory reader cannot open
- `VizDeepFindFiles` (line 5336): Raises error R24 today instead of drawing the whole tree with the matching files marked. -- Raises error R24 because GetFoldersContainingFileMatches does
- `ExpandThis` (line 5470): Raises error R24 today instead of marking one folder to be drawn open. -- Raises error R24 because it passes a variable cfolders that it never sets, instead of its own argument
- `GetPhysicalOrder` (line 6083): Raises error R24 today instead of listing a folder's entries as name and type records in disk order. -- Raises error R24 because a file entry reads a variable _aEntry_ that is never set
- `FormatStatsForFolder` (line 6297): Raises error R14 today instead of writing the statistics pattern for a child folder. -- Raises error R14 because it calls CountFilesIn, which exists nowhere

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

## stzKnowledgeGraph -- graph/stzKnowledgeGraph.ring (2)

- `ValidateOntology` (line 865): Returns 1 whatever the ontology holds; the check is not written yet. -- the body only returns 1, so no inconsistency is ever reported
- `Explain` (line 1000): Raises error R14 today instead of describing the knowledge graph in sections: structure, facts, entities, predicates, ontology and insights. -- it calls ApplyInference, which is defined nowhere, so the call always raises R14; stzGraph.Explain is shadowed by this version seen in the gallery: drawn through GraphCanvas a knowledge graph shows no predicate on its edges and no arrowheads; Dot() with graphviz draws each fact as an edge labelled with its predicate

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

## stzLocale -- i18n/stzLocale.ring (17)

- `ScriptNumber` (line 1059): Returns the library's number for the locale's script, as text, but answers 0 (common) for most locales today. -- answers 0, the common script, for a locale written without a script, so fr-FR, en-US, ar-EG, ja-JP and ru-RU all give common instead of Latin, Arabic or Cyrillic; a script written in the code (ar_Arab_TN gives 1) or a locale built from a country name (France gives Latin) is honoured
- `ScriptName` (line 1095): Returns the English name of the locale's script in lowercase, but answers common for most locales today. -- answers common for a locale written without a script, so fr-FR and ar-EG give common instead of latin and arabic; ar_Arab_TN gives arabic
- `ScriptAbbreviation` (line 1108): Returns the four-letter script code, such as Latn or Arab, but answers Zyyy (common) for most locales today. -- answers Zyyy for a locale written without a script, so fr-FR gives Zyyy instead of Latn
- `ToTimeAsString` (line 1335): Raises error R20 today instead of returning the time text written in a chosen format. -- raises R20 (extra number of parameters) on every call: the body calls the stzTime ToString method with an argument it does not take
- `ToTimeAsLongString` (line 1358): Raises error R20 today instead of returning the time text in the long format. -- raises R20 because ToTimeAsString raises
- `ToTimeAsShortString` (line 1367): Raises error R20 today instead of returning the time text in the short format. -- raises R20 because ToTimeAsString raises
- `ToTimeAsNarrowString` (line 1376): Raises error R20 today instead of returning the time text in the narrow format. -- raises R20 because ToTimeAsString raises
- `StringLowercased` (line 1760): Returns the text with its ASCII capital letters turned to lowercase; accented and non-Latin capitals are not changed today. -- the locale has no effect and only A to Z change, so É stays É and Turkish I gives i; a number as argument stops the Ring process without a message, and a list answers empty text
- `StringUppercased` (line 1821): Returns the text with its ASCII small letters turned to capitals; accented and non-Latin letters are not changed today. -- the locale has no effect and only a to z change, so école gives éCOLE, straße gives STRAßE and Turkish i gives I; a number as argument stops the Ring process without a message
- `StringTitlecased` (line 1881): Raises error R14 today instead of returning the text in title case. -- raises R14 on every call: for English it goes through StringCapitalcased, which calls the missing method CharAtPositionQ, and for other Latin-script languages it calls the missing method Char
- `ToTitleCase` (line 1924): Raises error R14 today instead of returning the text in title case. -- raises R14 on every call, through StringTitlecased
- `StringIsTitlecased` (line 1933): Raises error R14 today instead of telling whether the text is already in title case. -- raises R14 on every call, through StringTitlecased
- `StringFoldcased` (line 1951): Returns nothing today, because its body is an unwritten TODO instead of case folding. -- the body is empty, so every call answers empty text; the ToFoldcase form answers the same
- `CharFoldcased` (line 1963): Returns nothing today instead of the case-folded character, because StringFoldcased is not written. -- answers empty text for every character, because StringFoldcased does
- `CharIsFoldcased` (line 1988): Returns FALSE today for any character, because StringFoldcased answers empty text. -- answers FALSE for every character, because StringFoldcased is not written
- `StringCapitalcased` (line 2006): Raises error R14 today instead of returning the text with the first letter of every word capitalised. -- raises R14 on every call: the body calls the missing method CharAtPositionQ on a stzString
- `StringIsCapitalised` (line 2056): Raises error R14 today instead of telling whether every word of the text starts with a capital. -- raises R14 on every call, through StringCapitalcased

## stzText -- linguistic/stzText.ring (1)

- `SummarizedAbstractively` (line 1316): Raises error R19 today when no generative model is loaded, instead of falling back to the extractive summary. -- Raises error R19 without a generative model (checked on three texts): the fallback calls Summary without its sentence count

## stzGrid -- list/stzGrid.ring (26)

- `MoveToNthNode` (line 540): Raises error R14 today instead of moving the current position n steps in the direction the grid faces. -- Raises R14 today for every direction: each branch calls a method that exists nowhere, such as MoveToNthNodeBackward, and the right branch has a doubled Move in its name
- `MoveToNthPosition` (line 572): Raises error R14 today instead of moving the current position n steps in the direction the grid faces. -- Raises R14 today for every direction: each branch calls a method that exists nowhere, such as MoveToNthNodeBackward, and the right branch has a doubled Move in its name
- `MoveToNthCell` (line 584): Raises error R14 today instead of moving the current position n steps in the direction the grid faces. -- Raises R14 today for every direction: each branch calls a method that exists nowhere, such as MoveToNthNodeBackward, and the right branch has a doubled Move in its name
- `MoveToPreviousNthNode` (line 680): Raises error R19 today instead of moving the current position n steps against the direction the grid faces. -- Raises R19 today on every call: it hands MoveToNode the whole [ column, row ] list that PreviousNthNode returns, where MoveToNode wants the column and the row as two arguments
- `MoveToNthPreviousNode` (line 692): Raises error R19 today instead of moving the current position n steps against the direction the grid faces. -- Raises R19 today on every call: it hands MoveToNode the whole [ column, row ] list that PreviousNthNode returns, where MoveToNode wants the column and the row as two arguments
- `MoveToNthPrevious` (line 704): Raises error R19 today instead of moving the current position n steps against the direction the grid faces. -- Raises R19 today on every call: it hands MoveToNode the whole [ column, row ] list that PreviousNthNode returns, where MoveToNode wants the column and the row as two arguments
- `MoveToPreviousNth` (line 716): Raises error R19 today instead of moving the current position n steps against the direction the grid faces. -- Raises R19 today on every call: it hands MoveToNode the whole [ column, row ] list that PreviousNthNode returns, where MoveToNode wants the column and the row as two arguments
- `MoveToPreviousNthPosition` (line 729): Raises error R19 today instead of moving the current position n steps against the direction the grid faces. -- Raises R19 today on every call: it hands MoveToNode the whole [ column, row ] list that PreviousNthNode returns, where MoveToNode wants the column and the row as two arguments
- `MoveToNthPreviousPosition` (line 741): Raises error R19 today instead of moving the current position n steps against the direction the grid faces. -- Raises R19 today on every call: it hands MoveToNode the whole [ column, row ] list that PreviousNthNode returns, where MoveToNode wants the column and the row as two arguments
- `MoveToPreviousNthCell` (line 754): Raises error R19 today instead of moving the current position n steps against the direction the grid faces. -- Raises R19 today on every call: it hands MoveToNode the whole [ column, row ] list that PreviousNthNode returns, where MoveToNode wants the column and the row as two arguments
- `MoveToNthPreviousCell` (line 766): Raises error R19 today instead of moving the current position n steps against the direction the grid faces. -- Raises R19 today on every call: it hands MoveToNode the whole [ column, row ] list that PreviousNthNode returns, where MoveToNode wants the column and the row as two arguments
- `MoveNRight` (line 1119): Raises error R24 today instead of moving n cells right. -- Raises R24, Using uninitialized variable n, on every call: the method takes no argument but passes n on; MoveRightN takes the number of steps
- `MoveNNodesRight` (line 1128): Raises error R24 today instead of moving n cells right. -- Raises R24, Using uninitialized variable n, on every call: the method takes no argument but passes n on; MoveRightN takes the number of steps
- `MoveNCellsRight` (line 1147): Raises error R24 today instead of moving n cells right. -- Raises R24, Using uninitialized variable n, on every call: the method takes no argument but passes n on; MoveRightN takes the number of steps
- `MoveNLeft` (line 1192): Raises error R24 today instead of moving n cells left. -- Raises R24, Using uninitialized variable n, on every call: the method takes no argument but passes n on; MoveLeftN takes the number of steps
- `MoveNNodesLeft` (line 1201): Raises error R24 today instead of moving n cells left. -- Raises R24, Using uninitialized variable n, on every call: the method takes no argument but passes n on; MoveLeftN takes the number of steps
- `MoveNCellsLeft` (line 1218): Raises error R24 today instead of moving n cells left. -- Raises R24, Using uninitialized variable n, on every call: the method takes no argument but passes n on; MoveLeftN takes the number of steps
- `MoveNUp` (line 1263): Raises error R24 today instead of moving n cells up. -- Raises R24, Using uninitialized variable n, on every call: the method takes no argument but passes n on; MoveUpN takes the number of steps
- `MoveNNodesUp` (line 1272): Raises error R24 today instead of moving n cells up. -- Raises R24, Using uninitialized variable n, on every call: the method takes no argument but passes n on; MoveUpN takes the number of steps
- `MoveNCellsUp` (line 1289): Raises error R24 today instead of moving n cells up. -- Raises R24, Using uninitialized variable n, on every call: the method takes no argument but passes n on; MoveUpN takes the number of steps
- `MoveNDown` (line 1334): Raises error R24 today instead of moving n cells down. -- Raises R24, Using uninitialized variable n, on every call: the method takes no argument but passes n on; MoveDownN takes the number of steps
- `MoveNNodesDown` (line 1343): Raises error R24 today instead of moving n cells down. -- Raises R24, Using uninitialized variable n, on every call: the method takes no argument but passes n on; MoveDownN takes the number of steps
- `MoveNCellsDown` (line 1360): Raises error R24 today instead of moving n cells down. -- Raises R24, Using uninitialized variable n, on every call: the method takes no argument but passes n on; MoveDownN takes the number of steps
- `ShowAdjacent` (line 1466): Raises error R14 today instead of printing the grid with the neighbours marked. -- Raises R14 today: it calls PaintNeighbors, a method that exists nowhere
- `AreObstacles` (line 1987): Raises error R20 today instead of telling whether every cell of a list is an obstacle. -- Raises R20 today on every call: the parameter check is called with an argument it does not take; behind it, the loop would test the whole list instead of each pair
- `Maze` (line 3862): Raises error R19 today instead of building a random maze. -- Raises R19 today on every call: it calls RandomMaze without the density RandomMaze requires

## stzHashList -- list/stzHashList.ring (56)

- `KeysForValue` (line 732): Raises error R14 today instead of returning the keys of every pair that holds the given value. -- on text values the call raises error R14 today; on list values it answers an empty list. Use KeysByValue
- `FirstPair` (line 1053): Raises an error today instead of returning the first [ key, value ] pair. -- the call raises error R24 today, because it reads _n_, which it never sets; NthPair works
- `LastPair` (line 1071): Raises an error today instead of returning the last [ key, value ] pair. -- the call raises error R24 today, because it reads _n_, which it never sets; NthPair works
- `KeyInPair` (line 1084): Raises an error today instead of returning the key part of a [ key, value ] pair. -- the call raises a parameter-type error today even for a real pair
- `ValueInPair` (line 1109): Raises an error today instead of returning the value part of a [ key, value ] pair. -- the call raises a parameter-type error today even for a real pair
- `ValueInNthPairQ` (line 1155): Raises an error today instead of returning the value of the nth pair as a Q object. -- the call raises error R14 today, because it calls a method that is not defined
- `UpdateKeys` (line 1532): Raises an error today instead of replacing the keys by the given ones, in order. -- the call raises error R14 today, because it calls ItemsAreAllStrings, which is not defined
- `UpdateNthOccurrenceOfValue` (line 1580): Raises an error today instead of replacing the nth occurrence of a value. -- the call raises error R19 today (the definition takes one parameter and the body needs more)
- `UpdateFirstOccurrenceOfValue` (line 1617): Raises an error today instead of replacing the first occurrence of a value. -- the call raises error R20 today (its definition and its call disagree on the parameters)
- `UpdateFirstValue` (line 1627): Raises an error today instead of replacing the first occurrence of a value. -- the call raises error R20 today (its definition and its call disagree on the parameters)
- `UpdateLastValue` (line 1638): Raises an error today instead of replacing the last occurrence of a value. -- the call raises error R20 today (its definition and its call disagree on the parameters)
- `UpdateAllPairsWith` (line 1649): Replaces every pair by the given [ key, value ] pair, in place. -- the call raises a parameter-type error today
- `ReverseKeysAndValues` (line 1679): Raises a parameter-type error today instead of swapping keys and values, in place. -- the call raises a parameter-type error today for every hash list; ValuesAndKeys returns the pairs turned round
- `InsertBefore` (line 1792): Inserts a pair before position n, in place. -- the call raises an error today, because it reads a property named HashList that the object does not have; Add appends a pair and works
- `InsertAfter` (line 1811): Raises an error today instead of inserting a pair after position n. -- the call raises an error today, because it reads a property named HashList that the object does not have; Add appends a pair and works
- `RemovePair` (line 1866): Raises an error today instead of removing the given [ key, value ] pair. -- the call raises error R14 today, because it calls a RemoveQ method that is not defined
- `RemovePairsByKeys` (line 1912): Raises an error today instead of removing the pairs that hold any of the given keys. -- the call raises error R3 today, because it calls @IsListOfStrings, which is not defined
- `ReplaceValue` (line 2040): Raises an error today instead of replacing the first occurrence of the given value. -- the call raises an error today (it expects a position where the value should be); UpdateValue replaces a value
- `ReplacePair` (line 2168): Raises an error today instead of replacing the given pair by a new one. -- the call raises error R14 today, because it calls ReplaceNthPair, which is not defined
- `ReplacePairByKey` (line 2185): Raises an error today instead of replacing the pair that holds the given key. -- the call raises error R14 today, because it calls ReplaceNthPair, which is not defined
- `ReplacePairsW` (line 2199): Raises an error today instead of replacing the pairs that meet a condition. -- the feature is reserved and not implemented in this release
- `ContainsTheseValues` (line 2429): Raises an error today instead of telling whether every given value occurs. -- the call raises error R24 today, because it reads pValue, which it never sets; ContainsValues works
- `FindLastOccurrenceOfValue` (line 2662): Returns the position of the last pair that holds the given value. -- it asks for the nth occurrence with n = the number of pairs, so it raises an error (index out of range) unless every pair holds the value; FindValue gives the positions to take the last of
- `KeysByValues` (line 2845): Raises an error today instead of returning the keys of the pairs holding any of the given values. -- the call raises error R14 today, because it calls WithoutDuplicates, which this class does not define
- `FindNumber` (line 3091): Raises an error today instead of returning the positions of the pairs holding the number. -- the call raises a parameter-type error today even for an argument of the type it asks for
- `NumberZ` (line 3114): Raises an error today instead of returning the number with the positions that hold it. -- the call raises a parameter-type error today even for an argument of the type it asks for
- `FindTheseNumbers` (line 3132): Raises an error today instead of returning the positions of the pairs holding any of the numbers. -- the call raises a parameter-type error today even for an argument of the type it asks for
- `TheseNumbersZ` (line 3163): Raises an error today instead of returning each number with the positions that hold it. -- the call raises a parameter-type error today even for an argument of the type it asks for
- `FindString` (line 3238): Raises an error today instead of returning the positions of the pairs holding the text. -- the call raises a parameter-type error today even for an argument of the type it asks for
- `StringZ` (line 3261): Raises an error today instead of returning the text with the positions that hold it. -- the call raises a parameter-type error today even for an argument of the type it asks for
- `FindTheseStrings` (line 3279): Raises an error today instead of returning the positions of the pairs holding any of the texts. -- the call raises a parameter-type error today even for an argument of the type it asks for
- `TheseStringsZ` (line 3310): Raises an error today instead of returning each text with the positions that hold it. -- the call raises a parameter-type error today even for an argument of the type it asks for
- `FindLastItem` (line 3991): Raises an error today instead of returning the position of the last pair whose list value holds the item. -- the call raises error R14 today, because it calls NumberOfOccurreceOfItemInList, a misspelled name that is not defined
- `FindFirstKeyByItemInList` (line 4065): Raises an error today instead of returning a key whose list value holds the item. -- the call raises error R14 today, because it calls ContainsItemInList, which is not defined
- `FindLastKeyByItemInList` (line 4100): Raises an error today instead of returning a key whose list value holds the item. -- the call raises error R14 today, because it calls ContainsItemInList, which is not defined
- `KeyByItemInList` (line 4119): Raises an error today instead of returning a key whose list value holds the item. -- the call raises error R14 today, because it calls ContainsItemInList, which is not defined
- `KeysByItemInList` (line 4134): Raises an error today instead of returning the keys whose list value holds the item. -- the call raises a parameter-type error today when the item occurs; FindKeysByItem answers where it occurs
- `KeysByItem` (line 4153): Raises an error today instead of returning the keys whose list value holds the item. -- the call overflows the stack (R4) today; FindKeysByItem answers where the item occurs
- `Classify` (line 4216): Groups the keys by the value they hold, one [ class, keys ] pair per distinct value. -- the call raises error R14 today, because it uses IsStrictlyEqualTo, which no class defines; Classes and NumberOfClasses work
- `Klass` (line 4429): Raises an error today instead of returning the keys that belong to the given class. -- on text values the call raises error R14 today (it calls IsStrictlyEqualTo, which is not defined); it answers when the values are lists
- `NumberOfValuesInClass` (line 4508): Raises an error today instead of returning how many values belong to the given class. -- on text values the call raises error R14 today (it calls IsStrictlyEqualTo, which is not defined); it answers when the values are lists
- `ClassesSizes` (line 4577): Raises an error today instead of returning how many pairs each class holds. -- on text values the call raises error R14 today (it calls IsStrictlyEqualTo, which is not defined); on list values the figures it works from come out wrong, so the answer is not to be trusted
- `KlassFreq` (line 4745): Raises an error today instead of returning the share of the pairs that belong to the given class. -- on text values the call raises error R14 today (it calls IsStrictlyEqualTo, which is not defined); it answers when the values are lists
- `ClassesFrequencies` (line 4834): Raises an error today instead of returning the share of the pairs in each class. -- on text values the call raises error R14 today (it calls IsStrictlyEqualTo, which is not defined); on list values the figures it works from come out wrong, so the answer is not to be trusted
- `NStrongestClasses` (line 5031): Raises an error today instead of returning the n classes that hold the most pairs. -- on text values the call raises error R14 today (it calls IsStrictlyEqualTo, which is not defined); on list values the figures it works from come out wrong, so the answer is not to be trusted
- `StrongestClass` (line 5129): Raises an error today instead of returning the class that holds the most pairs. -- on text values the call raises error R14 today (it calls IsStrictlyEqualTo, which is not defined); on list values the figures it works from come out wrong, so the answer is not to be trusted
- `Top3Classes` (line 5182): Raises an error today instead of returning the three classes that hold the most pairs. -- on text values the call raises error R14 today (it calls IsStrictlyEqualTo, which is not defined); on list values the figures it works from come out wrong, so the answer is not to be trusted
- `Strongest3Classes` (line 5196): Raises an error today instead of returning the three classes that hold the most pairs. -- the call raises error R24 today, because it reads _n_, which it never sets; Top3Classes works
- `Strongest3ClassesAndTheirFrequencies` (line 5231): Raises an error today instead of returning the three strongest classes with their shares. -- the call raises error R24 today, because it reads _n_, which it never sets
- `NWeakestClasses` (line 5251): Raises an error today instead of returning the n classes that hold the fewest pairs. -- on text values the call raises error R14 today (it calls IsStrictlyEqualTo, which is not defined); on list values the figures it works from come out wrong, so the answer is not to be trusted
- `WeakestClass` (line 5346): Raises an error today instead of returning the class that holds the fewest pairs. -- on text values the call raises error R14 today (it calls IsStrictlyEqualTo, which is not defined); on list values the figures it works from come out wrong, so the answer is not to be trusted
- `Bottom3Classes` (line 5393): Raises an error today instead of returning the three classes that hold the fewest pairs. -- on text values the call raises error R14 today (it calls IsStrictlyEqualTo, which is not defined); on list values the figures it works from come out wrong, so the answer is not to be trusted
- `Weakest3Classes` (line 5407): Raises an error today instead of returning the three classes that hold the fewest pairs. -- the call raises error R24 today, because it reads _n_, which it never sets; Bottom3Classes works
- `Weakest3ClassesAndTheirFrequencies` (line 5438): Raises an error today instead of returning the three weakest classes with their shares. -- the call raises error R24 today, because it reads _n_, which it never sets
- `KlassInList` (line 5695): Raises an error today instead of returning the keys whose list value holds the class. -- the call raises error R14 today, because it calls KeysForItemInList, which is not defined
- `KalssInListQ` (line 5707): Raises an error today: a misspelling of KlassInListQ that asks for a return type the class does not support. -- the call raises an unsupported-return-type error today

## stzList -- list/stzList.ring (22)

- `SplitXT` (line 8765): Raises error R14 today instead of splitting the list with the given options. -- the call raises error R14 today, because it calls a method that is not defined
- `SplittedXT` (line 8777): Raises error R14 today instead of returning the parts split with the given options. -- the call raises error R14 today, because it calls a method that is not defined
- `SplitAsSectionsXT` (line 8789): Raises error R14 today instead of returning the sections of the parts. -- the call raises error R14 today, because it calls a method that is not defined
- `SplittedAsSectionsXT` (line 8801): Raises error R14 today instead of returning the sections of the parts. -- the call raises error R14 today, because it calls a method that is not defined
- `SplitCS` (line 8813): Leaves the list unchanged today instead of splitting it at an item or position. -- the call computes the parts on a copy and drops them; use the Splitted forms
- `SplitAtPosition` (line 8873): Leaves the list unchanged today instead of splitting it at a position. -- the call computes the parts on a copy and drops them; SplittedAtPosition returns them
- `SplitBeforePosition` (line 8933): Leaves the list unchanged today instead of splitting it before a position. -- the call computes the parts on a copy and drops them; SplittedBeforePosition returns them
- `SplitBefore` (line 8959): Splits the list before each occurrence of the item, but a known defect makes the call do nothing today. -- the call changes nothing and returns nothing, because it splits a copy of the list; SplitAt and SplitBeforePositions work
- `SplitAfterPosition` (line 8970): Leaves the list unchanged today instead of splitting it after a position. -- the call computes the parts on a copy and drops them; SplittedAfterPosition returns them
- `SplitAfter` (line 8996): Splits the list after each occurrence of the item, but a known defect makes the call do nothing today. -- the call changes nothing and returns nothing, because it splits a copy of the list; SplitAt and SplitBeforePositions work
- `SplitToNParts` (line 9008): Leaves the list unchanged today instead of splitting it into n parts. -- the call computes the parts on a copy and drops them; SplittedToNParts returns them
- `SplitAtPacer` (line 9065): Leaves the list unchanged today instead of splitting it every few items. -- the call computes the parts on a copy and drops them; SplittedAtPacer returns them
- `RepeatedLeadingItem` (line 9134): Leaves nothing today instead of returning the item that repeats at the start. -- the call returns an empty string whatever the list holds; RepeatedLeadingItems returns the run
- `RepeatedTrailingItem` (line 9181): Raises error R14 today instead of returning the item that repeats at the end. -- the call raises error R14 today, because it calls a method that is not defined
- `NumberOfRepeatedTrailingItems` (line 9195): Raises error R14 today instead of returning how many items before the last equal it. -- the call raises error R14 today, because it calls a method that is not defined
- `ExtractFirstOccurrence` (line 9335): Raises error R14 today instead of removing the first occurrence of the item and returning it. -- the call raises error R14 today, because it calls FirstOccurrenceCS, which is not defined; ExtractFirst works
- `ExtractLastOccurrence` (line 9351): Raises error R14 today instead of removing the last occurrence of the item and returning it. -- the call raises error R14 today, because it calls LastOccurrenceCS, which is not defined; ExtractLast works
- `ExtractDuplicates` (line 9367): Removes the repeats of duplicated items, in place, but answers an empty list instead of the removed items. -- the repeats are removed from the list but the call returns [ ] instead of them
- `AntiSection` (line 10455): Raises error R19 today instead of returning the items outside one section. -- the call raises error R19 today, because it passes too few arguments to the code behind it
- `RangesAndAntiRanges` (line 10605): Raises error R14 today instead of returning the ranges and the runs outside them. -- the call raises error R14 today, because it calls SectionsAndAntiSections, which is not defined
- `ItemsAppearingLessThanNTimes` (line 10783): Returns the distinct items that occur fewer than n times; today each comes back as text. -- numbers come back as text, such as "3" for 3
- `Insert` (line 11365): Inserts the item before a position, in place, but one place too early today. -- Insert(item, n) puts the item at position n-1, and raises an error for n = 1 or past the end; InsertBefore(n, item) puts it at n

## stzListOfLists -- list/stzListOfLists.ring (69)

- `ListAt` (line 541): Raises error R19 today instead of returning the list at a position. -- it calls NthList without passing the position, so the call raises error R19; ListAtPosition works
- `FindInLists` (line 614): Returns [ list, position ] pairs for every occurrence of a text item inside the lists; the match is case-sensitive. -- a number item, or a list that holds numbers, makes the engine search raise an error
- `FindItemsInLists` (line 680): Raises error R24 today instead of returning where several items occur inside the lists. -- the body passes a variable called pItem, which is never set, so the call raises error R24
- `FindSubListInListsCS` (line 697): Raises an error on purpose today: the search for a sublist inside the lists is not written yet. -- the body only raises "Function non implemented yet!"; FindSubList does the job
- `FindSubListInList` (line 707): Raises error R14 today instead of returning where a sublist occurs in the lists. -- it calls FindSubListInListCS, which is defined nowhere; FindSubList does the job
- `PositionsW` (line 723): Raises error R24 today instead of returning the positions of the lists that meet a condition. -- the body collects into a variable named _aResult_ while the evaluated code writes to aResult, which is never set, so the call raises error R24
- `JustifyEachListWith` (line 1994): Raises error R24 or R20 today instead of padding every shorter list with a given item. -- the def line declares no parameter yet the body reads pItem, so a call without an argument raises error R24 and a call with one raises error R20; JustifyWith works
- `ExtendToByRepeatingItems` (line 2250): Raises error R14 today instead of padding each list to n items by repeating its own items. -- it asks a plain list for ExtendedToByRepeatingItems, a method that list does not have, so the call raises error R14
- `ExtendToWithItemsRepeated` (line 2277): Raises error R14 today instead of padding each list to n items by repeating its own items. -- it asks a plain list for ExtendedToByRepeatingItems, a method that list does not have, so the call raises error R14
- `ExtendedToByRepeatingItems` (line 2291): Raises error R14 today instead of returning a copy padded to n items by repeating each list's own items. -- it asks a plain list for ExtendedToByRepeatingItems, a method that list does not have, so the call raises error R14
- `ExtendedToWithItemsRepeated` (line 2303): Raises error R14 today instead of returning a copy padded to n items by repeating each list's own items. -- it asks a plain list for ExtendedToByRepeatingItems, a method that list does not have, so the call raises error R14
- `ExtendByRepeatingItems` (line 2377): Raises error R14 today instead of padding every list to the longest size by repeating its own items. -- it ends in ExtendedToByRepeatingItems, a method a plain list does not have, so the call raises error R14
- `ExtendWithItemsRepeated` (line 2394): Raises error R14 today instead of padding every list to the longest size by repeating its own items. -- it ends in ExtendedToByRepeatingItems, a method a plain list does not have, so the call raises error R14
- `ExtendByItemsRepeated` (line 2406): Raises error R14 today instead of padding every list to the longest size by repeating its own items. -- it ends in ExtendedToByRepeatingItems, a method a plain list does not have, so the call raises error R14
- `ExtendedByRepeatingItems` (line 2419): Raises error R14 today instead of returning a copy padded to the longest size by repeating each list's own items. -- it ends in ExtendedToByRepeatingItems, a method a plain list does not have, so the call raises error R14
- `ExtendToWithItemsIn` (line 2445): Raises error R14 today instead of padding each list to n items with the given items in turn. -- it asks a plain list for ExtendedToWithItemsIn, a method that list does not have, so the call raises error R14
- `ExtendToUsingItemsIn` (line 2470): Raises error R14 today instead of padding each list to n items with the given items in turn. -- it asks a plain list for ExtendedToWithItemsIn, a method that list does not have, so the call raises error R14
- `ExtendedToWithItemsIn` (line 2484): Raises error R14 today instead of returning a copy padded to n items with the given items in turn. -- it asks a plain list for ExtendedToWithItemsIn, a method that list does not have, so the call raises error R14
- `ExtendWithItemsIn` (line 2502): Raises error R14 today instead of padding every list to the longest size with the given items in turn. -- it ends in ExtendedToWithItemsIn, a method a plain list does not have, so the call raises error R14
- `ExtendUsingItemsIn` (line 2516): Raises error R14 today instead of padding every list to the longest size with the given items in turn. -- it ends in ExtendedToWithItemsIn, a method a plain list does not have, so the call raises error R14
- `ExtendedWithItemsIn` (line 2529): Raises error R14 today instead of returning a copy padded to the longest size with the given items in turn. -- it ends in ExtendedToWithItemsIn, a method a plain list does not have, so the call raises error R14
- `AdjustedToSmallest` (line 2610): Returns nothing today instead of a copy with every list cut to the size of the shortest. -- the body calls Shrinked but has no return, so the answer is lost; Shrinked works
- `AdjustedToSmallestSize` (line 2619): Returns nothing today instead of a copy with every list cut to the size of the shortest. -- the body calls Shrinked but has no return, so the answer is lost; Shrinked works
- `AdjustedToSmallestList` (line 2628): Returns nothing today instead of a copy with every list cut to the size of the shortest. -- the body calls Shrinked but has no return, so the answer is lost; Shrinked works
- `AdjustedToMin` (line 2637): Returns nothing today instead of a copy with every list cut to the size of the shortest. -- the body calls Shrinked but has no return, so the answer is lost; Shrinked works
- `AdjustedToMinSize` (line 2646): Returns nothing today instead of a copy with every list cut to the size of the shortest. -- the body calls Shrinked but has no return, so the answer is lost; Shrinked works
- `AdjustedToMinList` (line 2655): Returns nothing today instead of a copy with every list cut to the size of the shortest. -- the body calls Shrinked but has no return, so the answer is lost; Shrinked works
- `ShrinkToWith` (line 2737): Cuts every list longer than n down to its first n items, in place, and never uses the given item. -- the padding loop never runs, and when n is greater than the longest list every list is dropped and the content becomes empty
- `ShrinkToUsing` (line 2807): Cuts every list longer than n down to its first n items, in place, and never uses the given item. -- the padding loop never runs, and when n is greater than the longest list every list is dropped and the content becomes empty
- `ShrinkedToWith` (line 2828): Returns a copy with every list cut to its first n items; the given item is never used. -- when n is greater than the longest list every list is dropped and the answer is empty
- `ShrinkedToUsing` (line 2841): Returns a copy with every list cut to its first n items; the given item is never used. -- when n is greater than the longest list every list is dropped and the answer is empty
- `ShrinkedToBy` (line 2852): Returns a copy with every list cut to its first n items; the given item is never used. -- when n is greater than the longest list every list is dropped and the answer is empty
- `EntryByPosition` (line 3426): Raises error R14 today instead of returning the index entry of an item by position. -- it calls IndexOn, which is defined nowhere, so the call raises error R14
- `EntryByNumberOfOccurrence` (line 3436): Raises error R14 today instead of returning the index entry of an item by its number of occurrences. -- it calls IndexOn, which is defined nowhere, so the call raises error R14
- `Entry` (line 3450): Raises error R14 today instead of returning the index entry of an item, by position or by number of occurrences. -- it calls IndexOn, which is defined nowhere, so the call raises error R14 for either mode; any other pcBy returns empty text
- `NumberOfOccurrenceOfEntry` (line 3469): Raises error R14 today instead of returning how many times an item occurs. -- it calls IndexOn, which is defined nowhere, so the call raises error R14
- `HowManyEntry` (line 3482): Raises error R14 today instead of returning how many times an item occurs. -- it calls IndexOn, which is defined nowhere, so the call raises error R14
- `HowManyEntries` (line 3492): Raises error R14 today instead of returning how many times an item occurs. -- it calls IndexOn, which is defined nowhere, so the call raises error R14
- `NthOccurrenceOfEntry` (line 3503): Raises error R14 today instead of returning where an item occurs for the nth time. -- it calls IndexOn, which is defined nowhere, so the call raises error R14
- `FirstOccurrenceOfEntry` (line 3516): Raises error R14 today instead of returning where an item first occurs. -- it calls IndexOn, which is defined nowhere, so the call raises error R14
- `LastOccurrenceOfEntry` (line 3526): Raises error R14 today instead of returning where an item last occurs. -- it calls IndexOn, which is defined nowhere, so the call raises error R14
- `Merge` (line 3657): Raises an error on purpose: the lists cannot be merged in place, use the passive form instead. -- the body only raises "Can't merge the list of lists! ... use Merged()"
- `Flatten` (line 3681): Raises an error on purpose: the lists cannot be flattened in place, use the passive form instead. -- the body only raises "Can't flatten the list of lists! ... use Flattened()"
- `SortDownNthList` (line 4483): Raises error R13 today instead of sorting the list at position n in descending order, in place. -- the body chains .Reversed() directly onto new stzList(...), which Ring answers with error R13
- `SortNthListInDescending` (line 4501): Raises error R13 today instead of sorting the list at position n in descending order, in place. -- it calls SortDownNthList, which raises error R13
- `NthListSortedDown` (line 4513): Raises error R13 today instead of returning a copy with the list at position n sorted descending. -- it calls SortDownNthList, which raises error R13
- `Classify` (line 5134): Raises error R14 today instead of grouping the other items under the distinct first items. -- the body asks the first column for StringifyNamedObjectsQ, which does not exist, so the call raises error R14
- `ClassifyOn` (line 5235): Raises error R14 today instead of grouping the items under the distinct items of one column. -- it moves the column first and then calls Classify, which raises error R14
- `ClassifyBy` (line 5294): Raises error R14 today instead of grouping the lists by the value of an expression on the first item. -- the call ends in Classify, which raises error R14
- `ClassifyOnBy` (line 5334): Raises error R14 today instead of grouping the lists by the value of an expression on one column. -- the call ends in Classify, which raises error R14
- `RemoveCol` (line 5679): Removes the item at position n from every list that has one, in place; nothing happens when n exceeds the NUMBER OF LISTS. -- the early check compares n with the number of lists instead of the number of columns, so with 2 lists of 3 items RemoveCol(3) does nothing
- `RemoveNthCol` (line 5726): Removes the item at position n from every list that has one, in place; nothing happens when n exceeds the NUMBER OF LISTS. -- the early check compares n with the number of lists instead of the number of columns
- `RemoveColumn` (line 5739): Removes the item at position n from every list that has one, in place; nothing happens when n exceeds the NUMBER OF LISTS. -- the early check compares n with the number of lists instead of the number of columns
- `RemoveNthColumn` (line 5752): Removes the item at position n from every list that has one, in place; nothing happens when n exceeds the NUMBER OF LISTS. -- the early check compares n with the number of lists instead of the number of columns
- `RemoveNthItems` (line 5765): Removes the item at position n from every list that has one, in place; nothing happens when n exceeds the NUMBER OF LISTS. -- the early check compares n with the number of lists instead of the number of columns
- `ColRemoved` (line 5779): Returns a copy without the column at position n; the object is unchanged, but the same early check applies. -- it calls RemoveCol, so n greater than the number of lists removes nothing
- `RemoveCols` (line 5810): Raises error R14 today instead of removing several columns at once, in place. -- the argument check calls IsAtOrAtPositionsNamedParams, which is defined nowhere, so the call raises error R14
- `RemoveTheseCols` (line 5856): Raises error R14 today instead of removing several columns at once, in place. -- it calls RemoveCols, which raises error R14
- `RemoveTheseColqQ` (line 5866): Raises error R14 today instead of removing several columns and returning the object. -- it calls RemoveColsQ, which raises error R14
- `RemoveManyCols` (line 5875): Raises error R14 today instead of removing several columns at once, in place. -- it calls RemoveCols, which raises error R14
- `RemoveManyColqQ` (line 5885): Raises error R14 today instead of removing several columns and returning the object. -- it calls RemoveColsQ, which raises error R14
- `RemoveColumns` (line 5894): Raises error R14 today instead of removing several columns at once, in place. -- it calls RemoveCols, which raises error R14
- `RemoveTheseColumns` (line 5907): Raises error R14 today instead of removing several columns at once, in place. -- it calls RemoveCols, which raises error R14
- `RemoveManyColumns` (line 5919): Raises error R14 today instead of removing several columns at once, in place. -- it calls RemoveCols, which raises error R14
- `ColsRemoved` (line 5932): Raises error R14 today instead of returning a copy without several columns. -- it calls RemoveCols, which raises error R14
- `ToListInStringInShortForm` (line 6126): Raises error R21 today instead of returning the lists written as one short text. -- it concatenates the written lists with an operator that does not accept them, so the call raises error R21
- `ToStzListOfpairsOfNumbers` (line 6210): Raises error R11 today instead of returning the lists as a list of pairs of numbers. -- the class stzListOfPairsOfNumbers is defined nowhere, so the call raises error R11
- `SpeedUp` (line 6227): Raises error R21 today instead of dividing the first number by the second. -- the body treats the first two lists as numbers and divides them, which raises error R21
- `GainFactor` (line 6250): Raises error R21 today instead of dividing the second number by the first. -- the body treats the first two lists as numbers and divides them, which raises error R21

## stzListOfPairs -- list/stzListOfPairs.ring (11)

- `ReplacePair` (line 717): Raises error R20 today instead of replacing the pair at position n by the new pair. -- Raises R20 today on every call: the check IsPair(paNewPair) inside the class reaches the IsPair method inherited from stzList, which takes no argument, instead of the global IsPair function
- `PairReplaced` (line 734): Raises error R20 today instead of returning a copy of the pairs with the pair at position n replaced. -- Raises R20 today on every call, because it goes through ReplacePair, whose IsPair check reaches the IsPair method inherited from stzList
- `SortBy` (line 1052): Leaves the order of the pairs unchanged today instead of ordering them by the key expression, ascending. -- Leaves the order unchanged today for every key expression tried (@pair[2], len(@pair[1]), @pair): the key sort it forwards to, stzList.SortBy, orders text items by an expression but does not evaluate one on a list item
- `SortByInAscending` (line 1078): Leaves the order of the pairs unchanged today instead of ordering them by the key expression, ascending. -- Leaves the order unchanged today, because it forwards to SortBy, which does not order a list of lists by an expression
- `SortByUp` (line 1091): Leaves the order of the pairs unchanged today instead of ordering them by the key expression, ascending. -- Leaves the order unchanged today, because it forwards to SortBy, which does not order a list of lists by an expression
- `SortedBy` (line 1106): Returns the pairs in their present order today instead of a copy ordered by the key expression, ascending. -- Does not order today, whatever the expression: it sorts a copy through SortBy, which leaves a list of lists in place
- `SortedByInDescending` (line 1157): Returns a copy of the pairs with the two items of every pair swapped, today instead of ordered by the key expression, descending. -- Swaps the items of each pair today, because it goes through SortByInDescending, which ends with SwapItems
- `ExpandedIfPairsOfNumbers` (line 1174): Raises error R14 today instead of returning the number lists that the pairs of numbers expand to. -- Raises R14 today on every call: it calls ExpandedIfPairOfNumbers, a method that exists nowhere in the loaded library
- `IsListOfSections` (line 1378): Answers TRUE for any list of pairs today, instead of TRUE only when every pair is made of two numbers. -- Answers TRUE whatever the pairs hold, text included: the loop records a failing pair in a variable that is never read, so the result stays at its start value
- `AreAnagrams` (line 1515): Raises error R14 today instead of telling whether the two items are anagrams of each other. -- Raises R14 today on every call: it reads FirstValue and SecondValue, which this class does not define
- `ToStzSetOfSections` (line 2268): Raises an error today instead of returning the pairs as a stzSetOfSections. -- Raises "You must provide a list of sections" today for valid sections such as [ [ 1, 3 ], [ 5, 8 ] ]: the stzSetOfSections constructor refuses what stzListOfSections accepts

## stzMathFigure -- math/stzMathFigure.ring (2)

- `Pin` (line 384): Raises an error today instead of holding a shape where it is during later solves: no shape of any figure kind has a free position to hold. -- the diagram refuses it because the rules fix every shape (checked on 35 sample figures of all ten kinds); an unknown path raises too
- `DragTo` (line 407): Raises an error today instead of moving a shape to a position and re-solving around it: no shape has a free centre to move. -- refused for every shape of 9 figures tried across the kinds; use MoveNoteTo to move a note

## stzListOfNumbers -- number/stzListOfNumbers.ring (65)

- `Bottom3AndTheirPositions` (line 2279): Returns [ number, position ] pairs for the 3 smallest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Bottom3NumbersAndTheirPositions` (line 2289): Returns [ number, position ] pairs for the three smallest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Bottom5AndTheirPositions` (line 2299): Returns [ number, position ] pairs for the 5 smallest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Bottom5NumbersAndTheirPositions` (line 2309): Returns [ number, position ] pairs for the five smallest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Bottom7AndTheirPositions` (line 2319): Returns [ number, position ] pairs for the 7 smallest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Bottom7NumbersAndTheirPositions` (line 2329): Returns [ number, position ] pairs for the seven smallest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Bottom10AndTheirPositions` (line 2339): Returns [ number, position ] pairs for the 10 smallest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Bottom10NumbersAndTheirPositions` (line 2349): Returns [ number, position ] pairs for the ten smallest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Top3AndTheirPositions` (line 2850): Returns [ number, position ] pairs for the 3 largest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Top3NumbersAndTheirPositions` (line 2860): Returns [ number, position ] pairs for the three largest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Top5AndTheirPositions` (line 2870): Returns [ number, position ] pairs for the 5 largest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Top5NumbersAndTheirPositions` (line 2880): Returns [ number, position ] pairs for the five largest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Top7AndTheirPositions` (line 2890): Returns [ number, position ] pairs for the 7 largest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Top7NumbersAndTheirPositions` (line 2900): Returns [ number, position ] pairs for the seven largest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Top10AndTheirPositions` (line 2910): Returns [ number, position ] pairs for the 10 largest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Top10NumbersAndTheirPositions` (line 2920): Returns [ number, position ] pairs for the ten largest distinct numbers, right only in an ascending list. -- the numbers and the positions come from two separately ordered lists and are paired index by index, so a pair names the number's own position only when the list is already ascending and has no repeats
- `Closest` (line 3326): Raises error R19 today instead of returning the number closest to n. -- it calls Nearest without passing n, so the call raises error R19; ClosestTo works
- `Neighbors` (line 3479): Returns the distinct numbers just below and just above n; one number when n sits at an end. -- for an absent n that is greater than the COUNT of numbers, it answers only the largest number instead of the pair around n (n = 8 in [ 4, 7, 10, 3, 6, 9 ] answers [ 10 ])
- `Nighbors` (line 3625): Returns the distinct numbers just below and just above n; one number when n sits at an end. -- for an absent n that is greater than the COUNT of numbers, it answers only the largest number instead of the pair around n
- `NearestNighbors` (line 3636): Returns the distinct numbers just below and just above n; one number when n sits at an end. -- for an absent n that is greater than the COUNT of numbers, it answers only the largest number instead of the pair around n
- `NighborsOf` (line 3647): Returns the distinct numbers just below and just above n; one number when n sits at an end. -- for an absent n that is greater than the COUNT of numbers, it answers only the largest number instead of the pair around n
- `NearestNighborsOf` (line 3658): Returns the distinct numbers just below and just above n; one number when n sits at an end. -- for an absent n that is greater than the COUNT of numbers, it answers only the largest number instead of the pair around n
- `NighborsTo` (line 3669): Returns the distinct numbers just below and just above n; one number when n sits at an end. -- for an absent n that is greater than the COUNT of numbers, it answers only the largest number instead of the pair around n
- `NearestNighborsTo` (line 3680): Returns the distinct numbers just below and just above n; one number when n sits at an end. -- for an absent n that is greater than the COUNT of numbers, it answers only the largest number instead of the pair around n
- `Walker` (line 4042): Raises error R11 today instead of returning a walker that reproduces the list. -- the class stzWalker is not defined anywhere, so the call raises error R11
- `Absolute` (line 4205): Raises error R24 today instead of replacing every negative number by its absolute value. -- a stray * after This.Content() joins the next line to it, so the local list and its length are never set
- `Absoluted` (line 4224): Raises error R24 today instead of returning a copy with every number made positive. -- it calls Absolute, which raises error R24
- `Negate` (line 4236): Leaves the list unchanged today instead of turning every positive number negative. -- it edits a local copy of the numbers and never stores it back
- `Negated` (line 4255): Returns the numbers unchanged today instead of a copy with every positive number made negative. -- it copies the list and calls Negate, which changes nothing
- `MeanByCoefficient` (line 4355): Raises error R11 today instead of returning the mean weighted by the given coefficients. -- it builds objects of a class that does not exist (steListOfNumbers)
- `ContainsADividableNumberBy` (line 4386): TRUE if the product of all the numbers is divisible by n, which is not the same as one number being divisible. -- it tests the product of the numbers, not each number, and raises an error when that product is negative
- `DividableNumbersBy` (line 4405): Returns the even numbers whatever n is, instead of the numbers divisible by n. -- the body tests number % 2 and never reads n
- `Cumulate` (line 4534): Turns the numbers into running sums, in place, but the second number is never added to the first. -- the loop starts at the third number, so [ 1, 2, 3, 4, 5 ] becomes [ 1, 2, 5, 9, 14 ] instead of [ 1, 3, 6, 10, 15 ]
- `Cumulated` (line 4573): Raises error R24 today instead of returning the running sums of the numbers. -- it calls the chaining form of Cumulate, which reads a return-type variable that is never set
- `OnlyUnicodes` (line 4586): Raises error R3 today instead of returning the numbers that are Unicode code points. -- it calls IsUnicodeNumber, which is defined nowhere
- `MultiplyEachWithW` (line 5400): Multiplies by n the numbers whose position meets the condition and drops the others, in place. -- the numbers that fail the condition are removed from the list, and a condition that does not mention @i is refused
- `EachMultipliedWithW` (line 5476): Raises error R19 today instead of returning a copy multiplied by n where the condition holds. -- it takes no condition and calls the chaining form of MultiplyEachWithW with one argument, so the call raises error R19
- `DivideEachWithW` (line 5499): Divides by n the numbers whose position meets the condition and drops the others, in place. -- the numbers that fail the condition are removed from the list, and a condition that does not mention @i is refused
- `EachDividedWithW` (line 5518): Raises error R19 today instead of returning a copy divided by n where the condition holds. -- it takes no condition and calls the chaining form of DivideEachWithW with one argument, so the call raises error R19
- `ARandomNumber` (line 5900): Returns a number taken at random from the list, but only when one of its numbers lies strictly between 1 and its size. -- the body calls ARandomNumberBetween, which resolves to this class's own method, so a number from the list is used as a position; with no number strictly between 1 and the size it raises "No valid numbers found in the list!"
- `ANumber` (line 5913): Returns a number taken at random from the list, but only when one of its numbers lies strictly between 1 and its size. -- same as ARandomNumber; the picked list number is used as a position, and the call raises when no number lies strictly between 1 and the size
- `AnyRandomNumber` (line 5923): Returns a number taken at random from the list, but only when one of its numbers lies strictly between 1 and its size. -- same as ARandomNumber; the picked list number is used as a position, and the call raises when no number lies strictly between 1 and the size
- `AnyNumber` (line 5933): Returns a number taken at random from the list, but only when one of its numbers lies strictly between 1 and its size. -- same as ARandomNumber; the picked list number is used as a position, and the call raises when no number lies strictly between 1 and the size
- `ANumberLessThan` (line 5957): Returns a random number among those below n, but only when one of them lies strictly between 1 and their count. -- it draws with ARandomNumber from the numbers below n, so it raises "No valid numbers found in the list!" when none of them lies strictly between 1 and their count
- `ANumberGreaterThan` (line 6056): Raises error R14 today instead of returning a random number above n. -- it calls NumbersGreaterThanQRT, which is defined nowhere
- `AnyNumberBeforeOrAfter` (line 6177): Picks a number before or after n at random, then reads that number as a position, so the answer is often wrong or an error. -- AnyNumberBefore and AnyNumberAfter already return numbers and the result is passed to Item() as a position; it also raises when n is absent
- `AnyNumberAfter` (line 6561): Returns a number from the positions after the place n holds counted from the END of the list, which is not the place after n. -- it looks n up in the reversed list and uses that position on the original list, so 200 in [ 100, 200, 300, 400, 500 ] always answers 500
- `AnyNumberAfterPosition` (line 6654): Returns a number from a position meant to come after the given one, but computed so that it can come before it. -- the position is chosen between n-1 and 2n-3 instead of after n, so n = 2 always answers the first number
- `AnyNumberNotBetweenPositions` (line 7266): Raises error R3 today instead of returning a number from outside the given positions. -- it calls AnyNumberNotIn, which is defined nowhere
- `AnyNumberOutsidePosition` (line 7417): Raises error R24 today instead of returning a number from any position but the given one. -- it builds the list of positions into one variable and reads another (_anPos_), which is never set
- `NRandomNumbers` (line 7580): Returns n numbers drawn at random, repeats allowed, from those strictly between 1 and the list size. -- it draws with ARandomNumberBetween(1, size), which resolves to this class's own method, so it picks list numbers lying between 1 and the size instead of any item of the list; it raises when none lies there
- `NNumbersOtherThan` (line 7681): Raises error R19 today instead of returning n random numbers other than a given number. -- it calls NRandomNumbersIn with too few arguments and looks up n, the count, instead of the number to leave out
- `NNumbersLessThan` (line 7757): Raises error R14 today instead of returning n random numbers below a given number. -- it asks NumbersLessThanQ for NRandomNumbers, which the object it gets back does not have
- `NNumbersGreaterThan` (line 7810): Raises error R14 today instead of returning n random numbers above a given number. -- it calls NumbersGreaterThanQ, which is defined nowhere
- `NItemsOutsidePositionZ` (line 8143): Raises error R4 today instead of returning n items from outside a position, with their positions. -- the method calls itself with the same argument, so it recurses until the stack overflows
- `SomeNumbersOtherThan` (line 8198): Returns some numbers picked at random from those other than n; the second parameter is not used. -- only the first parameter is read
- `SomeNumbersLessThan` (line 8235): Raises error R3 today instead of returning some random numbers below a given number. -- it calls StzListOfNumbers(), which is not a function (StzListOfNumbersQ is)
- `SomeNumbersGreaterThan` (line 8261): Raises error R3 today instead of returning some random numbers above a given number. -- it calls StzListOfNumbers(), which is not a function (StzListOfNumbersQ is)
- `SomeNumbersBetween` (line 8305): Raises error R3 today instead of returning some random numbers between two limits. -- it calls StzListOfNumbers(), which is not a function (StzListOfNumbersQ is)
- `SomeNumbersNotBetween` (line 8331): Raises error R3 today instead of returning some random numbers outside two limits. -- it calls StzListOfNumbers(), which is not a function (StzListOfNumbersQ is)
- `AreGreaterThen` (line 9172): TRUE if every number is at least n, the limit itself counting as greater. -- the test is number >= n, not strictly greater
- `AreSmallerThen` (line 9203): TRUE if every number is at most n, the limit itself counting as smaller. -- the test is number <= n, not strictly smaller
- `SortByInDescending` (line 9732): Raises error R13 today instead of sorting the numbers by an expression, largest first, in place. -- the body chains .Reversed() directly onto new stzList(...), which Ring answers with error R13
- `SortByDown` (line 9746): Raises error R13 today instead of sorting the numbers by an expression, largest first, in place. -- it calls SortByInDescending, which raises error R13
- `SortedByInDescending` (line 9758): Raises error R13 today instead of returning the numbers sorted by an expression, largest first. -- it calls SortByInDescending, which raises error R13

## stzMatrix -- number/stzMatrix.ring (2)

- `Diagonal1` (line 2961): Returns nothing today instead of the main diagonal, because its body is empty. -- the method exists but has no body, so it answers an empty value for every matrix; Diagonal gives the main diagonal
- `EigenVectors` (line 4433): Returns the unit eigenvectors as the columns of a matrix, in the same order as the eigenvalues. -- raises an error unless the matrix is square, for a defective matrix, and when an eigenvector is complex

## stzNumber -- number/stzNumber.ring (20)

- `isWeiferich` (line 3883): Answers an empty string today instead of telling whether the number is a Wieferich prime. -- the call answers an empty string today
- `IsQuietEqualTo` (line 4546): Raises an error today instead of telling whether two numbers differ by less than the quiet ratio. -- the call raises error R13 today, because it subtracts a plain number with an operator that needs an object
- `RoundUp` (line 5439): Raises an error today instead of returning the number rounded up. -- the call raises error R24 today (a variable used before it is set)
- `RoundDown` (line 5448): Raises an error today instead of returning the number rounded down. -- the call raises error R24 today (a variable used before it is set)
- `Incremented` (line 5946): Answers an empty string today instead of the number plus 1; the number is unchanged. -- it answers an empty string; NextNumber answers the number plus 1
- `Decremented` (line 5968): Answers an empty string today instead of the number minus 1; the number is unchanged. -- it answers an empty string; PreviousNumber answers the number minus 1
- `ArcTangent` (line 6309): Raises an error today instead of returning the arc tangent of the number. -- the call raises error R24 today (a variable used before it is set)
- `ArcTangent2` (line 6320): Raises an error today instead of returning the two-argument arc tangent. -- the call raises an error about its parameter count today
- `HyperbolicTangent` (line 6352): Raises an error today instead of returning the hyperbolic tangent of the number. -- the call raises error R3 today (it calls tanhh, which is not defined)
- `Derivative` (line 6485): Raises an error today instead of returning the derivative of a function at the number. -- the call raises error R24 today (a variable used before it is set)
- `ToBytes` (line 7369): Raises a parameter-type error today instead of returning the number as bytes. -- the call raises a parameter-type error today
- `RemoveLeadingSpaces` (line 8340): Raises an error today instead of removing the spaces before the number. -- the call raises error R14 today, because it calls a stzString method that does not exist
- `LeadingSpacesRemoved` (line 8352): Raises an error today instead of returning the number without its leading spaces. -- the call raises error R14 today, because it calls a stzString method that does not exist
- `RemoveTrailingSpaces` (line 8361): Raises an error today instead of removing the spaces after the number. -- the call raises error R14 today, because it calls a stzString method that does not exist
- `TrailingSpacesRemoved` (line 8373): Raises an error today instead of returning the number without its trailing spaces. -- the call raises error R14 today, because it calls a stzString method that does not exist
- `ZerosRemoved` (line 8423): Raises an error today instead of returning the number without the zeros at its ends. -- the call raises error R14 today, because it calls a method that does not exist
- `SetDefaultFormat` (line 8907): Raises an unsupported-feature error today instead of setting the default number format. -- the call raises an unsupported-feature error today
- `ApplyLocale` (line 8916): Raises an unsupported-feature error today instead of applying a locale to the number. -- the call raises an unsupported-feature error today
- `Stringify` (line 9360): Answers an empty string today instead of the number as text, because its body is empty. -- the body is empty, so the call answers nothing; StringValue answers the number as a string
- `DeepStringifiy` (line 9372): Answers an empty string today instead of the number as text, because its body is empty. -- the body is empty today; StringValue answers the number as a string

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

## stzDataSet -- stats/stzDataSet.ring (5)

- `WMean` (line 1814): Raises error R4 today instead of returning the weighted mean. -- it calls itself, so the stack overflows on every call
- `Percentile` (line 2185): Returns the value at a percentile of the sorted data, interpolating linearly between neighbours. -- a percent below 0, or far above 100, makes the engine panic and ends the Ring process; -1 and 150 did, 110 and 101 did not
- `NonParametricCorrelation` (line 2920): Raises error R24 today instead of returning a rank correlation. -- the body reads a variable named _oOtherStats_ that this method does not receive
- `MutualInformation` (line 3140): Returns the mutual information, in bits, between this data and another data set of the same length. -- the pairs are joined with an underscore and split again, so a value containing an underscore gives a wrong result: "a_b" and "c_d" against x and y give 0 where ab and cd give 1
- `PlanSummary` (line 3979): Raises error R5 today instead of returning a text preview of a plan's steps without running it. -- the body reads the title from a variable named oPlan, which does not exist, instead of from the plan it built

## stzString -- string/stzString.ring (9)

- `IsCurrencySymbol` (line 9373): Answers FALSE today: the currency symbol check is a stub that waits for the locale data.
- `SplitAroundCS_named` (line 14858): Raises error R14 today instead of splitting around the substring with a case rule. -- the call raises error R14 today, because it calls a method that is not defined
- `SplitToPartsOfNCharsXTOpt` (line 15469): Raises error R19 today instead of splitting the string into parts of n chars with options. -- the call raises error R19 today when given the one argument it documents
- `Move` (line 16132): Moves the char at one position to another, in place, but lands one place early today. -- Move(1, 3) on "banana" gives "abnana", the char landing at position 2 and not 3
- `IsIncludedIn` (line 16777): TRUE if the other string occurs inside this one; the two sides are read the other way round today. -- IsIncludedIn("bananas") on "banana" answers FALSE, and IsIncludedIn("an") answers TRUE, so it tests whether the argument is inside the string
- `TrailingCharIs` (line 17734): Answers FALSE today for a string that ends with the given char, such as "banana" and "a". -- the call answers FALSE where the last char equals the argument; HasThisTrailingChar answers correctly
- `LeadingCharIs` (line 17745): Answers FALSE today for a string that starts with the given char, such as "banana" and "b". -- the call answers FALSE where the first char equals the argument; HasThisLeadingChar answers correctly
- `RemoveDuplicates` (line 23599): Removes the repeated characters of the text, in place, but a known defect makes the call raise an error today. -- the call raises error R14 today, because it calls UpdateWith, which this class does not define
- `RemoveBlankLines` (line 25425): Raises error R14 today instead of removing the blank lines. -- the call raises error R14 today, because it calls a method that is not defined; RemoveEmptyLines works

## stzStringChar -- string/stzStringChar.ring (23)

- `HexUnicode` (line 815): Returns the codepoint as U+ followed by four hex digits, such as U+0061. -- only four hex digits are kept, so a char above U+FFFF comes out wrong: U+1F600 reads U+F600
- `Update` (line 883): Replaces the held char with the given text, in place; a codepoint number empties the object today. -- Update(98) leaves an empty string and Unicode 0, because the number is never converted; Update("ab") stores both chars, so only a one-char text works as meant
- `UpdateWith` (line 913): Replaces the held char with the given one, in place, exactly as the plain form does. -- shares the defect of the plain form, so a codepoint number empties the object
- `UpdateBy` (line 927): Replaces the held char with the given one, in place, exactly as the plain form does. -- shares the defect of the plain form, so a codepoint number empties the object
- `UpdateUsing` (line 941): Replaces the held char with the given one, in place, exactly as the plain form does. -- shares the defect of the plain form, so a codepoint number empties the object
- `CanRetrieveName` (line 976): Answers TRUE when the Unicode database holds a name for the char, and raises when it does not. -- for an unnamed code such as U+0378 it raises "Can't proceed!" instead of answering FALSE, because it asks for the name and the name request raises
- `AsciiCode` (line 1027): Returns the ASCII code of the char, 0 to 127; for a char above 127 it raises R3 instead of a clear message. -- the failure branch calls stzCharError, which is defined nowhere, so a non-ASCII char raises R3 "Calling Function without definition"
- `IsLeftToRightIsolate` (line 1231): Returns an empty string today instead of TRUE for the left-to-right isolate mark, U+2066. -- the body is only a comment ("Reserved for future implementation"), so the answer is always empty
- `IsRightToLeftIsolate` (line 1239): Returns an empty string today instead of TRUE for the right-to-left isolate mark, U+2067. -- the body is only a comment ("Reserved for future implementation"), so the answer is always empty
- `IsEuropean` (line 1452): Raises error R14 today instead of TRUE for a European number, separator or terminator. -- the body calls IsEuropeanNumber, which is defined nowhere
- `IsUnicodeNumber` (line 1477): Answers TRUE for Arabic, Hebrew or CJK letters and FALSE for 7 today, instead of TRUE for number chars. -- it tests category codes 3, 4 and 5, which are title-case, modifier and other letters in the engine's numbering, where digits are 9 to 11; Roman, Mandarin and Indian numerals are caught by their own tests
- `IsArabicNumber` (line 1522): Answers FALSE for 0 to 9 and raises R41 for a non-ASCII digit today, instead of TRUE for an Arabic digit. -- it searches a list of digit texts for a number, so a plain digit is never found, and it adds 0 to the content, which raises R41 "Invalid numeric string" for an Arabic-Indic, Devanagari or circled digit
- `Mirrored` (line 1744): Raises error R3 today instead of returning the mirror partner of the char. -- the body calls CharFromUnicode, which is defined nowhere
- `IsBasicLatin` (line 1777): Raises error R24 today instead of testing for the Basic Latin block, U+0000 to U+007F. -- the body reads _anBasicLatinUnicodes, but the data file defines _anLatinBasicUnicodes
- `IsBasicArabic` (line 1866): Raises error R24 today instead of testing for the basic Arabic block. -- the body reads _anBasicArabicUnicodes, which the data file does not define
- `IsCircledLatinSmallLetter` (line 1987): Raises error R24 today instead of testing for a circled small Latin letter. -- the body reads _aCircledLatinSmallLetterUnicodes directly, a variable that is not defined
- `IsCircledLatinCapitalLetter` (line 1997): Raises error R24 today instead of testing for a circled capital Latin letter. -- the body reads _aCircledLatinCapitalLetterUnicodes directly, a variable that is not defined
- `IsOtherCircledChar` (line 2006): Raises error R3 today instead of testing for a circled char outside the digits and Latin letters. -- the body calls OtherCircledCharUnicodes, which is defined nowhere
- `IsPrintable` (line 2020): Answers FALSE for digits, hyphens and Roman numerals and TRUE for control chars today, as it tests the wrong category codes. -- it rejects category codes 9 to 13 (digits, Roman numerals, connector and dash punctuation) where it meant the control, format and surrogate codes 26 to 29
- `IsNonPrintable` (line 2033): Answers TRUE for digits, hyphens and Roman numerals and FALSE for control chars today, the reverse of printable. -- it is the negation of the printable test, which tests the wrong category codes
- `IntroducedInUnicodeVersion` (line 2077): Returns a rough Unicode version taken from the char's block, "0.9" for nearly every char and "3.2" for emoji. -- the version list is an approximation, marked #TODO in the data file ("Put correct values"); emoji were added in Unicode 6
- `DefaultLanguage` (line 2165): Returns the main language of the char's script, such as english, arabic or hebrew, and undefined for chars shared by scripts. -- raises "Can not create char object!" for a char of the Inherited or Unknown script, such as a combining accent, an unassigned code or a private-use char
- `TaiThamScript` (line 2867): Raises error R14 today instead of testing for the Tai Tham script. -- the body calls ScriptCode, which was retired; ScriptIs("taitham") is the working test

## stzStringList -- string/stzStringList.ring (2)

- `SortBy` (line 1311): Sorts the strings in place by a numeric key computed from each one, such as its length; a text key raises. -- @item is not defined here and raises R24, and a key that is text raises R41 because keys are compared with a greater-than, so only numeric keys such as len(@string) work
- `Matches` (line 1760): TRUE if every string matches the pattern as a whole, so "a." matches ab and "a" does not; an empty list is TRUE. -- the old comment says it returns the strings that match, but it answers one verdict for the whole list

## stzTable -- table/stzTable.ring (191)

- `CellAndPosition` (line 1727): Raises error R24 today instead of returning a cell with its [ column, row ] position. -- Raises R24 (uninitialized variable pnrow) because the body passes pnRow while the parameter is named pRow; CellZ works
- `CellAndItsPosition` (line 1737): Raises error R24 today instead of returning a cell with its [ column, row ] position. -- Raises R24 (uninitialized variable pnrow) because the body passes pnRow while the parameter is named pRow; CellZ works
- `Cells` (line 1886): Raises error R41 today instead of returning every cell, row by row. -- Raises R41 (invalid numeric string) because it calls Section with :FirstCol and :LastRow corners, which Section does not read; Rows gives the cells row by row
- `PositionsAndTheseCells` (line 2049): Raises error today instead of pairing each given position with its cell. -- Raises Column not found! or R2 because the body reads paCells[1] and paCells[2] instead of the item of the loop
- `SectionToRange` (line 2748): Raises error today instead of returning a range of the table. -- Always raises Feature not implemented yet!
- `Range` (line 2758): Raises error today instead of returning a block of the table between two bounds. -- Always raises Feature not implemented yet!
- `CellsInCols` (line 2842): Raises error R14 today instead of returning the cells of the given columns. -- Raises R14 because IsListOfNumbersOrStrings is defined nowhere
- `CellsInRowNAndTheirPositions` (line 3590): Raises error R24 today instead of returning the cells of row n with their positions. -- Raises R24 (uninitialized variable p) because the body passes p, not n; RowZ works
- `CellsAndPositionsInNthRow` (line 3620): Raises error R24 today instead of returning the cells of row n with their positions. -- Raises R24 (uninitialized variable p) because the body passes p, not n; RowZ works
- `CellsInNthRowAndTheirPositions` (line 3636): Raises error R24 today instead of returning the cells of row n with their positions. -- Raises R24 (uninitialized variable p) because the body passes p, not n; RowZ works
- `Extend` (line 3935): Raises error today instead of growing the table to a given size. -- Always raises Unsupported feature in this release!
- `ExtendTo` (line 3947): Does nothing today instead of growing the table to a given size. -- Its body is empty
- `RenameCols` (line 4132): Raises error R14 today instead of renaming several columns from [ old name, new name ] pairs. -- Raises R14 because it calls RenameCol, which is defined nowhere
- `RemnameNthCols` (line 4179): Raises error R24 today instead of renaming several columns by position. -- Raises R24 (uninitialized variable pacolsnumbers) because the check reads another name than the parameter; it would also call RenameColN without a new name
- `RenameLastCol` (line 4205): Raises error R2 today instead of renaming the last column. -- Raises R2 because it passes :Last, which RenameNthCol does not understand; RenameNthCol with the real position works
- `RemoveColumnsAt` (line 4235): Raises error R24 today instead of removing the columns at the given positions. -- Raises R24 because the body sorts an undefined name (TpacColNamesOrNumbers); RemoveCols with the positions works
- `RemoveColsAt` (line 4262): Raises error R24 today instead of removing the columns at the given positions. -- Raises R24 because RemoveColumnsAt sorts an undefined name; RemoveCols with the positions works
- `RemoveNthCols` (line 4272): Raises error R24 today instead of removing the columns at the given positions. -- Raises R24 because RemoveColumnsAt sorts an undefined name; RemoveCols with the positions works
- `RemoveNthColumns` (line 4282): Raises error R24 today instead of removing the columns at the given positions. -- Raises R24 because RemoveColumnsAt sorts an undefined name; RemoveCols with the positions works
- `RemoveAllColsExceptAt` (line 4292): Raises error R24 today instead of keeping only the columns at the given positions. -- Raises R24 because the body passes paColNumbers, which is not the parameter name
- `RemoveColsExceptPositions` (line 4303): Raises error R24 today instead of keeping only the columns at the given positions. -- Raises R24 through RemoveAllColsExceptAt, which passes a name that is not its parameter
- `RemoveColumnsExceptPositions` (line 4313): Raises error R24 today instead of keeping only the columns at the given positions. -- Raises R24 through RemoveAllColsExceptAt, which passes a name that is not its parameter
- `RemoveAllColsExceptPositions` (line 4323): Raises error R24 today instead of keeping only the columns at the given positions. -- Raises R24 through RemoveAllColsExceptAt, which passes a name that is not its parameter
- `RemoveAllColumnsExceptPositions` (line 4333): Raises error R24 today instead of keeping only the columns at the given positions. -- Raises R24 through RemoveAllColsExceptAt, which passes a name that is not its parameter
- `RemoveColsExceptAt` (line 4344): Raises error R24 today instead of keeping only the columns at the given positions. -- Raises R24 through RemoveAllColsExceptAt, which passes a name that is not its parameter
- `RemoveAllColsOtherThanPositions` (line 4354): Raises error R24 today instead of keeping only the columns at the given positions. -- Raises R24 through RemoveAllColsExceptAt, which passes a name that is not its parameter
- `RemoveColsOtherThanPositions` (line 4364): Raises error R24 today instead of keeping only the columns at the given positions. -- Raises R24 through RemoveAllColsExceptAt, which passes a name that is not its parameter
- `RemoveAllColumnsExceptAt` (line 4375): Raises error R24 today instead of keeping only the columns at the given positions. -- Raises R24 through RemoveAllColsExceptAt, which passes a name that is not its parameter
- `RemoveColumnsExceptAt` (line 4385): Raises error R24 today instead of keeping only the columns at the given positions. -- Raises R24 through RemoveAllColsExceptAt, which passes a name that is not its parameter
- `RemoveAllColumnsOtherThanPositions` (line 4395): Raises error R24 today instead of keeping only the columns at the given positions. -- Raises R24 through RemoveAllColsExceptAt, which passes a name that is not its parameter
- `RemoveColumnsOtherThanPositions` (line 4405): Raises error R24 today instead of keeping only the columns at the given positions. -- Raises R24 through RemoveAllColsExceptAt, which passes a name that is not its parameter
- `RemoveAllColsOtherThan` (line 4431): Raises error R14 today instead of keeping only the given columns. -- Raises R14 because IsListOfNumbersOrStrings is defined nowhere
- `RemoveColsOtherThan` (line 4440): Raises error R14 today instead of keeping only the given columns. -- Raises R14 because IsListOfNumbersOrStrings is defined nowhere
- `RemoveAllColumnsOtherThan` (line 4457): Raises error R14 today instead of keeping only the given columns. -- Raises R14 because IsListOfNumbersOrStrings is defined nowhere
- `RemoveColumnsOtherThan` (line 4466): Raises error R14 today instead of keeping only the given columns. -- Raises R14 because IsListOfNumbersOrStrings is defined nowhere
- `RemoveNthRows` (line 4580): Raises error R13 today instead of removing the rows at the given positions. -- Raises R13 because the body sorts the positions through U(), which does not give an object; RemoveNthRow works one row at a time
- `RemoveRowsAt` (line 4609): Raises error R13 today instead of removing the rows at the given positions. -- Raises R13 because the body sorts the positions through U(), which does not give an object; RemoveNthRow works one row at a time
- `RemoveRows` (line 4619): Raises error R13 today instead of removing the given rows, listed by position or as lists of cells. -- Positions raise R13 through RemoveNthRows; rows raise R14 because FindTheseRows is defined nowhere
- `RemoveAllRowsExceptAt` (line 4648): Raises error R13 today instead of keeping only the rows at the given positions. -- Raises R13 through RemoveRows, which relies on RemoveNthRows
- `RemoveRowsExceptAt` (line 4665): Raises error R13 today instead of keeping only the rows at the given positions. -- Raises R13 through RemoveRows, which relies on RemoveNthRows
- `RemoveAllRowsOtherThanPositions` (line 4674): Raises error R13 today instead of keeping only the rows at the given positions. -- Raises R13 through RemoveRows, which relies on RemoveNthRows
- `RemoveRowsOtherThanPositions` (line 4683): Raises error R13 today instead of keeping only the rows at the given positions. -- Raises R13 through RemoveRows, which relies on RemoveNthRows
- `RemoveAllRowsExcept` (line 4694): Raises error R13 today instead of keeping only the given rows. -- Positions are passed to RemoveRowsAt, which would remove the rows to keep and raises R13; rows rely on FindRowsExceptThese
- `RemoveAllRowsOtherThan` (line 4728): Raises error R13 today instead of keeping only the given rows. -- Positions are passed to RemoveRowsAt, which would remove the rows to keep and raises R13; rows rely on FindRowsExceptThese
- `RemoveRowsOtherThan` (line 4738): Raises error R13 today instead of keeping only the given rows. -- Positions are passed to RemoveRowsAt, which would remove the rows to keep and raises R13; rows rely on FindRowsExceptThese
- `EraseSection` (line 4929): Raises error R19 today instead of emptying the cells between two corners. -- Raises R19 because it calls SectionAsPositions without the corners; EraseCells with a list of positions works
- `InsertCol` (line 4946): Does nothing today instead of inserting a new column before or after a given position. -- Does nothing today: the body appends the column to the stored content but then restores the content copied before, so the table is unchanged; AddColumn appends a column
- `InsertColBefore` (line 5008): Does nothing today instead of inserting a new column before or after a given position. -- Does nothing today: the body appends the column to the stored content but then restores the content copied before, so the table is unchanged
- `InsertColBeforePosition` (line 5019): Does nothing today instead of inserting a new column before or after a given position. -- Does nothing today: the body appends the column to the stored content but then restores the content copied before, so the table is unchanged
- `insertColAt` (line 5031): Does nothing today instead of inserting a new column before or after a given position. -- Does nothing today: the body appends the column to the stored content but then restores the content copied before, so the table is unchanged
- `InsertColAtPosition` (line 5042): Does nothing today instead of inserting a new column before or after a given position. -- Does nothing today: the body appends the column to the stored content but then restores the content copied before, so the table is unchanged
- `InsertColumn` (line 5054): Does nothing today instead of inserting a new column before or after a given position. -- Does nothing today: the body appends the column to the stored content but then restores the content copied before, so the table is unchanged
- `InsertColumnBefore` (line 5065): Does nothing today instead of inserting a new column before or after a given position. -- Does nothing today: the body appends the column to the stored content but then restores the content copied before, so the table is unchanged
- `InsertColumnBeforePosition` (line 5076): Does nothing today instead of inserting a new column before or after a given position. -- Does nothing today: the body appends the column to the stored content but then restores the content copied before, so the table is unchanged
- `insertColumnAt` (line 5088): Does nothing today instead of inserting a new column before or after a given position. -- Does nothing today: the body appends the column to the stored content but then restores the content copied before, so the table is unchanged
- `InsertColumnAtPosition` (line 5099): Does nothing today instead of inserting a new column before or after a given position. -- Does nothing today: the body appends the column to the stored content but then restores the content copied before, so the table is unchanged
- `InsertColAfter` (line 5111): Does nothing today instead of inserting a new column before or after a given position. -- Does nothing today: the body appends the column to the stored content but then restores the content copied before, so the table is unchanged
- `InsertColAfterPosition` (line 5123): Does nothing today instead of inserting a new column before or after a given position. -- Does nothing today: the body appends the column to the stored content but then restores the content copied before, so the table is unchanged
- `InsertColumnAfter` (line 5135): Does nothing today instead of inserting a new column before or after a given position. -- Does nothing today: the body appends the column to the stored content but then restores the content copied before, so the table is unchanged
- `InsertColumnAfterPosition` (line 5146): Does nothing today instead of inserting a new column before or after a given position. -- Does nothing today: the body appends the column to the stored content but then restores the content copied before, so the table is unchanged
- `InsertRowAtPositions` (line 5289): Raises error R13 today instead of inserting one row at each of several positions. -- Raises R13 because the body sorts the positions through U(), which does not give an object
- `InsertRows` (line 5311): Raises error R13 today instead of inserting one row at each of several positions. -- Raises R13 through InsertRowAtPositions, which sorts the positions through U(), which does not give an object
- `InsertRowsAt` (line 5322): Raises error R13 today instead of inserting one row at each of several positions. -- Raises R13 through InsertRowAtPositions, which sorts the positions through U(), which does not give an object
- `TheseColNames` (line 5593): Raises an error today instead of returning the names of the columns at the given positions. -- Raises Can't create the stzList object! because the body calls Sorted() straight on a new stzList; ColNumbersToNames works
- `ReplaceNthColName` (line 6261): Leaves the table unchanged today instead of giving a column a new name. -- Does nothing because the body renames the stored content and then restores the content copied before; a name that already exists still raises an error
- `ReplaceColName` (line 6275): Leaves the table unchanged today instead of giving a column a new name. -- Does nothing because the body renames the stored content and then restores the content copied before; a name that already exists still raises an error
- `ReplaceColumnName` (line 6303): Leaves the table unchanged today instead of giving a column a new name. -- Does nothing because the body renames the stored content and then restores the content copied before; a name that already exists still raises an error
- `FindColsByValue` (line 6520): Raises an error today instead of returning the positions of the columns equal to any of the given cell lists. -- Raises Can't create the stzList object! for a valid list of cell lists; FindColByValue works one list at a time
- `FindColsExceptAt` (line 6561): Returns the positions of the columns that are not in the given list; only a list of lists is accepted today. -- The check tests for a list of lists instead of a list of numbers: a plain list of positions raises, and [ [ 1 ] ] leaves out nothing
- `FindNthRow` (line 6719): Raises error R19 today instead of returning the position of the nth occurrence of a row. -- Raises R19 because it passes too few arguments to FindNthRowCS
- `FindSubValues` (line 7180): Raises error today instead of finding the cells that contain any of several texts. -- Always raises TODO!
- `FindNthOccurrenceOfSubValue` (line 7378): Raises error R24 today instead of finding the nth cell that contains a text. -- Raises R24 (uninitialized variable psubvalue) because the body passes pSubValue while the parameter is named pSubValueValue; FindNthSubValue works
- `FindFirstOccurrenceOfSubValue` (line 7509): Raises error R24 today instead of finding the first cell that contains a text. -- Raises R24 because the body passes pSubValue while the parameter is named pSubValueValue; FindFirstSubValue works
- `FindLastOccurrenceOfSubValue` (line 7619): Raises error R24 today instead of finding the last cell that contains a text. -- Raises R24 because the body passes pSubValue while the parameter is named pSubValueValue; FindLastSubValue works
- `ContainsColumns` (line 8255): Raises error R24 today instead of testing that the table has the given columns. -- Raises R24 (uninitialized variable pacol) because the body passes paCol while the parameter is named paCols; ContainsCols works
- `ContainsTheseColumns` (line 8265): Raises error R24 today instead of testing that the table has the given columns. -- Raises R24 (uninitialized variable pacol) because the body passes paCol while the parameter is named paCols; ContainsCols works
- `OccurrencesInCells` (line 8503): Raises error R24 today instead of finding a text inside the given cells. -- Raises R24 (uninitialized variable pacells) because the method takes no list of cells; FindAllInCells works
- `FindValueInCells` (line 8567): Raises an error today instead of finding the given cells that equal a value. -- Declares one parameter but forwards to a form that needs the cells and the value: any call raises R19 or R20
- `PositionsOfValueInCells` (line 8580): Raises error R24 today instead of finding the given cells that equal a value. -- Raises R24 (uninitialized variable ppacells) because the body passes a misspelt name
- `FindNthOccurrenceOfValueInCells` (line 8751): Raises error R24 today instead of finding the nth given cell that equals a value. -- Raises R24 (uninitialized variable pvalue) because the body passes pValue while the parameter is named pCellValue
- `FindNthOccurrenceOfSubValueInCells` (line 8819): Raises error R24 today instead of finding the nth given cell that contains a text. -- Raises R24 because the body passes pSubValue while the parameter is named pSubValueValue
- `FindFirstValueInCells` (line 8883): Raises error R14 today instead of finding the first given cell that equals a value. -- Raises R14 because FindFirstValueInCellCS is defined nowhere; FindFirstInCells works
- `FindFirstOccurrenceOfValueInCells` (line 8894): Raises error R24 today instead of finding the first given cell that equals a value. -- Raises R24 because the body passes pValue while the parameter is named pCellValue
- `FindFirstOccurrenceOfSubValueInCells` (line 8924): Raises error R24 today instead of finding the first given cell that contains a text. -- Raises R24 because the body passes pSubValue while the parameter is named pSubValueValue
- `FindLastValueInCells` (line 8988): Raises error R14 today instead of finding the last given cell that equals a value. -- Raises R14 because FindLastValueInCellCS is defined nowhere; FindLastInCells works
- `FindLastOccurrenceOfValueInCells` (line 8999): Raises error R24 today instead of finding the last given cell that equals a value. -- Raises R24 because the body passes pValue while the parameter is named pCellValue
- `FindLasttOccurrenceOfSubValueInCells` (line 9029): Raises error R24 today instead of finding the last given cell that contains a text. -- Raises R24 because the body passes pSubValue while the parameter is named pSubValueValue; the name misspells Last
- `NumberOfOccurrencesOfSubValueInCells` (line 9179): Returns 0 today instead of the number of given cells that contain a text. -- Counts cells equal to the text, not cells containing it, so a text found inside a longer cell is missed
- `FindLastInCell` (line 9420): Raises error today instead of returning the place of the last occurrence of a text inside one cell. -- Raises Incorrect param type! n must be a number. because it passes :Last, which the nth-occurrence finder does not read
- `NumberOfOccurrencesInCell` (line 9479): Raises an error today instead of counting how many times a text occurs inside one cell. -- Raises Bad parameter type! for every argument tried
- `NumberOfOccurrencesOfValueInCell` (line 9522): Raises an error today instead of counting how many times a value occurs inside one cell. -- Raises Bad parameter type! for every argument tried
- `NumberOfOccurrencesOfSubValueInCell` (line 9575): Raises an error today instead of counting how many times a text occurs inside one cell. -- Raises Bad parameter type! for every argument tried
- `CellContainsValueCS` (line 9663): Raises error R14 today instead of testing whether one cell equals a value, with a case flag. -- Raises R14 because FindFirstValueInCellCS is defined nowhere
- `CellContainValue` (line 9681): Raises error R14 today instead of testing whether one cell equals a value. -- Raises R14 because CellContainValueCS is defined nowhere
- `FindValueInRow` (line 9797): Raises error R24 today instead of finding the cells in one row that equal a value. -- Raises R24 (uninitialized variable psubvalue) because the body passes pSubValue, which is not its parameter; FindInRow works
- `FindNthValueInRow` (line 9859): Raises error R19 today instead of finding the nth cell in one row that equals a value. -- Raises R19 because the body calls RowAsPositions() or SectionAsPositions() without its arguments
- `FindNthSubValueInRow` (line 9880): Raises error R19 today instead of finding the nth cell in one row that contains a text. -- Raises R19 because the body calls RowAsPositions() or SectionAsPositions() without its arguments
- `FindFirstValueInRow` (line 9923): Raises error R4 today instead of finding the first cell in one row that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindFirstSubValueInRow` (line 9942): Raises error R4 today instead of finding the first cell in one row that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastValueInRow` (line 9985): Raises error R4 today instead of finding the last cell in one row that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastSubValueInRow` (line 10004): Raises error R4 today instead of finding the last cell in one row that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `NumberOfOccurrenceOfCellInRow` (line 10089): Raises error R14 today instead of counting the cells in one row that equal a value. -- Raises R14 because the CS helper it calls is defined nowhere
- `NumberOfOccurrenceOfValueInRow` (line 10120): Raises error R24 today instead of counting the cells in one row that equal a value. -- Raises R24 (uninitialized variable pcasesensitive) because the body passes a flag it does not have
- `CountOfValueInRowInRow` (line 10132): Raises error R14 today instead of counting the cells of a row that equal a value. -- Raises R14 because NumberOfOccurrenceOfCellInRowInRow is defined nowhere
- `FindValueInRows` (line 10350): Raises error R24 today instead of finding the cells in the given rows that equal a value. -- Raises R24 (uninitialized variable psubvalue) because the body passes pSubValue, which is not its parameter; FindInRows works
- `FindNthInRows` (line 10401): Raises error R14 today instead of finding the nth cell in the given rows that equals a value. -- Raises R14 because RowsToNames is defined nowhere; FindNthValueInRows works
- `FindFirstInRows` (line 10507): Raises error R14 today instead of finding the first cell in the given rows that equals a value. -- Raises R14 because RowsToNames is defined nowhere
- `FindFirstValueInRows` (line 10537): Raises error R4 today instead of finding the first cell in the given rows that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindFirstSubValueInRows` (line 10567): Raises error R4 today instead of finding the first cell in the given rows that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastInRows` (line 10600): Raises error R24 today instead of finding the last cell in the given rows that equals a value. -- Raises R24 (uninitialized variable prow) because the body passes a name that is not its parameter
- `FindLastValueInRows` (line 10630): Raises error R4 today instead of finding the last cell in the given rows that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastSubValueInRows` (line 10660): Raises error R4 today instead of finding the last cell in the given rows that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `NumberOfOccurrenceOfCellInRows` (line 10740): Raises error R14 today instead of counting the cells in the given rows that equal a value. -- Raises R14 because the CS helper it calls is defined nowhere
- `FindValueInCol` (line 10962): Raises error R24 today instead of finding the cells in one column that equal a value. -- Raises R24 (uninitialized variable psubvalue) because the body passes pSubValue, which is not its parameter; FindInCol works
- `FindFirstValueInCol` (line 11205): Raises error R4 today instead of finding the first cell in one column that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindFirstSubValueInCol` (line 11240): Raises error R4 today instead of finding the first cell in one column that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastValueInCol` (line 11323): Raises error R4 today instead of finding the last cell in one column that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastSubValueInCol` (line 11364): Raises error R4 today instead of finding the last cell in one column that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `NumberOfOccurrenceOfCellInCol` (line 11584): Raises error R14 today instead of counting the cells in one column that equal a value. -- Raises R14 because the CS helper it calls is defined nowhere
- `FindValueInCols` (line 12115): Raises error R24 today instead of finding the cells in the given columns that equal a value. -- Raises R24 (uninitialized variable psubvalue) because the body passes pSubValue, which is not its parameter; FindInCols works
- `FindNthInCols` (line 12179): Raises error R14 today instead of finding the nth cell in the given columns that equals a value. -- Raises R14 because ColsToNames is defined nowhere; FindNthValueInCols works
- `FindFirstInCols` (line 12320): Raises error R14 today instead of finding the first cell in the given columns that equals a value. -- Raises R14 because ColsToNames is defined nowhere
- `FindFirstValueInCols` (line 12361): Raises error R4 today instead of finding the first cell in the given columns that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindFirstSubValueInCols` (line 12396): Raises error R4 today instead of finding the first cell in the given columns that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastInCols` (line 12440): Raises error R24 today instead of finding the last cell in the given columns that equals a value. -- Raises R24 (uninitialized variable pcol) because the body passes a name that is not its parameter
- `FindLastValueInCols` (line 12481): Raises error R4 today instead of finding the last cell in the given columns that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastSubValueInCols` (line 12522): Raises error R4 today instead of finding the last cell in the given columns that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `NumberOfOccurrenceOfCellInCols` (line 12735): Raises error R14 today instead of counting the cells in the given columns that equal a value. -- Raises R14 because the CS helper it calls is defined nowhere
- `FindValueInSection` (line 13234): Raises error R24 today instead of finding the cells between two [ column, row ] corners that equal a value. -- Raises R24 (uninitialized variable psubvalue) because the body passes pSubValue, which is not its parameter; FindInSection works
- `FindNthValueInSection` (line 13295): Raises error R19 today instead of finding the nth cell between two [ column, row ] corners that equals a value. -- Raises R19 because the body calls RowAsPositions() or SectionAsPositions() without its arguments
- `FindNthSubValueInSection` (line 13317): Raises error R19 today instead of finding the nth cell between two [ column, row ] corners that contains a text. -- Raises R19 because the body calls RowAsPositions() or SectionAsPositions() without its arguments
- `FindFirstValueInSection` (line 13362): Raises error R4 today instead of finding the first cell between two [ column, row ] corners that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindFirstSubValueInSection` (line 13382): Raises error R4 today instead of finding the first cell between two [ column, row ] corners that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastValueInSection` (line 13427): Raises error R4 today instead of finding the last cell between two [ column, row ] corners that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastSubValueInSection` (line 13447): Raises error R4 today instead of finding the last cell between two [ column, row ] corners that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `NumberOfOccurrenceOfCellInSection` (line 13583): Raises error R14 today instead of counting the cells between two [ column, row ] corners that equal a value. -- Raises R14 because the CS helper it calls is defined nowhere
- `NumberOfOccurrenceOfValueInSection` (line 13615): Raises error R24 today instead of counting the cells between two [ column, row ] corners that equal a value. -- Raises R24 (uninitialized variable pcasesensitive) because the body passes a flag it does not have
- `CountOfValueInSectionInSection` (line 13629): Raises error R14 today instead of counting the cells of a section that equal a value. -- Raises R14 because NumberOfOccurrenceOfCellInSectionInSection is defined nowhere
- `SortedDownOn` (line 14131): Raises error R19 today instead of returning the content sorted in descending order of one column. -- Raises R19 because the body calls SortDownOnQ without the column; SortedOn works for ascending order
- `SortInDescendingOnBy` (line 14475): Raises error R24 today instead of sorting the rows in descending order of an expression on a column. -- Raises R24 (uninitialized variable _ncol_) because the body passes a name that is not its parameter; SortDownOnBy works
- `SortDownOnColBy` (line 14489): Raises error R24 today instead of sorting the rows in descending order of an expression on a column. -- Raises R24 (uninitialized variable pcol) because the parameter is named _nCol_ while the body passes pCol; SortDownOnBy works
- `SortedDownOnColBy` (line 14555): Raises error R24 today instead of returning the content sorted in descending order of an expression on a column. -- Raises R24 (uninitialized variable pcol) because the parameter is named _nCol_ while the body passes pCol; SortedDownOnBy works
- `IsSortedBy` (line 14729): Raises error R14 today instead of testing the order given by an expression on the first column. -- Raises R14 because the body calls IsSotedOnBy, a misspelling; IsSortedOnBy works
- `IsSortedUpBy` (line 14738): Raises error R20 today instead of testing the ascending order given by an expression on the first column. -- Raises R20 because it passes the expression as an extra argument to IsSortedUpOn
- `IsSortedInAscendingBy` (line 14747): Raises error R20 today instead of testing the ascending order given by an expression on the first column. -- Raises R20 because it passes an extra argument to IsSortedUpBy
- `IsSortedUpOnBy` (line 14830): Raises error R14 today instead of testing the ascending order given by an expression on one column. -- Raises R14 because the body relies on SortUpOnBy, which is defined nowhere; IsSortedOnBy works
- `IsSorteUpByOn` (line 14861): Raises error R14 today instead of testing the ascending order given by an expression on one column. -- Raises R14 because the body relies on SortUpOnBy, which is defined nowhere; IsSortedOnBy works
- `IsSortedUpByOnCol` (line 14872): Raises error R14 today instead of testing the ascending order given by an expression on one column. -- Raises R14 because the body relies on SortUpOnBy, which is defined nowhere; IsSortedOnBy works
- `IsSortedUpByOnColumn` (line 14883): Raises error R14 today instead of testing the ascending order given by an expression on one column. -- Raises R14 because the body relies on SortUpOnBy, which is defined nowhere; IsSortedOnBy works
- `IsSorteInAscendingByOn` (line 14903): Raises error R14 today instead of testing the ascending order given by an expression on one column. -- Raises R14 because the body relies on SortUpOnBy, which is defined nowhere; IsSortedOnBy works
- `IsSortedInAscendingByOnCol` (line 14914): Raises error R14 today instead of testing the ascending order given by an expression on one column. -- Raises R14 because the body relies on SortUpOnBy, which is defined nowhere; IsSortedOnBy works
- `IsSortedInAscendingByOnColumn` (line 14925): Raises error R14 today instead of testing the ascending order given by an expression on one column. -- Raises R14 because the body relies on SortUpOnBy, which is defined nowhere; IsSortedOnBy works
- `ReplaceOccurrencesOfCellByValue` (line 16420): Raises error R24 today instead of replacing every cell equal to a value by another value. -- Raises R24 (uninitialized variable pnewcellvalue) because the body passes a name that is not its parameter; ReplaceCellByValue works
- `ReplaceByValueOccurrencesOfCellBy` (line 16440): Raises error R24 today instead of replacing every cell equal to a value by another value. -- Raises R24 (uninitialized variable pnewcellvalue) because the body passes a name that is not its parameter; ReplaceCellByValue works
- `ReplaceManyCellsByValue` (line 16475): Raises error today instead of replacing the cells equal to any of several values by one value. -- Always raises Function not yet implemented!
- `ReplaceCellsByValue` (line 16486): Raises error today instead of replacing the cells equal to any of several values by one value. -- Always raises Function not yet implemented!
- `ReplaceByValueManyCells` (line 16497): Raises error today instead of replacing the cells equal to any of several values by one value. -- Always raises Function not yet implemented!
- `ReplaceByValueCells` (line 16507): Raises error today instead of replacing the cells equal to any of several values by one value. -- Always raises Function not yet implemented!
- `ReplaceManyCellsByValueByMany` (line 16542): Raises error today instead of replacing several cell values by several new values. -- Always raises Function not yet implemented!
- `ReplaceCellsByValueByMany` (line 16553): Raises error today instead of replacing several cell values by several new values. -- Always raises Function not yet implemented!
- `ReplaceByValueManyCellsByMany` (line 16563): Raises error today instead of replacing several cell values by several new values. -- Always raises Function not yet implemented!
- `ReplaceByValueCellsByMany` (line 16573): Raises error today instead of replacing several cell values by several new values. -- Always raises Function not yet implemented!
- `ReplaceAllColsByMany` (line 17284): Raises error today instead of replacing several columns by several new column lists. -- Always raises Unsupported feature in this release!
- `ReplaceAllColumsByMany` (line 17295): Raises error today instead of replacing several columns by several new column lists. -- Always raises Unsupported feature in this release!
- `ReplaceTheseColsByMany` (line 17311): Raises error today instead of replacing several columns by several new column lists. -- Always raises Unsupported feature in this release!
- `ReplaceTheseColumnsByMany` (line 17327): Raises error today instead of replacing several columns by several new column lists. -- Always raises Unsupported feature in this release!
- `ReplaceColsByMany` (line 17336): Raises error today instead of replacing several columns by several new column lists. -- Always raises Unsupported feature in this release!
- `ReplaceColumnsByMany` (line 17345): Raises error today instead of replacing several columns by several new column lists. -- Always raises Unsupported feature in this release!
- `ReplaceCellsInTheseRows` (line 17711): Raises error R24 today instead of setting every cell of the given rows to one value. -- Raises R24 (uninitialized variable panewrows) because the body checks a name that is not its parameter
- `ReplaceAllOccurrencesOfCell` (line 17790): Raises error R19 today instead of replacing every cell equal to a value by another value. -- Raises R19 because it forwards to ReplaceCell with two arguments where ReplaceCell needs a column, a row and a value; ReplaceAll works
- `ReplaceEachOccurrenceOfCell` (line 17800): Raises error R19 today instead of replacing every cell equal to a value by another value. -- Raises R19 because it forwards to ReplaceCell with two arguments where ReplaceCell needs a column, a row and a value; ReplaceAll works
- `ReplaceEveryOccurrenceOfCell` (line 17810): Raises error R19 today instead of replacing every cell equal to a value by another value. -- Raises R19 because it forwards to ReplaceCell with two arguments where ReplaceCell needs a column, a row and a value; ReplaceAll works
- `ReplaceAllOccurrences` (line 17821): Raises error R19 today instead of replacing every cell equal to a value by another value. -- Raises R19 because it forwards to ReplaceCell with two arguments where ReplaceCell needs a column, a row and a value; ReplaceAll works
- `ReplaceEachOccurrence` (line 17831): Raises error R19 today instead of replacing every cell equal to a value by another value. -- Raises R19 because it forwards to ReplaceCell with two arguments where ReplaceCell needs a column, a row and a value; ReplaceAll works
- `ReplaceEveryOccurrence` (line 17841): Raises error R19 today instead of replacing every cell equal to a value by another value. -- Raises R19 because it forwards to ReplaceCell with two arguments where ReplaceCell needs a column, a row and a value; ReplaceAll works
- `ReplaceNth` (line 17863): Raises error R19 today instead of replacing the nth, first or last cell equal to a value. -- Raises R19 because the CS form calls ReplaceCell with a position pair where ReplaceCell needs a column, a row and a value
- `ReplaceFirst` (line 17881): Raises error R19 today instead of replacing the nth, first or last cell equal to a value. -- Raises R19 because the CS form calls ReplaceCell with a position pair where ReplaceCell needs a column, a row and a value
- `ReplaceLast` (line 17899): Raises error R19 today instead of replacing the nth, first or last cell equal to a value. -- Raises R19 because the CS form calls ReplaceCell with a position pair where ReplaceCell needs a column, a row and a value
- `ReplaceInCell` (line 17919): Raises error today instead of replacing a text found inside cells. -- Always raises Function not yet implemented!
- `ReplaceInCells` (line 17936): Raises error today instead of replacing a text found inside cells. -- Always raises Function not yet implemented!
- `ReplaceInCellsByMany` (line 17953): Raises error today instead of replacing a text found inside cells. -- Always raises Function not yet implemented!
- `ReplaceInSection` (line 17973): Raises error today instead of replacing a text found inside cells. -- Always raises Function not yet implemented!
- `ReplaceInSectionByMany` (line 17992): Raises error R24 today instead of replacing several texts found inside a section. -- Raises R24 (uninitialized variable casesensitive) because the body passes a flag it does not have
- `ReplaceInSectionsCS` (line 18003): Raises error today instead of replacing a text found inside cells. -- Always raises Function not yet implemented!
- `ReplaceInSectionsByManyCS` (line 18018): Raises error today instead of replacing a text found inside cells. -- Always raises Function not yet implemented!
- `TheseRowsToRowsNumbers` (line 18310): Raises an error today instead of returning the positions of the given rows. -- Raises Incorrect param type! pRow must be a number. because each row is handed to RowToRowNumber, which refuses a list
- `@` (line 18351): Returns the cell-reading code of a column in a formula, or the text itself when it names no column; a list raises today. -- A column name gives the code text ( This.Cell(n, j) ); a list raises R14 because IsHasHListOrListOfStrings is defined nowhere
- `buildGrandTotal` (line 20783): Raises error R24 today instead of returning the grand-total line of the grid. -- Raises R24 because the body reads the grand totals, which are local to buildDataRows
- `TransposeWithColNames` (line 20964): Raises error R14 today instead of transposing the table while keeping the column names as a first column. -- Raises R14 because the body calls TansposeXT, a misspelling; TransposeXT works
- `ToHtml` (line 21179): Raises error R24 today instead of returning the table as an HTML table. -- Raises R24 because ToHtmlXT reads a variable named data that is never set
- `FromHtml` (line 21254): Raises error R14 today instead of replacing the table by the content of an HTML table. -- Raises R14 because HtmlToTable is defined nowhere
