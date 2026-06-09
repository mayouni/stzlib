# Narrative
# --------
# Q("A":"C"){
#
# Extracted from stzGlobalTest.ring, block #43.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

	? Type()	#--> "object"
	? StzType()	#--> "stzlist"
}

QQ("A":"C"){
	? Type()	#--> "object"
	? StzType()	#--> "stzlistofstrings"
}

pf()
