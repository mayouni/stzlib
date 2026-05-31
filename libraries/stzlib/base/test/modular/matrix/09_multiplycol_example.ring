# Narrative
# --------
# MultiplyCol Example
#
# Extracted from stzmatrixtest.ring, block #9.

load "../../../stzBase.ring"


pr()
 
o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

# Second column multiplied by 2

o1.MultiplyCol(2, :By = 2)

o1.Show()
#-->
# ┌        ┐
# │ 1  4 3 │
# │ 4 10 6 │
# │ 7 16 9 │
# └        ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
