# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #336.

load "../../stzBase.ring"


o1 = new stzList([ "T", "A", "Y", "O", "U", "B", "T", "A" ])
? @@NL( o1.SectionsBetween( "T", "A" ) )
#--> [
#	["T", "A"],
#	[ "T", "A", "Y", "O", "U", "B", "T", "A" ],
#	["T", "A"]
# ]

pf()
# Executed in almost 0 second(s).
