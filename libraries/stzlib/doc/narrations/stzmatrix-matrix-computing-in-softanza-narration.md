# Matrix Computing in Softanza with stzMatrix

## Introduction

Matrices are the unsung heroes of computational problem-solving, powering everything from data analysis to image processing and machine learning. Whether you're transforming coordinates in computer graphics, training neural networks, or analyzing large datasets, matrix operations form the foundation of modern computational techniques.

The Softanza library for the Ring programming language simplifies these complex operations with its `stzMatrix` class—a powerful, user-friendly tool that blends efficiency with elegance. Unlike working with raw lists or arrays, `stzMatrix` provides:

- Intuitive methods for common matrix operations
- Clear visualization of matrix data
- Mathematical rigor for complex calculations
- Consistent syntax that scales with complexity

All while maintaining Ring's accessible programming style. In this article, we'll explore `stzMatrix` through practical examples that demonstrate how it can streamline your numerical computing tasks across various domains.

> **Note**: `stzMatrix` is implemented using the efficient C-based `RingFastPro` extension, providing performance benefits for computationally intensive operations.

## Getting Started with stzMatrix

Creating and working with matrices in `stzMatrix` is straightforward. Before diving into operations, let's clarify an important convention: Matrix indexing in Softanza is one-based, meaning the first row and column are indexed as 1, not 0.

Let's start with a simple 3x3 matrix:

```ring
load "stzlib.ring"

# Create a 3x3 matrix
mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

# Display the matrix in a visually clear format
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

This example demonstrates the basic pattern we'll follow throughout this article: create a matrix, perform operations, and visualize the results. The `Show()` method displays the matrix in a clean, readable format that makes it easy to understand the data's structure.

## Basic Matrix-Wide Operations

The most common matrix operations apply transformations to every element. `stzMatrix` makes these operations intuitive with methods that affect the entire structure at once.

### Addition and Multiplication

Let's explore some fundamental operations that you might use in data preprocessing or signal analysis:

```ring
# Add 10 to all elements (e.g., a temperature offset)
mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

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

This operation might represent adding a constant offset to every data point—useful when normalizing measurements or adjusting baselines.

For scaling operations, multiplication works similarly:

```ring
# Multiply the matrix by a scalar
mx = new stzMatrix([
    [1, 2, 3],
    [1, 2, 3],
    [1, 2, 3]
])

mx.Multiply(3)		# Or MultiplyBy(3) or even Multiply(:By = 3)
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

This kind of scaling is essential in many applications, from normalizing datasets to adjusting signal strengths or applying uniform transformations.

These basic operations form the foundation of matrix manipulations—they're direct, intuitive, and applicable to many common tasks in data processing and mathematical modeling.

## Working With Specific Rows and Columns

After applying operations to the entire matrix, you'll often need to focus on specific parts. `stzMatrix` provides targeted methods for row and column operations, which are essential for working with structured data.

### Adding Values to Rows

When you need to adjust values in a specific row—perhaps to normalize a particular dataset dimension—you can use dedicated row operations:

```ring
# Add 3 to row 1
mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

mx.Add([ 1, 3 ]) # Adds 3 to row 1
mx.Show()
```

Output:

```
┌       ┐
│ 4 5 6 │
│ 4 5 6 │
│ 7 8 9 │
└       ┘
```

This syntax follows matrix coordinate conventions, where row indexes come before column indexes. For better readability, you can also use these alternative forms:

- `AddToRow(1, 3)`
- `Add([ :Row = 1, 3 ])` or `Add([ :ToRow = 1, 3 ])`
- `Add([ 3, :ToRow = 1 ])`

### Adding Values to Columns

Similarly, you can target specific columns. This is particularly useful when working with tabular data where columns represent different variables:

```ring
# Add 5 to column 2
mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

mx.Add([ :Col = 2, 5 ])	# Or AddToCol(2, 5)
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

Alternative syntaxes include:
- `AddToCol(2, 5)`
- `Add([ :Col = 2, 5 ])` or `Add([ :ToCol = 2, 5 ])`
- `Add([ 5, :ToCol = 2 ])`

### Explicit Parameter Order Definition

