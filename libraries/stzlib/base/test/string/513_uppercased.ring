# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #513.
#ERR Error (R3) : Calling Function without definition: stzlistofstringsq

load "../../stzBase.ring"

pr()

aStzStrList = StzListOfStringsQ([ "one", "two", "three" ]).ToListOfStzStrings()

foreach oStr in aStzStrList
	? oStr.Uppercased()
next
#-- [ "ONE", "TWO", "THREE" ]

pf()
# Executed in 0.02 second(s).
