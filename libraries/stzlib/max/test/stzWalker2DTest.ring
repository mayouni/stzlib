load "../stzmax.ring"


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
#	[ 1, 1 ], [ 3, 1 ], [ 5, 1 ],
#	[ 2, 2 ], [ 4, 2 ],
#	[ 1, 3 ], [ 3, 3 ], [ 5, 3 ],
#	[ 2, 4 ], [ 4, 4 ],
#	[ 1, 5 ], [ 3, 5 ], [ 5, 5 ]
# ]

#   1 2 3 4 5
# 1 S . o . o
# 2 . o . o .
# 3 o . o . o
# 4 . o . o .
# 5 o . o . E

pf()
# Executed in 0.07 second(s) in Ring 1.22

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
#	[ 2, 3 ], [ 4, 3 ], [ 6, 3 ],
#	[ 2, 4 ], [ 4, 4 ], [ 6, 4 ],
#	[ 2, 5 ], [ 4, 5 ], [ 6, 5 ],
#	[ 2, 6 ], [ 4, 6 ], [ 6, 6 ],
#	[ 2, 7 ], [ 4, 7 ], [ 6, 7 ],
#	[ 2, 8 ], [ 4, 8 ], [ 6, 8 ]
# ]

w.Show()

#   1 2 3 4 5 6
# 1 . . . . . .
# 2 . . . . . .
# 3 . S . o . o
# 4 . o . o . o
# 5 . o . o . o
# 6 . o . o . o
# 7 . o . o . o
# 8 . o . o . E

pf()
# Executed in 0.07 second(s) in Ring 1.22

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
#	[ 1, 1 ], [ 3, 1 ],
#	[ 1, 2 ], [ 3, 2 ],
#	[ 1, 3 ], [ 3, 3 ],
#	[ 1, 4 ], [ 3, 4 ],
#	[ 1, 5 ], [ 3, 5 ],
#	[ 1, 6 ], [ 3, 6 ],
#	[ 1, 7 ], [ 3, 7 ],
#	[ 1, 8 ], [ 3, 8 ]
]

pf()
# Executed in 0.08 second(s) in Ring 1.22

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
#	[ 1, 1 ], [ 2, 1 ], [ 3, 1 ],
#	[ 1, 2 ], [ 2, 2 ], [ 3, 2 ],
#	[ 1, 3 ], [ 2, 3 ], [ 3, 3 ]
# ]

pf()
# Executed in 0.07 second(s) in Ring 1.22

    1 2 3 4 5 
  ╭───────────╮
3 │ S . o . o │
4 │ . x . o . │
5 │ o . o . o │
6 │ . o . o . │
7 │ o . o . o │
8 │ . o . o E │
  ╰───────────╯

/*--- Initialize with reverse directions
*/
pr()

w = new stzWalker2D([1, 3], [5, 8], 2)

? @@( w.Walkables() ) + NL
#--> [
#	[ 1, 3 ], [ 3, 3 ], [ 5, 3 ],
#	[ 2, 4 ], [ 4, 4 ],
#	[ 1, 5 ], [ 3, 5 ], [ 5, 5 ],
#	[ 2, 6 ], [ 4, 6 ],
#	[ 1, 7 ], [ 3, 7 ], [ 5, 7 ],
#	[ 2, 8 ], [ 4, 8 ]
# ]

w.WalkN(4)

w.Show()
#-->
#     1  2  3  4  5  
#   ╭──────────v────╮
# 1 │ .  .  .  .  . │
# 2 │ .  .  .  .  . │
# 3 │ S  .  o  .  o │
# 4 > .  o  .  x  . │
# 5 │ o  .  o  .  o │
# 6 │ .  o  .  o  . │
# 7 │ o  .  o  .  o │
# 8 │ .  o  .  o  E │
#   ╰───────────────╯

pf()
# Executed in 0.07 second(s) in Ring 1.22

