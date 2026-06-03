# Narrative
# --------
# #perf
#
# Extracted from stzlisttest.ring, block #240.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"


pr()

aLarge = [ 10, 20, "One", "ONE", [ :Tunis, :Paris ], 30, "two" ]

	for i = 1 to 30_000
		aLarge + ("*"+i)
	next

aLarge + "in" + "out" + "IN" + "OUT"

o1 = new stzList(aLarge)
? o1.ContainsDuplicates()
#--> FALSE

pf()
# Executed in 4.89 second(s).
