# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #8.

load "../../stzBase.ring"

pr()

StzNamedObjectQ(:myobj = TRUEObject()) {

	? Name()
	#--> :myobj

	? StzType()
	#--> :stznumber

}

pf()
# Executed in 0.03 second(s)
