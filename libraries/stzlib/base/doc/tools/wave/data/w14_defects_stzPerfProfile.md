# Wave 14 (agent w14c) defects: stzPerfProfile, stzStopwatch, stzPerfSeries, stzFaultTree, stzPetriNet, stzFamilyTree, stzWorkerPool, stzWorkerProfile, stzCache, stzPivotTableShow (TableDisplayConfig, TableRenderer, TableConfigManager, TableThemeManager), stzUiDocument

Found by calling every root method with invented data (a pump fault tree, a small Petri net, a six-person family, worker profiles with a declared budget, pivot tables of two column dimensions, small .panel documents); each was confirmed with a second dataset or a second call. Nothing was fixed. Each is recorded as a warning in the doc block of the method. The values are exactly what the call returned.

## stzCache (common/stzCache.ring) and stzCacheStorage

| method | symptom | cause | evidence |
|---|---|---|---|
| stzCache.init, stzCacheStorage.init (every construction) | raises error R11, class not found: stzstorage; no cache can be built | stzCacheStorage builds a stzStorage, which sits in future/stzStorage.ring and is not loaded; with that file loaded the next error is R3 on the undefined TextFileCreateIfInexistant | `new stzCache("mycache", :InFile)`, `new stzCacheStorage("c", "cache", :InFile)`, a text storage type and :InMemory all raise R11; with future/stzStorage.ring loaded: R3 textfilecreateifinexistant |
| StorageType, CacheOpen, CacheFileHandler, CacheFindEntry, CacheGetCachedResult, CacheGetResultInLineNumber, CacheFileLines, CacheFileLineNumber, CacheFileNumberOfLines, AddLine (and the four forwarders of stzCacheStorage) | raise R13 Object is required | they use the storage object that init never builds | called on `new stzCache` without parentheses (init skipped): all R13, twice with different arguments |
| CacheFileColse | raises R3, undefined function TextFileColse | the name is misspelled and no TextFileClose exists either | called on `new stzCache` |
| ComposeLine | raises R3, undefined function TransformListToString | the function is not defined anywhere in the library | `ComposeLine([ "f", "1", "x" ])` and `ComposeLine([ "a" ])` |
| Content | returns the text NULL | cCacheContent is declared and never assigned | on `new stzCache` |

Also found by reading: TextFileOpen, TextFileAddLine and DatabaseConnect, called by CacheOpen and AddLine, are not defined anywhere; AddLine has an :InMemomry branch (misspelled) and two empty TODO branches.

## stzStopwatch (perf/stzStopwatch.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| JoinTrace | a header that is not a valid traceparent is accepted and leaves TraceId and SpanId empty; TraceParent then echoes the bad text and the OTLP export carries an empty traceId and spanId | the header is not validated | `JoinTrace("garbage")`, `JoinTrace("00-abc-def-01")`, `JoinTrace("")`: TraceId empty each time; TraceParent gives garbage, 00-abc-def-01, empty; ToOtelJson has "traceId":"" |

## stzFamilyTree (graph/stzFamilyTree.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| Marry | returns a union identifier that another union already has: Unions lists two unions with the same id | the identifier is built as u plus (number of unions + 1) with no check against identifiers given to AddUnion by hand | `AddUnion("u2", [ "a", "b" ])` then `Marry("c", "d")` answers u2 and Unions holds two entries with id u2; with `AddUnion("u1", ...)` first, Marry answers u2 and no clash, so only a hand-made u2 or later collides |

## stzUiDocument (gui/stzUiDocument.ring)

| method | symptom | cause | evidence |
|---|---|---|---|
| init | a document whose CHILDREN lists contain a cycle ends the Ring process with Stack Overflow (R4) in the constructor; the CHILD_CYCLE finding the court files is never readable | init walks the panel's children to build the direction map after the court, with no guard against a cycle (the court has one, the walk does not) | `DEFINE PANEL p ( CHILDREN [p] )`, and `DEFINE PANEL p ( CHILDREN [x] )` with `DEFINE BOX x ( CHILDREN [x] )`, and p, x, y with x listing y and y listing x: all three end in Stack Overflow from _mapdirection |
| TextsToPaint | the isRtl column is 0 for a text that inherits right-to-left from its box or panel, while IsRtl and DirectionOf say rtl for it | it reads the TEXT_DIRECTION the text declares itself, not the direction in force | a panel with TEXT_DIRECTION rtl and a text t: IsRtl("t") 1, TextsToPaint row 0; a box with TEXT_DIRECTION rtl holding a text inner: IsRtl 1, row 0; a text with its own TEXT_DIRECTION rtl: row 1 |
| init (path form) | a path that does not exist is parsed as the text of a document and the report says Character ':' has no place in .panel | a text is read as a file only when the file exists | `new stzUiDocument("C:/nonexistent/none.panel")`; noted, not a failure of the contract as written |

## stzPivotTableShow (table/stzPivotTableShow.ring): TableDisplayConfig, TableRenderer, TableConfigManager, TableThemeManager

