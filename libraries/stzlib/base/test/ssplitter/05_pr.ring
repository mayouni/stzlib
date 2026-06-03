# Narrative
# --------
# pr()
#
# Extracted from stzSsplittertest.ring, block #5.

load "../../stzBase.ring"


o1 = new stzSplitter(10)

? @@( o1.SplitAfter( :Position = 9) )
#--> [ [ 1, 9 ], [ 10, 10 ] ]

? @@( o1.SplitAfter( :Position = 5) )
#--> [ [ 1, 5 ], [ 6, 10 ] ]

? @@( o1.SplitAfter([3, 7]) )
#--> [ [ 1, 3 ], [ 4, 7 ], [ 8, 10 ] ]

? @@( o1.SplitAfterSection(4, 7) )
#--> [ [ 1, 7 ], [ 8, 10 ] ]

? @@( o1.SplitAfterSection(2, 9) )
#--> [ [1, 9], [10, 10] ]

? @@( o1.SplitAfterSections([ [3,5], [7, 8] ]) )
#--> [ [ 1, 5 ], [ 6, 8 ], [ 9, 10 ] ]

? @@( o1.SplitAfter( :Sections = [ [3,5], [7, 8] ] ) )
#--> [ [ 1, 5 ], [ 6, 8 ], [ 9, 10 ] ]

? @@( o1.SplitAfter( :Section = [ 4, 6 ] ) )
#--> [ [ 1, 6 ], [ 7, 10 ] ]

? @@( o1.SplitAfter( :Sections = [ [ 4, 6 ] ] ) )
#--> [ [ 1, 6 ], [ 7, 10 ] ]

pf()
# Executed in 0.18 second(s) in Ring 1.21
# Executed in 0.19 second(s) in Ring 1.20
