# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #427.
#ERR Error (R3) : Calling Function without definition: ismadeofoneormoreofthese

load "../../stzBase.ring"

pr()

StzListQ([ "by", "except"]) { 

	? IsMadeOfOneOrMoreOfThese([ :by, :except, :stopwords ])
	#--> TRUE

	# Same as:

	? IsMadeOfSome([ :by, :except, :stopwords ])
	#--> TRUE
}

pf()
# Executed in 0.02 second(s).
