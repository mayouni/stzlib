# Narrative
# --------
# Multiplying many cols
#
# Extracted from stzmatrixtest.ring, block #11.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 0, 3 ],
    [ 4, 0, 6 ],
    [ 7, 0, 9 ]
])

o1.MultiplyCols([1, 3], :By = 2)

o1.Show()
#-->
# ┌         ┐
# │  2 0  6 │
# │  8 0 12 │
# │ 14 0 18 │
# └         ┘

pf()
# Executed in 0.01 second(s) in Ring 1.22
