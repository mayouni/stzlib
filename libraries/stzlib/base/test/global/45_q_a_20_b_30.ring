# Narrative
# --------
# Q([ "A", 20, "B", 30 ]) {
#
# Extracted from stzGlobalTest.ring, block #45.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

	Q([ "A", 20, "B", 30 ]) {
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
