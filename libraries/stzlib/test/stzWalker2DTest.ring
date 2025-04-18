load "../max/stzmax.ring"


# ===============================
# Basic initialization tests
# ===============================

/*--- Standard initialization with individual coordinates

pr()

w = new stzWalker2D([1, 1], [5, 5], 2)

? @@(w.StartPosition())
#--> [ 1, 1 ]

? @@(w.EndPosition())
#--> [ 5, 5 ]

? w.Steps()
#--> 2

? @@(w.WalkablePositions())
#--> [
#	[ 1, 1 ], [ 1, 3 ], [ 3, 1 ],
#	[ 1, 5 ], [ 3, 3 ], [ 5, 1 ],
#	[ 3, 5 ], [ 5, 3 ], [ 5, 5 ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Initialize with pairs for coordinates

pr()

w = new stzWalker2D([2, 3], [6, 8], 2)

? @@(w.StartPosition())
#--> [ 2, 3 ]

? @@(w.EndPosition())
#--> [ 6, 8 ]

? w.Steps()
#--> 2

? @@(w.WalkablePositions())
#--> [
#	[ 2, 3 ], [ 2, 5 ], [ 4, 3 ], [ 2, 7 ], [ 4, 5 ],
#	[ 6, 3 ], [ 4, 7 ], [ 6, 5 ], [ 6, 7 ], [ 6, 8 ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Initialize with different X and Y steps

pr()

w = new stzWalker2D([1, 1], [5, 8], [2, 3])

? @@(w.StartPosition())
#--> [ 1, 1 ]

? @@(w.EndPosition())
#--> [ 5, 8 ]

? @@( w.Steps() )
#--> [ 2, 3 ]

? @@(w.WalkablePositions())
#--> [
#	[ 1, 1 ], [ 3, 1 ], [ 1, 4 ], [ 5, 1 ], [ 3, 4 ],
#	[ 1, 7 ], [ 5, 4 ], [ 3, 7 ], [ 5, 7 ], [ 5, 8 ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Initialize with variable steps

pr()

w = new stzWalker2D([1, 1], [9, 9], [[1, 2], [3, 1], [2, 2]])

? @@(w.StartPosition())
#--> [ 1, 1 ]

? @@(w.EndPosition())
#--> [ 9, 9 ]

? @@(w.Steps())
#--> [ [ 1, 2 ], [ 3, 1 ], [ 2, 2 ] ]

? w.IsVariantSteps()
#--> TRUE

? @@(w.Walkables())
#--> [ [ 1, 1 ], [ 2, 3 ], [ 5, 4 ], [ 7, 6 ], [ 8, 8 ], [ 9, 9 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Initialize with factory function Wk2D()

pr()

w = Wk2D([1, 1], [3, 3], 1)

? @@(w.StartPosition())
#--> [ 1, 1 ]

? @@(w.EndPosition())
#--> [ 3, 3 ]

? @@(w.Steps())
#--> 1

? @@(w.Walkables())
#--> [
#	[ 1, 1 ], [ 1, 2 ], [ 2, 1 ],
#	[ 1, 3 ], [ 2, 2 ], [ 3, 1 ],
#	[ 2, 3 ], [ 3, 2 ], [ 3, 3 ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Initialize with reverse directions

pr()

w = new stzWalker2D([5, 8], [1, 3], 2)

? @@(w.StartPosition())
? @@(w.EndPosition())

? @@( w.Directions() )	#TODO // Review this design
#--> [ -1, -1 ]

? w.Direction()
#--> "X: backward, Y: backward"

? @@(w.Steps())
#--> 2

? @@(w.Walkables())
#--> [
#	[ 5, 8 ], [ 5, 6 ], [ 3, 8 ], [ 5, 4 ],
#	[ 3, 6 ], [ 1, 8 ], [ 3, 4 ], [ 1, 6 ],
#	[ 1, 4 ], [ 1, 3 ]
# ]

pf()

# ======================
#  Basic Walking Tests
# ======================


/*--- Single step walk
*/

