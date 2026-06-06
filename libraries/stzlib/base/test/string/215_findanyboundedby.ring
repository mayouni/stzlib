# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #215.

load "../../stzBase.ring"

pr()

#                   ...4...8...2...6...2...   
o1 = new stzString("...&^^^&...&vvv&...&...")

? @@( o1.FindAnyBoundedBy("&") )
#--> [ 5, 9, 13, 17 ]

? @@( o1.FindAnyBoundedByIB("&") ) + NL
#--> [ 4, 8, 12, 16 ]

#--

? @@( o1.FindAnyBoundedByZZ("&") )
#--> [ [ 5, 7 ], [ 9, 11 ], [ 13, 15 ], [ 17, 19 ] ]

? @@( o1.FindAnyBoundedByIBZZ("&") ) + NL
#--> [ [ 4, 8 ], [ 8, 12 ], [ 12, 16 ], [ 16, 20 ] ]

#--

? @@( o1.BoundedBy("&") )
#--> [ "^^^", "...", "vvv", "..." ]

? @@( o1.BoundedByIB("&") )
#--> [ "&^^^&", "&...&", "&vvv&", "&...&" ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
