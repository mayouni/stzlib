# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #68.

load "../../stzBase.ring"


o1 = new stzString("iloveringprogramminglanguage!!")

? @@( o1.FindInSection("ring", 18, 22) )
#--> []

? @@( o1.FindInSection("ring", 3, 12) )
#--> [ 6 ]

? @@( o1.FindXT("ring", :InSection = [ 3, 12] ) )
#--> [ 6 ]

pf()
