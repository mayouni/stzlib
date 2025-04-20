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

pr()

w = new stzWalker2D([1, 1], [5, 5], 1)

? @@(w.CurrentPosition())
#--> [ 1, 1 ]

# Walk one step

? @@(w.Walk())
#--> [ [ 1, 1 ], [ 1, 2 ] ]

# New position

? @@(w.CurrentPosition())
#--> [ 1, 2 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test 2.2: Walk multiple steps

pr()

w = new stzWalker2D([1, 1], [5, 5], 1)

? @@(w.CurrentPosition())
#--> [ 1, 1 ]

? @@(w.WalkNSteps(3))
#--> [ [ 1, 1 ], [ 1, 2 ], [ 2, 1 ], [ 1, 3 ] ]

? @@(w.CurrentPosition())
#--> [ 1, 3 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Walk to specific position
*/
pr()

w = new stzWalker2D([1, 1], [5, 5], 1)

? @@(w.CurrentPosition()) + NL
#--> [ 1, 1 ]

? @@(w.WalkTo(3, 4)) + NL
#--> [
#	[ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 1, 5 ],
#	[ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 2, 4 ], [ 2, 5 ],
#	[ 3, 1 ], [ 3, 2 ], [ 3, 3 ], [ 3, 4 ]
# ]

? @@(w.CurrentPosition())
#--> [ 3, 4 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Walk to end

pr()

w = new stzWalker2D([1, 1], [5, 5], 1)

? @@( w.CurrentPosition() ) + NL
#--> [ 1, 1 ]

? @@( w.WalkToEnd() ) + NL
#--> [
#	[ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 1, 4 ], [ 1, 5 ],
#	[ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 2, 4 ], [ 2, 5 ],
#	[ 3, 1 ], [ 3, 2 ], [ 3, 3 ], [ 3, 4 ], [ 3, 5 ],
#	[ 4, 1 ], [ 4, 2 ], [ 4, 3 ], [ 4, 4 ], [ 4, 5 ],
#	[ 5, 1 ], [ 5, 2 ], [ 5, 3 ], [ 5, 4 ], [ 5, 5 ]
# ]

? @@( w.CurrentPosition() )
#--> [ 5, 5 ]

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Walk with pair step

pr()

w = new stzWalker2D([1, 1], [7, 7], [2, 3])

? @@(w.CurrentPosition()) + NL
#--> [ 1, 1 ]

? @@(w.Walkables()) + NL
#--> [
#	[ 1, 1 ], [ 1, 4 ], [ 1, 7 ], [ 3, 1 ], [ 3, 4 ], [ 3, 7 ],
#	[ 5, 1 ], [ 5, 4 ], [ 5, 7 ], [ 7, 1 ], [ 7, 4 ], [ 7, 7 ]
# ]

? @@(w.WalkNSteps(2)) + NL
#--> [ [ 1, 1 ], [ 1, 4 ], [ 1, 7 ] ]

? @@(w.CurrentPosition())
#--> [ 1, 7 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

# =================
# Position Queries
# =================

