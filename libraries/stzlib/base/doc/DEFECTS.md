# Defects found while documenting the library (generated)

Each row is a method whose doc block says it is broken **today**: it raises, does nothing, or answers wrongly.
They were found by calling every method once with real data before its block was written (DOCREFORM waves 1-4),
and each was checked with a second call on different data. **None is fixed yet.** The register is generated from
`reference.json` by `doc/tools/wave/mk_defects.py`: fix the method, fix its block (or drop the warning), regenerate.

**At least 227 methods in 31 classes** (the register only catches the blocks worded as defects; the per-wave notes with the evidence list more, for instance stzTimeLine.HasMoment): `doc/tools/wave/data/w*_defects*.md`.

| file | class | defects |
|---|---|---|
| table/stzTable.ring | stzTable | 66 |
| datetime/stzCalendar.ring | stzCalendar | 25 |
| geo/stzGeoMap.ring | stzGeoMap | 18 |
| regex/stzMatrex.ring | stzMatrex | 17 |
| graph/stzGraph.ring | stzGraph | 12 |
| graph/stzOrgChart.ring | stzOrgChart | 10 |
| regex/stzRegex.ring | stzRegex | 10 |
| string/stzStringChar.ring | stzStringChar | 10 |
| reactive/stzReactive.ring | stzReactiveSystem | 7 |
| geo/stzGeoField.ring | stzGeoField | 5 |
| geo/stzGeoSamples.ring | stzGeoSamples | 5 |
| graph/stzDiagram.ring | stzDiagram | 5 |
| list/stzListOfPairs.ring | stzListOfPairs | 4 |
| graph/stzGraph.ring | stzGraphComparison | 3 |
| stats/stzDataSet.ring | stzDataSet | 3 |
| appserver/stzAppServer.ring | stzAppServer | 2 |
| datetime/stzDate.ring | stzDate | 2 |
| geo/stzGeoFeatures.ring | stzGeoFeatures | 2 |
| geo/stzGeoProcess.ring | stzGeoProcess | 2 |
| graph/stzGraphQuery.ring | stzGraphQuery | 2 |
| graph/stzKnowledgeGraph.ring | stzKnowledgeGraph | 2 |
| math/stzMathFigure.ring | stzMathFigure | 2 |
| number/stzMatrix.ring | stzMatrix | 2 |
| number/stzNumber.ring | stzNumber | 2 |
| reactive/stzReactor.ring | stzReactor | 2 |
| string/stzStringList.ring | stzStringList | 2 |
| geo/stzGeoProjection.ring | stzGeoProjection | 1 |
| graph/stzOrgChart.ring | stzOrgChartReporter | 1 |
| graph/stzOrgChart.ring | stzOrgChartSimulation | 1 |
| linguistic/stzText.ring | stzText | 1 |
| string/stzString.ring | stzString | 1 |

## stzAppServer -- appserver/stzAppServer.ring (2)

- `Use` (line 492): Leaves every request unchanged today instead of running the middleware before the routes under a path. -- The middleware is stored in the router but nothing ever reads the list, so it never runs (checked with paths /a, / and *)
- `Static` (line 504): Leaves a folder unserved today instead of serving its files under a path; a request for a file in it answers 404. -- The static routes are stored in the router but nothing ever reads the list (checked with paths /files and /)

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

## stzText -- linguistic/stzText.ring (1)

- `SummarizedAbstractively` (line 1316): Raises error R19 today when no generative model is loaded, instead of falling back to the extractive summary. -- Raises error R19 without a generative model (checked on three texts): the fallback calls Summary without its sentence count

## stzListOfPairs -- list/stzListOfPairs.ring (4)

- `ExpandedIfPairsOfNumbers` (line 1223): Raises error R14 today instead of returning the number lists that the pairs of numbers expand to. -- Raises R14 today on every call: it calls ExpandedIfPairOfNumbers, a method that exists nowhere in the loaded library
- `IsListOfSections` (line 1427): Answers TRUE for any list of pairs today, instead of TRUE only when every pair is made of two numbers. -- Answers TRUE whatever the pairs hold, text included: the loop records a failing pair in a variable that is never read, so the result stays at its start value
- `AreAnagrams` (line 1564): Raises error R14 today instead of telling whether the two items are anagrams of each other. -- Raises R14 today on every call: it reads FirstValue and SecondValue, which this class does not define
- `ToStzSetOfSections` (line 2317): Raises an error today instead of returning the pairs as a stzSetOfSections. -- Raises "You must provide a list of sections" today for valid sections such as [ [ 1, 3 ], [ 5, 8 ] ]: the stzSetOfSections constructor refuses what stzListOfSections accepts

