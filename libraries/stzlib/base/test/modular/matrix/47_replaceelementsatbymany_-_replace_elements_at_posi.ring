# Narrative
# --------
# ReplaceElementsAtByMany() - Replace elements at positions with corresponding values
#
# Extracted from stzmatrixtest.ring, block #47.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

o1.ReplaceElementsAt([ [1,3], [2,2], [3,1] ], :By = [ 10, 20, 30 ]) # Or ReplaceElementsAtByMany
o1.Show()
#-->
# ┌          ┐
# │  1  2 10 │
# │  4 20  6 │
# │ 30  8  9 │
# └          ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
