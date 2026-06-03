# Narrative
# --------
# Multiplying the matrix by a number
#
# Extracted from stzmatrixtest.ring, block #4.

load "../../stzBase.ring"


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