If you prefer more predictable method calls, especially in complex programs, you can explicitly define the parameter order in the method name:

```ring
mx.AddCV(2, 5)	# C stands for Column, V for Value
```

Or specify it in the reverse order:

```ring
mx.AddVC(5, 2)	# V stands for Value, C for Column 
```

This explicit naming convention can make code more readable when you're performing many different operations with various parameters.

### Multiplying Rows and Columns

To multiply elements in a specific row by a value—perhaps scaling a particular feature in your dataset—you use similar syntax:

```ring
mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

mx.Multiply([ 3, 2 ]) # Multiplies row 3 by 2
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

For better readability, you can use alternative forms like `Multiply([ :Row = 3, :By = 2 ])` or `MultiplyRow(3, :By = 2)`.

For column operations:

```ring
mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

mx.Multiply([ :Col = 3, :By = 2 ]) # Multiplies column 3 by 2
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

You can also write this as `MultiplyCol(3, 2)`, `MultiplyCol(3, :By = 2)`, `MultiplyCV(3, 2)`, or `MultiplyVC(2, 3)`.

### Advanced Selection with Lists and Ranges

As your data manipulation needs become more complex, you'll often need to target multiple rows or columns simultaneously. This is where `stzMatrix` really shines, allowing you to work with sets of rows or columns using list notation:

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

This capability is invaluable when working with structured data where certain columns represent related variables that need the same transformation—like normalizing both latitude and longitude columns in geospatial data.

For rows, you would use `MultiplyRows([ 2, 3 ], :By = 2 )` to multiply all elements in rows 2 and 3 by 2.

When you need to work with sequential ranges, you can use the intuitive `:From` and `:To` keywords:

```ring
# Multiply rows 2 to 3 by 2
mx = new stzMatrix([
    [  0, 1,  2,  3 ],
    [  0, 4,  5,  6 ],
    [  0, 7,  8,  9 ]
])

mx.MultiplyRows([:From = 2, :To = 3], :By = 2)
mx.Show()
```

Output:

```
┌            ┐
│ 0  1  2  3 │
│ 0  8 10 12 │
│ 0 14 16 18 │
└            ┘
```

The same range syntax works for columns: `MultiplyCols([:From = 2, :To = 3], :By = 2)` multiplies all elements in columns 2 and 3 by 2.

## Statistical Functions

Data analysis often requires quick statistical insights. `stzMatrix` offers built-in statistical functions that operate directly on the matrix data:

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

These functions provide immediate insights into your data's characteristics. For example:

- `Sum()` is useful for calculating totals in financial data or aggregating measurements
- `Mean()` helps identify the central tendency of your dataset
- `Max()` and `Min()` quickly identify outliers or boundaries

In data analysis workflows, these quick metrics can help verify data normalization or identify anomalies without writing additional analysis code.

## Special Matrix Creation

Many scientific and mathematical applications require specific matrix types. `stzMatrix` provides factory functions to create these specialized matrices easily:

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

Diagonal matrices are essential in many applications, from solving systems of linear equations to representing scaling transformations in computer graphics.

For a secondary diagonal matrix (values along the opposite diagonal):

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

And when you need a matrix with uniform values throughout:

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

These factory functions generate matrix structures that you can then pass to the `stzMatrix` constructor. They save significant time when initializing specific matrix types commonly used in numerical algorithms and scientific computing.

## Element Transformations

As we progress to more advanced matrix manipulations, we often need to transform specific elements based on various conditions. Let's explore how `stzMatrix` handles these transformations while maintaining its intuitive approach.

### Basic Element Replacement

For straightforward element replacements, such as replacing error codes or standardizing values:

```ring
# Replace all 5s with 0
mx = new stzMatrix([
    [1, 2, 5],
    [4, 5, 6],
    [5, 8, 9]
])

mx.ReplaceElement(5, :By = 0) # Or Repalce(5, :By = 0) or Replace(5, 0)
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

This operation is particularly useful for data cleaning tasks, such as replacing missing values or standardizing categorical data.

### Position-Based Replacement

When you need precise control over a specific location in your matrix:

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

This capability is essential when dealing with known outliers or specific data points that require special treatment, such as removing noise from sensor readings or correcting known errors.

### Advanced Replacement Using Sequences

For more sophisticated transformations, you can replace values with sequences—useful for encoding categorical values or implementing complex transformations:

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

Which you can also write as `Replace([ 5, :ByMany = [-1, -2, -3] ])`.

Output:

```
┌          ┐
│  1  2 -1 │
│  4 -2  6 │
│ -3  8  9 │
└          ┘
```

This is particularly useful for encoding categorical values or applying different transformations to the same value based on its position in the data.

For repeating patterns (where replacement values cycle when exhausted):

```ring
# Cycle [-1, -2] for each 5
mx = new stzMatrix([
    [1, 2, 5],
    [4, 5, 6],
    [5, 8, 9]
])

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

Notice how the parameter names evolve logically from `:By` to `:ByMany` to `:ByManyXT` as operations become more complex, while maintaining a consistent syntax pattern.

## Working With Matrix Segments

Many practical applications require focusing on specific portions of a matrix—such as regions of interest in image processing or subsets of data in analysis. In Softanza, a segment of a matrix is called a `Section`.

### Matrix Sections

To extract or manipulate specific sections of your matrix:

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

It's important to understand how sections are extracted: elements are read in row-major order (across rows, then down columns) within the specified bounds. In the example above, the section spans rows 1-2 and columns 1-2, resulting in four elements being extracted in this order.

You can also modify specific sections:

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

This operation is incredibly useful for tasks like masking regions of interest in image processing, zeroing out specific areas in data analysis, or applying localized transformations.

### Submatrices

When you need to extract a true rectangular submatrix as a new matrix object:

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

This creates a new `stzMatrix` object containing just the specified rows and columns—perfect for focusing on a subset of data for separate processing or analysis. Unlike a section, which returns elements as a flat list, a submatrix preserves the matrix structure.

In machine learning applications, this might be used to extract feature subsets or process regions of interest separately, while maintaining the spatial relationships between elements.

## Advanced Matrix Operations

As we move into more sophisticated linear algebra operations, the syntax remains consistent even as the mathematical complexity increases. These operations form the backbone of many computational and scientific applications.

### Matrix Multiplication

Matrix multiplication is essential in many fields, from computer graphics to machine learning:

```ring
# Multiply matrices
mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6]
])

# Note: For matrix multiplication to work, the number of columns in the first matrix
# must equal the number of rows in the second matrix
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

Note how we reuse the familiar `MultiplyBy()` method, but now with a matrix parameter instead of a scalar. This operation is fundamental in transforming coordinates in computer graphics, applying weights in neural networks, or compressing data in dimensionality reduction algorithms.

### Matrix Addition

Similarly, adding matrices follows naturally from adding scalars:

```ring
mx = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

# Note: For matrix addition, both matrices must have the same dimensions
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

This operation is useful for combining multiple datasets, adding offset values in signal processing, or superimposing patterns in graphics applications.

### Determinant and Inverse

For more advanced linear algebra operations, `stzMatrix` maintains the same clean approach:

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

The determinant is a scalar value that provides important information about a square matrix, such as whether it's invertible (non-zero determinant) or singular (zero determinant). This calculation is crucial when solving systems of linear equations or analyzing transformations in space.

For matrix inversion:

```ring
# Invert a matrix (requires a non-singular square matrix)
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

Matrix inversion is essential in solving systems of equations (A⁻¹Ax = A⁻¹b) and is widely used in fields ranging from economics to engineering. It's worth noting that if you attempt to invert a singular matrix (one with zero determinant), an error will occur—this is a mathematical constraint, not a limitation of the library.

## Finding Elements

Locating specific values in your matrix is a common need in data analysis. `stzMatrix` provides intuitive methods for finding elements:

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

This returns a list of coordinates where the value 99 appears, making it easy to locate specific values or patterns. This capability is invaluable for identifying outliers, locating specific markers in datasets, or finding cells that meet certain criteria.

The search functionality naturally extends to multiple values:

```ring
# Find both 88s and 99s
mx = new stzMatrix([
    [80, 85, 99],
    [70, 88, 80],
    [99, 65, 88]
])