w = new stzWalker2D([1, 1], [5, 5], 1)

? @@(w.CurrentPosition())

# Walk one step
? @@(w.Walk())

# New position
? @@(w.CurrentPosition())

pf()

/*--- Test 2.2: Walk multiple steps
test2_2 = new stzWalker2D([1, 1], [5, 5], 1)
? NL + "Test 2.2: Walk multiple steps"
? "Initial position: " + @@(test2_2.CurrentPosition())
? "Walk 3 steps: " + @@(test2_2.WalkNSteps(3))
? "New position: " + @@(test2_2.CurrentPosition())

/*--- Test 2.3: Walk to specific position
test2_3 = new stzWalker2D([1, 1], [5, 5], 1)
? NL + "Test 2.3: Walk to specific position"
? "Initial position: " + @@(test2_3.CurrentPosition())
? "Walk to [3, 4]: " + @@(test2_3.WalkTo(3, 4))
? "New position: " + @@(test2_3.CurrentPosition())

/*--- Test 2.4: Walk to end
test2_4 = new stzWalker2D([1, 1], [5, 5], 1)
? NL + "Test 2.4: Walk to end"
? "Initial position: " + @@(test2_4.CurrentPosition())
? "Walk to end: " + @@(test2_4.WalkToEnd())
? "New position: " + @@(test2_4.CurrentPosition())

/*--- Test 2.5: Walk with pair step
test2_5 = new stzWalker2D([1, 1], [7, 7], [2, 3])
? NL + "Test 2.5: Walk with pair step"
? "Initial position: " + @@(test2_5.CurrentPosition())
? "Walkable positions: " + @@(test2_5.WalkablePositions())
? "Walk two steps: " + @@(test2_5.WalkNSteps(2))
? "New position: " + @@(test2_5.CurrentPosition())

# ===============================
# Position Queries
# ===============================

Separator("TEST GROUP 3: Position Queries")

/*--- Test 3.1: All Positions
test3_1 = new stzWalker2D([1, 1], [3, 3], 1)
? "Test 3.1: All Positions"
? "All positions: " + @@(test3_1.Positions())
? "Number of positions: " + test3_1.NumberOfPositions()

/*--- Test 3.2: Walkable Positions
? NL + "Test 3.2: Walkable Positions"
? "Walkable positions: " + @@(test3_1.WalkablePositions())
? "Number of walkable positions: " + test3_1.NumberOfWalkablePositions()

/*--- Test 3.3: Unwalkable Positions
? NL + "Test 3.3: Unwalkable Positions"
test3_3 = new stzWalker2D([1, 1], [3, 3], 2)
? "Walkable positions: " + @@(test3_3.WalkablePositions())
? "Unwalkable positions: " + @@(test3_3.UnwalkablePositions())
? "Number of unwalkable positions: " + test3_3.NumberOfUnwalkablePositions()

/*--- Test 3.4: Is Position Walkable
test3_4 = new stzWalker2D([1, 1], [5, 5], 2)
? NL + "Test 3.4: Is Position Walkable"
? "Is [1, 1] walkable: " + test3_4.IsWalkable([1, 1])
? "Is [2, 2] walkable: " + test3_4.IsWalkable([2, 2])
? "Is [3, 3] walkable: " + test3_4.IsWalkable([3, 3])
? "Is [4, 4] walkable: " + test3_4.IsWalkable([4, 4])

/*--- Test 3.5: Remaining Walkables
test3_5 = new stzWalker2D([1, 1], [5, 5], 1)
test3_5.WalkNSteps(3)
? NL + "Test 3.5: Remaining Walkables"
? "Current position: " + @@(test3_5.CurrentPosition())
? "Remaining walkables: " + @@(test3_5.RemainingWalkables())
? "Number of remaining walkables: " + test3_5.NumberOfRemainingWalkables()

# ===============================
# Directional & Backward Walking
# ===============================

Separator("TEST GROUP 4: Directional & Backward Walking")

/*--- Test 4.1: Walk backward
test4_1 = new stzWalker2D([1, 1], [5, 5], 1)
test4_1.WalkNSteps(3)
? "Test 4.1: Walk backward"
? "Current position before: " + @@(test4_1.CurrentPosition())
? "Walk one step backward: " + @@(test4_1.WalkBackward())
? "Current position after: " + @@(test4_1.CurrentPosition())

/*--- Test 4.2: Walk backward multiple steps
test4_2 = new stzWalker2D([1, 1], [5, 5], 1)
test4_2.WalkNSteps(5)
? NL + "Test 4.2: Walk backward multiple steps"
? "Current position before: " + @@(test4_2.CurrentPosition())
? "Walk two steps backward: " + @@(test4_2.WalkBackwardNSteps(2))
? "Current position after: " + @@(test4_2.CurrentPosition())

/*--- Test 4.3: Walk with reversed starting points
test4_3 = new stzWalker2D([5, 5], [1, 1], 1)
? NL + "Test 4.3: Walk with reversed starting points"
? "Start position: " + @@(test4_3.StartPosition())
? "End position: " + @@(test4_3.EndPosition())
? "Direction: " + test4_3.Direction()
? "Walkable positions: " + @@(test4_3.WalkablePositions())
? "Walk two steps: " + @@(test4_3.WalkNSteps(2))
? "Current position: " + @@(test4_3.CurrentPosition())

/*--- Test 4.4: Walk with mixed directions
test4_4 = new stzWalker2D([5, 1], [1, 5], 1)
? NL + "Test 4.4: Walk with mixed directions"
? "Start position: " + @@(test4_4.StartPosition())
? "End position: " + @@(test4_4.EndPosition())
? "Direction: " + test4_4.Direction()
? "Walkable positions: " + @@(test4_4.WalkablePositions())
? "Walk two steps: " + @@(test4_4.WalkNSteps(2))
? "Current position: " + @@(test4_4.CurrentPosition())

# ===============================
# Variable Steps & Complex Walks
# ===============================

Separator("TEST GROUP 5: Variable Steps & Complex Walks")

/*--- Test 5.1: Walk with variable steps (array of single numbers)
test5_1 = new stzWalker2D([1, 1], [10, 10], [1, 2, 3])
? "Test 5.1: Walk with variable steps (array of single numbers)"
? "Start position: " + @@(test5_1.StartPosition())
? "End position: " + @@(test5_1.EndPosition())
? "Step size: " + @@(test5_1.Steps())
? "Walkable positions: " + @@(test5_1.WalkablePositions())
? "Walk three steps: " + @@(test5_1.WalkNSteps(3))
? "Current position: " + @@(test5_1.CurrentPosition())

/*--- Test 5.2: Walk with variable steps (array of pairs)
test5_2 = new stzWalker2D([1, 1], [10, 10], [[1, 1], [2, 2], [1, 3]])
? NL + "Test 5.2: Walk with variable steps (array of pairs)"
? "Start position: " + @@(test5_2.StartPosition())
? "End position: " + @@(test5_2.EndPosition())
? "Step size: " + @@(test5_2.Steps())
? "Walkable positions: " + @@(test5_2.WalkablePositions())
? "Walk three steps: " + @@(test5_2.WalkNSteps(3))
? "Current position: " + @@(test5_2.CurrentPosition())

/*--- Test 5.3: Walk between two positions
test5_3 = new stzWalker2D([1, 1], [9, 9], 2)
? NL + "Test 5.3: Walk between two positions"
? "Start position: " + @@(test5_3.StartPosition())
? "End position: " + @@(test5_3.EndPosition())
? "Current position before: " + @@(test5_3.CurrentPosition())
? "Walk between [3, 3] and [7, 7]: " + @@(test5_3.WalkBetween([3, 3], [7, 7]))
? "Current position after: " + @@(test5_3.CurrentPosition())

# ===============================
# History & Reset Tests
# ===============================

Separator("TEST GROUP 6: History & Reset Tests")

/*--- Test 6.1: Walk history
test6_1 = new stzWalker2D([1, 1], [5, 5], 1)
test6_1.Walk()
test6_1.Walk()
test6_1.WalkBackward()
test6_1.Walk()
? "Test 6.1: Walk history"
? "Current position: " + @@(test6_1.CurrentPosition())
? "History: " + @@(test6_1.Walks())
? "Number of walks: " + test6_1.NumberOfWalks()

/*--- Test 6.2: Reset history
test6_2 = new stzWalker2D([1, 1], [5, 5], 1)
test6_2.WalkNSteps(3)
? NL + "Test 6.2: Reset history"
? "History before reset: " + @@(test6_2.Walks())
test6_2.ResetHistory()
? "History after reset: " + @@(test6_2.Walks())
? "Current position: " + @@(test6_2.CurrentPosition())

/*--- Test 6.3: Full reset
test6_3 = new stzWalker2D([1, 1], [5, 5], 1)
test6_3.WalkNSteps(3)
? NL + "Test 6.3: Full reset"
? "Position before reset: " + @@(test6_3.CurrentPosition())
? "History before reset: " + @@(test6_3.Walks())
test6_3.Reset()
? "Position after reset: " + @@(test6_3.CurrentPosition())
? "History after reset: " + @@(test6_3.Walks())

# ===============================
# Edge Cases
# ===============================

Separator("TEST GROUP 7: Edge Cases")

/*--- Test 7.1: Start equals end
test7_1 = new stzWalker2D([3, 3], [3, 3], 1)
? "Test 7.1: Start equals end"
? "Start position: " + @@(test7_1.StartPosition())
? "End position: " + @@(test7_1.EndPosition())
? "Walkable positions: " + @@(test7_1.WalkablePositions())
? "Walk attempt: " + @@(test7_1.Walk())

/*--- Test 7.2: Over-walking beyond end
test7_2 = new stzWalker2D([1, 1], [5, 5], 2)
? NL + "Test 7.2: Over-walking beyond end"
? "Walkable positions: " + @@(test7_2.WalkablePositions())
? "Number of walkable positions: " + test7_2.NumberOfWalkablePositions()
? "Walk 10 steps (more than available): " + @@(test7_2.WalkNSteps(10))
? "Current position: " + @@(test7_2.CurrentPosition())

/*--- Test 7.3: Negative steps
test7_3 = new stzWalker2D([1, 1], [5, 5], [-1, -2])
? NL + "Test 7.3: Negative steps"
? "Start position: " + @@(test7_3.StartPosition())
? "End position: " + @@(test7_3.EndPosition())
? "Step size: " + @@(test7_3.Steps())
? "Direction: " + test7_3.Direction()
? "Walkable positions: " + @@(test7_3.WalkablePositions())
? "Walk one step: " + @@(test7_3.Walk())
? "Current position: " + @@(test7_3.CurrentPosition())

/*--- Test 7.4: Walk between invalid positions
test7_4 = new stzWalker2D([1, 1], [5, 5], 1)
? NL + "Test 7.4: Walk between invalid positions"
? "Try walking between [1, 1] and [6, 6] (out of bounds): "
try
    ? @@(test7_4.WalkBetween([1, 1], [6, 6]))
catch
    ? "Error: Position [6, 6] is not walkable"
done

/*--- Test 7.5: Set current position to invalid position
test7_5 = new stzWalker2D([1, 1], [5, 5], 2)
? NL + "Test 7.5: Set current position to invalid position"
? "Try setting current position to [2, 2] (unwalkable): "
try
    test7_5.SetCurrentPosition(2, 2)
    ? "Successfully set position to: " + @@(test7_5.CurrentPosition())
catch
    ? "Error: Position [2, 2] is not walkable"
done

pf()


