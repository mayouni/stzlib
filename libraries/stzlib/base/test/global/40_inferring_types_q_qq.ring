# Narrative
# --------
# INFERRING TYPES: Q() & QQ()
#
# Extracted from stzGlobalTest.ring, block #40.

load "../../stzBase.ring"

#NOTE: Unlike Ring, Softanza return type in lowercase.

Q("ring") {
	? Type()	#--> "object"
	? IsAnObject()	#--> TRUE
	? StzType()	#--> "stzstring"
}
