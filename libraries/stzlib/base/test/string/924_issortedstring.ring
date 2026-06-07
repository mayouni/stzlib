# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #924.
#ERR Error (R41) : Invalid numeric string

load "../../stzBase.ring"

pr()

? IsSortedString(1:5)
#--> FALSE

? IsSortedList("abc")
#--> FALSE

? IsSortedListInAscending(1:5)
#--> TRUE

? IsSortedListInDescending(5:1)
#--> TRUE

? IsSortedStringInAscending("abc")
#--> TRUE

? IsSortedStringInDescending("cba")
#--> TRUE

? StzStringQ("cba").IsSortedInDescending()
#--> TRUE

pf()
# Executed in 0.02 second(s).
