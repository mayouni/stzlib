# Narrative
# --------
# ReplaceElementByManyXT() - Replace occurrences with cycling elements
#
# Extracted from stzmatrixtest.ring, block #40.

load "../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 5 ],
    [ 4, 5, 6 ],
    [ 5, 8, 9 ]
])

o1.ReplaceElement(5, :ByManyXT = [ -1, -2 ]) # Or ReplaceElementByManyXT()
o1.Show()
#-->
# ┌          ┐
# │  1  2 -1 │
# │  4 -2  6 │
# │ -1  8  9 │
# └          ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
