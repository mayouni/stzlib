
load "../stzmax.ring"

/*--- Initialize with factory functions Wks2D() and StzListOfWalkers2DQ()

pr()

# Create individual walkers first

w1 = new stzWalker2D([0,0], [2,2], 1)
w2 = new stzWalker2D([1,1], [3,3], 1)
w3 = new stzWalker2D([0,0], [4,4], 2)

# Create a list of walkers using factory functions

walkers1 = Wks([w1, w2])
walkers2 = StzListOfWalkers2DQ([w1, w2, w3])

# Number of walkers in walkers1
? walkers1.Size()
#--> 2

# Number of walkers in walkers2
? walkers2.Size()
#--> 3

pf()
# Executed in 0.20 second(s) in Ring 1.22

/*--- Access walkers and their properties

pr()

walkers = Wks([
    Wk([0,0], [2,2], 1),
    Wk([1,1], [3,3], 1),
    Wk([0,0], [4,4], 2)
])

? @@(walkers.FirstWalker().StartPosition())
#--> [ 0, 0 ]

? @@(walkers.LastWalker().EndPosition())
#--> [ 4, 4 ]

? @@(walkers.Walker(2).Steps())
#--> Walker at position 2 step size: 1

pf()

/*--- Add and remove walkers

pr()

walkers = Wks([ Wk([0,0], [2,2], 1) ])

# Initial size

? walkers.Size()
#--> 1

walkers.AddWalker(Wk([1,1], [3,3], 1))

# Size after adding one walker

? walkers.Size()
#--> 2

walkers.AddWalkers([
    Wk([0,0], [4,4], 2),
    Wk([5,5], [7,7], 1)
])

# Size after adding multiple walkers
? walkers.Size()
#--> 4

walkers.RemoveWalker(2)

# Size after removing one walker
? walkers.Size()
#--> 3

walkers.RemoveFirstWalker()

# Size after removing first walker
? walkers.Size()
#--> 2

walkers.RemoveLastWalker()

# Size after removing last walker
? walkers.Size()
#--> 1

pf()
# Executed in 0.34 second(s) in Ring 1.22

/*--- Comparative operations - finding smallest/largest walker

pr()

walkers = Wks2D([
    new stzWalker2D([1,1], [3,3], 1),
    new stzWalker2D([1,1], [2,2], 1),
    new stzWalker2D([1,1], [5,5], 2)
])

oSmallestWalker = walkers.SmallestWalker()

	? @@(oSmallestWalker.StartPosition())
	#--> [ 1, 1 ]

	? @@(oSmallestWalker.EndPosition())
	#--> [ 2, 2 ]

oLargestWalker = walkers.LargestWalker()

	? @@(oLargestWalker.StartPosition())
	#--> [ 1, 1 ]

	? @@(oLargestWalker.EndPosition())
	#--> [ 5, 5 ]

pf()
# Executed in 0.20 second(s) in Ring 1.22

/*--- Working with walker steps and equality

pr()

w1 = new stzWalker2D([0,0], [2,2], 1)
w2 = new stzWalker2D([0,0], [2,2], 1)
w3 = new stzWalker2D([1,1], [3,3], 1)
w4 = new stzWalker2D([0,0], [2,2], 2)

walkers = Wks2D([w1, w2, w3, w4])

# All walkers use the same steps?
? walkers.AllWalkersHaveSameSteps()
#--> FALSE

oSameStepWalkers = Wks2D([w1, w2, w3])
? oSameStepWalkers.AllWalkersHaveSameSteps()
#--> TRUE

# Walker 1 and 2 are equal
? walkers.WalkersEqual(1, 2)
#--> TRUE

? walkers.WalkersEqual(1, 3)
#--> FALSE

? walkers.WalkersEqual(1, 4)
#--> FALSE

pf()

# Executed in 0.25 second(s) in Ring 1.22

/*--- Walkable positions analysis

pr()

w1 = new stzWalker2D([1,1], [2,2], 1)
w2 = new stzWalker2D([1,1], [2,1], 1)
w3 = new stzWalker2D([2,1], [2,2], 1)

o1 = Wks2D([w1, w2, w3])

? @@NL( o1.Walkables() ) + NL
#--> [
#	[
#		[ 1, 1 ],
#		[ 2, 1 ],
#		[ 1, 2 ],
#		[ 2, 2 ]
#	],
#	[
#		[ 1, 1 ],
#		[ 2, 1 ]
#	],
#	[
#		[ 2, 1 ],
#		[ 2, 2 ]
#	]
# ]


? @@( o1.CommonWalkables() ) + NL
#--> [ [ 2, 1 ] ]

# Merged walkable positions (unique)

? @@(o1.MergedWalkables())
#--> [ [ 1, 1 ], [ 1, 2 ], [ 2, 1 ], [ 2, 2 ] ]

pf()
# Executed in 0.20 second(s) in Ring 1.22

/*--- Walking operations

pr()

? IsWalker2D([ [0,0], [2,2] ])
#--> FALSE

w1 = new stzWalker2D([0,0], [2,2], 1)
#--> ERROR: Incorrect param type! Start and end positions must not contain zeros.

pf()

/*---

pr()

w1 = new stzWalker2D([1, 1], [3, 3], 1)
w2 = new stzWalker2D([2, 2], [4, 4], 1)

o1 = Wks2D([ w1, w2 ])

? @@(o1.Walkables()) + Nl
#--> [
#	[
#		[ 1, 1 ], [ 2, 1 ], [ 3, 1 ],
#		[ 1, 2 ], [ 2, 2 ], [ 3, 2 ],
#		[ 1, 3 ], [ 2, 3 ], [ 3, 3 ]
#	],
#	[
#		[ 2, 2 ], [ 3, 2 ], [ 4, 2 ],
#		[ 2, 3 ], [ 3, 3 ], [ 4, 3 ],
#		[ 2, 4 ], [ 3, 4 ], [ 4, 4 ]
#	]
# ]

? @@( o1.CurrentPositions() )
#--> [ [ 1, 1 ], [ 2, 2 ] ]

o1.WalkAllNSteps(2)

? @@( o1.CurrentPositions() )
#--> [ [ 3, 1 ], [ 4, 2 ] ]

o1.WalkAllToEnd()
? @@( o1.CurrentPositions() )
#--> [ [ 3, 3 ], [ 4, 4 ] ]

o1.RestartAllWalkers()
? @@( o1.CurrentPositions() )
#--> [ [ 1, 1 ], [ 2, 2 ] ]

pf()
# Executed in 0.13 second(s) in Ring 1.22

/*--- Setting positions and walking to specific positions

pr()

w1 = new stzWalker2D([ 1, 1 ], [ 3, 3 ], 1)
w2 = new stzWalker2D([ 2, 2 ], [ 4, 4 ], 1)

o1 = Wks2D([ w1, w2 ])

o1.SetCurrentPosition(3, 3)
? @@( o1.CurrentPositions() )
#--> [ [ 2, 2 ], [ 2, 2 ] ]

#--> After setting position to [1,1]:
#--> Walker 1: [1,1]
#--> Walker 2: [1,1]

# This will only move walkers that can reach [ 3, 3 ]

o1.WalkIfPossible(3, 3)
? @@( o1.CurrentPositions() ) + NL
#--> [ [ 3, 3 ], [ 3, 3 ] ]

# Try a position outside some walkers' range

try
    walkers.SetAllToPosition(4, 4)
catch
    ? "Error: Position out of range for some walkers"
end
#--> Error: Position out of range for some walkers

pf()
# Executed in 0.13 second(s) in Ring 1.22

/*--- Bounding box and visualization

pr()

w1 = new stzWalker2D([1,1], [3,3], 1)
w2 = new stzWalker2D([2,2], [4,4], 1)

o1 = Wks2D([w1, w2])

? o1.ContainsPosition(1, 1)
#--> TRUE

? o1.ContainsPosition(4, 4)
#--> TRUE

? @@(o1.WalkersAtPosition(3, 3)) = NL
#--> [ 1, 2 ]

# Visual representation of walkers
o1.Show() + NL
#-->
#     1  2  3  4 
#   ╭──v──v───────╮
# 1 │ x1  1  1  . │
# 2 │  1 x2  *  2 │
# 3 │  1  *  *  2 │
# 4 │  .  2  2 E2 │
#   ╰─────────────╯

? o1.Legend()
#-->
#   . = Empty position
# 1-9 = Walker's walkable position
#   * = Overlapping walkable positions
#  x# = Current position of walker #
#  S# = Start position of walker #
#  E# = End position of walker #
# v/> = Markers of current positions on grid borders

pf()
# Executed in 0.14 second(s) in Ring 1.22

/*--- Finding walkers

pr()

w1 = new stzWalker2D([1,1], [3,3], 1)
w2 = new stzWalker2D([1,1], [3,3], 1)
w3 = new stzWalker2D([3,3], [6,6], 1)

walkers = Wks([w1, w2, w3])
//? @@( walkers.Walkables() ) + NL
#--> [
#	[
#		[ 1, 1 ], [ 2, 1 ], [ 3, 1 ],
#		[ 1, 2 ], [ 2, 2 ], [ 3, 2 ],
#		[ 1, 3 ], [ 2, 3 ], [ 3, 3 ]
#	],
#	[
#		[ 1, 1 ], [ 2, 1 ], [ 3, 1 ],
#		[ 1, 2 ], [ 2, 2 ], [ 3, 2 ],
#		[ 1, 3 ], [ 2, 3 ], [ 3, 3 ]
#	],
#	[
#		[ 3, 3 ], [ 4, 3 ], [ 5, 3 ], [ 6, 3 ],
#		[ 3, 4 ], [ 4, 4 ], [ 5, 4 ], [ 6, 4 ],
#		[ 3, 5 ], [ 4, 5 ], [ 5, 5 ], [ 6, 5 ],
#		[ 3, 6 ], [ 4, 6 ], [ 5, 6 ], [ 6, 6 ]
#	]
# ]

# Walkable position [1,1] is walked by walker1
# in position 1 and walker2 in position 1

? @@(walkers.FindWalkable([1,1])) + NL
#--> [ [ 1, 1 ], [ 2, 1 ] ]

# Finding walkables [1, 1] and [3,3]

? @@(walkers.FindWalkables([ [1,1], [3,3] ])) + NL
#--> [ [ 1, 1 ], [ 1, 9 ], [ 2, 1 ], [ 2, 9 ], [ 3, 1 ] ]

# What are the walkables that walks on a given section of the grid

? @@( walkers.FindWalkersInSection([1,1] , [3, 3]) ) + NL
#--> [ 1, 2 ]	~> Walkers 1 and 2


# Walkers intersecting path from [1,1] to [5,5]

? @@(walkers.FindWalkersIntersectingPath([ [1, 1], [5, 5] ] ))
#--> [ 1, 2, 3 ]
#~> Walkers 1, 2 and 3 have walkable positions that overlap with the given path.
#~> Helps you identify walkers that could potentially cross or interact with a given path

pf()
# Executed in 0.27 second(s) in Ring 1.22

/*--- Edge cases - Empty list of walkers

pr()

emptyWalkers = Wks([])
#--> ERROR: Can't create a stzListOfWalkers object!
# paoWalkers list must be a list of stzWalker or stzWalker2D objects.

pf()

/*--- Edge cases - Single walker

pr()

oSingleWalker = Wks2D([ new stzWalker2D([1,1], [3,3], 1) ])

? oSingleWalker.Size()
#--> 1

? oSingleWalker.AllWalkersHaveSameSteps()
#--> TRUE

? @@(oSingleWalker.CommonWalkablePositions())
#--> [
#	[ 1, 1 ], [ 2, 1 ], [ 3, 1 ],
#	[ 1, 2 ], [ 2, 2 ], [ 3, 2 ],
#	[ 1, 3 ], [ 2, 3 ], [ 3, 3 ]
# ]

pf()
# Executed in 0.07 second(s) in Ring 1.22

/*--- Edge cases - Walkers with different step types

pr()

w1 = new stzWalker2D([1, 1], [3, 3], 1)            // Single step
w2 = new stzWalker2D([1, 1], [3, 3], [1, 2, 1])    // List of steps

oMixedStepWalkers = Wks2D([w1, w2])

? oMixedStepWalkers.AllWalkersHaveSameSteps()
#--> FALSE


? oMixedStepWalkers.MostCommonStep()
#--> 1

? oMixedStepWalkers.WalkersWithStep(1).Size()
#--> 1

pf()

/*--- Edge cases - Invalid operations

pr()

w1 = new stzWalker2D([1,1], [3,3], 1)
w2 = new stzWalker2D([2,2], [4,4], 1)

walkers = Wks2D([w1, w2])

try
    walkers.Walker(3)
    ? "This should not be reached"
catch
    ? "Error: Index out of range"
end
#--> Error: Index out of range

try
    walkers.Walker(0)
    ? "This should not be reached"
catch
    ? "Error: Index out of range"
end
#--> Error: Index out of range

try
    walkers.WalkToPosition(5, 5)
    ? "This should not be reached"
catch
    ? "Error: Position not walkable"
end
#--> Error: Position not walkable

pf()
# Executed in 0.13 second(s) in Ring 1.22

/*--- Edge cases - Creating with invalid parameters

pr()

try
    invalidWalkers = Wks2D("not a list")
    ? "This should not be reached"
catch
    ? "Error: Invalid parameter type"
end
#--> Error: Invalid parameter type

try
    invalidWalkers = Wks2D([1, 2, 3])
    ? "This should not be reached"
catch
    ? "Error: Items must be stzWalker2D objects"
end
#--> Error: Items must be stzWalker2D objects

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Visualization with multiple walkers

pr()

w1 = new stzWalker2D([1,1], [4,4], 1)
w2 = new stzWalker2D([3,3], [6,6], 1)

Wks2D([w1, w2]) {

	# Set different positions for each walker

	Walker(1).WalkTo(2, 3)
	walker(2).WalkTo(4, 5)

	Show()
	#-->
	#       1  2  3  4  5  6 
	#    ╭─────v─────v───────╮
	#  1 │ S1  1  1  1  .  . │
	#  2 │  1  1  1  1  .  . │
	#  3 >  1 x1 S2  *  2  2 │
	#  4 │  1  1  *  *  2  2 │
	#  5 >  .  .  2 x2  2  2 │
	#  6 │  .  .  2  2  2 E2 │
	#    ╰───────────────────╯

	? Legend()
	#-->
	#   . = Empty position
	# 1-9 = Walker's walkable position
	#   * = Overlapping walkable positions
	#  x# = Current position of walker #
	#  S# = Start position of walker #
	#  E# = End position of walker #
	# v/> = Markers of current positions on grid borders

}

pf()
# Executed in 0.16 second(s) in Ring 1.22

/*--- Working with different step patterns
*/
pr()

// Create walkers with different step patterns
w1 = new stzWalker2D([1,1], [3,3], 1)        // Constant step of 1
w2 = new stzWalker2D([1,1], [5,5], 2)        // Constant step of 2
w3 = new stzWalker2D([1,1], [4,4], [1,2,1])  // Variable step pattern

walkers = Wks2D([w1, w2, w3])

// Walk each 3 steps and check positions
walkers.WalkAllNSteps(3)

? @@(walkers.CurrentPositions())
#--> [ [ 1, 2 ], [ 2, 2 ], [ 1, 2 ] ]

pf()
