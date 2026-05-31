# Narrative
# --------
# ReplaceElementsAtByManyXT() - Replace elements by cycling through replacement values
#
# Extracted from stzmatrixtest.ring, block #48.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

o1.ReplaceElementsAt([ [1,1], [1,3], [2,2], [3,1], [3,3] ], :ByXT = [ -1, -2 ]) # Or ReplaceElementsAtByManyXT()
o1.Show()
#-->
# ┌          ┐
# │ -1  2 -2 │
# │  4 -1  6 │
# │ -2  8 -1 │
# └          ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