? @@(mx.FindElements([88, 99]))
```

Output:

```
[[2, 2], [3, 3], [1, 3], [3, 1]]
```

This feature is particularly useful when you need to locate multiple categories or values of interest simultaneously.

## Data Analysis Features

Beyond basic matrix operations, `stzMatrix` offers specialized tools for data analysis that follow the same direct approach we've seen throughout. These features make it particularly valuable for statistical applications and data preprocessing.

### Difference Calculation

Calculating differences between adjacent elements is crucial in time series analysis, trend detection, and gradient computation:

```ring
# Create a matrix representing temperature readings over time
tempMatrix = new stzMatrix([
    [20, 22, 21, 23, 25],  # Location 1
    [18, 20, 17, 25, 28],  # Location 2
    [19, 17, 14, 23, 34]   # Location 3
])

# Calculate differences between adjacent readings
? @@NL(tempMatrix.Diff())
```

Output:

```
[
    [2, -1, 2, 2],   # Changes in Location 1
    [2, -3, 8, 3],   # Changes in Location 2
    [-2, -3, 9, 11]  # Changes in Location 3
]
```

This function computes the differences between adjacent elements in each row, revealing trends or anomalies in sequential data. In this example, it shows how temperatures changed between consecutive time points at each location.

### Mean Centering

Normalizing data around its mean is a critical preprocessing step in many statistical analyses and machine learning tasks:

```ring
# Create a matrix of test scores
scores = new stzMatrix([
    [80, 85, 90],  # Student 1
    [70, 75, 80],  # Student 2
    [60, 65, 70]   # Student 3
])

# Center the data around the mean
scores.SubMean()
scores.Show()
```

Output:

```
┌        ┐
│ 5 0 -5 │
│ 5 0 -5 │
│ 5 0 -5 │
└        ┘
```

By centering the data around its mean, subsequent analyses can focus on the variations rather than the absolute values. This is particularly important in statistical modeling, principal component analysis, and many machine learning algorithms where the scale of the data matters less than its distribution.

## Syntactic Flexibility: The Power of Choice

Throughout this exploration of `stzMatrix`, you've seen how the API naturally scales from simple to complex operations. This progression gives you the flexibility to choose the syntax that best fits your needs and coding style. Let's recap the syntax patterns that make this possible:

| Pattern Type | Description | Example | Use Case |
|--------------|-------------|---------|----------|
| **Simple method calls** | Direct, whole-matrix operations | `mx.Add(10)` | Basic transformations |
| **Direct target specification** | Operations on specific rows/columns | `mx.AddToCol(2, 5)` | Targeted adjustments |
| **Named parameters** | Explicit parameter descriptions | `mx.MultiplyRow(3, :By = 3)` | Self-documenting code |
| **List and range targeting** | Multi-target operations | `mx.MultiplyCols([1, 3], :By = 2)` | Batch processing |
| **Extended transformation options** | Complex replacements | `mx.ReplaceElement(5, :ByMany = [-1, -2, -3])` | Advanced data encoding |

This progressive approach to syntax ensures that simple operations remain simple to code, while more complex tasks have the expressiveness they need. You can start with the most basic approach for straightforward operations, then adopt more descriptive syntax as your requirements grow in complexity.

## Conclusion

The `stzMatrix` class transforms matrix operations from a potential programming challenge into a strength of the Ring language. Its syntax evolves naturally with your needs—from straightforward methods for basic tasks to expressive, flexible parameters for complex operations.

This design philosophy allows you to start with the simplest approach and gradually adopt more powerful features as your requirements grow. Whether you're:

- Preprocessing data for analysis
- Implementing mathematical algorithms
- Building simulations
- Developing machine learning models
- Processing images or signals

`stzMatrix` adapts to your workflow rather than forcing you to adapt to it.

For developers working in fields like data science, scientific computing, or machine learning, `stzMatrix` offers a particularly valuable combination of performance and expressiveness. Its consistent API makes complex matrix operations accessible without sacrificing mathematical rigor.

By mastering this elegant API, you can spend less time wrestling with implementation details and more time solving the real problems that matter to your users and projects.