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
*/
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


pf()