/*--- All Positions

pr()

w = new stzWalker2D([1, 1], [3, 3], 1)

? @@(w.Positions()) + NL
#--> [
#	[ 1, 1 ], [ 1, 2 ], [ 1, 3 ],
#	[ 2, 1 ], [ 2, 2 ], [ 2, 3 ],
#	[ 3, 1 ], [ 3, 2 ], [ 3, 3 ]
# ]

? w.NumberOfPositions()
#--> 9

pf()

/*--- Walkable Positions

pr()

w = new stzWalker2D([1, 1], [3, 3], 1)

? @@(w.Walkables()) + NL
#--> [
#	[ 1, 1 ], [ 1, 2 ], [ 1, 3 ],
#	[ 2, 1 ], [ 2, 2 ], [ 2, 3 ],
#	[ 3, 1 ], [ 3, 2 ], [ 3, 3 ]
# ]

? w.NumberOfWalkables()
#--> 9

pf()

/*--- Unwalkable Position

pr()

w = new stzWalker2D([1, 1], [3, 3], 2)

? @@(w.Walkables()) + NL
#--> [ [ 1, 1 ], [ 1, 3 ], [ 3, 1 ], [ 3, 3 ] ]

? @@(w.Unwalkables()) + NL
#--> [ [ 1, 2 ], [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 2 ] ]

? w.NumberOfUnwalkables()
#--> 5

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Is Position Walkable

pr()

w = new stzWalker2D([1, 1], [5, 5], 2)

? w.IsWalkable([1, 1])
#--> TRUE

? w.IsWalkable([2, 2])
#--> FALSE

? w.IsWalkable([3, 3])
#--> TRUE

? w.IsWalkable([4, 4])
#--> FALSE

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Remaining Walkables

pr()

w = new stzWalker2D([1, 1], [5, 5], 1)

w.WalkNSteps(3)
? @@(w.CurrentPosition()) + NL
#--> [ 1, 4 ]

? @@(w.RemainingWalkables()) + NL
#--> [
#	[ 1, 5 ], [ 2, 1 ], [ 2, 2 ],
#	[ 2, 3 ], [ 2, 4 ], [ 2, 5 ],
#	[ 3, 1 ], [ 3, 2 ], [ 3, 3 ],
#	[ 3, 4 ], [ 3, 5 ], [ 4, 1 ],
#	[ 4, 2 ], [ 4, 3 ], [ 4, 4 ],
#	[ 4, 5 ], [ 5, 1 ], [ 5, 2 ],
#	[ 5, 3 ], [ 5, 4 ], [ 5, 5 ]
# ]

? w.NumberOfRemainingWalkables()
#--> 21

pf()
# Executed in 0.01 second(s) in Ring 1.22

# ===============================
# Directional & Backward Walking
# ===============================

/*--- Walk backward

pr()

w = new stzWalker2D([1, 1], [5, 5], 1)

#   1 2 3 4 5
# 1 o o x o .
# 2 . . . . .
# 3 . . . . .
# 4 . . . . .
# 5 . . . . .

w.WalkNSteps(3)

? @@(w.CurrentPosition())
#--> [ 1, 4 ]

? @@(w.WalkBackward())
#--> [ [ 1, 4 ], [ 1, 3 ] ]

? @@(w.CurrentPosition())
#--> [ 1, 3 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Walk backward multiple steps

pr()

w = new stzWalker2D([1, 1], [5, 5], 1)

#   1 2 3 4 5
# 1 o o o x o
# 2 o . . . .
# 3 . . . . .
# 4 . . . . .
# 5 . . . . .

w.WalkNSteps(5)
? @@(w.CurrentPosition())
#--> [ 2, 1 ]

? @@(w.WalkBackwardNSteps(2))
#--> [ [ 2, 1 ], [ 1, 5 ], [ 1, 4 ] ]

? @@(w.CurrentPosition())
#--> [ 1, 4 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Walk with reversed starting points
*/
pr()

w = new stzWalker2D([5, 5], [1, 1], 1)

? @@(w.StartPosition())
#--> [ 5, 5 ]

? @@(w.EndPosition())
#--> [ 1, 1 ]

? w.Direction()
#--> Direction: X: backward, Y: backward

? @@(w.Walkables()) + NL
#--> [
#	[ 5, 5 ], [ 5, 4 ], [ 5, 3 ], [ 5, 2 ], [ 5, 1 ],
#	[ 4, 5 ], [ 4, 4 ], [ 4, 3 ], [ 4, 2 ], [ 4, 1 ],
#	[ 3, 5 ], [ 3, 4 ], [ 3, 3 ], [ 3, 2 ], [ 3, 1 ],
#	[ 2, 5 ], [ 2, 4 ], [ 2, 3 ], [ 2, 2 ], [ 2, 1 ],
#	[ 1, 5 ], [ 1, 4 ], [ 1, 3 ], [ 1, 2 ], [ 1, 1 ]
# ]

? @@(w.WalkNSteps(2))
#--> [ [ 5, 5 ], [ 5, 4 ], [ 5, 3 ] ]

? @@(w.CurrentPosition())
#--> [ 5, 3 ]

pf()
# Executed in 0.02 second(s) in Ring 1.22

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


