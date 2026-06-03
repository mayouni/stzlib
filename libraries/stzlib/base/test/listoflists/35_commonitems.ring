# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #35.

load "../../stzBase.ring"

pr()

o1 = new stzListOfLists([
	[ "Ring", "Ruby", "Python" ],
	[ "Julia", "Ring", "Go", "Python" ],
	[ "C#", "PHP", "Python", "Ring" ]
])

? o1.CommonItems() # Same as Intersection()
#--> [ "Ring", "Pyhton" ]

pf()
# Executed in 0.11 second(s)
