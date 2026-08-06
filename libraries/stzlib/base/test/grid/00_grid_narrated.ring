load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzGrid -- a rows x columns grid with
# a movable cursor. CurrentPosition() is [col, row]. Deterministic.

Scenario("Grid dimensions")
    Given("a 5x5 grid")
    o = Grid([ 5, 5 ])
    Then("NumberOfRows is 5", o.NumberOfRows(), 5)
    Then("NumberOfColumns is 5", o.NumberOfColumns(), 5)
    Then("NumberOfCells is 25", o.NumberOfCells(), 25)
    Then("the cursor starts at [1,1]", ListEq(o.CurrentPosition(), [ 1, 1 ]), TRUE)
EndScenario()

Scenario("Relative movement")
    Given("a fresh 5x5 grid")
    o = Grid([ 5, 5 ])
    o.MoveDown()
    o.MoveDown()
    Then("two downs reach [1,3]", ListEq(o.CurrentPosition(), [ 1, 3 ]), TRUE)
    o.MoveRight()
    o.MoveRight()
    o.MoveRight()
    Then("three rights reach [4,3]", ListEq(o.CurrentPosition(), [ 4, 3 ]), TRUE)
    o.MoveUp()
    Then("one up reaches [4,2]", ListEq(o.CurrentPosition(), [ 4, 2 ]), TRUE)
    o.MoveLeft()
    Then("one left reaches [3,2]", ListEq(o.CurrentPosition(), [ 3, 2 ]), TRUE)
EndScenario()

Scenario("Movement clamps at the edges")
    Given("a 3x3 grid")
    o = Grid([ 3, 3 ])
    o.MoveUp()
    o.MoveLeft()
    Then("up/left at the top-left corner stay at [1,1]", ListEq(o.CurrentPosition(), [ 1, 1 ]), TRUE)
    o.MoveDown() o.MoveDown() o.MoveDown() o.MoveDown()
    o.MoveRight() o.MoveRight() o.MoveRight() o.MoveRight()
    Then("over-moving clamps at the bottom-right [3,3]", ListEq(o.CurrentPosition(), [ 3, 3 ]), TRUE)
EndScenario()

Scenario("Absolute movement")
    Given("a 5x5 grid")
    o = Grid([ 5, 5 ])
    o.MoveToCell(3, 4)
    Then("MoveToCell(3,4) jumps to [3,4] (regression: was a no-op)", ListEq(o.CurrentPosition(), [ 3, 4 ]), TRUE)
    o.MoveToLastNode()
    Then("MoveToLastNode reaches [5,5]", ListEq(o.CurrentPosition(), [ 5, 5 ]), TRUE)
    o.MoveToFirstNode()
    Then("MoveToFirstNode returns to [1,1]", ListEq(o.CurrentPosition(), [ 1, 1 ]), TRUE)
EndScenario()

Scenario("Every mark the grid draws with can be chosen")

	# -- WHY THIS SCENE EXISTS --
	#
	# A matrix ran all fifteen stzGrid setters against the picture, on a grid that
	# actually HAD an obstacle, a path and a current node -- because an earlier
	# probe used an empty grid, found SetObstacleChar and SetPathChar changed
	# nothing, and called them dead. There was simply nothing on the board for
	# them to draw. A knob about obstacles needs an obstacle before it can be
	# judged.
	#
	# All fifteen were alive. What was missing was a door: the grid draws with
	# FIVE characters and only four could be set. ShowNeighbors() marked
	# neighbours with a character no caller could name.

	Given("a grid with an obstacle, a path and a current node")
	oG = GridFixture()

	# the four that always worked -- their negative sibling is the default, which
	# must differ, or these would pass against a setter that did nothing
	Then("the obstacle mark is drawn", GridDraws(oG, "#", :Obstacle), TRUE)
	Then("...and is not there by default", GridDraws(GridFixture(), "#", :None), FALSE)
	Then("the path mark is drawn", GridDraws(oG, "+", :Path), TRUE)
	Then("the current mark is drawn", GridDraws(oG, "@", :Current), TRUE)
	Then("the empty mark is drawn", GridDraws(oG, "~", :Empty), TRUE)

	# THE FIFTH, which had neither setter nor reader
	Given("a grid asked to show what is next to the current node")
	Then("the neighbour mark answers its reader", NeighborCharOf("*"), "*")
	Then("...and it is drawn with", NeighborDrawn("*"), TRUE)
	Then("...while the default is not", NeighborDrawn("N") and NOT NeighborDrawnWith("*", "N"), TRUE)

	# A REJECTED VALUE IS REFUSED, not quietly swapped for a default -- the shape
	# its four siblings already had.
	Then("a non-character is refused", NeighborRefuses("too long"), TRUE)

	Given("the cell alias nobody could spell")
	# SetCurrenCell is missing the T of Current. Both spellings now reach the
	# same place; the old one stays because someone may have typed it.
	Then("the spelled-out name works", CellAliasPos(:Spelled), "[ 2, 3 ]")
	Then("...and so does the old one", CellAliasPos(:Typo), "[ 2, 3 ]")
EndScenario()

Summary()

func Grid aDims
    return new stzGrid(aDims)

func ListEq aA, aE
    if len(aA) != len(aE) return FALSE ok
    nLen = len(aA)
    for i = 1 to nLen
        if isList(aA[i]) and isList(aE[i])
            if NOT ListEq(aA[i], aE[i]) return FALSE ok
        else
            if aA[i] != aE[i] return FALSE ok
        ok
    next
    return TRUE

# -- grid mark helpers ---------------------------------------------------------

func GridFixture()
	_g_ = new stzGrid([ 5, 4 ])
	_g_.AddObstacle(2, 2)
	_g_.AddPathNode(1, 1)
	_g_.SetCurrentNode(4, 1)
	return _g_

func GridDraws(poGrid, pcChar, pWhich)
	switch pWhich
	on :Obstacle
		poGrid.SetObstacleChar(pcChar)
	on :Path
		poGrid.SetPathChar(pcChar)
	on :Current
		poGrid.SetCurrentChar(pcChar)
	on :Empty
		poGrid.SetEmptyChar(pcChar)
	on :None
		# nothing set -- the negative sibling
	off
	return StzFindFirst(pcChar, poGrid.ToString()) > 0

func NeighborCharOf(pcChar)
	_g_ = new stzGrid([ 5, 4 ])
	_g_.SetNeighborChar(pcChar)
	return _g_.NeighborChar()

# ShowNeighbors() prints, so the mark is looked for in what ShowNodes would
# draw: set the mark, then read the picture the grid renders for those nodes.
func NeighborDrawn(pcChar)
	return NeighborDrawnWith(pcChar, pcChar)

func NeighborDrawnWith(pcSet, pcLookFor)
	_g_ = new stzGrid([ 5, 4 ])
	_g_.SetCurrentNode(3, 2)
	_g_.SetNeighborChar(pcSet)
	_cOut_ = _g_.ShowNodes(_g_.Neighbors(), _g_.NeighborChar())
	return StzFindFirst(pcLookFor, _cOut_) > 0

func NeighborRefuses(pcBad)
	_g_ = new stzGrid([ 5, 4 ])
	_bRaised_ = FALSE
	try
		_g_.SetNeighborChar(pcBad)
	catch
		_bRaised_ = TRUE
	done
	return _bRaised_

func CellAliasPos(pWhich)
	_g_ = new stzGrid([ 5, 4 ])
	if pWhich = :Spelled
		_g_.SetCurrentCell(2, 3)
	else
		_g_.SetCurrenCell(2, 3)
	ok
	return "" + @@(_g_.CurrentPosition())
