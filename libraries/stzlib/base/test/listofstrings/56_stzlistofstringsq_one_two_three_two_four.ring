# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #56.

load "../../stzBase.ring"

pr()

StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {

	RemoveAllCS("TWO", :CaseSensitive = FALSE) 
	#--> Same as RemoveAllCS("TWO", :CS = FALSE)
	? Content() #--> [ "one","three","four" ]
}

pf()
