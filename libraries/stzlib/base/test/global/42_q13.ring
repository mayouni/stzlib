# Narrative
# --------
# Q(1:3) {
#
# Extracted from stzGlobalTest.ring, block #42.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

	Q(1:3) {
	? Type()	#--> "object"
	? StzType()	#--> "stzlist"
}

QQ(1:3) {
	? Type()	#--> "object"
	? StzType()	#--> "stzlistofnumbers"
}

pf()
