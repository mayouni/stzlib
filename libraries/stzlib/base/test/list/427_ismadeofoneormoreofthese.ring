# Narrative
# --------
# Checks that a list is composed only of items found in a larger candidate set.
#
# IsMadeOfOneOrMoreOfThese asks whether every element of the host list
# (here [ "by", "except" ]) is present in the provided candidate list
# ([ :by, :except, :stopwords ]). Since both "by" and "except" appear in
# the candidate set, the answer is TRUE. The host need not use every
# candidate -- it just must not contain anything outside the set.
# IsMadeOfSome is the shorter alias for the same subset-membership test.
#
# Extracted from stzlisttest.ring, block #427.

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
