# Narrative
# --------
# Section() and CharsInSection()
#
# Extracted from stzStringTest.ring, block #32.
#ERR Error (R14) : Calling Method without definition: charsinsection

load "../../stzBase.ring"


pr()

# Here, you cen get a section from a string
? Q("---ring---").Section(4, 7)
#--> ring

# And here you get the list of chars of that section
? Q("---ring---").CharsInSection(4, 7)
#--> [ "r", "i", "n", "g" ]

pf()
# Executed in 0.01 second(s)
