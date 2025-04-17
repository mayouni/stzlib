load "../max/stzmax.ring"

/*===== Initialization Tests
# Tests the creation of stzWalker2D objects with
# various parameters and error conditions.

/*--

pr()

# Basic initialization with step size 1
w = new stzWalker2D([1, 1], [5, 5], 1)

? @@( w.Walkables() ) + NL
#--> [ [ 1, 1 ], [ 2, 1 ], [ 3, 1 ], [ 4, 1 ], [ 5, 1 ], [ 5, 2 ], [ 5, 3 ], [ 5, 4 ], [ 5, 5 ] ]

w.WalkNSteps(4) + NL

? @@( w.Position() )
w.Show()

pf()

/*---
*/
pr()

n = -10
m = 17

? @@( Swap(n, m) )
#--> [ 17, -10 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--
*/

pr()

# Basic initialization with step size 1
w = new stzWalker2D([5, 5], [1, 1], 1)
? w.Direction()
? @@( w.Walkables() ) + NL
#--> [ [ 1, 1 ], [ 2, 1 ], [ 3, 1 ], [ 4, 1 ], [ 5, 1 ], [ 5, 2 ], [ 5, 3 ], [ 5, 4 ], [ 5, 5 ] ]
dfdf
w.WalkNSteps(4) + NL

? @@( w.Position() )
w.Show()

pf()

