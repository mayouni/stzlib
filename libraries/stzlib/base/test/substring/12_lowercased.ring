# Narrative
# --------
# */
#
# Extracted from stzsubstringTest.ring, block #12.
#ERR Error (R11) : Error in class name, class not found: stzsubstring

load "../../stzBase.ring"

pr()

o1 = new stzSubString("ING", :in = "I love the RING language!")

? o1.Lowercased()
#--> I love the Ring language!

pf()
