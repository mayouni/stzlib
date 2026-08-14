# Narrative
# --------
# o1 = new stzListOfStrings( functions() )
#
# Extracted from stzlistofstringstest.ring, block #25.
#ERR Error (R14) : Calling Method without definition: findfirstcs

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings( functions() )

? o1.ContainsCS("StzRaise", :CS = FALSE)	#--> TRUE
# A POSITION IN functions() CANNOT BE PROMISED. That list is every
# function the loaded library defines, so StzRaise's index moves every
# time the library grows -- it was 318 when this was written and is 903
# now. What is worth asserting is that it is FOUND, and that the thing
# found at that position really is the one asked for.
? o1.FindFirstcs("StzRaise", :CS = FALSE) > 0	#--> TRUE
? StzLower( o1.NthString( o1.FindFirstcs("StzRaise", :CS = FALSE) ) )	#--> stzraise

pf()