/*-- Initialization with named parameters

oW = new stzWalker2D(:StartAt = [3, 3], :EndAt = [10, 10], :Steps = 3)

? @@( oW.StartPosition() )  #--> [3,3]
? @@( oW.EndPosition() )    #--> [10,10]
? oW.NStep()                #--> 3

pf()

#--- Error case: Same start and end position

try
    wErr = new stzWalker2D([1, 1], [1, 1], 1)
catch
    ? "Error caught: Same start and end position"
end

# Error case: Zero step size
try
    wErr = new stzWalker2D([1, 1], [5, 5], 0)
catch
    ? "Error caught: Zero step size"
end

pf()

/*=====
# Walkable Positions Tests
# Verifies the generation of walkable positions with constant and variant steps.

pr()
? "=== Walkable Positions Tests ==="

# Walkables with constant step size 2
w = new stzWalker2D([1, 1], [6, 6], 2)
? "Walkables with step size 2:"
? @@( w.Walkables() ) + NL
#--> [ [1,1], [1,3], [1,5], [3,5], [5,5], [6,6] ]

# Walkables with variant steps
oPath = new stzWalker2D([0, 0], [10, 10], [ [1,1], [2,0], [0,2] ])
? "Walkables with variant steps [ [1,1], [2,0], [0,2] ]:"
? @@( oPath.Walkables() ) + NL
#--> [ [0,0], [1,1], [3,1], [3,3], [4,4], [6,4], [6,6], [7,7], [9,7], [9,9], [10,10] ]

pf()

/*=====
# Walking Tests
# Tests basic walking operations, including forward and specific position movements.

pr()
? "=== Walking Tests ==="

w = new stzWalker2D([1, 1], [9, 9], 1)
? "Initial position:"
? @@( w.Position() )  #--> [1,1]

# Basic walking forward
w.Walk()
? "After Walk():"
? @@( w.Position() )  #--> [2,1]

# Walking multiple steps
w.WalkNSteps(3)
? "After WalkNSteps(3):"
? @@( w.Position() )  #--> [5,1]

# Walking to specific position
w.WalkTo(5, 5)
? "After WalkTo(5, 5):"
? @@( w.Position() )  #--> [5,5]

# Walking to end and start
w.WalkToEnd()
? "After WalkToEnd():"
? @@( w.Position() )  #--> [9,9]
w.WalkToStart()
? "After WalkToStart():"
? @@( w.Position() )  #--> [1,1]

pf()

/*=====
# Directional Walking Tests
# Tests walking in specific directions, including diagonal movements.

pr()
? "=== Directional Walking Tests ==="

walker = new stzWalker2D([5, 5], [15, 15], 1)
walker.SetAllowDiagonal(TRUE)
? "Initial position:"
? @@( walker.Position() )  #--> [5,5]

# Walking right
walker.SetDirection(:Right)
walker.Walk()
? "After walking right:"
? @@( walker.Position() )  #--> [6,5]

# Walking diagonally down-right
walker.SetDirection(:DownRight)
walker.Walk()
? "After walking down-right:"
? @@( walker.Position() )  #--> [7,6]

# Walking up-right
walker.WalkUpRight()
? "After walking up-right:"
? @@( walker.Position() )  #--> [8,5]

# Error case: Invalid direction
try
    walker.SetDirection(:Invalid)
    walker.Walk()
catch
    ? "Error caught: Invalid direction"
end

pf()

/*=====
# History and Reset Tests
# Verifies walking history and reset functionality.

pr()
? "=== History and Reset Tests ==="

walker = new stzWalker2D([1, 1], [5, 5], 1)
walker.WalkN(3)
? "After WalkN(3):"
? @@( walker.Position() )  #--> [1,4]
? "Number of walks:"
? walker.NumberOfWalks()   #--> 3

walker.WalkBack()
? "After WalkBack():"
? @@( walker.Position() )  #--> [1,3]

walker.Reset()
? "After Reset():"
? @@( walker.Position() )  #--> [1,1]
? "Number of walks after reset:"
? walker.NumberOfWalks()   #--> 0

pf()

/*=====
# Neighbors Tests
# Tests the retrieval of neighboring positions with and without diagonals.

pr()
? "=== Neighbors Tests ==="

w = new stzWalker2D([5, 5], [15, 15], 1)
w.SetAllowDiagonal(TRUE)
? "Neighbors of [6,6] with diagonals:"
? @@( w.NeighborsOf(6, 6) )  #--> [ [5,5], [5,6], [5,7], [6,5], [6,7], [7,5], [7,6], [7,7] ]

w.SetAllowDiagonal(FALSE)
? "Neighbors of [6,6] without diagonals:"
? @@( w.NeighborsOf(6, 6) )  #--> [ [5,6], [6,5], [6,7], [7,6] ]

pf()

/*=====
# Distance Calculation Tests
# Tests Euclidean and Manhattan distance calculations.

pr()
? "=== Distance Calculation Tests ==="

w = new stzWalker2D([1, 1], [10, 10], 1)
? "Euclidean distance between [1,1] and [4,5]:"
? @@( w.DistanceBetween([1, 1], [4, 5]) )  #--> 5
? "Manhattan distance between [1,1] and [4,5]:"
? w.ManhattanDistanceBetween([1, 1], [4, 5])  #--> 7

pf()

/*=====
# Visualization Tests
# Tests the visualization of the walker's path and grid.

pr()
? "=== Visualization Tests ==="

w = new stzWalker2D([1, 1], [5, 5], 1)
? "Initial grid:"
? w.Show()
w.WalkNSteps(4)
? "Grid after WalkNSteps(4):"
? w.Show()

oPath = new stzWalker2D([0, 0], [6, 6], [ [1,1], [2,0] ])
? "Path with variant steps [ [1,1], [2,0] ]:"
? oPath.ShowPath()

pf()

/*=====
# Edge Case Tests
# Tests edge cases such as walking beyond end and large grids.

pr()
? "=== Edge Case Tests ==="

w = new stzWalker2D([1, 1], [5, 5], 1)
w.WalkNSteps(10)  # Attempt to walk beyond end
? "Position after walking 10 steps (beyond end):"
? @@( w.Position() )  #--> [5,5]

# Large grid test
wLarge = new stzWalker2D([1, 1], [100, 100], 5)
? "Walkables in large grid (partial output):"
? @@( wLarge.Walkables()[1:5] )  # Show first 5 for brevity
wLarge.WalkNSteps(3)
? "Position after 3 steps in large grid:"
? @@( wLarge.Position() )

pf()

/*=====
# Practical Use Case Tests
# Tests practical scenarios like obstacle navigation.

pr()
? "=== Practical Use Case Tests ==="

# Simple obstacle navigation
w = new stzWalker2D([1, 1], [5, 5], 1)
? "Initial path to [5,5]:"
? @@( w.WalkBetween([1, 1], [5, 5]) )
# Simulate obstacle at [3,3] by manually checking path
path = w.WalkBetween([1, 1], [5, 5])
for pos in path
    if pos[1] = 3 and pos[2] = 3
        ? "Obstacle detected at [3,3], rerouting..."
        w.WalkTo(2, 4)  # Move around obstacle
        exit
    ok
next
? "Position after rerouting:"
? @@( w.Position() )

pf()
