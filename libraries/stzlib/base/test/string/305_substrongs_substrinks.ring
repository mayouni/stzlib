# Narrative
# --------
# SUBSTRONGS & SUBSTRINKS #narration #funny
#
# Extracted from stzStringTest.ring, block #305.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"


pr()

o1 = new stzListOfStrings([
	"I", "believe", "in", "Ring", "future", "and", "engage", "for", "it!"
])

? @@( o1.SubStrongs() ) # the strings containing other strings from the list
#--> [ "Ring" ]

# In fact, "Ring" contains "in" and "in" is an item from the list

? @@( o1.SubStrinks() ) # the strings that are contained IN other strings from the list
#--> [ "in" ]

# In fact, "in" is contained in the item "Ring"

pf()
# Executed in 0.06 second(s)
