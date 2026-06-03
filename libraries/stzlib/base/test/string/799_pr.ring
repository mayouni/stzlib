# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #799.

load "../../stzBase.ring"


o1 = new stzString("ring language isسلام  a nice language")

? @@( o1.PartsUsingXT( 'StzCharQ(@char).Orientation()') ) + NL
#--> [ "ring language is", "سلام", "  a nice language" ]

? @@( o1.Parts2UsingXT( 'StzCharQ(@char).Orientation()') ) + NL
#--> [
#	[ "ring language is", "lefttoright" ],
#o	[ "سلام", "righttoleft" ],
#	[ "  a nice language", "lefttoright" ]
# ]

#---

o1 = new stzString("سلام عليكم ياأهل مصر hello الكرام")

? @@( o1.PartsUsingXT( 'StzCharQ(@char).Orientation()') ) + NL #TODO // add PartitionBy() and PartionedBy()
#o--> [ "سلام", " ", "عليكم", " ", "ياأهل", " ", "مصر", " hello ", "الكرام" ]

? @@( o1.Parts2UsingXT( 'StzCharQ(@char).Orientation()') )
#o--> [
#o	[ "سلام", "righttoleft" ],
#o	[ " ", "lefttoright" ],
#o	[ "عليكم", "righttoleft" ],
#o	[ " ", "lefttoright" ],
#o	[ "ياأهل", "righttoleft" ],
#o	[ " ", "lefttoright" ],
#o	[ "مصر", "righttoleft" ],
#	[ " hello ", "lefttoright" ],
#o	[ "الكرام", "righttoleft" ]
# ]

pf()
# Executed in 0.88 second(s).
