# Beyond Inner Loops: Walking on the Second Dimension in Softanza

Building upon the innovative `stzWalker` paradigm, Softanza's `stzWalker2D` elevates traversal to new dimensions by providing an elegant alternative to nested loops for two-dimensional data structures. This intelligent iterator transforms mechanical iteration into an expressive journey through matrices and grid-like collections.

## From Nested Loops to Intelligent Traversal

Traditional nested loops for matrix-like traversal:

```ring
# Traditional nested loops for a 5x5 matrix
for i = 1 to 5
    for j = 1 to 5
        # Processing element at position [i, j]
        ...
    next
next
```

With `stzWalker2D`, this becomes:

```ring
oWalker = new stzWalker2D([1, 1], [5, 5], 1)
oWalker.Walkables()
#--> [ [1, 1], [2, 1], ... ,[5, 5] ]
```

## Understanding the 2D Walker

A 2D walker provides an abstraction over traditional nested loops, offering a complete iteration plan for traversing two-dimensional data structures. The walker tracks iteration state (current indices) and provides methods to control the iteration pattern:

```ring
load "stzlib.ring"

# Creating a 2D walker with step size 2 
# (this controls iteration increment, not spatial movement)
oWalker = new stzWalker2D([1, 1], [5, 5], 2)

# Or using shorthand factory function
oWalker = Wk2D([1, 1], [5, 5], 2)

# See all traversable positions (index pairs)
? @@(oWalker.WalkablePositions())
#--> [
#	[ 1, 1 ], [ 3, 1 ], [ 5, 1 ],
#	[ 2, 2 ], [ 4, 2 ],
#	[ 1, 3 ], [ 3, 3 ], [ 5, 3 ],
#	[ 2, 4 ], [ 4, 4 ],
#	[ 1, 5 ], [ 3, 5 ], [ 5, 5 ]
# ]
```
> **Note**: In practice, you will simply use the simpler `Wk()` shorthand function that creates either a `stzWalker` or `stzWalker2D` object by automatically analyzing the types of parameters provided.

## Advanced Iteration Control

### Index Tracking and Direction Control

The walker maintains complete awareness of current indices while providing flexible iteration patterns:

```ring
# Taking a step means advancing to the next index pair
? @@(oWalker.Walk())
#--> [ [ 1, 1 ], [ 3, 1 ] ]

? @@(oWalker.CurrentPosition())
#--> [ 3, 1 ]

# Direction refers to index progression, not spatial movement
w = new stzWalker2D([5, 5], [1, 1], 1)

? w.Direction()
#--> backward  # Indices decrease rather than increase

? @@(w.Walkables())
#--> [
#	[ 5, 5 ], [ 4, 5 ], [ 3, 5 ], [ 2, 5 ], [ 1, 5 ],
#	[ 5, 4 ], [ 4, 4 ], [ 3, 4 ], [ 2, 4 ], [ 1, 4 ],
#   ...
# ]
```

### Visual Representation of Iteration State

The `Show()` method visualizes the iteration pattern, marking start indices (S), end indices (E), current indices (x), and traversable indices (o):

```ring
w = new stzWalker2D([1, 1], [5, 5], 2)
w.WalkNSteps(4)
w.Show()
#-->
#     1  2  3  4  5  
#   ╭───────────────╮
# 1 │ S  .  o  .  o │
# 2 │ .  o  .  x  . │
# 3 │ o  .  o  .  o │
# 4 │ .  o  .  o  . │
# 5 │ o  .  o  .  E │
#   ╰───────────────╯
```

### Precise Traversal Control

`stzWalker2D` allows targeted navigation to specific index pairs:

```ring
# Advancing iteration to a specific position
? @@(w.WalkTo(3, 4))
#--> [
#	[ 1, 1 ], [ 2, 1 ], [ 3, 1 ], [ 4, 1 ], [ 5, 1 ],
#	[ 1, 2 ], [ 2, 2 ], [ 3, 2 ], [ 4, 2 ], [ 5, 2 ], 
#	[ 1, 3 ], [ 2, 3 ], [ 3, 3 ], [ 4, 3 ], [ 5, 3 ], 
#	[ 1, 4 ], [ 2, 4 ], [ 3, 4 ] 
# ]

# Iterating between specific index pairs
? @@(w.WalkBetween([3, 3], [5, 3]))
#--> [ [ 3, 3 ], [ 4, 3 ], [ 5, 3 ] ]
```

