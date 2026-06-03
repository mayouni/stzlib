# Narrative
# --------
# pr()
#
# Extracted from stzSsplittertest.ring, block #3.

load "../../stzBase.ring"


o1 = new stzSplitter(10)

? @@( o1.SplitAt( :Position = 5) )
#--> [ [1, 4], [6, 10] ]

? @@( o1.SplitAt([3, 7]) )
#--> [ [ 1, 2 ], [ 4, 6 ], [ 8, 10 ] ]

? @@( o1.SplitAtSection(4, 7) )
#--> [ [ 1, 3 ], [ 8, 10 ] ]

? @@( o1.SplitAtSection(1, 9) )
#--> [ [ 10, 10 ] ]

? @@( o1.SplitAtSections([ [3,5], [7, 8] ]) )
#--> [ [1, 2], [6, 6], [9, 10] ]

? @@( o1.SplitAt( :Sections = [ [3,5], [7, 8] ] ) )
#--> [ [1, 2], [6, 6], [9, 10] ]

? @@( o1.SplitAt( :Section = [ 4, 6 ] ) )
#--> [ [ 1, 3 ], [ 7, 10 ] ]

? @@( o1.SplitAt( :Sections = [ [ 4, 6 ] ] ) )
#--> [ [ 1, 3 ], [ 7, 10 ] ]

pf()
# Executed in 0.16 second(s) in Ring 1.21
# Executed in 0.23 second(s) in Ring 1.20
