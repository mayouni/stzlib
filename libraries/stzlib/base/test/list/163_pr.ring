# Narrative
# --------
# ExtendXT grows a list up to a target length, drawing the filler
# items from a supplied pool.
#
# Starting from [ "A", "B", "C" ] (length 3), ExtendXT( :To = 5,
# :WithItemsIn = [ "A", "B" ] ) appends items taken from the pool
# [ "A", "B" ] until the list reaches length 5. Two slots are
# missing, so the first two pool items "A" and "B" are appended,
# yielding [ "A", "B", "C", "A", "B" ]. The :To target sets the
# final size; :WithItemsIn is the source of the padding values
# (consumed in order). This is the named-parameter (XT) variant
# that makes the intent self-documenting.
#
# Extracted from stzlisttest.ring, block #163.

load "../../stzBase.ring"

pr()

Q([ "A", "B", "C" ]) {

	ExtendXT( :To = 5, :WithItemsIn = [ "A", "B" ] )
	Show()
	#--> [ "A", "B", "C", "A", "B" ]

}

pf()
# Executed in 0.06 second(s)
