# Narrative
# --------
# 2x2 Matrix Determinant
#
# Extracted from stzmatrixtest.ring, block #6.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 4, 7 ],
    [ 2, 6 ]
])

? o1.Determinant()
#--> 10

pf()
# Executed in almost 0 second(s) in Ring 1.22
