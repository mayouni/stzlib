# Narrative
# --------
# SIMPLE METHOD NAME WITH FLEXIBLE PARAMS
#
# Extracted from stzmatrixtest.ring, block #53.

load "../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 5, 3 ],
    [ 4, 5, 6 ],
    [ 7, 5, 9 ]
])

# Multiplies all the elements by 2

o1.Multiply(2) # Or Multiply(:by = 2) or MultiplyBy(2)
o1.Show()
#-->
# ┌          ┐
# │  2 10  6 │
# │  8 10 12 │
# │ 14 10 18 │
# └          ┘

# Multiplies row 2 by the value 3
# NOTE: Rows also come first in matrix conventions

o1.Multiply([ 2, 3 ])
o1.Show()
#-->
# ┌          ┐
# │  2 10  6 │
# │ 24 30 36 │
# │ 14 10 18 │
# └          ┘

# Multiplies column 2 by the value 3

o1.Multiply([ :Col = 2, :By = 3 ])
o1.Show()
#-->
# ┌          ┐
# │  2 30  6 │
# │ 24 90 36 │
# │ 14 30 18 │
# └          ┘

# Multiplies row 1 by 3

o1.Multiply([ :Row = 1, :By = 3 ])
o1.Show()
#-->
# ┌          ┐
# │  6 90 18 │
# │ 24 90 36 │
# │ 14 30 18 │
# └          ┘

# Specify the orders of params explicitely as a suffix in the
# function name: C or R for column or Row, and V for Value

o1.MultiplyCV(1, 3) # Multiply Column 1 by Value 3
o1.Show()

o1.MultiplyVC(3, 1) # Multiply Column 1 by Value 3
o1.Show()
#-->
# ┌          ┐
# │ 18 90 18 │
# │ 72 90 36 │
# │ 42 30 18 │
# └          ┘

o1.MultiplyRV(2, 3)
o1.Show()
#-->
# ┌           ┐
# │  54 90 18 │
# │ 216 90 36 │
# │ 126 30 18 │
# └           ┘

o1.MultiplyVR(3, 2)
#-->
# ┌            ┐
# │  54 270 18 │
# │ 216 270 36 │
# │ 126  90 18 │
# └            ┘

pf()
# Executed in 0.01 second(s) in Ring 1.22
