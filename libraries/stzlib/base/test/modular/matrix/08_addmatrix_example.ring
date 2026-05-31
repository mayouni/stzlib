# Narrative
# --------
# AddMatrix Example
#
# Extracted from stzmatrixtest.ring, block #8.

load "../../../stzBase.ring"


pr()
 
o1 = new stzMatrix([
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
])

o1.AddMatrix([
    [10, 20, 30],
    [40, 50, 60],
    [70, 80, 90]
])

o1.Show()
#-->
# ┌          ┐
# │ 11 22 33 │
# │ 44 55 66 │
# │ 77 88 99 │
# └          ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
