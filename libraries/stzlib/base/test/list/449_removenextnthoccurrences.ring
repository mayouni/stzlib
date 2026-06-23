# Narrative
# --------
# Removing selected later occurrences of a value, counted from an offset.
#
# The list ["A","B","A","C","A","D","A"] holds "A" at positions 1,3,5,7.
# RemoveNextNthOccurrences([2,3], :of = "A", :StartingAt = 2) scans for "A"
# from position 2 onward (the occurrences at 3,5,7), then deletes the 2nd and
# 3rd of those scanned hits -- the "A" at 5 and the "A" at 7 -- leaving
# ["A","B","A","C","D"]. The in-place mutator and the value-returning twin
# NextNthOccurrencesRemoved yield the same result; this is the classic
# Softanza pairing of a Q-block mutator with its pure functional counterpart.
#
# Extracted from stzlisttest.ring, block #449.

load "../../stzBase.ring"

pr()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	RemoveNextNthOccurrences([2, 3], :of = "A", :StartingAt = 2)
	? Content() #--> [ "A", "B", "A", "C", "D" ]
}

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? NextNthOccurrencesRemoved([2, 3], :of = "A", :StartingAt = 2)
	#--> [ "A", "B", "A", "C", "D" ]
}

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20
