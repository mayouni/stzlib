# Narrative
# --------
# FindNth(n, value) returns the position of the n-th occurrence of a
# given value inside a stzList.
#
# Here a small heterogeneous list (strings, numbers, a 1:3 range, and
# the "heart" emoji appearing twice) is grown to a million-plus items
# to show the lookup stays direct. Asking for the 2nd occurrence of
# the "heart" value walks the list and reports position 7 -- the index
# of the second matching element, not a zero-based or count value.
# This is the occurrence-aware sibling of Find(), letting you skip
# past earlier matches to address a specific repeat.
#
# Extracted from stzlisttest.ring, block #270.

load "../../stzBase.ring"

pr()

aList = [ "A", 10, "A", "♥", 20, 1:3, "♥", "B" ]
aLarge = aList

for i = 1 to 1_000_000
	aLarge + i
next

o1 = new stzList(aList)
? o1.FindNth(2, "♥")
#--> 7

pf()
# Executed in 0.15 second(s) in Ring 1.21 (64 bits)
# Executed in 0.17 second(s) in Ring 1.19 (64 bits)
# Executed in 0.20 second(s) in Ring 1.19 (32 bits)
# Executed in 0.26 second(s) in Ring 1.18
# Executed in 0.24 second(s) in Ring 1.17
