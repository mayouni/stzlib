load "../../stzBase.ring"
load "../_narrated.ring"

# stzGridNav (base/graph/stzGridNav.ring) -- the five register rows, and everything the broken constructor was
# hiding behind them, run on grids whose answers were worked out by hand BEFORE the code was run.
#
# Cells are counted from 0, as the class and the engine count them. On the 3 by 4 grid (rows 0..2, columns 0..3):
#
#       c0 c1 c2 c3          corners (0,0) (0,3) (2,0) (2,3) touch 2 cells
#   r0   2  3  3  2          the other border cells touch 3
#   r1   3  4  4  3          the inner cells (1,1) (1,2) touch 4
#   r2   2  3  3  2
#
# A single row or column touches at most 2 cells, a 1 by 1 grid touches none. The Manhattan distance of two
# cells is |row apart| + |column apart|: (0,0) to (2,3) is 5, (1,2) to (0,0) is 3.
#
# What each row was: the constructor handed the engine (name, rows, cols) where it takes (rows, cols), so no
# object could be built at all; the three queries and the distance sat behind it; the distance sent 3 arguments
# to a 4-argument engine function. Behind them: the class directions (0 up, 1 down, 2 left, 3 right) are not
# the engine's (0 up, 1 right, 2 down, 3 left); SetPosition never checked the bounds; ResetPosition cleared the
# engine grid; and the engine holds ONE grid for every object. Run from inside this folder. ASCII only.

Scenario("Build a named grid (init)")
	Given("new stzGridNav(g, 3, 4) and new stzGridNav(g5, 5, 5)")
	g = new stzGridNav("g", 3, 4)
	g5 = new stzGridNav("g5", 5, 5)
	Then("the 3 by 4 grid starts on row 0, column 0", Pos(g), "0,0")
	Then("the 5 by 5 grid starts on row 0, column 0", Pos(g5), "0,0")
	Then("the 3 by 4 grid keeps its name", g.Name(), "g")
	Then("the 5 by 5 grid keeps its own name", g5.Name(), "g5")
	Then("the name of one grid is not the name of the other", Mentions(g.Name(), "g5"), 0)
	Then("the last cell of the 3 by 4 grid exists", g.IsValidPosition(2, 3), 1)
	Then("one past it does not", g.IsValidPosition(3, 4), 0)
	g1 = StzGridNavQ("q", 2, 2)
	Then("the Q function builds the same grid", g1.IsValidPosition(1, 1), 1)
	Then("IsStzGridNav tells the object", IsStzGridNav(g1), 1)
	Then("IsStzGridNav refuses a number", IsStzGridNav(5), 0)

	Given("sizes and names the class must refuse")
	cE = ""
	try
		x = new stzGridNav("z", 0, 4)
	catch
		cE = cCatchError
	done
	Then("0 rows raises and names nRows", Mentions(cE, "nRows must be a positive whole number"), 1)
	cE = ""
	try
		x = new stzGridNav("z", 3, 0)
	catch
		cE = cCatchError
	done
	Then("0 columns raises and names nCols", Mentions(cE, "nCols must be a positive whole number"), 1)
	cE = ""
	try
		x = new stzGridNav("z", -2, 4)
	catch
		cE = cCatchError
	done
	Then("a negative number of rows raises", Mentions(cE, "nRows must be a positive whole number"), 1)
	cE = ""
	try
		x = new stzGridNav("z", 2.5, 4)
	catch
		cE = cCatchError
	done
	Then("a half row raises", Mentions(cE, "nRows must be a positive whole number"), 1)
	cE = ""
	try
		x = new stzGridNav("z", "3", 4)
	catch
		cE = cCatchError
	done
	Then("a text for the rows raises", Mentions(cE, "nRows must be a positive whole number"), 1)
	cE = ""
	try
		x = new stzGridNav("z", 3, [ 4 ])
	catch
		cE = cCatchError
	done
	Then("a list for the columns raises", Mentions(cE, "nCols must be a positive whole number"), 1)
	cE = ""
	try
		x = new stzGridNav("z", 2147483648, 4)
	catch
		cE = cCatchError
	done
	Then("one more row than the engine can read raises, and the process lives",
		Mentions(cE, "nRows must be a positive whole number"), 1)
	cE = ""
	try
		x = new stzGridNav("z", 3, 1000000000000000000000000000000)
	catch
		cE = cCatchError
	done
	Then("an enormous column count raises, and the process lives",
		Mentions(cE, "nCols must be a positive whole number"), 1)
	cE = ""
	try
		x = new stzGridNav("", 3, 4)
	catch
		cE = cCatchError
	done
	Then("an empty name raises", Mentions(cE, "cName must be a non-empty string"), 1)
	cE = ""
	try
		x = new stzGridNav(7, 3, 4)
	catch
		cE = cCatchError
	done
	Then("a number as the name raises", Mentions(cE, "cName must be a non-empty string"), 1)
	cE = ""
	try
		x = new stzGridNav([ "a" ], 3, 4)
	catch
		cE = cCatchError
	done
	Then("a list as the name raises", Mentions(cE, "cName must be a non-empty string"), 1)

	Given("the largest grid the engine can read")
	gB = new stzGridNav("big", 2147483647, 2147483647)
	gB.SetPosition(2147483646, 2147483646)
	Then("its last cell is the corner: 2 neighbours", gB.NeighborCount(), 2)
	Then("one past its last row is no cell", gB.IsValidPosition(2147483647, 0), 0)
	cE = ""
	try
		gB.MoveDown()
	catch
		cE = cCatchError
	done
	Then("a move down from its last row raises", Mentions(cE, "Would go out of bounds"), 1)
