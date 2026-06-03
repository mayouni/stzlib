# Narrative
# --------
# Removing facts
#
# Extracted from stzknowledgegraphtest.ring, block #2.

load "../../stzBase.ring"


pr()

oKG = new stzKnowledgeGraph("Simple")
oKG {
	AddFact("X", :RelatesTo, "Y")
	AddFact("X", :DifferentFrom, "Z")
	
	# efore removal

	? @@NL( Facts() )
	#--> [
	# 	[ "X", "relatesto", "Y" ],
	# 	[ "X", "differentfrom", "Z" ]
	# ]

	RemoveFact("X", :DifferentFrom, "Z")
	
	# After removal

	? @@NL( Facts() )
	#--> [ ["X", :RelatesTo, "Y"] ]
}

pf()

#====================#
#  QUERY INTERFACE   #
#====================#
