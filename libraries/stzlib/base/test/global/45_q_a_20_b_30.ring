# Narrative
# --------
# Q([ "A", 20, "B", 30 ]) {
#
# Extracted from stzGlobalTest.ring, block #45.

load "../../stzBase.ring"

	? Type()	#--> "object"
	? StzType()	#--> "stzlist"
}

QQ([ "A", 20, "B", 30 ]) {
	? Type()	#--> "object"
	? StzType()	#--> "stzlist"

	? @@( Types() )
	#--> [ "string", "number", "string", "number" ]
}