EndScenario()

Scenario("Neighbour counts (NeighborCount)")
	Given("the 3 by 4 grid, at its four corners")
	g = new stzGridNav("g", 3, 4)
	Then("the start (0,0) is a corner: 2", g.NeighborCount(), 2)
	g.SetPosition(0, 3)
	Then("(0,3) is a corner: 2", g.NeighborCount(), 2)
	g.SetPosition(2, 0)
	Then("(2,0) is a corner: 2", g.NeighborCount(), 2)
	g.SetPosition(2, 3)
	Then("(2,3) is a corner: 2", g.NeighborCount(), 2)

	Given("the 3 by 4 grid, on its edges")
	g.SetPosition(0, 1)
	Then("(0,1) is on the top edge: 3", g.NeighborCount(), 3)
	g.SetPosition(1, 0)
	Then("(1,0) is on the left edge: 3", g.NeighborCount(), 3)
	g.SetPosition(1, 3)
	Then("(1,3) is on the right edge: 3", g.NeighborCount(), 3)
	g.SetPosition(2, 2)
	Then("(2,2) is on the bottom edge: 3", g.NeighborCount(), 3)

	Given("the 3 by 4 grid, inside")
	g.SetPosition(1, 1)
	Then("(1,1) is inside: 4", g.NeighborCount(), 4)
	g.SetPosition(1, 2)
	Then("(1,2) is inside: 4", g.NeighborCount(), 4)
	Then("an inside cell has more neighbours than a corner", g.NeighborCount() > 2, 1)
	Then("NumberOfNeighbors is the same call", g.NumberOfNeighbors(), g.NeighborCount())

	Given("the 5 by 5 grid, one cell of each kind")
	g5 = new stzGridNav("g5", 5, 5)
	Then("(0,0) corner: 2", g5.NeighborCount(), 2)
	g5.SetPosition(4, 4)
	Then("(4,4) corner: 2", g5.NeighborCount(), 2)
	g5.SetPosition(0, 2)
	Then("(0,2) edge: 3", g5.NeighborCount(), 3)
	g5.SetPosition(2, 2)
	Then("(2,2) centre: 4", g5.NeighborCount(), 4)

	Given("every cell of both grids against a count worked out in Ring")
	Then("the 3 by 4 grid: no cell disagrees", CountWrongNeighbors(3, 4), 0)
	Then("the 5 by 5 grid: no cell disagrees", CountWrongNeighbors(5, 5), 0)
	Then("a 2 by 7 grid: no cell disagrees", CountWrongNeighbors(2, 7), 0)

	Given("grids with no room")
	g11 = new stzGridNav("one", 1, 1)
	Then("a 1 by 1 grid has no neighbour", g11.NeighborCount(), 0)
	g15 = new stzGridNav("row", 1, 5)
	Then("a single row: the first cell has 1", g15.NeighborCount(), 1)
	g15.SetPosition(0, 2)
	Then("a single row: a middle cell has 2", g15.NeighborCount(), 2)
	g15.SetPosition(0, 4)
	Then("a single row: the last cell has 1", g15.NeighborCount(), 1)
	g51 = new stzGridNav("col", 5, 1)
	g51.SetPosition(2, 0)
	Then("a single column: a middle cell has 2", g51.NeighborCount(), 2)
	g51.SetPosition(4, 0)
	Then("a single column: the last cell has 1", g51.NeighborCount(), 1)
	Then("a single row never gives 3 or 4", CountWrongNeighbors(1, 9), 0)
