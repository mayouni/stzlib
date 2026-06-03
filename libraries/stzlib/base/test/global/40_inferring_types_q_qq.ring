# Narrative
# --------
# INFERRING TYPES: Q() & QQ()
#
# Extracted from stzGlobalTest.ring, block #40.

load "../../stzBase.ring"

pr()

#NOTE: Unlike Ring, Softanza return type in lowercase.

Q("ring") {
	? Type()	#--> "object"
	? IsAnObject()	#--> TRUE
	? StzType()	#--> "stzstring"
}

pf()
