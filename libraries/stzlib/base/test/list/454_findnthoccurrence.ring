# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #454.

load "../../stzBase.ring"

pr()

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {

	? FindNthOccurrence(3, :Of = "A") + NL
	#--> 7

	ReplaceNthOccurrence(3, :Of = "A", :With = "#")
	? Content()
	#--> [ "A", "B", "C", "A", "D", "B", "#" ]

}

pf()
# Executed in 0.01 second(s) in Ring 1.21
