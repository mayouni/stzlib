load "../../stzBase.ring"
load "../_narrated.ring"

# Guard for the stzGrid defects fixed on fix/gscl (DEFECTS.md, stzGrid):
# ShortestPath and ReconstructPath answered their end cell first; the
# MoveN* forms raised R24; MoveToNthNode raised R14; MoveToPreviousNthNode
# raised R19 and PreviousNthNode cancelled its own steps; Maze raised R19;
# AreObstacles raised R20; ShowAdjacent raised R14.

Scenario("ShortestPath runs from the start to the end")
	o = new stzGrid([ 5, 4 ])
	Then("[1,1] to [3,1] on a free row is start, middle, end",
		@@(o.ShortestPath([ 1, 1 ], [ 3, 1 ])), "[ [ 1, 1 ], [ 2, 1 ], [ 3, 1 ] ]")
	o.AddObstacle(2, 1)
	aP = o.ShortestPath([ 1, 1 ], [ 3, 1 ])
	Then("around an obstacle the first cell is the start", @@(aP[1]), "[ 1, 1 ]")
	Then("and the last cell is the end", @@(aP[len(aP)]), "[ 3, 1 ]")
	Then("the detour is five cells long", len(aP), 5)
	Then("no cell of the route is the obstacle", find(aP, [ 2, 1 ]), 0)
EndScenario()

Scenario("ReconstructPath reads a predecessor map back into start-first order")
	o = new stzGrid([ 5, 4 ])
	aMap = [ [ [ 2, 1 ], [ 1, 1 ] ], [ [ 3, 1 ], [ 2, 1 ] ], [ [ 3, 2 ], [ 3, 1 ] ] ]
	Then("four cells, start first", @@(o.ReconstructPath(aMap, 3, 2)),
		"[ [ 1, 1 ], [ 2, 1 ], [ 3, 1 ], [ 3, 2 ] ]")
	Then("an empty map answers the end cell alone", @@(o.ReconstructPath([], 4, 4)), "[ [ 4, 4 ] ]")
EndScenario()

Scenario("The MoveN* forms take the number of steps")
	o = new stzGrid([ 5, 4 ])
	o.MoveNRight(2)
	Then("MoveNRight(2) from [1,1] lands on [3,1]", @@(o.CurrentPosition()), "[ 3, 1 ]")
	o.MoveNNodesRight(1)
	Then("MoveNNodesRight(1) lands on [4,1]", @@(o.CurrentPosition()), "[ 4, 1 ]")
	o.MoveNCellsLeft(3)
	Then("MoveNCellsLeft(3) lands on [1,1]", @@(o.CurrentPosition()), "[ 1, 1 ]")
	o.MoveNCellsRight(4)
	o.MoveNLeft(1)
	Then("MoveNCellsRight(4) then MoveNLeft(1) lands on [4,1]", @@(o.CurrentPosition()), "[ 4, 1 ]")
	o.MoveNNodesLeft(2)
	Then("MoveNNodesLeft(2) lands on [2,1]", @@(o.CurrentPosition()), "[ 2, 1 ]")
	o.MoveNDown(3)
	Then("MoveNDown(3) lands on [2,4]", @@(o.CurrentPosition()), "[ 2, 4 ]")
	o.MoveNUp(1)
	Then("MoveNUp(1) lands on [2,3]", @@(o.CurrentPosition()), "[ 2, 3 ]")
	o.MoveNNodesUp(2)
	Then("MoveNNodesUp(2) lands on [2,1]", @@(o.CurrentPosition()), "[ 2, 1 ]")
	o.MoveNNodesDown(1)
	Then("MoveNNodesDown(1) lands on [2,2]", @@(o.CurrentPosition()), "[ 2, 2 ]")
	o.MoveNCellsDown(2)
	Then("MoveNCellsDown(2) lands on [2,4]", @@(o.CurrentPosition()), "[ 2, 4 ]")
	o.MoveNCellsUp(3)
	Then("MoveNCellsUp(3) lands on [2,1]", @@(o.CurrentPosition()), "[ 2, 1 ]")
	o.MoveNDown(9)
	Then("a move off the grid changes nothing", @@(o.CurrentPosition()), "[ 2, 1 ]")
