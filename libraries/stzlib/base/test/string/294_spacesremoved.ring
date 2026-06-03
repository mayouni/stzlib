# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #294.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([" r   in g", "r ing", "  r     i ng  "])
? o1.SpacesRemoved()
#--> [ "ring", "ring", "ring" ]

# Content of the string remained the same, because ...ed() functions
# work on a copy of it.

o1.RemoveSpaces()
? o1.Content()
#--> [ "ring", "ring", "ring" ]

pf()
# Executed in 0.03 second(s)
