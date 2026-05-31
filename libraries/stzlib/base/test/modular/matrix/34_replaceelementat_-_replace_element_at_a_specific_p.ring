# Narrative
# --------
# ReplaceElementAt() - Replace element at a specific position
#
# Extracted from stzmatrixtest.ring, block #34.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

o1.ReplaceElementAt([ 3, 3 ], :By = 0 )
o1.Show()
#-->
# ┌       ┐
# │ 1 2 3 │
# │ 4 5 6 │
# │ 7 8 0 │
# └       ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
