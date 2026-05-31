# Narrative
# --------
# ReplaceTheseElementsAtByManyXT() - Replace specific elements at specific positions with cycling
#
# Extracted from stzmatrixtest.ring, block #42.

load "../../../stzBase.ring"


pr()

o1 = new stzMatrix([
    [ 1, 2, 5 ],
    [ 4, 5, 6 ],
    [ 5, 8, 9 ]
])

o1.ReplaceTheseElementsAtByManyXT(
	[ 2, 5, 8 ],
	[ [ 1, 2 ], [ 2, 2 ], [ 3, 2 ] ],
	[ -1, -2 ]
)
o1.Show()
#-->
# ┌        ┐
# │ 1 -1 5 │
# │ 4 -2 6 │
# │ 5 -1 9 │
# └        ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
