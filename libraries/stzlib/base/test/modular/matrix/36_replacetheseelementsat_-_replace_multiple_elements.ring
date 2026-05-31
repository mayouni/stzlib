# Narrative
# --------
# ReplaceTheseElementsAt() - Replace multiple elements at specific positions
#
# Extracted from stzmatrixtest.ring, block #36.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

o1.ReplaceTheseElementsAt([ 9, 2 ], [ [ 3, 3 ], [ 1, 2 ] ], :By = 0 )
o1.Show()
#-->
# ┌       ┐
# │ 1 0 3 │
# │ 4 5 6 │
# │ 7 8 0 │
# └       ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
