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
