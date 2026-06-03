# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #69.

load "../../stzBase.ring"


o1 = new stzString("iloveringprogramminglanguage!!")

? @@( o1.FindXT("ring", :InSections = [ [3, 12] ] ) )
#--> [ 6 ]

? @@( o1.FindInSections("ring", [ [3, 12], [18, 20] ] ) )
#--> [ 6 ]

pf()
