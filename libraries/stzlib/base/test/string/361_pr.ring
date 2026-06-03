# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #361.

load "../../stzBase.ring"


o1 = new stzSplitter(10)

? @@( o1.SplitAtSection(3, 5) )
#--> [ [ 1, 2 ], [ 6, 10 ] ]

? @@( o1.SplitAtSectionIB(3, 5) ) + NL
#--> [ [ 1, 3 ], [ 5, 10 ] ]

#--

? @@( o1.SplitAtSection(1, 5) )
#--> [ [ 6, 10 ] ]

? @@( o1.SplitAtSectionIB(1, 5) ) + NL
#--> [ [ 5, 10 ] ]

#--

? @@( o1.SplitAtSection(5, 10) )
#--> [ [ 1, 4 ] ]

? @@( o1.SplitAtSectionIB(5, 10) )
#--> [ [ 1, 5 ] ]

pf()
# Executed in 0.02 second(s) in Ring 1.21
