# stzTable defects found while documenting (method: symptom: cause)

AreColNamesOrNumbers (+aliases): R14 when the list mixes numbers and names: IsListOfNumbersAndStrings defined nowhere
FindRow: answers [ ] even for an existing row: rows compared with = (never true between lists)
FindInCol [:SubValue,..] / NumberOfOccurrenceInCol/Row/Cell [:OfSubValue,..]: never match: StzFindFirst called haystack-first (contract is needle-first)
CellAndPosition, CellAndItsPosition: R24: body passes pnRow, parameter is pRow
Cells: R41: calls Section with :FirstCol/:LastRow corners that Section does not read
PositionsAndTheseCells: raises: reads paCells[1], paCells[2] instead of the loop item
SectionToRange, Range: always raise Feature not implemented yet!
CellsInCols: R14: IsListOfNumbersOrStrings defined nowhere
CellsInRowNAndTheirPositions, CellsAndPositionsInNthRow, CellsInNthRowAndTheirPositions: R24: body passes p, parameter is n
Extend: always raises Unsupported feature in this release!
ExtendTo: does nothing: empty body
Updated: returns its argument and ignores the table: body is only `return paNewTable`
SectionAsPositions: order/shape differs from Section for the same corners (column-by-column, middle columns start at row 1 corner)
FillSections: takes cell positions, not sections (name misleads)
RowAsPositions: no range check on row
RenanmeCol: misspelt name (works); RenameCols: R14: calls RenameCol, defined nowhere
RenameNthCol(:Last) / RenameLastCol: R2: :Last not understood
RemnameNthCols: R24: checks paColsNumbers (not the parameter) and calls RenameColN without a name
RemoveColumnsAt/RemoveColsAt/RemoveNthCols/RemoveNthColumns: R24: sorts undefined name TpacColNamesOrNumbers
RemoveAllColsExceptAt + 12 aliases (…ExceptPositions, …OtherThanPositions, …ExceptAt): R24: passes paColNumbers, parameter is panColNumbers
RemoveAllColsOtherThan/RemoveColsOtherThan/RemoveAllColumnsOtherThan/RemoveColumnsOtherThan: R14: IsListOfNumbersOrStrings defined nowhere
RemoveNthRows/RemoveRowsAt/RemoveRows(positions)/RemoveAllRowsExceptAt/RemoveRowsExceptAt/RemoveAllRowsOtherThanPositions/RemoveRowsOtherThanPositions/RemoveAllRowsExcept/RemoveAllRowsOtherThan/RemoveRowsOtherThan: R13: new stzList(U(..)).Sorted() chain
RemoveRows(rows): R14: FindTheseRows defined nowhere; RemoveRow(list of cells): R2 (FindRow answers [])
EraseSection: R19: calls SectionAsPositions() without corners
InsertCol + 13 aliases: no-op: appends then restores the copy taken before
InsertRowAtPositions/InsertRows/InsertRowsAt: R13 (U() chain)
TheseColNames: raises "Can't create the stzList object!": new stzList(..).Sorted() chain
cColNamesToNumbers: misspelt; its forwards call ColNamesToNumbers (defined nowhere) -> R14
MoveRow/MoveCol/MoveColumn: swap two positions instead of moving; MoveCol by name R24 (pnForm typo)
SwapcColNames & aliases: positions only (names R41); SwapCol & aliases: positions only
ReplaceNthColName/ReplaceColName/ReplaceColumnName: no-op: rename then restore the earlier copy
FindColsByValue: raises "Can't create the stzList object!"
FindColsExceptAt: checks IsListOfLists instead of numbers
FindNthRow: R19: too few args to FindNthRowCS
FindAll/FindCell/FindCells/FindNthCell/FindFirst/FindFirstCell/FindLast/FindLastCell/NumberOfOccurrence/NumberOfOccurrenceOfCell/Contains with a NUMBER: raise "StzFindAll takes what you are looking FOR first": list-of-lists helper passes args in the wrong order
FindSubValues: always TODO!; FindNth [:SubValue,..]: R14 IsOfOfTheseNamedParams
FindNthOccurrenceOfSubValue/FindFirstOccurrenceOfSubValue/FindLastOccurrenceOfSubValue (+ ...InCells forms): R24: body passes pSubValue, param pSubValueValue; ...OfValueInCells: R24 pValue vs pCellValue
ContainsColumns/ContainsTheseColumns: R24: pacol vs paCols
OccurrencesInCells: R24 pacells; PositionsOfValueInCells: R24 ppacells; FindValueInCells: R19/R20 always
FindNthValueInCells: ignores paCells (searches whole table)
FindFirstValueInCells/FindLastValueInCells: R14 (…CellCS undefined)
NumberOfOccurrencesOfSubValueInCells: counts cells EQUAL to the text (0 for substring)
FindLastInCell: raises n must be a number (:Last); NumberOfOccurrencesInCell/OfValueInCell/OfSubValueInCell: Bad parameter type! always
CellContains: returns empty string; CellContainsValueCS, CellContainValue: R14
Find/…In{Row,Rows,Col,Cols,Section}: FindValueIn*: R24 psubvalue; FindSubValueIn*: forwards to the whole-value finder (substring never found); FindNthValueIn/FindNthSubValueIn Row,Section: R19; FindNthIn/FindFirstIn Rows,Cols: R14 RowsToNames/ColsToNames; FindLastIn Rows/Cols: R24; FindFirst/LastValue/SubValueIn* (all scopes): R4 stack overflow (CS form calls itself); NumberOfOccurrenceOfCellIn*: R14; NumberOfOccurrenceOfValueInRow/Section: R24 pcasesensitive; CountOfValueInRowInRow/InSectionInSection: R14
FindNthInCell/FindFirstInCell: R2 when absent
SortInDescendingOn: reorders the COLUMNS (inherited list SortOnDown on the column pairs), sorts no row; column name raises
SortedDownOn (+SortedInDescendingOnColumn alias): R19: SortDownOnQ called without column
SortInDescendingOnBy: R24 _ncol_; SortDownOnColBy, SortedDownOnColBy: R24 pcol (param _nCol_)
IsSortedBy: R14 (IsSotedOnBy typo); IsSortedUpBy, IsSortedInAscendingBy: R20 extra arg; IsSortedUpOnBy + 6 aliases: R14 SortUpOnBy undefined
ReplaceEachCellOfTheseByPositionsByMany, ReplaceByPositionsEachCellOfTheseByMany: forward to ReplaceCells (single value) so every cell gets the whole list
ReplaceOccurrencesOfCellByValue, ReplaceByValueOccurrencesOfCellBy: R24 (pNewCell vs pNewCellValue)
ReplaceManyCellsByValue +3 aliases, ReplaceManyCellsByValueByMany +3, ReplaceInCell, ReplaceInCells, ReplaceInCellsByMany, ReplaceInSection, ReplaceInSectionsCS, ReplaceInSectionsByManyCS: always "Function not yet implemented!"
ReplaceInSectionByMany: R24 casesensitive
ReplaceAllColsByMany +5 aliases: always "Unsupported feature in this release!"
ReplaceColNameAndData, ReplaceColumnNamedAndData: name NOT changed (relies on the no-op ReplaceNthColName)
ReplaceCellsInTheseRows: R24 panewrows; ReplaceTheseRowsWith/By: R5 for a single value (expect list of cells)
ReplaceAllOccurrencesOfCell +5 aliases: R19 (ReplaceCell with 2 args); ReplaceNth/ReplaceFirst/ReplaceLast: R19 same cause
ReplaceAllCols/ReplaceCols/...: every column becomes a copy of the list (data lost)
ContainsRow/ContainsRows: FALSE for an existing row unless the table has as many rows as columns (length test uses NumberOfRows)
CellContainsSubValue, ContainsSubValueInCell: raise R2 when the text is absent (never FALSE); CellContains: returns "" if present, R2 if absent
