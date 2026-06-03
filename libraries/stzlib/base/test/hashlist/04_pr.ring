# Narrative
# --------
# pr()
#
# Extracted from stzhashlisttest.ring, block #4.

load "../../stzBase.ring"


StzNamedHashListQ(:myhash = [ :x = 10, :y = 20 ]) {

	? Name()
	#--> :myhash

	? StzType()
	#--> :stzhashlist

}

pf()
# Executed in 0.03 second(s)
