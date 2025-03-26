load "../max/stzmax.ring"

/*----------------#
# BASIC EXAMPLES  #
#-----------------#
*/
pr()

# Create a 3x3 matrix
o1 = new stzMatrix([
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9]
])

o1.Show() + NL
#-->
# ┌       ┐
# │ 1 2 3 │
# │ 4 5 6 │
# │ 7 8 9 │
# └       ┘

# Add a value to entire matrix

o1.Add(10)
o1.Show() + NL
#-->
# ┌          ┐
# │ 11 12 13 │
# │ 14 15 16 │
# │ 17 18 19 │
# └          ┘

# Add to specific column

o1.AddInCol(5, 2)
o1.Show() + NL
#-->
# ┌          ┐
# │ 11 17 13 │
# │ 14 20 16 │
# │ 17 23 19 │
# └          ┘

# Add to specific row

o1.AddInRow(3, 1)
o1.Show() + NL
#-->
# ┌          ┐
# │ 14 20 16 │
# │ 14 20 16 │
# │ 17 23 19 │
# └          ┘

# Statistical operations

? o1.Sum()
#--> 159

? o1.Mean()
#--> 17.67

? o1.Max()
#--> 23

? o1.Min() + NL
#--> 14

# Submatrix extraction

o1.SubMatrixQ([ 1 , 1 ], [ 3, 2 ]).Show() + NL
#-->
# ┌       ┐
# │ 14 20 │
# │ 14 20 │
# │ 17 23 │
# └       ┘

# Diagonal extraction

? @@( o1.Diagonal() ) + NL
#--> [ 14, 20, 19 ]

# Column replacement

o1.ReplaceCol(2, :By = [ 100, 200, 300 ])
o1.Show()
#-->
# ┌           ┐
# │ 14 100 16 │
# │ 14 200 16 │
# │ 17 300 19 │
# └           ┘

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Test global matrix creation functions

pr()

? @@NL( Diagonal1Matrix([ 1, 2, 3, 4 ]) ) + NL
#--> [
#	[ 1, 0, 0, 0 ],
#	[ 2, 0, 0, 0 ],
#	[ 3, 0, 0, 0 ],
#	[ 4, 0, 0, 0 ]
# ]

? @@NL( Diagonal2Matrix([ 1, 2, 3, 4 ]) ) + NL
#--> [
#	[ 0, 0, 0, 1 ],
#	[ 0, 0, 2, 0 ],
#	[ 0, 3, 0, 0 ],
#	[ 4, 0, 0, 0 ]
# ]

? @@NL( ConstantMatrix([ 3, [2, 4] ]) )
#--> [
#	[ 3, 3, 3, 3 ],
#	[ 3, 3, 3, 3 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

o1 = new stzMatrix([
	[ 58,   64 ],
	[ 139, 154 ]
])

o1.Show()
#-->
# ┌         ┐
# │  58  64 │
# │ 139 154 │
# └         ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Multiplying the matrix by a number

pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 1, 2, 3 ],
    [ 1, 2, 3 ]
])

o1.MultiplyBy(3)
o1.Show()
#-->
# ┌       ┐
# │ 3 6 9 │
# │ 3 6 9 │
# │ 3 6 9 │
# └       ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Multiplying two matrices

pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ]
])

o1.MultiplyBy([
    [  7,  8 ],
    [  9, 10 ],
    [ 11, 12 ]
])

o1.Show()
#-->
# ┌         ┐
# │  58  64 │
# │ 139 154 │
# └         ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- 2x2 Matrix Determinant

pr()

o1 = new stzMatrix([
    [ 4, 7 ],
    [ 2, 6 ]
])

? o1.Determinant()
#--> 10

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- 3x3 Matrix Inversion

pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 0, 1, 4 ],
    [ 5, 6, 0 ]
])

o1.Inverse()
o1.Show()
#-->
# ┌            ┐
# │ -24  18  5 │
# │  20 -15 -4 │
# │  -5   4  1 │
# └            ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*=== AddMatrix Example

pr()
 
o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

o1.AddMatrix([
    [10, 20, 30],
    [40, 50, 60],
    [70, 80, 90]
])

o1.Show()
#-->
# ┌          ┐
# │ 11 22 33 │
# │ 44 55 66 │
# │ 77 88 99 │
# └          ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- MultiplyByInCol Example

pr()
 
o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

# Second column multiplied by 2

o1.MultiplyByInCol(2, 2)

o1.Show()
#-->
# ┌        ┐
# │ 1  4 3 │
# │ 4 10 6 │
# │ 7 16 9 │
# └        ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- MultiplyByInRow Example

pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

# Third row multiplied by 3

