# Narrative
# --------
# pr()
#
# Extracted from stzmatrixtest.ring, block #22.

load "../../stzBase.ring"

pr()

o1 = new stzMatrix([
	[ 0.05, 0.07 ],
	[ 0.30,	0.02 ]
])

o1.MultiplyBy(100)
o1.Show()
#-->
# ┌      ┐
# │  5 7 │
# │ 30 2 │
# └      ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
