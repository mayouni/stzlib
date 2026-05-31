# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #541.

load "../../../stzBase.ring"


StzListQ([ "one", "two", "three" ]) {

	ReplaceItemAtPosition(2, :With = "TWO") # or ReplaceAt
	? Content()
	#--> [ "one", "TWO", "three" ]

	ReplaceAllItems( :With = "***")
	? Content()
	#--> [ "***", "***", "***" ]
}

pf()
# Executed in almost 0 second(s).
