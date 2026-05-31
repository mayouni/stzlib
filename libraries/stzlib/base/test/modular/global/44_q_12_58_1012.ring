# Narrative
# --------
# Q([ 1:2, 5:8, 10:12 ]){
#
# Extracted from stzGlobalTest.ring, block #44.

load "../../../stzBase.ring"

	? Type()	#--> "object"
	? StzType()	#--> "stzlist"
}

# Now we start infering type at the second level:

QQ([ 1:2, 5:8, 10:12 ]){
	? Type()	#--> "object"
	? StzType()	#--> "stzlistoflists"
}
