# stzFastPro: A Semantic Interface for List Manipulation in Ring

## Introduction

RingFastPro provides essential high-performance list operations in Ring through C-based optimization. The stzFastPro library builds upon this foundation by offering a semantic interface that maintains RingFastPro's computational efficiency while providing a more declarative syntax. This approach enhances the developer experience without compromising on performance advantages. The stzFastPro library was originally motivated by its use in the stzMatrix class, where a more intuitive interface for matrix operations was needed.

## Core Commands Structure in stzFastPro

stzFastPro supports a comprehensive set of operations through its `FastProUpdate()` function. Here's the basic structure:

```ring
FastProUpdate(aList, :Command = [ parameters... ])
```

The main commands include operations like setting values, adding, subtracting, multiplying, dividing, copying, and merging elements within lists and matrices. Let's explore each with practical examples.

## Setting Values

### Setting Specific Rows or Columns

When working with matrices, you'll often need to modify entire rows or columns. stzFastPro makes this straightforward:

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

The equivalent in the original RingFastPro would be:
```ring
RFP_SetRowValue(aMatrix, 2, 0)
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

The equivalent RingFastPro code:
```ring
RFP_SetColValue(aMatrix, 2, 0)
```

### Setting Multiple Rows or Columns

stzFastPro allows for operating on multiple rows or columns in a single command:

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

The equivalent RingFastPro requires a loop or multiple calls:
```ring
for i = 2 to 3
    RFP_SetRowValue(aMatrix, i, 5)
next
```

### Setting All Elements

Setting all elements in a list or matrix is also simplified:

```ring
aMatrix = 1:7

# Set all elements to value 5
FastProUpdate(aMatrix, :set = [ :all = :with = 5 ])
```

This results in:
```
[ 5, 5, 5, 5, 5, 5, 5 ]
```

The RingFastPro equivalent would require iteration:
```ring
for i = 1 to len(aMatrix)
    aMatrix[i] = 5
next
```

## Addition Operations

Adding values to specific portions of a matrix becomes intuitive:

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

In RingFastPro, this would require:
```ring
RFP_AddValueToCols(aMatrix, 8, 1, 2)
```

## Subtraction Operations

Similarly, subtraction operations become more readable:

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

The RingFastPro version:
```ring
RFP_SubtractValueFromCols(aMatrix, 10, 1, 3)
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

The RingFastPro equivalent:
```ring
RFP_MultiplyColBy(aMatrix, 2, 2)
```

You can also store the result in a different column:

```ring
# Multiply column 2 by 2 and store in column 3
FastProUpdate(aMatrix, :Multiply = [ :Col = 2, :By = 2, :ToCol = 3 ])
```

This operation is particularly useful for preserving original data while calculating new values.

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

RingFastPro equivalent:
```ring
RFP_DivideColBy(aMatrix, 2, 2)
```

## Multiple Operations in a Single Call

One of the most powerful features of stzFastPro is the ability to chain multiple operations in a single call. This is ideal for complex transformations:

```ring
# Create a matrix to simulate image data with RGB channels
aImage = [
    [255, 100, 50],   # R, G, B for pixel 1
    [200, 150, 75],   # R, G, B for pixel 2
    [180, 90, 120]    # R, G, B for pixel 3
]
   
# Perform grayscale conversion with multiple steps
FastProUpdate(aImage, [
    :Multiply = [ :Col = 1, :By = 0.3, :ToCol = 1 ],     # R *= 0.3
    :Multiply = [ :Col = 2, :By = 0.59, :ToCol = 1 ],    # G *= 0.59
    :Multiply = [ :Col = 3, :By = 0.11, :ToCol = 1 ],    # B *= 0.11
    :Merge = [ :Cols = [ 1, 2 ], :InCol = 1 ],           # R += G
    :Merge = [ :Cols = [ 1, 2 ], :InCol = 1 ],           # R += B
    :Copy  = [ :Row = 1, :ToRow = 3],                    # G = R (grayscale)
    :Copy  = [ :Col = 1, :toCol = 2]                     # B = R (grayscale)
])
```

This example demonstrates how stzFastPro can handle complex image processing operations like grayscale conversion in a single, readable command. The RingFastPro equivalent would require multiple separate function calls and temporary variables.

## Performance with Large Datasets

Despite its more semantic interface, stzFastPro maintains the performance advantages of RingFastPro, even with large datasets:

```ring
# Create a 1D list with 1 million elements and set all to 1000
aList = 1:1_000_000
FastProUpdate(aList, :set = [ :items, :with = 1000 ])
# Executed in 0.15 second(s) in Ring 1.22
```

The RingFastPro equivalent:
```ring
RFP_FillList(aList, 1000)
```

## Conclusion

stzFastPro enhances RingFastPro's powerful list manipulation capabilities with a semantic interface that improves code readability and maintainability. By providing a declarative syntax while preserving the underlying C-powered performance, stzFastPro offers Ring developers an efficient way to work with numerical data in both simple operations and complex transformations.

Originally motivated by its use in the stzMatrix class, stzFastPro has evolved into a powerful tool for matrix manipulation, image processing, and general list operations. The semantic approach allows developers to express their intent more clearly, resulting in code that is easier to write, read, and maintain without sacrificing the performance benefits of the underlying RingFastPro implementation.