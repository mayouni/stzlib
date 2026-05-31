# Narrative
# --------
# ReplaceCols Example
#
# Extracted from stzmatrixtest.ring, block #17.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

# First and third columns replaced

o1.ReplaceCols([ 1, 3 ], :By = [ [ 10, 20, 30 ], [ 40, 50, 60 ] ])

o1.Show()
#-->
# ┌         ┐
# │ 10 2 40 │
# │ 20 5 50 │
# │ 30 8 60 │
# └         ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
