# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #163.
#ERR Error (R3) : Calling Function without definition: extendxt

load "../../stzBase.ring"

pr()

Q([ "A", "B", "C" ]) {

	ExtendXT( :To = 5, :WithItemsIn = [ "A", "B" ] )
	Show()
	#--> [ "A", "B", "C", "A", "B" ]

}

pf()
# Executed in 0.06 second(s)
