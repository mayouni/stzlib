# Working with Matrices in Softanza

In modern numerical computing, matrix operations are indispensable. The **stzMatrix** class in the Softanza library for Ring offers a robust and high-performance solution for managing and manipulating matrices. This guide walks you through its extensive features, practical examples, and real-world applications—from basic matrix creation to advanced machine learning tasks.

---

## Creating and Displaying Matrices

Matrix creation is the first step in any data manipulation process. With stzMatrix, you can create matrices effortlessly and display them in an intuitive, well-formatted way.

### Basic Matrix Creation

The following example demonstrates how to create a 3×3 matrix and display it using the `Show()` method. Notice the neat output formatting that makes it easier to visualize the matrix data.

```ring
# Create a 3x3 matrix
o1 = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

# Display the matrix
o1.Show()
```

Output:
```
┌       ┐
│ 1 2 3 │
│ 4 5 6 │
│ 7 8 9 │
└       ┘
```

### Special Matrix Creation Functions

Softanza also includes utility functions for generating matrices with specific patterns, such as diagonal matrices or constant matrices. These functions save time and ensure consistency when working with common matrix types.

For example, creating a matrix with values on the first column:

```ring
# Create a matrix with values on the first column
? @@NL(Diagonal1Matrix([1, 2, 3, 4]))
```

Output:
```
[
    [1, 0, 0, 0],
    [2, 0, 0, 0],
    [3, 0, 0, 0],
    [4, 0, 0, 0]
]
```

Similarly, you can create matrices with values on the secondary diagonal or generate constant matrices:

```ring
# Create a matrix with values on the secondary diagonal
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
# Create a constant matrix with specified dimensions
? @@NL(ConstantMatrix([3, [2, 4]]))
```

Output:
```
[
    [3, 3, 3, 3],
    [3, 3, 3, 3]
]
```

---

## Arithmetic Operations

Arithmetic operations are at the heart of matrix manipulation. The stzMatrix class offers various methods for element-wise and structural operations, making it straightforward to perform both simple and complex calculations.

### Addition Operations

#### Adding a Scalar to an Entire Matrix

You can add a constant value to every element in the matrix with the `Add()` method, transforming the matrix uniformly.

```ring
# Add a value to the entire matrix
o1 = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])
o1.Add(10)
o1.Show()
```

Output:
```
┌          ┐
│ 11 12 13 │
│ 14 15 16 │
│ 17 18 19 │
└          ┘
```

#### Targeted Addition: Columns, Rows, and Diagonals

For more granular control, you can add values to specific columns, rows, or even diagonal elements. This flexibility allows for fine-tuning matrix transformations.

Adding to a specific column:

```ring
# Add to specific column
o1.AddInCol(5, 2)
o1.Show()
```

Output:
```
┌          ┐
│ 11 17 13 │
│ 14 20 16 │
│ 17 23 19 │
└          ┘
```

Adding to a specific row:

```ring
# Add to specific row
o1.AddInRow(3, 1)
o1.Show()
```

Output:
```
┌          ┐
│ 14 20 16 │
│ 14 20 16 │
│ 17 23 19 │
└          ┘
```

Even if there’s a minor typo in the command (as in `Shwo()`), Softanza’s interpreter corrects it seamlessly:

```ring
# Add to diagonal elements
o1 = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])
o1.AddInDiagonal(10)
o1.Shwo() # Note: Despite the typo, Softanza understands this command
```

Output:
```
┌          ┐
│ 11  2  3 │
│  4 15  6 │
│  7  8 19 │
└          ┘
```

### Matrix Addition and Multiplication

In addition to scalar operations, you can perform whole-matrix addition and multiplication, further broadening the potential for complex computations.

#### Matrix Addition

```ring
o1 = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])
o1.AddMatrix([
    [10, 20, 30],
    [40, 50, 60],
    [70, 80, 90]
])
o1.Show()
```

Output:
```
┌          ┐
│ 11 22 33 │
│ 44 55 66 │
│ 77 88 99 │
└          ┘
```

#### Scalar and Column/Row Multiplication

Scalar multiplication, as well as selective column and row multiplication, is equally straightforward. These operations are particularly useful in applications such as image processing or financial modeling where proportional changes are applied.

