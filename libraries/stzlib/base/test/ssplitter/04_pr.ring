# Narrative
# --------
# pr()
#
# Extracted from stzSsplittertest.ring, block #4.

load "../../stzBase.ring"


o1 = new stzSplitter(10)

? @@( o1.SplitBefore( :Position = 10) )
#--> [ [ 1, 9 ], [ 10, 10 ] ]

? @@( o1.SplitBefore( :Position = 5) )
#--> [ [1, 4], [5, 10] ]

? @@( o1.SplitBefore([3, 7]) )
#--> [ [ 1, 2 ], [ 3, 6 ], [ 7, 10 ] ]

? @@( o1.SplitBeforeSection(4, 7) )
#--> [ [ 1, 3 ], [ 4, 10 ] ]

? @@( o1.SplitBeforeSection(1, 9) )
#--> [ [ 1, 10 ] ]

? @@( o1.SplitBeforeSections([ [3,5], [7, 8] ]) )
#--> [ [ 1, 2 ], [ 3, 6 ], [ 7, 10 ] ]

? @@( o1.SplitBefore( :Sections = [ [3,5], [7, 8] ] ) )
#--> [ [ 1, 2 ], [ 3, 6 ], [ 7, 10 ] ]

? @@( o1.SplitBefore( :Section = [ 4, 6 ] ) )
#--> [ [ 1, 3 ], [ 4, 10 ] ]

? @@( o1.SplitBefore( :Sections = [ [ 4, 6 ] ] ) )
#--> [ [ 1, 3 ], [ 4, 10 ] ]

pf()
# Executed in 0.20 second(s) in Ring 1.21