| method | symptom | cause | evidence |
|---|---|---|---|
| TableDisplayConfig.MeasureContentDimensions | the width kept for a data column is that of the last data row, not the widest | the test that should keep a running maximum asks @IsHashList of a number, always false (@IsHashList(5) is 0), so the stored value is reset to 0 on every row | a column holding 20 then 2 is stored as 1; the first pivot (10, 5, 1) stored 1 for every column |
| TableDisplayConfig.CalculateLayout | the measured data-cell widths are never used: every data column is MinCellWidth grown by CellGrowthRatio plus padding | same test on the stored width | a column with 100000 in it is 8 wide, as a column with 1; with MinCellWidth 5 the width is 8 and with 8 it is 12 |
| TableDisplayConfig.GetCellWidth | answers the MinCellWidth setting for every pair of values | the same test on the computed width | answers 5 while the layout holds 8, on two pivots |
| TableDisplayConfig.GetLayoutValue | answers an empty text for every key whose value is a number or a plain list | the same test; only a hashlist is returned | TableWidth, TotalColumnWidth, LeftPadding and RowLabelWidths answer an empty text, DataColumnWidths answers its hashlist |
| TableDisplayConfig.GetDimensionGroupWidth | raises R5, Can't access the list item, Object is not list | it reads _aFinalDataWidths_, a local variable of CalculateLayout | arguments 1 and 2 |
| TableDisplayConfig.DebugLayout | the Data Column Widths part prints no line | the same hashlist test | the printed block ends after the row label widths |
| TableDisplayConfig.init | a pivot with one column dimension, or an empty one, raises R2 Array Access (Index out of range); a third column dimension is ignored | the layout code reads the second dimension unconditionally and never the third | one dimension: R2; empty pivot: R2; three dimensions: layout of 27 |
| TableRenderer.RenderTable (RenderTableHeaders, RenderTableFooter) | the printed table does not line up: the top border and the first header lines are as wide as the column groups only (two groups of 11), the data rows are wider, the separators of the headers do not sit above those of the rows, and the grand-total row is printed below the bottom border without a side border | the header widths come from the lookup that always falls back to MinCellWidth, and add no separators or padding as the rows do | two pivots, one with two row dimensions and one with one |
| TableConfigManager.* and TableThemeManager.* and TableRenderer.init | every change the manager makes lands on its own copy of the config; the caller's config is unchanged, and so is the renderer's | Ring copies an object it stores: `oConfig = oTableConfig` is a copy | after `ApplyTheme(:Simple)` the manager's oConfig has MinCellWidth 4 and plus-sign borders, the caller's has 5 and the rounded ones; after `UpdateSettings([ [ :MinCellWidth, 9 ] ])` the manager's is 9 and the caller's 5 |
| TableConfigManager.SetChangeCallback | the callback never runs | the check is `type(fOnConfigChanged) = "BLOCK"` and Ring answers STRING for a function value | silent after UpdateSettings, ImportConfig and OptimizeLayout |
| TableConfigManager.OptimizeLayout | no lasting effect | its last statement is Recalculate, which recomputes the layout and overwrites the balanced and scaled widths | the widths are the same before and after, with a MaxTableWidth of 20 against a table of 90 wide as with the default |

## Pictures looked at (a model reading the PNG, not a person)

- **stzFaultTree**, the pump tree (top Or of power and motor seized, power an And of mains and battery): the top is a rounded box, the Or gate is a shield, the And gate a round-topped gate, basic events are small circles with 0.05, 0.10 and 0.20 inside and their names beneath, lines have no arrowheads. A second tree showed a question mark in a basic event with no probability, a diamond for an undeveloped event, and a note box beside the top. Probabilities were checked by hand: 0.1 x 0.2 = 0.02, 1 - 0.98 x 0.95 = 0.069, and for a repeated sensor (0.1) under two ANDs (valve 0.2, relay 0.3) the gates give 0.0494 and the cut sets give the exact 0.044.
- **stzPetriNet**, a loop of Pool (6 tokens), Start, Busy, Stop, Idle (3 tokens), an arc of weight 2 from Idle back to Start: places are circles, transitions are black bars, arrowheads point along the flow, the weight 2 is written on the arc, Idle shows three dots, Pool shows the number 6 (five or more tokens are a number). After firing Start the picture showed Pool 5, Busy one dot, Idle one dot, which equals the marking [ pool 5, busy 1, idle 1 ]. The names stand to the right of each node on the flow line and not beneath it as the file header says; noted, not judged a failure.
- **stzFamilyTree**, six people: a person is a box with the name and a second band for the years (1930 - 2001 for Anna, 1928 for Boris, none for Carl), a union is a black dot below its two partners, children hang from the dot (Carl and Dora from Anna and Boris), and Fred hangs from the dot of Carl and Eva. No arrowheads.
- The pivot table renderer prints text; its misaligned output is quoted in the evidence above, there is no picture.
