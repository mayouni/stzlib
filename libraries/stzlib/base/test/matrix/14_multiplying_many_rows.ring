# Narrative
# --------
# Multiplying many rows
#
# Extracted from stzmatrixtest.ring, block #14.

load "../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 5, 5, 5 ],
    [ 7, 8, 9 ]
])

o1.MultiplyRows([1, 3], :By = 2)

o1.Show()
#-->
# ┌          ┐
# │  2  4  6 │
# │  5  5  5 │
# │ 14 16 18 │
# └          ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
