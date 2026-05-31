# Narrative
# --------
# ReplaceRow Example
#
# Extracted from stzmatrixtest.ring, block #19.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

# Second row replaced

o1.ReplaceRow(2, [ 100, 200, 300 ])

o1.Show()
#-->
# ┌             ┐
# │   1   2   3 │
# │ 100 200 300 │
# │   7   8   9 │
# └             ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
