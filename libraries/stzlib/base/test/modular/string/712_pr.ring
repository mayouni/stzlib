# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #712.

load "../../../stzBase.ring"


? StringsAreEqualCS([ "abc","abc" ], TRUE )
#--> TRUE

? StringsAreEqual([ "cbad", "cbad", "cbad" ])
#--> TRUE

? BothStringsAreEqualCS("abc", "abc", TRUE)
#--> TRUE

? BothStringsAreEqual("abc", "abc")
#--> TRUE

pf()
# Executed in 0.01 second(s).
