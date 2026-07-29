# Narrative
# --------
# 3x3 Matrix Inversion
#
# Extracted from stzmatrixtest.ring, block #7.

load "../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 0, 1, 4 ],
    [ 5, 6, 0 ]
])

o1.Invert()	# the VERB mutates in place; Inverse() returns the data instead
o1.Show()
#-->
# ┌            ┐
# │ -24  18  5 │
# │  20 -15 -4 │
# │  -5   4  1 │
# └            ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