EndScenario()

Scenario("MoveToNthNode and its forms move n steps the way the grid faces")
	o = new stzGrid([ 5, 4 ])
	o.SetDirection(:right)
	o.MoveToNthNode(2)
	Then("facing right, MoveToNthNode(2) from [1,1] lands on [3,1]", @@(o.CurrentPosition()), "[ 3, 1 ]")
	Then("the direction is kept", o.Direction(), "right")
	o.SetDirection(:down)
	o.MoveToNthCell(3)
	Then("facing down, MoveToNthCell(3) lands on [3,4]", @@(o.CurrentPosition()), "[ 3, 4 ]")
	o.SetDirection(:left)
	o.MoveToNthPosition(2)
	Then("facing left, MoveToNthPosition(2) lands on [1,4]", @@(o.CurrentPosition()), "[ 1, 4 ]")
EndScenario()

Scenario("PreviousNthNode and MoveToPreviousNthNode step against the direction")
	o = new stzGrid([ 5, 4 ])
	o.SetCurrentNode(4, 1)
	o.SetDirection(:right)
	Then("facing right at [4,1], one step back is [3,1]", @@(o.PreviousNthNode(1)), "[ 3, 1 ]")
	Then("two steps back is [2,1], not the current cell", @@(o.PreviousNthNode(2)), "[ 2, 1 ]")
	Then("three steps back is [1,1]", @@(o.PreviousNthNode(3)), "[ 1, 1 ]")
	Then("asking does not move the grid", @@(o.CurrentPosition()), "[ 4, 1 ]")
	Then("nor turn it", o.Direction(), "right")
	o.MoveToPreviousNthNode(2)
	Then("MoveToPreviousNthNode(2) lands on [2,1]", @@(o.CurrentPosition()), "[ 2, 1 ]")
	o.SetCurrentNode(3, 4)
	o.SetDirection(:down)
	o.MoveToNthPreviousCell(3)
	Then("facing down at [3,4], MoveToNthPreviousCell(3) lands on [3,1]", @@(o.CurrentPosition()), "[ 3, 1 ]")
	o.MoveToPreviousNthPosition(1)
	Then("a step back off the grid changes nothing", @@(o.CurrentPosition()), "[ 3, 1 ]")
EndScenario()

Scenario("AreObstacles tests each cell of the list")
	o = new stzGrid([ 5, 4 ])
	o.AddObstacle(2, 2)
	o.AddObstacle(3, 3)
	Then("both cells are obstacles", o.AreObstacles([ [ 2, 2 ], [ 3, 3 ] ]), 1)
	Then("one free cell makes it FALSE", o.AreObstacles([ [ 2, 2 ], [ 1, 1 ] ]), 0)
	Then("the order does not matter", o.AreObstacles([ [ 1, 1 ], [ 3, 3 ] ]), 0)
	Then("a list that is not made of pairs raises an error",
		Raises("o.AreObstacles([ 1, 2 ])") != "", 1)
EndScenario()

Scenario("Maze and ShowAdjacent run")
	o = new stzGrid([ 6, 5 ])
	Then("Maze raises nothing", Raises("o.Maze()"), "")
	Then("the current cell is never an obstacle", o.IsObstacle(1, 1), 0)
	Then("never more obstacles than cells", len(o.Obstacles()) < 30, 1)
	Then("ShowAdjacent raises nothing", Raises("o.ShowAdjacent()"), "")
EndScenario()

Summary()

func Raises(cCode)
	try
		eval(cCode)
		return ""
	catch
		return cCatchError
	done
