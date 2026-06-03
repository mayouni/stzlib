# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #633.

load "../../stzBase.ring"


Q("AAABCDDEFGILNTVX") {
	IsSorted() 
	#--> TRUE

	? SortingOrder()
	#--> :Ascending
}

Q("XVTNLIGFEDDCBAAA") {
	IsSorted()
	#--> TRUE

	SortingOrder()
	#--> :Descending
}

pf()
# Executed in 0.16 second(s) in Ring 1.21
# Executed in 0.32 second(s) in Ring 1.18
# Executed in 0.74 second(s) in Ring 1.17
