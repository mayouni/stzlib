# Narrative
# --------
# pr()
#
# Extracted from stzRegexTest.ring, block #26.

load "../../../stzBase.ring"


o1 = new stzRegex(pat(:url))

cMyUrl = "https://example"

? o1.MatchPartial(cMyUrl)
#--> TRUE

? o1.FindPartialMatch(cMyUrl)
#--> TRUE

? @@( o1.FindPartialMatchZZ(cMyUrl) ) + NL
#--> [ 1, 15 ]

? @@NL( o1.PartialMatchInfo("https://example") )
#--> [
#	[ "matchtype", "partial" ],
#	[ "matched", "https://example" ],
#	[ "section", [ 1, 15 ] ]
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
