# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #32.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ "I", 1 ],
	[ AHeart(), 2 ],
	[ "Ring", 3 ],
	[ "Language", 4 ]
])

? o1.Rows()
#--> [ 1, 2, 3, 4 ]

pf()
# Executed in 0.02 second(s)
