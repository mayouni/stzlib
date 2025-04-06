# The Matrix Craftsman: Precision Computing with Softanza's stzMatrix Class

## Introduction

Matrices are the unsung heroes of computational problem-solving, powering everything from data analysis to image processing and machine learning. Whether you're balancing equations or transforming datasets, matrix operations are essential. The Softanza library for the Ring programming language simplifies this with its `stzMatrix` class—a powerful, user-friendly tool that blends efficiency with elegance. In this article, we'll dive into `stzMatrix`, exploring its features through practical examples that show how it can streamline your numerical computing tasks.

> **Note**: stzMatrix is implemented using the efficient C-based RingFastPro extension.

## Getting Started with stzMatrix

Creating and working with matrices in `stzMatrix` is a breeze. Let's start with a simple 3x3 matrix:

```ring
load "../max/stzmax.ring"

# Create a 3x3 matrix
mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

mx.Show()
```

Output:

```
┌       ┐
│ 1 2 3 │
│ 4 5 6 │
│ 7 8 9 │
└       ┘
```

This could represent anything from a small dataset to a transformation grid. The `Show()` method displays the matrix in a clean, readable format—already a step up from raw arrays.

## Basic Matrix-Wide Operations

The most natural way to work with matrices is to apply operations to the entire structure. `stzMatrix` makes this intuitive with simple methods that affect all elements.

### Addition and Multiplication

Let's perform some fundamental operations. Imagine you're adjusting a dataset by a constant value:

```ring
# Add 10 to all elements (e.g., a temperature offset)
mx.Add(10)
mx.Show()
```

Output:

```
┌          ┐
│ 11 12 13 │
│ 14 15 16 │
│ 17 18 19 │
└          ┘
```

Or scaling values, like amplifying a signal:

```ring
# Multiply the matrix by a scalar
mx = new stzMatrix([
    [1, 2, 3],
    [1, 2, 3],
    [1, 2, 3]
])

mx.Multiply(3)		# Or Multiply(:By = 3) or MultiplyBy(3)
mx.Show()
```

Output:

```
┌       ┐
│ 3 6 9 │
│ 3 6 9 │
│ 3 6 9 │
└       ┘
```

These simple operations are the foundation of matrix manipulations—direct and intuitive for common tasks.

## Working With Specific Rows and Columns

As your matrix operations become more targeted, you'll need to focus on specific parts of your data. `stzMatrix` offers a progressive approach that grows with your needs.

### Adding Values to Rows

When you need to add a value to the elements of a given row, you write:

```ring
# Add 3 to row 1
mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

mx.Add([ 3, 1 ]) # Adds 1 to the row 3
mx.Show()
```

Here, the first number is the row (which always comes before column in matrix coordinate conventions). But you can be more explicit and write `AddToRow(3, 1)`or `Add([ :Row = 3, 1 ])`.

Output:

```
┌       ┐
│ 4 5 6 │
│ 4 5 6 │
│ 7 8 9 │
└       ┘
```

Similarly, for cols:

```ring
# Add 5 to column 2
mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

mx.Add([ :Col = 5, 2)	# Or AddToCol(5, 2)
mx.Show()
```

Output:

```
┌        ┐
│ 1 7 3  │
│ 4 10 6 │
│ 7 13 9 │
└        ┘
```

You can also be explicit by defining the order of params in the method name suffix, like this:
```
mx.AddCV(5, 2)	# 5 is the C (for Column) and 2 is the V (for Value)
```
Or specify it the other way around like this:
```
mx.AddVC(2, 5)	# 2 is the V (for Value) and 5 is the C (for Column) 
```

Up to you then! And this applies the same wat the `Myltiply()` method as we are going to see next.


### Multiplying rows and columns

To multiply the elements of a given row with a value you write:

```ring

mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

mx.Multiply([ 3, 2 ]) # Multiplies the row 3 by the value 2
mx.Show()
```

Output:

