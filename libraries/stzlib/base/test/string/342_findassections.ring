# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #342.

load "../../stzBase.ring"

pr()

#                        6
o1 = new stzString("*aa***aa**aa***aa*")

? @@( o1.FindAsSections("aa") ) + NL
# [ [ 2, 3 ], [ 7, 8 ], [ 11, 12 ], [ 16, 17 ] ]

? @@( o1.FindAsAntiSections("aa") ) + NL
# [ [ 1, 1 ], [ 4, 6 ], [ 9, 10 ], [ 13, 15 ], [ 18, 18 ] ]

? o1.ContainsXT( :SubString = "***", :BoundedBy = "aa") # Or ? o1.ContainsSubStringBoundedBy()
#--> TRUE

pf()
# Executed in 0.04 second(s) in Ring 1.21
# Executed in 0.18 second(s) in ring 1.18
