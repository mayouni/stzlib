# Narrative
# --------
# MultiplyRow Example
#
# Extracted from stzmatrixtest.ring, block #13.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

# Third row multiplied by 3

o1.MultiplyRow(3, :By = 3)
o1.Show()
#-->
# ┌          ┐
# │  1  2  3 │
# │  4  5  6 │
# │ 21 24 27 │
# └          ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
