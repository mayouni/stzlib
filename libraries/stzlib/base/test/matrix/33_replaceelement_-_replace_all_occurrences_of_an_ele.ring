# Narrative
# --------
# ReplaceElement() - Replace all occurrences of an element
#
# Extracted from stzmatrixtest.ring, block #33.

load "../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 5 ],
    [ 4, 5, 6 ],
    [ 5, 8, 9 ]
])

o1.ReplaceElement(5, :By = 0)
o1.Show()
#-->
# ┌       ┐
# │ 1 2 0 │
# │ 4 0 6 │
# │ 0 8 9 │
# └       ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