```
┌          ┐
│  1  2  3 │
│  4  5  6 │
│ 14 16 18 │
└          ┘
```

You can be more expressive and say `Multiply([ :Row = 3, :By = 2 ])` or `MultiplyRow(3, :By = 2)` and you'll get the same result.

Same think when you want to multiply a column by a number:

```ring

mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

mx.Multiply([ :Col = 3, :By 2 ]) # Multiplies the column 3 by the value 2
mx.Show()
```

Output:

```
┌          ┐
│  1  2  6 │
│  4  5 12 │
│  7  8 18 │
└          ┘
```

Which you can also write `MultiplyCol(3, 2)` or `MultiplyCol(3, :By = 2)` or even `MultiplyCV(3, 2)` and `MultiplyVC(2, 3)` as we saugh earlier for the Add() method.

### Advanced Selection with Lists and Ranges

When your needs expand to multiple rows or columns, `stzMatrix` grows with you. You can target specific sets of rows or columns:

```ring
# Multiply columns 1 and 3 by 2
mx = new stzMatrix([
    [1, 0, 3],
    [4, 0, 6],
    [7, 0, 9]
])

mx.MultiplyCols([1, 3], :By = 2)
mx.Show()
```

Output:

```
┌         ┐
│  2 0  6 │
│  8 0 12 │
│ 14 0 18 │
└         ┘
```

And you can do it for rows also using `MultiplyRows([ 2, 3 ], :By = 2 )`which multiplies the elements in rows 2 and 3 with the value 2.

For sequential ranges, you can use the intuitive `:From` and `:To` keywords:

```ring
# Multiply rows 2 to 3 by 2
mx = new stzMatrix([
    [  1,  2,  3,  4 ],
    [  5,  6,  7,  8 ],
    [  9,  8,  9, 10 ],
    [ 11, 12, 13, 14 ]
])

mx.MultiplyRows([:From = 2, :To = 4], :By = 2)
mx.Show()
```

Output:

```
┌          ┐
│  1  2  3 │
│  8 10 12 │
│ 14 16 18 │
└          ┘
```

Of course, you can use the same range syntax for cloumns and write `MultiplyCols([:From = 2, :To = 4], :By = 2)`to multiply all the elements in columns 2 to 4 wuth the value 2.

## Statistical Functions

Need quick insights? `stzMatrix` offers built-in stats that work directly on the whole matrix:

```ring
mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

? mx.Sum()      # Total of all elements
? mx.Mean()     # Average value
? mx.Max()      # Highest value
? mx.Min()      # Lowest value
```

Output:

```
45
5.0
9
1
```

Think of this as summarizing a table of test scores or sensor readings in seconds.

## Special Matrix Creation

Creating specialized matrices is straightforward with the factory functions provided:

```ring
# Diagonal matrix (type 1) with values along the main diagonal
? @@NL(Diagonal1Matrix([1, 2, 3, 4]))
```

Output:

```
[
    [1, 0, 0, 0],
    [0, 2, 0, 0],
    [0, 0, 3, 0],
    [0, 0, 0, 4]
]
```

```ring
# Diagonal matrix (type 2) with values along the secondary diagonal
? @@NL(Diagonal2Matrix([1, 2, 3, 4]))
```

Output:

```
[
    [0, 0, 0, 1],
    [0, 0, 2, 0],
    [0, 3, 0, 0],
    [4, 0, 0, 0]
]
```

```ring
# Constant matrix (e.g., for initializing a grid)
? @@NL(ConstantMatrix([3, [2, 4]]))
```

Output:

```
[
    [3, 3, 3, 3],
    [3, 3, 3, 3]
]
```

Now you can feed these to stzMatrix to get an object that you can work on.

## Element Transformations

### Basic Element Replacement

For simple element transformations, the straightforward syntax continues:

```ring
# Replace all 5s with 0
mx = new stzMatrix([
    [1, 2, 5],
    [4, 5, 6],
    [5, 8, 9]
])

mx.ReplaceElement(5, :By = 0)
mx.Show()
```

