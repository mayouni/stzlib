# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #632.

load "../../stzBase.ring"

pr()

StzStringQ("BCAADDEFAGTILNXV") {

	? SortedInAscending()
	#--> AAABCDDEFGILNTVX
	
	? IsSortedInAscending()
	#--> FALSE
	
	? SortedInDescending()
	#--> XVTNLIGFEDDCBAAA
	
	? IsSortedInDescending()
	#--> FALSE
	
	? SortingOrder()
	#--> :Unsorted
	
	Sort()
	? Content()
	#--> AAABCDDEFGILNTVX
	
	? SortingOrder()
	#--> :ascending
}

pf()
# Executed in 0.17 second(s) in Ring 1.21
# Executed in 0.21 second(s) in Ring 1.18
