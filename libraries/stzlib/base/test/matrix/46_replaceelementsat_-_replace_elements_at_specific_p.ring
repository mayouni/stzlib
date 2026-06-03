# Narrative
# --------
# ReplaceElementsAt() - Replace elements at specific positions with a single value
#
# Extracted from stzmatrixtest.ring, block #46.
#ERR Error (R14) : Calling Method without definition: isbymanynamedparam

load "../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

o1.ReplaceElementsAt([ [1,3], [2,2], [3,1] ], :By = 0)
o1.Show()
#-->
# ┌       ┐
# │ 1 2 0 │
# │ 4 0 6 │
# │ 0 8 9 │
# └       ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
