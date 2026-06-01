# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #294.

load "../../../stzBase.ring"


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