Multiplying an entire matrix by a scalar:

```ring
# Multiply entire matrix by a scalar
o1 = new stzMatrix([
    [1, 2, 3],
    [1, 2, 3],
    [1, 2, 3]
])
o1.MultiplyBy(3)
o1.Show()
```

Output:
```
┌       ┐
│ 3 6 9 │
│ 3 6 9 │
│ 3 6 9 │
└       ┘
```

Multiply a specific column:

```ring
# Multiply a column by a value
o1 = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])
o1.MultiplyCol(2, :By = 2)
o1.Show()
```

Output:
```
┌        ┐
│ 1  4 3 │
│ 4 10 6 │
│ 7 16 9 │
└        ┘
```

And similar methods exist for multiplying multiple columns, a range of columns, rows, or even the whole matrix during matrix multiplication.

---

## Statistical and Transformational Operations

Beyond basic arithmetic, stzMatrix facilitates a range of statistical operations and transformations that are invaluable in data analysis.

### Statistical Operations

The built-in functions allow you to quickly compute summary statistics such as the sum, mean, maximum, and minimum of all matrix elements.

```ring
o1 = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])

# Sum of all elements
? o1.Sum()
# Output: 45

# Mean of all elements
? o1.Mean()
# Output: 5.0

# Maximum value
? o1.Max()
# Output: 9

# Minimum value
? o1.Min()
# Output: 1
```

### Matrix Transformations

Transformation functions like submatrix extraction, diagonal extraction, difference calculation, and mean subtraction are essential for breaking down data sets and preparing them for further analysis.

#### Extracting Submatrices and Diagonals

```ring
o1 = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])
o1.SubMatrixQ([1, 1], [3, 2]).Show()
```

Output:
```
┌       ┐
│ 1 2   │
│ 4 5   │
│ 7 8   │
└       ┘
```

Extracting the main and secondary diagonals:

```ring
o1 = new stzMatrix([
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9]
])
? @@(o1.Diagonal())
# Output: [1, 5, 9]

? @@(o1.Diagonal2())
# Output: [3, 5, 7]
```

#### Calculating Differences and Mean Subtraction

For time series data or trend analysis, you might need to calculate the difference between consecutive elements:

```ring
# Time series example
o1 = new stzMatrix([
    [20, 22, 21, 23, 25], # day 1
    [18, 20, 17, 25, 28], # day 2
    [19, 17, 14, 23, 34]  # day 3
])
? @@NL(o1.Diff())
```

Output:
```
[
    [2, -1, 2, 2],
    [2, -3, 8, 3],
    [-2, -3, 9, 11]
]
```

Subtracting the mean across rows standardizes data, which is crucial in normalization processes:

```ring
o1 = new stzMatrix([
    [80, 85, 90],
    [70, 75, 80],
    [60, 65, 70]
])
o1.SubMean()
o1.Show()
```

Output:
```
┌        ┐
│ -5 0 5 │
│ -5 0 5 │
│ -5 0 5 │
└        ┘
```

---

## Advanced Matrix Operations

For more complex mathematical tasks, the stzMatrix class provides operations for computing determinants, inverses, and handling element replacement.

### Determinant and Inversion

Computing the determinant and inverse of matrices is vital for solving systems of linear equations and performing advanced numerical simulations.

```ring
o1 = new stzMatrix([
    [4, 7],
    [2, 6]
])
? o1.Determinant()
# Output: 10
```

Inverting a matrix, even when dealing with larger datasets, is made efficient by the underlying C-based implementation:

```ring
o1 = new stzMatrix([
    [1, 2, 3],
    [0, 1, 4],
    [5, 6, 0]
])
o1.Inverse()
o1.Show()
```

Output:
```
┌            ┐
│ -24  18  5 │
│  20 -15 -4 │
│  -5   4  1 │
└            ┘
```

### Replacement and Searching Operations

Replacing elements or subsets of a matrix based on conditions or positions is handled seamlessly. Additionally, you can quickly locate specific values or patterns within a matrix, a useful feature for data cleaning and pre-processing.

#### Basic and Advanced Replacement

Basic element replacement:

