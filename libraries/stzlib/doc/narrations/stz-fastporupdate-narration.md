# FastProUpdate(): A Semantic Rengineering of RingFastPro extension

## Introduction

`RingFastPro` extension, by Mahmoud Fayed, provides essential high-performance list operations in Ring through C-based optimization. Softanza builds upon this foundation by offering a semantic interface that maintains `RingFastPro`'s computational efficiency while providing a more declarative and learnable syntax.

> **NOTE**: The `FastProUpdate()` function was originally motivated by its use in the Softanza's `stzMatrix` class, where a more intuitive programming experience for matrix operations was needed.

## Core Commands Structure in stzFastPro

`FastProUpdate()` provides a unique entry-point for all the features of the `RingFastPro`extension. Here's the basic unified structure:

```ring
FastProUpdate(aList, :Command = [ parameters... ])
```

The main commands include operations like setting values, adding, subtracting, multiplying, dividing, calculating modulo, raising to powers, copying, merging elements, and sequential stepping within lists and matrices. Let's explore each with practical examples.

> **NOTE**: You can read about the original `RingFastPro` extension in [this](https://ring-lang.github.io/doc1.22/whatisnew22.html) Ring documentation article.

## Setting Values

### Setting Specific Rows or Columns

When working with matrices, you'll often need to modify entire rows or columns. `FastProUpdate()` makes this straightforward:

```ring
aMatrix = [
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
]

# Set row 2 to value 0
FastProUpdate(aMatrix, :Set = [ :Row = 2, :With = 0 ])
```

This sets all values in the second row to zero, resulting in:

```
[
    [ 1, 2, 3 ],
    [ 0, 0, 0 ],
    [ 7, 8, 9 ]
]
```

Similarly, for columns:

```ring
# Set column 2 to value 0
FastProUpdate(aMatrix, :Set = [ :Col = 2, :With = 0 ])
```

This produces:

```
[
    [ 1, 0, 3 ],
    [ 0, 0, 0 ],
    [ 7, 0, 9 ]
]
```

### Setting Multiple Rows or Columns

`FastProUpdate()` allows for operating on multiple rows or columns in a single command:

```ring
aMatrix = [
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
]

# Set rows 2 and 3 to value 5
FastProUpdate(aMatrix, :Set = [ :Rows = [ 2, 3 ], :With = 5 ])
```

This creates:

```
[
    [ 1, 2, 3 ],
    [ 5, 5, 5 ],
    [ 5, 5, 5 ]
]
```

You can also set multiple columns at once:

```ring
# Set columns 2 and 3 to value 0
FastProUpdate(aMatrix, :Set = [ :Cols = [ 2, 3 ], :With = 0 ])
```

This produces:

```
[
    [ 1, 0, 0 ],
    [ 5, 0, 0 ],
    [ 5, 0, 0 ]
]
```

### Setting a Range of Rows or Columns

You can also specify a range of rows or columns using the `RowsFrom` and `ColsFrom` parameters:

```ring
aMatrix = [
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
]

# Set columns from 2 to 3 with the value 0
FastProUpdate(aMatrix, :Set = [ :ColsFrom = [ 2, :To = 3 ], :With = 0 ])

# Set rows from 1 to 2 with the value 5
FastProUpdate(aMatrix, :Set = [ :RowsFrom = [ 1, :To = 2 ], :With = 5 ])
```

This syntax provides a more intuitive way to specify ranges.

### Setting All Elements

Setting all elements in a list or matrix is also simplified:

```ring
aMatrix = 1:7

# Set all elements to value 5
FastProUpdate(aMatrix, :set = [ :all, :with = 5 ])
```

This results in:

```
[ 5, 5, 5, 5, 5, 5, 5 ]
```

This works for both 1D and 2D lists:

```ring
aMatrix = [
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
]

FastProUpdate(aMatrix, :set = [ :all, :with = 5 ])
```

Result:

```
[
    [ 5, 5, 5 ],
    [ 5, 5, 5 ],
    [ 5, 5, 5 ]
]
```

### Setting Sequential Values

You can also set a column to contain sequential values starting from 1:

```ring
aMatrix = [
    [ 5, 5, 5 ],
    [ 5, 5, 5 ],
    [ 5, 5, 5 ]
]

FastProUpdate(aMatrix, :Set = [ :Col = 1, :Step = 0 ])
```

This produces:

```
[
    [ 1, 5, 5 ],
    [ 2, 5, 5 ],
    [ 3, 5, 5 ]
]
```

## Addition Operations

Adding values to specific portions of a matrix becomes intuitive:

```ring
aMatrix = [
    [ 1, 2, 3 ],
    [ 1, 2, 3 ],
    [ 1, 2, 3 ]
]

# Add 8 to column 2
FastProUpdate(aMatrix, :Add = [ 8, :ToCol = 2 ])
```

The result:

```
[
    [ 1, 10, 3 ],
    [ 1, 10, 3 ],
    [ 1, 10, 3 ]
]
```

### Adding to a Range of Columns or Rows

You can add a value to a range of columns or rows:

```ring
aMatrix = [
    [ 1, 2, 3 ],
    [ 1, 2, 3 ],
    [ 1, 2, 3 ]
]

# Add 8 to columns 1 and 2
FastProUpdate(aMatrix, :Add = [ 8, :ToColsFrom = [ 1, :To = 2 ] ])
```

The result:

```
[
    [ 9, 10, 3 ],
    [ 9, 10, 3 ],
    [ 9, 10, 3 ]
]
```

You can also add to specific rows:

```ring
# Add 7 to rows 2 and 3
FastProUpdate(aMatrix, :Add = [ 7, :ToRowsFrom = [ 2, :To = 3 ] ])
```

This creates:

```
[
    [ 9, 10, 3 ],
    [ 16, 17, 10 ],
    [ 16, 17, 10 ]
]
```

## Subtraction Operations

Similarly, subtraction operations become more readable:

```ring
aMatrix = [
    [ 10, 20, 30 ],
    [ 40, 50, 60 ],
    [ 70, 80, 90 ]
]

# Subtract 10 from column 1
FastProUpdate(aMatrix, :Subtract = [ 10, :FromCol = 1 ])
```

This would subtract 10 from all values in column 1.

### Subtracting from a Range of Columns or Rows

You can also subtract from ranges:

```ring
aMatrix = [
    [ 10, 20, 30 ],
    [ 40, 50, 60 ],
    [ 70, 80, 90 ]
]

# Subtract 10 from columns 1-3
FastProUpdate(aMatrix, :Subtract = [ 10, :FromColsFrom = [ 1, :To = 3 ] ])
```

This yields:

```
[
    [ 0, 10, 20 ],
    [ 30, 40, 50 ],
    [ 60, 70, 80 ]
]
```

And for rows:

```ring
# Subtract 10 from rows 1-3
FastProUpdate(aMatrix, :Subtract = [ 10, :FromRowsFrom = [ 1, :To = 3 ] ])
```

This results in:

```
[
    [ -10, 0, 10 ],
    [ 20, 30, 40 ],
    [ 50, 60, 70 ]
]
```

## Multiplication Operations

Multiplication provides even more flexibility with destination options:

```ring
aMatrix = [
    [ 2, 4, 8 ],
    [ 1, 2, 4 ],
    [ 2, 4, 9 ]
]

# Multiply column 2 by 2
FastProUpdate(aMatrix, :Multiply = [ :Col = 2, :By = 2 ])
```

This transforms the matrix to:

```
[
    [ 2, 8, 8 ],
    [ 1, 4, 4 ],
    [ 2, 8, 9 ]
]
```

You can also store the result in a different column:

```ring
# Multiply column 2 by 2 and store in column 3
FastProUpdate(aMatrix, :Multiply = [ :Col = 2, :By = 2, :ToCol = 3 ])
```

This operation is particularly useful for preserving original data while calculating new values.

Row operations follow the same pattern:

```ring
# Multiply row 2 by 2
FastProUpdate(aMatrix, :Multiply = [ :Row = 2, :By = 2 ])
```

### Multiplying a Range of Columns or Rows

You can also multiply values in a range of columns or rows:

```ring
aMatrix = [
    [ 1, 2, 3 ],
    [ 1, 2, 3 ],
    [ 1, 2, 3 ]
]

# Multiply columns 1-3 by 2
FastProUpdate(aMatrix, :Multiply = [ :ColsFrom = [ 1, :To = 3 ], :By = 2 ])
```

Result:

```
[
    [ 2, 4, 6 ],
    [ 2, 4, 6 ],
    [ 2, 4, 6 ]
]
```

Similarly for rows:

```ring
# Multiply rows 2-3 by 3
FastProUpdate(aMatrix, :Multiply = [ :RowsFrom = [ 2, :To = 3 ], :By = 3 ])
```

Result:

```
[
    [ 2, 4, 6 ],
    [ 6, 12, 18 ],
    [ 6, 12, 18 ]
]
```

## Division Operations

Division follows a similar pattern to multiplication:

```ring
aMatrix = [
    [ 2, 4, 8 ],
    [ 1, 2, 4 ],
    [ 3, 4, 8 ]
]

# Divide column 2 by 2
FastProUpdate(aMatrix, :Divide = [ :Col = 2, :By = 2 ])
```

Result:

```
[
    [ 2, 2, 8 ],
    [ 1, 1, 4 ],
    [ 3, 2, 8 ]
]
```

You can also specify a destination column:

```ring
# Divide column 3 by 2 and store in column 1
FastProUpdate(aMatrix, :Divide = [ :Col = 3, :By = 2, :ToCol = 1 ])
```

This yields:

```
[
    [ 4, 2, 8 ],
    [ 2, 1, 4 ],
    [ 4, 2, 8 ]
]
```

Row division works similarly:

```ring
# Divide row 1 by 2
FastProUpdate(aMatrix, :Divide = [ :Row = 1, :By = 2 ])
```

Result:

```
[
    [ 1, 2, 4 ],
    [ 1, 2, 4 ],
    [ 3, 4, 8 ]
]
```

### Dividing a Range of Columns or Rows

You can also divide values in a range of columns or rows:

```ring
aMatrix = [
    [ 1, 2, 3 ],
    [ 1, 2, 3 ],
    [ 1, 2, 3 ]
]

# Divide columns 1-3 by 2
FastProUpdate(aMatrix, :Divide = [ :ColsFrom = [ 1, :To = 3 ], :By = 2 ])
```

Result:

```
[
    [ 0.50, 1, 1.50 ],
    [ 0.50, 1, 1.50 ],
    [ 0.50, 1, 1.50 ]
]
```

And for rows:

```ring
# Divide rows 2-3 by 3
FastProUpdate(aMatrix, :Divide = [ :RowsFrom = [ 2, :To = 3 ], :By = 3 ])
```

Result:

```
[
    [ 0.50, 1, 1.50 ],
    [ 0.17, 0.33, 0.50 ],
    [ 0.17, 0.33, 0.50 ]
]
```

## Power Operations

stzFastPro also supports raising elements to powers:

```ring
aMatrix = [
    [ 1, 0, 0 ],
    [ 2, 0, 0 ],
    [ 3, 0, 0 ]
]

# Raise column 1 to power 2
FastProUpdate(aMatrix, :Raise = [ :Col = 1, :ToPower = 2 ])
```

Result:

```ring
[
    [ 1, 0, 0 ],
    [ 4, 0, 0 ],
    [ 9, 0, 0 ]
]
```

### Raising a Range of Columns or Rows to Powers

You can also raise values in a range of columns or rows to a power:

```ring
aMatrix = [
    [ 1, 2, 3 ],
    [ 1, 2, 3 ],
    [ 1, 2, 3 ]
]

# Raise columns 2-3 to power 2
FastProUpdate(aMatrix, :Raise = [ :ColsFrom = [ 2, :To = 3 ], :ToPower = 2 ])
```

Result:

```
[
    [ 1, 4, 9 ],
    [ 1, 4, 9 ],
    [ 1, 4, 9 ]
]
```

Similarly for rows:

```ring
# Raise rows 2-3 to power 2
FastProUpdate(aMatrix, :Raise = [ :RowsFrom = [ 2, :To = 3 ], :ToPower = 2 ])
```

Result:

```
[
    [ 1, 4, 9 ],
    [ 1, 16, 81 ],
    [ 1, 16, 81 ]
]
```

This operation is particularly useful for mathematical transformations without needing explicit loops.

## Modulo Operations

stzFastPro enables modulo divisions:

```ring
aMatrix = [
    [ 1, 2, 4 ],
    [ 2, 4, 9 ],
    [ 2, 7, 8 ]
]

# Calculating the modulo of numbers in column 3 by 2
FastProUpdate(aMatrix, :Modulo = [ :Col = 3, :By = 2 ])
```

Result:

```ring
[
    [ 1, 2, 0 ],
    [ 2, 4, 1 ],
    [ 2, 7, 0 ]
]
```

### Modulo Operations on Ranges of Columns or Rows

You can perform modulo operations on ranges of columns or rows:

```ring
aMatrix = [
    [ 0, 5, 3 ],
    [ 0, 7, 9 ],
    [ 0, 9, 7 ]
]

# Modulo columns 2-3 by 2
FastProUpdate(aMatrix, :Modulo = [ :ColsFrom = [ 2, :To = 3 ], :By = 2 ])
```

Result:

```
[
    [ 0, 1, 1 ],
    [ 0, 1, 1 ],
    [ 0, 1, 1 ]
]
```

And for rows:

```ring
aMatrix = [
    [ 0, 0, 0 ],
    [ 2, 7, 4 ],
    [ 5, 9, 7 ]
]

# Modulo rows 2-3 by 2
FastProUpdate(aMatrix, :Modulo = [ :RowsFrom = [ 2, :To = 3 ], :By = 2 ])
```

Result:

```
[
    [ 0, 0, 0 ],
    [ 0, 1, 0 ],
    [ 1, 1, 1 ]
]
```

## Merging Operations

stzFastPro provides a powerful merge operation that combines values from two rows or columns:

```ring
aMatrix = [
    [ 3, 7, 5 ],
    [ 2, 8, 0 ],
    [ 5, 5, 0 ]
]

# Merge columns 1 and 2 into column 2 (addition)
FastProUpdate(aMatrix, :Merge = [ :Cols = [ 1, 2 ], :InCol = 2 ])
```

Result:

```
[
    [ 3, 10, 5 ],
    [ 2, 10, 0 ],
    [ 5, 10, 0 ]
]
```

Row merging works similarly:

```ring
# Merge rows 2 and 3 into row 3
FastProUpdate(aMatrix, :Merge = [ :Rows = [ 2, 3 ], :InRow = 3 ])
```

This produces:

```
[
    [ 3, 10, 5 ],
    [ 2, 10, 0 ],
    [ 7, 20, 0 ]
]
```

> **NOTE**: The number provided after `:InCol` or `:InRow` must be one of the numbers in the `:Cols` or `:Rows` list. Meaning that the merge can happen on one of the two specifed columns or rows.

## Copy Operations

`FastProUpdate()` allows copying data between rows or columns:

```ring
# Copy row 1 to row 3
FastProUpdate(aMatrix, :Copy = [ :Row = 1, :ToRow = 3 ])

# Copy column 1 to column 2
FastProUpdate(aMatrix, :Copy = [ :Col = 1, :ToCol = 2 ])
```

This operation is useful for duplicating data without needing to create temporary variables.

## Multiple Operations in a Single Call

One of the most powerful features of `FastProUpdate()` is the ability to chain multiple operations in a single call. This is ideal for complex transformations:

```ring
# Create a matrix to simulate image data with RGB channels
aImage = [
    [255, 100, 50],   # R, G, B for pixel 1
    [200, 150, 75],   # R, G, B for pixel 2
    [180, 90, 120]    # R, G, B for pixel 3
]
   
# Perform grayscale conversion with multiple steps
FastProUpdate(aImage, [
    :Multiply = [ :Col = 1, :By = 0.3 ],             # R channel weighting
    :Multiply = [ :Col = 2, :By = 0.59 ],            # G channel weighting
    :Multiply = [ :Col = 3, :By = 0.11 ],            # B channel weighting
    :Merge = [ :Cols = [ 1, 2 ], :InCol = 1 ],       # Combine R and G
    :Merge = [ :Cols = [ 1, 3 ], :InCol = 1 ],       # Add B to the result
    :Copy = [ :Row = 1, :ToRow = 3 ],                # Copy results to row 3
    :Copy = [ :Col = 1, :ToCol = 2 ]                 # Copy to G channel
])
```

This example demonstrates how `FastProUpdate()` can handle complex image processing operations like grayscale conversion in a single, readable command.

## Performance with Large Datasets

Despite its more semantic interface, `FastProUpdate()` maintains the performance advantages of RingFastPro, even with large datasets:

```ring
# Create a 1D list with 1 million elements and set all to 1000
aList = 1:1_000_000
FastProUpdate(aList, :set = [ :All, :with = 1000 ])
# Executed in 0.34 second(s) in Ring 1.22
```

The underlying C implementation ensures excellent performance even for operations on very large lists:

```ring
# Checking if a large list contains only numbers
? IsListOfNumbers(1:1_000_000)
# --> TRUE
# Executed in 0.23 second(s) in Ring 1.22
```

## Conclusion

`FastProUpdate()` enhances `RingFastPro`'s powerful list manipulation capabilities with a semantic interface that improves code readability and maintainability. By providing a declarative syntax while preserving the underlying C-powered performance, `FastProUpdate()` offers Ring programmers an efficient way to work with numerical data in both simple operations and complex transformations.

The range-based operations (using `:ColsFrom`, `:RowsFrom` with `:To` parameters) and the ability to chain multiple operations make `FastProUpdate()` especially powerful for matrix operations in scientific computing, image processing, and data analysis applications.
