# Narrative
# --------
# #perf
#
# Extracted from stzlisttest.ring, block #239.

load "../../../stzBase.ring"


pr()

#                                         v                              v
aLarge = [ 10, 20, "One", "ONE", [ :Tunis, :Paris ], 30, "two", [ :Tunis, :Paris ] ]
#                                         ^                              ^

for i = 1 to 100_000
	aLarge + ("*"+i)
next

aLarge + "in" + "out" + "IN" + "OUT"

o1 = new stzList(aLarge)
? o1.ContainsDuplicates()
#--> TRUE

pf()
# Executed in 5.11 second(s) in Ring 1.21
# Executed in 8.32 second(s) in Ring 1.17
