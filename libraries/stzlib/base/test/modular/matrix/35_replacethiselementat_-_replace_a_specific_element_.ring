# Narrative
# --------
# ReplaceThisElementAt() - Replace a specific element at a specific position
#
# Extracted from stzmatrixtest.ring, block #35.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

o1.ReplaceThisElementAt(9, [ 3, 3 ], :By = 0 )
o1.Show()
#-->
# ┌       ┐
# │ 1 2 3 │
# │ 4 5 6 │
# │ 7 8 0 │
# └       ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