/*---

pr()

w = new stzWalker2D([ 5, 8 ], [ 1, 3 ], 2)

? w.Direction()
#--> backward

? @@(w.StartPosition())
#--> [ 5, 8 ]

? @@(w.EndPosition())
#--> [ 1, 3 ]

? @@(w.Walkables())
#--> [
#	[ 5, 8 ], [ 3, 8 ], [ 1, 8 ],
#	[ 4, 7 ], [ 2, 7 ], [ 5, 6 ],
#	[ 3, 6 ], [ 1, 6 ], [ 4, 5 ],
#	[ 2, 5 ], [ 5, 4 ], [ 3, 4 ],
#	[ 1, 4 ], [ 4, 3 ], [ 2, 3 ]
# ]

pf()
# Executed in 0.08 second(s) in Ring 1.22

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
#--> [ [ 1, 1 ], [ 2, 1 ] ]

# New position

? @@(w.CurrentPosition())
#--> [ 2, 1 ]

pf()
# Executed in 0.07 second(s) in Ring 1.22

/*--- Walk multiple steps

pr()

w = new stzWalker2D([1, 1], [5, 5], 1)

? @@(w.CurrentPosition())
#--> [ 1, 1 ]

? @@(w.WalkNSteps(3))
#--> [ [ 1, 1 ], [ 2, 1 ], [ 3, 1 ], [ 4, 1 ] ]

? @@(w.CurrentPosition())
#--> [ 4, 1 ]

pf()
# Executed in 0.07 second(s) in Ring 1.22

/*--- Walk to specific position

pr()

w = new stzWalker2D([1, 1], [5, 5], 1)

? @@(w.CurrentPosition()) + NL
#--> [ 1, 1 ]

? @@(w.WalkTo(3, 4)) + NL
#--> [
#	[ 1, 1 ], [ 2, 1 ], [ 3, 1 ], [ 4, 1 ], [ 5, 1 ],
#	[ 1, 2 ], [ 2, 2 ], [ 3, 2 ], [ 4, 2 ], [ 5, 2 ], [ 1, 3 ], [ 2, 3 ], [ 3, 3 ], [ 4, 3 ], [ 5, 3 ], [ 1, 4 ], [ 2, 4 ], [ 3, 4 ] ]

? @@(w.CurrentPosition())
#--> [ 3, 4 ]

pf()
# Executed in 0.07 second(s) in Ring 1.22

/*--- Walk to end

pr()

w = new stzWalker2D([1, 1], [5, 5], 1)

? @@( w.CurrentPosition() ) + NL
#--> [ 1, 1 ]

? @@( w.WalkToEnd() ) + NL
#--> [
#	[ 1, 1 ], [ 2, 1 ], [ 3, 1 ], [ 4, 1 ], [ 5, 1 ],
#	[ 1, 2 ], [ 2, 2 ], [ 3, 2 ], [ 4, 2 ], [ 5, 2 ],
#	[ 1, 3 ], [ 2, 3 ], [ 3, 3 ], [ 4, 3 ], [ 5, 3 ],
#	[ 1, 4 ], [ 2, 4 ], [ 3, 4 ], [ 4, 4 ], [ 5, 4 ],
#	[ 1, 5 ], [ 2, 5 ], [ 3, 5 ], [ 4, 5 ], [ 5, 5 ]
# ]

? @@( w.CurrentPosition() )
#--> [ 5, 5 ]

pf()
# Executed in 0.07 second(s) in Ring 1.22

/*--- Walk with pair step

pr()

w = new stzWalker2D([1, 1], [7, 7], [2, 3])

#   1 2 3 4 5 6 7
# 1 S . o . . o .
# 2 o . . o . o .
# 3 . o . o . . o
# 4 . o . . o . o
# 5 . . o . o . .
# 6 o . o . . o .
# 7 o . . o . E .

? @@(w.CurrentPosition()) + NL
#--> [ 1, 1 ]

? @@(w.Walkables()) + NL
#--> [
#	[ 1, 1 ], [ 3, 1 ], [ 6, 1 ],
#	[ 1, 2 ], [ 4, 2 ], [ 6, 2 ],
#	[ 2, 3 ], [ 4, 3 ], [ 7, 3 ],
#	[ 2, 4 ], [ 5, 4 ], [ 7, 4 ],
#	[ 3, 5 ], [ 5, 5 ],
#	[ 1, 6 ], [ 3, 6 ], [ 6, 6 ],
#	[ 1, 7 ], [ 4, 7 ], [ 6, 7 ]
# ]

? @@(w.WalkNSteps(2)) + NL
#--> [ [ 1, 1 ], [ 3, 1 ], [ 6, 1 ] ]

? @@(w.CurrentPosition())
#--> [ 6, 1 ]

pf()
# Executed in 0.09 second(s) in Ring 1.22

# =================
# Position Queries
# =================

/*--- All Positions

pr()

w = new stzWalker2D([1, 1], [3, 3], 1)

? @@(w.Positions()) + NL
#--> [
#	[ 1, 1 ], [ 2, 1 ], [ 3, 1 ],
#	[ 1, 2 ], [ 2, 2 ], [ 3, 2 ],
#	[ 1, 3 ], [ 2, 3 ], [ 3, 3 ]
# ]

? w.NumberOfPositions()
#--> 9

pf()
# Executed in 0.08 second(s) in Ring 1.22

/*--- Walkable Positions

pr()

w = new stzWalker2D([1, 1], [3, 3], 1)

? @@(w.Walkables()) + NL
#--> [
#	[ 1, 1 ], [ 2, 1 ], [ 3, 1 ],
#	[ 1, 2 ], [ 2, 2 ], [ 3, 2 ],
#	[ 1, 3 ], [ 2, 3 ], [ 3, 3 ]
# ]

? w.NumberOfWalkables()
#--> 9

pf()
# Executed in 0.07 second(s) in Ring 1.22

/*--- Unwalkable Position

pr()

w = new stzWalker2D([1, 1], [3, 3], 2)

? @@(w.Walkables()) + NL
#--> [ [ 1, 1 ], [ 3, 1 ], [ 2, 2 ], [ 1, 3 ], [ 3, 3 ] ]

? @@(w.Unwalkables()) + NL
#--> [ [ 2, 1 ], [ 1, 2 ], [ 3, 2 ], [ 2, 3 ] ]

? w.NumberOfUnwalkables()
#--> 5

pf()
# Executed in 0.11 second(s) in Ring 1.22

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
# Executed in 0.07 second(s) in Ring 1.22

/*--- Remaining Walkables

pr()

w = new stzWalker2D([1, 1], [5, 5], 1)

w.WalkNSteps(3)
? @@(w.CurrentPosition()) + NL
#--> [ 1, 4 ]

? @@(w.RemainingWalkables()) + NL
#--> [
#	[ 5, 1 ],
#	[ 1, 2 ], [ 2, 2 ], [ 3, 2 ], [ 4, 2 ], [ 5, 2 ],
#	[ 1, 3 ], [ 2, 3 ], [ 3, 3 ], [ 4, 3 ], [ 5, 3 ],
#	[ 1, 4 ], [ 2, 4 ], [ 3, 4 ], [ 4, 4 ], [ 5, 4 ],
#	[ 1, 5 ], [ 2, 5 ], [ 3, 5 ], [ 4, 5 ], [ 5, 5 ]
# ]

? w.NumberOfRemainingWalkables()
#--> 21

pf()
# Executed in 0.07 second(s) in Ring 1.22

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
#--> [ 4, 1 ]

? @@(w.WalkBackward())
#--> [ [ 4, 1 ], [ 3, 1 ] ]

? @@(w.CurrentPosition())
#--> [ 3, 1 ]

pf()
# Executed in 0.07 second(s) in Ring 1.22

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
#--> [ 1, 2 ]

? @@(w.WalkBackwardNSteps(2))
#--> [ [ 1, 2 ], [ 5, 1 ], [ 4, 1 ] ]

? @@(w.CurrentPosition())
#--> [ 4, 1 ]

pf()
# Executed in 0.07 second(s) in Ring 1.22

/*--- Walk with reversed starting points

pr()

w = new stzWalker2D([5, 5], [1, 1], 1)

? @@(w.StartPosition())
#--> [ 5, 5 ]

? @@(w.EndPosition())
#--> [ 1, 1 ]

? w.Direction()
#--> backward

? @@(w.Walkables()) + NL
#--> [
#	[ 5, 5 ], [ 4, 5 ], [ 3, 5 ], [ 2, 5 ], [ 1, 5 ],
#	[ 5, 4 ], [ 4, 4 ], [ 3, 4 ], [ 2, 4 ], [ 1, 4 ],
#	[ 5, 3 ], [ 4, 3 ], [ 3, 3 ], [ 2, 3 ], [ 1, 3 ],
#	[ 5, 2 ], [ 4, 2 ], [ 3, 2 ], [ 2, 2 ], [ 1, 2 ],
#	[ 5, 1 ], [ 4, 1 ], [ 3, 1 ], [ 2, 1 ], [ 1, 1 ]
# ]

? @@(w.WalkNSteps(2))
#--> [ [ 5, 5 ], [ 4, 5 ], [ 3, 5 ] ]

? @@(w.CurrentPosition())
#--> [ 3, 5 ]

pf()
# Executed in 0.08 second(s) in Ring 1.22

#   1 2 3 4 5
# 1 . . . . .
# 2 . . . . .
# 3 E . . . .
# 4 . . . . .
# 5 S . . . .

/*--- Walk with mixed directions

pr()

w = new stzWalker2D([1, 3], [5, 1], 1)

? @@(w.StartPosition())
#--> [ 1, 3 ]

? @@(w.EndPosition())
#--> [ 5, 1 ]

? w.Direction() + NL
#--> froward

? @@(w.Walkables()) + NL
#--> [ [ 1, 3 ], [ 2, 3 ], [ 3, 3 ], [ 4, 3 ], [ 5, 3 ] ]

? @@(w.WalkNSteps(2)) + NL
#--> [ [ 1, 3 ], [ 2, 3 ], [ 3, 3 ] ]

? @@(w.CurrentPosition())
#--> [ 3, 3 ]

pf()
# Executed in 0.09 second(s) in Ring 1.22

/*---

pr()

w = new stzWalker2D([5, 1], [1, 3], 1)

? @@(w.StartPosition())
#--> [ 5, 1 ]

? @@(w.EndPosition())
#--> [ 1, 3 ]

? w.Direction() + NL
#--> backward

? @@(w.Walkables()) + NL
#--> [ [ 5, 1 ], [ 4, 1 ], [ 3, 1 ], [ 2, 1 ], [ 1, 1 ] ]

? @@(w.WalkNSteps(2)) + NL
#--> [ [ 5, 1 ], [ 4, 1 ], [ 3, 1 ] ]

? @@(w.CurrentPosition())
#--> [ 3, 1 ]

pf()
# Executed in 0.07 second(s) in Ring 1.22

# ===============================
# Variable Steps & Complex Walks
# ===============================

/*--- Walk with variable steps (list of single numbers)

pr()

w = new stzWalker2D([1, 1], [10, 10], [1, 2, 3])

? @@(w.StartPosition())
#--> [ 1, 1 ]

? @@(w.EndPosition())
#--> [ 10, 10 ]

? @@(w.Steps()) + NL
#--< [ 1, 2, 3 ]

? @@(w.WalkablePositions()) + NL
#--> [
#	[ 1, 1 ], [ 2, 1 ], [ 4, 1 ], [ 7, 1 ], [ 8, 1 ], [ 10, 1 ],
#	[ 3, 2 ], [ 4, 2 ], [ 6, 2 ], [ 9, 2 ], [ 10, 2 ],
#	[ 2, 3 ], [ 5, 3 ], [ 6, 3 ], [ 8, 3 ],
#	[ 1, 4 ], [ 2, 4 ], [ 4, 4 ], [ 7, 4 ], [ 8, 4 ], [ 10, 4 ],
#	[ 3, 5 ], [ 4, 5 ], [ 6, 5 ], [ 9, 5 ], [ 10, 5 ],
#	[ 2, 6 ], [ 5, 6 ], [ 6, 6 ], [ 8, 6 ],
#	[ 1, 7 ], [ 2, 7 ], [ 4, 7 ], [ 7, 7 ], [ 8, 7 ], [ 10, 7 ],
#	[ 3, 8 ], [ 4, 8 ], [ 6, 8 ], [ 9, 8 ], [ 10, 8 ],
#	[ 2, 9 ], [ 5, 9 ], [ 6, 9 ], [ 8, 9 ],
#	[ 1, 10 ], [ 2, 10 ], [ 4, 10 ], [ 7, 10 ], [ 8, 10 ], [ 10, 10 ]
# ]

? @@(w.WalkNSteps(3))
#--> [ [ 1, 1 ], [ 2, 1 ], [ 4, 1 ], [ 7, 1 ] ]

? @@(w.CurrentPosition())
#--> [ 7, 1 ]

pf()
# Executed in 0.09 second(s) in Ring 1.22

/*--- Walk between two positions
*/
pr()