## Dynamic Traversal Patterns

### Variable and Bidirectional Steps

`stzWalker2D` supports both variable stepping and bidirectional iteration:

```ring
# Variable steps cycling through 1, 2, 3
w = new stzWalker2D([1, 1], [10, 10], [1, 2, 3])

? @@(w.Steps())
#--> [ 1, 2, 3 ]

# Bidirectional steps (forward 3, backward 2)
w = new stzWalker2D([1, 1], [10, 10], [3, -2])

? @@(w.Walk())
#--> [ [ 1, 1 ], [ 4, 1 ] ]  # Forward 3

? @@(w.Walk())
#--> [ [ 4, 1 ], [ 2, 1 ] ]  # Backward 2
```

### History and Rollback

The walker maintains a complete history of traversal for analysis or backtracking:

```ring
w = new stzWalker2D([1, 1], [5, 5], 1)
w.Walk()
w.Walk()
w.WalkBackward()
w.Walk()

? @@(w.Walks()) # Or History()
# --> [
#	[ [ 1, 1 ], [ 2, 1 ] ],		~> Walk()
#	[ [ 2, 1 ], [ 3, 1 ] ],		~> Walk()
#	[ [ 3, 1 ], [ 2, 1 ] ],		~> WalkBackward()
#	[ [ 2, 1 ], [ 3, 1 ] ]		~> Walk()
# ]

# Reset history while maintaining current position
w.ResetHistory()

? @@(w.History())
#--> [ ]
```

## Robust Edge Case Handling

`stzWalker2D` intelligently handles edge cases to prevent invalid operations:

```ring
# Identical start and end positions
w = new stzWalker2D([3, 3], [3, 3], 1)
? @@(w.WalkablePositions())
# --> [ [ 3, 3 ] ]

# Preventing over-iteration
w = new stzWalker2D([1, 1], [5, 5], 2)
? @@(w.WalkNSteps(20)) # Walks only available positions
#--> [ [1,1], [2,1], ..., [5, 5] ]

# Cannot iterate before start position
w.Reset()
w.WalkBackward()
# --> ERROR: Can't walk backward from the start position!
```

## Orchestrating Multiple Iteration Patterns with stzListOfWalkers2D

The `stzListOfWalkers2D` class extends the walker paradigm by providing sophisticated management of multiple 2D walkers as a unified collection. This powerful abstraction enables synchronized iteration, comparative analysis, and coordinated traversal across multiple iteration patterns.

### Creating and Managing Walker Collections

```ring
# Create individual walkers
w1 = new stzWalker2D([1, 1], [3, 3], 1)
w2 = new stzWalker2D([2, 2], [4, 4], 1)
w3 = new stzWalker2D([0, 0], [4, 4], 2)

# Create collections using factory functions
walkers1 = Wks([w1, w2])
walkers2 = StzListOfWalkers2DQ([w1, w2, w3])

# Alternatively, use the shorthand factory function with inline walker creation
walkers = Wks2D([
    Wk([1, 1], [3, 3], 1),
    Wk([2, 2], [4, 4], 1),
    Wk([0, 0], [4, 4], 2)
])

# Adding and removing walkers
walkers = Wks([ Wk([0, 0], [2, 2], 1) ])
walkers.AddWalker(Wk([1, 1], [3, 3], 1))
walkers.AddWalkers([
    Wk([0, 0], [4, 4], 2),
    Wk([5, 5], [7, 7], 1)
])

# Removing walkers
walkers.RemoveWalker(2)      # Remove by index
walkers.RemoveFirstWalker()  # Remove first walker
walkers.RemoveLastWalker()   # Remove last walker
```

### Accessing Walker Properties

```ring
walkers = Wks2D([
    new stzWalker2D([1, 1], [3, 3], 1),
    new stzWalker2D([1, 1], [2, 2], 1),
    new stzWalker2D([1, 1], [5, 5], 2)
])

# Access individual walkers
? @@(walkers.FirstWalker().StartPosition())
#--> [ 1, 1 ]

? @@(walkers.LastWalker().EndPosition())
#--> [ 5, 5 ]

# Comparing walkers
oSmallestWalker = walkers.SmallestWalker()
? @@(oSmallestWalker.EndPosition())
#--> [ 2, 2 ]

oLargestWalker = walkers.LargestWalker()
? @@(oLargestWalker.EndPosition())
#--> [ 5, 5 ]

# Comparing steps
? walkers.AllWalkersHaveSameSteps()
#--> FALSE
```

