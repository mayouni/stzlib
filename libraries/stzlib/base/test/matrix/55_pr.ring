# Narrative
# --------
# pr()
#
# Extracted from stzmatrixtest.ring, block #55.

load "../../stzBase.ring"


o1 = new stzMatrix([
    [ 1, 5, 3 ],
    [ 4, 5, 6 ],
    [ 7, 5, 9 ]
])

# Adds 2 to all elements on the matrix

o1.Add(2) # Or Multiply(:by = 2) or MultiplyBy(2)
o1.Show()
#-->
# ┌        ┐
# │ 3 7  5 │
# │ 6 7  8 │
# │ 9 7 11 │
# └        ┘

# Adds 3 to row 2
# NOTE: Rows also come first in matrix conventions

o1.Add([ 2, 3 ])
o1.Show()
#-->
# ┌          ┐
# │  2 10  6 │
# │ 24 30 36 │
# │ 14 10 18 │
# └          ┘

# Adds column 2 by the value 3

o1.Add([ 3, :ToCol = 3 ])
o1.Show()
#-->
# ┌          ┐
# │  2 30  6 │
# │ 24 90 36 │
# │ 14 30 18 │
# └          ┘

# Adds 3 in row 1

o1.Add([ 3, :ToRow = 1 ])
o1.Show()
#-->
# ┌          ┐
# │  6 90 18 │
# │ 24 90 36 │
# │ 14 30 18 │
# └          ┘

# Specify the orders of params explicitely as a suffix in the
# function name: C or R for column or Row, and V for Value

o1.AddCV(1, 3) # Column 1, then Value 3
o1.Show()

o1.AddVC(3, 1) # Value 3, then Column 1
o1.Show()
#-->
# ┌          ┐
# │ 18 90 18 │
# │ 72 90 36 │
# │ 42 30 18 │
# └          ┘

pf()
# Executed in 0.01 second(s) in Ring 1.22
