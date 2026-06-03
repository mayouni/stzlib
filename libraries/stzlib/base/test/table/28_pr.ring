# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #28.

load "../../stzBase.ring"

pr()

o1 = new stzTable([
	[ "I", 		1, 	11, 	111 ],
	[ AHeart(), 	2, 	22, 	222 ],
	[ "Ring", 	3, 	33, 	333 ],
	[ "Language", 	4, 	44, 	444 ]
])

o1.ShowXT([ :UnderLineHeader = TRUE, :InterSectionChar = "+" ])

#-->     COL1 | COL2 | COL3 | COL4
#    ---------+------+------+-----
#           I |    1 |   11 |  111
#           ♥ |    2 |   22 |  222
#        Ring |    3 |   33 |  333
#    Language |    4 |   44 |  444

pf()
# Executed in 0.12 second(s)
