# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #387.

load "../../stzBase.ring"


o1 = new stzList([
	1982, 1964, 1992, 1982, 1964, 2001, 1982, 1992, 2000
])

? @@SP( o1.Classify() )
#--> [
# 	:1982 = [ 1, 4, 7 ],
# 	:1964 = [ 2, 5 ],
# 	:1992 = [ 3, 8 ],
# 	:2001 = [ 6 ],
# 	:2000 = [ 9 ]
#    ]

#NOTE that list items are stringified.

pf()
# Executed in 0.01 second(s).