EndScenario()

Scenario("Where the current cell is (CurrentRow, CurrentCol)")
	Given("the 3 by 4 grid after SetPosition(2, 3)")
	g = new stzGridNav("g", 3, 4)
	g.SetPosition(2, 3)
	Then("the row is 2", g.CurrentRow(), 2)
	Then("the column is 3", g.CurrentCol(), 3)
	Then("Row is the same call", g.Row(), 2)
	Then("Col is the same call", g.Col(), 3)
	Then("the row is not the column", g.CurrentRow() != g.CurrentCol(), 1)
	Given("a second position")
	g.SetPositionQ(1, 2).SetPositionQ(0, 1)
	Then("the chained SetPositionQ left the last position", Pos(g), "0,1")
EndScenario()

Scenario("Moves (MoveUp, MoveDown, MoveLeft, MoveRight, MoveDirection)")
	Given("the 3 by 4 grid, starting on (0,0)")
	g = new stzGridNav("g", 3, 4)
	g.MoveDown()
	Then("down adds a row", Pos(g), "1,0")
	g.MoveRight()
	Then("right adds a column", Pos(g), "1,1")
	g.MoveRight()
	Then("right again", Pos(g), "1,2")
	g.MoveUp()
	Then("up takes a row away", Pos(g), "0,2")
	g.MoveLeft()
	Then("left takes a column away", Pos(g), "0,1")
	Then("down is not right: the column did not change in a down move",
		g.MoveDownQ().CurrentCol(), 1)
	Then("right is not down: the row did not change in a right move",
		g.MoveRightQ().CurrentRow(), 1)

	Given("MoveDirection with the class codes, from (1,2)")
	g.SetPosition(1, 2)
	g.MoveDirection(0)
	Then("0 is up", Pos(g), "0,2")
	g.MoveDirection(1)
	Then("1 is down", Pos(g), "1,2")
	g.MoveDirection(2)
	Then("2 is left", Pos(g), "1,1")
	g.MoveDirection(3)
	Then("3 is right", Pos(g), "1,2")
	g.MoveDirection($STZ_GRID_DOWN)
	Then("the class constant for down moves down", Pos(g), "2,2")
	g.MoveDirection($STZ_GRID_LEFT)
	Then("the class constant for left moves left", Pos(g), "2,1")
	g.MoveDirection($STZ_GRID_UP)
	Then("the class constant for up moves up", Pos(g), "1,1")
	g.MoveDirection($STZ_GRID_RIGHT)
	Then("the class constant for right moves right", Pos(g), "1,2")

	Given("a direction that is none of the four")
	cE = ""
	try
		g.MoveDirection(4)
	catch
		cE = cCatchError
	done
	Then("4 raises", Mentions(cE, "nDirection must be 0-3"), 1)
	Then("and the position stays", Pos(g), "1,2")
	cE = ""
	try
		g.MoveDirection(-1)
	catch
		cE = cCatchError
	done
	Then("-1 raises", Mentions(cE, "nDirection must be 0-3"), 1)
	cE = ""
	try
		g.MoveDirection(1.5)
	catch
		cE = cCatchError
	done
	Then("1.5 raises", Mentions(cE, "nDirection must be 0-3"), 1)
	cE = ""
	try
		g.MoveDirection("up")
	catch
		cE = cCatchError
	done
	Then("a text raises", Mentions(cE, "nDirection must be 0-3"), 1)
	cE = ""
	try
		g.MoveDirection(1000000000000000000000000000000)
	catch
		cE = cCatchError
	done
	Then("an enormous number raises, and the process lives", Mentions(cE, "nDirection must be 0-3"), 1)

	Given("the Q forms")
	g.SetPosition(0, 0)
	g.MoveDownQ().MoveDownQ().MoveRightQ().MoveDirectionQ(3).MoveUpQ().MoveLeftQ()
	Then("a chain of moves lands on (1,1)", Pos(g), "1,1")
