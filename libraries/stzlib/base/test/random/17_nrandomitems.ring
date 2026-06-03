# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #17.
#ERR Error (R3) : Calling Function without definition: nrandomitemsz

load "../../stzBase.ring"

pr()

Q([ "S", "O", "F", "T", "A", "N", "Z", "A" ]) {

	? NRandomItems(3)
	#--> [ "A", "S", "Z" ]

	? @@( NRandomItemsZ(3) )
	#--> [ [ "S", 1 ], [ "A", 8 ], [ "N", 6 ] ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.23
