# Narrative
# --------
# Q([ "A", 20, [ "B" ], 30 ]){
#
# Extracted from stzGlobalTest.ring, block #46.

load "../../stzBase.ring"

pr()

Q([ "A", 20, [ "B" ], 30 ]){
	? Type()	#--> "object"
	? StzType()	#--> "stzlist"

	? @@( Types() )
	#--> [ "string", "number", "list", "number" ]
}

pf()
