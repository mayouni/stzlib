load "../max/stzmax.ring"

/*====

pr()

# Basic walkable positions with step size 1

oWalker = new stzWalker2D(1, 1, 5, 5, 1)

? @@( oWalker.Walkables() ) + NL
#--> [ [1,1], [2,1], [3,1], [4,1], [5,1], [5,2], [5,3], [5,4], [5,5] ]

# Current position

? @@( oWalker.Position() )
#--> Current position: [1,1]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

# Testing variable step sizes
w = new stzWalker2D(0, 0, 6, 6, 2)

? "TEST: Walkable positions with step size 2:"
? @@( w.Walkables() )
#--> [ [0,0], [2,0], [4,0], [6,0], [6,2], [6,4], [6,6] ]

? "Walking sequence:"
? @@( w.Position() )  #--> [0,0]
w.Walk()
? @@( w.Position() )  #--> [2,0]
w.WalkN(2)
? @@( w.Position() )  #--> [6,0]
w.Walk()
? @@( w.Position() )  #--> [6,2]

pf()
# Executed in almost 0 second(s)

/*---

pr()

# Testing initialization with list parameters
oW = new stzWalker2D([
    :StartAt = [3, 3],
    :EndAt = [10, 10],
    :Steps = 3
])

? "TEST: Walker initialized with named parameters:"
? "Start: " + @@( oW.StartPosition() )  #--> Start: [3,3]
? "End: " + @@( oW.EndPosition() )      #--> End: [10,10]
? "Step size: " + oW.NStep()            #--> Step size: 3
? "Walkables: " + @@( oW.Walkables() )  
#--> Walkables: [[3,3], [6,3], [9,3], [9,6], [9,9], [10,10]]

pf()
# Executed in almost 0 second(s)

/*---

pr()

# Testing directional walking
walker = new stzWalker2D(5, 5, 15, 15, 1)
walker.SetAllowDiagonal(TRUE)

? "TEST: Directional walking:"
? "Initial position: " + @@( walker.Position() )  #--> Initial position: [5,5]

walker.SetDirection(:Right)
walker.Walk()
? "After walking right: " + @@( walker.Position() )  #--> After walking right: [6,5]

walker.SetDirection(:DownRight)
walker.Walk()
? "After walking down-right: " + @@( walker.Position() )  #--> After walking down-right: [7,6]

walker.WalkUpRight()
? "After walking up-right: " + @@( walker.Position() )  #--> After walking up-right: [8,5]

pf()
# Executed in almost 0 second(s)

/*---

pr()

# Testing variant steps
oPath = new stzWalker2D(0, 0, 10, 10, [ [1,1], [2,0], [0,2] ])

? "TEST: Walker with variant steps:"
? @@( oPath.Walkables() )
#--> [[0,0], [1,1], [3,1], [3,3], [5,3], [5,5], [7,5], [7,7], [9,7], [9,9], [10,10]]

? "Is using variant steps: " + oPath.IsVariantSteps()  #--> Is using variant steps: TRUE

pf()
# Executed in almost 0 second(s)

/*---

pr()

# Testing walking to specific positions
w2d = new stzWalker2D(1, 1, 9, 9, 1)

? "TEST: Walking to specific positions:"
? "Initial: " + @@( w2d.Position() )  #--> Initial: [1,1]

w2d.WalkTo(5, 1)
? "After WalkTo(5,1): " + @@( w2d.Position() )  #--> After WalkTo(5,1): [5,1]

w2d.WalkTo([5, 5])
? "After WalkTo([5,5]): " + @@( w2d.Position() )  #--> After WalkTo([5,5]): [5,5]

w2d.WalkToEnd()
? "After WalkToEnd(): " + @@( w2d.Position() )  #--> After WalkToEnd(): [9,9]

w2d.WalkToStart()
? "After WalkToStart(): " + @@( w2d.Position() )  #--> After WalkToStart(): [1,1]

pf()
# Executed in almost 0 second(s)

/*---

pr()

# Testing walking back and history
walker = new stzWalker2D(0, 0, 5, 5, 1)

? "TEST: Walking back and history:"
walker.WalkN(3)
? "After walking 3 steps: " + @@( walker.Position() )  #--> After walking 3 steps: [3,0]

walker.WalkBack()
? "After walking back 1 step: " + @@( walker.Position() )  #--> After walking back 1 step: [2,0]

walker.WalkBackN(2)
? "After walking back 2 more steps: " + @@( walker.Position() )  #--> After walking back 2 more steps: [0,0]

? "Walk history count: " + walker.NumberOfWalks()  #--> Walk history count: 3

pf()
# Executed in almost 0 second(s)

/*--

pr()

# Testing path finding
pathFinder = new stzWalker2D(1, 1, 10, 10, 1)

? "TEST: Path finding:"
path = pathFinder.FindPathBetween(1, 1, 10, 10)
? "Path from [1,1] to [10,10]: " + @@(path)
#--> Path from [1,1] to [10,10]: [[1,1], [2,2], [3,3], [4,4], [5,5], [6,6], [7,7], [8,8], [9,9], [10,10]]

? "Finding path around obstacles (pretend [5,5] is blocked):"
# We'd need to customize the walkables for a real test here

pf()
# Executed in almost 0 second(s)

/*---

pr()

# Testing neighbors
w = new stzWalker2D(5, 5, 15, 15, 1)
w.SetAllowDiagonal(TRUE)

? "TEST: Finding neighbors:"
neighbors = w.NeighborsOf(6, 6)
? "Neighbors of [6,6] (with diagonals): " + @@(neighbors)
#--> Neighbors of [6,6] (with diagonals): [[6,5], [7,6], [6,7], [5,6], [7,5], [5,5], [7,7], [5,7]]

w.SetAllowDiagonal(FALSE)
neighbors = w.NeighborsOf(6, 6)
? "Neighbors of [6,6] (without diagonals): " + @@(neighbors)
#--> Neighbors of [6,6] (without diagonals): [[6,5], [7,6], [6,7], [5,6]]

pf()
# Executed in almost 0 second(s)

/*---

pr()

# Testing reset and positioning
walker = new stzWalker2D(0, 0, 10, 10, 2)

? "TEST: Reset functionality:"
walker.WalkN(3)
? "Position after walking 3 steps: " + @@( walker.Position() )  #--> Position after walking 3 steps: [6,0]

walker.Reset()
? "Position after reset: " + @@( walker.Position() )  #--> Position after reset: [0,0]

? "History count after reset: " + walker.NumberOfWalks()  #--> History count after reset: 0

pf()
# Executed in almost 0 second(s)

/*---
*/
pr()

