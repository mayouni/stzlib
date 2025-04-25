/*=============================================
 * SOFTANZA LIBRARY - STZLISTOFWALKERS2D TESTS
 *=============================================
 * This file contains comprehensive tests for the stzListOfWalkers2D class
 * demonstrating various features, functionalities, and edge cases.
 */

load "../max/stzmax.ring"

/*--- Initialize with factory functions WksIn2D() and StzListOfWalkers2DQ()

pr()

# Create individual walkers first

w1 = new stzWalker2D([0,0], [2,2], 1)
w2 = new stzWalker2D([1,1], [3,3], 1)
w3 = new stzWalker2D([0,0], [4,4], 2)

# Create a list of walkers using factory functions

walkers1 = WksIn2D([w1, w2])
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
*/
pr()

walkers = WksIn2D([
    new stzWalker2D([0,0], [2,2], 1),
    new stzWalker2D([1,1], [3,3], 1),
    new stzWalker2D([0,0], [4,4], 2)
])

? @@(walkers.FirstWalker().StartPosition())
#--> First walker start position: [0,0]

? @@(walkers.LastWalker().EndPosition())
#--> Last walker end position: [4,4]

? @@(walkers.Walker(2).Steps())
#--> Walker at position 2 step size: 1

pf()
/*--- Add and remove walkers

pr()

walkers = WksIn2D([new stzWalker2D([0,0], [2,2], 1)])

? "Initial size: " + walkers.Size()
#--> Initial size: 1

walkers.AddWalker(new stzWalker2D([1,1], [3,3], 1))
? "Size after adding one walker: " + walkers.Size()
#--> Size after adding one walker: 2

walkers.AddWalkers([
    new stzWalker2D([0,0], [4,4], 2),
    new stzWalker2D([5,5], [7,7], 1)
])
? "Size after adding multiple walkers: " + walkers.Size()
#--> Size after adding multiple walkers: 4

walkers.RemoveWalker(2)
? "Size after removing one walker: " + walkers.Size()
#--> Size after removing one walker: 3

walkers.RemoveFirstWalker()
? "Size after removing first walker: " + walkers.Size()
#--> Size after removing first walker: 2

walkers.RemoveLastWalker()
? "Size after removing last walker: " + walkers.Size()
#--> Size after removing last walker: 1

pf()
/*--- Comparative operations - finding smallest/largest walker

pr()

walkers = WksIn2D([
    new stzWalker2D([0,0], [2,2], 1),   // 9 positions total
    new stzWalker2D([0,0], [1,1], 1),   // 4 positions total
    new stzWalker2D([0,0], [4,4], 2)    // 9 positions total but larger steps
])

smallestGridWalker = walkers.WalkerWithSmallestGrid()
? "Smallest grid walker bounds: " + @@(smallestGridWalker.StartPosition()) + " to " + @@(smallestGridWalker.EndPosition())
#--> Smallest grid walker bounds: [0,0] to [1,1]

largestGridWalker = walkers.WalkerWithLargestGrid()
? "Largest grid walker bounds: " + @@(largestGridWalker.StartPosition()) + " to " + @@(largestGridWalker.EndPosition())
#--> Largest grid walker bounds: [0,0] to [4,4]

// Note: These methods count walkable positions, which may differ from grid size
smallestWalker = walkers.SmallestWalker()
? "Smallest walker bounds: " + @@(smallestWalker.StartPosition()) + " to " + @@(smallestWalker.EndPosition())
#--> Smallest walker bounds: [0,0] to [1,1]

largestWalker = walkers.LargestWalker()
? "Largest walker bounds: " + @@(largestWalker.StartPosition()) + " to " + @@(largestWalker.EndPosition())
#--> Largest walker bounds: [0,0] to [2,2]

pf()
/*--- Working with walker steps and equality

pr()

w1 = new stzWalker2D([0,0], [2,2], 1)
w2 = new stzWalker2D([0,0], [2,2], 1)
w3 = new stzWalker2D([1,1], [3,3], 1)
w4 = new stzWalker2D([0,0], [2,2], 2)

walkers = WksIn2D([w1, w2, w3, w4])

? "All walkers use the same steps? " + walkers.AllWalkersUseTheSameSteps()
#--> All walkers use the same steps? FALSE

sameStepWalkers = WksIn2D([w1, w2, w3])
? "These walkers use the same steps? " + sameStepWalkers.AllWalkersUseTheSameSteps()
#--> These walkers use the same steps? TRUE

? "Walker 1 and 2 are equal? " + walkers.WalkersEqual(1, 2)
#--> Walker 1 and 2 are equal? TRUE

? "Walker 1 and 3 are equal? " + walkers.WalkersEqual(1, 3)
#--> Walker 1 and 3 are equal? FALSE

? "Walker 1 and 4 are equal? " + walkers.WalkersEqual(1, 4)
#--> Walker 1 and 4 are equal? FALSE

pf()
/*--- Walkable positions analysis

pr()

w1 = new stzWalker2D([0,0], [1,1], 1)
w2 = new stzWalker2D([0,0], [1,0], 1)
w3 = new stzWalker2D([1,0], [1,1], 1)

walkers = WksIn2D([w1, w2, w3])

? "All walkable positions (all walkers): "
walkablePositions = walkers.WalkablePositions()
for position in walkablePositions
    ? "- " + @@(position)
next
#--> All walkable positions (all walkers):
#--> - [0,0]
#--> - [0,1]
#--> - [1,0]
#--> - [1,1]
#--> - [0,0]
#--> - [1,0]
#--> - [1,0]
#--> - [1,1]

? "Common walkable positions: "
commonPositions = walkers.CommonWalkablePositions()
for position in commonPositions
    ? "- " + @@(position)
next
#--> Common walkable positions:
#--> - [1,0]

? "Merged walkable positions (unique): "
mergedPositions = walkers.MergeWalkablePositions()
for position in mergedPositions
    ? "- " + @@(position)
next
#--> Merged walkable positions (unique):
#--> - [0,0]
#--> - [0,1]
#--> - [1,0]
#--> - [1,1]

pf()
/*--- Walking operations

pr()

w1 = new stzWalker2D([0,0], [2,2], 1)
w2 = new stzWalker2D([1,1], [3,3], 1)

walkers = WksIn2D([w1, w2])

? "Initial positions:"
for i = 1 to walkers.Size()
    ? "Walker " + i + ": " + @@(walkers.Walker(i).CurrentPosition())
next
#--> Initial positions:
#--> Walker 1: [0,0]
#--> Walker 2: [1,1]

walkers.WalkAllNSteps(2)
? "After walking 2 steps:"
for i = 1 to walkers.Size()
    ? "Walker " + i + ": " + @@(walkers.Walker(i).CurrentPosition())
next
#--> After walking 2 steps:
#--> Walker 1: [0,2]
#--> Walker 2: [1,3]

walkers.WalkAllToTheirEnd()
? "After walking to end:"
for i = 1 to walkers.Size()
    ? "Walker " + i + ": " + @@(walkers.Walker(i).CurrentPosition())
next
#--> After walking to end:
#--> Walker 1: [2,2]
#--> Walker 2: [3,3]

walkers.RestartAllWalkers()
? "After restarting:"
for i = 1 to walkers.Size()
    ? "Walker " + i + ": " + @@(walkers.Walker(i).CurrentPosition())
next
#--> After restarting:
#--> Walker 1: [0,0]
#--> Walker 2: [1,1]

pf()
/*--- Setting positions and walking to specific positions

pr()

w1 = new stzWalker2D([0,0], [2,2], 1)
w2 = new stzWalker2D([1,1], [3,3], 1)

walkers = WksIn2D([w1, w2])

walkers.SetCurrentPosition(1, 1)
? "After setting position to [1,1]:"
for i = 1 to walkers.Size()
    ? "Walker " + i + ": " + @@(walkers.Walker(i).CurrentPosition())
next
#--> After setting position to [1,1]:
#--> Walker 1: [1,1]
#--> Walker 2: [1,1]

// This will only move walkers that can reach [2,2]
walkers.WalkIfPossible(2, 2)
? "After walking if possible to [2,2]:"
for i = 1 to walkers.Size()
    ? "Walker " + i + ": " + @@(walkers.Walker(i).CurrentPosition())
next
#--> After walking if possible to [2,2]:
#--> Walker 1: [2,2]
#--> Walker 2: [2,2]

// Try a position outside some walkers' range
try
    walkers.SetAllToPosition(4, 4)
catch
    ? "Error: Position out of range for some walkers"
end
#--> Error: Position out of range for some walkers

pf()
/*--- Bounding box and visualization

pr()

w1 = new stzWalker2D([0,0], [2,2], 1)
w2 = new stzWalker2D([1,1], [3,3], 1)

walkers = WksIn2D([w1, w2])

boundingBox = walkers.BoundingBox()
? "Bounding box: " + @@(boundingBox)
#--> Bounding box: [0,0,3,3]

? "Contains position [1,1]: " + walkers.ContainsPosition(1, 1)
#--> Contains position [1,1]: TRUE

? "Contains position [4,4]: " + walkers.ContainsPosition(4, 4)
#--> Contains position [4,4]: FALSE

? "Walkers at position [1,1]: " + @@(walkers.WalkersAtPosition(1, 1))
#--> Walkers at position [1,1]: [1,2]

// Visual representation of walkers
? walkers.ToString()

pf()
/*--- Finding walkers

pr()

w1 = new stzWalker2D([0,0], [2,2], 1)
w2 = new stzWalker2D([1,1], [3,3], 1)
w3 = new stzWalker2D([4,4], [6,6], 1)

walkers = WksIn2D([w1, w2, w3])

? "Walkers containing position [1,1]: " + @@(walkers.FindWalkersContainingPositions([[1,1]]))
#--> Walkers containing position [1,1]: [1,2]

? "Walkers containing positions [1,1] and [2,2]: " + @@(walkers.FindWalkersContainingPositions([[1,1],[2,2]]))
#--> Walkers containing positions [1,1] and [2,2]: [1,2]

? "Walkers within bounding box [0,0,3,3]: " + @@(walkers.FindWalkersWithinBoundingBox(0, 0, 3, 3))
#--> Walkers within bounding box [0,0,3,3]: [1,2]

? "Walkers intersecting path [[1,1],[5,5]]: " + @@(walkers.FindWalkersIntersectingPath([[1,1],[5,5]]))
#--> Walkers intersecting path [[1,1],[5,5]]: [1,2,3]

pf()
/*--- Edge cases - Empty list of walkers

pr()

emptyWalkers = WksIn2D([])

? "Size of empty walkers: " + emptyWalkers.Size()
#--> Size of empty walkers: 0

? "Bounding box of empty walkers: " + @@(emptyWalkers.BoundingBox())
#--> Bounding box of empty walkers: [0,0,0,0]

? "Contains position [0,0]: " + emptyWalkers.ContainsPosition(0, 0)
#--> Contains position [0,0]: FALSE

? "Walkers at position [0,0]: " + @@(emptyWalkers.WalkersAtPosition(0, 0))
#--> Walkers at position [0,0]: []

try
    emptyWalkers.WalkerWithSmallestGrid()
    ? "This should not be reached"
catch
    ? "Error: Cannot find smallest grid in empty list"
end
#--> Error: Cannot find smallest grid in empty list

pf()
/*--- Edge cases - Single walker

pr()

singleWalker = WksIn2D([new stzWalker2D([0,0], [2,2], 1)])

? "Size: " + singleWalker.Size()
#--> Size: 1

? "All walkers use the same steps? " + singleWalker.AllWalkersUseTheSameSteps()
#--> All walkers use the same steps? TRUE

? "Bounding box: " + @@(singleWalker.BoundingBox())
#--> Bounding box: [0,0,2,2]

commonPositions = singleWalker.CommonWalkablePositions()
? "Common walkable positions count: " + len(commonPositions)
#--> Common walkable positions count: 9

pf()
/*--- Edge cases - Walkers with different step types

pr()

w1 = new stzWalker2D([0,0], [2,2], 1)            // Single step
w2 = new stzWalker2D([0,0], [2,2], [1, 2, 1])    // List of steps

mixedStepWalkers = WksIn2D([w1, w2])

? "All walkers use the same steps? " + mixedStepWalkers.AllWalkersUseTheSameSteps()
#--> All walkers use the same steps? FALSE

? "Most common step: " + @@(mixedStepWalkers.MostCommonStep())
#--> Most common step: 1

walkersWithStep1 = mixedStepWalkers.WalkersWithStep(1)
? "Number of walkers with step 1: " + walkersWithStep1.Size()
#--> Number of walkers with step 1: 1

pf()
/*--- Edge cases - Invalid operations

pr()

w1 = new stzWalker2D([0,0], [2,2], 1)
w2 = new stzWalker2D([1,1], [3,3], 1)

walkers = WksIn2D([w1, w2])

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
/*--- Edge cases - Creating with invalid parameters

pr()

try
    invalidWalkers = WksIn2D("not a list")
    ? "This should not be reached"
catch
    ? "Error: Invalid parameter type"
end
#--> Error: Invalid parameter type

try
    invalidWalkers = WksIn2D([1, 2, 3])
    ? "This should not be reached"
catch
    ? "Error: Items must be stzWalker2D objects"
end
#--> Error: Items must be stzWalker2D objects

pf()
/*--- Complex grid visualization with multiple walkers

pr()

w1 = new stzWalker2D([0,0], [3,3], 1)
w2 = new stzWalker2D([2,2], [5,5], 1)
w3 = new stzWalker2D([4,0], [4,4], 1)

walkers = WksIn2D([w1, w2, w3])

// Set different positions for each walker
w1.WalkTo(1, 2)
w2.WalkTo(3, 4)
w3.WalkTo(4, 2)

? walkers.ToString()

pf()
/*--- Working with different step patterns

pr()

// Create walkers with different step patterns
w1 = new stzWalker2D([0,0], [2,2], 1)        // Constant step of 1
w2 = new stzWalker2D([0,0], [4,4], 2)        // Constant step of 2
w3 = new stzWalker2D([0,0], [3,3], [1,2,1])  // Variable step pattern

walkers = WksIn2D([w1, w2, w3])

// Walk each 3 steps and check positions
walkers.WalkAllNSteps(3)

? "Positions after 3 steps:"
for i = 1 to walkers.Size()
    ? "Walker " + i + ": " + @@(walkers.Walker(i).CurrentPosition())
next
#--> Positions after 3 steps:
#--> Walker 1: [1,2]
#--> Walker 2: [2,2]
#--> Walker 3: [2,2]

pf()
