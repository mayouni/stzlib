# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #163.

load "../../../stzBase.ring"


Q([ "A", "B", "C" ]) {

	ExtendXT( :To = 5, :WithItemsIn = [ "A", "B" ] )
	Show()
	#--> [ "A", "B", "C", "A", "B" ]

}

pf()
# Executed in 0.06 second(s)
