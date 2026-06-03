# Narrative
# --------
# Q([ "A", 20, [ "B" ], 30 ]){
#
# Extracted from stzGlobalTest.ring, block #46.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

	? Type()	#--> "object"
	? StzType()	#--> "stzlist"

	? @@( Types() )
	#--> [ "string", "number", "list", "number" ]
}

pf()
