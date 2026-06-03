# Narrative
# --------
# */
#
# Extracted from stzsubstringTest.ring, block #12.

load "../../../stzBase.ring"

pr()

o1 = new stzSubString("ING", :in = "I love the RING language!")

? o1.Lowercased()
#--> I love the Ring language!

pf()
