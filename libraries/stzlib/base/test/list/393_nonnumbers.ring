# Narrative
# --------
# NonNumbers (view) and RemoveNonNumbers (mutator): the complement of
# block #392.
#
# NonNumbers() returns the non-numeric items without touching the list;
# RemoveNonNumbers() then deletes them in place, leaving only the numbers.
# Several spellings mean the same thing (RemoveOnlyNonNumbers,
# RemoveAllExceptNumbers) -- Softanza's near-natural-language aliasing.
#
# Extracted from stzlisttest.ring, block #393.

load "../../stzBase.ring"

pr()

StzListQ([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ]) {

	? NonNumbers()	# You can also say ? OnlyNonNumbers()
	#--> [ "A", "B", "C", "D" ]

	RemoveNonNumbers() # Or RemoveOnlyNonNumbers() or RemoveAllExceptNumbers()
	? Content()
	#--> [ 1, 2, 3, 4, 5 ]

}

pf()
# Executed in almost 0 second(s)