Output:

```
┌       ┐
│ 1 2 0 │
│ 4 0 6 │
│ 0 8 9 │
└       ┘
```

### Position-Based Replacement

When you need precise control over a specific position:

```ring
# Replace element at [3,3] with 0
mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

mx.ReplaceAt([3, 3], :By = 0) # Or ReplaceElementAt()
mx.Show()
```

Output:

```
┌       ┐
│ 1 2 3 │
│ 4 5 6 │
│ 7 8 0 │
└       ┘
```

### Advanced Replacement Using Sequences

For more sophisticated transformations, you can replace values with sequences:

```ring
# Replace 5s with [-1, -2, -3] in order
mx = new stzMatrix([
    [1, 2, 5],
    [4, 5, 6],
    [5, 8, 9]
])

mx.ReplaceByMany(5, [-1, -2, -3])
mx.Show()
```

Which you can also write `Replace([ 5, :ByMany = [-1, -2, -3] ])`.

Output:

```
┌          ┐
│  1  2 -1 │
│  4 -2  6 │
│ -3  8  9 │
└          ┘
```

Or for repeating patterns (the numbers provided are restarted cyclicly from the start when they are all replaced), the extended transformation parameter, usin the `XT` suffix:

```ring
# Cycle [-1, -2] for each 5
mx.ReplaceByManyXT(5, [-1, -2])	# Or Replace([ 5, :ByManyXT = [ -1, -2 ] ])
mx.Show()
```

Output:

```
┌          ┐
│  1  2 -1 │
│  4 -2  6 │
│ -1  8  9 │
└          ┘
```

Notice how the parameters evolve naturally from `:By` to `:ByMany` to `:ByManyXT` as operations become more complex, while maintaining a consistent syntax pattern.

## Working With Matrix Segments

In Softanza a segment of a matrix is called `Section`.

### Matrix Sections

Extracting specific sections of your matrix follows the same intuitive approach:

```ring
# Extract from [1,1] to [2,2]
mx = new stzMatrix([
    [14, 20, 16],
    [14, 20, 16],
    [17, 23, 19]
])

? @@(mx.Section([1, 1], [2, 2]))
```

Output:

```
[14, 14, 20, 20]
```

And modifying sections:

```ring
# Replace section with 0
mx.ReplaceSection([1, 1], [2, 2], :By = 0)
mx.Show()
```

Output:

```
┌          ┐
│  0  0 16 │
│  0  0 16 │
│ 17 23 19 │
└          ┘
```

> **Note**: In matrix semantics, element positions are read vertically from top to bottom and then horizontally from left to right.

### Submatrices

When you need a true submatrix (a proper rectangular extract):

```ring
# Extract a submatrix from [1,1] to [3,2]
mx = new stzMatrix([
    [14, 20, 16],
    [14, 20, 16],
    [17, 23, 19]
])

mx.SubMatrix([1, 1], [3, 2]).Show()
```

Output:

```
┌       ┐
│ 14 20 │
│ 14 20 │
│ 17 23 │
└       ┘
```

This creates a new `stzMatrix` object containing just the specified rows and columns—perfect for focusing on a subset of data without altering the original.

## Advanced Matrix Operations

As we move into more sophisticated linear algebra, the syntax remains consistent even as capabilities expand.

### Matrix Multiplication

Matrix multiplication is essential in many fields:

```ring
# Multiply matrices
mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6]
])

mx.MultiplyBy([
    [7, 8],
    [9, 10],
    [11, 12]
])
mx.Show()
```

Output:

```
┌         ┐
│  58  64 │
│ 139 154 │
└         ┘
```

Note how we reuse the familiar `MultiplyBy()` method, but now with a matrix parameter instead of a scalar.

### Matrix Addition

Similarly, adding matrices follows naturally from adding scalars:

```ring
mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

mx.AddMatrix([
    [10, 20, 30],
    [40, 50, 60],
    [70, 80, 90]
])
mx.Show()
```

