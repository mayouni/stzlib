# Narrative
# --------
# pr()
#
# Extracted from stzmatrixtest.ring, block #39.

load "../../stzBase.ring"

pr()

o1 = new stzMatrix([
    [ 1, 2, 5 ],
    [ 4, 5, 6 ],
    [ 5, 8, 9 ]
])

o1.ReplaceElement(5, :ByMany = [ -1, -2 ]) # Or ReplaceElementByMany()
o1.Show()
#-->
# ┌          ┐
# │  1  2 -1 │
# │  4 -2  6 │
# │  5  8  9 │
# └          ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
