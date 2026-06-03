# Narrative
# --------
# StzListOfStringsQ([ "one", "two", "three", "two", "four" ]) {
#
# Extracted from stzlistofstringstest.ring, block #56.

load "../../stzBase.ring"

	RemoveAllCS("TWO", :CaseSensitive = FALSE) 
	#--> Same as RemoveAllCS("TWO", :CS = FALSE)
	? Content() #--> [ "one","three","four" ]
}
