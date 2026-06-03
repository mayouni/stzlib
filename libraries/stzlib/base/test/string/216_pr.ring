# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #216.

load "../../stzBase.ring"


#                   ...4...8...2...6...2...   
o1 = new stzString("...&^^^&...&vvv&...&...")

? @@( o1.BoundedByIBZ("&") )
#--> [ [ "&^^^&", 4 ], [ "&vvv&", 12 ] ]

? @@( o1.BoundedByIBZZ("&") )
#--> [ [ "&^^^&", [ 4, 8 ] ], [ "&vvv&", [ 12, 16 ] ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
