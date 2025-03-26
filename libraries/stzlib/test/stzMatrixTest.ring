load "../max/stzmax.ring"

/*---

pr()

	# Create a 3x3 matrix
	o1 = new stzMatrix([
		[1, 2, 3],
		[4, 5, 6],
		[7, 8, 9]
	])

	o1.Show() + NL

	# Add a value to entire matrix

	o1.Add(10)
	o1.Show() + NL

	# Add to specific column

	o1.AddInCol(5, 2)
	o1.Show() + NL

	# Add to specific row
	o1.AddInRow(3, 1)
	o1.Show() + NL

	# Statistical operations

	? o1.Sum()
	? o1.Mean()
	? o1.Max()
	? o1.Min() + NL

	# Submatrix extraction

	o1.SubMatrixQ([1,3], [1,3]).Show() + NL

	# Diagonal extraction
	? @@( o1.Diagonal() ) + NL

	# Column replacement

	o1.ReplaceCol(2, [100, 200, 300])
	o1.Show()

pf()

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

o1.ReplaceCols([ 1, 3 ], [ [ 10, 20, 30 ], [ 40, 50, 60 ] ])
# Result: 
# Matrix becomes [10,2,40],[20,5,50],[30,8,60]

o1.Show()
#-->
# ┌         ┐
# │ 10 2 40 │
# │ 20 5 50 │
# │ 30 8 60 │
# └         ┘

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
*/
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