## stzMathFigure -- math/stzMathFigure.ring (2)

- `Pin` (line 384): Raises an error today instead of holding a shape where it is during later solves: no shape of any figure kind has a free position to hold. -- the diagram refuses it because the rules fix every shape (checked on 35 sample figures of all ten kinds); an unknown path raises too
- `DragTo` (line 407): Raises an error today instead of moving a shape to a position and re-solving around it: no shape has a free centre to move. -- refused for every shape of 9 figures tried across the kinds; use MoveNoteTo to move a note

## stzMatrix -- number/stzMatrix.ring (2)

- `Diagonal1` (line 2961): Returns nothing today instead of the main diagonal, because its body is empty. -- the method exists but has no body, so it answers an empty value for every matrix; Diagonal gives the main diagonal
- `EigenVectors` (line 4433): Returns the unit eigenvectors as the columns of a matrix, in the same order as the eigenvalues. -- raises an error unless the matrix is square, for a defective matrix, and when an eigenvector is complex

## stzNumber -- number/stzNumber.ring (2)

- `SetDefaultFormat` (line 8937): Raises an unsupported-feature error today instead of setting the default number format. -- the call raises an unsupported-feature error today
- `ApplyLocale` (line 8946): Raises an unsupported-feature error today instead of applying a locale to the number. -- the call raises an unsupported-feature error today

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

## stzDataSet -- stats/stzDataSet.ring (3)

- `NonParametricCorrelation` (line 2924): Raises error R24 today instead of returning a rank correlation. -- the body reads a variable named _oOtherStats_ that this method does not receive
- `MutualInformation` (line 3144): Returns the mutual information, in bits, between this data and another data set of the same length. -- the pairs are joined with an underscore and split again, so a value containing an underscore gives a wrong result: "a_b" and "c_d" against x and y give 0 where ab and cd give 1
- `PlanSummary` (line 3983): Raises error R5 today instead of returning a text preview of a plan's steps without running it. -- the body reads the title from a variable named oPlan, which does not exist, instead of from the plan it built

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

## stzStringList -- string/stzStringList.ring (2)

- `SortBy` (line 1311): Sorts the strings in place by a numeric key computed from each one, such as its length; a text key raises. -- @item is not defined here and raises R24, and a key that is text raises R41 because keys are compared with a greater-than, so only numeric keys such as len(@string) work
- `Matches` (line 1760): TRUE if every string matches the pattern as a whole, so "a." matches ab and "a" does not; an empty list is TRUE. -- the old comment says it returns the strings that match, but it answers one verdict for the whole list

## stzTable -- table/stzTable.ring (66)

