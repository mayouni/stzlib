# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #863.

load "../../../stzBase.ring"


StzStringQ("MustHave@32@Chars") {

	? NumberOfOccurrenceCS(:Of = "@", TRUE) #--> 2
	? FindAll("@") #--> [9, 12]

	? FindNext("@", :StartingAt = 5) #--> 9
	? FindNextNth(2, "@", :StartingAt = 5) #--> 12

	? FindPrevious("@", :StartingAt = 10) #--> 9
	? FindPreviousNth(2, "@", :StartingAt = 12) #--> 9
}

pf()
# Executed in 0.02 second(s).