EndScenario()

Scenario("A move off the grid is refused and leaves the cell where it was")
	Given("the 3 by 4 grid on (0,0)")
	g = new stzGridNav("g", 3, 4)
	cE = ""
	try
		g.MoveUp()
	catch
		cE = cCatchError
	done
	Then("up from row 0 raises", Mentions(cE, "Can't move! Would go out of bounds"), 1)
	Then("the cell is still (0,0)", Pos(g), "0,0")
	cE = ""
	try
		g.MoveLeft()
	catch
		cE = cCatchError
	done
	Then("left from column 0 raises", Mentions(cE, "Would go out of bounds"), 1)
	Then("the cell is still (0,0)", Pos(g), "0,0")

	Given("the far corner (2,3)")
	g.SetPosition(2, 3)
	cE = ""
	try
		g.MoveDown()
	catch
		cE = cCatchError
	done
	Then("down from the last row raises", Mentions(cE, "Would go out of bounds"), 1)
	cE = ""
	try
		g.MoveRight()
	catch
		cE = cCatchError
	done
	Then("right from the last column raises", Mentions(cE, "Would go out of bounds"), 1)
	Then("the cell is still (2,3)", Pos(g), "2,3")
	g.MoveUp()
	Then("up from there is fine", Pos(g), "1,3")
	g.MoveLeft()
	Then("so is left", Pos(g), "1,2")

	Given("a walk of 11 steps over the whole 3 by 4 grid, then one more")
	g.SetPosition(0, 0)
	for i = 1 to 3
		g.MoveRight()
	next
	for i = 1 to 2
		g.MoveDown()
	next
	Then("5 steps reached the far corner", Pos(g), "2,3")
	nRaised = 0
	for i = 1 to 3
		try
			g.MoveRight()
		catch
			nRaised++
		done
	next
	Then("three more steps right all raised", nRaised, 3)
	Then("and the cell never moved", Pos(g), "2,3")

	Given("a 1 by 1 grid")
	g11 = new stzGridNav("one", 1, 1)
	nRaised = 0
	for d = 0 to 3
		try
			g11.MoveDirection(d)
		catch
			nRaised++
		done
	next
	Then("all four directions raise", nRaised, 4)
	Then("the cell is still (0,0)", Pos(g11), "0,0")
EndScenario()

Scenario("Validity and SetPosition (IsValidPosition, SetPosition)")
	Given("the 3 by 4 grid")
	g = new stzGridNav("g", 3, 4)
	Then("(0,0) is a cell", g.IsValidPosition(0, 0), 1)
	Then("(2,3) is a cell", g.IsValidPosition(2, 3), 1)
	Then("(1,2) is a cell", g.IsValidPosition(1, 2), 1)
	Then("row 3 is not", g.IsValidPosition(3, 0), 0)
	Then("column 4 is not", g.IsValidPosition(0, 4), 0)
	Then("row -1 is not", g.IsValidPosition(-1, 0), 0)
	Then("column -1 is not", g.IsValidPosition(0, -1), 0)
	Then("(1.5, 1) is not a cell", g.IsValidPosition(1.5, 1), 0)
	Then("an enormous row is not a cell, and the process lives",
		g.IsValidPosition(1000000000000000000000000000000, 1), 0)
	Then("the 3 by 4 grid does not have the cell (3,4) that a 5 by 5 grid has",
		g.IsValidPosition(3, 4), 0)
	cE = ""
	try
		x = g.IsValidPosition("a", 1)
	catch
		cE = cCatchError
	done
	Then("a text for the row raises", Mentions(cE, "nRow and nCol must be numbers"), 1)

	Given("SetPosition to a cell in the grid and to cells outside it")
	g.SetPosition(2, 1)
	Then("(2,1) is taken", Pos(g), "2,1")
	cE = ""
	try
		g.SetPosition(3, 1)
	catch
		cE = cCatchError
	done
	Then("row 3 raises Out of bounds", Mentions(cE, "Can't set position! Out of bounds"), 1)
	Then("the cell stayed on (2,1)", Pos(g), "2,1")
	cE = ""
	try
		g.SetPosition(0, 4)
	catch
		cE = cCatchError
	done
	Then("column 4 raises Out of bounds", Mentions(cE, "Out of bounds"), 1)
	cE = ""
	try
		g.SetPosition(-1, 0)
	catch
		cE = cCatchError
	done
	Then("row -1 raises Out of bounds", Mentions(cE, "Out of bounds"), 1)
	cE = ""
	try
		g.SetPosition(1.5, 1)
	catch
		cE = cCatchError
	done
	Then("a half row raises its own error", Mentions(cE, "must be whole numbers"), 1)
	cE = ""
	try
		g.SetPosition("1", 1)
	catch
		cE = cCatchError
	done
	Then("a text raises", Mentions(cE, "must be numbers"), 1)
	cE = ""
	try
		g.SetPosition(1, 1000000000000000000000000000000)
	catch
		cE = cCatchError
	done
	Then("an enormous column raises Out of bounds, and the process lives", Mentions(cE, "Out of bounds"), 1)
	Then("after all of them the cell is still (2,1)", Pos(g), "2,1")