# Testing visualization
w = new stzWalker2D(1, 1, 5, 5, 1)

? "TEST: Visualization:"
? w.DrawPath()
#--> Shows a grid representation with 'S' for start, 'E' for end, 
#    'C' for current position, 'o' for walkable positions, and '.' for other positions

pf()
# Executed in almost 0 second(s)

/*---

pr()

# Testing distance calculations
w = new stzWalker2D(0, 0, 10, 10, 1)

? "TEST: Distance calculations:"
? "Euclidean distance between [1,1] and [4,5]: " + w.DistanceBetween(1, 1, 4, 5)
#--> Euclidean distance between [1,1] and [4,5]: 5

? "Manhattan distance between [1,1] and [4,5]: " + w.ManhattanDistanceBetween(1, 1, 4, 5)
#--> Manhattan distance between [1,1] and [4,5]: 7

pf()
# Executed in almost 0 second(s)

/*---

pr()

# Testing position information
w = new stzWalker2D(3, 3, 8, 8, 1)

? "TEST: Position information:"
? "Total positions in boundary: " + w.NumberOfPositions()  #--> Total positions in boundary: 36
? "Walkable positions: " + w.NumberOfWalkablePositions()  #--> Walkable positions: 11
? "Unwalkable positions: " + w.NumberOfUnwalkablePositions()  #--> Unwalkable positions: 25

? "Position at index 5: " + @@( w.PositionAt(5) )  #--> Position at index 5: [7,3]
? "Index of position [5,5]: " + w.IndexOf(5, 5)  #--> Index of position [5,5]: 7

pf()
# Executed in almost 0 second(s)

/*---

pr()

# Testing walking between positions
w = new stzWalker2D(1, 1, 9, 9, 1)

? "TEST: Walking between positions:"
segment = w.WalkBetween(3, 3, 6, 6)
? "Path between [3,3] and [6,6]: " + @@(segment)
#--> Path between [3,3] and [6,6]: [[3,3], [4,4], [5,5], [6,6]]

? "Current position after segment walk: " + @@( w.Position() )
#--> Current position after segment walk: [6,6]

pf()
# Executed in almost 0 second(s)
