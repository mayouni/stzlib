# Narrative
# --------
# FINDIND PARTiAL MATCHES
#
# Extracted from stzRegexTest.ring, block #25.

load "../../../stzBase.ring"


pr()

o1 = new stzRegex("^https?://[\w-]+(\.[\w-]+)*\.\w{2,}$")

? o1.PartialMatch("http")
#--> TRUE

? o1.FindPartialMatch("http")
#--> 1

? @@( o1.FindPartialMatchZZ("http") ) + NL
#--> [ 1, 4 ]

? @@NL( o1.PartialMatchInfo("http") )
#--> [
#	[ "matchtype", "partial" ],
#	[ "matched", "http" ],
#	[ "section", [ 1, 4 ] ]
# ]

pf()
