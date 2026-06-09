# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #4.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

StzNamedHashListQ(:myhash = [ :x = 10, :y = 20 ]) {

	? Name()
	#--> :myhash

	? StzType()
	#--> :stzhashlist

}

pf()
# Executed in 0.03 second(s)
