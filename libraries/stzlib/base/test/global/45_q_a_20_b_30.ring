# Narrative
# --------
# Q([ "A", 20, "B", 30 ]) {
#
# Extracted from stzGlobalTest.ring, block #45.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"

pr()

	? Type()	#--> "object"
	? StzType()	#--> "stzlist"
}

QQ([ "A", 20, "B", 30 ]) {
	? Type()	#--> "object"
	? StzType()	#--> "stzlist"

	? @@( Types() )
	#--> [ "string", "number", "string", "number" ]
}

pf()