w = new stzWalker2D([1, 1], [9, 9], 2)

? @@(w.StartPosition())
#--> [ 1, 1 ]

? @@(w.EndPosition())
#--> [ 9, 9 ]

? @@(w.CurrentPosition()) + NL
#--> [ 1, 1 ]

? @@(w.WalkBetween([3, 3], [7, 7])) + NL
#--> [
#		  [ 3, 3 ], [ 5, 3 ], [ 7, 3 ], [ 9, 3 ],
#	[ 2, 4 ], [ 4, 4 ], [ 6, 4 ], [ 8, 4 ],
#	[ 1, 5 ], [ 3, 5 ], [ 5, 5 ], [ 7, 5 ], [ 9, 5 ],
#	[ 2, 6 ], [ 4, 6 ], [ 6, 6 ], [ 8, 6 ],
#	[ 1, 7 ], [ 3, 7 ], [ 5, 7 ], [ 7, 7 ]
# ]

? @@(w.CurrentPosition())
#--> [ 1, 1 ]

pf()
# Executed in 0.08 second(s) in Ring 1.22

# =======================
# History & Reset Tests
# ======================

/*--- Walk history

pr()

w = new stzWalker2D([1, 1], [5, 5], 1)
w.Walk()
w.Walk()
w.WalkBackward()
w.Walk()

? @@(w.CurrentPosition()) + NL
#--> [ 3, 1 ]

? @@NL(w.Walks()) + NL
#--> [
#	[ [ 1, 1 ], [ 2, 1 ] ],		~> w.Walk()
#	[ [ 2, 1 ], [ 3, 1 ] ], 	~> w.Walk()
#	[ [ 3, 1 ], [ 2, 1 ] ], 	~> w.WalkBakcward()
#	[ [ 2, 1 ], [ 3, 1 ] ]  	~> w.Walk()
# ]

? w.NumberOfWalks()
#--> 4

pf()
# Executed in 0.08 second(s) in Ring 1.22

/*--- Reset history

pr()

w = new stzWalker2D([1, 1], [5, 5], 1)

w.WalkNSteps(3)

# History before reset

? @@NL(w.Walks()) # One walk for 3 steps
#--> [
#	[
#		[ 1, 1 ],
#		[ 2, 1 ],
#		[ 3, 1 ],
#		[ 4, 1 ]
#	]
# ]

w.ResetHistory()

# History after reset

? @@NL(w.Walks()) + NL
#--> []

? @@(w.CurrentPosition())
#--> [ 4, 1 ]

pf()
# Executed in 0.09 second(s) in Ring 1.22

/*--- Full reset

pr()

w = new stzWalker2D([1, 1], [5, 5], 1)

w.WalkNSteps(3)

# Position before reset

? @@(w.CurrentPosition())
#--> [ 4, 1 ]

# History before reset

? @@NL(w.Walks()) + NL
#--> [
#	[
#		[ 1, 1 ],
#		[ 2, 1 ],
#		[ 3, 1 ],
#		[ 4, 1 ]
#	]
# ]

w.Reset()

# After reset

? @@(w.CurrentPosition())
#--> [ 1, 1 ]

? @@(w.Walks())
#--> [ ]

pf()
# Executed in 0.07 second(s) in Ring 1.22

# ============
# Edge Cases
# ============

/*--- Start equals end

pr()

w = new stzWalker2D([3, 3], [3, 3], 1)

? @@(w.StartPosition())
#--> [ 3, 3 ]

? @@(w.EndPosition())
#--> [ 3, 3 ]

? @@(w.WalkablePositions())
#--> [ [ 3, 3 ] ]

# Walk attempt

? @@(w.Walk()) # Did not move ans stays on current position
#--> [ [ 3, 3 ] ]

pf()
# Executed in 0.09 second(s) in Ring 1.22

/*--- Over-walking beyond end

pr()

w = new stzWalker2D([1, 1], [5, 5], 2)

? @@(w.Walkables())
#--> [
#	[ 1, 1 ], [ 3, 1 ], [ 5, 1 ],
#	[ 2, 2 ], [ 4, 2 ],
#	[ 1, 3 ], [ 3, 3 ], [ 5, 3 ],
#	[ 2, 4 ], [ 4, 4 ],
#	[ 1, 5 ], [ 3, 5 ], [ 5, 5 ]
# ]

? w.NumberOfWalkables()
#--> 13

# Walk 3 steps

? @@(w.WalkNSteps(10)) + NL
#--> [
#	[ 1, 1 ], [ 3, 1 ], [ 5, 1 ],
#	[ 2, 2 ], [ 4, 2 ],
#	[ 1, 3 ], [ 3, 3 ], [ 5, 3 ],
#	[ 2, 4 ], [ 4, 4 ],
#	[ 1, 5 ]
# ]

? @@(w.RemainingWalkables()) + NL
#--> [ [ 3, 5 ], [ 5, 5 ] ]

# Walk 5 steps (more than available)

? @@(w.WalkNSteps(5)) # Walks just the remaining steps
#--> [ [ 1, 5 ], [ 3, 5 ], [ 5, 5 ] ]

? @@(w.CurrentPosition())
#--> [ 5, 5 ]

pf()
# Executed in 0.08 second(s) in Ring 1.22

/*--- Negative steps

pr()

w = new stzWalker2D([1, 1], [5, 5], [3, -1])

? @@(w.StartPosition())
#--> [ 1, 1 ]

? @@(w.EndPosition())
#--> [ 5, 5 ]

? @@(w.Steps())
#--> [ 3, -1 ]

? w.Direction()
#--> forward

? @@(w.Walkables()) + NL
#--> [
#	[ 1, 1 ], [ 4, 1 ], [ 3, 1 ],
#	[ 1, 2 ],
#	[ 5, 1 ],
#	[ 3, 2 ], [ 2, 2 ], [ 5, 2 ], [ 4, 2 ],
#	[ 2, 3 ], [ 1, 3 ], [ 4, 3 ], [ 3, 3 ],
#	[ 1, 4 ],
#	[ 5, 3 ],
#	[ 3, 4 ], [ 2, 4 ], [ 5, 4 ], [ 4, 4 ],
#	[ 2, 5 ], [ 1, 5 ], [ 4, 5 ], [ 3, 5 ]
# ]

? @@(w.Walk())
#--> [ [ 1, 1 ], [ 4, 1 ] ]

? @@(w.CurrentPosition())
#--> [ 4, 1 ]

pf()
# Executed in 0.09 second(s) in Ring 1.22

/*--- Walk between invalid positions

pr()

w = new stzWalker2D([1, 1], [5, 5], 1)

# Try walking between [1, 1] and [6, 6] (out of bounds)

w.WalkBetween([1, 1], [6, 6])
#--> Can't walk between the positions! End position [6,6] is not walkable.

pf()

/*--- Set current position to invalid position

pr()

w = new stzWalker2D([1, 1], [5, 5], 2)

? @@( w.Walkables() ) + NL
#--> [
#	[ 1, 1 ], [ 3, 1 ], [ 5, 1 ],
#	[ 2, 2 ], [ 4, 2 ],
#	[ 1, 3 ], [ 3, 3 ], [ 5, 3 ],
#	[ 2, 4 ], [ 4, 4 ],
#	[ 1, 5 ], [ 3, 5 ], [ 5, 5 ]
# ]

# Try setting current position to [2, 2] (unwalkable)

? w.IsWalkable(2, 3)
#--> FALSE

w.SetCurrentPosition(2, 3)
#--> ERROR: Incorrect params! [ 2, 3 ] do not correspond to a walkable position.

pf()

#---

pr()

w = new stzWalker2D([5, 1], [5, 5], [-4, -1])
#--> ERROR: Incorrect steps! Attempting to walk before the first position.

pf()

/*---

w = new stzWalker2D([5, 1], [5, 5], [-2, 1])
#--> Error (R2) : Array Access (Index out of range)