```ring
o1 = new stzMatrix([
    [1, 2, 5],
    [4, 5, 6],
    [5, 8, 9]
])
o1.ReplaceElement(5, :By = 0)
o1.Show()
```

Output:
```
┌       ┐
│ 1 2 0 │
│ 4 0 6 │
│ 0 8 9 │
└       ┘
```

Advanced replacement techniques allow multiple substitutions or targeted replacements based on element positions, enabling flexible matrix editing.

#### Searching for Elements, Rows, and Columns

Finding elements or entire rows/columns that match specific criteria simplifies tasks such as data extraction or filtering:

```ring
o1 = new stzMatrix([
    [88, 85, 99],
    [70, 88, 80],
    [99, 65, 99]
])
? @@(o1.FindElements([88, 99]))
```

Output:
```
[[1, 1], [2, 2], [1, 3], [3, 1], [3, 3]]
```

Similar functions exist for locating rows and columns, which can then be modified or analyzed further.

---

## Practical Applications with Code Examples

The versatility of stzMatrix shines in real-world applications. Here are some scenarios where you can apply these matrix operations effectively.

### Data Analysis

#### Time Series Analysis

Using matrix operations to analyze time series data is straightforward. The following example demonstrates how to compute daily changes in temperature and extract meaningful insights such as maximum increases or specific drops in temperature.

```ring
# Creating a matrix of temperature data
temperatures = new stzMatrix([
    [20, 22, 21, 23, 25], # day 1
    [18, 20, 17, 25, 28], # day 2
    [19, 17, 14, 23, 34]  # day 3
])

# Calculate day-to-day changes
dailyChanges = temperatures.Diff()

# Find the largest temperature increase
maxIncrease = new stzMatrix(dailyChanges).Max()
? "Maximum temperature increase: " + maxIncrease

# Find days with temperature drops
? "Temperature drops occurred at: " 
? @@(new stzMatrix(dailyChanges).FindElement(-3))
```

#### Data Normalization

Matrix operations simplify data normalization tasks. In this example, student test scores are adjusted by subtracting the mean, followed by identifying students with consistently above-average scores.

```ring
# Student test scores across three subjects
scores = new stzMatrix([
    [80, 85, 90], # Student 1
    [70, 75, 80], # Student 2
    [60, 65, 70]  # Student 3
])

# Normalize scores by subtracting the mean
scores.SubMean()

# Find students performing above average in all subjects
? "Students with above-average performance in all subjects:"
for i = 1 to scores.RowCount()
    if scores.Row(i)[1] > 0 and scores.Row(i)[2] > 0 and scores.Row(i)[3] > 0
        ? "Student " + i
    ok
next
```

### Image Processing

For image processing, stzMatrix enables pixel-level operations such as contrast enhancement, brightness adjustment, and thresholding. In the following code snippet, a small grayscale image is processed and converted into a binary image.

```ring
# Simulating a small grayscale image (3x3 pixels)
image = new stzMatrix([
    [100, 150, 100],
    [50, 200, 50],
    [100, 150, 100]
])

# Applying contrast enhancement
image.Power(1.2)

# Applying brightness adjustment
image.Add(20)

# Thresholding the image (binary conversion)
for i = 1 to image.RowCount()
    for j = 1 to image.ColCount()
        if image.Element(i, j) > 180
            image.ReplaceElementAt([i, j], :By = 255)
        else
            image.ReplaceElementAt([i, j], :By = 0)
        ok
    next
next

# Display the processed image
image.Show()
```

### Financial Analysis

Matrix operations are essential for financial data manipulation. In this example, stock returns are transformed into percentages and used to calculate an approximate covariance between companies.

```ring
# Stock returns for 3 companies over 4 months
returns = new stzMatrix([
    [0.05, 0.07, -0.02, 0.03], # Company A
    [0.02, -0.01, 0.04, 0.02], # Company B
    [0.03, 0.02, 0.01, -0.02]  # Company C
])

# Convert to percentage for easier reading
returns.MultiplyBy(100)
returns.Show()

# Calculate correlation between companies
# (Simplified implementation - actual correlation would need more steps)
meanCentered = new stzMatrix(returns.Content())
meanCentered.SubMean()

# Calculate covariance (simplified)
covAB = 0
for i = 1 to meanCentered.ColCount()
    covAB += meanCentered.Element(1, i) * meanCentered.Element(2, i)
next
covAB = covAB / meanCentered.ColCount()

? "Approximate covariance between Company A and B: " + covAB
```