EndScenario()

Scenario("Manhattan distance from the current cell (DistanceTo)")
	Given("the 3 by 4 grid on (0,0)")
	g = new stzGridNav("g", 3, 4)
	Then("to (2,3) it is 5", g.DistanceTo(2, 3), 5)
	Then("to (0,0), itself, it is 0", g.DistanceTo(0, 0), 0)
	Then("to (0,3) it is 3", g.DistanceTo(0, 3), 3)
	Then("to (2,0) it is 2", g.DistanceTo(2, 0), 2)

	Given("the same grid on (1,2): the distance is from the current cell, not from (0,0)")
	g.SetPosition(1, 2)
	Then("to (0,0) it is 3", g.DistanceTo(0, 0), 3)
	Then("to (1,2), itself, it is 0", g.DistanceTo(1, 2), 0)
	Then("to (2,3) it is 2", g.DistanceTo(2, 3), 2)
	Then("to (1,0) it is 2: a row apart of 0 and 2 columns", g.DistanceTo(1, 0), 2)
	Then("the distance to (2,3) differs from the one to (0,0)", g.DistanceTo(2, 3) != g.DistanceTo(0, 0), 1)

	Given("the distance is symmetric")
	g.SetPosition(2, 3)
	nBack = g.DistanceTo(0, 0)
	g.SetPosition(0, 0)
	nThere = g.DistanceTo(2, 3)
	Then("(2,3) to (0,0) and (0,0) to (2,3) agree", nBack, nThere)
	Then("both are 5", nThere, 5)

	Given("the 5 by 5 grid")
	g5 = new stzGridNav("g5", 5, 5)
	Then("from (0,0) to (4,4) it is 8", g5.DistanceTo(4, 4), 8)
	g5.SetPosition(2, 2)
	Then("from (2,2) to (4,4) it is 4", g5.DistanceTo(4, 4), 4)
	Then("from (2,2) to (0,4) it is 4", g5.DistanceTo(0, 4), 4)

	Given("a target outside the grid")
	g.SetPosition(1, 1)
	cE = ""
	try
		x = g.DistanceTo(3, 0)
	catch
		cE = cCatchError
	done
	Then("row 3 of the 3 by 4 grid raises", Mentions(cE, "The target cell is outside the grid"), 1)
	cE = ""
	try
		x = g.DistanceTo(0, 4)
	catch
		cE = cCatchError
	done
	Then("column 4 raises", Mentions(cE, "outside the grid"), 1)
	cE = ""
	try
		x = g.DistanceTo(-1, 0)
	catch
		cE = cCatchError
	done
	Then("row -1 raises", Mentions(cE, "outside the grid"), 1)
	cE = ""
	try
		x = g.DistanceTo("a", 0)
	catch
		cE = cCatchError
	done
	Then("a text raises its own error", Mentions(cE, "must be numbers"), 1)
	cE = ""
	try
		x = g.DistanceTo(1000000000000000000000000000000, 0)
	catch
		cE = cCatchError
	done
	Then("an enormous target raises, and the process lives", Mentions(cE, "outside the grid"), 1)
	Then("the cell did not move while measuring", Pos(g), "1,1")
	Then("a cell of the same grid is still measured after the errors", g.DistanceTo(2, 3), 3)
