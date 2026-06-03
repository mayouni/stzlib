# Narrative
# --------
# ReplaceThisElementInSection() - Replace specific value in a section with another value
#
# Extracted from stzmatrixtest.ring, block #51.
#ERR Error (R14) : Calling Method without definition: isbymanynamedparam

load "../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 5, 3 ],
    [ 4, 5, 6 ],
    [ 7, 5, 9 ]
])

o1.ReplaceElementInSection(5, :From = [1,1], :To = [3,2], :By = 0)
o1.Show()
#-->
# ┌       ┐
# │ 1 0 3 │
# │ 4 0 6 │
# │ 7 0 9 │
# └       ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