### Machine Learning Applications

The power of stzMatrix extends to machine learning. Two examples—linear regression and K-means clustering—illustrate how the class can be integrated into algorithmic implementations.

#### Linear Regression Implementation

Linear regression is implemented using the normal equation, showcasing how matrix inversion and multiplication come together to solve for model weights.

```ring
# Training data (X values and Y targets)
X = new stzMatrix([
    [1, 2],
    [1, 3],
    [1, 4],
    [1, 5]
]) # First column is bias term

Y = [14, 20, 22, 30]

# Calculate weights using Normal Equation: W = (X'X)^-1 X'Y
# Step 1: Calculate X transpose
Xt = new stzMatrix(X.Transpose())

# Step 2: Calculate X'X
XtX = new stzMatrix(Xt.Content())
XtX.MultiplyBy(X.Content())

# Step 3: Calculate inverse of X'X
XtX.Inverse()

# Step 4: Calculate X'Y
XtY = []
for i = 1 to Xt.RowCount()
    sum = 0
    for j = 1 to Xt.ColCount()
        sum += Xt.Element(i, j) * Y[j]
    next
    add(XtY, sum)
next

# Step 5: Calculate weights W = (X'X)^-1 * X'Y
W = []
for i = 1 to XtX.RowCount()
    sum = 0
    for j = 1 to XtX.ColCount()
        sum += XtX.Element(i, j) * XtY[j]
    next
    add(W, sum)
next

? "Linear Regression Weights: " + @@(W)

# Make predictions for new data points
newX = [1, 6] # Testing with X = 6
prediction = W[1] * newX[1] + W[2] * newX[2]
? "Prediction for X = 6: " + prediction
```

#### K-Means Clustering (Simplified)

This example demonstrates a basic implementation of K-means clustering. By calculating the Euclidean distance between data points and centroids, you can assign clusters and begin the iterative refinement process.

```ring
# Sample dataset
data = new stzMatrix([
    [2, 3],
    [3, 4],
    [9, 8],
    [8, 9],
    [1, 2]
])

# Initialize centroids (manually for this example)
centroids = new stzMatrix([
    [2, 3], # Centroid 1
    [8, 8]  # Centroid 2
])

# Function to calculate Euclidean distance
func distance(p1, p2)
    return sqrt(pow(p1[1] - p2[1], 2) + pow(p1[2] - p2[2], 2))
endfunc

# One iteration of K-means
clusters = []
for i = 1 to data.RowCount()
    point = data.Row(i)
    minDist = 999999
    cluster = 0
    
    for c = 1 to centroids.RowCount()
        dist = distance(point, centroids.Row(c))
        if dist < minDist
            minDist = dist
            cluster = c
        ok
    next
    
    add(clusters, cluster)
next

? "Point assignments to clusters: " + @@(clusters)
```

---

## Performance Considerations

The stzMatrix class is not only rich in functionality but also highly optimized. It leverages the ringFastPro C-based extension to achieve significant performance gains over pure Ring implementations. This efficiency is crucial when processing large matrices or running computationally intensive operations such as matrix multiplication, inversion, and determinant calculation.

For instance, creating a large matrix and applying an element-wise power operation is performed swiftly:

```ring
# Creating a large matrix for performance demonstration
largeMatrix = []
for i = 1 to 100
    row = []
    for j = 1 to 100
        add(row, random(100))
    next
    add(largeMatrix, row)
next

o1 = new stzMatrix(largeMatrix)

# Time-consuming operation made efficient by C implementation
startTime = clock()
o1.Power(2)
endTime = clock()

? "Time taken to square each element: " + (endTime - startTime) + " seconds"
```

---

## Conclusion

The stzMatrix class in Softanza is a comprehensive toolset for all your matrix operations in Ring. Its intuitive API combined with the performance benefits of a C-based backend makes it suitable for a wide range of applications—from simple arithmetic operations to sophisticated data analysis, image processing, financial modeling, and machine learning algorithms.