EndScenario()

Scenario("Putting the cell back (ResetPosition)")
	Given("the 3 by 4 grid after a walk")
	g = new stzGridNav("g", 3, 4)
	g.SetPosition(2, 3)
	g.ResetPosition()
	Then("the cell is on (0,0)", Pos(g), "0,0")
	Then("the grid kept its size: (2,3) is still a cell", g.IsValidPosition(2, 3), 1)
	Then("the corner count is back to 2", g.NeighborCount(), 2)
	Then("a move down works", g.MoveDownQ().CurrentRow(), 1)
	Then("the distance still works: (1,0) to (2,3) is 4", g.DistanceTo(2, 3), 3 + 1)
	g.SetPosition(1, 1)
	Then("ResetPositionQ returns the object, on (0,0)", Pos(g.ResetPositionQ()), "0,0")
EndScenario()

Scenario("Several grids side by side: the engine holds one, the objects hold their own")
	Given("a 3 by 4 grid and a 5 by 5 grid, driven in turn")
	a = new stzGridNav("a", 3, 4)
	b = new stzGridNav("b", 5, 5)
	a.SetPosition(2, 3)
	b.SetPosition(4, 4)
	Then("a kept its cell after b was built and moved", Pos(a), "2,3")
	Then("b kept its own", Pos(b), "4,4")
	Then("a still has 3 rows: row 3 is no cell of a", a.IsValidPosition(3, 0), 0)
	Then("b still has 5 rows: row 4 is a cell of b", b.IsValidPosition(4, 0), 1)
	a.MoveUp()
	Then("a moved", Pos(a), "1,3")
	Then("b did not", Pos(b), "4,4")
	Then("a corner count of b, after a was used: 2", b.NeighborCount(), 2)
	Then("an edge count of a, after b was used: 3", a.NeighborCount(), 3)
	Then("a distance of a, after b was used", a.DistanceTo(0, 0), 4)
	Then("a distance of b, after a was used", b.DistanceTo(0, 0), 8)

	Given("a copy of a grid")
	c = a
	c.MoveLeft()
	Then("the copy moved", Pos(c), "1,2")
	Then("the original did not", Pos(a), "1,3")
	Then("the copy keeps the name", c.Name(), "a")
EndScenario()

Scenario("The examples of the class block")
	Given("o1 = new stzGridNav(g, 3, 4)")
	o1 = new stzGridNav("g", 3, 4)
	Then("CurrentRow is 0", o1.CurrentRow(), 0)
	o1.MoveDown()
	o1.MoveRight()
	Then("after a move down and a move right: [ 1, 1 ]", Pos(o1), "1,1")
	Then("NeighborCount is 4", o1.NeighborCount(), 4)
	Then("DistanceTo(2, 3) is 3", o1.DistanceTo(2, 3), 3)
EndScenario()

Summary()

func Pos(o)
	return "" + o.CurrentRow() + "," + o.CurrentCol()

func Mentions(cText, cPart)
	if StzFindFirst(cPart, cText) > 0
		return 1
	ok
	return 0

# the neighbour count worked out in Ring, independently of the engine
func WantedNeighbors(nR, nC, nRows, nCols)
	n = 0
	if nR > 0
		n++
	ok
	if nR < nRows - 1
		n++
	ok
	if nC > 0
		n++
	ok
	if nC < nCols - 1
		n++
	ok
	return n

func CountWrongNeighbors(nRows, nCols)
	o = new stzGridNav("sweep", nRows, nCols)
	nWrong = 0
	for r = 0 to nRows - 1
		for c = 0 to nCols - 1
			o.SetPosition(r, c)
			if o.NeighborCount() != WantedNeighbors(r, c, nRows, nCols)
				nWrong++
			ok
		next
	next
	return nWrong
