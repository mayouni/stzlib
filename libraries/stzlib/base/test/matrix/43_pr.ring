# Narrative
# --------
# pr()
#
# Extracted from stzmatrixtest.ring, block #43.

load "../../stzBase.ring"


o1 = new stzMatrix([
    [ 1, 2, 5 ],
    [ 4, 5, 6 ],
    [ 5, 8, 9 ]
])

o1.Power(2)
o1.Show()
#-->
# ┌          ┐
# │  1  4 25 │
# │ 16 25 36 │
# │ 25 64 81 │
# └          ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
