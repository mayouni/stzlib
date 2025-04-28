load "../max/stzmax.ring"


/*--- Testing basic grid initialization and movement

pr()

o1 = new stzGrid([5, 5])

# Grid Size

? o1.NumberOfRows()
#--> 5

? o1.NumberOfColumns() + NL
#--> 5

# Current Position

? @@(o1.CurrentPosition()) + NL
#--> [ 1, 1 ]

# Moving down twice...

o1.MoveDown()
o1.MoveDown()
? @@( o1.CurrentPosition() ) + NL
#--> [ 1, 3 ]

#Moving right three times...

o1.MoveRight()
o1.MoveRight()
o1.MoveRight()

? @@( o1.CurrentPosition() ) + NL
#--> [ 4, 3 ]

o1.Show()
#-->
#     1 2 3 4 5 
#   ╭───────v───╮
# 1 │ . . . . . │
# 2 │ . . . . . │
# 3 > . . . x . │
# 4 │ . . . . . │
# 5 │ . . . . . │
#   ╰───────────╯

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing hitting the right boundary

pr()

o1 = new stzGrid([6, 4])
? @@( o1.SizeXY() )
#--> [ 6, 4 ]

# Moving right to edge

o1.GoTo(6, 1)
? @@(o1.Position())
#--> [ 6, 1 ]

# Moving right one more (hits boundary and does not move)

o1.MoveRight()
? @@(o1.Position())
#--> [ 6, 1 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing different movement directions
*/
pr()

o1 = new stzGrid([5, 5])
? @@(o1.SizeXY()) + NL

# Moving to center of grid

o1.GoTo(3, 3) + NL
o1.Show() + NL
#-->
#     1 2 3 4 5 
#   ╭─────v─────╮
# 1 │ . . . . . │
# 2 │ . . . . . │
# 3 > . . x . . │
# 4 │ . . . . . │
# 5 │ . . . . . │
#   ╰───────────╯

# Ajacent positions (above, below, left, right)

? @@( o1.NodeAboveLeft() )
#--> [ 2, 2 ]

? @@( o1.NodeAbove() )
#--> [ 3, 2 ]

? @@( o1.NodeAboveRight() ) + NL
#--> [ 4, 2 ]

#--

? @@( o1.NodeToLeft() )
#--> [ 2, 3 ]

? @@( o1.NodeToRight() ) + NL
#--> [ 4, 3 ]

#--

? @@( o1.NodeBelowLeft() )
#--> [ 2, 4 ]

? @@( o1.NodeBelow() )
#--> [ 3, 4 ]

? @@( o1.NodeBelowRight() ) + NL
#--> [ 4, 4 ]

# Adjacent Neighbors

? @@( o1.AdjacentNodes() ) + NL
#--> [ [ 2, 2 ], [ 2, 3 ], [ 2, 4 ], [ 3, 2 ], [ 3, 4 ], [ 4, 2 ], [ 4, 3 ], [ 4, 4 ] ]

// o1.PaintNighbors() #TODO

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Testing forward/backward movement

pr()

o1 = new stzGrid([3, 4])
? "Grid Size: " + o1.NumberOfRows() + "x" + o1.NumberOfColumns()
? "Default Direction: " + o1.Direction()

? "Starting position:"
o1.Show()

? "Moving forward three times..."
o1.MoveForward()
o1.MoveForward()
o1.MoveForward()
? "New Position: " + o1.CurrentRow() + "," + o1.CurrentColumn()
o1.Show()

? "Moving backward twice..."
o1.MoveBackward()
o1.MoveBackward()
? "New Position: " + o1.CurrentRow() + "," + o1.CurrentColumn()
o1.Show()

pf()

/*--- Testing grid traversal and iteration

pr()

o1 = new stzGrid([3, 3])
? "Grid Size: " + o1.NumberOfRows() + "x" + o1.NumberOfColumns()

? "Getting all positions:"
aPositions = o1.Positions()
for i = 1 to len(aPositions)
    ? "  Position " + i + ": " + aPositions[i][1] + "," + aPositions[i][2]
next

? "Traversing grid in right direction from (0,0):"
o1.GoTo(0, 0)
o1.SetDirection(:right)
o1.TraverseInDirection(:right, func(row, col)
    ? "  Visit: " + row + "," + col
    if col = 1  # Stop after column 1
        return FALSE
    ok
    return TRUE
})

o1.Show()

pf()

/*--- Testing distance calculations

pr()

o1 = new stzGrid([10, 10])
? "Grid Size: " + o1.NumberOfRows() + "x" + o1.NumberOfColumns()

o1.GoTo(3, 3)
? "Current Position: " + o1.CurrentRow() + "," + o1.CurrentColumn()

targetRow = 7
targetCol = 6
? "Target Position: " + targetRow + "," + targetCol

? "Manhattan Distance: " + o1.DistanceTo(targetRow, targetCol)
? "Euclidean Distance: " + o1.EuclideanDistanceTo(targetRow, targetCol)

? "Moving using MoveBy..."
o1.MoveBy(4, 3)  # Move 4 rows down, 3 columns right
? "New Position: " + o1.CurrentRow() + "," + o1.CurrentColumn()

o1.Show()

pf()

/*--- Testing edge cases and boundary conditions

pr()

o1 = new stzGrid([2, 3])
? "Grid Size: " + o1.NumberOfRows() + "x" + o1.NumberOfColumns()

? "Testing boundary movement (NoWrap mode):"
o1.DisableWrapping()
o1.GoTo(0, 0)
? "Current Position: " + o1.CurrentRow() + "," + o1.CurrentColumn()
o1.Show()

? "Moving left (should hit boundary)..."
result = o1.MoveLeft()
? "Result: " + (result = NULL ? "NULL (boundary hit)" : "Movement successful")

? "Moving up (should hit boundary)..."
result = o1.MoveUp()
? "Result: " + (result = NULL ? "NULL (boundary hit)" : "Movement successful")

? "Going to bottom-right corner..."
o1.GoTo(1, 2)
? "Current Position: " + o1.CurrentRow() + "," + o1.CurrentColumn()
o1.Show()

? "Moving right (should hit boundary)..."
result = o1.MoveRight()
? "Result: " + (result = NULL ? "NULL (boundary hit)" : "Movement successful")

? "Moving down (should hit boundary)..."
result = o1.MoveDown()
? "Result: " + (result = NULL ? "NULL (boundary hit)" : "Movement successful")

pf()

/*--- Testing direction changes and movement combinations

pr()

o1 = new stzGrid([4, 4])
? "Grid Size: " + o1.NumberOfRows() + "x" + o1.NumberOfColumns()

? "Starting at center..."
o1.GoTo(1, 1)
o1.Show()

? "Current Direction: " + o1.Direction()
? "Setting direction to :down"
o1.SetDirection(:down)
? "New Direction: " + o1.Direction()

? "Moving in current direction (down)..."
o1.GoToNextPosition()
? "New Position: " + o1.CurrentRow() + "," + o1.CurrentColumn()
o1.Show()

? "Going back to previous position (up)..."
o1.GoToPreviousPosition()
? "New Position: " + o1.CurrentRow() + "," + o1.CurrentColumn()
o1.Show()

? "Changing direction to :right and moving"
o1.SetDirection(:right)
o1.GoToNextPosition()
? "New Position: " + o1.CurrentRow() + "," + o1.CurrentColumn()
o1.Show()

pf()
