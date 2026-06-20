# Narrative
# --------
# Numbers / NonNumbers: pull just the numeric (or non-numeric) items out
# of a mixed list -- and the RemoveNumbers mutator.
#
# Numbers() and NonNumbers() are NON-destructive views: they return a
# filtered copy and leave the original list untouched (note Content() is
# unchanged between them). RemoveNumbers(), by contrast, mutates the list
# in place, deleting the numeric items and keeping the rest.
#
# Extracted from stzlisttest.ring, block #392.

load "../../stzBase.ring"

pr()

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
# Executed in almost 0 second(s)
