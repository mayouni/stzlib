# Narrative
# --------
# ReplaceTheseElementsAtByMany() - Replace specific elements at specific positions
#
# Extracted from stzmatrixtest.ring, block #41.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 5 ],
    [ 4, 5, 6 ],
    [ 5, 8, 9 ]
])

o1.ReplaceTheseElementsAtByMany([ 2, 8 ], [ [ 1, 2 ], [ 3, 2 ] ], [ -1, -2 ])
o1.Show()
#-->
# ┌        ┐
# │ 1 -1 5 │
# │ 4  5 6 │
# │ 5 -2 9 │
# └        ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
