# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #393.

load "../../../stzBase.ring"


StzListQ([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]) {

	? NonNumbers()	# You can also say ? OnlyNonNumbers()
	#--> [ "A", "B", "C", "D" ]
	
	RemoveNonNumbers() # Or RemoveOnlyNonNumbers() or RemoveAllExceptNumbers()
	? Content()
	#--> [ 1, 2, 3, 4, 5 ]

}

pf()
# Executed in almost 0 second(s).
