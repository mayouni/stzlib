# Narrative
# --------
# Q([ "A", 20, [ "B", 10 ], 30 ]){
#
# Extracted from stzGlobalTest.ring, block #47.

load "../../../stzBase.ring"

	? Type()	#--> "object"
	? StzType()	#--> "stzlist"

	? @@( Types() )
	#--> [ "string", "number", "list", "number" ]
}