o1.MultiplyByInRow(3, 3)
# Result: 
# Matrix becomes [1,2,3],[4,5,6],[21,24,27]

o1.Show()
#-->
# ┌          ┐
# │  1  2  3 │
# │  4  5  6 │
# │ 21 24 27 │
# └          ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- ReplaceCols Example

pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

# First and third columns replaced

o1.ReplaceCols([ 1, 3 ], :By = [ [ 10, 20, 30 ], [ 40, 50, 60 ] ])

o1.Show()
#-->
# ┌         ┐
# │ 10 2 40 │
# │ 20 5 50 │
# │ 30 8 60 │
# └         ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

? IsListOfNonZeroPositiveNumbers([ 100, 200, 300 ])
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- ReplaceRow Example

pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

# Second row replaced

o1.ReplaceRow(2, [ 100, 200, 300 ])

o1.Show()
#-->
# ┌             ┐
# │   1   2   3 │
# │ 100 200 300 │
# │   7   8   9 │
# └             ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- AddInDiagonal Example
*/
pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

# Main diagonal elements increased by 10

o1.AddInDiagonal(10)

o1.Shwo() # Note this is misspelled form of Show() but Softanza understands it!
#-->
# ┌          ┐
# │ 11  2  3 │
# │  4 15  6 │
# │  7  8 19 │
# └          ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Diagonal2 Example

pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

? @@( o1.Diagonal2() )
#--> [ 3, 5, 7 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*---

pr()

o1 = new stzMatrix([
	[ 0.05, 0.07 ],
	[ 0.30,	0.02 ]
])

o1.MultiplyBy(100)
o1.Show()
#-->
# ┌      ┐
# │  5 7 │
# │ 30 2 │
# └      ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Using Diff()

pr()

# Let's say we have a time series representing daily temperatures:

o1 = new stzMatrix([
	[ 20, 22, 21, 23, 25 ], # day 1
	[ 18, 20, 17, 25, 28 ], # day 2
	[ 19, 17, 14, 23, 34 ] # day 3
])

# Calculating temparture differences

? @@NL( o1.Diff() )
#--> [
#	[  2, -1, 2,  2 ],
#	[  2, -3, 8,  3 ],
#	[ -2, -3, 9, 11 ]
# ]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Using SubMean()
*/
pr()

# Consider a matrix of students' test scores

o1 = new stzMatrix([
	[ 80, 85, 90 ],
	[ 70, 75, 80 ],
	[ 60, 65, 70 ]
])

# Scores Adjusted by Row Mean

o1.SubMean() # Or SubtractMean()

o1.Show()
#-->
# ┌        ┐
# │ -5 0 5 │
# │ -5 0 5 │
# │ -5 0 5 │
# └        ┘

#~> This centers the scores around 0 for each student group.

pf()
# Executed in 0.02 second(s) in Ring 1.22


/*---------------------#
#  PRACTICAL EXAMPLES  #
#----------------------#

/*--- Example 1: Financial Portfolio Analysis
*/
pr()
	# Assume a 3-asset portfolio with historical returns for 5 time periods

	oRetMx = new stzMatrix([

		[  0.02,  0.03, -0.01 ],
		[  0.01, -0.02,  0.04 ],
		[  0.03,  0.01,  0.02 ],
		[ -0.01,  0.04,  0.03 ],
		[  0.02, -0.01,  0.01 ]

	])
	
	# Compute average returns for each asset

	? oRetMx.Mean()
	
	# Compute portfolio variance (sum of squared deviations)

	oRetMx.SubMean().Power(2).Sum()
	? "Portfolio Variance: " + variance

/*-- Example 2: Image Processing Simulation

pr()
	# Simulating a 3x3 grayscale image as a matrix
	image = new stzMatrix([
		[100, 150, 200],
		[50, 100, 150],
		[0, 50, 100]
	])
	
	# Apply brightness increase by adding 50 to all pixels
	image.Add(50)
	image.Show()
	
	# Apply an edge detection filter (simple difference operation)
	edges = image.Diff()
	edges.Show()

/--- Example 3: Neural Network Weight Simulation

pr()
	# Initialize weight matrix (3 neurons, 4 inputs)
	weights = new stzMatrix([
		[0.5, -0.2, 0.3, 0.1],
		[0.1, 0.4, -0.5, 0.2],
		[-0.3, 0.2, 0.6, -0.1]
	])
	
	# Input vector (1 sample, 4 features)
	input = new stzMatrix([
		[1.0, -0.5, 0.2, 0.4]
	])
	
	# Compute weighted sum (dot product simulation)
	output = input.Mul(weights.Transpose())
	? "Neural Network Output: "
	output.Show()


