# Narrative
# --------
# pr()
#
# Extracted from stzmatrixtest.ring, block #12.

load "../../stzBase.ring"

pr()

o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

o1.MultiplyCols([:from = 2, :to = 3], :By = 2)
o1.Show()
#-->
# ┌         ┐
# │ 1  4  6 │
# │ 4 10 12 │
# │ 7 16 18 │
# └         ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
