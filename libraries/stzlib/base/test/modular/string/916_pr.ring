# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #916.

load "../../../stzBase.ring"


o1 = new stzList([ "ONE", "TWO", "TWO", "ONE", "THREE", "ONE", "THREE" ])
? @@NL( o1.SectionsOfSameItems() )
#--> [
#	[ "ONE", "ONE", "ONE" ],
#	[ "TWO", "TWO" ],
#	[ "THREE" ]
# ]

pf()
# Executed in almost 0 second(s).
