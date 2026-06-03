# Narrative
# --------
# BOUNDEDBY
#
# Extracted from stzStringTest.ring, block #213.

load "../../stzBase.ring"


pr()

#                   ...4...8...2...6...2...   
o1 = new stzString("...&^^^&...&vvv&...&...")

? @@( o1.BoundedBy("&") )
#--> [ "^^^", "...", "vvv", "..." ]

? @@( o1.BoundedByIB("&") )
#--> [ "&^^^&", "&...&", "&vvv&", "&...&" ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.10 second(s) in ring 1.18
