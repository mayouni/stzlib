# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #392.

load "../../stzBase.ring"


StzListQ([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]) {

	? Numbers() #--> [ 1, 2, 3, 4, 5 ]
	# You can also say ? OnlyNumbers()

	? NonNumbers() # [ "A", "B", "C", "D" ]
	# You can also say OnlyNonNumbers()

	? Content()
	#--> [ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]

	# NOTE that the list is not altered by Numbers() and
	# NonNumbers() functions.

	# Now we alter it by removing numbers

	RemoveNumbers() #--> You can also say RemoveOnlyNumbers()
	? Content()
	#--> [ "A", "B", "C", "D" ] 
}

pf()
# Executed in almost 0 second(s).