### Synchronized Iteration Operations

```ring
w1 = new stzWalker2D([1, 1], [3, 3], 1)
w2 = new stzWalker2D([2, 2], [4, 4], 1)

o1 = Wks2D([ w1, w2 ])

# Current indices of all walkers
? @@(o1.CurrentPositions())
#--> [ [ 1, 1 ], [ 2, 2 ] ]

# Advance all walkers by the same number of steps
o1.WalkAllNSteps(2)
? @@(o1.CurrentPositions())
#--> [ [ 3, 1 ], [ 4, 2 ] ]

# Walk all to end position
o1.WalkAllToEnd()
? @@(o1.CurrentPositions())
#--> [ [ 3, 3 ], [ 4, 4 ] ]

# Restart all walkers
o1.RestartAllWalkers()
? @@(o1.CurrentPositions())
#--> [ [ 1, 1 ], [ 2, 2 ] ]

# Setting positions and conditional walking
o1.SetCurrentPosition(3, 3)  # This sets all walkers to nearest walkable position
? @@(o1.CurrentPositions())
#--> [ [ 2, 2 ], [ 2, 2 ] ]

# Walk walkers only if position is within their iteration range
o1.WalkIfPossible(3, 3)
? @@(o1.CurrentPositions())
#--> [ [ 3, 3 ], [ 3, 3 ] ]
```

### Analyzing Traversable Positions

```ring
w1 = new stzWalker2D([1, 1], [2, 2], 1)
w2 = new stzWalker2D([1, 1], [2, 1], 1)
w3 = new stzWalker2D([2, 1], [2, 2], 1)

o1 = Wks2D([w1, w2, w3])

# Get traversable index pairs for all walkers
? @@NL(o1.Walkables()) + NL
#--> [
#   [
#       [ 1, 1 ], [ 2, 1 ],
#       [ 1, 2 ], [ 2, 2 ]
#   ],
#   [
#       [ 1, 1 ], [ 2, 1 ]
#   ],
#   [
#       [ 2, 1 ], [ 2, 2 ]
#   ]
# ]

# Find index pairs common to all walkers
? @@(o1.CommonWalkables()) + NL
#--> [ [ 2, 1 ] ]

# Get merged traversable positions (unique across all walkers)
? @@(o1.MergedWalkables())
#--> [ [ 1, 1 ], [ 1, 2 ], [ 2, 1 ], [ 2, 2 ] ]
```

### Finding Walkers Based on Position Criteria

```ring
w1 = new stzWalker2D([1, 1], [3, 3], 1)
w2 = new stzWalker2D([1, 1], [3, 3], 1)
w3 = new stzWalker2D([3, 3], [6, 6], 1)

walkers = Wks([w1, w2, w3])

# Find walkers that can traverse position [1, 1]
? @@(walkers.FindWalkable([1, 1])) + NL
#--> [ [ 1, 1 ], [ 2, 1 ] ]

# Find walkers that can traverse specific index pairs
? @@(walkers.FindWalkables([ [1, 1], [3, 3] ])) + NL
#--> [ [ 1, 1 ], [ 1, 9 ], [ 2, 1 ], [ 2, 9 ], [ 3, 1 ] ]

# Find walkers within a specific section of the iteration space
? @@(walkers.FindWalkersInSection([1, 1], [3, 3])) + NL
#--> [ 1, 2 ]   # Walkers 1 and 2

# Find walkers that intersect a path of indices
? @@(walkers.FindWalkersIntersectingPath([ [1, 1], [5, 5] ] ))
#--> [ 1, 2, 3 ]
```

### Visual Representation of Multiple Walkers

```ring
w1 = new stzWalker2D([1, 1], [4, 4], 1)
w2 = new stzWalker2D([3, 3], [6, 6], 1)

Wks2D([w1, w2]) {
    # Set different indices for each walker
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
    # 1-9 = Walker's traversable position
    #   * = Overlapping traversable positions
    #  x# = Current position of walker #
    #  S# = Start position of walker #
    #  E# = End position of walker #
    # v/> = Markers of current positions on grid borders
}
```

### Working with Different Step Patterns

