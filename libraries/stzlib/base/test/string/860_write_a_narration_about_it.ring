# Narrative
# --------
# #todo write a narration about it
#
# Extracted from stzStringTest.ring, block #860.

load "../../stzBase.ring"


pr()

o1 = new stzString("🐨")

? o1.SizeInBytes()
#--> 624

? @@NL( o1.SizeInBytesXT() )
#--> [
#	[ "RING_64BIT_LIST_STRUCTURE_SIZE", 80 ],
#	[ "RING_64BIT_ITEM_STRUCTURE_SIZE * 8", 192 ],
#	[ "RING_64BIT_ITEMS_STRUCTURE_SIZE * 8", 256 ],
#	[ "RING_64BIT_ITEMS_CONTENT_SIZE", 96 ]
# ]

pf()
# Executed in 0.06 second(s).
