# Test engine-backed table operations via Ring bridge
# Run from base/table/test/: D:\Ring126\bin\ring.exe test_engine_table.ring

load "../../stzBase.ring"

nPass = 0
nFail = 0

# --- Create table and add columns/rows ---
? "=== Engine Table: Create and populate ==="

pTable = StzEngineTableNew()
if pTable != NULL
	nPass++
	? "  Created table handle: OK"
else
	nFail++
	? "  FAIL: could not create table"
ok

# Add columns (0-based indices returned)
nNameCol = StzEngineTableAddCol(pTable, "name")
nAgeCol = StzEngineTableAddCol(pTable, "age")
nCityCol = StzEngineTableAddCol(pTable, "city")

? "  Columns added: name=" + nNameCol + " age=" + nAgeCol + " city=" + nCityCol
if StzEngineTableNumCols(pTable) = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3 columns"
ok

# Add rows
nRow0 = StzEngineTableAddRow(pTable)
nRow1 = StzEngineTableAddRow(pTable)
nRow2 = StzEngineTableAddRow(pTable)

if StzEngineTableNumRows(pTable) = 3
	nPass++
else
	nFail++
	? "  FAIL: expected 3 rows"
ok

# Set cell values
StzEngineTableSetCellString(pTable, 0, 0, "Ali")
StzEngineTableSetCellInt(pTable, 1, 0, 35)
StzEngineTableSetCellString(pTable, 2, 0, "Tunis")

StzEngineTableSetCellString(pTable, 0, 1, "Dania")
StzEngineTableSetCellInt(pTable, 1, 1, 28)
StzEngineTableSetCellString(pTable, 2, 1, "Cairo")

StzEngineTableSetCellString(pTable, 0, 2, "Han")
StzEngineTableSetCellInt(pTable, 1, 2, 42)
StzEngineTableSetCellString(pTable, 2, 2, "Beijing")

# --- Read cells ---
? ""
? "=== Engine Table: Cell access ==="

cName = StzEngineTableGetCellString(pTable, 0, 0)
? "  Cell(0,0) name: " + cName
if cName = "Ali"
	nPass++
else
	nFail++
	? "  FAIL: expected Ali"
ok

nAge = StzEngineTableGetCellInt(pTable, 1, 2)
? "  Cell(1,2) age: " + nAge
if nAge = 42
	nPass++
else
	nFail++
	? "  FAIL: expected 42"
ok

# --- Find column ---
? ""
? "=== Engine Table: Find column ==="

nFound = StzEngineTableFindCol(pTable, "age")
? "  FindCol('age'): " + nFound
if nFound = 1
	nPass++
else
	nFail++
	? "  FAIL: expected 1"
ok

nNotFound = StzEngineTableFindCol(pTable, "xyz")
? "  FindCol('xyz'): " + nNotFound
if nNotFound = -1
	nPass++
else
	nFail++
	? "  FAIL: expected -1"
ok

# --- Column name ---
? ""
? "=== Engine Table: Column name ==="

cColName = StzEngineTableColName(pTable, 0)
? "  ColName(0): " + cColName
if cColName = "name"
	nPass++
else
	nFail++
	? "  FAIL: expected name"
ok

# --- Sort ---
? ""
? "=== Engine Table: Sort ==="

StzEngineTableSortOn(pTable, 0, 1)  # sort ascending on name column
cFirst = StzEngineTableGetCellString(pTable, 0, 0)
? "  After sort on name asc, first: " + cFirst
if cFirst = "Ali"
	nPass++
else
	nFail++
	? "  FAIL: expected Ali (alphabetically first)"
ok

cLast = StzEngineTableGetCellString(pTable, 0, 2)
? "  Last: " + cLast
if cLast = "Han"
	nPass++
else
	nFail++
	? "  FAIL: expected Han"
ok

# --- Aggregation ---
? ""
? "=== Engine Table: Aggregation ==="

nSum = StzEngineTableSumCol(pTable, 1)
? "  SumCol(age): " + nSum
if nSum = 105
	nPass++
else
	nFail++
	? "  FAIL: expected 105"
ok

nAvg = StzEngineTableAvgCol(pTable, 1)
? "  AvgCol(age): " + nAvg
if nAvg = 35
	nPass++
else
	nFail++
	? "  FAIL: expected 35"
ok

nMin = StzEngineTableMinCol(pTable, 1)
? "  MinCol(age): " + nMin
if nMin = 28
	nPass++
else
	nFail++
	? "  FAIL: expected 28"
ok

nMax = StzEngineTableMaxCol(pTable, 1)
? "  MaxCol(age): " + nMax
if nMax = 42
	nPass++
else
	nFail++
	? "  FAIL: expected 42"
ok

# --- Swap and reverse ---
? ""
? "=== Engine Table: Swap and Reverse ==="

StzEngineTableSwapRows(pTable, 0, 2)
cSwapped = StzEngineTableGetCellString(pTable, 0, 0)
? "  After swap(0,2), row 0 name: " + cSwapped
if cSwapped = "Han"
	nPass++
else
	nFail++
	? "  FAIL: expected Han"
ok

StzEngineTableReverseRows(pTable)
cReversed = StzEngineTableGetCellString(pTable, 0, 0)
? "  After reverse, row 0 name: " + cReversed

# --- Clone ---
? ""
? "=== Engine Table: Clone ==="

pClone = StzEngineTableClone(pTable)
if pClone != NULL
	nCloneCols = StzEngineTableNumCols(pClone)
	nCloneRows = StzEngineTableNumRows(pClone)
	? "  Clone cols=" + nCloneCols + " rows=" + nCloneRows
	if nCloneCols = 3 and nCloneRows = 3
		nPass++
	else
		nFail++
		? "  FAIL: expected 3 cols, 3 rows"
	ok
	StzEngineTableFree(pClone)
else
	nFail++
	? "  FAIL: clone returned NULL"
ok

# --- Remove row ---
? ""
? "=== Engine Table: Remove row ==="

StzEngineTableRemoveRow(pTable, 1)
if StzEngineTableNumRows(pTable) = 2
	nPass++
	? "  After remove row 1: 2 rows"
else
	nFail++
	? "  FAIL: expected 2 rows"
ok

# --- Rename column ---
? ""
? "=== Engine Table: Rename column ==="

StzEngineTableRenameCol(pTable, 0, "fullname")
cRenamed = StzEngineTableColName(pTable, 0)
? "  After rename col 0: " + cRenamed
if cRenamed = "fullname"
	nPass++
else
	nFail++
	? "  FAIL: expected fullname"
ok

# Cleanup
StzEngineTableFree(pTable)

# --- Summary ---
? ""
? "================================="
? "  PASSED: " + nPass + "  FAILED: " + nFail
? "================================="
