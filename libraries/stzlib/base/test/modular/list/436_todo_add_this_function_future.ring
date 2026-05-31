# Narrative
# --------
# TODO: Add this function (future)
#
# Extracted from stzlisttest.ring, block #436.

load "../../../stzBase.ring"


pr()

StzListQ([ "A" , "B", "A", "C", "A", "D", "A" ]) {
	? VizFindXT("A")
}

#--> Returns a string like this:

#	     1    2    3    4    5    6    7    8    9    0    1    2
#	  [ "A", "B", "D", "A", "C", "A", "E", "B", "D", "A", "F", "C" ]
#   "A" :  --^--------------^---------^-------------------^------------ (4)

pf()