- `SectionToRange` (line 2742): Raises error today instead of returning a range of the table. -- Always raises Feature not implemented yet!
- `Range` (line 2752): Raises error today instead of returning a block of the table between two bounds. -- Always raises Feature not implemented yet!
- `FindColsByValue` (line 6507): Raises an error today instead of returning the positions of the columns equal to any of the given cell lists. -- Raises Can't create the stzList object! for a valid list of cell lists; FindColByValue works one list at a time
- `NumberOfOccurrencesOfSubValueInCells` (line 9215): Returns 0 today instead of the number of given cells that contain a text. -- Counts cells equal to the text, not cells containing it, so a text found inside a longer cell is missed
- `FindLastInCell` (line 9467): Raises error today instead of returning the place of the last occurrence of a text inside one cell. -- Raises Incorrect param type! n must be a number. because it passes :Last, which the nth-occurrence finder does not read
- `NumberOfOccurrencesInCell` (line 9526): Raises an error today instead of counting how many times a text occurs inside one cell. -- Raises Bad parameter type! for every argument tried
- `NumberOfOccurrencesOfValueInCell` (line 9572): Raises an error today instead of counting how many times a value occurs inside one cell. -- Raises Bad parameter type! for every argument tried
- `NumberOfOccurrencesOfSubValueInCell` (line 9625): Raises an error today instead of counting how many times a text occurs inside one cell. -- Raises Bad parameter type! for every argument tried
- `NumberOfOccurrenceOfCellInRow` (line 10126): Raises error R14 today instead of counting the cells in one row that equal a value. -- Raises R14 because the CS helper it calls is defined nowhere
- `FindNthInRows` (line 10432): Raises error R14 today instead of finding the nth cell in the given rows that equals a value. -- Raises R14 because RowsToNames is defined nowhere; FindNthValueInRows works
- `FindFirstInRows` (line 10531): Raises error R14 today instead of finding the first cell in the given rows that equals a value. -- Raises R14 because RowsToNames is defined nowhere
- `FindFirstValueInRows` (line 10561): Raises error R4 today instead of finding the first cell in the given rows that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindFirstSubValueInRows` (line 10591): Raises error R4 today instead of finding the first cell in the given rows that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastInRows` (line 10624): Raises error R24 today instead of finding the last cell in the given rows that equals a value. -- Raises R24 (uninitialized variable prow) because the body passes a name that is not its parameter
- `FindLastValueInRows` (line 10654): Raises error R4 today instead of finding the last cell in the given rows that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastSubValueInRows` (line 10684): Raises error R4 today instead of finding the last cell in the given rows that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `NumberOfOccurrenceOfCellInRows` (line 10764): Raises error R14 today instead of counting the cells in the given rows that equal a value. -- Raises R14 because the CS helper it calls is defined nowhere
- `FindFirstValueInCol` (line 11220): Raises error R4 today instead of finding the first cell in one column that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindFirstSubValueInCol` (line 11255): Raises error R4 today instead of finding the first cell in one column that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastValueInCol` (line 11338): Raises error R4 today instead of finding the last cell in one column that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastSubValueInCol` (line 11379): Raises error R4 today instead of finding the last cell in one column that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `NumberOfOccurrenceOfCellInCol` (line 11599): Raises error R14 today instead of counting the cells in one column that equal a value. -- Raises R14 because the CS helper it calls is defined nowhere
- `FindNthInCols` (line 12191): Raises error R14 today instead of finding the nth cell in the given columns that equals a value. -- Raises R14 because ColsToNames is defined nowhere; FindNthValueInCols works
- `FindFirstInCols` (line 12325): Raises error R14 today instead of finding the first cell in the given columns that equals a value. -- Raises R14 because ColsToNames is defined nowhere
- `FindFirstValueInCols` (line 12366): Raises error R4 today instead of finding the first cell in the given columns that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindFirstSubValueInCols` (line 12401): Raises error R4 today instead of finding the first cell in the given columns that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastInCols` (line 12445): Raises error R24 today instead of finding the last cell in the given columns that equals a value. -- Raises R24 (uninitialized variable pcol) because the body passes a name that is not its parameter
- `FindLastValueInCols` (line 12486): Raises error R4 today instead of finding the last cell in the given columns that equals a value. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `FindLastSubValueInCols` (line 12527): Raises error R4 today instead of finding the last cell in the given columns that contains a text. -- Raises R4 (stack overflow) because the CS form calls itself without end
- `NumberOfOccurrenceOfCellInCols` (line 12740): Raises error R14 today instead of counting the cells in the given columns that equal a value. -- Raises R14 because the CS helper it calls is defined nowhere
- `NumberOfOccurrenceOfCellInSection` (line 13578): Raises error R14 today instead of counting the cells between two [ column, row ] corners that equal a value. -- Raises R14 because the CS helper it calls is defined nowhere
- `ReplaceOccurrencesOfCellByValue` (line 16389): Raises error R24 today instead of replacing every cell equal to a value by another value. -- Raises R24 (uninitialized variable pnewcellvalue) because the body passes a name that is not its parameter; ReplaceCellByValue works
- `ReplaceManyCellsByValue` (line 16457): Raises error today instead of replacing the cells equal to any of several values by one value. -- Always raises Function not yet implemented!
- `ReplaceCellsByValue` (line 16468): Raises error today instead of replacing the cells equal to any of several values by one value. -- Always raises Function not yet implemented!
- `ReplaceByValueManyCells` (line 16479): Raises error today instead of replacing the cells equal to any of several values by one value. -- Always raises Function not yet implemented!
- `ReplaceByValueCells` (line 16489): Raises error today instead of replacing the cells equal to any of several values by one value. -- Always raises Function not yet implemented!
- `ReplaceManyCellsByValueByMany` (line 16545): Raises error today instead of replacing several cell values by several new values. -- Always raises Function not yet implemented!
- `ReplaceCellsByValueByMany` (line 16556): Raises error today instead of replacing several cell values by several new values. -- Always raises Function not yet implemented!
- `ReplaceByValueManyCellsByMany` (line 16566): Raises error today instead of replacing several cell values by several new values. -- Always raises Function not yet implemented!
- `ReplaceByValueCellsByMany` (line 16576): Raises error today instead of replacing several cell values by several new values. -- Always raises Function not yet implemented!
- `ReplaceAllColsByMany` (line 17294): Raises error today instead of replacing several columns by several new column lists. -- Always raises Unsupported feature in this release!
- `ReplaceAllColumsByMany` (line 17303): Raises error today instead of replacing several columns by several new column lists. -- Always raises Unsupported feature in this release!
- `ReplaceTheseColsByMany` (line 17319): Raises error today instead of replacing several columns by several new column lists. -- Always raises Unsupported feature in this release!
- `ReplaceTheseColumnsByMany` (line 17349): Raises error today instead of replacing several columns by several new column lists. -- Always raises Unsupported feature in this release!
- `ReplaceColsByMany` (line 17358): Raises error today instead of replacing several columns by several new column lists. -- Always raises Unsupported feature in this release!
- `ReplaceColumnsByMany` (line 17367): Raises error today instead of replacing several columns by several new column lists. -- Always raises Unsupported feature in this release!
- `ReplaceCellsInTheseRows` (line 17733): Raises error R24 today instead of setting every cell of the given rows to one value. -- Raises R24 (uninitialized variable panewrows) because the body checks a name that is not its parameter
- `ReplaceAllOccurrencesOfCell` (line 17812): Raises error R19 today instead of replacing every cell equal to a value by another value. -- Raises R19 because it forwards to ReplaceCell with two arguments where ReplaceCell needs a column, a row and a value; ReplaceAll works
- `ReplaceEachOccurrenceOfCell` (line 17822): Raises error R19 today instead of replacing every cell equal to a value by another value. -- Raises R19 because it forwards to ReplaceCell with two arguments where ReplaceCell needs a column, a row and a value; ReplaceAll works
- `ReplaceEveryOccurrenceOfCell` (line 17832): Raises error R19 today instead of replacing every cell equal to a value by another value. -- Raises R19 because it forwards to ReplaceCell with two arguments where ReplaceCell needs a column, a row and a value; ReplaceAll works
- `ReplaceAllOccurrences` (line 17843): Raises error R19 today instead of replacing every cell equal to a value by another value. -- Raises R19 because it forwards to ReplaceCell with two arguments where ReplaceCell needs a column, a row and a value; ReplaceAll works
- `ReplaceEachOccurrence` (line 17853): Raises error R19 today instead of replacing every cell equal to a value by another value. -- Raises R19 because it forwards to ReplaceCell with two arguments where ReplaceCell needs a column, a row and a value; ReplaceAll works
- `ReplaceEveryOccurrence` (line 17863): Raises error R19 today instead of replacing every cell equal to a value by another value. -- Raises R19 because it forwards to ReplaceCell with two arguments where ReplaceCell needs a column, a row and a value; ReplaceAll works
- `ReplaceNth` (line 17889): Raises error R19 today instead of replacing the nth, first or last cell equal to a value. -- Raises R19 because the CS form calls ReplaceCell with a position pair where ReplaceCell needs a column, a row and a value
- `ReplaceFirst` (line 17907): Raises error R19 today instead of replacing the nth, first or last cell equal to a value. -- Raises R19 because the CS form calls ReplaceCell with a position pair where ReplaceCell needs a column, a row and a value
- `ReplaceLast` (line 17925): Raises error R19 today instead of replacing the nth, first or last cell equal to a value. -- Raises R19 because the CS form calls ReplaceCell with a position pair where ReplaceCell needs a column, a row and a value
- `ReplaceInCell` (line 17953): Raises error today instead of replacing a text found inside cells. -- Always raises Function not yet implemented!
- `ReplaceInCells` (line 17976): Raises error today instead of replacing a text found inside cells. -- Always raises Function not yet implemented!
- `ReplaceInCellsByMany` (line 17999): Raises error today instead of replacing a text found inside cells. -- Always raises Function not yet implemented!
- `ReplaceInSection` (line 18018): Raises error today instead of replacing a text found inside cells. -- Always raises Function not yet implemented!
- `ReplaceInSectionByMany` (line 18036): Raises error R24 today instead of replacing several texts found inside a section. -- Raises R24 (uninitialized variable casesensitive) because the body passes a flag it does not have
- `@` (line 18422): Returns the cell-reading code of a column in a formula, or the text itself when it names no column; a list raises today. -- A column name gives the code text ( This.Cell(n, j) ); a list raises R14 because IsHasHListOrListOfStrings is defined nowhere
- `buildGrandTotal` (line 20854): Raises error R24 today instead of returning the grand-total line of the grid. -- Raises R24 because the body reads the grand totals, which are local to buildDataRows
- `TransposeWithColNames` (line 21035): Raises error R14 today instead of transposing the table while keeping the column names as a first column. -- Raises R14 because the body calls TansposeXT, a misspelling; TransposeXT works
- `ToHtml` (line 21250): Raises error R24 today instead of returning the table as an HTML table. -- Raises R24 because ToHtmlXT reads a variable named data that is never set
- `FromHtml` (line 21325): Raises error R14 today instead of replacing the table by the content of an HTML table. -- Raises R14 because HtmlToTable is defined nowhere
