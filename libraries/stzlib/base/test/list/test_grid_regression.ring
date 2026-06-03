# Integration regression suite for stzGrid.
# Covers init, Size / SizeXT / NumberOfColumns / NumberOfRows,
# CurrentPosition (Position/CurrentNode/CurrentCell aliases),
# IsValidPosition, Direction get/set with valid+invalid input,
# SetCurrentNode, movement (MoveToNode), obstacles
# (AddObstacle / IsObstacle / RemoveObstacle / ClearObstacles).
#
# Run from base/list/test/.

load "../../stzBase.ring"

nPsd = 0
nFld = 0
nTtl = 0

? "=== stzGrid integration regression ==="

# ------------------------------------------------------------
# Construction + size queries
# ------------------------------------------------------------
? ""
? "--- Construction ---"

oG = new stzGrid([ 5, 4 ])   # 5 cols, 4 rows
chk("NumberOfColumns = 5",          oG.NumberOfColumns() = 5)
chk("NumberOfRows = 4",             oG.NumberOfRows() = 4)
chk("Size = 20",                    oG.Size() = 20)
chk("NumberOfNodes alias = 20",     oG.NumberOfNodes() = 20)
chk("NumberOfCells alias = 20",     oG.NumberOfCells() = 20)

aSz = oG.SizeXT()
chk("SizeXT = [5, 4]",              isList(aSz) and aSz[1] = 5 and aSz[2] = 4)

# ------------------------------------------------------------
# Initial position
# ------------------------------------------------------------
? ""
? "--- Initial position ---"

aPos = oG.CurrentPosition()
chk("Initial pos = [1, 1]",         aPos[1] = 1 and aPos[2] = 1)
chk("CurrentColumn = 1",            oG.CurrentColumn() = 1)
chk("CurrentRow = 1",               oG.CurrentRow() = 1)

# Aliases
chk("Position alias",               oG.Position()[1] = 1)
chk("CurrentNode alias",            oG.CurrentNode()[1] = 1)
chk("CurrentCell alias",            oG.CurrentCell()[1] = 1)

# ------------------------------------------------------------
# IsValidPosition
# ------------------------------------------------------------
? ""
? "--- IsValidPosition ---"

chk("(1,1) valid",                  oG.IsValidPosition(1, 1) = TRUE)
chk("(5,4) valid (corner)",         oG.IsValidPosition(5, 4) = TRUE)
chk("(0,1) invalid",                oG.IsValidPosition(0, 1) = FALSE)
chk("(6,1) invalid (out cols)",     oG.IsValidPosition(6, 1) = FALSE)
chk("(1,5) invalid (out rows)",     oG.IsValidPosition(1, 5) = FALSE)
chk("(-1,2) invalid",               oG.IsValidPosition(-1, 2) = FALSE)

# ------------------------------------------------------------
# SetCurrentNode + MoveToNode
# ------------------------------------------------------------
? ""
? "--- Set / Move ---"

oG.SetCurrentNode(3, 2)
chk("After SetCurrent: col = 3",    oG.CurrentColumn() = 3)
chk("After SetCurrent: row = 2",    oG.CurrentRow() = 2)

oG.MoveToNode(5, 4)
chk("MoveTo (5,4): col = 5",        oG.CurrentColumn() = 5)
chk("MoveTo (5,4): row = 4",        oG.CurrentRow() = 4)

# ------------------------------------------------------------
# Direction
# ------------------------------------------------------------
? ""
? "--- Direction ---"

oG.SetDirection(:right)
chk("Direction = :right",           oG.Direction() = :right)

oG.SetDirection(:down)
chk("Direction = :down",            oG.Direction() = :down)

# Invalid direction should raise
bRaised = 0
try
	oG.SetDirection(:diagonal)
catch
	bRaised = 1
done
chk("Invalid direction raises",     bRaised = 1)

# ------------------------------------------------------------
# Obstacles
# ------------------------------------------------------------
? ""
? "--- Obstacles ---"

oOb = new stzGrid([ 5, 5 ])
oOb.AddObstacle(3, 3)
chk("AddObstacle then IsObstacle",  oOb.IsObstacle(3, 3) = TRUE)
chk("Non-obstacle cell",            oOb.IsObstacle(1, 1) = FALSE)

# Adding same obstacle twice should be idempotent (no dupes)
oOb.AddObstacle(3, 3)
chk("Idempotent AddObstacle",       len(oOb.Obstacles()) = 1)

oOb.AddObstacles([ [1, 1], [2, 2] ])
chk("AddObstacles bulk",            len(oOb.Obstacles()) = 3)

oOb.RemoveObstacle(2, 2)
chk("RemoveObstacle works",         oOb.IsObstacle(2, 2) = FALSE)
chk("Other obstacles preserved",    oOb.IsObstacle(3, 3) = TRUE and oOb.IsObstacle(1, 1) = TRUE)

oOb.ClearObstacles()
chk("ClearObstacles empties list",  len(oOb.Obstacles()) = 0)

# Movement should not enter obstacle (per MoveToNode body)
oM = new stzGrid([ 5, 5 ])
oM.AddObstacle(2, 2)
oM.MoveToNode(2, 2)   # tries to move onto obstacle
chk("Cannot move onto obstacle",    oM.CurrentColumn() = 1 and oM.CurrentRow() = 1)

# ------------------------------------------------------------
# Edges
# ------------------------------------------------------------
? ""
? "--- Edges ---"

# 1x1 grid
oOne = new stzGrid([ 1, 1 ])
chk("1x1 Size = 1",                 oOne.Size() = 1)
chk("1x1 (1,1) valid",              oOne.IsValidPosition(1, 1) = TRUE)
chk("1x1 (2,1) invalid",            oOne.IsValidPosition(2, 1) = FALSE)

# Long rectangle
oRect = new stzGrid([ 100, 1 ])
chk("100x1 Size = 100",             oRect.Size() = 100)
chk("100x1 (100,1) valid",          oRect.IsValidPosition(100, 1) = TRUE)
chk("100x1 (50,1) valid",           oRect.IsValidPosition(50, 1) = TRUE)

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
? ""
? "=========================="
? "Total:  " + nTtl
? "Passed: " + nPsd
? "Failed: " + nFld
if nFld = 0
	? "ALL stzGrid CHECKS PASSED!"
else
	? "SOME stzGrid CHECKS FAILED!"
ok

func chk(cLabel, bCond)
	nTtl++
	if bCond
		nPsd++
	else
		nFld++
		? "  FAIL: " + cLabel
	ok
