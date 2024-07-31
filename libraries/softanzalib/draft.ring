load "stzProfsys.ring"

pron()

? MSize(1:10_000_000)
#--> 590_000_080 (BYTES)

? BytesToGigaBytes(590_000_080) + NL
#--> 0.55 (GB)

? MSize32(1:10_000_000)
#--> 350_000_048 (BYTES)

? BytesToGigaBytes(350_000_048)
#--> 0.33 (GB)

proff()
# Executed in 7.64 second(s).

/*----

? MSize([ "NULL", "@noname", "20", 2, "number" ])
#--> 510 (MB)

? MSizeXT([ "NULL", "@noname", "20", 2, "number" ])
#--> [
#	[ "RING_64BIT_LIST_STRUCTURE_SIZE", 	  80 ],
# 	[ "RING_64BIT_ITEM_STRUCTURE_SIZE * 5",  120 ],
#	[ "RING_64BIT_ITEMS_STRUCTURE_SIZE * 5", 160 ],
#	[ "RING_64BIT_ITEMS_CONTENT_SIZE", 	  22 ]
# ]

/*---

pron()

? MSize(1:100_000_000)
#--> 590_000_080 (BYTES)

? BytesToGigaBytes(5_900_000_080)
#--> 5.49 (GB)

proff()
# Executed in 80.59 second(s).

/*---
*/