```ring
// Create walkers with different step patterns
w1 = new stzWalker2D([1, 1], [3, 3], 1)        // Constant step of 1
w2 = new stzWalker2D([1, 1], [5, 5], 2)        // Constant step of 2
w3 = new stzWalker2D([1, 1], [4, 4], [1, 2, 1])  // Variable step pattern

walkers = Wks2D([w1, w2, w3])

// Walk each 3 steps and check positions
walkers.WalkAllNSteps(3)

? @@(walkers.CurrentPositions())
#--> [ [ 1, 2 ], [ 2, 2 ], [ 1, 2 ] ]
```

## Practical Applications

The `stzWalker2D` and `stzListOfWalkers2D` paradigms enable elegant solutions for index-based traversal across numerous domains:

- **Matrix Operations**: Custom traversal patterns for convolution or filtering
- **Data Analysis**: Consistent traversal of multidimensional datasets
- **Table Manipulation**: Precise control over cell processing
- **UI Component Iteration**: Grid-based UI element processing
- **Custom Collection Traversal**: Specialized patterns for irregular grids
- **Multi-pattern Coordination**: Synchronizing multiple iteration sequences
- **Complex Traversal Logic**: Implementing sophisticated iteration rules without nested conditionals
- **Parallel Processing**: Distributing work across multiple traversal patterns

## Softanza Advantage: A Comparative Analysis

Softanza's `stzWalker2D` walking paradigm stands out when compared to traditional approaches to two-dimensional traversal, , whether they are pure nested loops, iterator patterns (like Java's Iterator interface or C++'s STL iterators), or matrix libraries (like Python's NumPy array iteration or MATLAB's matrix operations).


| Feature                          | Softanza Walker2D         | Nested Loops            | Iterator Patterns        | Matrix Libraries         |
|----------------------------------|---------------------------|-------------------------|--------------------------|--------------------------|
| **Declarative Syntax**           | ✅ High (Expressive)      | Low (Procedural)        | Medium                   | Varies                   |
| **Differential Stepping**        | ✅ Built-in               | Manual                  | Not Common               | Limited                  |
| **Bidirectional Steps**          | ✅ Native support         | Complex Implementation  | Rare                     | Very Rare                |
| **Direction Control**            | ✅ Automatic Detection    | Manual                  | Typically Forward Only   | Limited                  |
| **Visual Representation**        | ✅ Built-in Show()        | None                    | None                     | Sometimes                |
| **Position Awareness**           | ✅ Native                 | Manual Tracking         | Limited                  | Sometimes                |
| **Walking History**              | ✅ Comprehensive          | None                    | None                     | Rare                     |
| **Targeted Navigation**          | ✅ WalkTo, WalkBetween    | Manual                  | Not Common               | Sometimes                |
| **Variable Step Patterns**       | ✅ Native                 | Complex Implementation  | Not Common               | Rare                     |
| **Error Handling**               | ✅ Robust                 | Manual                  | Varies                   | Varies                   |
| **Integration with Objects**     | ✅ Native                 | External                | Sometimes                | Sometimes                |
| **Multi-Walker Management**      | ✅ stzListOfWalkers2D     | Complex Implementation  | Not Native               | Rare                     |
| **Synchronized Traversal**       | ✅ Built-in               | Manual Coordination     | Not Common               | Limited                  |
| **Traversal Analysis Tools**     | ✅ Native                 | Complex Implementation  | Rare                     | Sometimes                |

## Conclusion

The combined power of `stzWalker2D` and `stzListOfWalkers2D` represents a paradigm shift in two-dimensional traversal of data structures. By transforming mechanical nested loops into an expressive iterator abstraction with index awareness, direction control, and pattern flexibility, Softanza eliminates error-prone index tracking while enabling sophisticated traversal patterns.

The `stzListOfWalkers2D` class extends this metaphor to coordinated operations across multiple iteration patterns, offering unprecedented control over complex traversal relationships. This unified traversal ecosystem spans both individual and collective iteration behaviors, simplifying complex algorithm development with a consistent abstraction regardless of dimensional complexity.

> **Design Disclaimer**: The walker metaphor used in Softanza's `stzWalker`, `stzListOfWalkers`, `stzWalker2D` and `stzListOfWalkers2D` classes represents an abstraction over traditional nested loops and index-based iteration, not actual spatial movement. While these classes use terminology like "walking" and "position," they are fundamentally iteration control mechanisms for traversing multi-dimensional data structures. The future `stzGridWalker` class,  will be the truly spatial-aware construct designed specifically for grid-based spatial applications.