# Narrative
# --------
# pr()
#
# Extracted from stzmatrixtest.ring, block #15.

load "../../stzBase.ring"


o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

o1.MultiplyRows([:from = 2, :to = 3], :By = 2)
o1.Show()
#-->
# ┌          ┐
# │  1  2  3 │
# │  8 10 12 │
# │ 14 16 18 │
# └          ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
