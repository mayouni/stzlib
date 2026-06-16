# Narrative
# --------
# Q([ 1:2, 5:8, 10:12 ]){
#
# Extracted from stzGlobalTest.ring, block #44.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

	Q([ 1:2, 5:8, 10:12 ]) {
	? Type()	#--> "object"
	? StzType()	#--> "stzlist"
}

# Now we start infering type at the second level:

QQ([ 1:2, 5:8, 10:12 ]){
	? Type()	#--> "object"
	? StzType()	#--> "stzlistoflists"
}

pf()
