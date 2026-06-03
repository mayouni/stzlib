# Narrative
# --------
# pr()
#
# Extracted from stzSsplittertest.ring, block #2.
#ERR Error (R14) : Calling Method without definition: isatibnamedparam

load "../../stzBase.ring"

pr()

o1 = new stzSplitter(10)
? @@( o1.SplitAtSection(3, 5) )
# [ [ 1, 2 ], [ 6, 10 ] ]

? @@( o1.SplitXT( :AtSections = [ [3,5], [8,9] ] ) )
#--> [ [ 1, 2 ], [ 6, 7 ], [ 10, 10 ] ]

pf()
# Executed in 0.25 second(s) in Ring 1.21
