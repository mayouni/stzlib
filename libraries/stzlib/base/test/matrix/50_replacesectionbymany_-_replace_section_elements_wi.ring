# Narrative
# --------
# ReplaceSectionByMany() - Replace section elements with multiple values
#
# Extracted from stzmatrixtest.ring, block #50.
#ERR Error (R14) : Calling Method without definition: isbymanynamedparam

load "../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

# Replace section from [1,1] to [2,3] with values [10, 20, 30, 40, 50, 60]
o1.ReplaceSection(:From = [1,1], :To = [2,3], :ByMany = [ 10, 20, 30, 40, 50, 60 ])
o1.Show()
#-->
# ┌         ┐
# │ 10 40 3 │
# │ 20 50 6 │
# │ 30 60 9 │
# └         ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
