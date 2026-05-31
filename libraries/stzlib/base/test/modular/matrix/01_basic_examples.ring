# Narrative
# --------
# # BASIC EXAMPLES  #
#
# Extracted from stzmatrixtest.ring, block #1.

load "../../../stzBase.ring"

#----------------#

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

o1.AddToCol(2, 5)
o1.Show() + NL
#-->
# ┌          ┐
# │ 11 17 13 │
# │ 14 20 16 │
# │ 17 23 19 │
# └          ┘

# Add to specific row

o1.AddToRow(1, 3)
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

o1.SubMatrix([ 1 , 1 ], [ 3, 2 ]).Show() + NL
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
