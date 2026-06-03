# Narrative
# --------
# #perf
#
# Extracted from stzlisttest.ring, block #241.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"


pr()

# Constructing a large list of 30K items

aLarge = [ 10, 20, "One", "ONE", [ :Tunis, :Paris ], 30, "two" ]

	for i = 1 to 30_000
		aLarge + ("*"+i)
	next
	
	aLarge + "in" + "out" + "IN" + "OUT"

o1 = new stzList(aLarge)
? o1.ContainsDuplicatesCS(FALSE)
#--> TRUE

? o1.NumberOfDuplicationsCS(FALSE)
#--> 3

pf()
# Executed in 6.68 second(s) in Ring 1.21
# Executed in 12.05 second(s) in Ring 1.17
