# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #252.
#ERR Error (R14) : Calling Method without definition: duplicatesz

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, "*", 10:12, "B", 2, 1, "*", "A", 3, "*", "B", 10:12, "B" ])
? @@( o1.DuplicatesZ() )
#--> [
#	[ 1, 	 [ 6 ] ],	# 1 is duplicated once at position 5
#	[ "*", 	 [ 7, 10 ] ],	# "*" is duplicated twice at positions 6 and 9
#	[ 10:12, [ 12 ] ],	# 10:12 is duplicated once at position 12
#	[ "B", 	 [ 11, 13 ] ]	# "B" is duplicated twice at positions 10 and 11
# ]
pf()
# Executed in almost 0 second(s).