Output:

```
┌          ┐
│ 11 22 33 │
│ 44 55 66 │
│ 77 88 99 │
└          ┘
```

### Determinant and Inverse

More advanced operations maintain the same clean approach:

```ring
# Calculate determinant
mx = new stzMatrix([
    [4, 7],
    [2, 6]
])
? mx.Determinant()
```

Output:

```
10
```

And inversion:

```ring
# Invert a matrix
mx = new stzMatrix([
    [1, 2, 3],
    [0, 1, 4],
    [5, 6, 0]
])
mx.Inverse()
mx.Show()
```

Output:

```
┌            ┐
│ -24  18  5 │
│  20 -15 -4 │
│  -5   4  1 │
└            ┘
```

## Finding Elements

Locating values follows the same pattern of clarity:

```ring
# Find all 99s
mx = new stzMatrix([
    [80, 85, 99],
    [70, 75, 80],
    [99, 65, 99]
])

? @@(mx.FindElement(99))
```

Output:

```
[[1, 3], [3, 1], [3, 3]]
```

And extends naturally to multiple values:

```ring
? @@(mx.FindElements([88, 99]))
```

Output (assuming 88s added):

```
[[1, 1], [2, 2], [1, 3], [3, 1], [3, 3]]
```

## Data Analysis Features

`stzMatrix` offers specialized tools for data analysis, following the same direct approach.

### Difference Calculation

Track changes between adjacent elements:

```ring
tempMatrix = new stzMatrix([
    [20, 22, 21, 23, 25],
    [18, 20, 17, 25, 28],
    [19, 17, 14, 23, 34]
])

? @@NL(tempMatrix.Diff())
```

Output:

```
[
    [2, -1, 2, 2],
    [2, -3, 8, 3],
    [-2, -3, 9, 11]
]
```

### Mean Centering

Normalize data around the mean:

```ring
scores = new stzMatrix([
    [80, 85, 90],
    [70, 75, 80],
    [60, 65, 70]
])

scores.SubMean()
scores.Show()
```

Output:

```
┌        ┐
│ -5 0 5 │
│ -5 0 5 │
│ -5 0 5 │
└        ┘
```

## Syntactic Flexibility: The Power of Choice

Throughout this exploration of `stzMatrix`, you've seen how the API naturally scales from simple to complex operations. Let's recap the syntax patterns that make this possible:

1. **Simple method calls** for whole-matrix operations:

   ```ring
   mx.Add(10)
   mx.MultiplyBy(3)
   ```

2. **Direct target specification** for basic row/column operations:

   ```ring
   mx.AddToCol(5, 2)
   mx.AddToRow(3, 1)
   ```

3. **Named parameters** for clarity in more complex operations:

   ```ring
   mx.MultiplyRow(3, :By = 3)
   mx.ReplaceElement(5, :By = 0)
   ```

4. **Lists and ranges** for multi-target operations:

   ```ring
   mx.MultiplyCols([1, 3], :By = 2)
   mx.MultiplyRows([:From = 2, :To = 3], :By = 2)
   ```

5. **Extended transformation options** for complex replacements:

   ```ring
   mx.ReplaceElement(5, :ByMany = [-1, -2, -3])
   mx.ReplaceElement(5, :ByManyXT = [-1, -2])
   ```

This progressive approach to syntax ensures that simple operations remain simple, while more complex tasks have the expressiveness they need.

## Conclusion

The `stzMatrix` class transforms matrix operations from a chore into a strength of the Ring language. Its syntax evolves naturally with your needs—from straightforward methods for basic tasks to expressive, flexible parameters for complex operations.

This design philosophy allows you to start with the simplest approach and gradually adopt more powerful features as your requirements grow. Whether you're crunching numbers for analysis, building simulations, or exploring linear algebra, `stzMatrix` adapts to your workflow rather than forcing you to adapt to it.

By mastering this elegant API, you can spend less time wrestling with implementation details and more time solving the real problems that matter to your users and projects.
