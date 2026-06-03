# Narrative
# --------
# ReplaceSection() - Replace all elements in a section with a single value
#
# Extracted from stzmatrixtest.ring, block #49.

load "../../stzBase.ring"


pr()

o1 = new stzMatrix([
	[ 14, 20, 16 ],
	[ 14, 20, 16 ],
	[ 17, 23, 19 ],
])

? @@( o1.Section([ 1, 1 ], [ 2, 2 ]) )
#--> [ 14, 14, 20, 20 ]

o1.ReplaceSection([ 1, 1 ], [ 2, 2 ], :By = 0)
o1.Show()
#-->
# ┌          ┐
# │  0  0 16 │
# │  0  0 16 │
# │ 17 23 19 │
# └          ┘

pf()
# Executed in almost 0 second(s) in Ring 1.22
